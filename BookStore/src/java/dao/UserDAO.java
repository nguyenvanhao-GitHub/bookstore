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

    public void updateLastLogin(int userId) {
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

    private boolean verifyPassword(String inputPass, String salt, String storedHash) throws Exception {
        if (salt == null || storedHash == null) {
            return false;
        }
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        String newHash = Base64.getEncoder().encodeToString(md.digest(inputPass.getBytes("UTF-8")));
        return newHash.equals(storedHash);
    }

    public void logout(String email) {
        String sql = "UPDATE user SET last_logout = NOW(), status = 'inactive' WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

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
            ps.setString(3, newAddress); 
            ps.setString(4, oldEmail);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(String email, String currentPass, String newPass) {
        String sqlGet = "SELECT password, salt FROM user WHERE email = ?";
        String sqlUpdate = "UPDATE user SET password = ?, salt = ? WHERE email = ?";

        try (Connection conn = db.getConnection()) {
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
                String newSalt = generateSalt(); 
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

    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }

    private String generateSalt() {
        return "randomSalt"; 
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

    public List<User> getAllUsers(int start, int total) {
        List<User> list = new ArrayList<>();
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
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isEmailAdmin(String email) {
        String sql = "SELECT COUNT(*) FROM user WHERE email = ? AND role_id = 1";
        try (Connection conn = db.getConnection();
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
    
    public boolean updateUserProfile(User user) {
        String sql = "UPDATE user SET name = ?, contact = ?, gender = ? WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getContact());
            ps.setString(3, user.getGender());
            ps.setString(4, user.getEmail());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkPassword(String email, String inputRawPassword) {
        String sql = "SELECT password, salt FROM user WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password");
                String salt = rs.getString("salt");
                return verifyPassword(inputRawPassword, salt, storedHash);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(String email, String newRawPassword) {
        String sql = "UPDATE user SET password = ?, salt = ? WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String newSalt = generateSalt();
            String newHashedPass = hashPassword(newRawPassword, newSalt);

            ps.setString(1, newHashedPass);
            ps.setString(2, newSalt);
            ps.setString(3, email);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
