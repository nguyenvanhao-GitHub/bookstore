<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.SubscriberDAO" %>
<%@ page import="entity.Subscriber" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<%
    SubscriberDAO subDAO = new SubscriberDAO();

    // 1. Phân trang
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) { currentPage = 1; }

    int totalRecords = subDAO.countSubscribers();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);

    // 2. Lấy dữ liệu
    List<Subscriber> subs = subDAO.getPaginatedSubscribers(start, recordsPerPage);
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<script>document.querySelector('a[href="subscriber.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-bell"></i> Subscriber Management</h2>
        <button class="btn btn-primary" onclick="composeToAll()">
            <i class="fas fa-paper-plane"></i> Send Newsletter to All
        </button>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="card-title mb-0">All Subscribers</h5>
            <div class="text-muted small">
                Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> subscribers
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Email</th>
                            <th>Subscribed Date</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (subs.isEmpty()) {
                                out.println("<tr><td colspan='4' class='text-center py-4 text-muted'>No subscribers found.</td></tr>");
                            } else {
                                for (Subscriber s : subs) {
                        %>
                        <tr>
                            <td>#<%= s.getId() %></td>
                            <td>
                                <span class="fw-bold text-primary"><%= s.getEmail() %></span>
                            </td>
                            <td><%= s.getSubscribedAt() != null ? sdf.format(s.getSubscribedAt()) : "N/A" %></td>
                            <td class="text-end">
                                <button class="btn btn-sm btn-outline-primary me-1" onclick="composeTo('<%= s.getEmail() %>')">
                                    <i class="fas fa-envelope"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger" onclick="confirmDelete(<%= s.getId() %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <% 
                                } 
                            } 
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <% if (totalPages > 1) { %>
        <div class="card-footer bg-white py-3">
            <nav aria-label="Subscriber Pagination">
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

<div class="modal fade" id="composeModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="../SendNewsletterServlet" method="post">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-envelope-open-text"></i> Compose Newsletter</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">To:</label>
                        <input type="text" name="recipients" id="recipients" class="form-control" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Subject:</label>
                        <input type="text" name="subject" class="form-control" required placeholder="Enter newsletter subject...">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Message:</label>
                        <textarea name="message" class="form-control" rows="6" required placeholder="Enter HTML or text content..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Send</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    // Hàm xóa subscriber
    function confirmDelete(id) {
        Swal.fire({
            title: 'Unsubscribe?',
            text: "Remove this email from newsletter list?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            confirmButtonText: 'Yes, remove'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '../DeleteSubscriberServlet?id=' + id;
            }
        });
    }

    // Hàm mở modal soạn mail cho 1 người
    function composeTo(email) {
        document.getElementById('recipients').value = email;
        new bootstrap.Modal(document.getElementById('composeModal')).show();
    }

    // Hàm mở modal soạn mail cho tất cả (Lấy danh sách từ bảng)
    function composeToAll() {
        const emails = Array.from(document.querySelectorAll('table tbody tr td:nth-child(2) span'))
            .map(span => span.textContent.trim())
            .join(', ');
            
        if (!emails) {
            Swal.fire('No subscribers', 'List is empty.', 'info');
            return;
        }

        document.getElementById('recipients').value = emails;
        new bootstrap.Modal(document.getElementById('composeModal')).show();
    }
    
    // Logic Flash Message
    <% 
        String alertIcon = (String) session.getAttribute("alertIcon");
        String alertTitle = (String) session.getAttribute("alertTitle");
        String alertMessage = (String) session.getAttribute("alertMessage");

        // XÓA thuộc tính alert khỏi Session (đảm bảo không lặp lại)
        if (alertIcon != null) {
            session.removeAttribute("alertIcon");
            session.removeAttribute("alertTitle");
            session.removeAttribute("alertMessage");
    %>
        Swal.fire({ 
            icon: '<%= alertIcon %>', 
            title: '<%= alertTitle %>', 
            text: '<%= alertMessage != null ? alertMessage : "Thao tác hoàn thành." %>', 
            timer: 2500, 
            showConfirmButton: false 
        });
    <% } %>
</script>