<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserDAO, entity.User" %>
<%@ page import="utils.LanguageHelper" %> 

<%
    // Lấy thông tin người dùng từ DB (Logic này giữ nguyên)
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) { response.sendRedirect("login.jsp"); return; }

    UserDAO dao = new UserDAO();
    User user = dao.getUserByEmail(userEmail);
    if (user == null) { session.invalidate(); response.sendRedirect("login.jsp"); return; }
    
    // =========================================================
    // LOGIC FLASH MESSAGE: Đọc và XÓA thông báo khỏi Session
    // 1. LƯU: Lấy thông báo từ Session
    String alertIcon = (String) session.getAttribute("alertIcon");
    String alertTitle = (String) session.getAttribute("alertTitle");
    String alertMessage = (String) session.getAttribute("alertMessage");

    // 2. XÓA: Xóa các thuộc tính Session ngay lập tức sau khi lấy
    if (alertIcon != null) {
        session.removeAttribute("alertIcon");
        session.removeAttribute("alertTitle");
        session.removeAttribute("alertMessage");
    }
    // =========================================================
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><%= LanguageHelper.getText(request, "settings.account.title") %> - E-Books</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="CSS/style.css">
    
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        .settings-container { max-width: 800px; margin: 40px auto; padding: 20px; background: #fff; border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.05); }
        .form-section { margin-bottom: 30px; }
        .section-title { font-weight: 600; color: #333; margin-bottom: 20px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="container">
        <div class="settings-container">
            <h2 class="text-center mb-4"><i class="fas fa-cog text-primary"></i> <%= LanguageHelper.getText(request, "settings.account.title") %></h2>

            <form action="UpdateSettingsServlet" method="post">
                
                <div class="form-section">
                    <h5 class="section-title"><i class="fas fa-user-circle me-2"></i><%= LanguageHelper.getText(request, "settings.personal.info") %></h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold"><%= LanguageHelper.getText(request, "user.fullname") %></label>
                            <input type="text" name="name" class="form-control" 
value="<%= user.getName() %>" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Email</label>
                            <input type="text" class="form-control bg-light" value="<%= user.getEmail() %>" readonly disabled>
                            <small class="text-muted">Email <%= LanguageHelper.getText(request, "btn.edit") %> không thể thay đổi.</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold"><%= LanguageHelper.getText(request, "user.phone.number") %></label>
                            <input type="text" name="phone" class="form-control" value="<%= user.getContact() != null ? user.getContact() : "" %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold"><%= LanguageHelper.getText(request, "user.gender") %></label>
                            <select name="gender" class="form-select">
                                <option value="Male" <%= "Male".equals(user.getGender()) ? "selected" : "" %>>Nam</option>
                                <option value="Female" <%= "Female".equals(user.getGender()) ? "selected" : "" %>>Nữ</option>
                                <option value="Other" <%= "Other".equals(user.getGender()) ? "selected" : "" %>>Khác</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h5 class="section-title"><i class="fas fa-lock me-2"></i><%= LanguageHelper.getText(request, "settings.security") %></h5>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label"><%= LanguageHelper.getText(request, "settings.current.password") %></label>
                            <input type="password" name="currentPassword" class="form-control" placeholder="••••••">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label"><%= LanguageHelper.getText(request, "settings.new.password") %></label>
                            <input type="password" name="newPassword" class="form-control" placeholder="<%= LanguageHelper.getText(request, "settings.new.password") %>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label"><%= LanguageHelper.getText(request, "settings.confirm.new.password") %></label>
                            <input type="password" name="confirmPassword" class="form-control" placeholder="<%= LanguageHelper.getText(request, "settings.confirm.new.password") %>">
                        </div>
                        <div class="col-12">
                            <small class="text-muted fst-italic"><%= LanguageHelper.getText(request, "settings.password.hint") %></small>
                        </div>
                    </div>
                </div>

                <div class="text-end mt-4">
                    <button type="submit" class="btn btn-primary px-4"><i class="fas fa-save me-2"></i><%= LanguageHelper.getText(request, "btn.save.changes") %></button>
                </div>
            </form>

            <hr class="my-5">

            <div class="bg-light p-4 rounded border border-danger border-opacity-25">
                <h5 class="text-danger mb-3"><i class="fas fa-exclamation-triangle me-2"></i><%= LanguageHelper.getText(request, "settings.danger.zone") %></h5>
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <p class="mb-0 fw-bold"><%= LanguageHelper.getText(request, "settings.delete.account") %></p>
                        <small class="text-muted"><%= LanguageHelper.getText(request, "settings.delete.warning") %></small>
                    </div>
                    <form action="DeleteAccountServlet" method="post">
                        <button type="button" class="btn btn-outline-danger" onclick="confirmDelete(this.form)">
                            <%= LanguageHelper.getText(request, "btn.delete") %> <%= LanguageHelper.getText(request, "menu.account") %>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(form) {
            Swal.fire({
                title: 'Bạn có chắc chắn?',
                text: "Tài khoản sẽ bị xóa vĩnh viễn và không thể khôi phục!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Xóa ngay',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    form.submit();
                }
            });
        }
    </script>
</body>
</html>