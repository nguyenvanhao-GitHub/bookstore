import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.Gson;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/BookRecommendationServlet")
public class BookRecommendationServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String type = request.getParameter("type"); // "category", "author", "user"
        String value = request.getParameter("value");
        String bookId = request.getParameter("bookId");
        
        HttpSession session = request.getSession(false);
        String userEmail = null;
        if (session != null) {
            userEmail = (String) session.getAttribute("userEmail");
        }
        
        List<Book> recommendations = new ArrayList<>();
        
        try {
            if ("category".equals(type) && value != null) {
                recommendations = getRecommendationsByCategory(value, bookId);
            } else if ("author".equals(type) && value != null) {
                recommendations = getRecommendationsByAuthor(value, bookId);
            } else if ("user".equals(type) && userEmail != null) {
                recommendations = getPersonalizedRecommendations(userEmail);
            } else if ("popular".equals(type)) {
                recommendations = getPopularBooks();
            } else if ("similar".equals(type) && bookId != null) {
                recommendations = getSimilarBooks(bookId);
            } else {
                recommendations = getPopularBooks();
            }
            
            // Return JSON response
            response.setContentType("application/json;charset=UTF-8");
            response.setHeader("Cache-Control", "no-cache");
            
            Gson gson = new Gson();
            String json = gson.toJson(recommendations);
            response.getWriter().write(json);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Get recommendations based on category
     */
    private List<Book> getRecommendationsByCategory(String category, String excludeBookId) 
            throws Exception {
        List<Book> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT id, name, author, price, category, image " +
                        "FROM books WHERE category = ? " +
                        (excludeBookId != null ? "AND id != ? " : "") +
                        "ORDER BY RAND() LIMIT 6";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, category);
            if (excludeBookId != null) {
                stmt.setString(2, excludeBookId);
            }
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("author"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image")
                ));
            }
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return books;
    }
    
    /**
     * Get recommendations based on author
     */
    private List<Book> getRecommendationsByAuthor(String author, String excludeBookId) 
            throws Exception {
        List<Book> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT id, name, author, price, category, image " +
                        "FROM books WHERE author = ? " +
                        (excludeBookId != null ? "AND id != ? " : "") +
                        "ORDER BY RAND() LIMIT 6";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, author);
            if (excludeBookId != null) {
                stmt.setString(2, excludeBookId);
            }
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("author"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image")
                ));
            }
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return books;
    }
    
    /**
     * Get personalized recommendations based on user's order history
     */
    private List<Book> getPersonalizedRecommendations(String userEmail) 
            throws Exception {
        List<Book> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Get user's most purchased categories
            String categorySql = "SELECT b.category, COUNT(*) as count " +
                                "FROM orders o " +
                                "JOIN cart c ON o.email = c.user_email " +
                                "JOIN books b ON c.book_id = b.id " +
                                "WHERE o.email = ? " +
                                "GROUP BY b.category " +
                                "ORDER BY count DESC LIMIT 3";
            
            stmt = conn.prepareStatement(categorySql);
            stmt.setString(1, userEmail);
            rs = stmt.executeQuery();
            
            List<String> favoriteCategories = new ArrayList<>();
            while (rs.next()) {
                favoriteCategories.add(rs.getString("category"));
            }
            
            rs.close();
            stmt.close();
            
            if (favoriteCategories.isEmpty()) {
                return getPopularBooks();
            }
            
            // Get books from favorite categories that user hasn't ordered
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT DISTINCT b.id, b.name, b.author, b.price, b.category, b.image ");
            sql.append("FROM books b ");
            sql.append("WHERE b.category IN (");
            for (int i = 0; i < favoriteCategories.size(); i++) {
                sql.append("?");
                if (i < favoriteCategories.size() - 1) sql.append(",");
            }
            sql.append(") ");
            sql.append("AND b.id NOT IN (");
            sql.append("  SELECT DISTINCT c.book_id FROM cart c ");
            sql.append("  JOIN orders o ON c.user_email = o.email ");
            sql.append("  WHERE o.email = ?");
            sql.append(") ");
            sql.append("ORDER BY RAND() LIMIT 6");
            
            stmt = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            for (String category : favoriteCategories) {
                stmt.setString(paramIndex++, category);
            }
            stmt.setString(paramIndex, userEmail);
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("author"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image")
                ));
            }
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return books;
    }
    
    /**
     * Get popular books (most ordered)
     */
    private List<Book> getPopularBooks() throws Exception {
        List<Book> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT b.id, b.name, b.author, b.price, b.category, b.image, " +
                        "COUNT(c.id) as order_count " +
                        "FROM books b " +
                        "LEFT JOIN cart c ON b.id = c.book_id " +
                        "GROUP BY b.id " +
                        "ORDER BY order_count DESC, RAND() " +
                        "LIMIT 6";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("author"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image")
                ));
            }
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return books;
    }
    
    /**
     * Get similar books (same category and author)
     */
    private List<Book> getSimilarBooks(String bookId) throws Exception {
        List<Book> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // First get the book's category and author
            String getBookSql = "SELECT category, author FROM books WHERE id = ?";
            stmt = conn.prepareStatement(getBookSql);
            stmt.setString(1, bookId);
            rs = stmt.executeQuery();
            
            String category = null;
            String author = null;
            
            if (rs.next()) {
                category = rs.getString("category");
                author = rs.getString("author");
            }
            
            rs.close();
            stmt.close();
            
            if (category == null) {
                return getPopularBooks();
            }
            
            // Get similar books
            String sql = "SELECT id, name, author, price, category, image " +
                        "FROM books " +
                        "WHERE (category = ? OR author = ?) AND id != ? " +
                        "ORDER BY " +
                        "  CASE WHEN category = ? AND author = ? THEN 1 " +
                        "       WHEN category = ? THEN 2 " +
                        "       WHEN author = ? THEN 3 " +
                        "       ELSE 4 END, " +
                        "  RAND() " +
                        "LIMIT 6";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, category);
            stmt.setString(2, author);
            stmt.setString(3, bookId);
            stmt.setString(4, category);
            stmt.setString(5, author);
            stmt.setString(6, category);
            stmt.setString(7, author);
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("author"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image")
                ));
            }
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
        
        return books;
    }
    
    /**
     * Book model class
     */
    private static class Book {
        private int id;
        private String name;
        private String author;
        private double price;
        private String category;
        private String image;
        
        public Book(int id, String name, String author, double price, 
                   String category, String image) {
            this.id = id;
            this.name = name;
            this.author = author;
            this.price = price;
            this.category = category;
            this.image = image;
        }
        
        // Getters
        public int getId() { return id; }
        public String getName() { return name; }
        public String getAuthor() { return author; }
        public double getPrice() { return price; }
        public String getCategory() { return category; }
        public String getImage() { return image; }
    }
}