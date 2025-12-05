package controller;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import config.VNPayConfig;
import dao.CartDAO;
import dao.OrderDAO;
import entity.Order;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.util.List; // QUAN TRỌNG: Import List để tránh lỗi
import java.util.Map;

@WebServlet("/ProcessOrderServlet")
public class ProcessOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();

        try {
            // 1. Lấy dữ liệu form
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zip = request.getParameter("zipCode");
            String books = request.getParameter("books"); // Chuỗi tóm tắt sách
            String selectedItemsJSON = request.getParameter("selectedItems"); // JSON chi tiết
            
            String totalStr = request.getParameter("total");
            double total = (totalStr != null && !totalStr.isEmpty()) ? Double.parseDouble(totalStr) : 0;

            // 2. Tạo Order ID ngẫu nhiên
            String orderId = VNPayConfig.getRandomNumber(8);

            // 3. Tạo đối tượng Order (Khớp Entity Order 13 tham số)
            // Lưu ý: transactionId là null vì đây là thanh toán COD
            Order order = new Order(
                orderId, fullName, email, phone, address, city, state, zip, 
                books, total, "COD", "Pending", null
            );

            // 4. Lưu vào DB
            OrderDAO orderDAO = new OrderDAO();
            boolean isSaved = orderDAO.insertOrder(order);

            if (isSaved) {
                // Xóa giỏ hàng
                CartDAO cartDAO = new CartDAO();
                cartDAO.clearCart(email);

                // Gửi email xác nhận (Chạy luồng riêng)
                new Thread(() -> {
                    try {
                        Gson gson = new Gson();
                        Type listType = new TypeToken<List<Map<String, Object>>>(){}.getType();
                        List<Map<String, Object>> cartDetails = gson.fromJson(selectedItemsJSON, listType);
                        
                        String subject = "Xác nhận đơn hàng #" + orderId;
                        String content = buildEmailHTML(orderId, fullName, phone, address, cartDetails, total);
                        EmailUtils.sendEmail(email, subject, content);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }).start();

                showSuccessAlert(response, orderId, total);
            } else {
                showErrorAlert(response, "Lỗi đặt hàng", "Không thể lưu đơn hàng vào hệ thống.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            showErrorAlert(response, "Lỗi hệ thống", e.getMessage());
        }
    }
    
    // Hàm tạo nội dung email
    private String buildEmailHTML(String orderId, String name, String phone, String address, List<Map<String, Object>> items, double total) {
        StringBuilder html = new StringBuilder();
        html.append("<div style='font-family: Arial, sans-serif; padding: 20px; border: 1px solid #ddd;'>");
        html.append("<h2 style='color: #28a745;'>Cảm ơn bạn đã đặt hàng!</h2>");
        html.append("<p>Xin chào <b>").append(name).append("</b>,</p>");
        html.append("<p>Đơn hàng <b>#").append(orderId).append("</b> của bạn đang được xử lý.</p>");
        html.append("<hr>");
        html.append("<p><b>Tổng tiền:</b> <span style='color: #d9534f; font-weight: bold;'>")
            .append(String.format("%,.0f", total)).append(" đ</span></p>");
        html.append("<p><b>Địa chỉ nhận hàng:</b> ").append(address).append("</p>");
        html.append("<p><b>Điện thoại:</b> ").append(phone).append("</p>");
        html.append("</div>");
        return html.toString();
    }
    
    private void showSuccessAlert(HttpServletResponse response, String orderId, double total) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("window.onload = function() {");
        out.println("  Swal.fire({");
        out.println("    icon: 'success',");
        out.println("    title: 'Đặt hàng thành công!',");
        out.println("    text: 'Mã đơn: " + orderId + " - Tổng tiền: " + String.format("%,.0f", total) + " đ',");
        out.println("    confirmButtonText: 'Xem đơn hàng'");
        out.println("  }).then(() => { window.location.href = 'orders.jsp'; });");
        out.println("}");
        out.println("</script></body></html>");
    }
    
    private void showErrorAlert(HttpServletResponse response, String title, String msg) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("window.onload = function() {");
        out.println("  Swal.fire({icon: 'error', title: '" + title + "', text: '" + msg + "'})");
        out.println("  .then(() => { window.history.back(); });");
        out.println("}");
        out.println("</script></body></html>");
    }
}