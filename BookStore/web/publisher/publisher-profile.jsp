<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PublisherDAO, dao.BookDAO, entity.Publisher" %>
<%@ include file="header.jsp" %>

<%
    // Cache control (Giữ nguyên)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Lấy thông tin Publisher mới nhất từ DB
    String pubEmail = (String) session.getAttribute("publisherEmail");
    if (pubEmail == null) { response.sendRedirect("login.jsp"); return; }

    PublisherDAO pubDAO = new PublisherDAO();
    Publisher pub = pubDAO.getPublisherByEmail(pubEmail);
    
    // Lấy thống kê
    BookDAO bookDAO = new BookDAO();
    int totalBooks = bookDAO.countBooksByPublisher(pubEmail);

    // --- BỔ SUNG LOGIC FLASH MESSAGE ---
    String alertIcon = (String) session.getAttribute("alertIcon");
    String alertTitle = (String) session.getAttribute("alertTitle");
    String alertMessage = (String) session.getAttribute("alertMessage");

    // XÓA các thuộc tính Session ngay lập tức
    if (alertIcon != null) {
        session.removeAttribute("alertIcon");
        session.removeAttribute("alertTitle");
        session.removeAttribute("alertMessage");
    }
    // --- END LOGIC FLASH MESSAGE ---
%>

<div class="publisher-content">
    <div class="container-fluid">
        <div class="profile-section">
            <div class="profile-header text-center py-4 bg-white shadow-sm rounded mb-4">
                <img src="../images/publisher.png" alt="Profile Image" class="profile-image rounded-circle mb-3" style="width: 100px; height: 100px;">
                <div class="profile-info">
                    <h2 class="fw-bold"><%= pub.getName() %></h2>
                    <p class="text-muted"><i class="fas fa-envelope me-2"></i> <%= pub.getEmail() %></p>
                    
                    <div class="d-flex justify-content-center gap-4 mt-3">
                        <div class="text-center p-3 border rounded bg-light" style="min-width: 120px;">
                            <h4 class="mb-0 fw-bold text-primary"><%= totalBooks %></h4>
                            <small class="text-muted">Published Books</small>
                        </div>
                        <div class="text-center p-3 border rounded bg-light" style="min-width: 120px;">
                            <h4 class="mb-0 fw-bold text-success">Active</h4>
                            <small class="text-muted">Status</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="card h-100 shadow-sm border-0">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="fas fa-user-edit me-2"></i> Account Info</h5>
                        </div>
                        <div class="card-body">
                            <form action="../UpdatePublisherProfileServlet" method="post">
                                <input type="hidden" name="action" value="updateInfo">
                                <div class="mb-3">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" class="form-control" name="name" value="<%= pub.getName() %>" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" value="<%= pub.getEmail() %>" readonly disabled>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Contact Number</label>
                                    <input type="text" class="form-control" name="contact" value="<%= pub.getContact() != null ? pub.getContact() : "" %>">
                                </div>
                                <button type="submit" class="btn btn-primary w-100">Save Changes</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <div class="card h-100 shadow-sm border-0">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="fas fa-key me-2"></i> Change Password</h5>
                        </div>
                        <div class="card-body">
                            <form action="../UpdatePublisherProfileServlet" method="post">
                                <input type="hidden" name="action" value="changePassword">
                                <div class="mb-3">
                                    <label class="form-label">Current Password</label>
                                    <div class="input-group">
                                        <input type="password" class="form-control" name="currentPassword" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">New Password</label>
                                    <input type="password" class="form-control" name="newPassword" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Confirm New Password</label>
                                    <input type="password" class="form-control" name="confirmPassword" required>
                                </div>
                                <button type="submit" class="btn btn-warning text-dark w-100">Update Password</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    <% 
        // Hiển thị thông báo (chỉ một lần)
        if (alertIcon != null) {
            String msg = (String) session.getAttribute("alertMessage"); // Lấy lại msg (mặc dù đã lấy ở trên)
    %>
        Swal.fire({
            icon: '<%= alertIcon %>',
            title: '<%= alertTitle %>',
            text: '<%= alertMessage != null ? alertMessage : "" %>',
            timer: 2000,
            showConfirmButton: false
        });
    <% } %>
</script>
</body>
</html>