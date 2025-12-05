<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="utils.LanguageHelper" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%@ page import="dao.BookDAO" %>
<%@ page import="entity.User" %>

<%
    // Cache control
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);

    // Check login
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userEmail == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageHelper.getText(request, "user.profile") %> - <%= LanguageHelper.getText(request, "brand.name") %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .profile-section { background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .profile-avatar { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; border: 4px solid #f0f2f5; margin-bottom: 15px; }
        body { background-color: #f8f9fa; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="profile-section text-center">
                    <img src="images/user.png" alt="Avatar" class="profile-avatar" onerror="this.src='https://ui-avatars.com/api/?name=<%= userName %>&background=random'">
                    <h3 class="mb-1"><%= userName %></h3>
                    <p class="text-muted mb-4"><%= userEmail %></p>
                    
                    <div class="d-grid gap-2">
                        <a href="my-orders.jsp" class="btn btn-outline-primary">
                            <i class="fas fa-box me-2"></i> <%= LanguageHelper.getText(request, "user.orders") %>
                        </a>
                        <a href="wishlist.jsp" class="btn btn-outline-danger">
                            <i class="fas fa-heart me-2"></i> <%= LanguageHelper.getText(request, "user.wishlist") %>
                        </a>
                        <a href="settings.jsp" class="btn btn-outline-secondary">
                            <i class="fas fa-cog me-2"></i> <%= LanguageHelper.getText(request, "user.settings") %>
                        </a>
                        <form action="LogoutServlet" method="post" class="mt-3">
                            <button type="submit" class="btn btn-danger w-100">
                                <i class="fas fa-sign-out-alt me-2"></i> <%= LanguageHelper.getText(request, "user.logout") %>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>