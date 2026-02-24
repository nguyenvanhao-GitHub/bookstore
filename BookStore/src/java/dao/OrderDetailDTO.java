package dao;

public class OrderDetailDTO {

    private int bookId;
    private int quantity;
    
    private String orderStatus; 
    

    public OrderDetailDTO() {
    }

    public OrderDetailDTO(int bookId, int quantity, String orderStatus) {
        this.bookId = bookId;
        this.quantity = quantity;
        this.orderStatus = orderStatus;
    }


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

    @Override
    public String toString() {
        return "OrderDetailDTO{" +
               "bookId=" + bookId +
               ", quantity=" + quantity +
               ", orderStatus='" + orderStatus + '\'' +
               '}';
    }
}