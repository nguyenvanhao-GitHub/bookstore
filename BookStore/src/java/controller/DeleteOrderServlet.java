package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteOrderServlet")
public class DeleteOrderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderId = request.getParameter("orderId");
        HttpSession session = request.getSession();
        
        try {
            if (new OrderDAO().deleteOrder(orderId)) {
                setAlert(session, "success", "Đã xóa", "Xóa đơn hàng thành công!");
            } else {
                setAlert(session, "error", "Lỗi", "Không thể xóa đơn hàng này.");
            }
        } catch (Exception e) {
            setAlert(session, "error", "Lỗi hệ thống", e.getMessage());
        }
        response.sendRedirect("admin/orders.jsp");
    }
    
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}