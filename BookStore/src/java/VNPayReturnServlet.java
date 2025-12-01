import config.VNPayConfig;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/VNPayReturnServlet")
public class VNPayReturnServlet extends HttpServlet {
    
    private static final String EMAIL_FROM = "haonguyen2004hy@gmail.com";
    private static final String EMAIL_PASSWORD = "ejpk uhrq byde nxyn";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // ✅ Set UTF-8 encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        
        try {
            // ✅ Get all VNPay return parameters
            Map<String, String> vnp_Params = new HashMap<>();
            Enumeration<String> params = request.getParameterNames();
            
            while (params.hasMoreElements()) {
                String paramName = params.nextElement();
                String paramValue = request.getParameter(paramName);
                vnp_Params.put(paramName, paramValue);
            }
            
            System.out.println("========== VNPay Return Parameters ==========");
            for (Map.Entry<String, String> entry : vnp_Params.entrySet()) {
                System.out.println(entry.getKey() + " = " + entry.getValue());
            }
            System.out.println("============================================");
            
            // ✅ Get important parameters
            String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
            String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");
            String vnp_TxnRef = request.getParameter("vnp_TxnRef"); // Order ID
            String vnp_Amount = request.getParameter("vnp_Amount");
            String vnp_OrderInfo = request.getParameter("vnp_OrderInfo");
            String vnp_PayDate = request.getParameter("vnp_PayDate");
            
            // ✅ Verify signature
            boolean signValid = VNPayConfig.verifyPayment(new HashMap<>(vnp_Params));
            
            System.out.println("========== VNPay Verification ==========");
            System.out.println("Signature Valid: " + signValid);
            System.out.println("Response Code: " + vnp_ResponseCode);
            System.out.println("Transaction No: " + vnp_TransactionNo);
            System.out.println("Order ID: " + vnp_TxnRef);
            System.out.println("========================================");
            
            // ✅ Check signature
            if (!signValid) {
                System.err.println("❌ Invalid signature!");
                showErrorAlert(response, "Lỗi bảo mật", 
                    "Chữ ký không hợp lệ. Giao dịch có thể bị can thiệp.");
                return;
            }
            
            // ✅ Check payment success
            if ("00".equals(vnp_ResponseCode)) {
                // ✅ Payment successful
                @SuppressWarnings("unchecked")
                Map<String, String> orderInfo = (Map<String, String>) session.getAttribute("orderInfo");
                
                if (orderInfo == null) {
                    showErrorAlert(response, "Lỗi", "Không tìm thấy thông tin đơn hàng.");
                    return;
                }
                
                // ✅ Get order details
                String orderId = orderInfo.get("orderId");
                String fullName = orderInfo.get("fullName");
                String userEmail = orderInfo.get("userEmail");
                String phone = orderInfo.get("phone");
                String address = orderInfo.get("address");
                String city = orderInfo.get("city");
                String state = orderInfo.get("state");
                String zipCode = orderInfo.get("zipCode");
                String books = orderInfo.get("books");
                double total = Double.parseDouble(orderInfo.get("total"));
                
                // ✅ Save order to database
                boolean orderSaved = saveOrderToDatabase(
                    orderId, fullName, userEmail, phone, address, 
                    city, state, zipCode, books, total, vnp_TransactionNo
                );
                
                if (orderSaved) {
                    System.out.println("✅ Order saved successfully: " + orderId);
                    
                    // ✅ Clear cart
                    clearCart(userEmail);
                    
                    // ✅ Send email
                    sendPaymentSuccessEmail(userEmail, fullName, orderId, vnp_TransactionNo, total);
                    
                    // ✅ Clear session
                    session.removeAttribute("orderInfo");
                    
                    // ✅ Show success
                    showSuccessAlert(response, orderId, vnp_TransactionNo, total);
                } else {
                    System.err.println("❌ Failed to save order");
                    showErrorAlert(response, "Lỗi lưu đơn hàng", 
                        "Thanh toán thành công nhưng không thể lưu đơn hàng. Vui lòng liên hệ hỗ trợ.");
                }
            } else {
                // ✅ Payment failed
                String errorMessage = VNPayConfig.getResponseMessage(vnp_ResponseCode);
                System.err.println("❌ Payment failed: " + vnp_ResponseCode + " - " + errorMessage);
                showPaymentFailedAlert(response, vnp_ResponseCode, errorMessage);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Exception in VNPayReturnServlet: " + e.getMessage());
            e.printStackTrace();
            showErrorAlert(response, "Lỗi hệ thống", 
                "Đã có lỗi xảy ra: " + e.getMessage());
        }
    }
    
