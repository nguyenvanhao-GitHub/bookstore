import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/DeleteOrderServlet")
public class DeleteOrderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("orderId");

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
                "root", "");
             PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE id = ?")) {

            ps.setString(1, orderId);
            int rows = ps.executeUpdate();

            HttpSession session = request.getSession();
            if (rows > 0) {
                session.setAttribute("alert", "✅ Order deleted successfully!");
            } else {
                session.setAttribute("alert", "⚠️ Order not found!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("alert", "❌ Error deleting order: " + e.getMessage());
        }

        response.sendRedirect("admin/orders.jsp");
    }
}
