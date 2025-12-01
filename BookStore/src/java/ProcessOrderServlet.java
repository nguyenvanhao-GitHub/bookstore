import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import jakarta.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/ProcessOrderServlet")
public class ProcessOrderServlet extends HttpServlet {
    
    // Email configuration
    private static final String EMAIL_FROM = "haonguyen2004hy@gmail.com";
    private static final String EMAIL_PASSWORD = "ejpk uhrq byde nxyn";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get user email from session
        HttpSession session = request.getSession(false);
        
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String userEmail = (String) session.getAttribute("userEmail");
        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Retrieve form data
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String zipCode = request.getParameter("zipCode");
        String totalStr = request.getParameter("total");
        
        // ✅ NHẬN CHUỖI BOOKS ĐÃ FORMAT SẴN TỪ CHECKOUT
        String books = request.getParameter("books");
        
        // 🔍 DEBUG LOG
        System.out.println("========== PROCESS ORDER DEBUG ==========");
        System.out.println("Books parameter received: " + books);
        System.out.println("Total: " + totalStr);
        System.out.println("========================================");
        
        // Validate input
        if (fullName == null || phone == null || address == null || 
            city == null || state == null || zipCode == null || totalStr == null) {
            showErrorAlert(response, "Missing Information", 
                "Please fill in all required fields.");
            return;
        }
        
        double total = 0.0;
        try {
            total = Double.parseDouble(totalStr);
        } catch (NumberFormatException e) {
            showErrorAlert(response, "Invalid Amount", 
                "The total amount is not valid.");
            return;
        }
        
        List<Map<String, Object>> cartDetails = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String orderId = "ORD" + System.currentTimeMillis();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
            
