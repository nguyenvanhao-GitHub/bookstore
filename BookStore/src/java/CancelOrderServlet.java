import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        String userEmail = (session != null) ? (String) session.getAttribute("userEmail") : null;
        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String orderId = request.getParameter("orderId");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE orders SET status = 'Cancelled' WHERE id = ? AND email = ? AND status = 'Pending'")) {

            ps.setString(1, orderId);
            ps.setString(2, userEmail);
            int updated = ps.executeUpdate();

            if (updated > 0) {
                response.sendRedirect("orders.jsp?cancelSuccess=true");
            } else {
                response.sendRedirect("orders.jsp?cancelFail=true");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("orders.jsp?error=" + e.getMessage());
        }
    }
}
