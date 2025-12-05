<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu | E-Books</title>
    
    <!-- CSS Dependencies -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/style.css">
    <link rel="stylesheet" href="CSS/theme.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .forgot-password-container {
            min-height: 85vh; /* Tăng chiều cao để căn giữa tốt hơn */
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f6f8fd 0%, #e9ecef 100%); /* Gradient nền nhẹ */
            padding: 40px 15px;
        }
        
        .card-forgot {
            background: white;
            border-radius: 20px; /* Bo tròn nhiều hơn */
            box-shadow: 0 15px 35px rgba(51, 54, 82, 0.1); /* Shadow mềm mại hơn */
            overflow: hidden;
            border: none;
            max-width: 450px; /* Thu hẹp card lại một chút cho gọn */
            width: 100%;
            transition: transform 0.3s ease;
        }
        
        .card-forgot:hover {
            transform: translateY(-5px); /* Hiệu ứng bay lên nhẹ khi hover */
        }
        
        .card-header-custom {
            background: white; /* Đổi sang nền trắng cho sạch sẽ */
            padding: 40px 30px 10px;
            text-align: center;
            border-bottom: none;
        }
        
        .icon-wrapper {
            width: 80px;
            height: 80px;
            background: rgba(51, 54, 82, 0.05); /* Màu nền icon nhạt */
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }

        .card-header-custom i {
            font-size: 32px;
            color: var(--primary-color, #333652); /* Icon màu tối */
        }
        
        .card-header-custom h3 {
            margin: 0;
            font-weight: 700;
            color: var(--primary-color, #333652);
            font-size: 1.5rem;
        }
        
        .subtitle {
            color: #6c757d;
            font-size: 0.95rem;
            margin-top: 10px;
            line-height: 1.5;
        }
        
        .card-body-custom {
            padding: 20px 40px 40px;
        }
        
        .form-floating > .form-control {
            border-radius: 10px;
            border: 1px solid #dee2e6;
        }

        .form-floating > .form-control:focus {
            border-color: var(--primary-color, #333652);
            box-shadow: 0 0 0 0.25rem rgba(51, 54, 82, 0.15);
        }
        
        .btn-reset {
            background: var(--primary-color, #333652);
            color: white;
            padding: 14px;
            width: 100%;
            border-radius: 10px;
            font-weight: 600;
            font-size: 1rem;
            border: none;
            transition: all 0.3s;
            margin-top: 10px;
            box-shadow: 0 4px 15px rgba(51, 54, 82, 0.2);
        }
        
        .btn-reset:hover {
            background: var(--secondary-color, #90ADC6);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(51, 54, 82, 0.25);
        }
        
        .back-link {
            text-align: center;
            display: inline-flex;
            align-items: center;
            color: #666;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
            font-size: 0.9rem;
        }
        
        .back-link:hover {
            color: var(--primary-color, #333652);
        }

        .footer-links {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>
<body>

    <!-- Include Header -->
    <jsp:include page="header.jsp" />

    <div class="forgot-password-container">
        <div class="container d-flex justify-content-center">
            <div class="card card-forgot">
                <div class="card-header-custom">
                    <div class="icon-wrapper">
                        <i class="fas fa-key"></i>
                    </div>
                    <h3>Quên Mật Khẩu?</h3>
                    <p class="subtitle">Đừng lo lắng! Hãy nhập email của bạn và chúng tôi sẽ gửi mật khẩu mới.</p>
                </div>
                
                <div class="card-body card-body-custom">
                    
                    <!-- Hiển thị thông báo lỗi hoặc thành công từ Servlet -->
                    <% 
                        String message = (String) request.getAttribute("message");
                        String messageType = (String) request.getAttribute("messageType");
                        if (message != null) { 
                    %>
                        <div class="alert alert-<%= messageType %> alert-dismissible fade show d-flex align-items-center" role="alert">
                            <% if("success".equals(messageType)) { %>
                                <i class="fas fa-check-circle me-2 flex-shrink-0"></i>
                            <% } else { %>
                                <i class="fas fa-exclamation-triangle me-2 flex-shrink-0"></i>
                            <% } %>
                            <div><%= message %></div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <form action="ForgotPasswordServlet" method="POST">
                        <div class="form-floating mb-4">
                            <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
                            <label for="email"><i class="fas fa-envelope me-2 text-muted"></i>Địa chỉ Email của bạn</label>
                        </div>
                        
                        <button type="submit" class="btn btn-reset">
                            <i class="fas fa-paper-plane me-2"></i> Gửi Mật Khẩu Mới
                        </button>
                    </form>
                    
                    <div class="footer-links">
                        <a href="login.jsp" class="back-link">
                            <i class="fas fa-arrow-left me-2"></i> Đăng nhập
                        </a>
                        <a href="signup.jsp" class="text-decoration-none fw-bold" style="color: var(--primary-color);">
                            Tạo tài khoản mới
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Footer -->
    <jsp:include page="footer.jsp" />

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>