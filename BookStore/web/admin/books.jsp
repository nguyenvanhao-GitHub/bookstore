<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO" %> <%-- [BỔ SUNG] --%>
<%@ page import="entity.Book" %> <%-- [BỔ SUNG] --%>
<%@ page import="java.util.List" %> <%-- [BỔ SUNG] --%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    // Khởi tạo DAO
    BookDAO bookDAO = new BookDAO();
    
    // [SỬA LỖI] Lấy dữ liệu thống kê từ DAO
    int totalBooks = bookDAO.countBooks(); 
    int addedToday = bookDAO.countBooksAddedToday(); 
    
    // Phân trang
    int currentPage = 1;
    int recordsPerPage = 10;
    
    if (request.getParameter("page") != null) {
        try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (NumberFormatException e) { currentPage = 1; }
    }
    
    if (request.getParameter("records") != null) {
        try { recordsPerPage = Integer.parseInt(request.getParameter("records")); } catch (NumberFormatException e) { recordsPerPage = 10; }
    }
    
    int start = (currentPage - 1) * recordsPerPage;
    int totalPages = (int) Math.ceil(totalBooks * 1.0 / recordsPerPage);
    
    // [SỬA LỖI] Lấy danh sách sách từ DAO
    List<Book> booksList = null;
    try {
        booksList = bookDAO.getAllBooks(start, recordsPerPage); 
    } catch (Exception e) {
        e.printStackTrace();
    }

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
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
                    </select>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table admin-table" id="booksTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Cover</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>PDF</th> <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (booksList != null) {
                            for (Book book : booksList) { 
                                // Giả định tỉ giá 1:300 theo logic cũ trong file
                                double priceVND = book.getPrice() * 300; 
                                String formattedPrice = currencyVN.format(priceVND);
                                String pdfPath = book.getPdfPreviewPath(); 
                        %>
                        <tr>
                            <td><%= book.getId() %></td>
                            <td>
                                <img src="../<%= book.getImage() %>" alt="Cover" 
                                     style="width: 50px; height: 70px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd;">
                            </td>
                            <td><strong><%= book.getName() %></strong></td>
                            <td><%= book.getAuthor() %></td>
                            <td><span class="badge bg-secondary"><%= book.getCategory() %></span></td>
                            <td class="text-success fw-bold"><%= formattedPrice %></td>
                            <td>
                                <% if(pdfPath != null && !pdfPath.isEmpty()) { %>
                                    <a href="../<%= pdfPath %>" target="_blank" class="btn btn-sm btn-outline-danger" title="View PDF">
                                        <i class="fas fa-file-pdf"></i>
                                    </a>
                                <% } else { %>
                                    <span class="text-muted small">No PDF</span>
                                <% } %>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-danger" onclick="confirmDelete(<%= book.getId() %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <% 
                            }
                        } else {
                            out.println("<tr><td colspan='8' class='text-center'>Không tìm thấy sách.</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
            
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center">
                    <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage - 1 %>&records=<%= recordsPerPage %>">Previous</a>
                    </li>
                    <% for(int i=1; i<=totalPages; i++) { %>
                        <li class="page-item <%= i == currentPage ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %>&records=<%= recordsPerPage %>"><%= i %></a>
                        </li>
                    <% } %>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage + 1 %>&records=<%= recordsPerPage %>">Next</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function changeRecordsPerPage() {
    const value = document.getElementById("recordsPerPage").value;
    window.location.href = "?page=1&records=" + value;
}

function confirmDelete(id) {
    Swal.fire({
        title: 'Xóa sách này?',
        text: "Hành động này không thể hoàn tác!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = "../DeleteBookServlet?id=" + id;
        }
    })
}
</script>
</body>
</html>