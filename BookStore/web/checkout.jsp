<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.google.gson.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Kiểm tra đăng nhập
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Nhận dữ liệu từ Cart
    String selectedItemsJSON = request.getParameter("selectedItems");
    String totalAmountStr = request.getParameter("totalAmount");

    List<Map<String, Object>> displayItems = new ArrayList<>();
    double total = 0.0;
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

    try {
        if (selectedItemsJSON != null && !selectedItemsJSON.trim().isEmpty() && !selectedItemsJSON.equals("[]")) {
            Gson gson = new Gson();
            JsonArray jsonArray = gson.fromJson(selectedItemsJSON, JsonArray.class);

            for (JsonElement element : jsonArray) {
                JsonObject jsonItem = element.getAsJsonObject();
                Map<String, Object> item = new HashMap<>();
                
                String bookName = jsonItem.has("bookname") ? jsonItem.get("bookname").getAsString() : "Sản phẩm";
                String author = jsonItem.has("author") ? jsonItem.get("author").getAsString() : "";
                int quantity = jsonItem.has("quantity") ? jsonItem.get("quantity").getAsInt() : 1;
                double subtotal = jsonItem.has("subtotal") ? jsonItem.get("subtotal").getAsDouble() : 0.0;
                
                item.put("bookname", bookName);
                item.put("author", author);
                item.put("quantity", quantity);
                item.put("subtotal", subtotal);
                displayItems.add(item);
            }
            
            if (totalAmountStr != null && !totalAmountStr.isEmpty()) {
                total = Double.parseDouble(totalAmountStr);
            }
        } else {
            response.sendRedirect("cart.jsp");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("cart.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán - BookStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
        .checkout-container { max-width: 1200px; margin: 40px auto; display: grid; grid-template-columns: 1fr 400px; gap: 30px; }
        .card-custom { background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .section-header { font-size: 1.25rem; font-weight: 700; margin-bottom: 20px; color: #333; display: flex; align-items: center; gap: 10px; }
        .section-header i { color: #2563eb; }
        .payment-option { border: 2px solid #eee; border-radius: 10px; padding: 15px; margin-bottom: 15px; cursor: pointer; transition: 0.3s; display: flex; align-items: center; gap: 15px; }
        .payment-option:hover, .payment-option.selected { border-color: #2563eb; background: #f8fbff; }
        .payment-logo { font-size: 24px; width: 50px; text-align: center; }
        .checkout-btn { width: 100%; padding: 15px; background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; border: none; border-radius: 10px; font-weight: 700; font-size: 1.1rem; margin-top: 20px; transition: 0.3s; }
        .checkout-btn:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(37, 99, 235, 0.3); }
        .summary-item { display: flex; justify-content: space-between; margin-bottom: 15px; font-size: 0.95rem; }
        .total-row { border-top: 2px dashed #eee; margin-top: 20px; padding-top: 20px; font-size: 1.2rem; font-weight: 700; color: #dc2626; display: flex; justify-content: space-between; }
    </style>
</head>
<body>
    <div class="checkout-container">
        <div class="card-custom">
            <div class="section-header"><i class="fas fa-map-marker-alt"></i> Thông tin giao hàng</div>
            
            <form id="checkoutForm" method="post" onsubmit="return validateForm()">
                <input type="hidden" name="total" value="<%= total %>">
                <% 
                    StringBuilder books = new StringBuilder();
                    for(Map<String, Object> i : displayItems) {
                        books.append(i.get("bookname")).append(" (x").append(i.get("quantity")).append("), ");
                    }
                    String booksStr = books.length() > 2 ? books.substring(0, books.length() - 2) : "";
                %>
                <input type="hidden" name="books" value="<%= booksStr %>">

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Họ và tên</label>
                        <input type="text" class="form-control" name="fullName" value="<%= userName %>" readonly>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" name="email" value="<%= userEmail %>" readonly>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="phone" name="phone" placeholder="Ví dụ: 0912345678" required>
                        <small class="text-danger" id="phoneError"></small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Thành phố <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="city" required>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Quận / Huyện <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="state" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Mã bưu điện</label>
                        <input type="text" class="form-control" name="zipCode" value="700000">
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label">Địa chỉ chi tiết <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="address" rows="2" placeholder="Số nhà, tên đường, phường/xã..." required></textarea>
                </div>

                <div class="section-header"><i class="fas fa-credit-card"></i> Phương thức thanh toán</div>
                
                <div class="payment-option selected" onclick="selectPayment('vnpay', this)">
                    <input type="radio" name="paymentMethod" value="vnpay" checked class="form-check-input">
                    <div class="payment-logo text-primary"><i class="fas fa-qrcode"></i></div>
                    <div>
                        <div class="fw-bold">VNPay QR / ATM / Thẻ quốc tế</div>
                        <small class="text-muted">Thanh toán an toàn qua cổng VNPay</small>
                    </div>
                </div>

                <div class="payment-option" onclick="selectPayment('cod', this)">
                    <input type="radio" name="paymentMethod" value="cod" class="form-check-input">
                    <div class="payment-logo text-success"><i class="fas fa-money-bill-wave"></i></div>
                    <div>
                        <div class="fw-bold">Thanh toán khi nhận hàng (COD)</div>
                        <small class="text-muted">Trả tiền mặt khi giao hàng</small>
                    </div>
                </div>

                <button type="submit" class="checkout-btn">
                    <i class="fas fa-lock me-2"></i> HOÀN TẤT ĐẶT HÀNG
                </button>
            </form>
        </div>

        <div class="card-custom h-100">
            <div class="section-header"><i class="fas fa-shopping-basket"></i> Đơn hàng (<%= displayItems.size() %>)</div>
            
            <div style="max-height: 400px; overflow-y: auto; padding-right: 5px;">
                <% for (Map<String, Object> item : displayItems) { %>
                <div class="summary-item border-bottom pb-2">
                    <div>
                        <div class="fw-bold"><%= item.get("bookname") %></div>
                        <small class="text-muted"><%= item.get("author") %> | x<%= item.get("quantity") %></small>
                    </div>
                    <div class="fw-bold text-primary">
                        <%= currencyVN.format(item.get("subtotal")) %>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="total-row">
                <span>Tổng cộng</span>
                <span><%= currencyVN.format(total) %></span>
            </div>
        </div>
    </div>

    <script>
        function selectPayment(val, el) {
            document.querySelectorAll('.payment-option').forEach(e => e.classList.remove('selected'));
            el.classList.add('selected');
            el.querySelector('input').checked = true;
        }

        function validateForm() {
            const phone = document.getElementById('phone').value;
            const phoneRegex = /^(0[3|5|7|8|9])+([0-9]{8})$/;
            
            if (!phoneRegex.test(phone)) {
                document.getElementById('phoneError').innerText = 'Số điện thoại không hợp lệ (10 số, đầu 03/05/07/08/09)';
                return false;
            }

            const method = document.querySelector('input[name="paymentMethod"]:checked').value;
            const form = document.getElementById('checkoutForm');
            
            if (method === 'vnpay') {
                form.action = 'VNPayServlet';
            } else {
                form.action = 'ProcessOrderServlet';
            }
            return true;
        }
    </script>
</body>
</html>