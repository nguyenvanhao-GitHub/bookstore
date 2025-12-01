import java.io.IOException;
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

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        
        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String cartItemIdStr = request.getParameter("cartItemId");
        String newQuantityStr = request.getParameter("quantity");
        
        Connection conn = null;
        
        try {
            int bookId = Integer.parseInt(cartItemIdStr);
            int newQuantity = Integer.parseInt(newQuantityStr);
            
            if (newQuantity < 1) {
                response.sendRedirect("cart.jsp?error=invalid_quantity");
                return;
            }
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8",
                "root", ""
            );
            conn.setAutoCommit(false);
            
            // Get old quantity from cart
            PreparedStatement getCartStmt = conn.prepareStatement(
                "SELECT quantity FROM cart WHERE book_id = ? AND user_email = ?"
            );
            getCartStmt.setInt(1, bookId);
            getCartStmt.setString(2, userEmail);
            ResultSet cartRs = getCartStmt.executeQuery();
            
            int oldQuantity = 0;
            if (cartRs.next()) {
                oldQuantity = cartRs.getInt("quantity");
            } else {
                response.sendRedirect("cart.jsp?error=item_not_found");
                return;
            }
            
            // Get current book stock
            PreparedStatement getStockStmt = conn.prepareStatement(
                "SELECT stock FROM books WHERE id = ?"
            );
            getStockStmt.setInt(1, bookId);
            ResultSet stockRs = getStockStmt.executeQuery();
            
            int currentStock = 0;
            if (stockRs.next()) {
                currentStock = stockRs.getInt("stock");
            }
            
            // Calculate stock change
            int stockChange = oldQuantity - newQuantity;
            
            // Check if enough stock when increasing quantity
            if (stockChange < 0 && Math.abs(stockChange) > currentStock) {
                conn.rollback();
                response.sendRedirect("cart.jsp?error=out_of_stock");
                return;
            }
            
            // Update cart quantity
            PreparedStatement updateCartStmt = conn.prepareStatement(
                "UPDATE cart SET quantity = ?, updated_at = NOW() " +
                "WHERE book_id = ? AND user_email = ?"
            );
            updateCartStmt.setInt(1, newQuantity);
            updateCartStmt.setInt(2, bookId);
            updateCartStmt.setString(3, userEmail);
            updateCartStmt.executeUpdate();
            
            // Update stock (positive = restore, negative = deduct)
            PreparedStatement updateStockStmt = conn.prepareStatement(
                "UPDATE books SET stock = stock + ? WHERE id = ?"
            );
            updateStockStmt.setInt(1, stockChange);
            updateStockStmt.setInt(2, bookId);
            updateStockStmt.executeUpdate();
            
            conn.commit();
            
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) { }
            }
        }
        
        response.sendRedirect("cart.jsp");
    }
}