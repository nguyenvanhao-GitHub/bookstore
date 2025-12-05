package controller;

import dao.UserDAO;
import utils.RememberMeUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        
        if (userEmail != null) {
            UserDAO dao = new UserDAO();
            if (dao.deleteAccount(userEmail)) {
                
                // 1. Xóa Cookie Remember Me (nếu có) để tránh tự động đăng nhập lại
                Cookie[] cookies = request.getCookies();
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if ("rememberMeToken".equals(cookie.getName())) {
                            // Xóa token trong DB (Optional: phòng trường hợp DB không có cascade delete)
                            RememberMeUtil.deleteToken(cookie.getValue());
                            
                            // Xóa cookie trên trình duyệt
                            cookie.setMaxAge(0);
                            cookie.setPath("/");
                            response.addCookie(cookie);
                        }
                    }
                }

                // 2. Hủy session hiện tại
                session.invalidate(); 
                
                // 3. Tạo session mới để hiển thị thông báo
                HttpSession newSession = request.getSession(true);
                setAlert(newSession, "success", "Đã xóa", "Tài khoản của bạn đã bị xóa vĩnh viễn.");
                
                response.sendRedirect("login.jsp");
                return;
            }
        }
        
        // Trường hợp xóa thất bại
        setAlert(session, "error", "Lỗi", "Không thể xóa tài khoản. Vui lòng thử lại.");
        response.sendRedirect("settings.jsp");
    }
    
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}