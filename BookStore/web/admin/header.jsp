<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.AdminDAO" %>
<%@ page import="java.util.Map" %>

<%
    // 1. Kiểm tra đăng nhập
    String adminName = (String) session.getAttribute("adminName");
    String adminRole = (String) session.getAttribute("userRole");
    String adminEmail = (String) session.getAttribute("adminEmail");

    if (adminName == null || adminEmail == null || !"admin".equals(adminRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Cache Control
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 3. Xử lý Logic Thông báo (Sử dụng DAO)
    // Lấy timestamp lần cuối xem từ session (mặc định là 1 ngày trước)
    long oneDayAgo = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
    
    Long lastViewedOrders = (Long) session.getAttribute("lastViewedOrders");
    Long lastViewedReviews = (Long) session.getAttribute("lastViewedReviews");
    Long lastViewedContacts = (Long) session.getAttribute("lastViewedContacts");
    
    if (lastViewedOrders == null) { lastViewedOrders = oneDayAgo; session.setAttribute("lastViewedOrders", lastViewedOrders); }
    if (lastViewedReviews == null) { lastViewedReviews = oneDayAgo; session.setAttribute("lastViewedReviews", lastViewedReviews); }
    if (lastViewedContacts == null) { lastViewedContacts = oneDayAgo; session.setAttribute("lastViewedContacts", lastViewedContacts); }

    // Gọi DAO để lấy số lượng thông báo
    AdminDAO adminDAO = new AdminDAO();
    Map<String, Integer> counts = adminDAO.getNotificationCounts(lastViewedOrders, lastViewedReviews, lastViewedContacts);
    
    int newOrdersCount = counts.getOrDefault("newOrders", 0);
    int newReviewsCount = counts.getOrDefault("newReviews", 0);
    int newContactsCount = counts.getOrDefault("newContacts", 0);

    // 4. Reset badge khi vào trang tương ứng
    String currentPageUri = request.getRequestURI();
    String pageName = currentPageUri.substring(currentPageUri.lastIndexOf("/") + 1);

    if ("orders.jsp".equals(pageName) && newOrdersCount > 0) {
        session.setAttribute("lastViewedOrders", System.currentTimeMillis());
        newOrdersCount = 0;
    } else if ("reviews.jsp".equals(pageName) && newReviewsCount > 0) {
        session.setAttribute("lastViewedReviews", System.currentTimeMillis());
        newReviewsCount = 0;
    } else if ("contact.jsp".equals(pageName) && newContactsCount > 0) {
        session.setAttribute("lastViewedContacts", System.currentTimeMillis());
        newContactsCount = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/admin-dashboard.css" rel="stylesheet">
    <link href="css/admin-style.css" rel="stylesheet">
    <link rel="stylesheet" href="../CSS/responsive.min.css">
    
    <style>
        .notification-badge {
            position: absolute; top: 8px; right: 15px;
            background: #ff4757; color: white;
            font-size: 0.65rem; font-weight: bold;
            padding: 2px 6px; border-radius: 10px;
            min-width: 18px; text-align: center;
            animation: pulse 2s infinite;
        }
        @keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.1); } 100% { transform: scale(1); } }
        .nav-link { position: relative; }
    </style>
</head>
<body>
    <div class="admin-sidebar">
        <div class="p-3">
            <a class="navbar-brand d-flex align-items-center mb-4" href="index.jsp">
                <i class="fas fa-book-reader me-2 text-warning"></i>
                <span class="fs-4 fw-bold text-white">E-Books Admin</span>
            </a>
            <nav>
                <a href="index.jsp" class="nav-link"><i class="fas fa-home"></i> Dashboard</a>
                <a href="books.jsp" class="nav-link"><i class="fas fa-book"></i> Books</a>
                <a href="orders.jsp" class="nav-link">
                    <i class="fas fa-shopping-cart"></i> Orders
                    <% if (newOrdersCount > 0) { %><span class="notification-badge"><%= newOrdersCount %></span><% } %>
                </a>
                <a href="reviews.jsp" class="nav-link">
                    <i class="fas fa-star"></i> Reviews
                    <% if (newReviewsCount > 0) { %><span class="notification-badge"><%= newReviewsCount %></span><% } %>
                </a>
                <a href="users.jsp" class="nav-link"><i class="fas fa-users"></i> Users</a>
                <a href="subscriber.jsp" class="nav-link"><i class="fas fa-envelope"></i> Subscribers</a>
                <a href="contact.jsp" class="nav-link">
                    <i class="fas fa-comment-dots"></i> Contact
                    <% if (newContactsCount > 0) { %><span class="notification-badge"><%= newContactsCount %></span><% } %>
                </a>
                <a href="admin-profile.jsp" class="nav-link"><i class="fas fa-user-shield"></i> Profile</a>
            </nav>
            <div class="mt-auto p-3">
                <form action="../AdminLogoutServlet" method="post">
                    <button type="submit" class="btn btn-danger w-100"><i class="fas fa-sign-out-alt"></i> Logout</button>
                </form>
            </div>
        </div>
    </div>