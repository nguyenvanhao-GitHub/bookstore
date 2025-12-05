package entity;

import java.sql.Timestamp;

public class Publisher {
    private int id;
    private String name;
    private String email;
    private String contact;
    private String gender;
    private String password;
    private String role;
    private Timestamp lastLogin;
    private Timestamp lastLogout;
    private String status;
    private String lockReason;
    private Timestamp lockedAt;
    private String salt;

    public Publisher() {}

    // Constructor đầy đủ
    public Publisher(int id, String name, String email, String contact, String gender, 
                     String password, String role, Timestamp lastLogin, Timestamp lastLogout, 
                     String status, String lockReason, Timestamp lockedAt, String salt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.contact = contact;
        this.gender = gender;
        this.password = password;
        this.role = role;
        this.lastLogin = lastLogin;
        this.lastLogout = lastLogout;
        this.status = status;
        this.lockReason = lockReason;
        this.lockedAt = lockedAt;
        this.salt = salt;
    }

    // Constructor đơn giản cho session
    public Publisher(String email, String name, String role) {
        this.email = email;
        this.name = name;
        this.role = role;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }
    public Timestamp getLastLogout() { return lastLogout; }
    public void setLastLogout(Timestamp lastLogout) { this.lastLogout = lastLogout; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLockReason() { return lockReason; }
    public void setLockReason(String lockReason) { this.lockReason = lockReason; }
    public Timestamp getLockedAt() { return lockedAt; }
    public void setLockedAt(Timestamp lockedAt) { this.lockedAt = lockedAt; }
    public String getSalt() { return salt; }
    public void setSalt(String salt) { this.salt = salt; }
}