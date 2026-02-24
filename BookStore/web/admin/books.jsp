<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.CategoryDAO" %>
<%@ page import="entity.Book, entity.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%@ include file="header.jsp" %>

<%
    BookDAO bookDAO = new BookDAO();
    CategoryDAO catDAO = new CategoryDAO();

    int totalBooks = bookDAO.countBooks();
    int addedToday = bookDAO.countBooksAddedToday();

    int currentPage = 1;
    int recordsPerPage = 10;

    try {
        if (request.getParameter("page") != null) {
            currentPage = Integer.parseInt(request.getParameter("page"));
        }
        if (request.getParameter("records") != null) {
            recordsPerPage = Integer.parseInt(request.getParameter("records"));
        }
    } catch (NumberFormatException e) {
        currentPage = 1;
    }

    int start = (currentPage - 1) * recordsPerPage;
    int totalPages = (int) Math.ceil(totalBooks * 1.0 / recordsPerPage);
    if (start < 0) {
        start = 0;
    }

    List<Book> booksList = bookDAO.getAllBooks(start, recordsPerPage);
    List<Category> categories = catDAO.getAllCategories();

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
%>

<script>document.querySelector('a[href="books.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-book"></i> Quản lý Sách</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addBookModal">
            <i class="fas fa-plus-circle me-2"></i> Thêm Sách Mới
        </button>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-6">
            <div class="stats-card">
                <div class="icon bg-primary text-white"><i class="fas fa-book"></i></div>
                <h3><%= totalBooks%></h3> 
                <p class="text-muted mb-0">Tổng số sách</p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="stats-card">
                <div class="icon bg-success text-white"><i class="fas fa-calendar-plus"></i></div>
                <h3><%= addedToday%></h3>
                <p class="text-muted mb-0">Sách mới hôm nay</p>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="text-muted">
                    Hiển thị <%= totalBooks > 0 ? start + 1 : 0%> - <%= Math.min(start + recordsPerPage, totalBooks)%> của <%= totalBooks%> sách
                </div>
                <div>
                    <select class="form-select form-select-sm" id="recordsPerPage" onchange="changeRecordsPerPage()" style="width: auto;">
                        <option value="10" <%= recordsPerPage == 10 ? "selected" : ""%>>10 / trang</option>
                        <option value="20" <%= recordsPerPage == 20 ? "selected" : ""%>>20 / trang</option>
                        <option value="50" <%= recordsPerPage == 50 ? "selected" : ""%>>50 / trang</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table admin-table table-hover align-middle" id="booksTable">
                    <thead class="table-light">
                        <tr>
                        <th>ID</th>
                        <th>Ảnh bìa</th>
                        <th>Tên sách</th>
                        <th>Tác giả</th>
                        <th>Danh mục</th>
                        <th>Giá gốc</th>
                        <th>Kho</th>
                        <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (booksList != null && !booksList.isEmpty()) {
                                for (Book book : booksList) {
                                    double priceVND = book.getPrice() * 300; 
                                    String imgUrl = (book.getImage() != null && !book.getImage().startsWith("http")) ? "../" + book.getImage() : book.getImage();
                        %>
                        <tr>
                        <td><%= book.getId()%></td>
                        <td>
                            <img src="<%= imgUrl%>" style="width: 40px; height: 60px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd;">
                        </td>
                        <td class="fw-bold"><%= book.getName()%></td>
                        <td><%= book.getAuthor()%></td>
                        <td><span class="badge bg-secondary"><%= book.getCategory()%></span></td>
                        <td class="text-success fw-bold"><%= currencyVN.format(priceVND)%></td>
                        <td>
                        <span class="badge bg-<%= book.getStock() > 0 ? "success" : "danger"%>">
                            <%= book.getStock()%>
                        </span>
                        </td>
                        <td>
                        <button class="btn btn-sm btn-warning me-1" 
                                data-bs-toggle="modal" 
                                data-bs-target="#editBookModal"
                                onclick="openEditModal('<%= book.getId()%>', '<%= book.getName()%>', '<%= book.getAuthor()%>', '<%= book.getPrice()%>', '<%= book.getCategory()%>', '<%= book.getStock()%>', '<%= book.getDescription()%>')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="confirmDelete(<%= book.getId()%>)">
                            <i class="fas fa-trash"></i>
                        </button>
                        </td>
                        </tr>
                        <%
                                }
                            } else {
                                out.println("<tr><td colspan='8' class='text-center py-4 text-muted'>Không tìm thấy sách nào.</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <% if (totalPages > 1) {%>
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center">
                    <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage - 1%>&records=<%= recordsPerPage%>">Trước</a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <li class="page-item <%= i == currentPage ? "active" : ""%>">
                        <a class="page-link" href="?page=<%= i%>&records=<%= recordsPerPage%>"><%= i%></a>
                    </li>
                    <% }%>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage + 1%>&records=<%= recordsPerPage%>">Sau</a>
                    </li>
                </ul>
            </nav>
            <% } %>
        </div>
    </div>
</div>

<div class="modal fade" id="addBookModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="../AddBookServlet" method="post" enctype="multipart/form-data">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i>Thêm Sách Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="userType" value="admin"> <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Tên sách</label>
                            <input type="text" class="form-control" name="bookName" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Tác giả</label>
                            <input type="text" class="form-control" name="bookAuthor" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Giá (USD)</label>
                            <input type="number" step="0.01" class="form-control" name="bookPrice" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Số lượng kho</label>
                            <input type="number" class="form-control" name="bookStock" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Danh mục</label>
                        <select class="form-select" name="bookCategory" required>
                            <% for (Category c : categories) {%>
                            <option value="<%= c.getName()%>"><%= c.getName()%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Ảnh bìa</label>
                        <input type="file" class="form-control" name="bookImage" accept="image/*" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" name="bookDescription" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu Sách</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editBookModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="../EditBookServlet" method="post" enctype="multipart/form-data">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Cập Nhật Sách</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="editBookId" name="bookId">
                    <input type="hidden" name="userType" value="admin">

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Tên sách</label>
                            <input type="text" class="form-control" id="editBookName" name="bookName" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Tác giả</label>
                            <input type="text" class="form-control" id="editBookAuthor" name="bookAuthor" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Giá (USD)</label>
                            <input type="number" step="0.01" class="form-control" id="editBookPrice" name="bookPrice" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Số lượng kho</label>
                            <input type="number" class="form-control" id="editBookStock" name="bookStock" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Danh mục</label>
                        <select class="form-select" id="editBookCategory" name="bookCategory" required>
                            <% for (Category c : categories) {%>
                            <option value="<%= c.getName()%>"><%= c.getName()%></option>
                            <% }%>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Ảnh bìa mới (Không bắt buộc)</label>
                        <input type="file" class="form-control" name="bookImage" accept="image/*">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" id="editBookDescription" name="bookDescription" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning">Cập Nhật</button>
                </div>
            </form>
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
                            
                                    function openEditModal(id, name, author, price, category, stock, desc) {
                                        document.getElementById('editBookId').value = id;
                                        document.getElementById('editBookName').value = name;
                                        document.getElementById('editBookAuthor').value = author;
                                        document.getElementById('editBookPrice').value = price;
                                        document.getElementById('editBookCategory').value = category;
                                        document.getElementById('editBookStock').value = stock;
                                        document.getElementById('editBookDescription').value = desc;
                                    }

                                    function confirmDelete(id) {
                                        Swal.fire({
                                            title: 'Xác nhận xóa?',
                                            text: "Hành động này không thể hoàn tác!",
                                            icon: 'warning',
                                            showCancelButton: true,
                                            confirmButtonColor: '#d33',
                                            cancelButtonColor: '#6c757d',
                                            confirmButtonText: 'Xóa ngay',
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