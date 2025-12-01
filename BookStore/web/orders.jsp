<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DecimalFormat vndFormat = new DecimalFormat("#,###");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Của Tôi - BookStore</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            padding-bottom: 50px;
        }

        .header-section {
            background: linear-gradient(135deg, #ee4d2d 0%, #ff6d4d 100%);
            color: white;
            padding: 30px 0;
            box-shadow: 0 4px 12px rgba(238, 77, 45, 0.3);
            margin-bottom: 30px;
        }

        .header-section h1 {
            font-size: 2rem;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .header-section .subtitle {
            font-size: 0.95rem;
            opacity: 0.95;
            margin-top: 8px;
        }

        .nav-tabs-custom {
            background: white;
            padding: 15px 20px 0;
            border-radius: 8px 8px 0 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 0;
            border-bottom: 2px solid #f0f0f0;
        }

        .nav-tabs-custom .nav-link {
            color: #666;
            border: none;
            padding: 12px 24px;
            font-weight: 500;
            transition: all 0.3s;
            border-radius: 0;
            border-bottom: 3px solid transparent;
        }

        .nav-tabs-custom .nav-link:hover {
            color: #ee4d2d;
            background: transparent;
        }

        .nav-tabs-custom .nav-link.active {
            color: #ee4d2d;
            background: transparent;
            border-bottom: 3px solid #ee4d2d;
        }

        .orders-container {
            background: white;
            border-radius: 0 0 8px 8px;
            padding: 20px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }

        .order-card {
            background: white;
            border: 1px solid #e5e5e5;
            border-radius: 8px;
            margin-bottom: 20px;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .order-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }

        .order-header {
            background: #fffefb;
            padding: 15px 20px;
            border-bottom: 1px solid #e5e5e5;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-id {
            font-weight: 600;
            color: #333;
            font-size: 0.95rem;
        }

        .order-status {
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-pending {
            background: #fff8e1;
            color: #f57c00;
            border: 1px solid #ffe082;
        }

        .status-delivered {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
        }

        .status-cancelled {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #ef9a9a;
        }

        .order-body {
            padding: 20px;
        }

        .book-info {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px dashed #e5e5e5;
        }

        .book-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.8rem;
            flex-shrink: 0;
        }

        .book-details {
            flex: 1;
        }

        .book-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
            font-size: 1rem;
        }

        .book-meta {
            color: #888;
            font-size: 0.85rem;
        }

        .order-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
        }

        .order-total {
            text-align: right;
        }

        .total-label {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .total-amount {
            color: #ee4d2d;
            font-size: 1.5rem;
            font-weight: 700;
        }

        .order-date {
            color: #888;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-cancel {
            background: white;
            color: #ee4d2d;
            border: 1px solid #ee4d2d;
            padding: 10px 24px;
            border-radius: 6px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-cancel:hover {
            background: #ee4d2d;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(238, 77, 45, 0.3);
        }

        .btn-disabled {
            background: #f5f5f5;
            color: #999;
            border: 1px solid #ddd;
            padding: 10px 24px;
            border-radius: 6px;
            cursor: not-allowed;
        }

        .empty-state {
            text-align: center;
            padding: 80px 20px;
        }

        .empty-icon {
            font-size: 5rem;
            color: #ddd;
            margin-bottom: 20px;
        }

        .empty-text {
            color: #666;
            font-size: 1.1rem;
            margin-bottom: 10px;
        }

        .empty-subtext {
            color: #999;
            font-size: 0.95rem;
        }

        @media (max-width: 768px) {
            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .order-footer {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }

            .order-total {
                text-align: left;
                width: 100%;
            }
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>

<div class="header-section">
    <div class="container">
        <h1>
            <i class="fas fa-shopping-bag"></i>
            Đơn Hàng Của Tôi
        </h1>
        <div class="subtitle">Quản lý và theo dõi đơn hàng của bạn</div>
    </div>
</div>

<div class="container">
    <ul class="nav nav-tabs nav-tabs-custom" id="orderTabs">
        <li class="nav-item">
            <a class="nav-link active" data-bs-toggle="tab" href="#all">Tất cả</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" data-bs-toggle="tab" href="#pending">Chờ xác nhận</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" data-bs-toggle="tab" href="#delivered">Đã giao</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" data-bs-toggle="tab" href="#cancelled">Đã hủy</a>
        </li>
    </ul>

    <div class="orders-container">
        <div class="tab-content">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");

                    ps = conn.prepareStatement("SELECT * FROM orders WHERE email = ? ORDER BY order_date DESC");
                    ps.setString(1, userEmail);
                    rs = ps.executeQuery();

                    boolean hasOrder = false;
                    StringBuilder allOrders = new StringBuilder();
                    StringBuilder pendingOrders = new StringBuilder();
                    StringBuilder deliveredOrders = new StringBuilder();
                    StringBuilder cancelledOrders = new StringBuilder();

                    while (rs.next()) {
                        hasOrder = true;
                        String orderId = rs.getString("id");
                        String books = rs.getString("books");
                        double total = rs.getDouble("total_amount");
                        String status = rs.getString("status");
                        Timestamp date = rs.getTimestamp("order_date");

                        String displayStatus, statusClass;
                        switch (status.toLowerCase()) {
                            case "pending":
                                displayStatus = "Pending";
                                statusClass = "status-pending";
                                break;
                            case "delivered":
                                displayStatus = "Delivered";
                                statusClass = "status-delivered";
                                break;
                            case "cancelled":
                                displayStatus = "cancelled";
                                statusClass = "status-cancelled";
                                break;
                            default:
                                displayStatus = "Not determined";
                                statusClass = "status-pending";
                                break;
                        }

                        String orderCard = String.format(
                            "<div class='order-card'>" +
                            "  <div class='order-header'>" +
                            "    <span class='order-id'><i class='fas fa-receipt'></i> Đơn hàng #%s</span>" +
                            "    <span class='order-status %s'>%s</span>" +
                            "  </div>" +
                            "  <div class='order-body'>" +
                            "    <div class='book-info'>" +
                            "      <div class='book-icon'><i class='fas fa-book'></i></div>" +
                            "      <div class='book-details'>" +
                            "        <div class='book-title'>%s</div>" +
                            "        <div class='book-meta'><i class='far fa-calendar'></i> %s</div>" +
                            "      </div>" +
                            "    </div>" +
                            "    <div class='order-footer'>" +
                            "      <div class='action-buttons'>",
                            orderId, statusClass, displayStatus, books,
                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(date)
                        );

                        if ("pending".equalsIgnoreCase(status)) {
                            orderCard += String.format(
                                "        <form action='CancelOrderServlet' method='post' style='display:inline;'>" +
                                "          <input type='hidden' name='orderId' value='%s'>" +
                                "          <button type='submit' class='btn-cancel'>" +
                                "            <i class='fas fa-times-circle'></i> Cancel order" +
                                "          </button>" +
                                "        </form>",
                                orderId
                            );
                        } else {
                            orderCard += "        <button class='btn-disabled' disabled>" +
                                        "          <i class='fas fa-ban'></i> Cannot be cancelled" +
                                        "        </button>";
                        }

                        orderCard += String.format(
                            "      </div>" +
                            "      <div class='order-total'>" +
                            "        <div class='total-label'>Total Payment:</div>" +
                            "        <div class='total-amount'>%s₫</div>" +
                            "      </div>" +
                            "    </div>" +
                            "  </div>" +
                            "</div>",
                            vndFormat.format(total)
                        );

                        allOrders.append(orderCard);
                        
                        if ("pending".equalsIgnoreCase(status)) {
                            pendingOrders.append(orderCard);
                        } else if ("delivered".equalsIgnoreCase(status)) {
                            deliveredOrders.append(orderCard);
                        } else if ("cancelled".equalsIgnoreCase(status)) {
                            cancelledOrders.append(orderCard);
                        }
                    }

                    String emptyState = 
                        "<div class='empty-state'>" +
                        "  <div class='empty-icon'><i class='fas fa-inbox'></i></div>" +
                        "  <div class='empty-text'>Chưa có đơn hàng</div>" +
                        "  <div class='empty-subtext'>Bạn chưa có đơn hàng nào trong mục này</div>" +
                        "</div>";
            %>

            <div class="tab-pane fade show active" id="all">
                <%= hasOrder ? allOrders.toString() : emptyState %>
            </div>

            <div class="tab-pane fade" id="pending">
                <%= pendingOrders.length() > 0 ? pendingOrders.toString() : emptyState %>
            </div>

            <div class="tab-pane fade" id="delivered">
                <%= deliveredOrders.length() > 0 ? deliveredOrders.toString() : emptyState %>
            </div>

            <div class="tab-pane fade" id="cancelled">
                <%= cancelledOrders.length() > 0 ? cancelledOrders.toString() : emptyState %>
            </div>

            <%
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Lỗi: " + e.getMessage() + "</div>");
                } finally {
                    try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
                    try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
                    try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
                }
            %>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
<%
    if (request.getParameter("cancelSuccess") != null) {
%>
Swal.fire({
    icon: 'success',
    title: 'Hủy đơn hàng thành công!',
    text: 'Đơn hàng của bạn đã được hủy.',
    confirmButtonText: 'Đồng ý',
    confirmButtonColor: '#ee4d2d',
    timer: 3000
});
<%
    } else if (request.getParameter("cancelFail") != null) {
%>
Swal.fire({
    icon: 'error',
    title: 'Không thể hủy đơn hàng',
    text: 'Đơn hàng đã được xác nhận hoặc giao, không thể hủy.',
    confirmButtonText: 'Đồng ý',
    confirmButtonColor: '#ee4d2d'
});
<%
    }
%>
</script>
</body>
</html>