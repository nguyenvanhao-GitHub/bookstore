package controller;

import dao.SubscriberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteSubscriberServlet")
public class DeleteSubscriberServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                SubscriberDAO dao = new SubscriberDAO();
                
                if (dao.deleteSubscriber(id)) {
                    setAlert(session, "success", "Đã xóa", "Subscriber đã được xóa khỏi danh sách.");
                } else {
                    setAlert(session, "error", "Lỗi", "Không thể xóa subscriber này.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                setAlert(session, "error", "Lỗi hệ thống", "ID không hợp lệ hoặc lỗi server.");
            }
        } else {
            setAlert(session, "error", "Lỗi", "Thiếu ID subscriber.");
        }
        
        response.sendRedirect("admin/subscriber.jsp");
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}