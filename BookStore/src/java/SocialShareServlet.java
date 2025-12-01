import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;

@WebServlet("/SocialShareServlet")
public class SocialShareServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    private static final String BASE_URL = "http://localhost:8080/BookStore";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String platform = request.getParameter("platform");
        String bookId = request.getParameter("bookId");
        
        if ("getLinks".equals(action) && bookId != null) {
            // Return JSON with all social share links
            generateShareLinks(request, response, bookId);
        } else if ("track".equals(action) && platform != null && bookId != null) {
            // Track share analytics
            trackShare(bookId, platform);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true}");
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters");
        }
    }
    
    /**
     * Generate social media share links for a book
     */
    private void generateShareLinks(HttpServletRequest request, HttpServletResponse response, 
            String bookId) throws IOException {
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT name, author, price, image, description FROM books WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(bookId));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String bookName = rs.getString("name");
                String author = rs.getString("author");
                double price = rs.getDouble("price");
                String image = rs.getString("image");
                String description = rs.getString("description");
                
                String bookUrl = BASE_URL + "/book-details.jsp?id=" + bookId;
                String imageUrl = BASE_URL + "/" + image;
                
                String shareText = bookName + " by " + author + " - Only Rs." + 
                                  String.format("%.2f", price) + " at E-Books Store!";
                
                if (description != null && description.length() > 100) {
                    description = description.substring(0, 100) + "...";
                }
                
                // Create JSON response with all share links
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"success\":true,");
                json.append("\"bookName\":\"").append(escapeJson(bookName)).append("\",");
                json.append("\"author\":\"").append(escapeJson(author)).append("\",");
                json.append("\"price\":").append(price).append(",");
                json.append("\"bookUrl\":\"").append(bookUrl).append("\",");
                json.append("\"shareLinks\":{");
                
                // Facebook
                String fbLink = "https://www.facebook.com/sharer/sharer.php?u=" + 
                               URLEncoder.encode(bookUrl, StandardCharsets.UTF_8);
                json.append("\"facebook\":\"").append(fbLink).append("\",");
                
                // Twitter/X
                String twitterLink = "https://twitter.com/intent/tweet?text=" + 
                                    URLEncoder.encode(shareText, StandardCharsets.UTF_8) + 
                                    "&url=" + URLEncoder.encode(bookUrl, StandardCharsets.UTF_8);
                json.append("\"twitter\":\"").append(twitterLink).append("\",");
                
                // LinkedIn
                String linkedInLink = "https://www.linkedin.com/sharing/share-offsite/?url=" + 
                                     URLEncoder.encode(bookUrl, StandardCharsets.UTF_8);
                json.append("\"linkedin\":\"").append(linkedInLink).append("\",");
                
                // WhatsApp
                String whatsappLink = "https://api.whatsapp.com/send?text=" + 
                                     URLEncoder.encode(shareText + " " + bookUrl, StandardCharsets.UTF_8);
                json.append("\"whatsapp\":\"").append(whatsappLink).append("\",");
                
                // Telegram
                String telegramLink = "https://t.me/share/url?url=" + 
                                     URLEncoder.encode(bookUrl, StandardCharsets.UTF_8) + 
                                     "&text=" + URLEncoder.encode(shareText, StandardCharsets.UTF_8);
                json.append("\"telegram\":\"").append(telegramLink).append("\",");
                
                // Email
                String emailSubject = "Check out this book: " + bookName;
                String emailBody = shareText + "\n\n" + bookUrl;
                String emailLink = "mailto:?subject=" + 
                                  URLEncoder.encode(emailSubject, StandardCharsets.UTF_8) + 
                                  "&body=" + URLEncoder.encode(emailBody, StandardCharsets.UTF_8);
                json.append("\"email\":\"").append(emailLink).append("\",");
                
                // Pinterest
                String pinterestLink = "https://pinterest.com/pin/create/button/?url=" + 
                                      URLEncoder.encode(bookUrl, StandardCharsets.UTF_8) + 
                                      "&media=" + URLEncoder.encode(imageUrl, StandardCharsets.UTF_8) + 
                                      "&description=" + URLEncoder.encode(shareText, StandardCharsets.UTF_8);
                json.append("\"pinterest\":\"").append(pinterestLink).append("\",");
                
                // Copy Link
                json.append("\"copy\":\"").append(bookUrl).append("\"");
                
                json.append("}");
                json.append("}");
                
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(json.toString());
                
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"error\":\"Book not found\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"" + 
                                      escapeJson(e.getMessage()) + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
    
    /**
     * Track social media shares for analytics
     */
    private void trackShare(String bookId, String platform) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Create table if not exists
            String createTableSql = "CREATE TABLE IF NOT EXISTS social_shares (" +
                                   "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                   "book_id INT NOT NULL, " +
                                   "platform VARCHAR(50) NOT NULL, " +
                                   "share_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                                   "FOREIGN KEY (book_id) REFERENCES books(id)" +
                                   ")";
            
            stmt = conn.prepareStatement(createTableSql);
            stmt.executeUpdate();
            stmt.close();
            
            // Insert share record
            String insertSql = "INSERT INTO social_shares (book_id, platform) VALUES (?, ?)";
            stmt = conn.prepareStatement(insertSql);
            stmt.setInt(1, Integer.parseInt(bookId));
            stmt.setString(2, platform);
            stmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
    
    /**
     * Escape JSON strings
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}