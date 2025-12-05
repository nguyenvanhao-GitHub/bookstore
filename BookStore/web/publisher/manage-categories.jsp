<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.CategoryDAO, entity.Category, java.util.List" %>
<%@ include file="header.jsp" %>

<%
    CategoryDAO dao = new CategoryDAO();
    List<Category> allCategories = dao.getAllCategories();
    
    // 1. Pagination Setup (Simple)
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) {}

    int totalRecords = allCategories.size();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    
    // Adjust currentPage if it exceeds totalPages
    if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
    }

    // Calculate start and end index for subList
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);

    // Get categories for current page (Sublist)
    List<Category> list = allCategories.subList(start, end);

%>

<div class="publisher-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mt-4 mb-4">
            <h2 class="fw-bold text-secondary"><i class="fas fa-tags me-2"></i> Manage Categories</h2>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                <i class="fas fa-plus me-1"></i> Add Category
           
            </button>
        </div>

        <div class="card shadow border-0">
            <div class="card-header bg-white py-3">
                <div class="text-muted small">
                    Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> danh mục
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 text-center">
                        
                        <thead class="bg-light">
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
       
                                <th>Description</th>
                                <th>Actions</th>
                            </tr>
               
                        </thead>
                        <tbody>
                            <%
                                if (list.isEmpty()) {
                            %>
                                <tr><td colspan="4" class="text-center text-muted py-3">No categories found.</td></tr>
                            
                            <%  } else {
                                    for (Category c : list) {
                            %>
                           
                            <tr>
                                <td><%= c.getId() %></td>
                                <td class="fw-bold text-primary"><%= c.getName() %></td>
                             
                                <td><%= c.getDescription() %></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-warning edit-btn me-1" 
                     
                                            data-id="<%= c.getId() %>" 
                                            data-name="<%= c.getName() %>" 
                           
                                            data-description="<%= c.getDescription() %>"
                                            data-bs-toggle="modal" data-bs-target="#editCategoryModal">
                                    
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    
                      
                                    <button class="btn btn-sm btn-outline-danger delete-btn" data-id="<%= c.getId() %>">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
 
                                </td>
                            </tr>
                            <%      } 
      
                            } 
                            %>
                        </tbody>
                    </table>
 
                </div>
            </div>

            <% if (totalPages > 1) { %>
            <div class="card-footer bg-white py-3">
                <nav aria-label="Category Pagination">
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

<div class="modal fade" id="addCategoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../AddCategoryServlet" method="post">
                <div class="modal-header bg-primary text-white">
         
                    <h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i> Add New Category</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
    
                        <label class="form-label">Category Name</label>
                        <input type="text" class="form-control" name="categoryName" required>
                    </div>
                    <div class="mb-3">
         
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="categoryDescription" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
    
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Category</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editCategoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      
        <div class="modal-content">
            <form action="../EditCategoryServlet" method="post">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i> Edit Category</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
               
                </div>
                <div class="modal-body">
                    <input type="hidden" id="editCategoryId" name="categoryId">
                    
                    <div class="mb-3">
                  
                        <label class="form-label">Category Name</label>
                        <input type="text" class="form-control" id="editCategoryName" name="categoryName" required>
                    </div>
                    <div class="mb-3">
                      
                        <label class="form-label">Description</label>
                        <textarea class="form-control" id="editCategoryDescription" name="categoryDescription" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning">Update Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        
        document.querySelector('a[href="manage-categories.jsp"]').classList.add('active');

        // 1. Xử lý 
        // điền dữ liệu vào Edit Modal
        const editModal = document.getElementById('editCategoryModal');
        editModal.addEventListener('show.bs.modal', function(event) {
            // Button that triggered the modal
            const btn = event.relatedTarget;
            
            // Extract info from data-* attributes
            const id = btn.getAttribute('data-id');
            const name = btn.getAttribute('data-name');
       
            const desc = btn.getAttribute('data-description');
            
            // Update the modal's content
            document.getElementById('editCategoryId').value = id;
            document.getElementById('editCategoryName').value = name;
            document.getElementById('editCategoryDescription').value = desc;
        });
        // 2. Xử lý xóa Category
        document.querySelectorAll(".delete-btn").forEach(btn => {
            btn.addEventListener("click", function() {
                let id = this.getAttribute("data-id");
                
                Swal.fire({
                    
                    title: 'Delete this category?',
                    text: "Warning: This might affect books assigned to this category.",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
     
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Yes, delete it!'
                }).then((result) => {
                    if (result.isConfirmed) {
                     
                        window.location.href = "../DeleteCategoryServlet?categoryId=" + id;
                    }
                });
            });
        });
        // 3. Hiển thị thông báo kết quả (nếu có từ Servlet trả về qua Session)
        <% 
            String alertIcon = (String) session.getAttribute("alertIcon");
            if (alertIcon != null) {
                String title = (String) session.getAttribute("alertTitle");
                String msg = (String) session.getAttribute("alertMessage");
                session.removeAttribute("alertIcon"); 
                session.removeAttribute("alertTitle"); 
                session.removeAttribute("alertMessage");
        %>
            Swal.fire({
                icon: '<%= alertIcon %>',
                title: '<%= title %>',
                text: '<%= msg %>',
                timer: 2000,
      
                showConfirmButton: false
            });
        <% } %>
    });
</script>