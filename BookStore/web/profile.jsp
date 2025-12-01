<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    String userEmail = (String) session.getAttribute("userEmail");

    if (userName == null || !"user".equals(userRole) || userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    String alert = (String) session.getAttribute("alert");
    if (alert != null) {
%>
<script>
    window.onload = () => {
        Swal.fire({
            text: '<%= alert%>'
        });
    };
</script>
<%
        session.removeAttribute("alert");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Profile - BookStore</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
        <style>
            .profile-container {
                padding: 2rem 0;
                background-color: #f8f9fa;
            }

            .profile-header {
                background: #2c3e50;
                color: white;
                padding: 2rem 0;
                margin-bottom: 2rem;
            }

            .profile-avatar {
                width: 100px;
                height: 100px;
                border-radius: 50%;
                border: 3px solid white;
                object-fit: cover;
                margin-bottom: 1rem;
            }

            .profile-section {
                background: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                margin-bottom: 1.5rem;
            }

            .order-item {
                border: 1px solid #e9ecef;
                border-radius: 8px;
                padding: 1rem;
                margin-bottom: 1rem;
            }

            .btn-logout {
                background-color: #ff4757;
                color: white;
                border: none;
                padding: 0.8rem 1.5rem;
                border-radius: 25px;
                transition: all 0.3s ease;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 1px;
                box-shadow: 0 2px 5px rgba(255, 71, 87, 0.3);
            }

            .btn-logout:hover {
                background-color: #ff6b81;
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(255, 71, 87, 0.4);
            }
        </style>
    </head>
    <body>
        <jsp:include page="header.jsp" />

        <div class="profile-container">
            <!-- <div class="profile-header text-center">
                <img src="https://i.pravatar.cc/150?img=12" alt="Profile Picture" class="profile-avatar">
                <h2><%= userName%></h2>
                <p class="mb-0"><%= userEmail%></p>
                
            </div> -->

            <div class="container">
                <div class="row">
                    <!-- Account Info -->
                    <div class="col-md-4">
                        <div class="profile-section">
                            <center>
                                <h4>Account</h4>
                                <hr>
                                <img src="images/user.png" alt="Profile Picture" class="profile-avatar">
                                <p><strong>Name:</strong> <%= userName%></p>
                                <p><strong>Email:</strong> <%= userEmail%></p>
                                <!-- <p><strong>Role:</strong> <%= userRole%></p> -->
                                <form action="LogoutServlet" method="post" class="mt-3">
                                    <button type="submit" class="btn btn-danger w-100">
                                        <i class="fas fa-sign-out-alt"></i> Logout
                                    </button>
                                </form>
                            </center>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <jsp:include page="footer.jsp" />
    </body>
</html>
