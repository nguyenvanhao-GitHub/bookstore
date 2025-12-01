import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.*;
import java.util.Base64;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    //Sinh salt ngẫu nhiên
    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    //Mã hóa SHA-256 kèm salt
    private String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        byte[] hashed = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hashed);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contact = request.getParameter("contact");
        String gender = request.getParameter("gender");
        String role = request.getParameter("role");
        String password = request.getParameter("password");

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            //Kiểm tra email đã tồn tại trong 3 bảng
            String checkQuery = "SELECT email FROM user WHERE email = ? UNION "
                    + "SELECT email FROM publisher WHERE email = ? UNION "
                    + "SELECT email FROM admin WHERE email = ?";
            PreparedStatement checkStmt = connection.prepareStatement(checkQuery);
            checkStmt.setString(1, email);
            checkStmt.setString(2, email);
            checkStmt.setString(3, email);
            ResultSet resultSet = checkStmt.executeQuery();

            if (resultSet.next()) {
                showAlert(response,
                        "error",
                        "Email Already Registered",
                        "Please use a different email.",
                        "signup.jsp");
                return;
            }

            //Tạo salt và hash password
            String salt = generateSalt();
            String hashedPassword = hashPassword(password, salt);

            //Chọn bảng phù hợp với vai trò
            String insertQuery = null;
            if ("user".equalsIgnoreCase(role)) {
                insertQuery = "INSERT INTO user (name, email, contact, gender, password, salt, role, last_login, last_logout) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL)";
            } else if ("publisher".equalsIgnoreCase(role)) {
                insertQuery = "INSERT INTO publisher (name, email, contact, gender, password, salt, role, last_login, last_logout) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL)";
            } else if ("admin".equalsIgnoreCase(role)) {
                insertQuery = "INSERT INTO admin (name, email, contact, gender, password, salt, role, last_login, last_logout) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL)";
            }

            if (insertQuery == null) {
                showAlert(response, "error", "Invalid Role", "Please select a valid role.", "signup.jsp");
                return;
            }

            PreparedStatement insertStmt = connection.prepareStatement(insertQuery);
            insertStmt.setString(1, name);
            insertStmt.setString(2, email);
            insertStmt.setString(3, contact);
            insertStmt.setString(4, gender);
            insertStmt.setString(5, hashedPassword);
            insertStmt.setString(6, salt);
            insertStmt.setString(7, role);

            int rowsInserted = insertStmt.executeUpdate();

            if (rowsInserted > 0) {
                showAlert(response,
                        "success",
                        "Account Created Successfully!",
                        "You can now log in.",
                        "login.jsp");
            } else {
                showAlert(response,
                        "error",
                        "Registration Failed",
                        "Please try again later.",
                        "signup.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            showAlert(response,
                    "error",
                    "An unexpected error occurred!",
                    e.getMessage(),
                    "signup.jsp");
        }
    }

    // ✅ Hàm hiển thị SweetAlert và điều hướng
    private void showAlert(HttpServletResponse response, String icon, String title, String text, String redirectPage)
            throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<html><head>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({"
                + "icon: '" + icon + "',"
                + "title: '" + title + "',"
                + "text: '" + text + "'"
                + "}).then(()=>{ window.location='" + redirectPage + "'; });");
        out.println("</script>");
        out.println("</body></html>");
        out.close();
    }
}
