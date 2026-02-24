package controller;

import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/ReplyContactMessageServlet")
public class ReplyContactMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String to = request.getParameter("recipients"); 
        String subject = request.getParameter("subject"); 
        String messageContent = request.getParameter("message"); 

        try {
            EmailUtils.send(to, subject, messageContent);
            
            setAlert(session, "success", "Đã gửi", "Phản hồi đã được gửi thành công đến " + to);
            
        } catch (Exception e) {
            e.printStackTrace();
            setAlert(session, "error", "Lỗi gửi mail", "Không thể gửi mail: " + e.getMessage());
        }
        
        response.sendRedirect("admin/contact.jsp");
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}