import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.sql.*;
import java.util.Base64;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import utils.RememberMeUtil;

/**
 * LoginServlet với chức năng Remember Me
 * File: LoginServlet.java
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    // Hàm mã hóa mật khẩu
    private String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(salt.getBytes());
        byte[] hashed = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hashed);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 🔄 Kiểm tra Remember Me token khi người dùng vào trang
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberMeToken".equals(cookie.getName())) {
                    String token = cookie.getValue();
                    
                    // Xác thực token
                    String[] userInfo = RememberMeUtil.validateToken(token);
                    if (userInfo != null) {
                        // Token hợp lệ, tự động đăng nhập
                        HttpSession session = request.getSession();
                        session.setAttribute("userId", Integer.parseInt(userInfo[0]));
                        session.setAttribute("userName", userInfo[1]);
                        session.setAttribute("userEmail", userInfo[2]);
                        session.setAttribute("userRole", "user");
                        
                        // Cập nhật cookie với token mới
                        Cookie newCookie = new Cookie("rememberMeToken", userInfo[3]);
                        newCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
                        newCookie.setPath("/");
                        newCookie.setHttpOnly(true);
                        response.addCookie(newCookie);
                        
                        // Redirect về trang profile
                        response.sendRedirect("profile.jsp");
                        return;
                    } else {
                        // Token không hợp lệ, xóa cookie
                        cookie.setMaxAge(0);
                        cookie.setPath("/");
                        response.addCookie(cookie);
                    }
                }
            }
        }
        
        // Nếu không có token hoặc token không hợp lệ, hiển thị trang login
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe"); //Nhận giá trị Remember Me

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ Email và Mật khẩu!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

                // Lấy thông tin user
                String sql = "SELECT id, name, password, salt, status, lock_reason, locked_at, last_login FROM user WHERE email = ?";
                try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                    stmt.setString(1, email);
                    ResultSet rs = stmt.executeQuery();

                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        String name = rs.getString("name");
                        String storedPassword = rs.getString("password");
                        String salt = rs.getString("salt");
                        String status = rs.getString("status");
                        String lockReason = rs.getString("lock_reason");
                        Timestamp lockedAt = rs.getTimestamp("locked_at");
                        Timestamp lastLogin = rs.getTimestamp("last_login");

                        // 1️⃣ KIỂM TRA TÀI KHOẢN BỊ KHÓA
                        if ("Locked".equalsIgnoreCase(status)) {
                            String lockMsg = "Tài khoản của bạn đã bị khóa!";
                            if (lockReason != null && !lockReason.isEmpty()) {
                                lockMsg += "<br><strong>Lý do:</strong> " + lockReason;
                            }
                            if (lockedAt != null) {
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                                lockMsg += "<br><strong>Thời gian khóa:</strong> " + sdf.format(lockedAt);
                            }
                            lockMsg += "<br><br>Vui lòng liên hệ quản trị viên để được hỗ trợ.";
                            showAlert(response, "error", "❌ Tài khoản bị khóa", lockMsg, "login.jsp", true);
                            return;
                        }

                        // 2️⃣ KIỂM TRA KHÔNG HOẠT ĐỘNG TRÊN 90 NGÀY
                        if (lastLogin != null) {
                            long diffMillis = System.currentTimeMillis() - lastLogin.getTime();
                            long diffDays = diffMillis / (1000 * 60 * 60 * 24);
                            if (diffDays > 90) {
                                String inactiveMsg = "Tài khoản của bạn đã quá 90 ngày không hoạt động (" + diffDays + " ngày)!";
                                inactiveMsg += "<br><br>Vui lòng liên hệ quản trị viên để kích hoạt lại tài khoản.";
                                showAlert(response, "warning", "⚠️ Tài khoản tạm khóa", inactiveMsg, "login.jsp", true);
                                return;
                            }
                        }

                        // 3️⃣ HASH MẬT KHẨU VÀ KIỂM TRA
                        String hashedInput = hashPassword(password, salt);

                        if (storedPassword.equals(hashedInput)) {
                            // Đăng nhập thành công → Lưu session
                            HttpSession session = request.getSession();
                            session.setAttribute("userId", userId);
                            session.setAttribute("userName", name);
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userRole", "user");

                            // Cập nhật last_login + status
                            String update = "UPDATE user SET last_login = NOW(), status = 'Active' WHERE email = ?";
                            try (PreparedStatement up = connection.prepareStatement(update)) {
                                up.setString(1, email);
                                up.executeUpdate();
                            }

                            // XỬ LÝ REMEMBER ME
                            if ("on".equals(rememberMe)) {
                                // Tạo token và lưu vào database
                                String token = RememberMeUtil.generateToken(userId, email);
                                
                                if (token != null) {
                                    // Tạo cookie với token
                                    Cookie rememberMeCookie = new Cookie("rememberMeToken", token);
                                    rememberMeCookie.setMaxAge(30 * 24 * 60 * 60); // 30 ngày
                                    rememberMeCookie.setPath("/");
                                    rememberMeCookie.setHttpOnly(true); // Bảo mật
                                    rememberMeCookie.setSecure(false); // Set true nếu dùng HTTPS
                                    response.addCookie(rememberMeCookie);
                                }
                            } else {
                                // Xóa token nếu có (user bỏ tick Remember Me)
                                RememberMeUtil.deleteTokenByUserId(userId);
                                
                                // Xóa cookie
                                Cookie[] cookies = request.getCookies();
                                if (cookies != null) {
                                    for (Cookie cookie : cookies) {
                                        if ("rememberMeToken".equals(cookie.getName())) {
                                            cookie.setMaxAge(0);
                                            cookie.setPath("/");
                                            response.addCookie(cookie);
                                        }
                                    }
                                }
                            }

                            // Hiển thị thông báo thành công
                            showAlert(response, "success", "✅ Đăng nhập thành công!",
                                    "Chào mừng " + name + " quay lại!", "profile.jsp", false);
                        } else {
                            request.setAttribute("error", "❌ Sai mật khẩu, vui lòng thử lại!");
                            request.getRequestDispatcher("login.jsp").forward(request, response);
                        }
                    } else {
                        request.setAttribute("error", "❌ Tài khoản không tồn tại!");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "❌ Lỗi hệ thống! Vui lòng thử lại sau.<br>Chi tiết: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    /**
     * Hiển thị thông báo SweetAlert2 có tự động redirect
     */
    private void showAlert(HttpServletResponse response, String icon, String title, String text,
                           String redirectUrl, boolean showConfirm) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html lang='vi'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>" + title + "</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<style>body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }</style>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: '" + icon + "',");
        out.println("  title: '" + title + "',");
        out.println("  html: '" + text.replace("'", "\\'") + "',");
        out.println("  showConfirmButton: " + showConfirm + ",");
        if (!showConfirm) {
            out.println("  timer: 2500, timerProgressBar: true,");
        }
        out.println("  confirmButtonColor: '#3085d6', confirmButtonText: 'OK'");
        out.println("}).then(() => { window.location.href = '" + redirectUrl + "'; });");
        out.println("</script></body></html>");
    }
}