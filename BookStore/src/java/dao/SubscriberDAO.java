package dao;

import context.DBContext;
import java.sql.*;

public class SubscriberDAO {

    DBContext db = new DBContext();

    public boolean deleteSubscriber(int id) {
        String sql = "DELETE FROM subscriber WHERE id=?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addSubscriber(String email) {
        String sql = "INSERT INTO subscriber (email) VALUES (?)";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Sửa hàm getAllSubscribers
    public java.util.List<entity.Subscriber> getAllSubscribersList() {
        java.util.List<entity.Subscriber> list = new java.util.ArrayList<>();
        String sql = "SELECT id, email, subscribed_at FROM subscriber ORDER BY subscribed_at DESC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                entity.Subscriber sub = new entity.Subscriber();
                sub.setId(rs.getInt("id"));
                sub.setEmail(rs.getString("email"));
                sub.setSubscribedAt(rs.getTimestamp("subscribed_at")); // MỚI
                list.add(sub);
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

    public int countSubscribers() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM subscriber")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public java.util.List<entity.Subscriber> getPaginatedSubscribers(int start, int total) {
        java.util.List<entity.Subscriber> list = new java.util.ArrayList<>();
        String sql = "SELECT id, email, subscribed_at FROM subscriber ORDER BY subscribed_at DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, start);
            ps.setInt(2, total);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                entity.Subscriber sub = new entity.Subscriber();
                sub.setId(rs.getInt("id"));
                sub.setEmail(rs.getString("email"));
                sub.setSubscribedAt(rs.getTimestamp("subscribed_at"));
                list.add(sub);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
// ...
}
