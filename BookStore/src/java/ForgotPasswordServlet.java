import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.*;
import java.util.Properties;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    private String generateSalt() {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        StringBuilder sb = new StringBuilder();
        for (byte b : salt) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private String hashPassword(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update((password + salt).getBytes());
            byte[] hashed = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : hashed) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random rand = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt(rand.nextInt(chars.length())));
        }
        return sb.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/bookstore",
                    "root",
                    ""
            );

            // Kiểm tra email
            PreparedStatement ps = con.prepareStatement("SELECT id FROM user WHERE email=?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int id = rs.getInt("id");

                // Tạo mật khẩu mới
                String newPassword = generateRandomPassword();
                String newSalt = generateSalt();
                String hashed = hashPassword(newPassword, newSalt);

                PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE user SET password=?, salt=? WHERE id=?");
                psUpdate.setString(1, hashed);
                psUpdate.setString(2, newSalt);
                psUpdate.setInt(3, id);
                psUpdate.executeUpdate();

                // Gửi email
                sendEmail(email, newPassword);

                out.println("<script>alert('New password sent to your email!');window.location='login.jsp';</script>");
            } else {
                out.println("<script>alert('Email not found!');window.location='forgot-password.jsp';</script>");
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('Error: " + e.getMessage() + "');window.location='forgot-password.jsp';</script>");
        }
    }

    private void sendEmail(String to, String newPassword) throws MessagingException {
        final String from = "haonguyen2004hy@gmail.com"; // Gmail thật
        final String pass = "ejpk uhrq byde nxyn";       // App Password (16 ký tự)

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, pass);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject("Your New Password - E-Books Digital Library");
        message.setText("Hello,\n\nYour new password is: " + newPassword +
                "\n\nPlease log in and change it soon.\n\nBest regards,\nE-Books Support Team");
        Transport.send(message);
        
    }
}
