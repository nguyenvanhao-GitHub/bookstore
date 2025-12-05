package controller;

import dao.AccountDAO;
import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Random;

@WebServlet("/ManageAccountsServlet")
public class ManageAccountsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        String targetTable = request.getParameter("targetTable");
        String idStr = request.getParameter("id");
        
        AccountDAO dao = new AccountDAO();
        HttpSession session = request.getSession();
        boolean success = false;
        String msg = "";

        try {
            int id = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;

            switch (action) {
                case "autolock":
                    int days = Integer.parseInt(request.getParameter("daysInactive"));
                    int count = dao.autoLockInactive(days);
                    success = true;
                    msg = "Đã tự động khóa " + count + " tài khoản không hoạt động quá " + days + " ngày.";
                    break;

                case "lock":
                    String reason = request.getParameter("lockReason");
                    if (dao.updateAccountStatus(targetTable, id, "Locked", reason)) {
                        success = true; msg = "Đã khóa tài khoản thành công.";
                    }
                    break;

                case "unlock":
                    if (dao.updateAccountStatus(targetTable, id, "Active", null)) {
                        success = true; msg = "Đã mở khóa tài khoản.";
                    }
                    break;

                case "reset":
                    String email = dao.getEmailById(targetTable, id);
                    if (email != null) {
                        String newPass = generateRandomPassword();
                        String salt = generateSalt();
                        String hash = hashPassword(newPass, salt);
                        
                        if (dao.resetPassword(targetTable, id, hash, salt)) {
                            // Gửi email
                            new Thread(() -> {
                                try {
                                    EmailUtils.sendEmail(email, "Cấp lại mật khẩu - E-Books", "Mật khẩu mới của bạn là: " + newPass);
                                } catch (Exception e) { e.printStackTrace(); }
                            }).start();
                            success = true; msg = "Mật khẩu mới đã được gửi qua email.";
                        }
                    } else {
                        msg = "Không tìm thấy email.";
                    }
                    break;

                case "delete":
                    if(dao.deleteAccount(targetTable, id)) {
                        success = true; msg = "Đã xóa tài khoản.";
                    }
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Lỗi hệ thống: " + e.getMessage();
        }

        session.setAttribute("alertIcon", success ? "success" : "error");
        session.setAttribute("alertTitle", success ? "Thông báo" : "Lỗi");
        session.setAttribute("alertMessage", msg);
        
        response.sendRedirect("admin/users.jsp");
    }

    // Các hàm helper hash/salt giữ nguyên như cũ
    private String generateSalt() { byte[] b = new byte[16]; new SecureRandom().nextBytes(b); return Base64.getEncoder().encodeToString(b); }
    private String hashPassword(String p, String s) throws Exception { MessageDigest m = MessageDigest.getInstance("SHA-256"); m.update(s.getBytes()); return Base64.getEncoder().encodeToString(m.digest(p.getBytes())); }
    private String generateRandomPassword() { return "Pass@" + new Random().nextInt(999999); }
}