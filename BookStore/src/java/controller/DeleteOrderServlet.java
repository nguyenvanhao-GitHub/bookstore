package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteOrderServlet")
public class DeleteOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String orderId = request.getParameter("orderId");
        String returnPage = request.getParameter("returnPage");
        
        HttpSession session = request.getSession();
        OrderDAO orderDAO = new OrderDAO();
        
        try {
            // Delete order
            boolean deleted = orderDAO.deleteOrder(orderId);
            
            if (deleted) {
                session.setAttribute("deleteStatus", "success");
                session.setAttribute("deleteMessage", "Order deleted successfully!");
            } else {
                session.setAttribute("deleteStatus", "error");
                session.setAttribute("deleteMessage", "Failed to delete order.");
            }
        } catch (Exception e) {
            session.setAttribute("deleteStatus", "error");
            session.setAttribute("deleteMessage", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Redirect back to the same page
        if (returnPage != null && !returnPage.isEmpty()) {
            response.sendRedirect("admin/orders.jsp?page=" + returnPage);
        } else {
            response.sendRedirect("admin/orders.jsp");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Support GET method as well
        doPost(request, response);
    }
}