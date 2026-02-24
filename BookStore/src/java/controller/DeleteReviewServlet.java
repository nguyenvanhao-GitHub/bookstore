package controller;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteReviewServlet")
public class DeleteReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                ReviewDAO dao = new ReviewDAO();
                
                if (dao.deleteReview(id)) {
                    setAlert(session, "success", "Đã xóa", "Đánh giá đã được xóa thành công.");
                } else {
                    setAlert(session, "error", "Thất bại", "Không thể xóa đánh giá này.");
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
                setAlert(session, "error", "Lỗi hệ thống", "Dữ liệu không hợp lệ hoặc lỗi server.");
            }
        } else {
            setAlert(session, "error", "Lỗi", "ID đánh giá không tồn tại.");
        }
        
        response.sendRedirect("admin/reviews.jsp");
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}