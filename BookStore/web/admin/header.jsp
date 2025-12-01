<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%
    // Check if admin is logged in and validate session attributes
    String adminName = (String) session.getAttribute("adminName");
    String adminRole = (String) session.getAttribute("userRole");
    String adminEmail = (String) session.getAttribute("adminEmail");

    if (adminName == null || adminEmail == null || !"admin".equals(adminRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<%
    // Lấy thời gian xem cuối cùng từ session
    Long lastViewedOrders = (Long) session.getAttribute("lastViewedOrders");
    Long lastViewedReviews = (Long) session.getAttribute("lastViewedReviews");
    Long lastViewedContacts = (Long) session.getAttribute("lastViewedContacts");

    // Nếu chưa có, khởi tạo với thời gian hiện tại trừ 1 ngày
    if (lastViewedOrders == null) {
        lastViewedOrders = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
        session.setAttribute("lastViewedOrders", lastViewedOrders);
    }
    if (lastViewedReviews == null) {
        lastViewedReviews = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
        session.setAttribute("lastViewedReviews", lastViewedReviews);
    }
    if (lastViewedContacts == null) {
        lastViewedContacts = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
        session.setAttribute("lastViewedContacts", lastViewedContacts);
    }

    // Đếm số thông báo mới
    int newOrdersCount = 0;
    int newReviewsCount = 0;
    int newContactsCount = 0;

    try {
        Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
                "root", ""
        );
        Statement stmt = conn.createStatement();

        // Đếm đơn hàng mới sau lần xem cuối
        PreparedStatement ps1 = conn.prepareStatement(
                "SELECT COUNT(*) FROM orders WHERE order_date > FROM_UNIXTIME(?/1000)"
        );
        ps1.setLong(1, lastViewedOrders);
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) {
            newOrdersCount = rs1.getInt(1);
        }

        // Đếm review mới sau lần xem cuối
        PreparedStatement ps2 = conn.prepareStatement(
                "SELECT COUNT(*) FROM reviews WHERE created_at > FROM_UNIXTIME(?/1000)"
        );
        ps2.setLong(1, lastViewedReviews);
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) {
            newReviewsCount = rs2.getInt(1);
        }

        // Đếm contact mới sau lần xem cuối
        try {
            PreparedStatement ps3 = conn.prepareStatement(
                    "SELECT COUNT(*) FROM contact WHERE created_at > FROM_UNIXTIME(?/1000)"
            );
            ps3.setLong(1, lastViewedContacts);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) {
                newContactsCount = rs3.getInt(1);
            }
        } catch (Exception e) {
            // Bỏ qua nếu bảng contact không có trường created_at
        }

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Lấy tên trang hiện tại
    String currentPageUri = request.getRequestURI();
    String pageName = currentPageUri.substring(currentPageUri.lastIndexOf("/") + 1);

    // Cập nhật thời gian xem khi vào trang tương ứng
    if ("orders.jsp".equals(pageName) && newOrdersCount > 0) {
        session.setAttribute("lastViewedOrders", System.currentTimeMillis());
        newOrdersCount = 0; // Reset ngay lập tức để không hiện badge
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
            /* Notification Badge Style */
            .nav-link {
                position: relative;
            }

            .notification-badge {
                position: absolute;
                top: 8px;
                right: 15px;
                background: linear-gradient(135deg, #ff6b6b, #ee5a6f);
                color: white;
                font-size: 0.65rem;
                font-weight: bold;
                padding: 2px 6px;
                border-radius: 10px;
                min-width: 18px;
                text-align: center;
                box-shadow: 0 2px 5px rgba(255, 107, 107, 0.4);
                animation: pulse 2s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                    box-shadow: 0 2px 5px rgba(255, 107, 107, 0.4);
                }
                50% {
                    transform: scale(1.1);
                    box-shadow: 0 3px 8px rgba(255, 107, 107, 0.6);
                }
            }

            /* Highlight effect cho nav link có notification */
            .nav-link.has-notification {
                background: rgba(255, 107, 107, 0.05);
            }

            .nav-link.has-notification:hover {
                background: rgba(255, 107, 107, 0.1);
            }

            /* Animation khi badge biến mất */
            @keyframes fadeOut {
                from {
                    opacity: 1;
                    transform: scale(1);
                }
                to {
                    opacity: 0;
                    transform: scale(0.5);
                }
            }

            .notification-badge.fade-out {
                animation: fadeOut 0.3s ease-out forwards;
            }
        </style>
    </head>
    <body>
        <div class="admin-sidebar">
            <div class="p-3">
                <a class="navbar-brand d-flex align-items-center mb-4" href="index.jsp">
                    <center>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <i class="fas fa-book-reader me-2 text-warning"></i>
                        <span class="brand-text fs-4 fw-bold text-white">E-Books  </span>
                    </center>
                </a>
                <nav>
                    <a href="index.jsp" class="nav-link">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                    <a href="books.jsp" class="nav-link">
                        <i class="fas fa-book"></i> Books
                    </a>
                    <a href="orders.jsp" class="nav-link <%= newOrdersCount > 0 ? "has-notification" : ""%>">
                        <i class="fas fa-shopping-cart"></i> Orders
                        <% if (newOrdersCount > 0) {%>
                        <span class="notification-badge"><%= newOrdersCount%></span>
                        <% }%>
                    </a>
                    <a href="reviews.jsp" class="nav-link <%= newReviewsCount > 0 ? "has-notification" : ""%>">
                        <i class="fas fa-star"></i> Reviews
                        <% if (newReviewsCount > 0) {%>
                        <span class="notification-badge"><%= newReviewsCount%></span>
                        <% }%>
                    </a>
                    <a href="users.jsp" class="nav-link">
                        <i class="fas fa-users"></i> Users
                    </a>
                    <a href="subscriber.jsp" class="nav-link">
                        <i class="fas fa-envelope"></i> Subscribers
                    </a>
                    <a href="contact.jsp" class="nav-link <%= newContactsCount > 0 ? "has-notification" : ""%>">
                        <i class="fas fa-message"></i> Contact
                        <% if (newContactsCount > 0) {%>
                        <span class="notification-badge"><%= newContactsCount%></span>
                        <% }%>
                    </a>
                    <a href="admin-profile.jsp" class="nav-link">
                        <i class="fas fa-user"></i> Profile
                    </a>
                </nav>
                <div class="mt-auto p-3">
                    <form action="../AdminLogoutServlet" method="post">
                        <button type="submit" class="btn btn-danger w-100">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>