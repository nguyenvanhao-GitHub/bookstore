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

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        
        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String cartItemIdStr = request.getParameter("cartItemId");
        Connection conn = null;
        boolean success = false;
        
        try {
            int bookId = Integer.parseInt(cartItemIdStr);
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8",
                "root", ""
            );
            conn.setAutoCommit(false);
            
            // Get quantity to restore to stock
            PreparedStatement getQtyStmt = conn.prepareStatement(
                "SELECT quantity FROM cart WHERE book_id = ? AND user_email = ?"
            );
            getQtyStmt.setInt(1, bookId);
            getQtyStmt.setString(2, userEmail);
            ResultSet rs = getQtyStmt.executeQuery();
            
            int quantityToRestore = 0;
            if (rs.next()) {
                quantityToRestore = rs.getInt("quantity");
            }
            
            // Delete from cart
            PreparedStatement deleteStmt = conn.prepareStatement(
                "DELETE FROM cart WHERE book_id = ? AND user_email = ?"
            );
            deleteStmt.setInt(1, bookId);
            deleteStmt.setString(2, userEmail);
            int rowsDeleted = deleteStmt.executeUpdate();
            
            if (rowsDeleted > 0) {
                // Restore stock
                PreparedStatement restoreStockStmt = conn.prepareStatement(
                    "UPDATE books SET stock = stock + ? WHERE id = ?"
                );
                restoreStockStmt.setInt(1, quantityToRestore);
                restoreStockStmt.setInt(2, bookId);
                restoreStockStmt.executeUpdate();
                
                conn.commit();
                success = true;
            } else {
                conn.rollback();
            }
            
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
        
        // Show SweetAlert
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head>");
        out.println("<body>");
        
        if (success) {
            out.println("<script>");
            out.println("Swal.fire({");
            out.println("    title: 'Deleted!',");
            out.println("    text: 'Item has been removed from your cart.',");
            out.println("    icon: 'success',");
            out.println("    timer: 2000,");
            out.println("    showConfirmButton: false");
            out.println("}).then(() => { window.location.href = 'cart.jsp'; });");
            out.println("</script>");
        } else {
            out.println("<script>");
            out.println("Swal.fire({");
            out.println("    title: 'Error!',");
            out.println("    text: 'Failed to remove item. Please try again.',");
            out.println("    icon: 'error',");
            out.println("    confirmButtonText: 'OK'");
            out.println("}).then(() => { window.location.href = 'cart.jsp'; });");
            out.println("</script>");
        }
        
        out.println("</body>");
        out.println("</html>");
    }
}