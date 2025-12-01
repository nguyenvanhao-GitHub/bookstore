<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    int totalBooks = 0;
    int addedToday = 0;
    
    // Phân trang
    int currentPage = 1;
    int recordsPerPage = 10;
    
    // Xử lý tham số page
    if (request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    // Xử lý tham số records
    if (request.getParameter("records") != null) {
        try {
            recordsPerPage = Integer.parseInt(request.getParameter("records"));
        } catch (NumberFormatException e) {
            recordsPerPage = 10;
        }
    }
    
    int start = (currentPage - 1) * recordsPerPage;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
        Statement stmt = conn.createStatement();

        // Tổng số sách
        ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) FROM books");
        if (rs1.next()) totalBooks = rs1.getInt(1);

        // Sách thêm trong ngày
        ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) FROM books WHERE DATE(created_at) = CURDATE()");
        if (rs2.next()) addedToday = rs2.getInt(1);

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    int totalPages = (int) Math.ceil(totalBooks * 1.0 / recordsPerPage);
%>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        document.querySelector('a[href="books.jsp"]').classList.add('active');
    });
</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <button id="sidebar-toggle" class="btn btn-primary d-md-none"><i class="fas fa-bars"></i></button>
        <h2 class="mb-0"><i class="fas fa-book"></i> Book Management</h2>
    </div>

    <!-- Book Statistics -->
    <div class="row g-4 mb-4">
        <div class="col-md-6">
            <div class="stats-card">
                <div class="icon bg-primary text-white"><i class="fas fa-book"></i></div>
                <h3><%= totalBooks %></h3>
                <p class="text-muted mb-0">Total Books</p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="stats-card">
                <div class="icon bg-success text-white"><i class="fas fa-calendar-plus"></i></div>
                <h3><%= addedToday %></h3>
                <p class="text-muted mb-0">Books Added Today</p>
            </div>
        </div>
    </div>

    <!-- Search Box -->
    <div class="card mb-4">
        <div class="card-body">
            <div class="input-group">
                <span class="input-group-text bg-primary text-white">
                    <i class="fas fa-search"></i>
                </span>
                <input type="text" id="searchInput" class="form-control" placeholder="Search by Title, Author, or Category" onkeyup="searchBooks()">
            </div>
        </div>
    </div>

    <!-- Books Table -->
    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="text-muted">
                    Hiển thị <%= start + 1 %> - <%= Math.min(start + recordsPerPage, totalBooks) %> của <%= totalBooks %> sách
                </div>
                <div>
                    <select class="form-select form-select-sm" id="recordsPerPage" onchange="changeRecordsPerPage()" style="width: auto;">
                        <option value="10" <%= recordsPerPage == 10 ? "selected" : "" %>>10 / trang</option>
                        <option value="20" <%= recordsPerPage == 20 ? "selected" : "" %>>20 / trang</option>
                        <option value="50" <%= recordsPerPage == 50 ? "selected" : "" %>>50 / trang</option>
                        <option value="100" <%= recordsPerPage == 100 ? "selected" : "" %>>100 / trang</option>
                    </select>
                </div>
            </div>
            
            <table class="table admin-table" id="booksTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cover</th>
                        <th>Title</th>
                        <th>Author</th>
                        <th>Publisher</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
                            Statement stmt = conn.createStatement();
                            
                            // Query với LIMIT và OFFSET cho phân trang
                            String query = "SELECT * FROM books LIMIT " + start + ", " + recordsPerPage;
                            ResultSet rs = stmt.executeQuery(query);

                            Locale localeVN = new Locale("vi", "VN");
                            NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

                            while (rs.next()) {
                                double priceUSD = rs.getDouble("price");
                                double priceVND = priceUSD * 300;
                                String formattedPrice = currencyVN.format(priceVND);
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><img src="../<%= rs.getString("image") %>" alt="Cover" style="width: 50px; height: 70px; object-fit: cover;"></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("author") %></td>
                        <td><%= rs.getString("publisher_email") %></td>
                        <td><%= rs.getString("category") %></td>
                        <td><%= formattedPrice %></td>
                        <td><%= rs.getString("description") %></td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
            
            <!-- Pagination Controls -->
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center">
                    <!-- Nút Previous -->
                    <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage - 1 %>&records=<%= recordsPerPage %>" tabindex="-1">
                            <i class="fas fa-chevron-left"></i> Previous
                        </a>
                    </li>
                    
                    <%
                        // Hiển thị các số trang
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, currentPage + 2);
                        
                        // Nút trang đầu tiên
                        if (startPage > 1) {
                    %>
                        <li class="page-item">
                            <a class="page-link" href="?page=1&records=<%= recordsPerPage %>">1</a>
                        </li>
                        <% if (startPage > 2) { %>
                            <li class="page-item disabled">
                                <span class="page-link">...</span>
                            </li>
                        <% } %>
                    <%
                        }
                        
                        // Các trang ở giữa
                        for (int i = startPage; i <= endPage; i++) {
                    %>
                        <li class="page-item <%= i == currentPage ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %>&records=<%= recordsPerPage %>"><%= i %></a>
                        </li>
                    <%
                        }
                        
                        // Nút trang cuối cùng
                        if (endPage < totalPages) {
                    %>
                        <% if (endPage < totalPages - 1) { %>
                            <li class="page-item disabled">
                                <span class="page-link">...</span>
                            </li>
                        <% } %>
                        <li class="page-item">
                            <a class="page-link" href="?page=<%= totalPages %>&records=<%= recordsPerPage %>"><%= totalPages %></a>
                        </li>
                    <%
                        }
                    %>
                    
                    <!-- Nút Next -->
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage + 1 %>&records=<%= recordsPerPage %>">
                            Next <i class="fas fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function searchBooks() {
    const input = document.getElementById("searchInput").value.toLowerCase();
    const rows = document.querySelectorAll("#booksTable tbody tr");
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(input) ? "" : "none";
    });
}

function changeRecordsPerPage() {
    const value = document.getElementById("recordsPerPage").value;
    window.location.href = "?page=1&records=" + value;
}
</script>

<style>
.pagination .page-link {
    color: #0d6efd;
    border: 1px solid #dee2e6;
    padding: 0.5rem 0.75rem;
}

.pagination .page-item.active .page-link {
    background-color: #0d6efd;
    border-color: #0d6efd;
    color: white;
}

.pagination .page-item.disabled .page-link {
    color: #6c757d;
    pointer-events: none;
    background-color: #fff;
    border-color: #dee2e6;
}

.pagination .page-link:hover {
    background-color: #e9ecef;
    color: #0d6efd;
}
</style>

</body>
</html>