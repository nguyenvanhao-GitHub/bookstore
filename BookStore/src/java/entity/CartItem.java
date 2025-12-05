package entity;

import java.sql.Timestamp;

public class CartItem {
    // Đã xóa trường 'id' vì DB không có
    private int bookId;
    private String userEmail;
    private String bookName;
    private String author;
    private double price;
    private String image;
    private int quantity;
    private String publisherEmail;
    private Timestamp createdAt;
    private Timestamp updatedAt; // Thêm trường này cho đúng DB

    public CartItem() {
    }

    // Constructor 6 tham số khớp với AddToCartServlet
    public CartItem(int bookId, String bookName, String author, double price, String image, int quantity) {
        this.bookId = bookId;
        this.bookName = bookName;
        this.author = author;
        this.price = price;
        this.image = image;
        this.quantity = quantity;
    }

    public double getSubtotal() {
        return this.price * this.quantity;
    }

    // Getters and Setters
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getBookName() { return bookName; }
    public void setBookName(String bookName) { this.bookName = bookName; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getPublisherEmail() { return publisherEmail; }
    public void setPublisherEmail(String publisherEmail) { this.publisherEmail = publisherEmail; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}