package dao;

import context.DBContext;
import java.sql.*;

public class ContactDAO {

    DBContext db = new DBContext();

    public boolean saveMessage(String name, String email, String subject, String message) {
        String sql = "INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, subject);
            ps.setString(4, message);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteMessage(int id) {
        String sql = "DELETE FROM contact_messages WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<entity.ContactMessage> getAllMessages() {
        java.util.List<entity.ContactMessage> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM contact_messages ORDER BY submitted_at DESC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                entity.ContactMessage msg = new entity.ContactMessage();
                msg.setId(rs.getInt("id"));
                msg.setName(rs.getString("name"));
                msg.setEmail(rs.getString("email"));
                msg.setSubject(rs.getString("subject"));
                msg.setMessage(rs.getString("message"));
                msg.setSubmittedAt(rs.getTimestamp("submitted_at"));
                // Xóa dòng msg.setReplied(...);
                list.add(msg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countMessages() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM contact_messages")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public java.util.List<entity.ContactMessage> getPaginatedMessages(int start, int total) {
        java.util.List<entity.ContactMessage> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM contact_messages ORDER BY submitted_at DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, start);
            ps.setInt(2, total);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                entity.ContactMessage msg = new entity.ContactMessage();
                msg.setId(rs.getInt("id"));
                msg.setName(rs.getString("name"));
                msg.setEmail(rs.getString("email"));
                msg.setSubject(rs.getString("subject"));
                msg.setMessage(rs.getString("message"));
                msg.setSubmittedAt(rs.getTimestamp("submitted_at"));
                list.add(msg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
// ...
}
