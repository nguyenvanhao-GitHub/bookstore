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

        // 1. Kiểm tra đăng nhập
        String userEmail = (String) session.getAttribute("userEmail");
        if (userEmail == null) {
            setAlert(session, "error", "Chưa đăng nhập!", "Vui lòng đăng nhập để đánh giá.");
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Lấy dữ liệu từ form
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            if(comment != null) comment = comment.trim();

            ReviewDAO reviewDAO = new ReviewDAO();

            // 3. Tạo Entity Review (Sử dụng Setters cho an toàn)
            Review newReview = new Review();
            newReview.setUserEmail(userEmail);
            newReview.setBookId(bookId);
            newReview.setRating(rating);
            newReview.setComment(comment);
            newReview.setCreatedAt(new Timestamp(System.currentTimeMillis()));

            // 4. Lưu vào DB
            boolean isAdded = reviewDAO.addReview(newReview);

            if (isAdded) {
                setAlert(session, "success", "Thành công", "Cảm ơn bạn đã đánh giá!");
            } else {
                setAlert(session, "error", "Thất bại", "Có lỗi xảy ra khi lưu đánh giá.");
            }
            
            response.sendRedirect("book-detail.jsp?id=" + bookId);

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