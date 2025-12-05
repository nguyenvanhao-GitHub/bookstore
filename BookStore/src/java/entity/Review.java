package entity;

import java.sql.Timestamp;

public class Review {
    private int id;
    private int bookId;
    private String userEmail;
    private int rating;
    private String comment;
    private Timestamp createdAt;
    
    // Optional: Tên sách để hiển thị trong Admin
    private String bookName;

    public Review() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getBookName() { return bookName; }
    public void setBookName(String bookName) { this.bookName = bookName; }
}