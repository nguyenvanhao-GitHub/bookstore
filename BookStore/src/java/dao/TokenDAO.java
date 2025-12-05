package dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import context.DBContext; // Giả định class này tồn tại

public class TokenDAO {
    
    private final DBContext db = new DBContext(); // Khởi tạo DBContext
    private static final DateTimeFormatter DB_DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * Lưu hoặc cập nhật token mới vào DB.
     */
    public void saveToken(String email, String token, LocalDateTime expiryTime) {
        String sql = "INSERT INTO password_reset_tokens (email, token, expires_at) VALUES (?, ?, ?)" +
                     "ON DUPLICATE KEY UPDATE token = VALUES(token), expires_at = VALUES(expires_at), created_at = NOW()";
        
        try (Connection conn = db.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, token);
            ps.setString(3, expiryTime.format(DB_DATETIME_FORMATTER)); // Chuyển đổi LocalDateTime sang chuỗi
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Kiểm tra token có hợp lệ (tồn tại và chưa hết hạn) hay không.
     */
    public boolean isTokenValid(String email, String token) {
        String sql = "SELECT expires_at FROM password_reset_tokens WHERE email = ? AND token = ?";
        
        try (Connection conn = db.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, token);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                // Lấy thời gian hết hạn và so sánh với thời gian hiện tại
                Timestamp expiresAt = rs.getTimestamp("expires_at");
                LocalDateTime expiryDateTime = expiresAt.toLocalDateTime();
                
                return expiryDateTime.isAfter(LocalDateTime.now());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Xóa token sau khi reset mật khẩu thành công.
     */
    public boolean deleteToken(String token) {
        String sql = "DELETE FROM password_reset_tokens WHERE token = ?";
        
        try (Connection conn = db.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}