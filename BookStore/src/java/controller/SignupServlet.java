package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contact = request.getParameter("contact");
        String gender = request.getParameter("gender");
        String role = request.getParameter("role");
        String password = request.getParameter("password");

        UserDAO userDAO = new UserDAO();

        // 1. Kiểm tra email tồn tại
        if (userDAO.checkEmailExistsInAllRoles(email)) {
            showAlert(response, "error", "Email đã tồn tại", "Vui lòng sử dụng email khác.", "signup.jsp");
            return;
        }

        try {
            // 2. Hash mật khẩu
            String salt = generateSalt();
            String hashedPassword = hashPassword(password, salt);

            // 3. Đăng ký người dùng
            boolean isRegistered = userDAO.registerUser(name, email, contact, gender, role, hashedPassword, salt);

            if (isRegistered) {
                showAlert(response, "success", "Tạo tài khoản thành công!", "Bạn có thể đăng nhập ngay bây giờ.", "login.jsp");
            } else {
                showAlert(response, "error", "Đăng ký thất bại", "Vui lòng thử lại sau.", "signup.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            showAlert(response, "error", "Lỗi hệ thống", e.getMessage(), "signup.jsp");
        }
    }

    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    private String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        byte[] hashed = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hashed);
    }

    private void showAlert(HttpServletResponse response, String icon, String title, String text, String url) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon:'" + icon + "', title:'" + title + "', text:'" + text + "'})");
        out.println(".then(() => { window.location='" + url + "'; });");
        out.println("</script></body></html>");
    }
}