            // ✅ NẾU KHÔNG CÓ BOOKS TỪ FORM, LẤY TỪ DATABASE (FALLBACK)
            if (books == null || books.trim().isEmpty()) {
                System.out.println("⚠️ Books parameter is empty, fetching from database...");
                
                List<String> booksList = new ArrayList<>();
                String cartSql = "SELECT c.bookname, c.quantity, c.price, c.author " +
                               "FROM cart c WHERE c.user_email = ?";
                stmt = conn.prepareStatement(cartSql);
                stmt.setString(1, userEmail);
                rs = stmt.executeQuery();
                
                while (rs.next()) {
                    String bookname = rs.getString("bookname");
                    int quantity = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    String author = rs.getString("author");
                    
                    // ✅ LUÔN THÊM (xN) VÀO TÊN SÁCH
                    booksList.add(bookname + " (x" + quantity + ")");
                    
                    Map<String, Object> item = new HashMap<>();
                    item.put("bookname", bookname);
                    item.put("quantity", quantity);
                    item.put("price", price);
                    item.put("author", author);
                    cartDetails.add(item);
                }
                
                if (booksList.isEmpty()) {
                    showErrorAlert(response, "Empty Cart", 
                        "Your cart is empty. Please add items before placing an order.");
                    return;
                }
                
                books = String.join(", ", booksList);
                System.out.println("✅ Books from database: " + books);
                
                rs.close();
                stmt.close();
            } else {
                // ✅ ĐÃ CÓ BOOKS TỪ FORM, CHỈ CẦN LẤY THÔNG TIN ĐỂ GỬI EMAIL
                System.out.println("✅ Using books from form parameter");
                
                String cartSql = "SELECT c.bookname, c.quantity, c.price, c.author " +
                               "FROM cart c WHERE c.user_email = ?";
                stmt = conn.prepareStatement(cartSql);
                stmt.setString(1, userEmail);
                rs = stmt.executeQuery();
                
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("bookname", rs.getString("bookname"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("price", rs.getDouble("price"));
                    item.put("author", rs.getString("author"));
                    cartDetails.add(item);
                }
                
                rs.close();
                stmt.close();
            }
            
            // ✅ INSERT ORDER VÀO DATABASE
            String insertSql = "INSERT INTO orders (id, customer_name, email, phone, address, " +
                             "city, state, zipcode, books, total_amount, payment_method, status, order_date) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            
            stmt = conn.prepareStatement(insertSql);
            stmt.setString(1, orderId);
            stmt.setString(2, fullName);
            stmt.setString(3, userEmail);
            stmt.setString(4, phone);
            stmt.setString(5, address);
            stmt.setString(6, city);
            stmt.setString(7, state);
            stmt.setString(8, zipCode);
            stmt.setString(9, books);  // ✅ Chuỗi đã có format: "Book1 (x5), Book2 (x3)"
            stmt.setDouble(10, total);
            stmt.setString(11, "Direct Order");
            stmt.setString(12, "pending");
            
            System.out.println("📝 Executing SQL INSERT with books: " + books);
            
            int rowsInserted = stmt.executeUpdate();
            
            if (rowsInserted > 0) {
                System.out.println("✅ Order saved successfully: " + orderId);
                
                // Clear the cart after order is placed
                stmt.close();
                String clearCartSql = "DELETE FROM cart WHERE user_email = ?";
                stmt = conn.prepareStatement(clearCartSql);
                stmt.setString(1, userEmail);
                stmt.executeUpdate();
                
                // Send confirmation email
                sendOrderConfirmationEmail(orderId, userEmail, fullName, phone, address, 
                    city, state, zipCode, cartDetails, total);
                
                // Show success alert
                showSuccessAlert(response, orderId, total);
                
            } else {
                System.out.println("❌ Failed to insert order");
                showErrorAlert(response, "Order Failed", 
                    "Failed to place the order. Please try again.");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Exception occurred: " + e.getMessage());
            e.printStackTrace();
            showErrorAlert(response, "System Error", 
                "Something went wrong: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
    }
    
    /**
     * Send order confirmation email with detailed information
     */
    private void sendOrderConfirmationEmail(String orderId, String email, String name, 
            String phone, String address, String city, String state, String zipcode, 
            List<Map<String, Object>> cartDetails, double total) {
        
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
            message.setSubject("Order Confirmation - #" + orderId);

            String htmlContent = buildEmailHTML(orderId, name, phone, address, 
                city, state, zipcode, cartDetails, total);
            
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            
        } catch (Exception e) {
            e.printStackTrace();
            // Don't throw exception - email failure shouldn't stop the order process
        }
    }
    
    /**
     * Build detailed email HTML content
     */
    private String buildEmailHTML(String orderId, String name, String phone, 
            String address, String city, String state, String zipcode, 
            List<Map<String, Object>> cartDetails, double total) {
        
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>");
        html.append("<html><head><style>");
        html.append("body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }");
        html.append(".container { max-width: 600px; margin: 0 auto; background: #ffffff; }");
        html.append(".header { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; padding: 30px 20px; text-align: center; }");
        html.append(".header h1 { margin: 0; font-size: 28px; }");
        html.append(".content { padding: 30px 20px; }");
        html.append(".section { background: #f9f9f9; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #4CAF50; }");
        html.append(".section h3 { margin: 0 0 15px 0; color: #4CAF50; font-size: 18px; }");
        html.append(".detail-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #e0e0e0; }");
        html.append(".detail-row:last-child { border-bottom: none; }");
        html.append(".label { font-weight: 600; color: #666; }");
        html.append(".value { color: #333; text-align: right; }");
        html.append(".book-item { background: white; padding: 15px; margin: 10px 0; border-radius: 6px; border: 1px solid #e0e0e0; }");
        html.append(".book-name { font-weight: 600; color: #333; margin-bottom: 5px; }");
        html.append(".book-details { color: #666; font-size: 14px; }");
        html.append(".total-section { background: #4CAF50; color: white; padding: 20px; margin: 20px 0; border-radius: 8px; text-align: center; }");
        html.append(".total-amount { font-size: 32px; font-weight: bold; margin: 10px 0; }");
        html.append(".footer { text-align: center; padding: 20px; background: #f5f5f5; color: #666; font-size: 13px; }");
        html.append(".btn { display: inline-block; padding: 12px 30px; background: #4CAF50; color: white; text-decoration: none; border-radius: 6px; margin: 20px 0; }");
        html.append("</style></head><body>");
        
        html.append("<div class='container'>");
        
        // Header
        html.append("<div class='header'>");
        html.append("<h1>🎉 Order Confirmation</h1>");
        html.append("<p style='margin: 10px 0 0 0; font-size: 16px;'>Thank you for your order!</p>");
        html.append("</div>");
        
        // Content
        html.append("<div class='content'>");
        html.append("<p>Dear <strong>").append(name).append("</strong>,</p>");
        html.append("<p>Your order has been successfully placed and is being processed. Below are the details of your order:</p>");
        
        // Order Information
        html.append("<div class='section'>");
        html.append("<h3>📋 Order Information</h3>");
        html.append("<div class='detail-row'><span class='label'>Order ID:</span><span class='value'><strong>").append(orderId).append("</strong></span></div>");
        html.append("<div class='detail-row'><span class='label'>Order Date:</span><span class='value'>").append(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>Status:</span><span class='value' style='color: #FF9800;'><strong>Pending</strong></span></div>");
        html.append("</div>");
        
        // Shipping Address
        html.append("<div class='section'>");
        html.append("<h3>🚚 Shipping Address</h3>");
        html.append("<div class='detail-row'><span class='label'>Name:</span><span class='value'>").append(name).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>Phone:</span><span class='value'>").append(phone).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>Address:</span><span class='value'>").append(address).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>City:</span><span class='value'>").append(city).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>State:</span><span class='value'>").append(state).append("</span></div>");
        html.append("<div class='detail-row'><span class='label'>Postal Code:</span><span class='value'>").append(zipcode).append("</span></div>");
        html.append("</div>");
        
        // Items Ordered
        html.append("<div class='section'>");
        html.append("<h3>📚 Items Ordered</h3>");
        for (Map<String, Object> item : cartDetails) {
            html.append("<div class='book-item'>");
            html.append("<div class='book-name'>").append(item.get("bookname")).append("</div>");
            html.append("<div class='book-details'>");
            html.append("Author: ").append(item.get("author")).append(" | ");
            html.append("Quantity: ").append(item.get("quantity")).append(" | ");
            html.append("Price: ₫").append(String.format("%.0f", (Double)item.get("price")));
            html.append("</div>");
            html.append("</div>");
        }
        html.append("</div>");
        
        // Total Amount
        html.append("<div class='total-section'>");
        html.append("<div>Total Amount</div>");
        html.append("<div class='total-amount'>₫").append(String.format("%.0f", total)).append("</div>");
        html.append("</div>");
        
        html.append("<p style='margin-top: 30px;'>Your order will be processed soon. We will notify you once it has been shipped.</p>");
        
        html.append("<center>");
        html.append("<a href='http://localhost:8081/BookStore/orders.jsp?orderId=")
            .append(orderId)
            .append("' class='btn'>Xem trạng thái đơn hàng</a>");
        html.append("</center>");
        
        html.append("</div>");
        
        // Footer
        html.append("<div class='footer'>");
        html.append("<p><strong>Thank you for shopping with E-Books Store!</strong></p>");
        html.append("<p>If you have any questions about your order, please contact our customer support.</p>");
        html.append("<p style='margin-top: 15px; font-size: 11px; color: #999;'>This is an automated email. Please do not reply to this message.</p>");
        html.append("</div>");
        
        html.append("</div>");
        html.append("</body></html>");
        
        return html.toString();
    }
    
