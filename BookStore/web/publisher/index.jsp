<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.CategoryDAO, entity.Book" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    // Lấy thông tin từ session
    String pubEmail = (String) session.getAttribute("publisherEmail");
    if (pubEmail == null) { response.sendRedirect("login.jsp"); return; }

    // Gọi DAO lấy số liệu
    BookDAO bookDAO = new BookDAO();
    int totalBooks = bookDAO.countBooksByPublisher(pubEmail);
    List<Book> recentBooks = bookDAO.getRecentBooksByPublisher(pubEmail);

    CategoryDAO catDAO = new CategoryDAO();
    int totalCategories = catDAO.countCategories();
    
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
%>

<div class="publisher-content">
    <div class="container-fluid">
        <h2 class="mt-4 mb-4 fw-bold text-secondary"><i class="fas fa-tachometer-alt me-2"></i> Publisher Dashboard</h2>
        
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card text-white bg-success shadow h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title fw-bold">Total Books</h5>
                            <h2 class="mb-0"><%= totalBooks %></h2>
                        </div>
                        <div class="fs-1 opacity-50"><i class="fas fa-book"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card text-white bg-info shadow h-100">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="card-title fw-bold">Total Categories</h5>
                            <h2 class="mb-0"><%= totalCategories %></h2>
                        </div>
                        <div class="fs-1 opacity-50"><i class="fas fa-th-list"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card shadow border-0">
            <div class="card-header bg-white py-3">
                <h5 class="mb-0 fw-bold text-primary"><i class="fas fa-clock me-2"></i> Books Added in Last 24 Hours</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Image</th>
                                <th>Name</th>
                                <th>Author</th>
                                <th>Price</th>
                                <th>Category</th>
                                <th>Stock</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (recentBooks.isEmpty()) { %>
                                <tr><td colspan="7" class="text-center text-muted py-3">No books added recently.</td></tr>
                            <% } else { 
                                for (Book b : recentBooks) {
                            %>
                            <tr>
                                <td><%= b.getId() %></td>
                                <td><img src="../<%= b.getImage() %>" width="40" height="60" class="rounded border"></td>
                                <td class="fw-bold"><%= b.getName() %></td>
                                <td><%= b.getAuthor() %></td>
                                <td class="text-success"><%= currencyVN.format(b.getPrice() * 300) %></td>
                                <td><span class="badge bg-secondary"><%= b.getCategory() %></span></td>
                                <td><%= b.getStock() %></td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/publisher-script.js"></script>
</body>
</html>