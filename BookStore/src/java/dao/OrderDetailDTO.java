package dao;

// Import các thư viện cần thiết nếu sử dụng Timestamp hoặc các loại dữ liệu phức tạp khác
// (Trong trường hợp này chỉ cần các loại dữ liệu cơ bản)

/**
 * Data Transfer Object (DTO) dùng để truyền thông tin chi tiết
 * của một mặt hàng trong đơn hàng.
 */
public class OrderDetailDTO {

    // Thông tin cơ bản của sản phẩm
    private int bookId;
    private int quantity;
    
    // Thông tin trạng thái (được lấy từ bảng 'orders' thông qua JOIN)
    private String orderStatus; 
    
    // Constructors

    public OrderDetailDTO() {
    }

    public OrderDetailDTO(int bookId, int quantity, String orderStatus) {
        this.bookId = bookId;
        this.quantity = quantity;
        this.orderStatus = orderStatus;
    }

    // Getters and Setters

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    // Tùy chọn: Thêm phương thức toString() để debug
    @Override
    public String toString() {
        return "OrderDetailDTO{" +
               "bookId=" + bookId +
               ", quantity=" + quantity +
               ", orderStatus='" + orderStatus + '\'' +
               '}';
    }
}