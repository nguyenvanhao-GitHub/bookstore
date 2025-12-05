<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.BookDAO, dao.CategoryDAO, entity.Book, entity.Category" %>
<%@ page import="java.util.List, java.text.NumberFormat, java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    String pubEmail = (String) session.getAttribute("publisherEmail");
    BookDAO bookDAO = new BookDAO();
    CategoryDAO catDAO = new CategoryDAO();

    // 1. Pagination Setup
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) {
        // Giữ nguyên giá trị mặc định nếu parsing lỗi
    }

    int totalRecords = bookDAO.countBooksByPublisher(pubEmail);
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);

    // Đảm bảo currentPage không vượt quá totalPages sau khi tính toán
    if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
        start = (currentPage - 1) * recordsPerPage;
    }
    
    // Đảm bảo start không âm
    if (start < 0) start = 0;


    // 2. Data fetching (SỬ DỤNG PHƯƠNG THỨC DAO MỚI ĐÃ PAGINATE)
    List<Book> myBooks = null;
    try {
        // [SỬA LỖI] Gọi phương thức DAO có phân trang
        myBooks = bookDAO.getBooksByPublisher(pubEmail, start, recordsPerPage); 
    } catch (Exception e) {
        e.printStackTrace();
        myBooks = new ArrayList<>();
    }
    
    List<Category> categories = catDAO.getAllCategories();
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
%>

