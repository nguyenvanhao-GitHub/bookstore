package dao;

import context.DBContext;
import entity.CartItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    DBContext db = new DBContext();

    /**
     * Xử lý thêm vào giỏ hàng với Transaction Trả về chuỗi thông báo: "SUCCESS"
     * hoặc nội dung lỗi
     */
    public String addToCart(CartItem item) {
        Connection conn = null;
        PreparedStatement psCheckStock = null;
        PreparedStatement psCheckCart = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdateStock = null;
        ResultSet rs = null;

        try {
            conn = db.getConnection();
            // Bắt đầu Transaction
            conn.setAutoCommit(false);

            // 1. Kiểm tra tồn kho (Stock)
            String sqlCheckStock = "SELECT stock FROM books WHERE id = ?";
            psCheckStock = conn.prepareStatement(sqlCheckStock);
            psCheckStock.setInt(1, item.getBookId());
            rs = psCheckStock.executeQuery();

            int currentStock = 0;
            if (rs.next()) {
                currentStock = rs.getInt("stock");
            } else {
                return "Sách không tồn tại!";
            }
            rs.close();

            if (currentStock <= 0) {
                return "Sản phẩm này hiện đã hết hàng.";
            }

            // 2. Kiểm tra số lượng hiện tại trong giỏ của User
            String sqlCheckCart = "SELECT quantity FROM cart WHERE book_id = ? AND user_email = ?";
            psCheckCart = conn.prepareStatement(sqlCheckCart);
            psCheckCart.setInt(1, item.getBookId());
            psCheckCart.setString(2, item.getUserEmail());
            rs = psCheckCart.executeQuery();

            int currentCartQuantity = 0;
            if (rs.next()) {
                currentCartQuantity = rs.getInt("quantity");
            }

            // 3. Validate logic: Tổng mua > Tồn kho?
            if (currentCartQuantity + item.getQuantity() > currentStock) {
                return "Không thể thêm số lượng này. Kho chỉ còn: " + currentStock;
            }

            // 4. Insert hoặc Update Cart
            String sqlInsert = "INSERT INTO cart (book_id, user_email, bookname, author, publisher_email, price, image, quantity) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?) "
                    + "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity), updated_at = NOW()";

            psInsert = conn.prepareStatement(sqlInsert);
            psInsert.setInt(1, item.getBookId());
            psInsert.setString(2, item.getUserEmail());
            psInsert.setString(3, item.getBookName());
            psInsert.setString(4, item.getAuthor());
            psInsert.setString(5, item.getPublisherEmail());
            psInsert.setDouble(6, item.getPrice());
            psInsert.setString(7, item.getImage());
            psInsert.setInt(8, item.getQuantity());
            psInsert.executeUpdate();

            // 5. Trừ kho (Update Stock) - Theo logic gốc của bạn
            String sqlUpdateStock = "UPDATE books SET stock = stock - ? WHERE id = ? AND stock >= ?";
            psUpdateStock = conn.prepareStatement(sqlUpdateStock);
            psUpdateStock.setInt(1, item.getQuantity());
            psUpdateStock.setInt(2, item.getBookId());
            psUpdateStock.setInt(3, item.getQuantity());

            int updated = psUpdateStock.executeUpdate();
            if (updated == 0) {
                // Nếu update thất bại (do concurrency, ai đó vừa mua hết), rollback
                conn.rollback();
                return "Không đủ hàng trong kho (Lỗi đồng bộ).";
            }

            // Hoàn tất Transaction
            conn.commit();
            return "SUCCESS";

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return "Lỗi hệ thống: " + e.getMessage();
        } finally {
            // Đóng resources thủ công để đảm bảo an toàn
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psCheckStock != null) {
                    psCheckStock.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psCheckCart != null) {
                    psCheckCart.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psInsert != null) {
                    psInsert.close();
                }
            } catch (Exception e) {
            }
            try {
                if (psUpdateStock != null) {
                    psUpdateStock.close();
                }
            } catch (Exception e) {
            }
            try {
                if (conn != null) {
                    conn.setAutoCommit(true); // Trả lại trạng thái mặc định
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
    }

    public boolean removeFromCart(int bookId, String userEmail) {
        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Lấy số lượng cần trả lại kho
            int qty = 0;
            String getQtySql = "SELECT quantity FROM cart WHERE book_id=? AND user_email=?";
            try (PreparedStatement ps = conn.prepareStatement(getQtySql)) {
                ps.setInt(1, bookId);
                ps.setString(2, userEmail);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    qty = rs.getInt("quantity");
                }
            }

            // 2. Xóa khỏi giỏ
            String delSql = "DELETE FROM cart WHERE book_id=? AND user_email=?";
            try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                ps.setInt(1, bookId);
                ps.setString(2, userEmail);
                ps.executeUpdate();
            }

            // 3. Trả lại kho
            if (qty > 0) {
                String stockSql = "UPDATE books SET stock = stock + ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(stockSql)) {
                    ps.setInt(1, qty);
                    ps.setInt(2, bookId);
                    ps.executeUpdate();
                }
            }

            conn.commit(); // Thành công
            return true;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
            }
            e.printStackTrace();
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException ex) {
            }
        }
        return false;
    }

    public String updateCartQuantity(int bookId, String userEmail, int newQuantity) {
        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy số lượng cũ
            int oldQty = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT quantity FROM cart WHERE book_id=? AND user_email=?")) {
                ps.setInt(1, bookId);
                ps.setString(2, userEmail);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    oldQty = rs.getInt("quantity");
                } else {
                    return "ITEM_NOT_FOUND";
                }
            }

            // 2. Check tồn kho
            int currentStock = 0;
            try (PreparedStatement ps = conn.prepareStatement("SELECT stock FROM books WHERE id=?")) {
                ps.setInt(1, bookId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    currentStock = rs.getInt("stock");
                }
            }

            int diff = oldQty - newQuantity; // Dương: trả lại kho, Âm: lấy thêm từ kho
            if (diff < 0 && Math.abs(diff) > currentStock) {
                return "OUT_OF_STOCK";
            }

            // 3. Update Cart
            try (PreparedStatement ps = conn.prepareStatement("UPDATE cart SET quantity=?, updated_at=NOW() WHERE book_id=? AND user_email=?")) {
                ps.setInt(1, newQuantity);
                ps.setInt(2, bookId);
                ps.setString(3, userEmail);
                ps.executeUpdate();
            }

            // 4. Update Stock
            try (PreparedStatement ps = conn.prepareStatement("UPDATE books SET stock = stock + ? WHERE id=?")) {
                ps.setInt(1, diff);
                ps.setInt(2, bookId);
                ps.executeUpdate();
            }

            conn.commit();
            return "SUCCESS";
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
            }
            e.printStackTrace();
            return "ERROR";
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException ex) {
            }
        }
    }

    public List<CartItem> getCartItems(String userEmail) {
        List<CartItem> list = new ArrayList<>();
        // Thêm updated_at vào query
        String sql = "SELECT book_id, bookname, author, price, image, quantity, created_at, updated_at "
                + "FROM cart WHERE user_email = ? ORDER BY created_at DESC";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userEmail);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CartItem item = new CartItem();
                // Không set ID
                item.setBookId(rs.getInt("book_id"));
                item.setBookName(rs.getString("bookname"));
                item.setAuthor(rs.getString("author"));
                item.setPrice(rs.getDouble("price"));
                item.setImage(rs.getString("image"));
                item.setQuantity(rs.getInt("quantity"));
                item.setCreatedAt(rs.getTimestamp("created_at"));
                item.setUpdatedAt(rs.getTimestamp("updated_at")); // [MỚI]

                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void clearCart(String userEmail) {
        String sql = "DELETE FROM cart WHERE user_email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userEmail);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
