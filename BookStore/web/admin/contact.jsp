<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ContactDAO" %>
<%@ page import="entity.ContactMessage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<%
    ContactDAO contactDAO = new ContactDAO();

    // 1. Phân trang
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) { currentPage = 1; }

    int totalRecords = contactDAO.countMessages();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);

    // 2. Lấy dữ liệu
    List<ContactMessage> messages = contactDAO.getPaginatedMessages(start, recordsPerPage);
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<script>document.querySelector('a[href="contact.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-envelope"></i> Contact Messages</h2>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="card-title mb-0">All Messages</h5>
            <div class="text-muted small">
                Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> tin nhắn
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table admin-table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Subject</th>
                            <th>Message</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (messages.isEmpty()) {
                                out.println("<tr><td colspan='7' class='text-center py-4 text-muted'>No contact messages found.</td></tr>");
                            } else {
                                for (ContactMessage msg : messages) {
                        %>
                        <tr>
                            <td>#<%= msg.getId() %></td>
                            <td><%= msg.getName() %></td>
                            <td><%= msg.getEmail() %></td>
                            <td><%= msg.getSubject() %></td>
                            <td class="text-truncate" style="max-width: 200px;"><%= msg.getMessage() %></td>
                            <td><%= sdf.format(msg.getSubmittedAt()) %></td>
                            <td>
                                <button class="btn btn-sm btn-primary me-1" onclick="composeTo('<%= msg.getEmail() %>', 'Re: <%= msg.getSubject() %>')">
                                    <i class="fas fa-reply"></i>
                                </button>
                                <button class="btn btn-sm btn-danger" onclick="confirmDelete(<%= msg.getId() %>)">
                                    <i class="fas fa-trash"></i>
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
            <nav aria-label="Contact Pagination">
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
            title: 'Delete this message?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            confirmButtonText: 'Yes'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '../DeleteContactMessageServlet?id=' + id;
            }
        });
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
    
    // Hàm composeTo giữ nguyên
    function composeTo(email, subject) {
        Swal.fire({
            title: 'Reply to Message',
            html: 
                '<form id="replyForm" action="../ReplyContactMessageServlet" method="post">' +
                '<input type="hidden" name="recipients" value="' + email + '">' +
                '<div class="mb-3 text-start">' +
                '<label class="form-label">To:</label>' +
                '<input type="text" class="form-control" value="' + email + '" readonly>' +
                '</div>' +
                '<div class="mb-3 text-start">' +
                '<label class="form-label">Subject:</label>' +
                '<input type="text" name="subject" class="form-control" value="' + subject + '" required>' +
                '</div>' +
                '<div class="mb-3 text-start">' +
                '<label class="form-label">Message (HTML content supported):</label>' +
                '<textarea name="message" class="form-control" rows="5" required></textarea>' +
                '</div>' +
                '</form>',
            showCancelButton: true,
            confirmButtonText: 'Send Reply',
            showLoaderOnConfirm: true,
            preConfirm: () => {
                const form = document.getElementById('replyForm');
                if (form.checkValidity()) {
                    form.submit(); 
                    return true;
                } else {
                    Swal.showValidationMessage('Vui lòng điền đủ thông tin.');
                    return false;
                }
            },
            allowOutsideClick: () => !Swal.isLoading()
        });
    }
</script>