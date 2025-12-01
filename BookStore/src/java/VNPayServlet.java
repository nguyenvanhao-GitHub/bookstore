import config.VNPayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/VNPayServlet")
public class VNPayServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // ======= LẤY THÔNG TIN ĐƠN HÀNG TỪ FORM =======
            String orderId = "ORD" + System.currentTimeMillis(); // Tạo mã đơn hàng
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zip = request.getParameter("zip");
            String books = request.getParameter("books"); // danh sách sách dạng chuỗi
            double total = Double.parseDouble(request.getParameter("total"));

            // ======= LƯU THÔNG TIN ĐƠN HÀNG VÀO SESSION =======
            Map<String, String> orderInfo = new HashMap<>();
            orderInfo.put("orderId", orderId);
            orderInfo.put("fullName", fullName);
            orderInfo.put("userEmail", email);
            orderInfo.put("phone", phone);
            orderInfo.put("address", address);
            orderInfo.put("city", city);
            orderInfo.put("state", state);
            orderInfo.put("zipCode", zip);
            orderInfo.put("books", books);
            orderInfo.put("total", String.valueOf(total));

            HttpSession session = request.getSession();
            session.setAttribute("orderInfo", orderInfo);

            // ======= LẤY IP CLIENT =======
            String ipAddress = VNPayConfig.getIpAddress(request);

            // ======= TẠO URL THANH TOÁN VNPay =======
            String paymentUrl = VNPayConfig.createPaymentUrl(
                    orderId,
                    (long) total,
                    "Thanh toán đơn hàng #" + orderId,
                    ipAddress
            );

            // ======= REDIRECT NGƯỜI DÙNG SANG VNPay =======
            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi hệ thống: " + e.getMessage());
        }
    }
}
