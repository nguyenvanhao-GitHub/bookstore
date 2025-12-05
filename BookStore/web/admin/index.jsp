<%@ include file="header.jsp" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script>document.querySelector('a[href="index.jsp"]').classList.add('active');</script>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <button id="sidebar-toggle" class="btn btn-primary d-md-none"><i class="fas fa-bars"></i></button>
        <h2 class="mb-0"><i class="fas fa-home"></i> Admin Dashboard</h2>
    </div>

    <%
        // Lấy dữ liệu thống kê từ DAO
        AdminDAO dao = new AdminDAO();
        Map<String, Object> stats = dao.getDashboardStats();
        
        // [MỚI] Lấy dữ liệu cho biểu đồ
        List<Double> monthlyRevenue = dao.getMonthlyRevenueCurrentYear();
        Map<String, Integer> statusCounts = dao.getOrderStatusCounts();
        
        // Format tiền tệ
        Locale localeVN = new Locale("vi", "VN");
        NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
        String revenue = currencyVN.format(stats.getOrDefault("totalRevenue", 0.0));
    %>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-primary text-white"><i class="fas fa-book"></i></div>
                <h3><%= stats.getOrDefault("totalBooks", 0) %></h3>
                <p class="text-muted mb-0">Total Books</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-warning text-white"><i class="fas fa-users"></i></div>
                <h3><%= stats.getOrDefault("totalUsers", 0) %></h3>
                <p class="text-muted mb-0">Users</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-info text-white"><i class="fas fa-shopping-bag"></i></div>
                <h3><%= stats.getOrDefault("totalOrders", 0) %></h3>
                <p class="text-muted mb-0">Orders</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-success text-white"><i class="fas fa-dollar-sign"></i></div>
                <h3><%= revenue %></h3>
                <p class="text-muted mb-0">Revenue</p>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0"><i class="fas fa-chart-bar me-2 text-primary"></i>Doanh Thu Năm Nay</h5>
                </div>
                <div class="card-body">
                    <canvas id="revenueChart" style="height: 300px; width: 100%;"></canvas>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-white py-3">
                    <h5 class="card-title mb-0"><i class="fas fa-chart-pie me-2 text-info"></i>Trạng Thái Đơn Hàng</h5>
                </div>
                <div class="card-body d-flex align-items-center justify-content-center">
                    <div style="width: 100%; max-width: 300px;">
                        <canvas id="orderStatusChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-3">
            <h5 class="card-title mb-0">Recent Orders</h5>
        </div>
        <div class="card-body">
            <table class="table admin-table align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Books</th>
                        <th>Total</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Map<String, String>> recentOrders = dao.getRecentOrders();
                        if (recentOrders.isEmpty()) {
                    %>
                        <tr><td colspan="5" class="text-center py-4">No orders found.</td></tr>
                    <%  
                        } else {
                            for (Map<String, String> order : recentOrders) {
                                String status = order.get("status");
                                double amount = Double.parseDouble(order.get("total"));
                    %>
                    <tr>
                        <td><span class="fw-bold">#<%= order.get("id") %></span></td>
                        <td><%= order.get("customer") %></td>
                        <td class="text-truncate" style="max-width: 200px;"><%= order.get("books") %></td>
                        <td class="text-success fw-bold"><%= currencyVN.format(amount) %></td>
                        <td>
                            <% 
                                String badgeClass = "secondary";
                                if ("delivered".equalsIgnoreCase(status) || "paid".equalsIgnoreCase(status)) badgeClass = "success";
                                else if ("cancelled".equalsIgnoreCase(status)) badgeClass = "danger";
                                else if ("pending".equalsIgnoreCase(status)) badgeClass = "warning text-dark";
                            %>
                            <span class="badge bg-<%= badgeClass %>">
                                <%= status.substring(0, 1).toUpperCase() + status.substring(1) %>
                            </span>
                        </td>
                    </tr>
                    <%      }
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // 1. Dữ liệu biểu đồ Doanh thu (Từ Server -> JSP -> JS Array)
    const revenueData = <%= monthlyRevenue.toString() %>;
    
    const ctxRevenue = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctxRevenue, {
        type: 'bar',
        data: {
            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Doanh thu (VND)',
                data: revenueData,
                backgroundColor: 'rgba(54, 162, 235, 0.6)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1,
                borderRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                        }
                    }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });

    // 2. Dữ liệu biểu đồ Trạng thái đơn hàng
    const pendingCount = <%= statusCounts.getOrDefault("pending", 0) %>;
    const deliveredCount = <%= statusCounts.getOrDefault("delivered", 0) %> + <%= statusCounts.getOrDefault("paid", 0) %>;
    const cancelledCount = <%= statusCounts.getOrDefault("cancelled", 0) %>;

    const ctxStatus = document.getElementById('orderStatusChart').getContext('2d');
    new Chart(ctxStatus, {
        type: 'doughnut',
        data: {
            labels: ['Đang xử lý', 'Thành công', 'Đã hủy'],
            datasets: [{
                data: [pendingCount, deliveredCount, cancelledCount],
                backgroundColor: [
                    '#ffc107', // Vàng (Pending)
                    '#198754', // Xanh (Success)
                    '#dc3545'  // Đỏ (Cancelled)
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
</script>
</body>
</html>