<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    List<Map<String, Object>> notifications = new ArrayList<>();

    if (userEmail != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
            String sql = "SELECT id, message, is_read, created_at FROM notifications WHERE user_email = ? ORDER BY created_at DESC";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, userEmail);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> notif = new HashMap<>();
                notif.put("id", rs.getInt("id"));
                notif.put("message", rs.getString("message"));
                notif.put("is_read", rs.getBoolean("is_read"));
                notif.put("created_at", rs.getTimestamp("created_at"));
                notifications.add(notif);
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Thông Báo Của Tôi</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="CSS/style.css">
    <style>
        .notification-page { max-width: 600px; margin: 80px auto; }
        .notification-item { padding: 15px; border-bottom: 1px solid #f0f0f0; display: flex; gap: 10px; }
        .notification-item.read { background: #f5f5f5; color: #888; }
        .notification-item i { color: #ee4d2d; }
        .notification-date { font-size: 0.75rem; color: #aaa; margin-left: auto; }
    </style>
</head>
<body>
    <div class="notification-page">
        <h2>Thông Báo Của Tôi</h2>
        <%
            if (notifications.isEmpty()) {
        %>
            <p>Không có thông báo nào.</p>
        <%
            } else {
                for (Map<String, Object> notif : notifications) {
                    boolean isRead = (Boolean) notif.get("is_read");
        %>
            <div class="notification-item <%= isRead ? "read" : "" %>">
                <i class="fas fa-info-circle"></i>
                <span><%= notif.get("message") %></span>
                <span class="notification-date"><%= notif.get("created_at") %></span>
            </div>
        <%
                }
            }
        %>
    </div>
</body>
</html>
