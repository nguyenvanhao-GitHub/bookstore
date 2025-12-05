package entity;

import java.sql.Timestamp;

public class Subscriber {
    private int id;
    private String email;
    private Timestamp subscribedAt;

    public Subscriber() {
    }

    public Subscriber(int id, String email, Timestamp subscribedAt) {
        this.id = id;
        this.email = email;
        this.subscribedAt = subscribedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Timestamp getSubscribedAt() { return subscribedAt; }
    public void setSubscribedAt(Timestamp subscribedAt) { this.subscribedAt = subscribedAt; }
}