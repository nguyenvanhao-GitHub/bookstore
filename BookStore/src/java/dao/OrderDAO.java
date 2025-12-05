package dao;

import context.DBContext;
import entity.Order;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO {

    DBContext db = new DBContext();

    public boolean cancelOrder(String orderId, String userEmail) {
        String sql = "UPDATE orders SET status = 'Cancelled' WHERE id = ? AND email = ? AND status = 'Pending'";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderId);
            ps.setString(2, userEmail);

            // Trả về true nếu có dòng được update (tức là hủy thành công)
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteOrder(String id) {
        String sql = "DELETE FROM orders WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createOrder(String orderId, String userEmail, String fullName, String phone,
            String address, String city, String state, String zip,
            String booksInfo, double total) {
        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert Order
            String sql = "INSERT INTO orders (id, customer_name, email, phone, address, city, state, zipcode, books, total_amount, payment_method, status, order_date) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Direct Order', 'pending', NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, orderId);
                ps.setString(2, fullName);
                ps.setString(3, userEmail);
                ps.setString(4, phone);
                ps.setString(5, address);
                ps.setString(6, city);
                ps.setString(7, state);
                ps.setString(8, zip);
                ps.setString(9, booksInfo);
                ps.setDouble(10, total);
                ps.executeUpdate();
            }

            // 2. Clear Cart
            String clearCart = "DELETE FROM cart WHERE user_email = ?";
            try (PreparedStatement ps = conn.prepareStatement(clearCart)) {
                ps.setString(1, userEmail);
                ps.executeUpdate();
            }

            conn.commit();
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

// 1. Lưu đơn hàng từ VNPay (Status = paid)
    public boolean saveOrderFromVNPay(String orderId, String fullName, String email,
            String phone, String address, String city, String state, String zipCode,
            String books, double total, String transactionNo) {

        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false); // Transaction

            // Insert Order
            String sql = "INSERT INTO orders (id, customer_name, email, phone, address, "
                    + "city, state, zipcode, books, total_amount, payment_method, status, "
                    + "transaction_id, order_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'VNPay', 'paid', ?, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, orderId);
                ps.setString(2, fullName);
                ps.setString(3, email);
                ps.setString(4, phone);
                ps.setString(5, address);
                ps.setString(6, city);
                ps.setString(7, state);
                ps.setString(8, zipCode);
                ps.setString(9, books);
                ps.setDouble(10, total);
                ps.setString(11, transactionNo);
                ps.executeUpdate();
            }

            // Xóa giỏ hàng
            String clearCart = "DELETE FROM cart WHERE user_email = ?";
            try (PreparedStatement ps = conn.prepareStatement(clearCart)) {
                ps.setString(1, email);
                ps.executeUpdate();
            }

            conn.commit();
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

// 2. Cập nhật trạng thái đơn hàng (Admin)
   public boolean updateOrderStatus(String orderId, String newStatus) {
    // ⚠️ LƯU Ý: Nếu cột 'cancelled_at' chưa tồn tại, bạn cần thêm nó vào bảng 'orders'
    // ALTER TABLE orders ADD COLUMN cancelled_at datetime DEFAULT NULL;
    
    String sql = "UPDATE orders SET status = ?, cancelled_at = NOW() WHERE id = ? AND status='pending'";
    
    try (Connection conn = db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, newStatus);
        ps.setString(2, orderId);
        
        int rowsAffected = ps.executeUpdate();
        
        // Trả về true nếu có 1 hàng bị ảnh hưởng (cập nhật thành công)
        return rowsAffected > 0;
        
    } catch (Exception e) {
        System.err.println("Error updating status for ID: " + orderId);
        e.printStackTrace();
        return false;
    }
}

