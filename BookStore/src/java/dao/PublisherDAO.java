package dao;

import context.DBContext;
import entity.Publisher;
import java.sql.*;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PublisherDAO {

    DBContext db = new DBContext();

    public Publisher login(String email, String password) {
        // [CẬP NHẬT] Lấy đủ các trường cần thiết
        String sql = "SELECT id, name, password, salt, status, contact, gender, role FROM publisher WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedPass = rs.getString("password");
                String salt = rs.getString("salt");

                // [Logic mới] Kiểm tra pass hash
                if (verifyPassword(password, salt, storedPass)) {
                    Publisher pub = new Publisher();
                    pub.setId(rs.getInt("id"));
                    pub.setEmail(email);
                    pub.setName(rs.getString("name"));
                    pub.setRole(rs.getString("role"));
                    pub.setStatus(rs.getString("status"));
                    pub.setContact(rs.getString("contact"));

                    // Cập nhật trạng thái đăng nhập
                    updateLoginStatus(email);

                    return pub;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void logout(String email) {
        String sql = "UPDATE publisher SET last_logout = NOW() WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void updateLoginStatus(String email) {
        String sql = "UPDATE publisher SET last_login = NOW() WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Hàm verify pass
    private boolean verifyPassword(String inputPass, String salt, String storedHash) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        String newHash = Base64.getEncoder().encodeToString(md.digest(inputPass.getBytes()));
        return newHash.equals(storedHash);
    }

    // Thêm vào PublisherDAO
    public void lockAccount(int id, String reason) {
        String sql = "UPDATE publisher SET status = 'Locked', lock_reason = ?, locked_at = NOW() WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // 1. Lấy thông tin Publisher theo Email
    public Publisher getPublisherByEmail(String email) {
        String sql = "SELECT * FROM publisher WHERE email = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Publisher(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("contact"),
                    rs.getString("gender"),
                    rs.getString("password"),
                    rs.getString("role"),
                    rs.getTimestamp("last_login"),
                    rs.getTimestamp("last_logout"),
                    rs.getString("status"),
                    rs.getString("lock_reason"),
                    rs.getTimestamp("locked_at"),
                    rs.getString("salt")
                );
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // 2. Cập nhật thông tin cơ bản
    public boolean updatePublisherInfo(String email, String name, String contact) {
        String sql = "UPDATE publisher SET name = ?, contact = ? WHERE email = ?";
        try (Connection conn = db.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, contact);
            ps.setString(3, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // 3. Đổi mật khẩu
    public boolean changePassword(String email, String currentPass, String newPass) {
        // Lấy thông tin cũ để verify pass hiện tại
        Publisher pub = getPublisherByEmail(email);
        if (pub == null) return false;

        try {
            if (verifyPassword(currentPass, pub.getSalt(), pub.getPassword())) {
                // Tạo salt và hash mới
                String newSalt = generateSalt();
                String newHash = hashPassword(newPass, newSalt);

                String sql = "UPDATE publisher SET password = ?, salt = ? WHERE email = ?";
                try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, newHash);
                    ps.setString(2, newSalt);
                    ps.setString(3, email);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }


    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }

    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    // 1. Thống kê tổng quan cho Publisher (Dashboard Cards)
    public Map<String, Object> getPublisherStats(String publisherEmail) {
        Map<String, Object> stats = new HashMap<>();
        // Khởi tạo mặc định
        stats.put("totalBooks", 0);
        stats.put("totalSold", 0);
        stats.put("totalRevenue", 0.0);
        stats.put("activeBooks", 0);

        try (Connection conn = db.getConnection()) {
            // A. Tổng số sách và sách đang active
            String sqlBooks = "SELECT COUNT(*) as total, SUM(CASE WHEN stock > 0 THEN 1 ELSE 0 END) as active FROM books WHERE publisher_email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlBooks)) {
                ps.setString(1, publisherEmail);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    stats.put("totalBooks", rs.getInt("total"));
                    stats.put("activeBooks", rs.getInt("active"));
                }
            }

            // B. Tổng số lượng bán và Doanh thu (Chỉ tính đơn đã giao/đã thanh toán)
            // Logic: Join OrderDetail -> Books (để lọc theo publisher) -> Orders (để lọc status)
            String sqlSales = "SELECT SUM(od.quantity) as sold_count, SUM(od.quantity * b.price) as revenue " +
                              "FROM order_detail od " +
                              "JOIN books b ON od.book_id = b.id " +
                              "JOIN orders o ON od.order_id = o.id " +
                              "WHERE b.publisher_email = ? AND o.status IN ('delivered', 'paid')";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlSales)) {
                ps.setString(1, publisherEmail);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    stats.put("totalSold", rs.getInt("sold_count"));
                    stats.put("totalRevenue", rs.getDouble("revenue"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // 2. Biểu đồ doanh thu 12 tháng (Chỉ của Publisher này)
    public List<Double> getPublisherMonthlyRevenue(String publisherEmail) {
        List<Double> list = new ArrayList<>(Collections.nCopies(12, 0.0));
        
        String sql = "SELECT MONTH(o.order_date) as month, SUM(od.quantity * b.price) as total " +
                     "FROM order_detail od " +
                     "JOIN books b ON od.book_id = b.id " +
                     "JOIN orders o ON od.order_id = o.id " +
                     "WHERE b.publisher_email = ? " +
                     "AND YEAR(o.order_date) = YEAR(CURDATE()) " +
                     "AND o.status IN ('delivered', 'paid') " +
                     "GROUP BY MONTH(o.order_date)";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, publisherEmail);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int month = rs.getInt("month");
                if (month >= 1 && month <= 12) {
                    list.set(month - 1, rs.getDouble("total"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Top sách bán chạy nhất của Publisher
    public List<Map<String, Object>> getTopSellingBooks(String publisherEmail) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT b.name, SUM(od.quantity) as sold " +
                     "FROM order_detail od " +
                     "JOIN books b ON od.book_id = b.id " +
                     "JOIN orders o ON od.order_id = o.id " +
                     "WHERE b.publisher_email = ? AND o.status IN ('delivered', 'paid') " +
                     "GROUP BY b.id " +
                     "ORDER BY sold DESC LIMIT 5";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, publisherEmail);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("name"));
                map.put("sold", rs.getInt("sold"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
