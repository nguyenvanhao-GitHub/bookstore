<%@page import="utils.LanguageHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.DecimalFormat, java.util.List, java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="dao.OrderDAO" %>
<%@ page import="entity.Order" %>
<%@ page import="com.google.gson.*" %> 

<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DecimalFormat vndFormat = new DecimalFormat("#,###");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = orderDAO.getOrdersByEmail(userEmail);
%>

<!DOCTYPE html>
<html lang="<%= "vi".equals(session.getAttribute("lang")) ? "vi" : "en" %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= LanguageHelper.getText(request, "order.management.title")%> - <%= LanguageHelper.getText(request, "brand.name")%></title>

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="CSS/style.css"> 
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <style>
            body { background-color: #f8f9fa; }
            .header-section { background: white; padding: 20px 0; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
            
            .nav-tabs-custom { border-bottom: 1px solid #ddd; margin-bottom: 20px; display: flex; justify-content: center; }
            .nav-tabs-custom .nav-link { color: #555; border: none; border-bottom: 3px solid transparent; font-weight: 600; padding: 12px 25px; transition: all 0.3s; }
            .nav-tabs-custom .nav-link:hover { color: #0d6efd; }
            .nav-tabs-custom .nav-link.active { color: #0d6efd; border-bottom: 3px solid #0d6efd; background: transparent; }

            .order-card { background: white; border: none; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); overflow: hidden; transition: transform 0.2s; border: 1px solid #f0f0f0; }
            .order-card:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
            
            .order-header { padding: 15px 20px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; background-color: #fcfcfc; }
            .order-body { padding: 0; } 
            .order-footer { padding: 15px 20px; background-color: #fff; border-top: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }

            .book-item { display: flex; align-items: center; padding: 15px 20px; border-bottom: 1px solid #f9f9f9; }
            .book-item:last-child { border-bottom: none; }
            .book-thumb { width: 50px; height: 75px; object-fit: cover; border-radius: 4px; margin-right: 15px; background: #eee; border: 1px solid #eee; }
            .book-info { flex: 1; }
            .book-title { font-weight: 600; font-size: 0.95rem; color: #333; margin-bottom: 2px; }
            .book-meta { font-size: 0.85rem; color: #777; }
            .book-price { font-weight: 600; color: #333; }

            .book-thumb-icon { width: 50px; height: 75px; display: flex; align-items: center; justify-content: center; background: #f0f0f0; border-radius: 4px; margin-right: 15px; color: #aaa; font-size: 1.5rem; }

            .payment-info { font-size: 0.9rem; color: #555; padding: 15px 20px; border-top: 1px dashed #eee; background: #fafafa; }
            .total-price { font-size: 1.1rem; font-weight: 700; color: #d32f2f; }
            
            .btn-cancel { border: 1px solid #dc3545; color: #dc3545; background: white; padding: 6px 18px; border-radius: 6px; transition: all 0.3s; font-size: 0.9rem; font-weight: 500; }
            .btn-cancel:hover { background: #dc3545; color: white; }

            .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; }
            .bg-warning-soft { background-color: #fff3cd; color: #856404; } 
            .bg-info-soft { background-color: #cff4fc; color: #055160; }
            .bg-success-soft { background-color: #d1e7dd; color: #0f5132; }
            .bg-danger-soft { background-color: #f8d7da; color: #842029; }
        </style>
    </head>
    <body>

        <jsp:include page="header.jsp" />

        <div class="header-section">
            <div class="container">
                <h2 class="mb-0"><i class="fas fa-history text-primary me-2"></i><%= LanguageHelper.getText(request, "order.management.title")%></h2>
            </div>
        </div>

        <div class="container" style="min-height: 60vh;">
            <ul class="nav nav-tabs nav-tabs-custom" id="orderTabs" role="tablist">
                <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#all"><%= LanguageHelper.getText(request, "order.tab.all")%></a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#pending"><%= LanguageHelper.getText(request, "status.pending")%></a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#shipping"><%= LanguageHelper.getText(request, "status.shipping")%></a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#delivered"><%= LanguageHelper.getText(request, "status.delivered")%></a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#cancelled"><%= LanguageHelper.getText(request, "status.cancelled")%></a></li>
            </ul>

            <div class="orders-container">
                <div class="tab-content">
                    <%
                        StringBuilder allTab = new StringBuilder();
                        StringBuilder pendingTab = new StringBuilder();
                        StringBuilder shippingTab = new StringBuilder();
                        StringBuilder deliveredTab = new StringBuilder();
                        StringBuilder cancelledTab = new StringBuilder();

                        if (orders != null && !orders.isEmpty()) {
                            Gson gson = new Gson(); 
                            
                            for (Order o : orders) {
                                String status = o.getStatus().toLowerCase();
                                String badgeClass = "bg-secondary text-white";
                                String statusText = LanguageHelper.getText(request, "status.unknown");

                                if ("pending".equals(status) || "paid".equals(status)) {
                                    badgeClass = "bg-warning-soft"; 
                                    statusText = "⏳ " + LanguageHelper.getText(request, "status.pending"); 
                                    status = "pending";
                                } else if ("shipping".equals(status)) {
                                    badgeClass = "bg-info-soft"; 
                                    statusText = "🚚 " + LanguageHelper.getText(request, "status.shipping");
                                } else if ("delivered".equals(status)) {
                                    badgeClass = "bg-success-soft"; 
                                    statusText = "✅ " + LanguageHelper.getText(request, "status.delivered");
                                } else if ("cancelled".equals(status)) {
                                    badgeClass = "bg-danger-soft"; 
                                    statusText = "❌ " + LanguageHelper.getText(request, "status.cancelled");
                                }

                                StringBuilder booksHtml = new StringBuilder();
                                String booksRaw = o.getBooks();
                                
                                try {
                                    JsonArray items = gson.fromJson(booksRaw, JsonArray.class);
                                    for (JsonElement el : items) {
                                        JsonObject item = el.getAsJsonObject();
                                        String bName = item.has("bookname") ? item.get("bookname").getAsString() : "Sản phẩm";
                                        String bAuthor = item.has("author") ? item.get("author").getAsString() : "";
                                        int bQty = item.has("quantity") ? item.get("quantity").getAsInt() : 1;
                                        double bSubtotal = item.has("subtotal") ? item.get("subtotal").getAsDouble() : 0;
                                        String bImage = item.has("image") ? item.get("image").getAsString() : "images/default-book.png";

                                        booksHtml.append("<div class='book-item'>")
                                                 .append("  <img src='").append(bImage).append("' class='book-thumb' onerror=\"this.src='https://via.placeholder.com/50x75?text=Book'\">")
                                                 .append("  <div class='book-info'>")
                                                 .append("     <div class='book-title'>").append(bName).append("</div>")
                                                 .append("     <div class='book-meta'>x").append(bQty).append(" ").append(bAuthor.isEmpty() ? "" : "| " + bAuthor).append("</div>")
                                                 .append("  </div>")
                                                 .append("  <div class='book-price'>").append(vndFormat.format(bSubtotal)).append("₫</div>")
                                                 .append("</div>");
                                    }
                                } catch (Exception e) {
                                    String[] bookList = (booksRaw != null) ? booksRaw.split(",(?![^()]*\\))") : new String[]{};
                                    for (String book : bookList) {
                                        booksHtml.append("<div class='book-item'>")
                                                 .append("  <div class='book-thumb-icon'><i class='fas fa-book'></i></div>")
                                                 .append("  <div class='book-info'><div class='book-title'>").append(book.trim()).append("</div></div>")
                                                 .append("</div>");
                                    }
                                }

                                String payMethod = o.getPaymentMethod();
                                if(payMethod == null || payMethod.trim().isEmpty() || payMethod.equalsIgnoreCase("null")) {
                                    payMethod = LanguageHelper.getText(request, "payment.method.cod");
                                } else if (payMethod.equalsIgnoreCase("vnpay")) {
                                    payMethod = "VNPay / ATM / VISA";
                                }
                                
                                String transIdHtml = "";
                                if(o.getTransactionId() != null && !o.getTransactionId().trim().isEmpty() && !o.getTransactionId().equals("null")) {
                                    transIdHtml = " <span class='mx-2 text-muted'>|</span> <small class='text-muted'>" + LanguageHelper.getText(request, "order.trans_id") + ": " + o.getTransactionId() + "</small>";
                                }

                                String actionButton = "";
                                if ("pending".equals(status)) {
                                    actionButton = "<button onclick=\"confirmCancel('" + o.getId() + "')\" class='btn-cancel'><i class='far fa-trash-alt me-1'></i> " + LanguageHelper.getText(request, "btn.cancel.order") + "</button>";
                                } else if ("shipping".equals(status)) {
                                    actionButton = "<span class='text-info small'><i class='fas fa-truck'></i> " + LanguageHelper.getText(request, "msg.shipping") + "</span>";
                                }

                                String cardHtml = String.format(
                                    "<div class='order-card'>"
                                    + "  <div class='order-header'>"
                                    + "    <div><strong>%s: #%s</strong> <span class='text-muted small ms-2'>%s</span></div>"
                                    + "    <span class='status-badge %s'>%s</span>"
                                    + "  </div>"
                                    + "  <div class='order-body'>"
                                    + "    %s" 
                                    + "  </div>"
                                    + "  <div class='payment-info'>"
                                    + "       <i class='far fa-credit-card me-1'></i> %s: <strong>%s</strong>%s"
                                    + "  </div>"
                                    + "  <div class='order-footer'>"
                                    + "    <div class='total-price'>%s: %s₫</div>"
                                    + "    <div>%s</div>"
                                    + "  </div>"
                                    + "</div>",
                                    LanguageHelper.getText(request, "order.id"),
                                    o.getId(),
                                    dateFormat.format(o.getOrderDate()),
                                    badgeClass,
                                    statusText,
                                    booksHtml.toString(),
                                    LanguageHelper.getText(request, "order.payment.method"),
                                    payMethod,
                                    transIdHtml,
                                    LanguageHelper.getText(request, "order.total.amount"),
                                    vndFormat.format(o.getTotalAmount()),
                                    actionButton
                                );

                                allTab.append(cardHtml);
                                if ("pending".equals(status)) pendingTab.append(cardHtml);
                                else if ("shipping".equals(status)) shippingTab.append(cardHtml);
                                else if ("delivered".equals(status)) deliveredTab.append(cardHtml);
                                else if ("cancelled".equals(status)) cancelledTab.append(cardHtml);
                            }
                        }

                        String emptyState = "<div class='text-center py-5 text-muted'><i class='fas fa-box-open fa-3x mb-3 opacity-25'></i><p>" + LanguageHelper.getText(request, "order.none") + "</p><a href='categories.jsp' class='btn btn-primary btn-sm mt-2'>" + LanguageHelper.getText(request, "book.view.books") + "</a></div>";
                    %>

                    <div class="tab-pane fade show active" id="all"><%= allTab.length() > 0 ? allTab : emptyState %></div>
                    <div class="tab-pane fade" id="pending"><%= pendingTab.length() > 0 ? pendingTab : emptyState %></div>
                    <div class="tab-pane fade" id="shipping"><%= shippingTab.length() > 0 ? shippingTab : emptyState %></div>
                    <div class="tab-pane fade" id="delivered"><%= deliveredTab.length() > 0 ? deliveredTab : emptyState %></div>
                    <div class="tab-pane fade" id="cancelled"><%= cancelledTab.length() > 0 ? cancelledTab : emptyState %></div>
                </div>
            </div>
        </div>

        <jsp:include page="footer.jsp" />

        <form id="cancelOrderForm" action="CancelOrderServlet" method="post" style="display:none;">
            <input type="hidden" name="orderId" id="cancelOrderIdInput">
        </form>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            const msgConfirmTitle = "<%= LanguageHelper.getText(request, "alert.confirm.title") %>";
            const msgConfirmText = "<%= LanguageHelper.getText(request, "alert.cancel.confirm.text") %>";
            const msgYes = "<%= LanguageHelper.getText(request, "btn.yes") %>";
            const msgNo = "<%= LanguageHelper.getText(request, "btn.no") %>";
            const msgSuccessTitle = "<%= LanguageHelper.getText(request, "alert.success.title") %>";
            const msgSuccessText = "<%= LanguageHelper.getText(request, "alert.cancel.success.text") %>";
            const msgErrorTitle = "<%= LanguageHelper.getText(request, "alert.error.title") %>";
            const msgErrorText = "<%= LanguageHelper.getText(request, "alert.cancel.error.text") %>";

            function confirmCancel(orderId) {
                Swal.fire({
                    title: msgConfirmTitle,
                    text: msgConfirmText.replace("{0}", orderId),
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: msgYes,
                    cancelButtonText: msgNo
                }).then((result) => {
                    if (result.isConfirmed) {
                        document.getElementById('cancelOrderIdInput').value = orderId;
                        document.getElementById('cancelOrderForm').submit();
                    }
                });
            }

            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('cancelSuccess')) {
                Swal.fire({ icon: 'success', title: msgSuccessTitle, text: msgSuccessText, timer: 2000, showConfirmButton: false })
                .then(() => window.history.replaceState(null, null, window.location.pathname));
            } else if (urlParams.has('cancelFail')) {
                Swal.fire({ icon: 'error', title: msgErrorTitle, text: msgErrorText, confirmButtonColor: '#dc3545' });
            }
        </script>
    </body>
</html>