package dao;

import context.DBContext;
import entity.Book;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO {

    DBContext db = new DBContext();

    public List<Book> getWishlistByUserId(int userId) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT b.id, b.name, b.image, b.price, b.author, b.publisher_email "
                + "FROM wishlist w "
                + "JOIN books b ON w.book_id = b.id "
                + "WHERE w.user_id = ? "
                + "ORDER BY w.id DESC";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Book b = new Book();
                b.setId(rs.getInt("id"));
                b.setName(rs.getString("name"));
                b.setImage(rs.getString("image"));
                b.setPrice(rs.getDouble("price"));
                b.setAuthor(rs.getString("author"));
                b.setPublisherEmail(rs.getString("publisher_email"));

                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public String addToWishlist(int userId, int bookId) {
        try (Connection conn = db.getConnection()) {
            String checkSql = "SELECT id FROM wishlist WHERE user_id = ? AND book_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                if (ps.executeQuery().next()) {
                    return "EXISTS";
                }
            }
            String insertSql = "INSERT INTO wishlist (user_id, book_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                return ps.executeUpdate() > 0 ? "SUCCESS" : "ERROR";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR";
        }
    }

    public boolean removeFromWishlist(int userId, int bookId) {
        String sql = "DELETE FROM wishlist WHERE user_id = ? AND book_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countWishlistItems(int userId) {
        String sql = "SELECT COUNT(*) FROM wishlist WHERE user_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTotalWishlistValue(int userId) {
        String sql = "SELECT COALESCE(SUM(b.price), 0) FROM wishlist w JOIN books b ON w.book_id = b.id WHERE w.user_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
