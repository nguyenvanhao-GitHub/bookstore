import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/DeleteReviewServlet")
public class DeleteReviewServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String reviewIdParam = request.getParameter("id");

        if (reviewIdParam == null || reviewIdParam.trim().isEmpty()) {
            session.setAttribute("deleteStatus", "error");
            session.setAttribute("deleteMessage", "ID đánh giá không hợp lệ!");
            response.sendRedirect("admin/reviews.jsp");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM reviews WHERE id = ?")) {

            Class.forName("com.mysql.cj.jdbc.Driver");
            int reviewId = Integer.parseInt(reviewIdParam);
            stmt.setInt(1, reviewId);

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                session.setAttribute("deleteStatus", "success");
                session.setAttribute("deleteMessage", "Đánh giá đã được xóa thành công!");
            } else {
                session.setAttribute("deleteStatus", "failed");
                session.setAttribute("deleteMessage", "Không tìm thấy đánh giá để xóa!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("deleteStatus", "error");
            session.setAttribute("deleteMessage", "ID đánh giá không đúng định dạng!");
        } catch (Exception e) {
            session.setAttribute("deleteStatus", "error");
            session.setAttribute("deleteMessage", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect("admin/reviews.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
