<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PublisherDAO" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    // 1. Kiểm tra đăng nhập
    String pubEmail = (String) session.getAttribute("publisherEmail");
    if (pubEmail == null) { response.sendRedirect("login.jsp"); return; }

    // 2. Lấy dữ liệu thống kê
    PublisherDAO pubDAO = new PublisherDAO();
    Map<String, Object> stats = pubDAO.getPublisherStats(pubEmail);
    List<Double> monthlyRevenue = pubDAO.getPublisherMonthlyRevenue(pubEmail);
    List<Map<String, Object>> topBooks = pubDAO.getTopSellingBooks(pubEmail);

    // 3. Xử lý dữ liệu cho biểu đồ tròn (Active vs Inactive Books)
    int totalBooks = (int) stats.get("totalBooks");
    int activeBooks = (int) stats.get("activeBooks");
    int inactiveBooks = totalBooks - activeBooks;

    // 4. Format tiền tệ
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
    String revenueStr = currencyVN.format(stats.get("totalRevenue"));
%>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="publisher-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mt-4 mb-4">
            <h2 class="fw-bold text-secondary"><i class="fas fa-chart-line me-2"></i> Publisher Dashboard</h2>
            <span class="badge bg-primary fs-6"><%= pubEmail %></span>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center p-3 h-100">
                    <div class="mb-2"><i class="fas fa-book fa-2x text-primary"></i></div>
                    <h3 class="fw-bold"><%= stats.get("totalBooks") %></h3>
                    <p class="text-muted mb-0">Tổng số sách</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center p-3 h-100">
                    <div class="mb-2"><i class="fas fa-shopping-cart fa-2x text-success"></i></div>
                    <h3 class="fw-bold"><%= stats.get("totalSold") %></h3>
                    <p class="text-muted mb-0">Sách đã bán</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center p-3 h-100">
                    <div class="mb-2"><i class="fas fa-money-bill-wave fa-2x text-warning"></i></div>
                    <h3 class="fw-bold text-success"><%= revenueStr %></h3>
                    <p class="text-muted mb-0">Doanh thu ước tính</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm text-center p-3 h-100">
                    <div class="mb-2"><i class="fas fa-check-circle fa-2x text-info"></i></div>
                    <h3 class="fw-bold"><%= stats.get("activeBooks") %></h3>
                    <p class="text-muted mb-0">Sách đang bán</p>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="card h-100 shadow border-0">
                    <div class="card-header bg-white py-3">
                        <h5 class="card-title mb-0"><i class="fas fa-chart-area me-2 text-primary"></i>Doanh thu năm nay</h5>
                    </div>
                    <div class="card-body">
                        <canvas id="revenueChart" style="height: 300px; width: 100%;"></canvas>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="card h-100 shadow border-0">
                    <div class="card-header bg-white py-3">
                        <h5 class="card-title mb-0"><i class="fas fa-crown me-2 text-warning"></i>Top Sách Bán Chạy</h5>
                    </div>
                    <div class="card-body">
                        <% if (topBooks.isEmpty()) { %>
                            <p class="text-center text-muted py-5">Chưa có dữ liệu bán hàng.</p>
                        <% } else { %>
                            <ul class="list-group list-group-flush">
                                <% for (Map<String, Object> book : topBooks) { %>
                                    <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                        <span class="text-truncate" style="max-width: 200px;" title="<%= book.get("name") %>">
                                            <%= book.get("name") %>
                                        </span>
                                        <span class="badge bg-primary rounded-pill"><%= book.get("sold") %> đã bán</span>
                                    </li>
                                <% } %>
                            </ul>
                            <div class="mt-4">
                                <canvas id="stockChart" style="height: 150px;"></canvas>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. Biểu đồ Doanh thu
    const revenueCtx = document.getElementById('revenueChart').getContext('2d');
    const revenueData = <%= monthlyRevenue.toString() %>;
    
    new Chart(revenueCtx, {
        type: 'line', // Dùng line chart cho xu hướng
        data: {
            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Doanh thu (VND)',
                data: revenueData,
                borderColor: 'rgba(75, 192, 192, 1)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderWidth: 2,
                tension: 0.4, // Đường cong mềm mại
                fill: true
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

    // 2. Biểu đồ Trạng thái Sách (Pie Chart nhỏ ở góc phải dưới nếu có top sách)
    <% if (!topBooks.isEmpty()) { %>
        const stockCtx = document.getElementById('stockChart').getContext('2d');
        new Chart(stockCtx, {
            type: 'doughnut',
            data: {
                labels: ['Active', 'Inactive/Hết hàng'],
                datasets: [{
                    data: [<%= activeBooks %>, <%= inactiveBooks %>],
                    backgroundColor: ['#28a745', '#dc3545'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'right' }
                }
            }
        });
    <% } %>
</script>
</body>
</html>