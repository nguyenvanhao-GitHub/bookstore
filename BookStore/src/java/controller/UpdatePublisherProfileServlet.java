package controller;

import dao.PublisherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UpdatePublisherProfileServlet")
public class UpdatePublisherProfileServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        
        String email = (String) session.getAttribute("publisherEmail");
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        PublisherDAO dao = new PublisherDAO();
        boolean success = false;
        String msg = "";

        if ("updateInfo".equals(action)) {
            String name = request.getParameter("name");
            String contact = request.getParameter("contact");
            if (dao.updatePublisherInfo(email, name, contact)) {
                session.setAttribute("publisherName", name); // Cập nhật session name
                success = true; msg = "Cập nhật thông tin thành công!";
            } else {
                msg = "Lỗi khi cập nhật thông tin.";
            }
        } else if ("changePassword".equals(action)) {
            String currentPass = request.getParameter("currentPassword");
            String newPass = request.getParameter("newPassword");
            String confirmPass = request.getParameter("confirmPassword");

            if (!newPass.equals(confirmPass)) {
                msg = "Mật khẩu xác nhận không khớp.";
            } else {
                if (dao.changePassword(email, currentPass, newPass)) {
                    success = true; msg = "Đổi mật khẩu thành công!";
                } else {
                    msg = "Mật khẩu hiện tại không đúng.";
                }
            }
        }

        session.setAttribute("alertIcon", success ? "success" : "error");
        session.setAttribute("alertTitle", success ? "Thành công" : "Lỗi");
        session.setAttribute("alertMessage", msg);
        
        response.sendRedirect("publisher/publisher-profile.jsp");
    }
}