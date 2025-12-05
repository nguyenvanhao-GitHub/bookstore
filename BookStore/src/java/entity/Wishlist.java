package entity;
import java.sql.Timestamp;

public class Wishlist {
    private int id;
    private int userId;
    private int bookId;
    private Timestamp addedAt; // Sửa từ createdAt -> addedAt

    public Wishlist() {}

    public Wishlist(int id, int userId, int bookId, Timestamp addedAt) {
        this.id = id;
        this.userId = userId;
        this.bookId = bookId;
        this.addedAt = addedAt;
    }

    // Getter/Setter mới
    public Timestamp getAddedAt() { return addedAt; }
    public void setAddedAt(Timestamp addedAt) { this.addedAt = addedAt; }
    
    // ... Các getter/setter khác giữ nguyên
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
}