import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("status");

        Connection conn = null;
        PreparedStatement getStmt = null;
        PreparedStatement updateStmt = null;
        ResultSet rs = null;
        HttpSession session = request.getSession();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");

            // 1. Get current status, email, and name
            String email = null, name = null, currentStatus = null;

            String getSql = "SELECT email, customer_name, status FROM orders WHERE id = ?";
            getStmt = conn.prepareStatement(getSql);
            getStmt.setString(1, orderId);
            rs = getStmt.executeQuery();

            if (rs.next()) {
                email = rs.getString("email");
                name = rs.getString("customer_name");
                currentStatus = rs.getString("status");
            }

            // 2. Prevent update if already cancelled or delivered
            if (currentStatus == null || (!currentStatus.equalsIgnoreCase("pending"))) {
                session.setAttribute("alert", "Cannot update. Order is already " + currentStatus + ".");
            } else {
                // 3. Update if it's still pending
                String updateSql = "UPDATE orders SET status = ? WHERE id = ?";
                updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, newStatus);
                updateStmt.setString(2, orderId);
                int rowsUpdated = updateStmt.executeUpdate();

                if (rowsUpdated > 0) {
                    session.setAttribute("alert", "Order status updated successfully!");
                    if (email != null) {
                        sendStatusUpdateEmail(email, name, orderId, newStatus);
                    }
                } else {
                    session.setAttribute("alert", "Failed to update order status.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("alert", "Something went wrong!");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (getStmt != null) getStmt.close(); } catch (Exception ignored) {}
            try { if (updateStmt != null) updateStmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }

        response.sendRedirect("admin/orders.jsp");
    }

    private void sendStatusUpdateEmail(String recipient, String name, String orderId, String status) {
        final String senderEmail = "haonguyen2004hy@gmail.com";
        final String senderPassword = "ejpk uhrq byde nxyn"; // App Password

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(senderEmail, "BookStore Admin"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipient));
            message.setSubject("Your Order Status Has Been Updated");
            message.setText("Hello " + name + ",\n\nYour order (ID: " + orderId + ") status has been updated to: " + status.toUpperCase() + ".\n\nThank you for shopping with us!\n\n— BookStore Team");

            Transport.send(message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
