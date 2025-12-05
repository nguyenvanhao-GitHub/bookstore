package dao;

import java.sql.*;

import context.DBContext;
import entity.Review;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class ReviewDAO {

    DBContext db = new DBContext();

    // Kiểm tra xem user đã đánh giá sách này chưa
    public boolean hasReviewed(String email, int bookId) {
        String query = "SELECT id FROM reviews WHERE user_email = ? AND book_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            ps.setInt(2, bookId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Thêm review mới
    public boolean addReview(Review review) {
        String query = "INSERT INTO reviews (user_email, book_id, rating, comment, created_at) VALUES (?, ?, ?, ?, NOW())";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, review.getUserEmail());
            ps.setInt(2, review.getBookId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getComment());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteReview(int id) {
        String sql = "DELETE FROM reviews WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Review> getReviewsByBookId(int bookId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT * FROM reviews WHERE book_id = ? ORDER BY created_at DESC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Review r = new Review();
                r.setId(rs.getInt("id"));
                r.setUserEmail(rs.getString("user_email"));
                r.setRating(rs.getInt("rating"));
                r.setComment(rs.getString("comment"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public double getAverageRating(int bookId) {
        String sql = "SELECT AVG(rating) FROM reviews WHERE book_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalReviews(int bookId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE book_id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getAllReviewsWithDetails(int offset, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();

        // SQL chuẩn cho MySQL: LIMIT [số lượng] OFFSET [vị trí bắt đầu]
        String sql = "SELECT r.id, r.user_email, r.rating, r.comment, r.created_at, b.name as book_name "
                + "FROM reviews r "
                + "JOIN books b ON r.book_id = b.id "
                + "ORDER BY r.created_at DESC "
                + "LIMIT ? OFFSET ?";

        // Debug: In ra console để kiểm tra xem hàm có được gọi không
        System.out.println("DEBUG: Getting reviews with Limit: " + pageSize + ", Offset: " + offset);

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) { // 1. Chỉ tạo PreparedStatement ở đây

            // 2. QUAN TRỌNG: Gán tham số TRƯỚC KHI execute
            ps.setInt(1, pageSize); // LIMIT
            ps.setInt(2, offset);   // OFFSET

            // 3. Bây giờ mới thực thi câu lệnh
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("id"));
                    map.put("userEmail", rs.getString("user_email"));
                    map.put("bookName", rs.getString("book_name"));
                    map.put("rating", rs.getInt("rating"));
                    map.put("comment", rs.getString("comment"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // Xem log server nếu có lỗi SQL
        }

        // Debug: Kiểm tra size list trả về
        System.out.println("DEBUG: Found " + list.size() + " reviews.");

        return list;
    }

    // Đảm bảo hàm đếm tổng số lượng vẫn đúng
    public int getTotalReviewsCount() {
        String sql = "SELECT COUNT(*) FROM reviews";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