    /**
     * Save order to database
     */
    private boolean saveOrderToDatabase(String orderId, String fullName, String email, 
            String phone, String address, String city, String state, String zipCode, 
            String books, double total, String transactionNo) {
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
            
            String insertSql = "INSERT INTO orders (id, customer_name, email, phone, address, " +
                             "city, state, zipcode, books, total_amount, payment_method, status, " +
                             "transaction_id, order_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            
            stmt = conn.prepareStatement(insertSql);
            stmt.setString(1, orderId);
            stmt.setString(2, fullName);
            stmt.setString(3, email);
            stmt.setString(4, phone);
            stmt.setString(5, address);
            stmt.setString(6, city);
            stmt.setString(7, state);
            stmt.setString(8, zipCode);
            stmt.setString(9, books);
            stmt.setDouble(10, total);
            stmt.setString(11, "VNPay");
            stmt.setString(12, "paid"); // ✅ Đã thanh toán
            stmt.setString(13, transactionNo);
            
            int rowsInserted = stmt.executeUpdate();
            return rowsInserted > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
    
    /**
     * Clear cart after successful payment
     */
    private void clearCart(String userEmail) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
            
            String clearSql = "DELETE FROM cart WHERE user_email = ?";
            stmt = conn.prepareStatement(clearSql);
            stmt.setString(1, userEmail);
            stmt.executeUpdate();
            
            System.out.println("✅ Cart cleared for user: " + userEmail);
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
    
    /**
     * Send payment success email
     */
    private void sendPaymentSuccessEmail(String email, String name, String orderId, 
            String transactionNo, double total) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session mailSession = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(EMAIL_FROM, "E-Books Store"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("✅ Thanh toán thành công - Đơn hàng #" + orderId);

            String htmlContent = buildPaymentSuccessEmail(orderId, name, transactionNo, total);
            message.setContent(htmlContent, "text/html; charset=UTF-8");
            
            Transport.send(message);
            System.out.println("✅ Email sent to: " + email);
            
        } catch (Exception e) {
            System.err.println("❌ Failed to send email: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Build payment success email HTML
     */
    private String buildPaymentSuccessEmail(String orderId, String name, 
            String transactionNo, double total) {
        
        return "<!DOCTYPE html><html><head><style>" +
               "body { font-family: Arial; background: #f5f5f5; margin: 0; padding: 20px; }" +
               ".container { max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }" +
               ".header { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; padding: 40px 20px; text-align: center; }" +
               ".success-icon { font-size: 60px; margin-bottom: 20px; }" +
               ".header h1 { margin: 0; font-size: 28px; }" +
               ".content { padding: 30px; }" +
               ".detail { background: #f9f9f9; padding: 15px; margin: 10px 0; border-radius: 8px; display: flex; justify-content: space-between; }" +
               ".label { font-weight: 600; color: #666; }" +
               ".value { color: #333; font-weight: 500; }" +
               ".total { font-size: 32px; font-weight: 700; color: #4CAF50; text-align: center; margin: 30px 0; padding: 20px; background: #f0f9ff; border-radius: 8px; }" +
               ".footer { text-align: center; padding: 20px; background: #f5f5f5; color: #666; font-size: 13px; }" +
               ".btn { display: inline-block; padding: 12px 30px; background: #4CAF50; color: white; text-decoration: none; border-radius: 6px; margin: 20px 0; }" +
               "</style></head><body>" +
               "<div class='container'>" +
               "<div class='header'>" +
               "<div class='success-icon'>✓</div>" +
               "<h1>Thanh toán thành công!</h1>" +
               "<p style='margin: 10px 0 0 0; opacity: 0.9;'>Cảm ơn bạn đã mua hàng</p>" +
               "</div>" +
               "<div class='content'>" +
               "<p>Xin chào <strong>" + name + "</strong>,</p>" +
               "<p>Giao dịch thanh toán của bạn đã được xử lý thành công. Đơn hàng sẽ được giao đến bạn trong thời gian sớm nhất.</p>" +
               "<div class='detail'><span class='label'>Mã đơn hàng:</span><span class='value'>" + orderId + "</span></div>" +
               "<div class='detail'><span class='label'>Mã giao dịch VNPay:</span><span class='value'>" + transactionNo + "</span></div>" +
               "<div class='detail'><span class='label'>Phương thức thanh toán:</span><span class='value'>VNPay</span></div>" +
               "<div class='detail'><span class='label'>Trạng thái:</span><span class='value' style='color:#4CAF50;'>✓ Đã thanh toán</span></div>" +
               "<div class='detail'><span class='label'>Thời gian:</span><span class='value'>" + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) + "</span></div>" +
               "<div class='total'>₫" + String.format("%,.0f", total) + "</div>" +
               "<p style='margin-top: 30px;'>Bạn có thể theo dõi trạng thái đơn hàng tại trang <strong>Đơn mua</strong> của bạn.</p>" +
               "<center><a href='http://localhost:8081/BookStore/orders.jsp' class='btn'>Xem đơn hàng</a></center>" +
               "</div>" +
               "<div class='footer'>" +
               "<p><strong>E-Books Store</strong></p>" +
               "<p>Cảm ơn bạn đã tin tưởng và mua hàng tại E-Books Store!</p>" +
               "<p style='margin-top: 15px; font-size: 11px; color: #999;'>Email này được gửi tự động. Vui lòng không trả lời email này.</p>" +
               "</div>" +
               "</div></body></html>";
    }
    
    /**
     * Show success alert
     */
    private void showSuccessAlert(HttpServletResponse response, String orderId, 
            String transactionNo, double total) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html><html><head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Thanh toán thành công</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: 'success',");
        out.println("  title: '<i class=\"fas fa-check-circle\" style=\"color: #4CAF50;\"></i> Thanh toán thành công!',");
        out.println("  html: '<div style=\"text-align:left; padding:20px; background:#f9f9f9; border-radius:8px; margin:20px 0;\">' +");
        out.println("        '<p style=\"margin:10px 0;\"><strong>Mã đơn hàng:</strong> " + orderId + "</p>' +");
        out.println("        '<p style=\"margin:10px 0;\"><strong>Mã giao dịch:</strong> " + transactionNo + "</p>' +");
        out.println("        '<p style=\"margin:10px 0;\"><strong>Số tiền:</strong> <span style=\"color:#4CAF50; font-size:20px; font-weight:700;\">₫" + String.format("%,.0f", total) + "</span></p>' +");
        out.println("        '<p style=\"margin:10px 0;\"><strong>Trạng thái:</strong> <span style=\"color:#4CAF50; font-weight:600;\">✓ Đã thanh toán</span></p>' +");
        out.println("        '</div>' +");
        out.println("        '<p style=\"font-size:14px; color:#666; margin-top:15px;\"><i class=\"fas fa-envelope\"></i> Email xác nhận đã được gửi đến hộp thư của bạn.</p>',");
        out.println("  confirmButtonText: '<i class=\"fas fa-list\"></i> Xem đơn hàng',");
        out.println("  confirmButtonColor: '#4CAF50',");
        out.println("  allowOutsideClick: false,");
        out.println("  customClass: { popup: 'swal-wide' }");
        out.println("}).then(() => { window.location.href = 'orders.jsp'; });");
        out.println("</script>");
        out.println("<style>.swal-wide { width: 600px !important; }</style>");
        out.println("</body></html>");
    }
    
    /**
     * Show payment failed alert
     */
    private void showPaymentFailedAlert(HttpServletResponse response, String code, 
            String message) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html><html><head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Thanh toán thất bại</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: 'error',");
        out.println("  title: 'Thanh toán thất bại',");
        out.println("  html: '<div style=\"text-align:left; padding:15px;\">' +");
        out.println("        '<p><strong>Mã lỗi:</strong> " + code + "</p>' +");
        out.println("        '<p style=\"margin-top:10px;\">" + escapeJavaScript(message) + "</p>' +");
        out.println("        '</div>',");
        out.println("  confirmButtonText: 'Thử lại',");
        out.println("  confirmButtonColor: '#dc3545'");
        out.println("}).then(() => { window.location.href = 'checkout.jsp'; });");
        out.println("</script></body></html>");
    }
    
    /**
     * Show error alert
     */
    private void showErrorAlert(HttpServletResponse response, String title, 
            String message) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html><html><head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Lỗi</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head><body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: 'error',");
        out.println("  title: '" + escapeJavaScript(title) + "',");
        out.println("  text: '" + escapeJavaScript(message) + "',");
        out.println("  confirmButtonText: 'Quay lại',");
        out.println("  confirmButtonColor: '#dc3545'");
        out.println("}).then(() => { window.location.href = 'index.jsp'; });");
        out.println("</script></body></html>");
    }
    
    /**
     * Escape JavaScript strings
     */
    private String escapeJavaScript(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("'", "\\'")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}