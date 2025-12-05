<%@ page import="dao.CartDAO" %>
<%@ page import="entity.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="utils.LanguageHelper" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    CartDAO cartDAO = new CartDAO();
    List<CartItem> cartItems = cartDAO.getCartItems(userEmail);

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= LanguageHelper.getText(request, "cart.title") %> - <%= LanguageHelper.getText(request, "brand.name") %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="CSS/style.css">
    <style>
        /* CSS giữ nguyên */
        body { background: #f5f5f5; }
        .cart-container { max-width: 1200px; margin: 40px auto; padding: 0 15px; min-height: 60vh; }
        .cart-header { background: linear-gradient(135deg, #2563eb 0%, #1d4edb 100%); padding: 25px 30px; border-radius: 12px; color: white; display: flex; align-items: center; gap: 15px; margin-bottom: 20px; }
        .cart-item { background: white; border-radius: 10px; padding: 20px; margin-bottom: 15px; display: flex; align-items: center; gap: 15px; border: 1px solid #eee; transition: all 0.3s; }
        .cart-item:hover { box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .quantity-control { display: flex; align-items: center; border: 1px solid #ddd; border-radius: 5px; }
        .quantity-btn { width: 30px; height: 30px; border: none; background: #f8f9fa; cursor: pointer; }
        .quantity-input { width: 40px; text-align: center; border: none; font-weight: bold; }
        .item-price { color: #2563eb; font-weight: 600; }
        .item-subtotal { color: #dc2626; font-weight: 700; }
        .btn-remove { color: #ef4444; border: none; background: none; font-size: 1.2rem; cursor: pointer; }
        
        .loading-overlay {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(255,255,255,0.7); z-index: 10; display: none;
            justify-content: center; align-items: center;
        }
        .cart-item.processing .loading-overlay { display: flex; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="cart-container">
        <div class="cart-header">
            <i class="fas fa-shopping-cart" style="font-size: 2rem;"></i>
            <h2 class="m-0 flex-grow-1"><%= LanguageHelper.getText(request, "cart.title") %></h2>
            <span class="badge bg-white text-primary fs-6">
                <%= String.format(LanguageHelper.getText(request, "cart.items.count"), cartItems.size()) %>
            </span>
        </div>

        <% if (cartItems == null || cartItems.isEmpty()) { %>
            <div class="text-center p-5 bg-white rounded shadow-sm">
                <i class="fas fa-shopping-basket mb-3 text-muted" style="font-size: 4rem;"></i>
                <h3><%= LanguageHelper.getText(request, "cart.empty") %></h3>
                <a href="categories.jsp" class="btn btn-primary mt-3"><%= LanguageHelper.getText(request, "book.view.books") %></a>
            </div>
        <% } else { %>
            <div class="row">
                <div class="col-lg-9">
                    <div class="bg-white p-3 rounded shadow-sm mb-3">
                        <div class="d-flex align-items-center mb-3 pb-2 border-bottom">
                            <input type="checkbox" id="selectAll" class="form-check-input me-3" style="width: 20px; height: 20px;">
                            <label for="selectAll" class="fw-bold cursor-pointer"><%= LanguageHelper.getText(request, "cart.select.all") %></label>
                        </div>

                        <% for (CartItem item : cartItems) { 
                            double priceVND = item.getPrice() * 300; 
                            double subtotal = priceVND * item.getQuantity();
                            String imgUrl = (item.getImage() != null && !item.getImage().isEmpty()) ? item.getImage() : "images/default-book.jpg";
                        %>
                        <div class="cart-item position-relative" 
                             id="item-<%= item.getBookId() %>"
                             data-id="<%= item.getBookId() %>"
                             data-price="<%= priceVND %>">
                            
                            <div class="loading-overlay"><div class="spinner-border text-primary" role="status"></div></div>

                            <input type="checkbox" class="item-select form-check-input" style="width: 20px; height: 20px;">
                            
                            <img src="<%= imgUrl %>" alt="<%= item.getBookName() %>" style="width: 80px; height: 120px; object-fit: cover; border-radius: 5px;">
                            
                            <div class="flex-grow-1">
                                <h5 class="mb-1 text-truncate" style="max-width: 300px;"><%= item.getBookName() %></h5>
                                <p class="text-muted mb-1"><small><%= LanguageHelper.getText(request, "book.author") %>: <%= item.getAuthor() %></small></p>
                                <div class="item-price"><%= currencyVN.format(priceVND) %></div>
                            </div>

                            <div class="quantity-control">
                                <button class="quantity-btn btn-decrease" onclick="updateQuantity(<%= item.getBookId() %>, -1)">-</button>
                                <input type="text" class="quantity-input" value="<%= item.getQuantity() %>" readonly>
                                <button class="quantity-btn btn-increase" onclick="updateQuantity(<%= item.getBookId() %>, 1)">+</button>
                            </div>

                            <div class="item-subtotal text-end" style="min-width: 120px;">
                                <%= currencyVN.format(subtotal) %>
                            </div>

                            <button class="btn-remove ms-3" onclick="removeItem(<%= item.getBookId() %>)">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-3">
                    <div class="bg-white p-4 rounded shadow-sm position-sticky" style="top: 20px;">
                        <h5 class="border-bottom pb-3 mb-3"><%= LanguageHelper.getText(request, "cart.checkout") %></h5>
                        <div class="d-flex justify-content-between mb-3">
                            <span class="text-muted"><%= LanguageHelper.getText(request, "cart.selected.count") %></span>
                            <span class="fw-bold" id="selectedCount">0</span>
                        </div>
                        <div class="d-flex justify-content-between mb-4">
                            <span class="text-muted"><%= LanguageHelper.getText(request, "cart.total") %>:</span>
                            <span class="fw-bold text-danger fs-4" id="totalAmount">0 ₫</span>
                        </div>
                        
                        <form action="checkout.jsp" method="POST" id="checkoutForm">
                            <input type="hidden" name="selectedItems" id="selectedItemsInput">
                            <input type="hidden" name="totalAmount" id="totalAmountInput">
                            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold" id="btnCheckout" disabled>
                                <%= LanguageHelper.getText(request, "cart.checkout") %>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

        // 1. Cập nhật số lượng bằng AJAX (Giữ nguyên logic)
        function updateQuantity(bookId, change) {
            const itemRow = document.getElementById('item-' + bookId);
            const input = itemRow.querySelector('.quantity-input');
            const currentQty = parseInt(input.value);
            const newQty = currentQty + change;

            if (newQty < 1) return;

            itemRow.classList.add('processing');

            const params = new URLSearchParams();
            params.append('cartItemId', bookId);
            params.append('quantity', newQty);

            fetch('UpdateCartServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                itemRow.classList.remove('processing');
                
                if (data.status === 'success') {
                    input.value = newQty;
                    const price = parseFloat(itemRow.dataset.price);
                    const subtotal = price * newQty;
                    itemRow.querySelector('.item-subtotal').textContent = currencyFormatter.format(subtotal);
                    
                    calculateTotal();
                } else {
                    // Dùng key lỗi chung
                    Swal.fire({ icon: 'warning', title: '<%= LanguageHelper.getText(request, "error.title") %>', text: data.message });
                }
            })
            .catch(err => {
                itemRow.classList.remove('processing');
                // Dùng key lỗi kết nối
                Swal.fire({ icon: 'error', title: '<%= LanguageHelper.getText(request, "error.title") %>', text: '<%= LanguageHelper.getText(request, "messages.msg.error.connection") %>' });
            });
        }

        // 2. Xóa sản phẩm
        function removeItem(bookId) {
            Swal.fire({
                title: '<%= LanguageHelper.getText(request, "btn.delete") %> <%= LanguageHelper.getText(request, "cart.title") %>?',
                text: "<%= LanguageHelper.getText(request, "cart.delete.text") %>", // Giả định key mới
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: '<%= LanguageHelper.getText(request, "btn.delete") %>',
                cancelButtonText: '<%= LanguageHelper.getText(request, "btn.cancel") %>'
            }).then((result) => {
                if (result.isConfirmed) {
                    const params = new URLSearchParams();
                    params.append('cartItemId', bookId);
                    
                    fetch('RemoveFromCartServlet', {
                        method: 'POST',
                        body: params
                    }).then(() => location.reload()); 
                }
            })
        }

        // 3. Logic Checkbox & Tính Tổng (Giữ nguyên logic JS tính toán)
        const checkboxes = document.querySelectorAll('.item-select');
        const selectAll = document.getElementById('selectAll');

        function calculateTotal() {
            let total = 0;
            let count = 0;
            let selectedItems = [];

            checkboxes.forEach(cb => {
                if (cb.checked) {
                    const itemRow = cb.closest('.cart-item');
                    const bookId = itemRow.dataset.id;
                    const price = parseFloat(itemRow.dataset.price); 
                    const quantity = parseInt(itemRow.querySelector('.quantity-input').value);
                    const subtotal = price * quantity;
                    
                    const bookname = itemRow.querySelector('h5').textContent;
                    const author = itemRow.querySelector('p small').textContent.replace('<%= LanguageHelper.getText(request, "messages.book.author") %>: ', ''); // Localize this!

                    total += subtotal;
                    count++;
                    
                    selectedItems.push({
                        bookId: bookId,
                        bookname: bookname,
                        author: author,
                        quantity: quantity,
                        subtotal: subtotal
                    });
                }
            });

            document.getElementById('selectedCount').textContent = count;
            document.getElementById('totalAmount').textContent = currencyFormatter.format(total);
            
            document.getElementById('selectedItemsInput').value = JSON.stringify(selectedItems);
            document.getElementById('totalAmountInput').value = total;
            
            document.getElementById('btnCheckout').disabled = count === 0;
        }

        checkboxes.forEach(cb => cb.addEventListener('change', () => {
            const allChecked = Array.from(checkboxes).every(c => c.checked);
            if(selectAll) selectAll.checked = allChecked;
            calculateTotal();
        }));

        if(selectAll) {
            selectAll.addEventListener('change', function() {
                checkboxes.forEach(cb => cb.checked = this.checked);
                calculateTotal();
            });
        }
        
        // Initial calculation on load (after DOM is ready)
        document.addEventListener('DOMContentLoaded', calculateTotal);
    </script>
    <jsp:include page="footer.jsp" />
</body>
</html>