package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailUtils {
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "587";
    private static final String EMAIL = "haonguyen2004hy@gmail.com";
    private static final String PASSWORD = "ejpk uhrq byde nxyn"; 
    
    private static Session getSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);

        return Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL, PASSWORD);
            }
        });
    }
    
    public static void sendEmail(String to, String subject, String htmlContent) throws MessagingException {
        Message msg = new MimeMessage(getSession());
        msg.setFrom(new InternetAddress(EMAIL));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        msg.setSubject(subject);
        msg.setContent(htmlContent, "text/html; charset=UTF-8");
        
        Transport.send(msg);
    }

    public static void sendPasswordResetEmail(String toEmail, String newPassword) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL, PASSWORD);
            }
        });

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(EMAIL));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Yêu cầu cấp lại mật khẩu - E-Books Library");
        
        String content = "<h3>Xin chào,</h3>"
                + "<p>Mật khẩu mới của bạn là: <b style='color: blue;'>" + newPassword + "</b></p>"
                + "<p>Vui lòng đổi lại mật khẩu ngay lập tức.</p>";
        
        msg.setContent(content, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
    
    public static void send(String to, String subject, String htmlContent) throws MessagingException {
        Message msg = new MimeMessage(getSession());
        msg.setFrom(new InternetAddress(EMAIL));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        msg.setSubject(subject);
        msg.setContent(htmlContent, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
}