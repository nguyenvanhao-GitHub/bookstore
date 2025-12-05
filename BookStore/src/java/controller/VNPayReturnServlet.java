package controller;

import config.VNPayConfig;
import dao.CartDAO;
import dao.OrderDAO;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@WebServlet("/VNPayReturnServlet")
public class VNPayReturnServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        try {
            // 1. Lấy tham số từ VNPay trả về
            Map<String, String> fields = new HashMap<>();
            for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
                String fieldName = params.nextElement();
                String fieldValue = request.getParameter(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    fields.put(fieldName, fieldValue);
                }
            }

            // 2. Xác thực chữ ký (Checksum)
            if (fields.containsKey("vnp_SecureHashType")) fields.remove("vnp_SecureHashType");
            if (fields.containsKey("vnp_SecureHash")) fields.remove("vnp_SecureHash");
            
            boolean signValid = VNPayConfig.verifyPayment(fields);

            // 3. Xử lý kết quả
            if (signValid) {
                String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
                String vnp_TxnRef = request.getParameter("vnp_TxnRef"); // Mã đơn hàng
                String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");

                if ("00".equals(vnp_ResponseCode)) {
                    // --- THANH TOÁN THÀNH CÔNG ---
                    
                    @SuppressWarnings("unchecked")
                    Map<String, String> orderInfo = (Map<String, String>) session.getAttribute("orderInfo");

                    if (orderInfo != null) {
                        // Lưu đơn hàng
                        OrderDAO orderDAO = new OrderDAO();
                        boolean saved = orderDAO.saveVNPayOrder(orderInfo, vnp_TransactionNo);

                        if (saved) {
                            String email = orderInfo.get("email");
                            double total = Double.parseDouble(orderInfo.get("total"));

                            // Xóa giỏ hàng
                            CartDAO cartDAO = new CartDAO();
                            cartDAO.clearCart(email);

                            // Gửi email
                            try {
                                String subject = "Thanh toán thành công - Đơn hàng #" + vnp_TxnRef;
                                String content = buildEmailContent(orderInfo.get("fullName"), vnp_TxnRef, vnp_TransactionNo, total);
                                EmailUtils.sendEmail(email, subject, content);
                            } catch (Exception ex) {
                                ex.printStackTrace();
                            }

                            // Xóa session và báo thành công
                            session.removeAttribute("orderInfo");
                            showSuccessAlert(out, vnp_TxnRef, vnp_TransactionNo, total);
                        } else {
                            showErrorAlert(out, "Lỗi Lưu Đơn Hàng", "Thanh toán thành công nhưng lỗi khi lưu vào hệ thống.");
                        }
                    } else {
                        // Trường hợp mất session (ví dụ thanh toán quá lâu)
                        showErrorAlert(out, "Hết phiên làm việc", "Không tìm thấy thông tin đơn hàng trong Session.");
                    }
                } else {
                    // --- THANH TOÁN THẤT BẠI ---
                    String errorMsg = VNPayConfig.getResponseMessage(vnp_ResponseCode);
                    showErrorAlert(out, "Thanh toán thất bại", errorMsg);
                }
            } else {
                showErrorAlert(out, "Lỗi Bảo Mật", "Chữ ký không hợp lệ!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            showErrorAlert(out, "Lỗi Hệ Thống", e.getMessage());
        }
    }

    private String buildEmailContent(String name, String orderId, String transId, double total) {
        return "<div style='font-family: Arial; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>"
             + "<h2 style='color: #28a745;'>Thanh toán thành công!</h2>"
             + "<p>Xin chào <b>" + name + "</b>,</p>"
             + "<p>Đơn hàng <b>#" + orderId + "</b> của bạn đã được thanh toán thành công qua VNPay.</p>"
             + "<p><strong>Mã giao dịch:</strong> " + transId + "</p>"
             + "<p><strong>Tổng tiền:</strong> " + String.format("%,.0f", total) + " VNĐ</p>"
             + "<p>Cảm ơn bạn đã mua sắm tại E-Books!</p></div>";
    }

    private void showSuccessAlert(PrintWriter out, String orderId, String transId, double amount) {
        out.println("<!DOCTYPE html><html><head><title>Kết quả</title><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon: 'success', title: 'Thanh toán thành công!', html: 'Mã đơn: <b>" + orderId + "</b><br>Số tiền: <b>" + String.format("%,.0f", amount) + " đ</b>', confirmButtonText: 'Xem đơn hàng'})");
        out.println(".then(() => { window.location.href = 'orders.jsp'; });");
        out.println("</script></body></html>");
    }

    private void showErrorAlert(PrintWriter out, String title, String msg) {
        out.println("<!DOCTYPE html><html><head><title>Kết quả</title><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon: 'error', title: '" + title + "', text: '" + msg + "', confirmButtonText: 'Quay lại giỏ hàng'})");
        out.println(".then(() => { window.location.href = 'cart.jsp'; });");
        out.println("</script></body></html>");
    }
}