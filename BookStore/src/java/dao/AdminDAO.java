// File: java/dao/AdminDAO.java
package dao;

import context.DBContext;
import entity.Admin; // Import entity Admin
import java.sql.*;
import java.util.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class AdminDAO {

    DBContext db = new DBContext();

    public Admin login(String email, String password) {
        String sql = "SELECT * FROM admin WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPass = rs.getString("password");
                String salt = rs.getString("salt");
                String status = rs.getString("status");

                boolean isVerified = false;

                // **LOGIC ĐÃ SỬA: Xử lý cả trường hợp có salt và không có salt**
                if (salt != null && !salt.trim().isEmpty()) {
                    // 1. Kiểm tra mật khẩu (Sử dụng Salted Hash)
                    if (verifyPassword(password, salt, storedPass)) {
                        isVerified = true;
                    }
                } else {
                    // 2. Kiểm tra mật khẩu (Dạng Plaintext - Không khuyến khích, nhưng cần cho dữ liệu cũ)
                    if (password.equals(storedPass)) {
                        isVerified = true;
                    }
                }

                if (isVerified) {
                    Admin admin = new Admin();
                    admin.setId(rs.getInt("id"));
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setContact(rs.getString("contact"));
                    admin.setGender(rs.getString("gender"));
                    admin.setRole(rs.getString("role"));
                    admin.setStatus(status);
                    admin.setLastLogin(rs.getTimestamp("last_login"));
                    admin.setLockReason(rs.getString("lock_reason"));
                    admin.setLockedAt(rs.getTimestamp("locked_at"));
                    admin.setLastLogout(rs.getTimestamp("last_logout"));

                    // 3. Nếu ACTIVE, thì update Last Login
                    if ("Active".equalsIgnoreCase(status)) {
                        updateLastLogin(email); // Chỉ update khi active login
                    }

                    return admin; // Trả về Admin object
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // Trả về null nếu sai email hoặc sai mật khẩu
    }

    public boolean updateAdminInfo(String email, String name, String contact) {
        String sql = "UPDATE admin SET name = ?, contact = ? WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, contact);
            ps.setString(3, email);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updateLastLogin(String email) {
        String sql = "UPDATE admin SET last_login = NOW() WHERE email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.executeUpdate();
        } catch (Exception e) {
        }
    }

    private boolean verifyPassword(String inputPass, String salt, String storedHash) throws Exception {
        if (salt == null || storedHash == null) {
            return false;
        }
        // Hash mật khẩu đầu vào với salt đã lưu
        String newHash = hashPassword(inputPass, salt);
        // So sánh hash mới tạo với hash đã lưu
        return newHash.equals(storedHash);
    }

    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        // LƯU Ý: Nếu DB lưu ở dạng hex string, không dùng Base64.getEncoder().encodeToString()
        // Nhưng tôi giữ lại logic Base64 theo mã bạn cung cấp.
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = db.getConnection()) {
            try (ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM books")) {
                if (rs.next()) {
                    stats.put("totalBooks", rs.getInt(1));
                }
            }
            try (ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM user")) {
                if (rs.next()) {
                    stats.put("totalUsers", rs.getInt(1));
                }
            }
            try (ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rs.next()) {
                    stats.put("totalOrders", rs.getInt(1));
                }
            }
            try (ResultSet rs = conn.createStatement().executeQuery("SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status IN ('delivered', 'paid')")) {
                if (rs.next()) {
                    stats.put("totalRevenue", rs.getDouble(1));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public List<Map<String, String>> getRecentOrders() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT id, customer_name, books, total_amount, status FROM orders ORDER BY order_date DESC LIMIT 5";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> order = new HashMap<>();
                order.put("id", rs.getString("id"));
                order.put("customer", rs.getString("customer_name"));
                order.put("books", rs.getString("books"));
                order.put("total", String.valueOf(rs.getDouble("total_amount")));
                order.put("status", rs.getString("status"));
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getNotificationCounts(long lastViewedOrders, long lastViewedReviews, long lastViewedContacts) {
        Map<String, Integer> counts = new HashMap<>();
        Connection conn = null;
        try {
            conn = db.getConnection();
            String sqlOrder = "SELECT COUNT(*) FROM orders WHERE UNIX_TIMESTAMP(order_date) * 1000 > ?";
            PreparedStatement ps1 = conn.prepareStatement(sqlOrder);
            ps1.setLong(1, lastViewedOrders);
            ResultSet rs1 = ps1.executeQuery();
            if (rs1.next()) {
                counts.put("newOrders", rs1.getInt(1));
            }

            String sqlReview = "SELECT COUNT(*) FROM reviews WHERE UNIX_TIMESTAMP(created_at) * 1000 > ?";
            PreparedStatement ps2 = conn.prepareStatement(sqlReview);
            ps2.setLong(1, lastViewedReviews);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                counts.put("newReviews", rs2.getInt(1));
            }

            String sqlContact = "SELECT COUNT(*) FROM contact_messages WHERE UNIX_TIMESTAMP(submitted_at) * 1000 > ?";
            PreparedStatement ps3 = conn.prepareStatement(sqlContact);
            ps3.setLong(1, lastViewedContacts);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) {
                counts.put("newContacts", rs3.getInt(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
            }
        }
        return counts;
    }

    public Admin getAdminByEmail(String email) {
        String sql = "SELECT id, name, email, contact, gender, last_login, last_logout, status, lock_reason, locked_at FROM admin WHERE email=?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Admin admin = new Admin();
                admin.setId(rs.getInt("id"));
                admin.setName(rs.getString("name"));
                admin.setEmail(rs.getString("email"));
                admin.setContact(rs.getString("contact"));
                admin.setGender(rs.getString("gender"));
                admin.setLastLogin(rs.getTimestamp("last_login"));
                admin.setLastLogout(rs.getTimestamp("last_logout"));
                admin.setStatus(rs.getString("status"));
                admin.setLockReason(rs.getString("lock_reason"));
                admin.setLockedAt(rs.getTimestamp("locked_at"));
                return admin;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // [MỚI] 1. Lấy doanh thu 12 tháng của năm hiện tại
    public List<Double> getMonthlyRevenueCurrentYear() {
        // Tạo list 12 phần tử có giá trị 0.0
        List<Double> list = new ArrayList<>(Collections.nCopies(12, 0.0));
        
        // Chỉ tính đơn hàng đã giao (delivered) hoặc đã thanh toán (paid)
        String sql = "SELECT MONTH(order_date) as month, SUM(total_amount) as total " +
                     "FROM orders WHERE YEAR(order_date) = YEAR(CURDATE()) " +
                     "AND status IN ('delivered', 'paid') " +
                     "GROUP BY MONTH(order_date)";
                     
        try (Connection conn = db.getConnection(); 
             Statement st = conn.createStatement(); 
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                int month = rs.getInt("month");
                double total = rs.getDouble("total");
                // Gán giá trị vào đúng vị trí tháng (tháng 1 là index 0)
                if (month >= 1 && month <= 12) {
                    list.set(month - 1, total);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // [MỚI] 2. Lấy số lượng đơn hàng theo từng trạng thái (Pending, Delivered, Cancelled)
    public Map<String, Integer> getOrderStatusCounts() {
        Map<String, Integer> map = new HashMap<>();
        // Khởi tạo giá trị mặc định để tránh null
        map.put("pending", 0);
        map.put("delivered", 0);
        map.put("cancelled", 0);
        
        String sql = "SELECT status, COUNT(*) as count FROM orders GROUP BY status";
        
        try (Connection conn = db.getConnection(); 
             Statement st = conn.createStatement(); 
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                // Chuẩn hóa key về chữ thường để dễ xử lý
                if (status != null) map.put(status.toLowerCase(), count);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
