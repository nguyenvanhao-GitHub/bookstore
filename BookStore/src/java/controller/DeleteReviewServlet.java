package controller;

import dao.ReviewDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteReviewServlet")
public class DeleteReviewServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        HttpSession session = request.getSession();
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                if (new ReviewDAO().deleteReview(id)) {
                    session.setAttribute("deleteStatus", "success");
                    session.setAttribute("deleteMessage", "Review deleted successfully.");
                } else {
                    session.setAttribute("deleteStatus", "failed");
                    session.setAttribute("deleteMessage", "Failed to delete review.");
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
                session.setAttribute("deleteStatus", "error");
                session.setAttribute("deleteMessage", "System error.");
            }
        }
        response.sendRedirect("admin/reviews.jsp");
    }
}