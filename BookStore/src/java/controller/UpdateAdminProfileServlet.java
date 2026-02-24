package controller;

import dao.AdminDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UpdateAdminProfileServlet")
public class UpdateAdminProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String email = (String) session.getAttribute("adminEmail");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name = request.getParameter("name");
        String contact = request.getParameter("contact");

        AdminDAO dao = new AdminDAO();
        boolean success = dao.updateAdminInfo(email, name, contact);

        if (success) {
            session.setAttribute("adminName", name);

            setAlert(session, "success", "Thành công", "Cập nhật hồ sơ thành công!");
        } else {
            setAlert(session, "error", "Lỗi", "Không thể cập nhật thông tin.");
        }

        response.sendRedirect("admin/admin-profile.jsp");
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}
