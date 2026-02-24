package controller;

import dao.AdminDAO;
import entity.Admin;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        AdminDAO dao = new AdminDAO();
        Admin admin = dao.login(email, password); 

        HttpSession session = request.getSession();

        if (admin != null) {
            if ("Locked".equalsIgnoreCase(admin.getStatus()) || "Inactive".equalsIgnoreCase(admin.getStatus())) {
                String reason = admin.getLockReason(); // Lấy reason từ object
                String msg = "Tài khoản của bạn đã bị khóa.";
                if (reason != null && !reason.trim().isEmpty()) {
                    msg += "<br>Lý do: <b>" + reason + "</b>";
                } else {
                    msg += "<br>Vui lòng liên hệ quản trị viên cấp cao.";
                }

                showAlert(response, "error", "Truy cập bị từ chối", msg, "admin/login.jsp", true);
                return;
            }

            session.setAttribute("adminName", admin.getName());
            session.setAttribute("adminEmail", admin.getEmail());
            session.setAttribute("userRole", "admin");

            showAlert(response, "success", "Đăng nhập thành công!", "Chào mừng " + admin.getName(), "admin/index.jsp", false);

        } else {
            showAlert(response, "error", "Đăng nhập thất bại", "Email hoặc mật khẩu không đúng.", "admin/login.jsp", true);
        }
    }

    private void showAlert(HttpServletResponse response, String icon, String title, String text, String url, boolean confirm) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Notification</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<style>body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; }</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: '" + icon + "',");
        out.println("  title: '" + title + "',");
        out.println("  html: '" + text + "',"); // Sử dụng html để hiển thị thẻ <br> hoặc <b>
        out.println("  showConfirmButton: " + confirm + ",");
        if (!confirm) {
            out.println("  timer: 2000,");
            out.println("  timerProgressBar: true,");
        } else {
            out.println("  confirmButtonText: 'Đóng',");
            out.println("  confirmButtonColor: '#3085d6',");
        }
        out.println("  allowOutsideClick: false");
        out.println("}).then(() => {");
        out.println("  window.location.href = '" + url + "';");
        out.println("});");
        out.println("</script>");
        out.println("</body>");
        out.println("</html>");
        out.close();
    }
}
