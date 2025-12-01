import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddToCart")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail == null || userEmail.trim().isEmpty()) {
            showAlert(out, "warning", "Login Required", 
                     "Please login first!", "login.jsp");
            return;
        }

        // Validate input parameters
        String bookIdStr = request.getParameter("bookId");
        String bookName = request.getParameter("bookName");
        String author = request.getParameter("author");
        String publisherEmail = request.getParameter("publisherEmail");
        String priceStr = request.getParameter("price");
        String image = request.getParameter("image");

        if (bookIdStr == null || bookIdStr.trim().isEmpty() ||
            bookName == null || bookName.trim().isEmpty() ||
            author == null || author.trim().isEmpty() ||
            publisherEmail == null || publisherEmail.trim().isEmpty() ||
            priceStr == null || priceStr.trim().isEmpty()) {
            
            showAlert(out, "error", "Invalid Request", 
                     "Missing required book information!", null);
            return;
        }

        // Parse bookId and price
        int bookId = 0;
        double price = 0;
        
        try {
            bookId = Integer.parseInt(bookIdStr);
            price = Double.parseDouble(priceStr);
        } catch (NumberFormatException e) {
            showAlert(out, "error", "Invalid Data", 
                     "Book ID or price format is incorrect!", null);
            return;
        }

        int quantityToAdd = 1;
        Connection conn = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            conn.setAutoCommit(false);

            // Check stock
            int currentStock = checkStock(conn, bookId);
            
            if (currentStock <= 0) {
                showAlert(out, "error", "Out of Stock", 
                         "This book is currently not available.", 
                         "book-detail.jsp?id=" + bookId);
                return;
            }

            // Check current cart quantity
            int currentCartQuantity = getCartQuantity(conn, bookId, userEmail);
            int totalQuantityNeeded = currentCartQuantity + quantityToAdd;
            
            if (totalQuantityNeeded > currentStock) {
                showAlert(out, "warning", "Stock Limit Reached", 
                         "You cannot add more. Maximum available: " + currentStock, 
                         "cart.jsp");
                return;
            }

            // Add to cart using INSERT ... ON DUPLICATE KEY UPDATE
            addToCart(conn, bookId, userEmail, bookName, author, 
                     publisherEmail, price, image, quantityToAdd);

            // Update stock
            updateStock(conn, bookId, quantityToAdd);

            conn.commit();

            // Success message
            showSuccessAlert(out, bookName, image);

        } catch (Exception e) {
            rollback(conn);
            e.printStackTrace();
            showAlert(out, "error", "Error", 
                     "An error occurred: " + e.getMessage(), null);
        } finally {
            closeConnection(conn);
        }
    }

    private int checkStock(Connection conn, int bookId) throws SQLException {
        String sql = "SELECT stock FROM books WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, bookId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stock");
                }
                throw new SQLException("Book not found with ID: " + bookId);
            }
        }
    }

    private int getCartQuantity(Connection conn, int bookId, String userEmail) 
            throws SQLException {
        String sql = "SELECT quantity FROM cart WHERE book_id = ? AND user_email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, bookId);
            stmt.setString(2, userEmail);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                }
                return 0;
            }
        }
    }

    private void addToCart(Connection conn, int bookId, String userEmail,
                          String bookName, String author, String publisherEmail,
                          double price, String image, int quantityToAdd) 
            throws SQLException {
        
        String sql = "INSERT INTO cart " +
                    "(book_id, user_email, bookname, author, publisher_email, price, image, quantity) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE " +
                    "quantity = quantity + VALUES(quantity), " +
                    "updated_at = NOW()";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, bookId);
            stmt.setString(2, userEmail);
            stmt.setString(3, bookName);
            stmt.setString(4, author);
            stmt.setString(5, publisherEmail);
            stmt.setDouble(6, price);
            stmt.setString(7, image != null ? image : "");
            stmt.setInt(8, quantityToAdd);
            stmt.executeUpdate();
        }
    }

    private void updateStock(Connection conn, int bookId, int quantityToDeduct) 
            throws SQLException {
        String sql = "UPDATE books SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantityToDeduct);
            stmt.setInt(2, bookId);
            stmt.setInt(3, quantityToDeduct);
            int updated = stmt.executeUpdate();
            if (updated == 0) {
                throw new SQLException("Insufficient stock available");
            }
        }
    }

    private void rollback(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    private void showSuccessAlert(PrintWriter out, String bookName, String image) {
        out.println("<html><head>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head><body><script>");
        out.println("Swal.fire({");
        out.println("  icon: 'success',");
        out.println("  title: 'Added to Cart!',");
        out.println("  text: '" + escapeJs(bookName) + " has been added to your cart.',");
        if (image != null && !image.trim().isEmpty()) {
            out.println("  imageUrl: '" + escapeJs(image) + "',");
            out.println("  imageWidth: 100,");
            out.println("  imageHeight: 100,");
        }
        out.println("  timer: 2500,");
        out.println("  timerProgressBar: true,");
        out.println("  showConfirmButton: false");
        out.println("}).then(() => { window.location.href='cart.jsp'; });");
        out.println("</script></body></html>");
    }

    private void showAlert(PrintWriter out, String icon, String title, 
                          String text, String redirectUrl) {
        out.println("<html><head>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head><body><script>");
        out.println("Swal.fire({");
        out.println("  icon: '" + icon + "',");
        out.println("  title: '" + escapeJs(title) + "',");
        out.println("  text: '" + escapeJs(text) + "',");
        out.println("  confirmButtonText: 'OK'");
        if (redirectUrl != null) {
            out.println("}).then(() => { window.location.href='" + redirectUrl + "'; });");
        } else {
            out.println("}).then(() => { window.history.back(); });");
        }
        out.println("</script></body></html>");
    }

    private String escapeJs(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("'", "\\'")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r");
    }
}
