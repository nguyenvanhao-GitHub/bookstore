<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ReviewDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<%
    ReviewDAO reviewDAO = new ReviewDAO();

    // 1. Phân trang (Tính toán OFFSET an toàn)
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) { currentPage = 1; }

    int totalRecords = reviewDAO.getTotalReviewsCount();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    int start = (currentPage - 1) * recordsPerPage; // Vị trí OFFSET
    if (start < 0) start = 0; 
    
    int end = Math.min(start + recordsPerPage, totalRecords);

    // 2. Lấy dữ liệu
    List<Map<String, Object>> reviews = null;
    try {
        // [ĐÃ SỬA LỖI] Truyền OFFSET (start) và LIMIT (recordsPerPage)
        reviews = reviewDAO.getAllReviewsWithDetails(start, recordsPerPage); 
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<script>document.querySelector('a[href="reviews.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><i class="fas fa-star me-2"></i>Reviews Management</h2>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="card-title mb-0">All Reviews</h5>
            <div class="text-muted small">
                Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> đánh giá
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table id="reviewsTable" class="table align-middle text-center table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Book</th>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (reviews != null && !reviews.isEmpty()) {
                                for (Map<String, Object> r : reviews) {
                                    
                                    // Đảm bảo rating là int
                                    int rating = 0;
                                    Object ratingObj = r.get("rating");
                                    if (ratingObj instanceof Integer) {
                                        rating = (Integer) ratingObj;
                                    }
                        %>
                        <tr>
                            <td><strong>#<%= r.get("id") %></strong></td>
                            <td><%= r.get("userEmail") %></td>
                            <td class="text-primary"><%= r.get("bookName") %></td>
                            <td>
                                <% 
                                for (int i = 1; i <= 5; i++) { 
                                %>
                                    <i class="fa<%= (i <= rating) ? "s" : "r" %> fa-star text-warning"></i> 
                                <% 
                                } %>
                            </td>
                            <td class="text-start text-truncate" style="max-width: 250px;">
                                <%= r.get("comment") %>
                            </td>
                            <td><%= sdf.format(r.get("createdAt")) %></td>
                            <td>
                                <button class="btn btn-sm btn-outline-danger" onclick="confirmDelete(<%= r.get("id") %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <% } 
                        } else {
                            out.println("<tr><td colspan='7' class='text-center py-4 text-muted'>No reviews found.</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <% if (totalPages > 1) { %>
        <div class="card-footer bg-white py-3">
            <nav aria-label="Review Pagination">
                <ul class="pagination justify-content-center mb-0">
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
        <% } %>
        </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    function confirmDelete(id) {
        Swal.fire({
            title: "Delete this review?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#d33",
            confirmButtonText: "Delete"
        }).then((result) => {
            if (result.isConfirmed) {
                window.location = "../DeleteReviewServlet?id=" + id;
            }
        });
    }
    
    // LOGIC FLASH MESSAGE (Xử lý cả 2 loại thông báo)
    <% 
        // 1. Lấy tất cả thông báo
        String alertIcon = (String) session.getAttribute("alertIcon");
        String alertTitle = (String) session.getAttribute("alertTitle");
        String alertMessage = (String) session.getAttribute("alertMessage");
        
        String delStatus = (String) session.getAttribute("deleteStatus");
        String delMessage = (String) session.getAttribute("deleteMessage");

        // 2. XÓA TẤT CẢ thuộc tính alert khỏi Session (đảm bảo không lặp lại)
        if (alertIcon != null || delStatus != null) {
            session.removeAttribute("alertIcon");
            session.removeAttribute("alertTitle");
            session.removeAttribute("alertMessage");
            session.removeAttribute("deleteStatus");
            session.removeAttribute("deleteMessage");
        }
        
        // 3. Quyết định thông báo hiển thị
        String iconToDisplay = null;
        String titleToDisplay = null;
        String messageToDisplay = null;
        
        if (alertIcon != null) { // Ưu tiên thông báo chung
            iconToDisplay = alertIcon;
            titleToDisplay = alertTitle;
            messageToDisplay = alertMessage;
        } else if (delStatus != null) { // Thông báo cụ thể từ DeleteReviewServlet
            iconToDisplay = delStatus.equals("success") ? "success" : "error";
            titleToDisplay = "Action Completed";
            messageToDisplay = delMessage;
        }

        if (iconToDisplay != null) {
    %>
        Swal.fire({ 
            icon: '<%= iconToDisplay %>', 
            title: '<%= titleToDisplay %>', 
            text: '<%= messageToDisplay != null ? messageToDisplay : "Thao tác hoàn thành." %>', 
            timer: 2500, 
            showConfirmButton: false 
        });
    <% } %>
</script>
</body>
</html>