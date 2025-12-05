package dao;

import context.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO {
    DBContext db = new DBContext();

    // DTO để hiển thị dữ liệu tổng hợp
    public static class AccountDTO {
        public String source;
        public int id;
        public String name;
        public String email;
        public String role;
        public String status;
        public Timestamp lastLogin;
        public String lockReason;
        public Timestamp lockedAt;
        public String contact;
        public String gender;
    }

    // 1. Auto Lock: Gọi Stored Procedure từ Database
    public int autoLockInactive(int days) {
        int count = 0;
        try (Connection conn = db.getConnection();
             CallableStatement cs = conn.prepareCall("{call AutoLockInactiveAccounts(?)}")) {
            
            cs.setInt(1, days);
            
            // Lấy kết quả trả về từ Procedure (SELECT locked_count)
            boolean hasResults = cs.execute();
            while (hasResults) {
                ResultSet rs = cs.getResultSet();
                if (rs.next()) {
                    count = rs.getInt("total_locked");
                }
                hasResults = cs.getMoreResults();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 2. Cập nhật trạng thái (Lock/Unlock)
    public boolean updateAccountStatus(String table, int id, String status, String reason) {
        if (!isValidTable(table)) return false;

        String sql;
        if ("Locked".equalsIgnoreCase(status)) {
            sql = "UPDATE `" + table + "` SET status = ?, lock_reason = ?, locked_at = NOW() WHERE id = ?";
        } else {
            // Khi mở khóa: Xóa lý do và thời gian khóa, set status = Active
            sql = "UPDATE `" + table + "` SET status = ?, lock_reason = NULL, locked_at = NULL WHERE id = ?";
        }

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            if ("Locked".equalsIgnoreCase(status)) {
                ps.setString(2, reason);
                ps.setInt(3, id);
            } else {
                ps.setInt(2, id);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // 3. Lấy danh sách (Union 3 bảng)
    public List<AccountDTO> getAllAccounts(int page, int recordsPerPage, String search) {
        List<AccountDTO> list = new ArrayList<>();
        int start = (page - 1) * recordsPerPage;
        String searchSql = "";
        
        if (search != null && !search.trim().isEmpty()) {
            searchSql = " WHERE name LIKE '%" + search + "%' OR email LIKE '%" + search + "%' ";
        }

        String sql = "SELECT * FROM ("
                + "SELECT 'admin' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM admin " + searchSql
                + "UNION ALL "
                + "SELECT 'user' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM user " + searchSql
                + "UNION ALL "
                + "SELECT 'publisher' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM publisher " + searchSql
                + ") as combined ORDER BY id DESC LIMIT ?, ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, start);
            ps.setInt(2, recordsPerPage);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AccountDTO acc = new AccountDTO();
                acc.source = rs.getString("source");
                acc.id = rs.getInt("id");
                acc.name = rs.getString("name");
                acc.email = rs.getString("email");
                acc.role = rs.getString("role");
                acc.status = rs.getString("status");
                acc.contact = rs.getString("contact");
                acc.gender = rs.getString("gender");
                acc.lastLogin = rs.getTimestamp("last_login");
                acc.lockReason = rs.getString("lock_reason");
                acc.lockedAt = rs.getTimestamp("locked_at");
                list.add(acc);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int countAllAccounts(String search) {
        String searchSql = "";
        if (search != null && !search.trim().isEmpty()) {
            searchSql = " WHERE name LIKE '%" + search + "%' OR email LIKE '%" + search + "%' ";
        }
        String sql = "SELECT COUNT(*) FROM (SELECT id FROM admin " + searchSql 
                   + "UNION ALL SELECT id FROM user " + searchSql 
                   + "UNION ALL SELECT id FROM publisher " + searchSql + ") as t";
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    
    // Các hàm phụ trợ (Insert, Update Info, Delete, Reset Password, Get Email)
    // Giữ nguyên như phiên bản trước hoặc thêm vào đây nếu cần thiết
    public boolean deleteAccount(String table, int id) {
        if(!isValidTable(table)) return false;
        try(Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement("DELETE FROM `"+table+"` WHERE id=?")) {
            ps.setInt(1, id); return ps.executeUpdate() > 0;
        } catch(Exception e){e.printStackTrace(); return false;}
    }
    
    public String getEmailById(String table, int id) {
        if(!isValidTable(table)) return null;
        try(Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT email FROM `"+table+"` WHERE id=?")) {
            ps.setInt(1, id); ResultSet rs = ps.executeQuery(); if(rs.next()) return rs.getString(1);
        } catch(Exception e){} return null;
    }
    
    public boolean resetPassword(String table, int id, String pass, String salt) {
        if(!isValidTable(table)) return false;
        try(Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement("UPDATE `"+table+"` SET password=?, salt=? WHERE id=?")) {
            ps.setString(1, pass); ps.setString(2, salt); ps.setInt(3, id); return ps.executeUpdate() > 0;
        } catch(Exception e){e.printStackTrace(); return false;}
    }

    private boolean isValidTable(String table) {
        return "user".equalsIgnoreCase(table) || "admin".equalsIgnoreCase(table) || "publisher".equalsIgnoreCase(table);
    }
}