package utils;

import java.security.SecureRandom;
import java.sql.*;
import java.util.Base64;

public class RememberMeUtil {
    private static final int TOKEN_LENGTH = 32;
    private static final SecureRandom secureRandom = new SecureRandom();
    
    // Database connection
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    /**
     * Tạo token ngẫu nhiên an toàn
     */
    private static String generateSecureToken() {
        byte[] randomBytes = new byte[TOKEN_LENGTH];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    /**
     * Tạo và lưu token cho user
     * @param userId ID của user
     * @param email Email của user
     * @return Token string
     */
    public static String generateToken(int userId, String email) {
        String token = generateSecureToken();
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Xóa token cũ của user này
            String deleteOld = "DELETE FROM remember_me_tokens WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteOld)) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }
            
            // Lưu token mới
            String insert = "INSERT INTO remember_me_tokens (user_id, token, email, created_at, expires_at) " +
                           "VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))";
            try (PreparedStatement stmt = conn.prepareStatement(insert)) {
                stmt.setInt(1, userId);
                stmt.setString(2, token);
                stmt.setString(3, email);
                stmt.executeUpdate();
            }
            
            return token;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Xác thực token và trả về user info nếu hợp lệ
     * @param token Token cần xác thực
     * @return Array [userId, userName, userEmail, newToken] hoặc null
     */
    public static String[] validateToken(String token) {
        if (token == null || token.isEmpty()) {
            return null;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Lấy thông tin user từ token
            String sql = "SELECT t.user_id, t.email, u.name, u.status " +
                        "FROM remember_me_tokens t " +
                        "JOIN user u ON t.user_id = u.id " +
                        "WHERE t.token = ? AND t.expires_at > NOW()";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, token);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    String status = rs.getString("status");
                    
                    // Kiểm tra tài khoản có bị khóa không
                    if ("Locked".equalsIgnoreCase(status)) {
                        deleteToken(token); // Xóa token nếu tài khoản bị khóa
                        return null;
                    }
                    
                    int userId = rs.getInt("user_id");
                    String email = rs.getString("email");
                    String name = rs.getString("name");
                    
                    // Refresh token (tạo token mới)
                    String newToken = generateSecureToken();
                    String update = "UPDATE remember_me_tokens " +
                                   "SET token = ?, created_at = NOW(), expires_at = DATE_ADD(NOW(), INTERVAL 30 DAY) " +
                                   "WHERE token = ?";
                    try (PreparedStatement upStmt = conn.prepareStatement(update)) {
                        upStmt.setString(1, newToken);
                        upStmt.setString(2, token);
                        upStmt.executeUpdate();
                    }
                    
                    // Cập nhật last_login
                    String updateLogin = "UPDATE user SET last_login = NOW(), status = 'Active' WHERE id = ?";
                    try (PreparedStatement upLogin = conn.prepareStatement(updateLogin)) {
                        upLogin.setInt(1, userId);
                        upLogin.executeUpdate();
                    }
                    
                    return new String[]{String.valueOf(userId), name, email, newToken};
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Xóa token
     * @param token Token cần xóa
     */
    public static void deleteToken(String token) {
        if (token == null || token.isEmpty()) {
            return;
        }
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String sql = "DELETE FROM remember_me_tokens WHERE token = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, token);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Xóa tất cả token của một user
     * @param userId ID của user
     */
    public static void deleteTokenByUserId(int userId) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String sql = "DELETE FROM remember_me_tokens WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Xóa các token đã hết hạn
     */
    public static int cleanupExpiredTokens() {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String sql = "DELETE FROM remember_me_tokens WHERE expires_at < NOW()";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                return stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
}