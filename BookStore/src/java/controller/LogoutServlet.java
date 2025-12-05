package controller;

import dao.UserDAO;
import utils.RememberMeUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleLogout(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleLogout(request, response);
    }
    
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            String userEmail = (String) session.getAttribute("userEmail");
            Integer userId = (Integer) session.getAttribute("userId");
            
            // Xóa Cookie RememberMe
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("rememberMeToken".equals(cookie.getName())) {
                        RememberMeUtil.deleteToken(cookie.getValue());
                        cookie.setMaxAge(0);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                    }
                }
            }
            if (userId != null) RememberMeUtil.deleteTokenByUserId(userId);
            
            // Gọi DAO cập nhật status
            if (userEmail != null) {
                UserDAO dao = new UserDAO();
                dao.logout(userEmail);
            }
            
            session.invalidate();
        }

        // Tạo session mới để hiển thị alert
        HttpSession newSession = request.getSession();
        newSession.setAttribute("alertIcon", "success");
        newSession.setAttribute("alertTitle", "Đăng xuất thành công");
        newSession.setAttribute("alertMessage", "Hẹn gặp lại bạn!");
        
        response.sendRedirect("login.jsp");
    }
}