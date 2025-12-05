package controller;

import config.VNPayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/VNPayServlet")
public class VNPayServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            // 1. Lấy và kiểm tra tổng tiền
            String totalStr = request.getParameter("total");
            if (totalStr == null || totalStr.isEmpty()) {
                response.sendRedirect("cart.jsp?error=missing_total");
                return;
            }
            
            // Chuyển đổi tiền tệ (VNPay yêu cầu đơn vị là đồng, không có decimal)
            double total = Double.parseDouble(totalStr);
            long amount = (long) (total); 

            // 2. Lấy thông tin giao hàng
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zip = request.getParameter("zipCode");
            String books = request.getParameter("books");

            // 3. Tạo mã đơn hàng (Unique)
            String orderId = VNPayConfig.getRandomNumber(8);

            // 4. Lưu thông tin vào Session để dùng lại sau khi thanh toán xong
            Map<String, String> orderInfo = new HashMap<>();
            orderInfo.put("orderId", orderId);
            orderInfo.put("fullName", fullName != null ? fullName : "");
            orderInfo.put("email", email != null ? email : "");
            orderInfo.put("phone", phone != null ? phone : "");
            orderInfo.put("address", address != null ? address : "");
            orderInfo.put("city", city != null ? city : "");
            orderInfo.put("state", state != null ? state : "");
            orderInfo.put("zipCode", zip != null ? zip : "");
            orderInfo.put("books", books != null ? books : "");
            orderInfo.put("total", String.valueOf(total));

            HttpSession session = request.getSession();
            session.setAttribute("orderInfo", orderInfo);

            // 5. Tạo URL thanh toán VNPay
            String ipAddress = VNPayConfig.getIpAddress(request);
            String paymentUrl = VNPayConfig.createPaymentUrl(orderId, amount, "Thanh toan don hang " + orderId, ipAddress);

            // 6. Chuyển hướng
            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h3>Lỗi hệ thống: " + e.getMessage() + "</h3>");
        }
    }
}