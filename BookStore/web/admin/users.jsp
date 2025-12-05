<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.AccountDAO" %>
<%@ page import="dao.AccountDAO.AccountDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="header.jsp" %>

<script>document.querySelector('a[href="users.jsp"]').classList.add('active');</script>

<%
    // 1. Phân trang & Tìm kiếm
    int currentPage = 1;
    int recordsPerPage = 10;
    String search = request.getParameter("search");
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) {}

    // 2. Lấy dữ liệu từ DAO
    AccountDAO dao = new AccountDAO();
    int totalRecords = dao.countAllAccounts(search);
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    List<AccountDTO> users = dao.getAllAccounts(currentPage, recordsPerPage, search);
%>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-users-cog"></i> Quản Lý Tài Khoản</h2>
    </div>

    <div class="card mb-4 border-warning border-start border-4 shadow-sm">
        <div class="card-body d-flex justify-content-between align-items-center flex-wrap gap-3">
            <div>
                <h5 class="card-title text-warning mb-1"><i class="fas fa-user-clock"></i> Khóa Tài Khoản Không Hoạt Động</h5>
                <p class="mb-0 text-muted small">
                    Hệ thống sẽ tự động khóa các tài khoản không đăng nhập trong vòng <strong>90 ngày</strong>.
                </p>
            </div>
            <form action="../ManageAccountsServlet" method="post" class="d-flex align-items-center gap-2">
                <input type="hidden" name="action" value="autolock">
                <input type="hidden" name="daysInactive" value="90">
                
                <button class="btn btn-warning text-dark fw-bold" onclick="return confirm('Bạn có chắc muốn chạy quy trình khóa các tài khoản không hoạt động trên 90 ngày?')">
                    <i class="fas fa-bolt"></i> Chạy Ngay
                </button>
            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addUserModal">
                <i class="fas fa-plus-circle"></i> Thêm User Mới
            </button>
            
            <form class="d-flex" method="get">
                <input type="text" name="search" class="form-control me-2" placeholder="Tìm theo tên, email..." value="<%= search != null ? search : "" %>">
                <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i></button>
            </form>
        </div>

        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 text-center">
                    <thead class="bg-light text-secondary">
                        <tr>
                            <th>Loại</th>
                            <th class="text-start">Thông Tin User</th>
                            <th>Vai Trò</th>
                            <th>Trạng Thái</th>
                            <th>Đăng Nhập Cuối</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (users.isEmpty()) {
                        %>
                            <tr><td colspan="6" class="text-center py-5 text-muted"><i class="fas fa-inbox fa-2x mb-2"></i><br>Không tìm thấy tài khoản nào.</td></tr>
                        <%
                        } else {
                            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                            for (AccountDTO u : users) {
                                boolean isLocked = "Locked".equalsIgnoreCase(u.status);
                                String badgeClass = "admin".equals(u.source) ? "danger" : "publisher".equals(u.source) ? "warning text-dark" : "secondary";
                        %>
                        <tr class="<%= isLocked ? "table-danger" : "" %>">
                            <td><span class="badge bg-<%= badgeClass %>"><%= u.source.toUpperCase() %></span></td>
                            <td class="text-start">
                                <div class="fw-bold text-dark"><%= u.name %></div>
                                <div class="small text-muted"><i class="far fa-envelope me-1"></i><%= u.email %></div>
                            </td>
                            <td><%= u.role %></td>
                            <td>
                                <% if (isLocked) { %>
                                    <span class="badge bg-danger mb-1"><i class="fas fa-lock"></i> Locked</span>
                                    <% if (u.lockReason != null) { %>
                                        <div class="small text-danger" style="font-size: 0.75rem; max-width: 150px; margin: 0 auto;" title="<%= u.lockReason %>">
                                            <%= u.lockReason.length() > 20 ? u.lockReason.substring(0, 18) + "..." : u.lockReason %>
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <span class="badge bg-success">Active</span>
                                <% } %>
                            </td>
                            <td class="small text-muted">
                                <%= u.lastLogin != null ? sdf.format(u.lastLogin) : "Chưa từng" %>
                            </td>
                            <td>
                                <div class="btn-group shadow-sm">
                                    <button class="btn btn-sm btn-outline-primary" title="Sửa thông tin"
                                            onclick="fillEditForm('<%= u.source %>', <%= u.id %>, '<%= u.name %>', '<%= u.email %>', '<%= u.role %>', '<%= u.contact %>', '<%= u.gender %>')">
                                        <i class="fas fa-edit"></i>
                                    </button>

                                    <% if (!isLocked) { %>
                                        <button class="btn btn-sm btn-outline-warning" 
                                                onclick="lockAccount('<%= u.source %>', <%= u.id %>)" 
                                                title="Khóa tài khoản">
                                            <i class="fas fa-lock"></i>
                                        </button>
                                    <% } else { %>
                                        <form action="../ManageAccountsServlet" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="unlock">
                                            <input type="hidden" name="targetTable" value="<%= u.source %>">
                                            <input type="hidden" name="id" value="<%= u.id %>">
                                            <button class="btn btn-sm btn-outline-success" title="Mở khóa">
                                                <i class="fas fa-unlock"></i>
                                            </button>
                                        </form>
                                    <% } %>

                                    <form action="../ManageAccountsServlet" method="post" class="d-inline" onsubmit="return confirm('Reset mật khẩu cho user này? Mật khẩu mới sẽ gửi qua email.')">
                                        <input type="hidden" name="action" value="reset">
                                        <input type="hidden" name="targetTable" value="<%= u.source %>">
                                        <input type="hidden" name="id" value="<%= u.id %>">
                                        <button class="btn btn-sm btn-outline-info" title="Cấp lại mật khẩu">
                                            <i class="fas fa-key"></i>
                                        </button>
                                    </form>

                                    <form action="../ManageAccountsServlet" method="post" class="d-inline" onsubmit="return confirm('CẢNH BÁO: Hành động này không thể hoàn tác! Xóa tài khoản?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="targetTable" value="<%= u.source %>">
                                        <input type="hidden" name="id" value="<%= u.id %>">
                                        <button class="btn btn-sm btn-outline-danger" title="Xóa">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% 
                            }
                        } 
                        %>
                    </tbody>
                </table>
            </div>
            
            <% if (totalPages > 1) { %>
            <div class="card-footer bg-white py-3">
                <nav>
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage - 1 %>&search=<%= search != null ? search : "" %>">Trước</a>
                        </li>
                        <li class="page-item disabled"><span class="page-link">Trang <%= currentPage %> / <%= totalPages %></span></li>
                        <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage + 1 %>&search=<%= search != null ? search : "" %>">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../ManageAccountsServlet" method="post">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title"><i class="fas fa-user-plus me-2"></i> Thêm Người Dùng Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="add">
                    <div class="mb-3">
                        <label class="form-label">Loại Tài Khoản</label>
                        <select name="targetTable" class="form-select">
                            <option value="user">Khách hàng (User)</option>
                            <option value="publisher">Nhà xuất bản (Publisher)</option>
                            <option value="admin">Quản trị viên (Admin)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Họ và Tên</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <input type="hidden" name="role" value="user">
                    <input type="hidden" name="status" value="Active">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-success">Tạo Mới</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../ManageAccountsServlet" method="post">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i> Chỉnh Sửa Tài Khoản</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="targetTable" id="editTargetTable">
                    <input type="hidden" name="id" id="editId">
                    
                    <div class="mb-3">
                        <label class="form-label">Họ và Tên</label>
                        <input type="text" name="name" id="editName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" id="editEmail" class="form-control" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Vai Trò</label>
                            <input type="text" name="role" id="editRole" class="form-control">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Giới Tính</label>
                            <select name="gender" id="editGender" class="form-select">
                                <option value="Male">Nam</option>
                                <option value="Female">Nữ</option>
                                <option value="Other">Khác</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Liên Hệ</label>
                        <input type="text" name="contact" id="editContact" class="form-control">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    // Điền thông tin vào Modal Edit
    function fillEditForm(table, id, name, email, role, contact, gender) {
        document.getElementById("editTargetTable").value = table;
        document.getElementById("editId").value = id;
        document.getElementById("editName").value = name;
        document.getElementById("editEmail").value = email;
        document.getElementById("editRole").value = role;
        document.getElementById("editContact").value = (contact && contact !== 'null') ? contact : '';
        document.getElementById("editGender").value = (gender && gender !== 'null') ? gender : 'Other';
        
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }

    // Xử lý nút Lock với Popup nhập lý do
    function lockAccount(table, id) {
        Swal.fire({
            title: 'Khóa tài khoản này?',
            input: 'text',
            inputLabel: 'Lý do khóa (bắt buộc)',
            inputPlaceholder: 'VD: Vi phạm chính sách, spam...',
            showCancelButton: true,
            confirmButtonText: 'Khóa Ngay',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#d33',
            preConfirm: (reason) => {
                if (!reason) {
                    Swal.showValidationMessage('Vui lòng nhập lý do để tiếp tục!');
                }
                return reason;
            }
        }).then((result) => {
            if (result.isConfirmed) {
                // Tạo form ẩn để gửi dữ liệu
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '../ManageAccountsServlet';
                
                const inputs = {
                    'action': 'lock',
                    'targetTable': table,
                    'id': id,
                    'lockReason': result.value
                };
                for (const [key, value] of Object.entries(inputs)) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = key;
                    input.value = value;
                    form.appendChild(input);
                }
                
                document.body.appendChild(form);
                form.submit();
            }
        });
    }

    // Hiển thị thông báo kết quả (Toast) từ Session (LOGIC NÀY ĐÃ ĐÚNG)
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
            timer: 2500,
            showConfirmButton: false
        });
    <% } %>
</script>