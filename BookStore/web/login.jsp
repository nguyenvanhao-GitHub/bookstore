<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - E-Books Digital Library</title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" sizes="32x32"
          href="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/svgs/solid/book-reader.svg">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="CSS/style.css">
    <link rel="stylesheet" href="CSS/login.css">

    <style>
        .home-button {
            position: fixed;
            top: 20px;
            left: 20px;
            font-size: 24px;
            color: #333;
            text-decoration: none;
            transition: color 0.3s ease;
            z-index: 1000;
        }

        .home-button:hover {
            color: #007bff;
        }

        .password-toggle {
            position: absolute;
            right: 10px;
            top: 12px;
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            z-index: 10;
        }

        .password-toggle:hover {
            color: #000;
        }

        .remember-me-container {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .remember-me-container input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #007bff;
        }

        .remember-me-container label {
            cursor: pointer;
            margin: 0;
            user-select: none;
            font-size: 14px;
        }

        .info-tooltip {
            display: inline-block;
            margin-left: 5px;
            color: #6c757d;
            cursor: help;
            font-size: 12px;
        }

        .info-tooltip:hover {
            color: #007bff;
        }

        .alert {
            border-radius: 8px;
            border: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .alert-danger {
            background-color: #fee;
            color: #c33;
        }

        .alert-success {
            background-color: #efe;
            color: #3a3;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 12px;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:disabled {
            transform: none;
            opacity: 0.7;
        }
    </style>
</head>
<body class="login-page">
<a href="index.jsp" class="home-button" title="Back to Home">
    <i class="fas fa-arrow-left"></i>
</a>

<div class="login-container">
    <div class="login-form-container">
        <div class="login-form">
            <div class="text-center mb-4">
                <a href="index.jsp" class="login-logo text-decoration-none">
                    <i class="fas fa-book-reader me-2"></i>
                    <span>E-Books</span>
                </a>
            </div>

            <h1>Sign In</h1>
            <p class="text-muted mb-4">Please login to your account</p>

            <!-- Form -->
            <form id="loginForm" method="POST" action="LoginServlet">
                <!-- Error Alert -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <!-- Success Alert -->
                <% if (session.getAttribute("message") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>
                        <%= session.getAttribute("message") %>
                        <% session.removeAttribute("message"); %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <!-- Email Input -->
                <div class="form-floating mb-3">
                    <input type="email" 
                           class="form-control" 
                           id="emailInput" 
                           name="email"
                           placeholder="name@example.com" 
                           required
                           autocomplete="email">
                    <label for="emailInput">Email address</label>
                </div>

                <!-- Password Input -->
                <div class="form-floating mb-3 position-relative">
                    <input type="password" 
                           class="form-control" 
                           id="passwordInput" 
                           name="password"
                           placeholder="Password" 
                           required
                           autocomplete="current-password">
                    <label for="passwordInput">Password</label>
                    <button type="button" 
                            class="password-toggle" 
                            onclick="togglePassword()" 
                            title="Show/Hide Password">
                        <i class="far fa-eye" id="toggleIcon"></i>
                    </button>
                </div>

                <!-- Role Selection -->
                <div class="form-floating mb-3">
                    <select class="form-select" 
                            id="roleSelect" 
                            name="role" 
                            onchange="updateFormAction()" 
                            required>
                        <option value="" selected disabled>Select Role</option>
                        <option value="user">User</option>
                        <option value="publisher">Publisher</option>
                        <option value="admin">Admin</option>
                    </select>
                    <label for="roleSelect">User Role</label>
                </div>

                <!-- Remember Me & Forgot Password -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="remember-me-container">
                        <input type="checkbox" 
                               id="rememberMe" 
                               name="rememberMe"
                               title="Stay logged in for 30 days">
                        <label for="rememberMe">
                            Remember Me
                            <span class="info-tooltip" 
                                  data-bs-toggle="tooltip" 
                                  data-bs-placement="top"
                                  title="You won't need to login again for 30 days">
                                <i class="fas fa-info-circle"></i>
                            </span>
                        </label>
                    </div>
                    <a href="forgot-password.jsp" class="forgot-password">Forgot Password?</a>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn btn-primary w-100 mb-3" id="submitBtn">
                    <i class="fas fa-sign-in-alt me-2"></i>Sign In
                </button>

                <!-- Sign Up Link -->
                <p class="text-center mt-4">
                    Don't have an account?
                    <a href="signup.jsp" class="signup-link">Sign up</a>
                </p>
            </form>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    // ============================================
    // PASSWORD TOGGLE
    // ============================================
    function togglePassword() {
        const passwordInput = document.getElementById('passwordInput');
        const icon = document.getElementById('toggleIcon');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            passwordInput.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    // ============================================
    // UPDATE FORM ACTION BASED ON ROLE
    // ============================================
    function updateFormAction() {
        const form = document.getElementById('loginForm');
        const role = document.getElementById('roleSelect').value;

        switch (role) {
            case 'admin':
                form.action = 'AdminLoginServlet';
                break;
            case 'publisher':
                form.action = 'PublisherLoginServlet';
                break;
            default:
                form.action = 'LoginServlet';
                break;
        }
    }

    // ============================================
    // COOKIE HELPER FUNCTIONS
    // ============================================
    function setCookie(name, value, days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        const expires = "expires=" + date.toUTCString();
        document.cookie = name + "=" + encodeURIComponent(value) + ";" + expires + ";path=/;SameSite=Lax";
    }

    function getCookie(name) {
        const nameEQ = name + "=";
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            let cookie = cookies[i].trim();
            if (cookie.indexOf(nameEQ) === 0) {
                return decodeURIComponent(cookie.substring(nameEQ.length));
            }
        }
        return null;
    }

    function deleteCookie(name) {
        document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;";
    }

    // ============================================
    // LOAD SAVED CREDENTIALS ON PAGE LOAD
    // ============================================
    window.addEventListener('DOMContentLoaded', function() {
        const savedEmail = getCookie('rememberedEmail');
        const savedRole = getCookie('rememberedRole');
        
        if (savedEmail) {
            document.getElementById('emailInput').value = savedEmail;
            document.getElementById('rememberMe').checked = true;
            // Focus on password field if email is already filled
            document.getElementById('passwordInput').focus();
        }
        
        if (savedRole) {
            document.getElementById('roleSelect').value = savedRole;
            updateFormAction();
        }

        // Initialize Bootstrap tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

        // Auto-dismiss alerts after 5 seconds
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            setTimeout(() => {
                const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
                bsAlert.close();
            }, 5000);
        });
    });

    // ============================================
    // SAVE/CLEAR COOKIES ON FORM SUBMIT
    // ============================================
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        const rememberMe = document.getElementById('rememberMe').checked;
        const email = document.getElementById('emailInput').value;
        const role = document.getElementById('roleSelect').value;

        if (rememberMe) {
            // Save email and role for auto-fill next time
            setCookie('rememberedEmail', email, 30);
            setCookie('rememberedRole', role, 30);
        } else {
            // Clear saved cookies
            deleteCookie('rememberedEmail');
            deleteCookie('rememberedRole');
        }

        // Show loading state
        const submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Signing in...';
    });

    // ============================================
    // EMAIL VALIDATION
    // ============================================
    document.getElementById('emailInput').addEventListener('blur', function() {
        const email = this.value;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        
        if (email && !emailRegex.test(email)) {
            this.classList.add('is-invalid');
            if (!this.nextElementSibling || !this.nextElementSibling.classList.contains('invalid-feedback')) {
                const feedback = document.createElement('div');
                feedback.className = 'invalid-feedback';
                feedback.textContent = 'Please enter a valid email address';
                this.parentNode.appendChild(feedback);
            }
        } else {
            this.classList.remove('is-invalid');
            const feedback = this.parentNode.querySelector('.invalid-feedback');
            if (feedback) feedback.remove();
        }
    });

    // ============================================
    // ENTER KEY TO SUBMIT
    // ============================================
    document.getElementById('passwordInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            document.getElementById('loginForm').requestSubmit();
        }
    });

    // ============================================
    // PREVENT DOUBLE SUBMIT
    // ============================================
    let isSubmitting = false;
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        if (isSubmitting) {
            e.preventDefault();
            return false;
        }
        isSubmitting = true;
        
    });
</script>

</body>
</html>