    /**
     * Show success alert with SweetAlert2
     */
    private void showSuccessAlert(HttpServletResponse response, String orderId, double total) 
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Order Success</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>");
        out.println("</head>");
        out.println("<body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: 'success',");
        out.println("  title: '<i class=\"fas fa-check-circle\" style=\"color: #4CAF50;\"></i> Order Placed Successfully!',");
        out.println("  html: '<div style=\"text-align: left; padding: 20px;\">' +");
        out.println("        '<p style=\"font-size: 16px; margin-bottom: 15px;\">Your order has been placed successfully!</p>' +");
        out.println("        '<div style=\"background: #f9f9f9; padding: 15px; border-radius: 8px; margin: 15px 0;\">' +");
        out.println("        '<p style=\"margin: 5px 0;\"><strong>Order ID:</strong> " + orderId + "</p>' +");
        out.println("        '<p style=\"margin: 5px 0;\"><strong>Total Amount:</strong> <span style=\"color: #4CAF50; font-size: 18px;\">₫" + String.format("%.0f", total) + "</span></p>' +");
        out.println("        '<p style=\"margin: 5px 0;\"><strong>Status:</strong> <span style=\"color: #FF9800;\">Pending</span></p>' +");
        out.println("        '</div>' +");
        out.println("        '<p style=\"font-size: 14px; color: #666; margin-top: 15px;\"><i class=\"fas fa-envelope\"></i> A confirmation email has been sent to your registered email address.</p>' +");
        out.println("        '</div>',");
        out.println("  confirmButtonText: '<i class=\"fas fa-list\"></i> View My Orders',");
        out.println("  confirmButtonColor: '#4CAF50',");
        out.println("  allowOutsideClick: false,");
        out.println("  customClass: { popup: 'swal-wide' }");
        out.println("}).then(() => {");
        out.println("  window.location.href = 'orders.jsp';");
        out.println("});");
        out.println("</script>");
        out.println("<style>");
        out.println(".swal-wide { width: 600px !important; }");
        out.println("</style>");
        out.println("</body>");
        out.println("</html>");
    }
    
    /**
     * Show error alert with SweetAlert2
     */
    private void showErrorAlert(HttpServletResponse response, String title, String message) 
            throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='en'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Error</title>");
        out.println("<script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script>");
        out.println("</head>");
        out.println("<body>");
        out.println("<script>");
        out.println("Swal.fire({");
        out.println("  icon: 'error',");
        out.println("  title: '" + escapeJavaScript(title) + "',");
        out.println("  text: '" + escapeJavaScript(message) + "',");
        out.println("  confirmButtonText: 'Back to Checkout',");
        out.println("  confirmButtonColor: '#dc3545'");
        out.println("}).then(() => {");
        out.println("  window.location.href = 'checkout.jsp';");
        out.println("});");
        out.println("</script>");
        out.println("</body>");
        out.println("</html>");
    }
    
    /**
     * Escape JavaScript strings to prevent XSS
     */
    private String escapeJavaScript(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("'", "\\'")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r");
    }
}