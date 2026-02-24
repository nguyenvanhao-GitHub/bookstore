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
import java.util.List;
import java.util.Map;

@WebServlet("/ProcessOrderServlet")
public class ProcessOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {

            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zip = request.getParameter("zipCode");

            String books = request.getParameter("books");
            String selectedItemsJSON = request.getParameter("selectedItems");
            String totalStr = request.getParameter("total");
            double total = (totalStr != null && !totalStr.isEmpty()) ? Double.parseDouble(totalStr) : 0;

            String orderId = VNPayConfig.getRandomNumber(8);

            Order order = new Order(
                    orderId, fullName, email, phone, address, city, state, zip,
                    books, total, "COD", "Pending", null
            );

            OrderDAO orderDAO = new OrderDAO();
            boolean isSaved = orderDAO.insertOrder(order);

            if (isSaved) {
                CartDAO cartDAO = new CartDAO();
                cartDAO.clearCart(email);

                new Thread(() -> {
                    try {
                        if (selectedItemsJSON != null && !selectedItemsJSON.isEmpty()) {
                            Gson gson = new Gson();
                            Type listType = new TypeToken<List<Map<String, Object>>>() {
                            }.getType();
                            List<Map<String, Object>> cartDetails = gson.fromJson(selectedItemsJSON, listType);
                            String content = buildEmailHTML(orderId, fullName, phone, address, cartDetails, total);
                            EmailUtils.sendEmail(email, "Xác nhận đơn hàng #" + orderId, content);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }).start();

                showSuccessAlert(response, orderId, total, fullName, email, phone, address, city, state, zip);
            } else {
                showErrorAlert(response, "Lỗi đặt hàng", "Không thể lưu đơn hàng vào hệ thống.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            showErrorAlert(response, "Lỗi hệ thống", e.getMessage());
        }
    }

    private void showSuccessAlert(HttpServletResponse response, String orderId, double total,
            String name, String email, String phone,
            String address, String city, String state, String zip) throws IOException {
        PrintWriter out = response.getWriter();

        String infoHtml = "<div style='text-align: left; font-size: 14px; line-height: 1.5; color: #333;'>"
                + "<hr style='margin: 10px 0;'>"
                + "<strong style='color: #0d6efd;'>Thông tin khách hàng:</strong><br>"
                + "Tên: " + name + "<br>"
                + "Email: " + (email != null ? email : "") + "<br>"
                + "SĐT: " + (phone != null ? phone : "") + "<br><br>"
                + "<strong style='color: #0d6efd;'>Địa chỉ giao hàng:</strong><br>"
                + address + "<br>"
                + city + ", " + state + " - " + (zip != null ? zip : "")
                + "<hr style='margin: 10px 0;'>"
                + "<div style='text-align: right; font-size: 16px;'>"
                + "Tổng cộng: <strong style='color: #dc3545;'>" + String.format("%,.0f", total) + " đ</strong>"
                + "</div>"
                + "</div>";

        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("window.onload = function() {");
        out.println("  Swal.fire({");
        out.println("    icon: 'success',");
        out.println("    title: 'Đặt hàng thành công!',");
        out.println("    html: `" + infoHtml + "`,");
        out.println("    confirmButtonText: 'Tiếp tục mua sắm',");
        out.println("    allowOutsideClick: false");
        out.println("  }).then((result) => {");
        out.println("      if (result.isConfirmed) { window.location.href = 'index.jsp'; }");
        out.println("  });");
        out.println("}");
        out.println("</script></body></html>");
    }

    private void showErrorAlert(HttpServletResponse response, String title, String msg) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>window.onload = function() { Swal.fire({icon: 'error', title: '" + title + "', text: '" + msg + "'}).then(() => { window.history.back(); }); }</script></body></html>");
    }

    private String buildEmailHTML(String orderId, String name, String phone, String address, List<Map<String, Object>> items, double total) {
        StringBuilder html = new StringBuilder();
        html.append("<h3>Cảm ơn bạn đã đặt hàng tại BookStore!</h3>");
        html.append("<p>Mã đơn hàng: <b>").append(orderId).append("</b></p>");
        html.append("<p>Tổng tiền: <b>").append(String.format("%,.0f", total)).append(" đ</b></p>");
        html.append("<p>Địa chỉ nhận: ").append(address).append("</p>");
        return html.toString();
    }
}
