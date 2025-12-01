<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<style>
    body {
        background: #f6f9fc;
        font-family: "Segoe UI", sans-serif;
    }
    .admin-main {
        padding: 40px;
    }
    h2 i {
        background: linear-gradient(45deg, #6a11cb, #2575fc);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .card {
        border: none;
        border-radius: 20px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.08);
    }
    .table thead {
        background: linear-gradient(45deg, #2575fc, #6a11cb);
        color: white;
    }
    .table tbody tr:hover {
        background: rgba(37,117,252,0.05);
    }
    .btn-outline-danger {
        border-radius: 50px;
        padding: 6px 14px;
    }
    .swal2-popup {
        border-radius: 20px !important;
    }
</style>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><i class="fas fa-star me-2"></i>Quản lý đánh giá</h2>
        <span class="text-muted fst-italic">📅 Các phản hồi mới nhất từ khách hàng</span>
    </div>

    <div class="card">
        <div class="card-body">
            <h5 class="card-title mb-4 text-primary fw-semibold">
                <i class="fas fa-comments me-2"></i>Danh sách đánh giá sản phẩm
            </h5>

            <div class="table-responsive">
                <table id="reviewsTable" class="table align-middle text-center table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người dùng</th>
                            <th>Sách</th>
                            <th>Đánh giá</th>
                            <th>Bình luận</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(
                                    "SELECT r.id, r.user_email, b.name AS book_name, r.rating, r.comment, r.created_at " +
                                    "FROM reviews r JOIN books b ON r.book_id = b.id ORDER BY r.created_at DESC"
                                );
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                                while (rs.next()) {
                                    int rating = rs.getInt("rating");
                        %>
                        <tr>
                            <td><strong class="text-secondary"><%= rs.getInt("id") %></strong></td>
                            <td><i class="fas fa-user text-info me-1"></i><%= rs.getString("user_email") %></td>
                            <td><i class="fas fa-book text-success me-1"></i><%= rs.getString("book_name") %></td>
                            <td>
                                <% for (int i = 1; i <= 5; i++) { %>
                                    <i class="fa<%= (i <= rating) ? "s" : "r" %> fa-star text-warning"></i>
                                <% } %>
                                <span class="badge bg-light text-dark ms-2"><%= rating %>/5</span>
                            </td>
                            <td class="text-start text-truncate" style="max-width: 260px;" title="<%= rs.getString("comment") %>">
                                <%= rs.getString("comment") %>
                            </td>
                            <td class="text-muted"><%= sdf.format(rs.getTimestamp("created_at")) %></td>
                            <td>
                                <button class="btn btn-sm btn-outline-danger" 
                                        onclick="confirmDelete(<%= rs.getInt("id") %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                                conn.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7' class='text-danger fw-bold text-center'>Lỗi: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    // Datatables setup
    new DataTable('#reviewsTable', {
        pageLength: 8,
        language: {
            search: "🔍 Tìm kiếm:",
            lengthMenu: "Hiển thị _MENU_ dòng",
            info: "Đang hiển thị _START_ - _END_ / _TOTAL_",
            paginate: { previous: "←", next: "→" }
        }
    });

    // SweetAlert confirm delete
    function confirmDelete(id) {
        Swal.fire({
            title: "Xác nhận xóa?",
            text: "Hành động này không thể hoàn tác!",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#d33",
            cancelButtonColor: "#3085d6",
            confirmButtonText: "Xóa",
            cancelButtonText: "Hủy"
        }).then((result) => {
            if (result.isConfirmed) {
                window.location = "../DeleteReviewServlet?id=" + id;
            }
        });
    }

    // Hiển thị thông báo sau redirect
    <% 
        String status = (String) session.getAttribute("deleteStatus");
        String msg = (String) session.getAttribute("deleteMessage");
        if (status != null && msg != null) {
            session.removeAttribute("deleteStatus");
            session.removeAttribute("deleteMessage");
    %>
        Swal.fire({
            icon: "<%= status.equals("success") ? "success" : (status.equals("failed") ? "info" : "error") %>",
            title: "<%= msg %>",
            timer: 1800,
            showConfirmButton: false
        });
    <% } %>
</script>
