package dao;

import context.DBContext;
import entity.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    DBContext db = new DBContext();

    public boolean addCategory(String name, String desc) {
        String sql = "INSERT INTO category (name, description) VALUES (?, ?)";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, desc);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCategory(int id, String name, String description) {
        String sql = "UPDATE category SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCategory(int id) {
        String sql = "DELETE FROM category WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        // Sắp xếp theo tên hoặc ngày tạo tùy ý
        String sql = "SELECT * FROM category ORDER BY name";

        try (Connection conn = db.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                // [MỚI] Lấy timestamp từ DB
                c.setCreatedAt(rs.getTimestamp("created_at")); 
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public int countCategories() {
        try (Connection conn = db.getConnection(); 
             ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM category")) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}