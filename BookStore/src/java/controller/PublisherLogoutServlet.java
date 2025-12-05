package controller;

import dao.PublisherDAO;
import entity.Publisher;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/PublisherLogoutServlet")
public class PublisherLogoutServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String email = (String) session.getAttribute("publisherEmail");
            if (email != null) new PublisherDAO().logout(email);
            session.invalidate();
        }
        // Tạo session mới để hiện alert
        req.getSession().setAttribute("alertIcon", "success");
        req.getSession().setAttribute("alertTitle", "Đã đăng xuất");
        resp.sendRedirect("publisher/login.jsp");
    }
}