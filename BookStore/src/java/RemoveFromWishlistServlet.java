import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/RemoveFromWishlistServlet")
public class RemoveFromWishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            // Kiểm tra session
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                out.write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để thực hiện thao tác này.\"}");
                return;
            }
            
            Integer userId = (Integer) session.getAttribute("userId");
            String bookIdParam = request.getParameter("bookId");
            
            if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
                out.write("{\"status\":\"error\",\"message\":\"Không tìm thấy thông tin sách.\"}");
                return;
            }
            
            int bookId = Integer.parseInt(bookIdParam);
            
            // Kết nối database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // Xóa khỏi wishlist
            String sql = "DELETE FROM wishlist WHERE user_id = ? AND book_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, bookId);
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                out.write("{\"status\":\"success\",\"message\":\"Đã xóa sách khỏi danh sách yêu thích!\"}");
            } else {
                out.write("{\"status\":\"error\",\"message\":\"Không tìm thấy sách trong danh sách yêu thích.\"}");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            out.write("{\"status\":\"error\",\"message\":\"Mã sách không hợp lệ.\"}");
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("❌ SQL Error: " + e.getMessage());
            out.write("{\"status\":\"error\",\"message\":\"Lỗi cơ sở dữ liệu. Vui lòng thử lại sau.\"}");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            out.write("{\"status\":\"error\",\"message\":\"Lỗi kết nối database.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi. Vui lòng thử lại sau.\"}");
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            out.flush();
            out.close();
        }
    }
}