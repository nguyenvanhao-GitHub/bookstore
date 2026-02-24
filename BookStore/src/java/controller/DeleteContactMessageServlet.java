package controller;
import dao.ContactDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteContactMessageServlet")
public class DeleteContactMessageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        HttpSession session = request.getSession();
        try {
            int id = Integer.parseInt(idStr);
            if(new ContactDAO().deleteMessage(id)){
                 setAlert(session, "success", "Đã xóa", "Tin nhắn đã được xóa.");
            } else {
                 setAlert(session, "error", "Lỗi", "Không thể xóa tin nhắn.");
            }
        } catch (Exception e) {
             setAlert(session, "error", "Lỗi", "ID không hợp lệ.");
        }
        response.sendRedirect("admin/contact.jsp");
    }
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}