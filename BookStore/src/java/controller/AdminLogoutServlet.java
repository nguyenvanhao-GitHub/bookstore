package controller;

import dao.AdminDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/AdminLogoutServlet")
public class AdminLogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            String email = (String) session.getAttribute("adminEmail");
            if (email != null) {
                AdminDAO dao = new AdminDAO();
//                 dao.logout(email); 
            }
            session.invalidate();
        }

        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("alertIcon", "success");
        newSession.setAttribute("alertTitle", "Đã đăng xuất");
        newSession.setAttribute("alertMessage", "Hẹn gặp lại!");

        response.sendRedirect("admin/login.jsp");
    }
}
