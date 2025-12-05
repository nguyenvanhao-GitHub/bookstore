package controller;

import dao.PublisherDAO;
import entity.Publisher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;

@WebServlet("/PublisherLoginServlet")
public class PublisherLoginServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        PublisherDAO dao = new PublisherDAO();
        Publisher pub = dao.login(email, password);

        if (pub != null) {
            // 1. Check Locked Status
            if ("Locked".equalsIgnoreCase(pub.getStatus())) {
                String reason = pub.getLockReason();
                String msg = "Tài khoản Nhà xuất bản đã bị khóa.";
                if (reason != null && !reason.trim().isEmpty()) msg += "<br>Lý do: <b>" + reason + "</b>";
                showAlert(response, "error", "Truy cập bị từ chối", msg, "publisher/login.jsp", true);
                return;
            }

            // 2. [MỚI] Check 90 Days Inactivity
            Timestamp lastLogin = pub.getLastLogin();
            if (lastLogin != null) {
                long diff = System.currentTimeMillis() - lastLogin.getTime();
                long days = diff / (24 * 60 * 60 * 1000);

                if (days > 90) {
                    String reason = "Tự động khóa do không hoạt động quá 90 ngày.";
                    dao.lockAccount(pub.getId(), reason);
                    showAlert(response, "error", "Tài khoản bị khóa", 
                        "Tài khoản đã bị khóa do không hoạt động " + days + " ngày.<br>Vui lòng liên hệ Admin.", 
                        "publisher/login.jsp", true);
                    return;
                }
            }

            // 3. Login Success
            // Note: DAO.login() của Publisher thường đã tự update last_login bên trong, 
            // nhưng nếu bạn tách ra giống User thì gọi dao.updateLastLogin(pub.getId()) ở đây.
            
            HttpSession session = request.getSession();
            session.setAttribute("publisherName", pub.getName());
            session.setAttribute("publisherEmail", pub.getEmail());
            session.setAttribute("userRole", "publisher");

            showAlert(response, "success", "Đăng nhập thành công", "Xin chào " + pub.getName(), "publisher/publisher-profile.jsp", false);
            
        } else {
            showAlert(response, "error", "Lỗi", "Sai email hoặc mật khẩu.", "publisher/login.jsp", true);
        }
    }

    private void showAlert(HttpServletResponse response, String icon, String title, String text, String url, boolean confirm) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon: '" + icon + "', title: '" + title + "', html: '" + text + "', showConfirmButton: " + confirm + (confirm ? "" : ", timer: 1500") + "})");
        out.println(".then(() => { window.location.href = '" + url + "'; });");
        out.println("</script></body></html>");
    }
}