package controller;

import dao.ContactDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");
        
        ContactDAO dao = new ContactDAO();
        boolean sent = dao.saveMessage(name, email, subject, message);
        
        HttpSession session = request.getSession();
        if (sent) {
            setAlert(session, "success", "Đã gửi!", "Cảm ơn bạn đã liên hệ.");
        } else {
            setAlert(session, "error", "Lỗi", "Không thể gửi tin nhắn lúc này.");
        }
        response.sendRedirect("contact.jsp");
    }
    
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}