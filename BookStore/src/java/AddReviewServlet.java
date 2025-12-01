import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.*;
import java.sql.*;

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        PreparedStatement bookCheckStmt = null;
        ResultSet rs = null;
        ResultSet bookRs = null;
        
        String bookIdParam = request.getParameter("bookId");
        
        try {
            // Kiểm tra session
            HttpSession session = request.getSession(false);
            if (session == null) {
                redirectWithMessage(response, "error", "Phiên làm việc hết hạn!", 
                    "Vui lòng đăng nhập lại.", "login.jsp");
                return;
            }
            
            String userEmail = (String) session.getAttribute("userEmail");
            if (userEmail == null || userEmail.trim().isEmpty()) {
                redirectWithMessage(response, "error", "Chưa đăng nhập!", 
                    "Vui lòng đăng nhập để gửi đánh giá.", "login.jsp");
                return;
            }
            
            // Lấy và validate parameters
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            System.out.println("=== AddReviewServlet Debug ===");
            System.out.println("BookId: " + bookIdParam);
            System.out.println("Rating: " + ratingParam);
            System.out.println("Comment: " + comment);
            System.out.println("User: " + userEmail);
            
            if (bookIdParam == null || ratingParam == null || comment == null) {
                redirectWithMessage(response, "error", "Thiếu thông tin!", 
                    "Vui lòng điền đầy đủ thông tin đánh giá.", 
                    "categories.jsp");
                return;
            }
            
            int bookId;
            int rating;
            
            try {
                bookId = Integer.parseInt(bookIdParam);
                rating = Integer.parseInt(ratingParam);
            } catch (NumberFormatException e) {
                System.err.println("❌ Invalid number format: " + e.getMessage());
                redirectWithMessage(response, "error", "Dữ liệu không hợp lệ!", 
                    "Vui lòng thử lại.", "categories.jsp");
                return;
            }
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                redirectWithMessage(response, "error", "Đánh giá không hợp lệ!", 
                    "Vui lòng chọn từ 1 đến 5 sao.", "book-detail.jsp?id=" + bookId);
                return;
            }
            
            // Validate comment
            comment = comment.trim();
            if (comment.isEmpty()) {
                redirectWithMessage(response, "error", "Thiếu nội dung!", 
                    "Vui lòng nhập nội dung đánh giá.", "book-detail.jsp?id=" + bookId);
                return;
            }
            
            // Kết nối database
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            
            // ✅ KIỂM TRA SÁCH CÓ TỒN TẠI KHÔNG
            bookCheckStmt = conn.prepareStatement("SELECT id FROM books WHERE id = ?");
            bookCheckStmt.setInt(1, bookId);
            bookRs = bookCheckStmt.executeQuery();
            
            if (!bookRs.next()) {
                System.err.println("❌ Book not found: ID=" + bookId);
                redirectWithMessage(response, "error", "Không tìm thấy sản phẩm!", 
                    "Sản phẩm này không tồn tại hoặc đã bị xóa.", "categories.jsp");
                return;
            }
            
            System.out.println("✅ Book exists: ID=" + bookId);
            
            // Kiểm tra xem user đã review sách này chưa
            checkStmt = conn.prepareStatement(
                "SELECT id FROM reviews WHERE user_email = ? AND book_id = ?");
            checkStmt.setString(1, userEmail);
            checkStmt.setInt(2, bookId);
            rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                System.out.println("⚠️ User already reviewed this book");
                redirectWithMessage(response, "warning", "Đã đánh giá!", 
                    "Bạn đã đánh giá sản phẩm này rồi.", "book-detail.jsp?id=" + bookId);
                return;
            }
            
            // Insert review
            insertStmt = conn.prepareStatement(
                "INSERT INTO reviews (user_email, book_id, rating, comment, created_at) " +
                "VALUES (?, ?, ?, ?, NOW())");
            insertStmt.setString(1, userEmail);
            insertStmt.setInt(2, bookId);
            insertStmt.setInt(3, rating);
            insertStmt.setString(4, comment);
            
            int rowsAffected = insertStmt.executeUpdate();
            
            if (rowsAffected > 0) {
                System.out.println("✅ Review added successfully!");
                System.out.println("   - User: " + userEmail);
                System.out.println("   - BookId: " + bookId);
                System.out.println("   - Rating: " + rating);
                
                // ✅ REDIRECT ĐÚNG VỀ TRANG SÁCH VỪA REVIEW
                redirectWithMessage(response, "success", "Đánh giá thành công!", 
                    "Cảm ơn bạn đã chia sẻ nhận xét về sản phẩm.", 
                    "book-detail.jsp?id=" + bookId);
            } else {
                throw new SQLException("Insert failed, no rows affected");
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found: " + e.getMessage());
            e.printStackTrace();
            redirectWithMessage(response, "error", "Lỗi hệ thống!", 
                "Không tìm thấy driver database.", "index.jsp");
                
        } catch (SQLException e) {
            System.err.println("❌ Database error: " + e.getMessage());
            e.printStackTrace();
            
            String redirectUrl = (bookIdParam != null) ? 
                "book-detail.jsp?id=" + bookIdParam : "categories.jsp";
            
            redirectWithMessage(response, "error", "Lỗi database!", 
                "Không thể lưu đánh giá: " + e.getMessage(), redirectUrl);
                
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
            redirectWithMessage(response, "error", "Lỗi không xác định!", 
                "Vui lòng thử lại sau: " + e.getMessage(), "index.jsp");
                
        } finally {
            // Đóng kết nối
            try {
                if (bookRs != null) bookRs.close();
                if (bookCheckStmt != null) bookCheckStmt.close();
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (conn != null) conn.close();
                System.out.println("✅ Database connections closed");
            } catch (SQLException e) {
                System.err.println("❌ Error closing connections: " + e.getMessage());
            }
        }
    }
    
    /**
     * Phương thức helper để redirect với thông báo SweetAlert2
     */
    private void redirectWithMessage(HttpServletResponse response, String icon, 
            String title, String text, String redirectUrl) throws IOException {
        
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='vi'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Đang xử lý...</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }");
        out.println(".loading { text-align: center; }");
        out.println(".spinner { border: 4px solid #f3f3f3; border-top: 4px solid #3498db; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto; }");
        out.println("@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='loading'>");
        out.println("<div class='spinner'></div>");
        out.println("<p>Đang xử lý...</p>");
        out.println("</div>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: '" + icon + "',");
        out.println("  title: '" + escapeJs(title) + "',");
        out.println("  html: '" + escapeJs(text) + "',");
        
        // Màu button theo loại thông báo
        String buttonColor;
        switch(icon) {
            case "success": buttonColor = "#16a34a"; break;
            case "error": buttonColor = "#dc2626"; break;
            case "warning": buttonColor = "#f59e0b"; break;
            default: buttonColor = "#2563eb";
        }
        
        out.println("  confirmButtonColor: '" + buttonColor + "',");
        out.println("  confirmButtonText: 'Đóng',");
        out.println("  allowOutsideClick: false,");
        out.println("  allowEscapeKey: false");
        out.println("}).then((result) => {");
        out.println("  if (result.isConfirmed) {");
        out.println("    window.location.href = '" + escapeJs(redirectUrl) + "';");
        out.println("  }");
        out.println("});");
        out.println("</script>");
        out.println("</body>");
        out.println("</html>");
        
        out.close();
    }
    
    /**
     * Escape các ký tự đặc biệt cho JavaScript
     */
    private String escapeJs(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("'", "\\'")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("<", "\\x3C")
                   .replace(">", "\\x3E");
    }
}