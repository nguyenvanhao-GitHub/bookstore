<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ContactDAO" %>
<%@ page import="entity.ContactMessage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<%
    ContactDAO contactDAO = new ContactDAO();

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

    int totalRecords = contactDAO.countMessages();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);

    if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
    }
    if (currentPage < 1) {
        currentPage = 1;
    }

    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);

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
                Hiển thị <%= totalRecords > 0 ? start + 1 : 0%> - <%= end%> / <%= totalRecords%> tin nhắn
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
                        <td>#<%= msg.getId()%></td>
                        <td><%= msg.getName()%></td>
                        <td><%= msg.getEmail()%></td>
                        <td><%= msg.getSubject()%></td>
                        <td class="text-truncate" style="max-width: 200px;"><%= msg.getMessage()%></td>
                        <td><%= sdf.format(msg.getSubmittedAt())%></td>
                        <td>
                        <button class="btn btn-sm btn-primary me-1" onclick="composeTo('<%= msg.getEmail()%>', 'Re: <%= msg.getSubject()%>')">
                            <i class="fas fa-reply"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="confirmDelete(<%= msg.getId()%>)">
                            <i class="fas fa-trash"></i>
                        </button>
                        </td>
                        </tr>
                        <% }
                            } %>
                    </tbody>
                </table>
            </div>
        </div>

        <% if (totalPages > 1) {%>
        <div class="card-footer bg-white py-3">
            <nav aria-label="Contact Pagination">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage - 1%>&records=<%= recordsPerPage%>">Previous</a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) {%>
                    <li class="page-item <%= i == currentPage ? "active" : ""%>">
                        <a class="page-link" href="?page=<%= i%>&records=<%= recordsPerPage%>"><%= i%></a>
                    </li>
                    <% }%>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                        <a class="page-link" href="?page=<%= currentPage + 1%>&records=<%= recordsPerPage%>">Next</a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
    </div>
</div>
<div class="modal fade" id="composeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">
                    <i class="fas fa-reply me-2"></i> Reply to Message
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <form action="<%= request.getContextPath() %>/ReplyContactMessageServlet" method="post">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold"><i class="fas fa-user me-1"></i> To:</label>
                        <input type="email" class="form-control" id="recipients" name="recipients" readonly required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold"><i class="fas fa-heading me-1"></i> Subject:</label>
                        <input type="text" class="form-control" id="composeSubject" name="subject" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold"><i class="fas fa-envelope me-1"></i> Message:</label>
                        <textarea class="form-control" name="message" rows="6" placeholder="Type your reply here..." required></textarea>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane me-1"></i> Send Reply
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    function confirmDelete(id) {
        Swal.fire({
            title: 'Xóa tin nhắn này?',
            text: "Hành động này không thể hoàn tác!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Xóa ngay',
            cancelButtonText: 'Hủy'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '<%= request.getContextPath() %>/DeleteContactMessageServlet?id=' + id;
            }
        });
    }

    function composeTo(email, subject = '') {
        document.getElementById('recipients').value = email;
        
        if (subject) {
            document.getElementById('composeSubject').value = subject;
        } else {
            document.getElementById('composeSubject').value = "";
        }

        var myModal = new bootstrap.Modal(document.getElementById('composeModal'));
        myModal.show();
    }

    document.addEventListener("DOMContentLoaded", function () {
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
                icon: '<%= alertIcon%>',
                title: '<%= title%>',
                text: '<%= msg%>',
                timer: 2500,
                showConfirmButton: false
            });
        <% }%>
    });
</script>

