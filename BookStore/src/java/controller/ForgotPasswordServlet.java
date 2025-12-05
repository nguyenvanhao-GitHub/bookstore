package controller;

import dao.UserDAO;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        UserDAO dao = new UserDAO();
        
        int userId = dao.getUserIdByEmail(email);

        if (userId != -1) {
            try {
                // 1. Tạo mật khẩu ngẫu nhiên
                String newPass = generateRandomPassword();
                
                // 2. [MỚI] Tạo Salt mới
                String salt = generateSalt();
                
                // 3. Hash mật khẩu với Salt
                String hashedPass = hashPassword(newPass, salt);

                // 4. Cập nhật vào DB (DAO cần update hàm updatePassword để nhận thêm salt)
                if (dao.updatePassword(userId, hashedPass, salt)) {
                    EmailUtils.sendPasswordResetEmail(email, newPass);
                    request.setAttribute("message", "Mật khẩu mới đã được gửi vào email!");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Lỗi cập nhật database.");
                    request.setAttribute("messageType", "danger");
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("message", "Lỗi hệ thống: " + e.getMessage());
                request.setAttribute("messageType", "danger");
            }
        } else {
            request.setAttribute("message", "Email không tồn tại.");
            request.setAttribute("messageType", "danger");
        }
        
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#";
        Random rand = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            sb.append(chars.charAt(rand.nextInt(chars.length())));
        }
        return sb.toString();
    }

    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }
}