package entity;

import java.sql.Timestamp;

public class User {
    private int id;
    private String name;
    private String email;
    private String contact;
    private String password;
    private String salt;
    private String gender;
    private String role; 
    private String status;
    private Timestamp lastLogin;
    // [MỚI] Thêm các trường từ DB
    private Timestamp lastLogout;
    private String lockReason;
    private Timestamp lockedAt;

    public User() {}

    // Getters and Setters cho các trường mới
    public Timestamp getLastLogout() { return lastLogout; }
    public void setLastLogout(Timestamp lastLogout) { this.lastLogout = lastLogout; }

    public String getLockReason() { return lockReason; }
    public void setLockReason(String lockReason) { this.lockReason = lockReason; }

    public Timestamp getLockedAt() { return lockedAt; }
    public void setLockedAt(Timestamp lockedAt) { this.lockedAt = lockedAt; }

    // Giữ nguyên các Getter/Setter cũ...
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getSalt() { return salt; }
    public void setSalt(String salt) { this.salt = salt; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }
}