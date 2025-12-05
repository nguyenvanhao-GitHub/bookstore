package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import utils.EmailUtils;

// SendNewsletterServlet.java
@WebServlet("/SendNewsletterServlet")
public class SendNewsletterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String recipients = req.getParameter("recipients");
        String subject = req.getParameter("subject");
        String message = req.getParameter("message");
        
        // Logic tách email (nếu bulk) nên chuyển vào DAO hoặc Utils
        // Ở đây demo gọi Utils
        try {
             // Giả sử recipients là 1 email hoặc loop list email
            String[] emails = recipients.split(",");
            for(String email : emails) {
                EmailUtils.send(email.trim(), subject, message);
            }
            setAlert(req.getSession(), "success", "Đã gửi", "Newsletter đã được gửi đi.");
        } catch (Exception e) {
            setAlert(req.getSession(), "error", "Lỗi", e.getMessage());
        }
        resp.sendRedirect("admin/subscriber.jsp");
    }
    private void setAlert(HttpSession s, String i, String t, String m) {
        s.setAttribute("alertIcon", i); s.setAttribute("alertTitle", t); s.setAttribute("alertMessage", m);
    }
}