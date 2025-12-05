package controller;

import dao.UserDAO;
import entity.User;
import utils.RememberMeUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            showAlert(response, "warning", "Thiếu thông tin", "Vui lòng nhập đầy đủ email và mật khẩu.", "login.jsp", true);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(email, password);

        if (user != null) {
            // 1. Kiểm tra nếu đã bị khóa từ trước
            if ("Locked".equalsIgnoreCase(user.getStatus())) {
                String reason = user.getLockReason();
                String msg = "Tài khoản của bạn đã bị khóa.";
                if (reason != null && !reason.trim().isEmpty()) {
                    msg += "<br>Lý do: <b>" + reason + "</b>";
                }
                showAlert(response, "error", "Đăng nhập thất bại", msg, "login.jsp", true);
                return;
            }

            // 2. [MỚI] Kiểm tra thời gian không hoạt động (90 ngày)
            Timestamp lastLogin = user.getLastLogin();
            if (lastLogin != null) {
                long diff = System.currentTimeMillis() - lastLogin.getTime();
                long days = diff / (24 * 60 * 60 * 1000); // Đổi ra số ngày

                if (days > 90) {
                    // Tự động khóa
                    String reason = "Tự động khóa do không hoạt động quá 90 ngày.";
                    userDAO.lockAccount(user.getId(), reason);
                    
                    showAlert(response, "error", "Tài khoản bị khóa", 
                        "Tài khoản đã bị khóa do không hoạt động trong " + days + " ngày.<br>Vui lòng liên hệ Admin để mở khóa.", 
                        "login.jsp", true);
                    return;
                }
            }

            // 3. Nếu mọi thứ OK -> Cập nhật Last Login & Vào hệ thống
            userDAO.updateLastLogin(user.getId());

            HttpSession session = request.getSession();
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole", "user");

            if ("on".equals(rememberMe)) {
                String token = RememberMeUtil.generateToken(user.getId(), user.getEmail());
                if (token != null) {
                    Cookie c = new Cookie("rememberMeToken", token);
                    c.setMaxAge(30 * 24 * 60 * 60);
                    c.setPath("/");
                    c.setHttpOnly(true);
                    response.addCookie(c);
                }
            } else {
                RememberMeUtil.deleteTokenByUserId(user.getId());
                Cookie c = new Cookie("rememberMeToken", "");
                c.setMaxAge(0);
                c.setPath("/");
                response.addCookie(c);
            }

            showAlert(response, "success", "Đăng nhập thành công!", "Chào mừng " + user.getName(), "index.jsp", false);
            
        } else {
            showAlert(response, "error", "Lỗi đăng nhập", "Email hoặc mật khẩu không chính xác.", "login.jsp", true);
        }
    }

    private void showAlert(HttpServletResponse response, String icon, String title, String text, String url, boolean confirm) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<style>body { font-family: 'Segoe UI', sans-serif; background-color: #f0f2f5; }</style>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: '" + icon + "',");
        out.println("  title: '" + title + "',");
        out.println("  html: '" + text + "',");
        out.println("  showConfirmButton: " + confirm + ",");
        if (!confirm) {
            out.println("  timer: 1500, timerProgressBar: true,");
        } else {
            out.println("  confirmButtonText: 'Đồng ý', confirmButtonColor: '#3085d6',");
        }
        out.println("  allowOutsideClick: false");
        out.println("}).then(() => { window.location.href = '" + url + "'; });");
        out.println("</script>");
        out.println("</body></html>");
        out.close();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        super.doGet(request, response); 
    }
}