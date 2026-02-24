package controller;

import dao.ReviewDAO;
import entity.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String userEmail = (String) session.getAttribute("userEmail");
        if (userEmail == null) {
            setAlert(session, "error", "Chưa đăng nhập!", "Vui lòng đăng nhập để đánh giá.");
            response.sendRedirect("login.jsp");
            return;
        }

        try {

            int bookId = Integer.parseInt(request.getParameter("bookId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            if (comment != null) {
                comment = comment.trim();
            }

            ReviewDAO reviewDAO = new ReviewDAO();

            Review newReview = new Review();
            newReview.setUserEmail(userEmail);
            newReview.setBookId(bookId);
            newReview.setRating(rating);
            newReview.setComment(comment);
            newReview.setCreatedAt(new Timestamp(System.currentTimeMillis()));

            boolean isAdded = reviewDAO.addReview(newReview);

            if (isAdded) {
                response.sendRedirect("book-detail.jsp?id=" + bookId + "&reviewSuccess=true");
            } else {
                response.sendRedirect("book-detail.jsp?id=" + bookId + "&reviewError=true");
            }

        } catch (NumberFormatException e) {
            setAlert(session, "error", "Lỗi dữ liệu", "Thông tin đánh giá không hợp lệ.");
            response.sendRedirect("index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            setAlert(session, "error", "Lỗi hệ thống", e.getMessage());
            response.sendRedirect("index.jsp");
        }
    }

    private void setAlert(HttpSession session, String icon, String title, String message) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", message);
    }
}
