package dao;
import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class SocialDAO {
    DBContext db = new DBContext();

    public void trackShare(int bookId, String platform) {
        String sqlCreate = "CREATE TABLE IF NOT EXISTS social_shares (id INT AUTO_INCREMENT PRIMARY KEY, book_id INT, platform VARCHAR(50), share_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
        String sqlInsert = "INSERT INTO social_shares (book_id, platform) VALUES (?, ?)";
        
        try (Connection conn = db.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlCreate)) { ps.executeUpdate(); }
            
            try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                ps.setInt(1, bookId);
                ps.setString(2, platform);
                ps.executeUpdate();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}