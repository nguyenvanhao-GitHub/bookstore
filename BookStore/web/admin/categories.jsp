<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.CategoryDAO, entity.Category, java.util.List" %>
<%@ include file="header.jsp" %>

<%
    CategoryDAO catDAO = new CategoryDAO();
    List<Category> allCategories = catDAO.getAllCategories();

    int currentPage = 1;
    int recordsPerPage = 10;
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) {}

    int totalRecords = allCategories.size();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    if(currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);
    List<Category> list = (start < totalRecords) ? allCategories.subList(start, end) : allCategories;
%>

<script>document.querySelector('a[href="categories.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-tags"></i> Quản lý Danh mục</h2>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
            <i class="fas fa-plus me-1"></i> Thêm Danh mục
        </button>
    </div>

    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-warning text-white"><i class="fas fa-layer-group"></i></div>
                <h3><%= totalRecords %></h3>
                <p class="text-muted mb-0">Tổng số danh mục</p>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-white py-3 d-flex justify-content-between">
            <h6 class="m-0 font-weight-bold text-primary">Danh sách danh mục</h6>
            <span class="text-muted small">Hiển thị <%= start + 1%> - <%= end%> / <%= totalRecords%></span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table admin-table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Tên danh mục</th>
                            <th>Mô tả</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list.isEmpty()) { %>
                            <tr><td colspan="4" class="text-center py-4 text-muted">Chưa có danh mục nào.</td></tr>
                        <% } else {
                            for (Category c : list) {
                        %>
                        <tr>
                            <td><%= c.getId()%></td>
                            <td class="fw-bold text-primary"><%= c.getName()%></td>
                            <td><%= c.getDescription() != null ? c.getDescription() : "" %></td>
                            <td>
                                <button class="btn btn-sm btn-warning me-1" 
                                        onclick="openEditModal('<%= c.getId()%>', '<%= c.getName()%>', '<%= c.getDescription()%>')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-danger" onclick="confirmDelete(<%= c.getId()%>)">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                        </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <% if (totalPages > 1) { %>
        <div class="card-footer bg-white py-3">
            <nav>
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage - 1%>">Trước</a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <li class="page-item <%= i == currentPage ? "active" : ""%>">
                        <a class="page-link" href="?page=<%= i%>"><%= i%></a>
                    </li>
                    <% } %>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage + 1%>">Sau</a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
    </div>
</div>

<div class="modal fade" id="addCategoryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../AddCategoryServlet" method="post">
                <input type="hidden" name="userType" value="admin">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Thêm Danh mục Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Tên danh mục</label>
                        <input type="text" class="form-control" name="categoryName" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" name="categoryDescription" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editCategoryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../EditCategoryServlet" method="post">
                <input type="hidden" name="userType" value="admin">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">Cập nhật Danh mục</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="editCategoryId" name="categoryId">
                    <div class="mb-3">
                        <label class="form-label">Tên danh mục</label>
                        <input type="text" class="form-control" id="editCategoryName" name="categoryName" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" id="editCategoryDescription" name="categoryDescription" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning">Cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    function openEditModal(id, name, desc) {
        document.getElementById('editCategoryId').value = id;
        document.getElementById('editCategoryName').value = name;
        document.getElementById('editCategoryDescription').value = (desc && desc !== 'null') ? desc : '';
        new bootstrap.Modal(document.getElementById('editCategoryModal')).show();
    }

    function confirmDelete(id) {
        Swal.fire({
            title: 'Xóa danh mục?',
            text: "Cảnh báo: Sách thuộc danh mục này có thể bị ảnh hưởng!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            confirmButtonText: 'Xóa ngay'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = "../DeleteCategoryServlet?categoryId=" + id + "&userType=admin";
            }
        });
    }
</script>