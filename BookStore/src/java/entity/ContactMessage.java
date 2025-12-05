package entity;
import java.sql.Timestamp;

public class ContactMessage {
    private int id;
    private String name;
    private String email;
    private String subject;
    private String message;
    private Timestamp submittedAt;
    // Đã xóa private boolean isReplied;

    public ContactMessage() {}

    public ContactMessage(int id, String name, String email, String subject, String message, Timestamp submittedAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.submittedAt = submittedAt;
    }

    // Getters và Setters (Xóa getter/setter của isReplied)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }
}