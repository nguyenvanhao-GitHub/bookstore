package controller;

import dao.OrderDAO;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("status");
        String returnPage = request.getParameter("returnPage");
        
        HttpSession session = request.getSession();
        OrderDAO orderDAO = new OrderDAO();
        
        // 1. Lấy thông tin đơn hàng hiện tại
        Map<String, String> orderInfo = orderDAO.getOrderBasicInfo(orderId);
        String currentStatus = orderInfo != null ? orderInfo.get("status") : null;
        
        if (currentStatus == null) {
            session.setAttribute("alert", "Order not found!");
            if (returnPage != null && !returnPage.isEmpty()) {
                response.sendRedirect("admin/orders.jsp?page=" + returnPage);
            } else {
                response.sendRedirect("admin/orders.jsp");
            }
            return;
        }
        
        // 2. Logic kiểm tra trạng thái (Tùy chọn: không cho update nếu đã finalized)
        // if ("cancelled".equalsIgnoreCase(currentStatus) || "delivered".equalsIgnoreCase(currentStatus)) {
        //     session.setAttribute("alert", "Cannot update finalized order.");
        //     response.sendRedirect("admin/orders.jsp?page=" + (returnPage != null ? returnPage : "1"));
        //     return;
        // }
        
        // 3. Update Status
        boolean updated = orderDAO.updateOrderStatus(orderId, newStatus);
        
        if (updated) {
            session.setAttribute("alert", "Order status updated successfully!");
            
            // 4. Gửi mail thông báo
            String email = orderInfo.get("email");
            String name = orderInfo.get("name");
            
            if (email != null && !email.isEmpty()) {
                try {
                    String subject = "Your Order Status Has Been Updated - #" + orderId;
                    String content = "Hello " + name + ",<br><br>"
                            + "Your order (ID: " + orderId + ") status has been updated to: <strong>" 
                            + newStatus.toUpperCase() + "</strong>.<br><br>"
                            + "Thank you for shopping with us!<br>— BookStore Team";
                    
                    EmailUtils.send(email, subject, content);
                } catch (Exception e) {
                    System.err.println("Failed to send email notification: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        } else {
            session.setAttribute("alert", "Failed to update order status.");
        }
        
        // 5. Redirect về trang hiện tại
        if (returnPage != null && !returnPage.isEmpty()) {
            response.sendRedirect("admin/orders.jsp?page=" + returnPage);
        } else {
            response.sendRedirect("admin/orders.jsp");
        }
    }
}