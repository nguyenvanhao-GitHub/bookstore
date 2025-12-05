package dao;

import context.DBContext;
import entity.User;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.sql.*;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

public class UserDAO {

    DBContext db = new DBContext();

    public User login(String email, String password) {
        String sql = "SELECT id, name, password, salt, status, role, last_login, lock_reason FROM user WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPass = rs.getString("password");
                String salt = rs.getString("salt");

                // Verify mật khẩu
                if (verifyPassword(password, salt, storedPass)) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(email);
                    user.setStatus(rs.getString("status")); // Lấy đúng status hiện tại trong DB
                    user.setRole(rs.getString("role"));
                    user.setLastLogin(rs.getTimestamp("last_login"));
                    user.setLockReason(rs.getString("lock_reason"));
                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 2. Cập nhật Last Login: Chỉ update nếu KHÔNG BỊ KHÓA
    public void updateLastLogin(int userId) {
        // Logic: Cập nhật thời gian login. 
        // Nếu status là 'Inactive' -> chuyển thành 'Active'. 
        // Nếu status là 'Locked' -> GIỮ NGUYÊN (Không được tự động mở khóa).
        String sql = "UPDATE user SET last_login = NOW(), "
                + "status = CASE WHEN status = 'Inactive' THEN 'Active' ELSE status END "
                + "WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Helper Verify Password
    private boolean verifyPassword(String inputPass, String salt, String storedHash) throws Exception {
        if (salt == null || storedHash == null) {
            return false;
        }
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        String newHash = Base64.getEncoder().encodeToString(md.digest(inputPass.getBytes("UTF-8")));
        return newHash.equals(storedHash);
    }

    // Dùng cho Logout
    public void logout(String email) {
        String sql = "UPDATE user SET last_logout = NOW(), status = 'inactive' WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Dùng cho Forgot Password: Kiểm tra email có tồn tại không -> Trả về ID
    public int getUserIdByEmail(String email) {
        String sql = "SELECT id FROM user WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Dùng cho Forgot Password: Cập nhật pass mới
    public boolean updatePassword(int userId, String hashedPassword, String salt) {
        String sql = "UPDATE user SET password = ?, salt = ? WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setString(2, salt);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkEmailExistsInAllRoles(String email) {
        String sql = "SELECT email FROM user WHERE email = ? UNION "
                + "SELECT email FROM publisher WHERE email = ? UNION "
                + "SELECT email FROM admin WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            ps.setString(3, email);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(String name, String email, String contact, String gender,
            String role, String hashedPassword, String salt) {
        String table = "";
        if ("user".equalsIgnoreCase(role)) {
            table = "user";
        } else if ("publisher".equalsIgnoreCase(role)) {
            table = "publisher";
        } else if ("admin".equalsIgnoreCase(role)) {
            table = "admin";
        } else {
            return false;
        }

        String sql = "INSERT INTO " + table + " (name, email, contact, gender, password, salt, role) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, contact);
            ps.setString(4, gender);
            ps.setString(5, hashedPassword);
            ps.setString(6, salt);
            ps.setString(7, role);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateUserInfo(String oldEmail, String newName, String newPhone, String newAddress) {
        String sql = "UPDATE user SET name = ?, contact = ?, address = ? WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newName);
            ps.setString(2, newPhone);
            ps.setString(3, newAddress); // Cần đảm bảo bảng user có cột address, nếu không hãy thêm vào DB hoặc bỏ dòng này
            ps.setString(4, oldEmail);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(String email, String currentPass, String newPass) {
        // Cần lấy salt cũ để check pass cũ trước
        String sqlGet = "SELECT password, salt FROM user WHERE email = ?";
        String sqlUpdate = "UPDATE user SET password = ?, salt = ? WHERE email = ?";

        try (Connection conn = db.getConnection()) {
            // 1. Verify old pass
            String storedPass = null;
            String salt = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    storedPass = rs.getString("password");
                    salt = rs.getString("salt");
                }
            }

            if (storedPass != null && verifyPassword(currentPass, salt, storedPass)) {
                // 2. Update new pass
                String newSalt = generateSalt(); // Hàm này cần implement hoặc lấy từ Utils
                String newHashed = hashPassword(newPass, newSalt);
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setString(1, newHashed);
                    ps.setString(2, newSalt);
                    ps.setString(3, email);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteAccount(String email) {
        String sql = "DELETE FROM user WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Helper hashing (bạn có thể đưa vào class Utils riêng)
    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }

    private String generateSalt() {
        // Logic sinh salt (copy từ SignupServlet cũ sang đây hoặc Utils)
        return "randomSalt"; // Placeholder
    }

    private void updateLastLogin(String email) {
        String sql = "UPDATE user SET last_login = NOW(), status = 'Active' WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<entity.User> getAllUsers(int start, int total) {
        List<entity.User> list = new ArrayList<>();
        String sql = "SELECT * FROM user ORDER BY id DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, start);
            ps.setInt(2, total);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                entity.User u = new entity.User();
                u.setId(rs.getInt("id"));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                u.setStatus(rs.getString("status"));
                u.setLastLogin(rs.getTimestamp("last_login"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUsers() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM user")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void lockAccount(int id, String reason) {
        String sql = "UPDATE user SET status = 'Locked', lock_reason = ?, locked_at = NOW() WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Thêm vào class UserDAO
    // 1. Lấy thông tin User chi tiết (Dùng cho trang Settings)
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM user WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setContact(rs.getString("contact"));
                user.setGender(rs.getString("gender"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                // Các trường bảo mật như password/salt không cần lấy ở đây nếu không dùng
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Trong class UserDAO.java hiện tại của bạn
// ... (các imports và constructor hiện có) ...
    /**
     * Kiểm tra xem email có tồn tại VÀ có phải là tài khoản Admin hay không.
     */
    public boolean isEmailAdmin(String email) {
        // Giả định: role_id = 1 là Admin
        String sql = "SELECT COUNT(*) FROM user WHERE email = ? AND role_id = 1";
        try (Connection conn = db.getConnection(); // Sử dụng DBContext của bạn
                 PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật mật khẩu Admin (đã được Hash) và Salt mới.
     */
    public boolean updateAdminPassword(String email, String hashedPass, String salt) {
        String sql = "UPDATE user SET password = ?, salt = ?, status = 'Active' WHERE email = ? AND role_id = 1";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hashedPass);
            ps.setString(2, salt);
            ps.setString(3, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
