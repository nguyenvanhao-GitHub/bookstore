<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.google.gson.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Parse selected items from cart
    String selectedItemsJSON = request.getParameter("selectedItems");
    String totalAmountStr = request.getParameter("totalAmount");

    List<Map<String, Object>> cartItems = new ArrayList<>();
    double total = 0.0;

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

    try {
        if (selectedItemsJSON != null && !selectedItemsJSON.isEmpty()) {
            Gson gson = new Gson();
            JsonArray jsonArray = gson.fromJson(selectedItemsJSON, JsonArray.class);

            for (int i = 0; i < jsonArray.size(); i++) {
                JsonObject jsonItem = jsonArray.get(i).getAsJsonObject();
                Map<String, Object> item = new HashMap<>();
                item.put("book_id", jsonItem.get("bookId").getAsString());
                item.put("bookname", jsonItem.get("bookname").getAsString());
                item.put("author", jsonItem.get("author").getAsString());
                item.put("quantity", jsonItem.get("quantity").getAsInt());
                double subtotal = jsonItem.get("subtotal").getAsDouble();
                int quantity = jsonItem.get("quantity").getAsInt();
                item.put("priceVND", subtotal / quantity);
                item.put("subtotal", subtotal);
                total += subtotal;
                cartItems.add(item);
            }
        } else if (totalAmountStr != null) {
            total = Double.parseDouble(totalAmountStr);
        } else {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
            String sql = "SELECT book_id, bookname, author, price, quantity FROM cart WHERE user_email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, userEmail);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("book_id", rs.getString("book_id"));
                item.put("bookname", rs.getString("bookname"));
                item.put("author", rs.getString("author"));
                item.put("quantity", rs.getInt("quantity"));
                double price = rs.getDouble("price");
                int quantity = rs.getInt("quantity");
                double priceVND = price * 300;
                double subtotal = priceVND * quantity;
                item.put("priceVND", priceVND);
                item.put("subtotal", subtotal);
                total += subtotal;
                cartItems.add(item);
            }
            conn.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - BookStore</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 40px 20px;
            min-height: 100vh;
        }

        .checkout-wrapper { max-width: 1400px; margin: 0 auto; }

        .checkout-header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
            animation: fadeInDown 0.6s ease;
        }

        .checkout-header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .checkout-container {
            display: grid;
            grid-template-columns: 1fr 450px;
            gap: 30px;
            animation: fadeInUp 0.6s ease;
        }

        .checkout-form {
            background: white;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group { margin-bottom: 20px; }
        .form-group.full-width { grid-column: 1 / -1; }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 0.9rem;
        }

        .input-wrapper { position: relative; }

        .input-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 14px 15px 14px 45px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s;
            background: #fafafa;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        .form-group input[readonly] {
            background: #f5f5f5;
            cursor: not-allowed;
        }

        .form-group textarea {
            height: 80px;
            resize: vertical;
            padding-top: 14px;
        }

        .error {
            color: #f44336;
            font-size: 0.85rem;
            margin-top: 5px;
        }

        /* ===== PAYMENT METHODS ===== */
        .payment-methods {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
        }

        .payment-method-item {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .payment-method-item:hover {
            border-color: #667eea;
            transform: translateX(5px);
        }

        .payment-method-item.selected {
            border-color: #667eea;
            background: linear-gradient(135deg, #f8f9ff 0%, #f5f0ff 100%);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }

        .payment-method-item input[type="radio"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }

        .payment-method-info { flex: 1; }

        .payment-method-name {
            font-weight: 700;
            font-size: 1.1rem;
            color: #333;
            margin-bottom: 5px;
        }

        .payment-method-desc {
            color: #666;
            font-size: 0.9rem;
        }

        .payment-method-logo {
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            border-radius: 8px;
        }

        .vnpay-logo {
            background: #0066B2;
            color: white;
            padding: 10px;
        }

        .cod-logo {
            background: #4CAF50;
            color: white;
        }

        /* ===== ORDER SUMMARY ===== */
        .order-summary {
            background: white;
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            position: sticky;
            top: 20px;
            max-height: calc(100vh - 40px);
            overflow-y: auto;
        }

        .summary-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px dashed #e0e0e0;
        }

        .item-count {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .summary-items {
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 20px;
        }

        .summary-item {
            padding: 15px;
            margin-bottom: 15px;
            background: linear-gradient(135deg, #f8f9ff 0%, #f5f0ff 100%);
            border-radius: 12px;
        }

        .item-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        .item-details {
            display: flex;
            justify-content: space-between;
            color: #666;
            font-size: 0.85rem;
        }

        .price-breakdown {
            padding: 20px 0;
            border-top: 2px dashed #e0e0e0;
        }

        .price-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
        }

        .price-row.total {
            font-size: 1.4rem;
            font-weight: 700;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid #667eea;
            color: #667eea;
        }

        .place-order-btn {
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.2rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
        }

        .place-order-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 30px rgba(102, 126, 234, 0.6);
        }

        .security-badge {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 15px;
            padding: 12px;
            background: #f0f9ff;
            border-radius: 8px;
            color: #666;
            font-size: 0.85rem;
        }

        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 1024px) {
            .checkout-container { grid-template-columns: 1fr; }
            .order-summary { position: static; max-height: none; }
        }

        @media (max-width: 768px) {
            .form-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="checkout-wrapper">
        <div class="checkout-header">
            <h1><i class="fas fa-shopping-bag"></i> Thanh toán đơn hàng</h1>
        </div>

        <div class="checkout-container">
            <div class="checkout-form">
                <div class="section-title">
                    <i class="fas fa-map-marker-alt"></i>
                    Thông tin giao hàng
                </div>

                <form id="checkoutForm" method="post" onsubmit="return validateForm()">
                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fas fa-user"></i> Họ và tên</label>
                            <div class="input-wrapper">
                                <i class="fas fa-user input-icon"></i>
                                <input type="text" id="fullName" name="fullName" value="<%= userName %>" readonly>
                            </div>
                        </div>

                        <div class="form-group">
                            <label><i class="fas fa-envelope"></i> Email</label>
                            <div class="input-wrapper">
                                <i class="fas fa-envelope input-icon"></i>
                                <input type="email" id="email" name="email" value="<%= userEmail %>" readonly>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fas fa-phone"></i> Số điện thoại</label>
                            <div class="input-wrapper">
                                <i class="fas fa-phone input-icon"></i>
                                <input type="tel" id="phone" name="phone" placeholder="0123456789" required>
                            </div>
                            <div class="error" id="phoneError"></div>
                        </div>

                        <div class="form-group">
                            <label><i class="fas fa-city"></i> Thành phố</label>
                            <div class="input-wrapper">
                                <i class="fas fa-city input-icon"></i>
                                <input type="text" id="city" name="city" placeholder="Hà Nội" required>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label><i class="fas fa-map"></i> Tỉnh / Bang</label>
                            <div class="input-wrapper">
                                <i class="fas fa-map input-icon"></i>
                                <input type="text" id="state" name="state" placeholder="Hà Nội" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label><i class="fas fa-mail-bulk"></i> Mã bưu điện</label>
                            <div class="input-wrapper">
                                <i class="fas fa-mail-bulk input-icon"></i>
                                <input type="text" id="zipCode" name="zipCode" placeholder="100000" required>
                            </div>
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label><i class="fas fa-map-marked-alt"></i> Địa chỉ giao hàng</label>
                        <div class="input-wrapper">
                            <i class="fas fa-map-marked-alt input-icon"></i>
                            <textarea id="address" name="address" placeholder="Số nhà, tên đường..." required></textarea>
                        </div>
                    </div>

                    <%
                        StringBuilder booksString = new StringBuilder();
                        for (int i = 0; i < cartItems.size(); i++) {
                            Map<String, Object> item = cartItems.get(i);
                            String bookname = (String) item.get("bookname");
                            int quantity = (Integer) item.get("quantity");
                            booksString.append(bookname);
                            if (quantity > 1) {
                                booksString.append(" (x").append(quantity).append(")");
                            }
                            if (i < cartItems.size() - 1) {
                                booksString.append(", ");
                            }
                        }
                    %>

                    <input type="hidden" name="books" value="<%= booksString.toString() %>">
                    <input type="hidden" name="total" value="<%= total %>">

                    <!-- ===== PAYMENT METHOD ===== -->
                    <div class="section-title" style="margin-top: 30px;">
                        <i class="fas fa-credit-card"></i>
                        Phương thức thanh toán
                    </div>

                    <div class="payment-methods">
                        <label class="payment-method-item selected" onclick="selectPaymentMethod('vnpay', this)">
                            <input type="radio" name="paymentMethod" value="vnpay" checked>
                            <div class="payment-method-info">
                                <div class="payment-method-name">VNPay QR</div>
                                <div class="payment-method-desc">Thanh toán qua VNPay, ATM, Visa, MasterCard</div>
                            </div>
                            <div class="payment-method-logo vnpay-logo">
                                <i class="fas fa-qrcode"></i>
                            </div>
                        </label>

                        <label class="payment-method-item" onclick="selectPaymentMethod('cod', this)">
                            <input type="radio" name="paymentMethod" value="cod">
                            <div class="payment-method-info">
                                <div class="payment-method-name">Thanh toán khi nhận hàng (COD)</div>
                                <div class="payment-method-desc">Thanh toán bằng tiền mặt khi nhận hàng</div>
                            </div>
                            <div class="payment-method-logo cod-logo">
                                <i class="fas fa-money-bill-wave"></i>
                            </div>
                        </label>
                    </div>

                    <button type="submit" class="place-order-btn">
                        <i class="fas fa-lock"></i>
                        Đặt hàng ngay
                        <i class="fas fa-arrow-right"></i>
                    </button>

                    <div class="security-badge">
                        <i class="fas fa-shield-alt"></i>
                        Thông tin của bạn được bảo mật an toàn
                    </div>
                </form>
            </div>

            <div class="order-summary">
                <div class="summary-header">
                    <h2><i class="fas fa-receipt"></i> Đơn hàng</h2>
                    <span class="item-count"><%= cartItems.size() %> sản phẩm</span>
                </div>

                <div class="summary-items">
                    <% for (Map<String, Object> item : cartItems) { %>
                    <div class="summary-item">
                        <div class="item-name"><%= item.get("bookname") %></div>
                        <div class="item-details">
                            <span><i class="fas fa-feather-alt"></i> <%= item.get("author") %></span>
                            <span>x<%= item.get("quantity") %></span>
                        </div>
                        <div style="text-align:right; color:#667eea; font-weight:700; margin-top:8px;">
                            <%= currencyVN.format((Double)item.get("subtotal")) %>
                        </div>
                    </div>
                    <% } %>
                </div>

                <div class="price-breakdown">
                    <div class="price-row">
                        <span>Tạm tính:</span>
                        <span><%= currencyVN.format(total) %></span>
                    </div>
                    <div class="price-row">
                        <span><i class="fas fa-truck"></i> Phí vận chuyển:</span>
                        <span style="color:#4caf50;">Miễn phí</span>
                    </div>
                    <div class="price-row total">
                        <span>Tổng cộng:</span>
                        <span><%= currencyVN.format(total) %></span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function selectPaymentMethod(method, element) {
            document.querySelectorAll('.payment-method-item').forEach(item => {
                item.classList.remove('selected');
            });
            element.classList.add('selected');
        }

        function validateForm() {
            const form = document.getElementById('checkoutForm');
            const paymentMethod = form.querySelector('input[name="paymentMethod"]:checked').value;
            
            // ✅ Set action based on payment method
            if (paymentMethod === 'vnpay') {
                form.action = 'VNPayServlet';
            } else {
                form.action = 'ProcessOrderServlet';
            }
            
            // ✅ Validate phone
            const phone = document.getElementById('phone').value;
            const phoneRegex = /^[0-9]{10}$/;
            
            if (!phoneRegex.test(phone)) {
                document.getElementById('phoneError').innerHTML = '<i class="fas fa-exclamation-circle"></i> Số điện thoại phải gồm 10 chữ số';
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>