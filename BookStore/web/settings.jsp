<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài đặt tài khoản - E-Books</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f9f9f9; font-family: 'Open Sans', sans-serif; }
        .settings-container {
            max-width: 900px;
            margin: 80px auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            padding: 30px;
        }
        .settings-title {
            font-weight: 700;
            font-size: 1.5rem;
            color: #ee4d2d;
            margin-bottom: 25px;
        }
        .form-label { font-weight: 600; }
        .btn-save {
            background: linear-gradient(135deg, #ee4d2d 0%, #ff6d4d 100%);
            color: white;
            font-weight: 600;
        }
        .btn-save:hover {
            opacity: 0.9;
        }
        body.dark-mode {
    background-color: #121212 !important;
    color: #e0e0e0 !important;
  }

  .settings-container.dark-mode {
    background-color: #1e1e1e;
    color: #ddd;
    box-shadow: 0 4px 20px rgba(255,255,255,0.05);
  }

  .form-control.dark-mode {
    background-color: #2c2c2c;
    color: #fff;
    border-color: #444;
  }

  .btn-save.dark-mode {
    background: linear-gradient(135deg, #444 0%, #666 100%);
    color: #fff;
  }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" /> <!-- Gọi header hiện tại -->

    <div class="settings-container">
        <h2 class="settings-title">Cài đặt tài khoản</h2>

        <!-- Thông tin cá nhân -->
        <form action="UpdateSettingsServlet" method="post">
            <h5 class="mb-3">👤 Thông tin cá nhân</h5>
            <div class="mb-3">
                <label class="form-label">Họ và tên</label>
                <input type="text" name="name" class="form-control" value="<%= userName %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Email đăng nhập</label>
                <input type="email" class="form-control" value="<%= userEmail %>" readonly>
            </div>

            <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <input type="text" name="phone" class="form-control" placeholder="Nhập số điện thoại">
            </div>

            <div class="mb-3">
                <label class="form-label">Địa chỉ</label>
                <input type="text" name="address" class="form-control" placeholder="Nhập địa chỉ nhận sách">
            </div>

            <hr>

            <!-- Đổi mật khẩu -->
            <h5 class="mb-3">🔒 Bảo mật</h5>
            <div class="mb-3">
                <label class="form-label">Mật khẩu hiện tại</label>
                <input type="password" name="currentPassword" class="form-control">
            </div>
            <div class="mb-3">
                <label class="form-label">Mật khẩu mới</label>
                <input type="password" name="newPassword" class="form-control">
            </div>

            <hr>

            <!-- Tùy chọn hiển thị -->
            <h5 class="mb-3">🎨 Giao diện & thông báo</h5>
            <div class="form-check form-switch mb-2">
                <input class="form-check-input" type="checkbox" id="darkMode" name="darkMode">
                <label class="form-check-label" for="darkMode">Bật chế độ tối (Dark Mode)</label>
            </div>
            <div class="form-check form-switch mb-4">
                <input class="form-check-input" type="checkbox" id="emailNotify" name="emailNotify" checked>
                <label class="form-check-label" for="emailNotify">Nhận thông báo qua email</label>
            </div>

            <button type="submit" class="btn btn-save">Lưu thay đổi</button>
        </form>

        <hr class="my-4">

        <!-- Xóa tài khoản -->
        <div>
            <h5 class="text-danger mb-3">⚠️ Xóa tài khoản</h5>
            <p class="text-muted">Hành động này không thể hoàn tác. Toàn bộ dữ liệu sẽ bị xóa vĩnh viễn.</p>
            <form action="DeleteAccountServlet" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tài khoản không?');">
                <button class="btn btn-danger">Xóa tài khoản</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<script>
  const toggle = document.getElementById('darkMode');
  const body = document.body;
  const container = document.querySelector('.settings-container');
  const inputs = document.querySelectorAll('.form-control');
  const btnSave = document.querySelector('.btn-save');

  // Kiểm tra xem người dùng đã bật dark mode từ trước chưa
  if (localStorage.getItem('darkMode') === 'true') {
    toggle.checked = true;
    enableDarkMode();
  }

  // Khi người dùng thay đổi switch
  toggle.addEventListener('change', () => {
    if (toggle.checked) {
      enableDarkMode();
      localStorage.setItem('darkMode', 'true');
    } else {
      disableDarkMode();
      localStorage.setItem('darkMode', 'false');
    }
  });

  function enableDarkMode() {
    body.classList.add('dark-mode');
    container.classList.add('dark-mode');
    btnSave.classList.add('dark-mode');
    inputs.forEach(i => i.classList.add('dark-mode'));
  }

  function disableDarkMode() {
    body.classList.remove('dark-mode');
    container.classList.remove('dark-mode');
    btnSave.classList.remove('dark-mode');
    inputs.forEach(i => i.classList.remove('dark-mode'));
  }
</script>
