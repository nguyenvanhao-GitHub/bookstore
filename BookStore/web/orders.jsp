<%@page import="utils.LanguageHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.DecimalFormat, java.util.List, java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="entity.Order" %>

<%
    // 1. Kiểm tra đăng nhập
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Lấy dữ liệu
    DecimalFormat vndFormat = new DecimalFormat("#,###");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = orderDAO.getOrdersByEmail(userEmail);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageHelper.getText(request, "order.management.title") %> - <%= LanguageHelper.getText(request, "brand.name") %></title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="CSS/style.css"> <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        /* CSS giữ nguyên */
        body { background-color: #f8f9fa; }
        .header-section { background: white; padding: 20px 0; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .nav-tabs-custom .nav-link { color: #555; border: none; border-bottom: 2px solid transparent; font-weight: 500; padding: 10px 20px; }
        .nav-tabs-custom .nav-link.active { color: #0d6efd; border-bottom: 2px solid #0d6efd; background: transparent; }
        .nav-tabs-custom { border-bottom: 1px solid #ddd; margin-bottom: 20px; }
        .order-card { background: white; border: none; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); transition: transform 0.2s; }
        .order-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .order-header { padding: 15px 20px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; background-color: #fff; border-radius: 10px 10px 0 0; }
        .order-body { padding: 20px; }
        .order-footer { padding: 15px 20px; background-color: #fbfbfb; border-top: 1px solid #f0f0f0; border-radius: 0 0 10px 10px; display: flex; justify-content: space-between; align-items: center; }
        .book-list-item { font-size: 0.95rem; color: #333; margin-bottom: 5px; display: flex; align-items: flex-start; }
        .book-list-item i { color: #0d6efd; margin-top: 4px; margin-right: 8px; }
        .payment-info { font-size: 0.85rem; color: #666; margin-top: 10px; padding-top: 10px; border-top: 1px dashed #eee; }
        .total-price { font-size: 1.1rem; font-weight: 700; color: #d32f2f; }
        .btn-cancel { border: 1px solid #dc3545; color: #dc3545; background: white; padding: 5px 15px; border-radius: 5px; transition: all 0.3s; font-size: 0.9rem; }
        .btn-cancel:hover { background: #dc3545; color: white; }
    </style>
</head>
<body>

<jsp:include page="header.jsp" />

<div class="header-section">
    <div class="container">
        <h2 class="mb-0"><i class="fas fa-box-open text-primary"></i><%= LanguageHelper.getText(request, "order.management.title")%></h2>
    </div>
</div>

<div class="container" style="min-height: 60vh;">
    <ul class="nav nav-tabs nav-tabs-custom" id="orderTabs" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#all">Tất cả</a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#pending"><%= LanguageHelper.getText(request, "status.pending")%></a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#delivered"><%= LanguageHelper.getText(request, "status.delivered")%></a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#cancelled"><%= LanguageHelper.getText(request, "status.cancelled")%></a></li>
    </ul>

    <div class="orders-container">
        <div class="tab-content">
            <%
                // Khởi tạo StringBuilder cho từng tab (Logic giữ nguyên)
                StringBuilder allTab = new StringBuilder();
                StringBuilder pendingTab = new StringBuilder();
                StringBuilder deliveredTab = new StringBuilder();
                StringBuilder cancelledTab = new StringBuilder();
                
                boolean hasOrder = !orders.isEmpty();

                if (hasOrder) {
                    for (Order o : orders) {
                        String status = o.getStatus();
                        
                        // Xác định màu sắc badge trạng thái
                        String badgeClass = "bg-warning text-dark";
                        String statusText = LanguageHelper.getText(request, "status.pending"); // Mặc định: Chờ xử lý
                        if ("delivered".equalsIgnoreCase(status)) {
                            badgeClass = "bg-success";
                            statusText = LanguageHelper.getText(request, "status.delivered");
                        } else if ("cancelled".equalsIgnoreCase(status)) {
                            badgeClass = "bg-danger";
                            statusText = LanguageHelper.getText(request, "status.cancelled");
                        }

                        // Xử lý danh sách sách (Tách chuỗi từ DB)
                        String booksRaw = o.getBooks();
                        String[] bookList = booksRaw != null ? booksRaw.split(",(?![^()]*\\))") : new String[]{};
                        
                        StringBuilder booksHtml = new StringBuilder();
                        for(String book : bookList) {
                            booksHtml.append("<div class='book-list-item'><i class='fas fa-book-open'></i> <span>").append(book.trim()).append("</span></div>");
                        }

                        // Xử lý Payment Method & Transaction ID
                        String paymentInfo = "";
                        if(o.getPaymentMethod() != null) {
                            paymentInfo = "<div class='payment-info'><i class='far fa-credit-card me-1'></i> " + LanguageHelper.getText(request, "order.payment.method") + ": <strong>" + o.getPaymentMethod() + "</strong>";
                            if(o.getTransactionId() != null && !o.getTransactionId().isEmpty()) {
                                paymentInfo += " | GD: <code class='text-muted'>" + o.getTransactionId() + "</code>";
                            }
                            paymentInfo += "</div>";
                        }

                        // Tạo HTML cho nút Hủy (Chỉ hiện khi Pending)
                        String cancelButton = "";
                        if ("pending".equalsIgnoreCase(status)) {
                            cancelButton = 
                                "<form action='CancelOrderServlet' method='post' onsubmit=\"return confirm('" + LanguageHelper.getText(request, "btn.confirm") + " " + LanguageHelper.getText(request, "btn.cancel.order") + "?');\">" +
                                "  <input type='hidden' name='orderId' value='" + o.getId() + "'>" +
                                "  <button type='submit' class='btn-cancel'><i class='fas fa-times'></i> " + LanguageHelper.getText(request, "btn.cancel.order") + "</button>" +
                                "</form>";
                        }

                        // Tạo Card HTML
                        String cardHtml = String.format(
                            "<div class='order-card'>" +
                            "  <div class='order-header'>" +
                            "    <div><strong>#%s</strong> <span class='text-muted small ms-2'>%s</span></div>" +
                            "    <span class='badge %s'>%s</span>" + // Status Text (localized via code)
                            "  </div>" +
                            "  <div class='order-body'>" +
                            "    %s" + // Danh sách sách
                            "    %s" + // Payment Info
                            "  </div>" +
                            "  <div class='order-footer'>" +
                            "    <div class='total-price'>" + LanguageHelper.getText(request, "order.total.amount") + ": %s₫</div>" +
                            "    %s" + // Nút hủy
                            "  </div>" +
                            "</div>",
                            o.getId(), 
                            dateFormat.format(o.getOrderDate()), 
                            badgeClass, 
                            statusText,
                            booksHtml.toString(),
                            paymentInfo,
                            vndFormat.format(o.getTotalAmount()),
                            cancelButton
                        );

                        // Phân loại vào các tab
                        allTab.append(cardHtml);
                        if ("pending".equalsIgnoreCase(status)) pendingTab.append(cardHtml);
                        else if ("delivered".equalsIgnoreCase(status)) deliveredTab.append(cardHtml);
                        else if ("cancelled".equalsIgnoreCase(status)) cancelledTab.append(cardHtml);
                    }
                }
                
                String emptyState = LanguageHelper.getText(request, "msg.order.none");
                // Cần làm lại empty state để nó là HTML
                String emptyStateHtml = 
                    "<div class='text-center py-5 text-muted'>" +
                    "  <i class='fas fa-box-open fa-3x mb-3 opacity-50'></i>" +
                    "  <p>" + emptyState + "</p>" +
                    "  <a href='categories.jsp' class='btn btn-primary btn-sm'>" + LanguageHelper.getText(request, "book.view.books") + "</a>" +
                    "</div>";
            %>

            <div class="tab-pane fade show active" id="all">
                <%= allTab.length() > 0 ? allTab.toString() : emptyStateHtml %>
            </div>
            <div class="tab-pane fade" id="pending">
                <%= pendingTab.length() > 0 ? pendingTab.toString() : emptyStateHtml %>
            </div>
            <div class="tab-pane fade" id="delivered">
                <%= deliveredTab.length() > 0 ? deliveredTab.toString() : emptyStateHtml %>
            </div>
            <div class="tab-pane fade" id="cancelled">
                <%= cancelledTab.length() > 0 ? cancelledTab.toString() : emptyStateHtml %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Logic Swal.fire giữ nguyên, bạn cần đảm bảo các keys alert đã được định nghĩa trong properties
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('cancelSuccess')) {
        Swal.fire({
            icon: 'success',  
            title: '<%= LanguageHelper.getText(request, "msg.cancel.success") %>', 
            text: 'Đơn hàng của bạn đã được hủy.',
            confirmButtonColor: '#0d6efd'
        }).then(() => {
            window.history.replaceState(null, null, window.location.pathname);
        });
    } else if (urlParams.has('cancelFail')) {
        Swal.fire({
            icon: 'error',  
            title: '<%= LanguageHelper.getText(request, "msg.cancel.fail") %>', 
            text: 'Đơn hàng đã được xử lý hoặc không tồn tại.',
            confirmButtonColor: '#dc3545'
        });
    }
</script>

</body>
</html> 