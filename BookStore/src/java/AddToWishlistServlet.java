import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddToWishlistServlet")
public class AddToWishlistServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Lấy user_id từ session
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String bookIdParam = request.getParameter("bookId");

        if (userId == null) {
            out.write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để thêm vào yêu thích.\"}");
            return;
        }

        if (bookIdParam == null) {
            out.write("{\"status\":\"error\",\"message\":\"Thiếu mã sách.\"}");
            return;
        }

        int bookId = Integer.parseInt(bookIdParam);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // Kiểm tra xem sách đã có trong wishlist chưa
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT * FROM wishlist WHERE user_id = ? AND book_id = ?"
            );
            checkStmt.setInt(1, userId);
            checkStmt.setInt(2, bookId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                out.write("{\"status\":\"info\",\"message\":\"Sách này đã có trong danh sách yêu thích.\"}");
                rs.close();
                checkStmt.close();
                conn.close();
                return;
            }

            // Thêm vào wishlist
            PreparedStatement insertStmt = conn.prepareStatement(
                "INSERT INTO wishlist (user_id, book_id) VALUES (?, ?)"
            );
            insertStmt.setInt(1, userId);
            insertStmt.setInt(2, bookId);
            insertStmt.executeUpdate();

            insertStmt.close();
            conn.close();

            out.write("{\"status\":\"success\",\"message\":\"Đã thêm vào danh sách yêu thích!\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"status\":\"error\",\"message\":\"Lỗi khi thêm vào danh sách yêu thích.\"}");
        }
    }
}
