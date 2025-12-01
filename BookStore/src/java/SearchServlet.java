import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Search Servlet - Handles book search requests via AJAX
 * Returns JSON array of matching books
 */
@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set character encoding
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Get search query
        String query = request.getParameter("query");
        
        // Validate query
        if (query == null || query.trim().isEmpty()) {
            sendJsonResponse(response, new JSONArray());
            return;
        }
        
        // Perform search
        JSONArray results = searchBooks(query.trim());
        
        // Send response
        sendJsonResponse(response, results);
    }
    
    /**
     * Search books in database
     */
    private JSONArray searchBooks(String query) {
        JSONArray booksArray = new JSONArray();
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Load driver and connect
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Build SQL query with ranking
            String sql = 
                "SELECT id, name, author, price, image, category " +
                "FROM books " +
                "WHERE LOWER(name) LIKE ? " +
                "   OR LOWER(author) LIKE ? " +
                "   OR LOWER(category) LIKE ? " +
                "ORDER BY " +
                "   CASE " +
                "       WHEN LOWER(name) LIKE ? THEN 1 " +
                "       WHEN LOWER(author) LIKE ? THEN 2 " +
                "       ELSE 3 " +
                "   END, " +
                "   name ASC " +
                "LIMIT 12";
            
            stmt = conn.prepareStatement(sql);
            
            // Prepare search patterns
            String wildcardPattern = "%" + query.toLowerCase() + "%";
            String exactPattern = query.toLowerCase() + "%";
            
            // Set parameters
            stmt.setString(1, wildcardPattern);
            stmt.setString(2, wildcardPattern);
            stmt.setString(3, wildcardPattern);
            stmt.setString(4, exactPattern);
            stmt.setString(5, exactPattern);
            
            // Execute query
            rs = stmt.executeQuery();
            
            // Build JSON array
            while (rs.next()) {
                JSONObject book = new JSONObject();
                book.put("id", rs.getInt("id"));
                book.put("title", rs.getString("name"));
                book.put("author", rs.getString("author"));
                book.put("price", rs.getString("price"));
                book.put("image", rs.getString("image"));
                book.put("category", rs.getString("category"));
                
                booksArray.put(book);
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Database error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        
        return booksArray;
    }
    
    /**
     * Send JSON response
     */
    private void sendJsonResponse(HttpServletResponse response, JSONArray data) 
            throws IOException {
        PrintWriter out = response.getWriter();
        out.print(data.toString());
        out.flush();
    }
    
    /**
     * Close database resources safely
     */
    private void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try { if (rs != null) rs.close(); } catch (SQLException e) { }
        try { if (stmt != null) stmt.close(); } catch (SQLException e) { }
        try { if (conn != null) conn.close(); } catch (SQLException e) { }
    }
}