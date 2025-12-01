import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.sql.*;
import java.util.Base64;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    // Hàm hash password với salt
    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        byte[] hashed = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hashed);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Lấy name, password và salt của admin
            String loginQuery = "SELECT name, password, salt FROM admin WHERE email = ?";

            try (PreparedStatement stmt = connection.prepareStatement(loginQuery)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    String name = rs.getString("name");
                    String storedPassword = rs.getString("password");
                    String salt = rs.getString("salt");

                    // Hash lại mật khẩu nhập vào để so sánh
                    String hashedInput = hashPassword(password, salt);

                    if (storedPassword.equals(hashedInput)) {
                        // Đăng nhập thành công
                        HttpSession session = request.getSession();
                        session.setAttribute("adminName", name);
                        session.setAttribute("adminEmail", email);
                        session.setAttribute("userRole", "admin");

                        String updateQuery = "UPDATE admin SET last_login = NOW(), status = 'active' WHERE email = ?";
                        try (PreparedStatement updateStmt = connection.prepareStatement(updateQuery)) {
                            updateStmt.setString(1, email);
                            updateStmt.executeUpdate();
                        }

                        // Hiển thị SweetAlert2
                        response.setContentType("text/html;charset=UTF-8");
                        PrintWriter out = response.getWriter();
                        out.println("<!DOCTYPE html><html lang='en'><head>");
                        out.println("<meta charset='UTF-8'><title>Login Successful</title>");
                        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
                        out.println("<script>");
                        out.println("Swal.fire({icon:'success',title:'Login Successful!',text:'Welcome, Admin " + name + "!',timer:3000,showConfirmButton:false})");
                        out.println(".then(()=>{window.location.href='admin/admin-profile.jsp';});");
                        out.println("</script></body></html>");
                    } else {
                        // Sai mật khẩu
                        showError(response, "Incorrect password. Please try again.", "admin/login.jsp");
                    }
                } else {
                    // Email không tồn tại
                    showError(response, "Account not found!", "admin/login.jsp");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            showError(response, "Unexpected error occurred. Please try again later.", "admin/login.jsp");
        }
    }

    private void showError(HttpServletResponse response, String message, String redirectPage) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html lang='en'><head>");
        out.println("<meta charset='UTF-8'><title>Error</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon:'error',title:'Login Failed!',text:'" + message + "'}).then(()=>{window.location.href='" + redirectPage + "';});");
        out.println("</script></body></html>");
    }
}