// 3. Lấy thông tin cơ bản đơn hàng (để gửi mail status)
    public Map<String, String> getOrderBasicInfo(String orderId) {
        Map<String, String> info = new HashMap<>();
        String sql = "SELECT email, customer_name, status FROM orders WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                info.put("email", rs.getString("email"));
                info.put("name", rs.getString("customer_name"));
                info.put("status", rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return info;
    }

    public List<Order> getOrdersByEmail(String email) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE email = ? ORDER BY order_date DESC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getString("id"));
                o.setBooks(rs.getString("books"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setStatus(rs.getString("status"));
                o.setOrderDate(rs.getTimestamp("order_date"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Tìm hàm insertOrder và sửa tên cột
    public boolean insertOrder(Order order) throws ClassNotFoundException {
        // Sửa 'zipCode' thành 'zipcode' để khớp với database
        String sql = "INSERT INTO orders (id, customer_name, email, phone, address, city, state, zipcode, "
                + "books, total_amount, payment_method, status, transaction_id, order_date) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, order.getId());
            ps.setString(2, order.getCustomerName());
            ps.setString(3, order.getEmail());
            ps.setString(4, order.getPhone());
            ps.setString(5, order.getAddress());
            ps.setString(6, order.getCity());
            ps.setString(7, order.getState());
            ps.setString(8, order.getZipCode()); // Getter Java vẫn là getZipCode, nhưng cột DB là zipcode
            ps.setString(9, order.getBooks());
            ps.setDouble(10, order.getTotalAmount());
            ps.setString(11, order.getPaymentMethod());
            ps.setString(12, order.getStatus());
            ps.setString(13, order.getTransactionId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Phương thức hỗ trợ VNPayReturnServlet (mapping từ Map sang Object)
    public boolean saveVNPayOrder(java.util.Map<String, String> info, String transactionId) throws ClassNotFoundException {
        Order order = new Order();
        order.setId(info.get("orderId"));
        order.setCustomerName(info.get("fullName"));
        order.setEmail(info.get("email"));
        order.setPhone(info.get("phone"));
        order.setAddress(info.get("address"));
        order.setCity(info.get("city"));
        order.setState(info.get("state"));
        order.setZipCode(info.get("zipCode"));
        order.setBooks(info.get("books"));
        order.setTotalAmount(Double.parseDouble(info.get("total")));
        order.setPaymentMethod("VNPay");
        order.setStatus("paid"); // Đã thanh toán
        order.setTransactionId(transactionId);

        return insertOrder(order);
    }

    public List<entity.Order> getAllOrders(int start, int total) {
        List<entity.Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY order_date DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, start);
            ps.setInt(2, total);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                entity.Order o = new entity.Order();
                o.setId(rs.getString("id"));
                o.setCustomerName(rs.getString("customer_name"));
                o.setBooks(rs.getString("books"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setPaymentMethod(rs.getString("payment_method"));
                o.setStatus(rs.getString("status"));
                o.setOrderDate(rs.getTimestamp("order_date"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countOrders() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM orders")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countOrdersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM orders WHERE status = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getString("id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setEmail(rs.getString("email"));
        order.setPhone(rs.getString("phone"));
        order.setAddress(rs.getString("address"));
        order.setCity(rs.getString("city"));
        order.setState(rs.getString("state"));
        order.setZipCode(rs.getString("zipcode"));
        order.setBooks(rs.getString("books"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setStatus(rs.getString("status"));

        // MỚI: Mapping đầy đủ
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setTransactionId(rs.getString("transaction_id"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        return order;
    }

    // Thêm vào class OrderDAO.java (Giả định có OrderDetail DTO)
    public List<OrderDetailDTO> getOrderDetailsForCancellation(int orderId) {
        List<OrderDetailDTO> details = new ArrayList<>();
        // Dựa trên cấu trúc DB của bạn: Phải JOIN Order và OrderDetail
        String sql = "SELECT od.book_id, od.quantity, o.status FROM order_detail od JOIN orders o ON od.order_id = o.id WHERE od.order_id = ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                // Giả định OrderDetailDTO có bookId, quantity, và status (tạm thời)
                OrderDetailDTO detail = new OrderDetailDTO();
                detail.setBookId(rs.getInt("book_id"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setOrderStatus(rs.getString("status")); // Lấy status để kiểm tra ở Servlet
                details.add(detail);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return details;
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE orders SET status = ?, cancelled_at = NOW() WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    

    // Trong class OrderDAO.java

public String getOrderStatus(String orderId) {
    String status = null;
    // Lấy kết nối DB từ context (giả định db.getConnection() tồn tại)
    String sql = "SELECT status FROM orders WHERE id = ?";
    
    try (Connection conn = db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, orderId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            status = rs.getString("status");
        }
        
    } catch (Exception e) {
        System.err.println("Error fetching order status for ID: " + orderId);
        e.printStackTrace();
    }
    return status;
}
// Trong class OrderDAO.java

public String getBooksSummary(String orderId) {
    String booksSummary = null;
    String sql = "SELECT books FROM orders WHERE id = ?";
    
    try (Connection conn = db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, orderId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            booksSummary = rs.getString("books");
        }
        
    } catch (Exception e) {
        System.err.println("Error fetching book summary for ID: " + orderId);
        e.printStackTrace();
    }
    return booksSummary;
}


}
