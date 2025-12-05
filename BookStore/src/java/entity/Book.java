package entity;

import java.sql.Timestamp;

public class Book {

    private int id;
    private String name;
    private String author;
    private double price;
    private String category;
    private String image;
    private int stock;
    private String description;
    private String publisherEmail;
    private Timestamp createdAt;
    // [MỚI] Thêm trường PDF Preview
    private String pdfPreviewPath;

    public Book() {
    }

    // Constructor đầy đủ
    public Book(int id, String name, String author, double price, String category,
            String image, int stock, String description, String publisherEmail,
            Timestamp createdAt, String pdfPreviewPath) {
        this.id = id;
        this.name = name;
        this.author = author;
        this.price = price;
        this.category = category;
        this.image = image;
        this.stock = stock;
        this.description = description;
        this.publisherEmail = publisherEmail;
        this.createdAt = createdAt;
        this.pdfPreviewPath = pdfPreviewPath;
    }

    // Constructor dùng để thêm mới (không có ID và Time)
    public Book(String name, String author, double price, int stock, String description,
            String publisherEmail, String category, String image, String pdfPreviewPath) {
        this.name = name;
        this.author = author;
        this.price = price;
        this.stock = stock;
        this.description = description;
        this.publisherEmail = publisherEmail;
        this.category = category;
        this.image = image;
        this.pdfPreviewPath = pdfPreviewPath;
    }

    // Thêm Constructor này vào class Book
    public Book(int id, String name, String author, double price, String category, String image, String pdfPreviewPath) {
        this.id = id;
        this.name = name;
        this.author = author;
        this.price = price;
        this.category = category;
        this.image = image;
        this.pdfPreviewPath = pdfPreviewPath;
    }

    // Getters and Setters cũ giữ nguyên...
    // [MỚI] Getter/Setter cho PDF
    public String getPdfPreviewPath() {
        return pdfPreviewPath;
    }

    public void setPdfPreviewPath(String pdfPreviewPath) {
        this.pdfPreviewPath = pdfPreviewPath;
    }

    // Các Getter/Setter cũ cần giữ lại đầy đủ...
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPublisherEmail() {
        return publisherEmail;
    }

    public void setPublisherEmail(String publisherEmail) {
        this.publisherEmail = publisherEmail;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
