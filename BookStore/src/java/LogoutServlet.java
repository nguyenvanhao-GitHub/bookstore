import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import utils.RememberMeUtil;

/**
 * LogoutServlet với chức năng xóa Remember Me token
 * File: LogoutServlet.java
 */
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection details
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleLogout(request, response);
    }
    
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);  // Get the existing session if it exists
        
        if (session != null) {
            String userEmail = (String) session.getAttribute("userEmail");
            Integer userId = (Integer) session.getAttribute("userId");
            
            // 🆕 Xóa Remember Me token nếu có
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("rememberMeToken".equals(cookie.getName())) {
                        // Xóa token từ database
                        RememberMeUtil.deleteToken(cookie.getValue());
                        
                        // Xóa cookie
                        cookie.setMaxAge(0);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                    }
                }
            }
            
            // Xóa tất cả token của user trong database
            if (userId != null) {
                RememberMeUtil.deleteTokenByUserId(userId);
            }
            
            // Update last_logout and status in database
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                String updateQuery = "UPDATE user SET last_logout = NOW(), status = 'inactive' WHERE email = ?";
                try (PreparedStatement stmt = connection.prepareStatement(updateQuery)) {
                    stmt.setString(1, userEmail);
                    stmt.executeUpdate();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            session.invalidate();  // End the session
        }
        
        // Set content type to HTML and write a response with SweetAlert2
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println("<!DOCTYPE html>");
        response.getWriter().println("<html lang='vi'>");
        response.getWriter().println("<head>");
        response.getWriter().println("<meta charset='UTF-8'>");
        response.getWriter().println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        response.getWriter().println("<title>Đăng xuất thành công</title>");
        response.getWriter().println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        response.getWriter().println("</head>");
        response.getWriter().println("<body>");
        
        // Show SweetAlert2 message and redirect to login page
        response.getWriter().println("<script>");
        response.getWriter().println("Swal.fire({");
        response.getWriter().println("  icon: 'success',");
        response.getWriter().println("  title: '✅ Đăng xuất thành công',");
        response.getWriter().println("  text: 'Hẹn gặp lại bạn!',");
        response.getWriter().println("  timer: 2500,");
        response.getWriter().println("  timerProgressBar: true,");
        response.getWriter().println("  showConfirmButton: false");
        response.getWriter().println("}).then(() => {");
        response.getWriter().println("  window.location.href = 'login.jsp';");
        response.getWriter().println("});");
        response.getWriter().println("</script>");
        response.getWriter().println("</body>");
        response.getWriter().println("</html>");
    }
}