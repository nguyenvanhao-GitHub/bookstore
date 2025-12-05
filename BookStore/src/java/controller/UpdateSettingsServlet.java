package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UpdateSettingsServlet")
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

        // 1. Nhận dữ liệu form
        String name = request.getParameter("name");
        String phone = request.getParameter("phone"); // Map với cột 'contact' trong DB
        String gender = request.getParameter("gender");
        
        String currentPass = request.getParameter("currentPassword");
        String newPass = request.getParameter("newPassword");
        String confirmPass = request.getParameter("confirmPassword");

        UserDAO dao = new UserDAO();
        String msg = "";
        String icon = "error";
        boolean isSuccess = false;

        try {
            // 2. Cập nhật thông tin cơ bản
            if (dao.updateUserInfo(userEmail, name, phone, gender)) {
                session.setAttribute("userName", name); // Cập nhật lại session
                isSuccess = true;
                msg = "Cập nhật thông tin thành công!";
                icon = "success";
            } else {
                msg = "Không có thay đổi nào được lưu.";
            }

            // 3. Xử lý đổi mật khẩu (nếu có nhập)
            if (currentPass != null && !currentPass.isEmpty()) {
                if (newPass == null || newPass.isEmpty()) {
                    msg = "Vui lòng nhập mật khẩu mới.";
                    icon = "warning";
                } else if (!newPass.equals(confirmPass)) {
                    msg = "Mật khẩu xác nhận không khớp.";
                    icon = "error";
                } else {
                    // Gọi hàm changePassword (đã viết trong UserDAO ở phần trước)
                    if (dao.changePassword(userEmail, currentPass, newPass)) {
                        msg += " Đổi mật khẩu thành công!";
                        icon = "success";
                    } else {
                        msg = "Mật khẩu hiện tại không đúng.";
                        icon = "error";
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Lỗi hệ thống: " + e.getMessage();
        }

        // 4. Set thông báo
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", isSuccess ? "Thành công" : "Thông báo");
        session.setAttribute("alertMessage", msg);
        
        response.sendRedirect("settings.jsp");
    }
}