<div class="publisher-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mt-4 mb-4">
            <h2 class="fw-bold text-secondary"><i class="fas fa-book me-2"></i> Manage Books</h2>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addBookModal">
                <i class="fas fa-plus-circle me-2"></i> Add New Book
            </button>
        </div>

        <div class="card shadow border-0">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="input-group" style="max-width: 400px;">
                    <span class="input-group-text bg-light"><i class="fas fa-search text-muted"></i></span>
                    <input type="text" id="searchInput" class="form-control" placeholder="Search by title or author...">
                </div>
                <div class="text-muted small">
                    Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> sách
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table id="booksTable" class="table table-hover align-middle mb-0 text-center">
                        
                        <thead class="bg-light">
                            <tr>
                                <th>ID</th>
                                <th>Cover</th>
                                <th class="text-start">Book Info</th>
                                <th>Price</th>
                                <th>Category</th>
                                <th>Stock</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            if (myBooks.isEmpty()) { 
                            %>
                            <tr><td colspan="7" class="text-center text-muted py-5">No books found for this publisher.</td></tr>
                            <%
                            } else {
                                for (Book b : myBooks) { 
                            %>
                            <tr>
                                <td><%= b.getId() %></td>
                                <td><img src="../<%= b.getImage() %>" width="50" height="75" class="rounded shadow-sm"></td>
                                
                                <td class="text-start">
                                    <div class="fw-bold text-dark"><%= b.getName() %></div>
                                    <div class="small text-muted">by <%= b.getAuthor() %></div>
                                </td>
                                <td class="fw-bold text-success"><%= currencyVN.format(b.getPrice() * 300) %></td>
                                <td><span class="badge bg-info text-dark"><%= b.getCategory() %></span></td>
                                <td>
                                    <span class="badge bg-<%= b.getStock() > 0 ? "success" : "danger" %>">
                                        <%= b.getStock() %>
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-outline-warning edit-btn me-1"
                                            data-id="<%= b.getId() %>"
                                            data-name="<%= b.getName() %>"
                                            data-author="<%= b.getAuthor() %>"
                                            data-price="<%= b.getPrice() %>"
                                            data-stock="<%= b.getStock() %>"
                                            data-description="<%= b.getDescription() %>"
                                            data-category="<%= b.getCategory() %>"
                                            data-bs-toggle="modal" data-bs-target="#editBookModal">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger delete-btn" data-id="<%= b.getId() %>">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% if (totalPages > 1) { %>
            <div class="card-footer bg-white py-3">
                <nav aria-label="Book Pagination">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage - 1 %>&records=<%= recordsPerPage %>">Trước</a>
                        </li>
                        
                        <% for(int i=1; i<=totalPages; i++) { %>
                        <li class="page-item <%= i == currentPage ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %>&records=<%= recordsPerPage %>"><%= i %></a>
                        </li>
                        <% } %>

                        <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage + 1 %>&records=<%= recordsPerPage %>">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
            <% } %>
            
        </div>
    </div>
</div>

<div class="modal fade" id="addBookModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../AddBookServlet" method="post" enctype="multipart/form-data">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-plus me-2"></i>Add New Book</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="publisherEmail" value="<%= pubEmail %>">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Book Name</label>
                            <input type="text" class="form-control" name="bookName" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Author</label>
                            <input type="text" class="form-control" name="bookAuthor" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Price ($)</label>
                            <input type="number" step="0.01" class="form-control" name="bookPrice" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Stock</label>
                            <input type="number" class="form-control" name="bookStock" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Category</label>
                        <select class="form-select" name="bookCategory" required>
                            <% for (Category c : categories) { %>
                                <option value="<%= c.getName() %>"><%= c.getName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Book Cover</label>
                        <input type="file" class="form-control" name="bookImage" accept="image/*" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">PDF Preview (Optional)</label>
                        <input type="file" class="form-control" name="bookPdf" accept="application/pdf">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="bookDescription" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Book</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editBookModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../EditBookServlet" method="post" enctype="multipart/form-data">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">Edit Book</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="editBookId" name="bookId">
      
                    <div class="mb-3"><label>Name</label><input type="text" id="editBookName" name="bookName" class="form-control" required></div>
                    <div class="mb-3"><label>Author</label><input type="text" id="editBookAuthor" name="bookAuthor" class="form-control" required></div>
                    <div class="row">
                        <div class="col-6 mb-3"><label>Price</label><input type="number" step="0.01" id="editBookPrice" name="bookPrice" class="form-control" required></div>
                        <div class="col-6 mb-3"><label>Stock</label><input type="number" id="editBookStock" name="bookStock" class="form-control" required></div>
                    </div>
                    <div class="mb-3">
                        <label>Category</label>
                        <select id="editBookCategory" name="bookCategory" class="form-select" required>
                            <% for (Category c : categories) { %>
                                <option value="<%= c.getName() %>"><%= c.getName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3"><label>New Cover (Optional)</label><input type="file" name="bookImage" class="form-control"></div>
                    <div class="mb-3"><label>New PDF (Optional)</label><input type="file" name="bookPdf" class="form-control"></div>
                    <div class="mb-3"><label>Description</label><textarea id="editBookDescription" name="bookDescription" class="form-control" rows="3"></textarea></div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-warning">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        document.querySelector('a[href="manage-books.jsp"]').classList.add('active');

        const editModal = document.getElementById('editBookModal');
        editModal.addEventListener('show.bs.modal', function (event) {
            const btn = event.relatedTarget;
            document.getElementById('editBookId').value = btn.getAttribute('data-id');
            document.getElementById('editBookName').value = btn.getAttribute('data-name');
            document.getElementById('editBookAuthor').value = btn.getAttribute('data-author');
            document.getElementById('editBookPrice').value = btn.getAttribute('data-price');
            document.getElementById('editBookStock').value = btn.getAttribute('data-stock');
            
            // [SỬA LỖI] Đảm bảo logic này hoạt động với Select Box (đã sửa trong HTML)
            document.getElementById('editBookCategory').value = btn.getAttribute('data-category');
            document.getElementById('editBookDescription').value = btn.getAttribute('data-description');
        });

        // Search logic
        const searchInput = document.getElementById("searchInput");
        const paginationFooter = document.querySelector('.card-footer');
        searchInput.addEventListener("keyup", function () {
            let value = this.value.toLowerCase();
            let hasResults = false;
            document.querySelectorAll("#booksTable tbody tr").forEach(row => {
                let text = row.innerText.toLowerCase();
                const isVisible = text.includes(value);
                row.style.display = isVisible ? "" : "none";
                if (isVisible) hasResults = true;
            });

            // Ẩn/hiện phân trang khi tìm kiếm
            if (paginationFooter) {
                if (value.length > 0) {
                    paginationFooter.style.display = 'none';
                } else if (<%= totalPages %> > 1) { // Chỉ hiển thị lại nếu có nhiều hơn 1 trang
                    paginationFooter.style.display = '';
                }
            }
        });

        // Delete confirm
        document.querySelectorAll(".delete-btn").forEach(btn => {
            btn.addEventListener("click", function() {
                let id = this.getAttribute("data-id");
                Swal.fire({
                    title: 'Delete this book?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    confirmButtonText: 'Yes, delete'
                }).then((result) => {
                    if (result.isConfirmed) window.location.href = "../DeleteBookServlet?id=" + id;
                });
            });
        });
    });
</script>