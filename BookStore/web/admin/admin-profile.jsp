<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="entity.Admin" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%
    String userEmail = (String) session.getAttribute("adminEmail");
    
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
    
    // [SỬA LỖI] Thay thế logic DB cũ bằng cách gọi DAO
    AdminDAO dao = new AdminDAO();
    Admin admin = dao.getAdminByEmail(userEmail);
    
    // Kiểm tra và lấy dữ liệu
    String userName = admin != null ? admin.getName() : (String) session.getAttribute("adminName");
    String contact = admin != null ? admin.getContact() : "";
    String status = admin != null ? admin.getStatus() : "N/A";
    Timestamp lastLogin = admin != null ? admin.getLastLogin() : null;
    Timestamp lastLogout = admin != null ? admin.getLastLogout() : null;

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<script>document.querySelector('a[href="admin-profile.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <h2 class="mb-4">Admin Profile</h2>
    <div class="row">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-center p-4">
                <div class="mb-3">
                    <img src="../images/admin.png" alt="Admin" class="rounded-circle img-thumbnail" style="width: 120px;">
                </div>
                <h4 class="mb-1"><%= userName %></h4>
                <p class="text-muted"><%= userEmail %></p>
                <span class="badge bg-success mb-3"><%= status != null ? status : "Active" %></span>
                <p><i class="fas fa-phone me-2"></i> <%= contact != null ? contact : "N/A" %></p>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0"><i class="fas fa-clock me-2 text-warning"></i> Activity Log</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div class="p-3 border rounded bg-light">
                                <small class="text-muted d-block">Last Login</small>
                                <h6 class="mb-0 text-primary">
                                    <i class="fas fa-sign-in-alt me-2"></i>
                                    <%= lastLogin != null ? sdf.format(lastLogin) : "Never" %>
                                </h6>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="p-3 border rounded bg-light">
                                <small class="text-muted d-block">Last Logout</small>
                                <h6 class="mb-0 text-danger">
                                    <i class="fas fa-sign-out-alt me-2"></i>
                                    <%= lastLogout != null ? sdf.format(lastLogout) : "Never" %>
                                </h6>
                            </div>
                        </div>
                    </div>
                    
                    <h5 class="mb-3">Update Information</h5>
                    <form action="../UpdateAdminProfileServlet" method="post">
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-control" value="<%= userName %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Contact Number</label>
                            <input type="text" name="contact" class="form-control" value="<%= contact %>">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" value="<%= userEmail %>" required>
                        </div>
                        <button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i> Save Changes</button>
                    </form>

                    <h5 class="mt-4 mb-3 text-danger"><i class="fas fa-key me-2"></i>Change Password</h5>
                    <form action="../UpdateAdminProfileServlet" method="post">
                        <div class="mb-3">
                            <label class="form-label">Current Password</label>
                            <input type="password" name="currentPassword" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">New Password</label>
                            <input type="password" name="newPassword" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-danger"><i class="fas fa-lock me-1"></i> Change Password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    <% 
        // Hiển thị thông báo (chỉ một lần)
        if (alertIcon != null) {
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