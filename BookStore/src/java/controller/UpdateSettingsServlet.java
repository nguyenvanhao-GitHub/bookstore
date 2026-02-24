package controller;

import dao.UserDAO;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "UpdateSettingsServlet", urlPatterns = {"/UpdateSettingsServlet"})
public class UpdateSettingsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");

        String currentPass = request.getParameter("currentPassword");
        String newPass = request.getParameter("newPassword");
        String confirmPass = request.getParameter("confirmPassword");

        UserDAO dao = new UserDAO();
        String msg = "";
        String icon = "error";
        String title = "Lỗi";
        boolean hasError = false;

        if (newPass != null && !newPass.trim().isEmpty()) {
            if (currentPass == null || currentPass.trim().isEmpty()) {
                msg = "Vui lòng nhập mật khẩu hiện tại để xác nhận thay đổi.";
                hasError = true;
            } else if (!newPass.equals(confirmPass)) {
                msg = "Mật khẩu xác nhận không khớp.";
                hasError = true;
            } else if (!dao.checkPassword(userEmail, currentPass)) {
                msg = "Mật khẩu hiện tại không đúng.";
                hasError = true;
            } else {
                if (dao.changePassword(userEmail, newPass)) {
                    msg = "Đổi mật khẩu thành công! ";
                } else {
                    msg = "Lỗi hệ thống khi đổi mật khẩu. ";
                    hasError = true;
                }
            }
        }

        if (!hasError) {
            User user = new User();
            user.setEmail(userEmail);
            user.setName(name);
            user.setContact(phone);
            user.setGender(gender);

            if (dao.updateUserProfile(user)) {
                session.setAttribute("userName", name);
                msg += "Thông tin cá nhân đã được cập nhật.";
                icon = "success";
                title = "Thành công";
            } else {
                msg = "Không thể cập nhật thông tin cá nhân.";
                icon = "error";
            }
        }

        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);

        response.sendRedirect("settings.jsp");
    }
}
