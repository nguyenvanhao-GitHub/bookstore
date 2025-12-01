<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, String>> cartItems = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8",
                "root", ""
        );

        String sql = "SELECT book_id, bookname, author, price, image, quantity, created_at "
                + "FROM cart WHERE user_email = ? ORDER BY created_at DESC";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, userEmail);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("book_id", rs.getString("book_id"));
            item.put("bookname", rs.getString("bookname"));
            item.put("author", rs.getString("author"));
            item.put("price", rs.getString("price"));
            item.put("image", rs.getString("image"));
            item.put("quantity", rs.getString("quantity"));

            Timestamp timestamp = rs.getTimestamp("created_at");
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
            item.put("created_at", sdf.format(timestamp));

            cartItems.add(item);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException ignored) {
        }
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException ignored) {
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException ignored) {
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <title>Giỏ Hàng - BookStore</title>
        <style>
            /* ===== CART PAGE STYLES ===== */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f5f5f5;
    color: #333;
    line-height: 1.6;
}

/* Cart Container */
.cart-container {
    max-width: 1200px;
    margin: 20px auto;
    padding: 0 15px;
    min-height: calc(100vh - 200px);
}

/* Cart Header */
.cart-header {
    background: linear-gradient(135deg, #ee4d2d 0%, #ff6b46 100%);
    padding: 25px 30px;
    border-radius: 12px;
    color: white;
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
    box-shadow: 0 4px 12px rgba(238, 77, 45, 0.3);
}

.cart-header i {
    font-size: 32px;
}

.cart-header h2 {
    font-size: 28px;
    font-weight: 600;
    flex: 1;
}

.cart-count {
    background: rgba(255, 255, 255, 0.2);
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 500;
}

/* Empty Cart */
.empty-cart {
    background: white;
    padding: 60px 30px;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.empty-icon {
    font-size: 80px;
    color: #ddd;
    margin-bottom: 20px;
}

.empty-text {
    font-size: 24px;
    font-weight: 600;
    color: #555;
    margin-bottom: 10px;
}

.empty-subtext {
    font-size: 16px;
    color: #888;
    margin-bottom: 30px;
}

.btn-shop-now {
    display: inline-block;
    background: linear-gradient(135deg, #ee4d2d 0%, #ff6b46 100%);
    color: white;
    padding: 14px 32px;
    border-radius: 8px;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.3s ease;
    box-shadow: 0 4px 12px rgba(238, 77, 45, 0.3);
}

.btn-shop-now:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(238, 77, 45, 0.4);
}

.btn-shop-now i {
    margin-right: 8px;
}

/* Cart Items Container */
.cart-items {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

/* Select All Container */
.select-all-container {
    padding: 15px 20px;
    background: #f8f9fa;
    border-radius: 8px;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.select-all-container label {
    font-weight: 600;
    color: #333;
    cursor: pointer;
}

/* Table Header - FLEXBOX SIMPLE */
.table-header {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    background: #f8f9fa;
    border-radius: 8px;
    font-weight: 600;
    color: #555;
    margin-bottom: 15px;
    gap: 15px;
}

.table-header > div:nth-child(1) {
    width: 40px;
    text-align: center;
}

.table-header > div:nth-child(2) {
    width: 100px;
    text-align: center;
}

.table-header > div:nth-child(3) {
    flex: 1;
    min-width: 200px;
}

.table-header > div:nth-child(4) {
    width: 130px;
    text-align: center;
}

.table-header > div:nth-child(5) {
    width: 180px;
    text-align: center;
}

.table-header > div:nth-child(6) {
    width: 130px;
    text-align: center;
}

.table-header > div:nth-child(7) {
    width: 130px;
    text-align: center;
}

/* Cart Item - FLEXBOX SIMPLE */
.cart-item {
    display: flex;
    align-items: center;
    padding: 20px;
    border: 2px solid #f0f0f0;
    border-radius: 10px;
    margin-bottom: 15px;
    background: white;
    transition: all 0.3s ease;
    gap: 15px;
}

.cart-item:hover {
    border-color: #ee4d2d;
    box-shadow: 0 4px 12px rgba(238, 77, 45, 0.1);
}

/* Checkbox */
.item-checkbox,
.item-select {
    width: 20px;
    height: 20px;
    cursor: pointer;
    accent-color: #ee4d2d;
    flex-shrink: 0;
}

.cart-item > .item-select {
    width: 40px;
    text-align: center;
    display: flex;
    justify-content: center;
}

/* Item Image */
.item-image {
    width: 100px;
    height: 130px;
    object-fit: cover;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    transition: transform 0.3s ease;
    flex-shrink: 0;
}

.item-image:hover {
    transform: scale(1.05);
}

/* Item Info */
.item-info {
    flex: 1;
    min-width: 200px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.item-name {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.item-author {
    font-size: 14px;
    color: #666;
    display: flex;
    align-items: center;
    gap: 6px;
}

.item-author i {
    color: #ee4d2d;
}

/* Item Price */
.item-price {
    width: 130px;
    font-size: 18px;
    font-weight: 600;
    color: #ee4d2d;
    text-align: center;
    flex-shrink: 0;
}

/* Quantity Control */
.quantity-form {
    width: 180px;
    margin: 0;
    display: flex;
    justify-content: center;
    flex-shrink: 0;
}

.quantity-control {
    display: flex;
    align-items: center;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    overflow: hidden;
}

.quantity-btn {
    width: 36px;
    height: 36px;
    border: none;
    background: #f5f5f5;
    color: #333;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
}

.quantity-btn:hover {
    background: #ee4d2d;
    color: white;
}

.quantity-btn:active {
    transform: scale(0.95);
}

.quantity-input {
    width: 50px;
    height: 36px;
    border: none;
    text-align: center;
    font-size: 16px;
    font-weight: 600;
    background: white;
}

.quantity-input:focus {
    outline: none;
}

/* Item Subtotal */
.item-subtotal {
    width: 130px;
    font-size: 18px;
    font-weight: 700;
    color: #ee4d2d;
    text-align: center;
    flex-shrink: 0;
}

/* Item Actions */
.item-actions {
    width: 130px;
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-shrink: 0;
}

.action-btn {
    width: 40px;
    height: 40px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
}

.btn-update {
    background: #4CAF50;
    color: white;
}

.btn-update:hover {
    background: #45a049;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(76, 175, 80, 0.3);
}

.btn-remove {
    background: #f44336;
    color: white;
}

.btn-remove:hover {
    background: #da190b;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(244, 67, 54, 0.3);
}

/* Cart Bottom */
.cart-bottom {
    background: white;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    position: sticky;
    bottom: 20px;
    z-index: 100;
}

.bottom-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
}

.bottom-left {
    display: flex;
    align-items: center;
    gap: 30px;
}

.select-all-bottom {
    display: flex;
    align-items: center;
    gap: 10px;
}

.select-all-bottom label {
    font-weight: 600;
    cursor: pointer;
}

.delete-selected {
    color: #666;
    cursor: pointer;
    font-weight: 500;
    transition: color 0.3s ease;
    display: flex;
    align-items: center;
    gap: 8px;
}

.delete-selected:hover {
    color: #f44336;
}

/* Bottom Right */
.bottom-right {
    display: flex;
    align-items: center;
    gap: 20px;
}

.total-section {
    text-align: right;
}

.total-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 5px;
}

.selected-count {
    color: #ee4d2d;
    font-weight: 600;
}

.total-amount {
    font-size: 28px;
    font-weight: 700;
    color: #ee4d2d;
}

/* Checkout Button */
.checkout-btn {
    background: linear-gradient(135deg, #ee4d2d 0%, #ff6b46 100%);
    color: white;
    border: none;
    padding: 16px 40px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 12px rgba(238, 77, 45, 0.3);
    white-space: nowrap;
}

.checkout-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(238, 77, 45, 0.4);
}

.checkout-btn:disabled {
    background: #ccc;
    cursor: not-allowed;
    box-shadow: none;
}

/* ===== RESPONSIVE DESIGN ===== */

/* Tablet */
@media (max-width: 1024px) {
    .cart-container {
        padding: 0 10px;
    }

    .table-header > div:nth-child(3) {
        min-width: 150px;
    }

    .table-header > div:nth-child(4),
    .table-header > div:nth-child(6) {
        width: 110px;
    }

    .table-header > div:nth-child(5) {
        width: 150px;
    }

    .table-header > div:nth-child(7) {
        width: 110px;
    }

    .item-info {
        min-width: 150px;
    }

    .item-price,
    .item-subtotal {
        width: 110px;
        font-size: 16px;
    }

    .quantity-form {
        width: 150px;
    }

    .item-actions {
        width: 110px;
    }

    .total-amount {
        font-size: 24px;
    }

    .checkout-btn {
        padding: 14px 32px;
        font-size: 15px;
    }
}

/* Mobile */
@media (max-width: 768px) {
    .cart-header {
        padding: 20px;
        margin-top: 80px;
        flex-wrap: wrap;
    }

    .cart-header h2 {
        font-size: 22px;
    }

    .cart-header i {
        font-size: 28px;
    }

    .table-header {
        display: none;
    }

    .cart-item {
        flex-direction: column;
        align-items: stretch;
        gap: 15px;
    }

    .cart-item > .item-select {
        width: auto;
        justify-content: flex-start;
    }

    .item-image {
        width: 150px;
        height: 180px;
        align-self: center;
    }

    .item-info {
        min-width: auto;
        align-self: center;
    }

    .item-price,
    .item-subtotal {
        width: auto;
        font-size: 18px;
    }

    .item-price::before {
        content: 'Đơn giá: ';
        font-weight: 400;
        color: #666;
    }

    .item-subtotal::before {
        content: 'Thành tiền: ';
        font-weight: 400;
        color: #666;
    }

    .quantity-form {
        width: auto;
    }

    .quantity-control {
        margin: 0 auto;
    }

    .item-actions {
        width: auto;
        gap: 15px;
    }

    .action-btn {
        width: 45px;
        height: 45px;
    }

    .bottom-content {
        flex-direction: column;
        gap: 15px;
    }

    .bottom-left {
        width: 100%;
        justify-content: space-between;
    }

    .bottom-right {
        width: 100%;
        flex-direction: column;
        gap: 15px;
    }

    .total-section {
        width: 100%;
        text-align: center;
    }

    .checkout-btn {
        width: 100%;
        padding: 16px;
    }
}

/* Mobile Portrait */
@media (max-width: 480px) {
    .cart-container {
        margin: 10px auto;
    }

    .cart-header {
        padding: 15px;
        border-radius: 8px;
    }

    .cart-header h2 {
        font-size: 20px;
        width: 100%;
    }

    .cart-count {
        padding: 6px 12px;
        font-size: 13px;
    }

    .cart-items {
        padding: 15px;
        border-radius: 8px;
    }

    .select-all-container {
        padding: 12px 15px;
        font-size: 14px;
    }

    .cart-item {
        padding: 15px;
        gap: 12px;
    }

    .item-image {
        width: 120px;
        height: 150px;
    }

    .item-name {
        font-size: 14px;
    }

    .item-author {
        font-size: 13px;
    }

    .item-price,
    .item-subtotal {
        font-size: 16px;
    }

    .quantity-btn {
        width: 34px;
        height: 34px;
    }

    .quantity-input {
        width: 45px;
        height: 34px;
        font-size: 15px;
    }

    .action-btn {
        width: 42px;
        height: 42px;
        font-size: 15px;
    }

    .cart-bottom {
        padding: 15px;
        bottom: 10px;
        border-radius: 8px;
    }

    .bottom-left {
        font-size: 14px;
        gap: 15px;
    }

    .total-label {
        font-size: 13px;
    }

    .total-amount {
        font-size: 22px;
    }

    .checkout-btn {
        padding: 14px;
        font-size: 15px;
    }

    .empty-cart {
        padding: 40px 20px;
    }

    .empty-icon {
        font-size: 60px;
    }

    .empty-text {
        font-size: 20px;
    }

    .empty-subtext {
        font-size: 14px;
    }

    .btn-shop-now {
        padding: 12px 24px;
        font-size: 14px;
    }
}

/* Very Small Devices */
@media (max-width: 360px) {
    .cart-header h2 {
        font-size: 18px;
    }

    .item-image {
        width: 100px;
        height: 130px;
    }

    .item-name {
        font-size: 13px;
    }

    .total-amount {
        font-size: 20px;
    }
}

/* Print Styles */
@media print {
    .cart-bottom,
    .item-actions,
    .select-all-container,
    .action-btn,
    .delete-selected {
        display: none !important;
    }

    .cart-item {
        break-inside: avoid;
    }
}
        </style>
    </head>
    <body>
        <jsp:include page="header.jsp" />

        <div class="cart-container">
            <div class="cart-header">
                <i class="fas fa-shopping-cart"></i>
                <h2>Giỏ Hàng Của Bạn</h2>
                <span class="cart-count"><%= cartItems.size()%> sản phẩm</span>
            </div>

            <% if (cartItems.isEmpty()) { %>
            <div class="empty-cart">
                <div class="empty-icon"><i class="fas fa-shopping-cart"></i></div>
                <div class="empty-text">Giỏ hàng trống</div>
                <div class="empty-subtext">Hãy thêm sản phẩm vào giỏ hàng để mua sắm nhé!</div>
                <a href="index.jsp" class="btn-shop-now">
                    <i class="fas fa-shopping-bag"></i> Mua sắm ngay
                </a>
            </div>
            <% } else {%>
            <div class="cart-items">
                <div class="select-all-container">
                    <input type="checkbox" id="selectAll" class="item-checkbox">
                    <label for="selectAll">Chọn tất cả (<%= cartItems.size()%>)</label>
                </div>

                <div class="table-header">
                    <div></div>
                    <div></div>
                    <div>Sản phẩm</div>
                    <div>Đơn giá</div>
                    <div>Số lượng</div>
                    <div>Thành tiền</div>
                    <div>Thao tác</div>
                </div>

                <%
                    for (Map<String, String> item : cartItems) {
                        String bookId = item.get("book_id");
                        double price = Double.parseDouble(item.get("price"));
                        int quantity = Integer.parseInt(item.get("quantity"));
                        double priceVND = price * 300;
                        double subtotal = priceVND * quantity;
                %>
                <div class="cart-item" 
                     data-book-id="<%= bookId%>"
                     data-price-per-unit="<%= priceVND%>"
                     data-price="<%= subtotal%>"
                     data-bookname="<%= item.get("bookname")%>"
                     data-author="<%= item.get("author")%>">

                    <input type="checkbox" class="item-select" 
                           data-id="<%= bookId%>" 
                           data-price="<%= subtotal%>">

                    <img src="<%= item.get("image")%>" class="item-image" alt="<%= item.get("bookname")%>">

                    <div class="item-info">
                        <div class="item-name"><%= item.get("bookname")%></div>
                        <div class="item-author">
                            <i class="fas fa-user"></i> <%= item.get("author")%>
                        </div>
                    </div>

                    <div class="item-price" data-price="<%= priceVND%>"><%= currencyVN.format(priceVND)%></div>

                    <form action="UpdateCartServlet" method="post" class="quantity-form">
                        <input type="hidden" name="cartItemId" value="<%= bookId%>">
                        <div class="quantity-control">
                            <button type="button" class="quantity-btn btn-decrease">
                                <i class="fas fa-minus"></i>
                            </button>
                            <input type="number" name="quantity" value="<%= quantity%>" 
                                   min="1" max="99" class="quantity-input" readonly>
                            <button type="button" class="quantity-btn btn-increase">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                    </form>

                    <div class="item-subtotal"><%= currencyVN.format(subtotal)%></div>

                    <div class="item-actions">
                        <form action="UpdateCartServlet" method="post" style="display: inline;">
                            <input type="hidden" name="cartItemId" value="<%= bookId%>">
                            <input type="hidden" name="quantity" class="hidden-quantity" value="<%= quantity%>">
                            <button type="submit" class="action-btn btn-update">
                                <i class="fas fa-sync"></i>
                            </button>
                        </form>

                        <form action="RemoveFromCartServlet" method="post" class="delete-form" style="display: inline;">
                            <input type="hidden" name="cartItemId" value="<%= bookId%>">
                            <button type="button" class="action-btn btn-remove">
                                <i class="fas fa-trash"></i>
                            </button>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="cart-bottom">
                <div class="bottom-content">
                    <div class="bottom-left">
                        <div class="select-all-bottom">
                            <input type="checkbox" id="selectAllBottom" class="item-checkbox">
                            <label for="selectAllBottom">Chọn tất cả</label>
                        </div>
                        <span class="delete-selected">
                            <i class="fas fa-trash"></i> Xóa
                        </span>
                    </div>

                    <div class="bottom-right">
                        <div class="total-section">
                            <div class="total-label">Tổng thanh toán (<span class="selected-count">0</span> sản phẩm):</div>
                            <div class="total-amount">0₫</div>
                        </div>

                        <form action="checkout.jsp" method="post" id="checkoutForm">
                            <input type="hidden" name="selectedItems" id="selectedItems">
                            <input type="hidden" name="totalAmount" id="totalAmount">
                            <button type="submit" class="checkout-btn" disabled>Mua hàng</button>
                        </form>
                    </div>
                </div>
            </div>
            <% }%>
        </div>

        <script>
            // Quantity control
            document.querySelectorAll('.btn-decrease').forEach(btn => {
                btn.addEventListener('click', function () {
                    const cartItem = this.closest('.cart-item');
                    const input = this.closest('.quantity-control').querySelector('.quantity-input');
                    const hiddenInput = cartItem.querySelector('.hidden-quantity');

                    if (input.value > 1) {
                        input.value = parseInt(input.value) - 1;
                        hiddenInput.value = input.value;
                        updateSubtotal(cartItem);
                    }
                });
            });

            document.querySelectorAll('.btn-increase').forEach(btn => {
                btn.addEventListener('click', function () {
                    const cartItem = this.closest('.cart-item');
                    const input = this.closest('.quantity-control').querySelector('.quantity-input');
                    const hiddenInput = cartItem.querySelector('.hidden-quantity');

                    if (input.value < 99) {
                        input.value = parseInt(input.value) + 1;
                        hiddenInput.value = input.value;
                        updateSubtotal(cartItem);
                    }
                });
            });

            function updateSubtotal(cartItem) {
                const pricePerUnit = parseFloat(cartItem.dataset.pricePerUnit);
                const quantity = parseInt(cartItem.querySelector('.quantity-input').value);
                const subtotal = pricePerUnit * quantity;

                // Update subtotal display
                const subtotalElement = cartItem.querySelector('.item-subtotal');
                subtotalElement.textContent = new Intl.NumberFormat('vi-VN', {
                    style: 'currency',
                    currency: 'VND'
                }).format(subtotal);

                // Update data attributes
                cartItem.dataset.price = subtotal;
                cartItem.querySelector('.item-select').dataset.price = subtotal;

                // Update total if item is selected
                if (cartItem.querySelector('.item-select').checked) {
                    updateTotal();
                }
            }

            // Select all functionality
            const selectAll = document.getElementById('selectAll');
            const selectAllBottom = document.getElementById('selectAllBottom');
            const itemSelects = document.querySelectorAll('.item-select');

            function syncSelectAll() {
                const allChecked = Array.from(itemSelects).every(cb => cb.checked);
                selectAll.checked = allChecked;
                selectAllBottom.checked = allChecked;
                updateTotal();
            }

            selectAll.addEventListener('change', function () {
                itemSelects.forEach(cb => cb.checked = this.checked);
                selectAllBottom.checked = this.checked;
                updateTotal();
            });

            selectAllBottom.addEventListener('change', function () {
                itemSelects.forEach(cb => cb.checked = this.checked);
                selectAll.checked = this.checked;
                updateTotal();
            });

            itemSelects.forEach(cb => {
                cb.addEventListener('change', syncSelectAll);
            });

            // Update total - FIXED VERSION
            function updateTotal() {
                let total = 0;
                let count = 0;
                const selectedData = [];

                itemSelects.forEach(cb => {
                    if (cb.checked) {
                        const cartItem = cb.closest('.cart-item');
                        const price = parseFloat(cartItem.dataset.price);
                        const bookId = cartItem.dataset.bookId;
                        const quantity = parseInt(cartItem.querySelector('.quantity-input').value);
                        const bookname = cartItem.dataset.bookname;
                        const author = cartItem.dataset.author;

                        total += price;
                        count++;

                        // Store detailed item data
                        selectedData.push({
                            bookId: bookId,
                            quantity: quantity,
                            bookname: bookname,
                            author: author,
                            subtotal: price
                        });
                    }
                });

                // Display total
                document.querySelector('.total-amount').textContent =
                        new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(total);
                document.querySelector('.selected-count').textContent = count;

                // Store as JSON for checkout page
                document.getElementById('selectedItems').value = JSON.stringify(selectedData);
                document.getElementById('totalAmount').value = total;

                const checkoutBtn = document.querySelector('.checkout-btn');
                checkoutBtn.disabled = count === 0;
            }

            // Delete confirmation
            document.querySelectorAll('.btn-remove').forEach(btn => {
                btn.addEventListener('click', function () {
                    const form = this.closest('.delete-form');
                    Swal.fire({
                        title: 'Xác nhận xóa?',
                        text: 'Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#ee4d2d',
                        cancelButtonColor: '#666',
                        confirmButtonText: 'Xóa',
                        cancelButtonText: 'Hủy'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            form.submit();
                        }
                    });
                });
            });

            // Delete selected items
            document.querySelector('.delete-selected').addEventListener('click', function () {
                const selected = Array.from(itemSelects).filter(cb => cb.checked);
                if (selected.length === 0) {
                    Swal.fire({
                        icon: 'info',
                        title: 'Chưa chọn sản phẩm',
                        text: 'Vui lòng chọn ít nhất một sản phẩm để xóa',
                        confirmButtonColor: '#ee4d2d'
                    });
                    return;
                }

                Swal.fire({
                    title: 'Xác nhận xóa?',
                    text: `Bạn có chắc muốn xóa ${selected.length} sản phẩm đã chọn?`,
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#ee4d2d',
                    cancelButtonColor: '#666',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        selected.forEach(cb => {
                            cb.closest('.cart-item').querySelector('.delete-form').submit();
                        });
                    }
                });
            });

            // Checkout validation
            document.getElementById('checkoutForm').addEventListener('submit', function (e) {
                const selectedItems = document.getElementById('selectedItems').value;
                if (!selectedItems || selectedItems === '[]') {
                    e.preventDefault();
                    Swal.fire({
                        icon: 'info',
                        title: 'Chưa chọn sản phẩm',
                        text: 'Vui lòng chọn ít nhất một sản phẩm để thanh toán',
                        confirmButtonColor: '#ee4d2d'
                    });
                }
            });
        </script>

        <jsp:include page="footer.jsp" />
    </body>
</html>