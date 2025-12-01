<%@page import="jakarta.mail.Transport"%>
<%@page import="jakarta.mail.internet.InternetAddress"%>
<%@page import="jakarta.mail.internet.MimeMessage"%>
<%@page import="jakarta.mail.Session"%>
<%@page import="jakarta.mail.Message"%>
<%@page import="jakarta.mail.PasswordAuthentication"%>
<%@page import="jakarta.mail.Authenticator"%>
<%@ page import="java.sql.*, java.security.*, java.util.*, java.util.Base64" %>
<%@ include file="header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
    public String generateSalt() {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            return Base64.getEncoder().encodeToString(salt);
        } catch (Exception e) {
            return "defaultSalt";
        }
    }
 
    public String hashPassword(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes());
            byte[] hashed = md.digest(password.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(hashed);
        } catch (Exception e) {
            return password;
        }
    }

    public String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$!";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    public void sendEmail(String toEmail, String subject, String body) {
        final String fromEmail = "haonguyen2004hy@gmail.com";
        final String password = "ejpk uhrq byde nxyn";

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(fromEmail, "BookStore"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setText(body);
            Transport.send(msg);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int autoLockInactiveAccounts(Connection con, int daysInactive) throws SQLException {
        String[] tables = {"user", "admin", "publisher"};
        int totalLocked = 0;

        for (String table : tables) {
            String sql = "UPDATE `" + table + "` "
                    + "SET status = 'Locked', lock_reason = 'Auto-locked: Inactive for " + daysInactive + " days' "
                    + "WHERE status = 'Active' "
                    + "AND (last_login IS NULL OR last_login < DATE_SUB(NOW(), INTERVAL ? DAY))";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, daysInactive);
                totalLocked += ps.executeUpdate();
            }
        }
        return totalLocked;
    }
%>

<%
    Connection con = null;
    Statement stmt = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String toastType = null, toastMsg = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");

        String action = request.getParameter("action");
        String targetTable = request.getParameter("targetTable");
        if (targetTable == null || targetTable.trim().isEmpty()) {
            targetTable = "user";
        }

        // XỬ LÝ CÁC ACTION
        if ("add".equals(action)) {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String status = request.getParameter("status");
            String contact = request.getParameter("contact");
            String gender = request.getParameter("gender");
            String rawPass = request.getParameter("password");

            String salt = generateSalt();
            String hashed = hashPassword(rawPass, salt);

            String sql = "INSERT INTO `" + targetTable + "` (name,email,password,salt,role,status,contact,gender) VALUES (?,?,?,?,?,?,?,?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, hashed);
            ps.setString(4, salt);
            ps.setString(5, role);
            ps.setString(6, status);
            ps.setString(7, contact);
            ps.setString(8, gender);
            ps.executeUpdate();

            toastType = "success";
            toastMsg = "User added successfully to " + targetTable;

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String role = request.getParameter("role");
            String status = request.getParameter("status");
            String contact = request.getParameter("contact");
            String gender = request.getParameter("gender");

            String sql = "UPDATE `" + targetTable + "` SET name=?, email=?, role=?, status=?, contact=?, gender=? WHERE id=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, role);
            ps.setString(4, status);
            ps.setString(5, contact);
            ps.setString(6, gender);
            ps.setInt(7, id);
            ps.executeUpdate();

            toastType = "info";
            toastMsg = "User updated successfully in " + targetTable;

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "DELETE FROM `" + targetTable + "` WHERE id=?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
            toastType = "error";
            toastMsg = "User deleted from " + targetTable;

        } else if ("reset".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String userEmailReset = null;

            ps = con.prepareStatement("SELECT email FROM `" + targetTable + "` WHERE id=?");
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                userEmailReset = rs.getString("email");
            }
            rs.close();
            ps.close();

            String newPassword = generateRandomPassword(8);
            String newSalt = generateSalt();
            String hashed = hashPassword(newPassword, newSalt);

            String sql = "UPDATE `" + targetTable + "` SET password=?, salt=? WHERE id=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, hashed);
            ps.setString(2, newSalt);
            ps.setInt(3, id);
            ps.executeUpdate();

            if (userEmailReset != null) {
                sendEmail(userEmailReset, "Password Reset", "Your new password: " + newPassword);
            }

            toastType = "warning";
            toastMsg = "Password has been reset and sent to user's email in " + targetTable;

        } else if ("lock".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String lockReason = request.getParameter("lockReason");
            if (lockReason == null || lockReason.trim().isEmpty()) {
                lockReason = "Manually locked by admin";
            }

            String sql = "UPDATE `" + targetTable + "` SET status='Locked', lock_reason=?, locked_at=NOW() WHERE id=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, lockReason);
            ps.setInt(2, id);
            ps.executeUpdate();

            toastType = "warning";
            toastMsg = "Account has been locked";

        } else if ("unlock".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "UPDATE `" + targetTable + "` SET status='Active', lock_reason=NULL, locked_at=NULL WHERE id=?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();

            toastType = "success";
            toastMsg = "Account has been unlocked";

        } else if ("autolock".equals(action)) {
            int daysInactive = Integer.parseInt(request.getParameter("daysInactive"));
            int locked = autoLockInactiveAccounts(con, daysInactive);

            toastType = "info";
            toastMsg = "Auto-locked " + locked + " inactive accounts (>" + daysInactive + " days)";
        }

        // PHÂN TRANG
        int currentPage = 1;
        int recordsPerPage = 10;

        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        String recordsParam = request.getParameter("recordsPerPage");
        if (recordsParam != null) {
            try {
                recordsPerPage = Integer.parseInt(recordsParam);
            } catch (NumberFormatException e) {
                recordsPerPage = 10;
            }
        }

        // ĐẾM TỔNG SỐ BẢN GHI
        stmt = con.createStatement();
        rs = stmt.executeQuery(
                "SELECT COUNT(*) as total FROM ("
                + "SELECT id FROM admin UNION ALL SELECT id FROM user UNION ALL SELECT id FROM publisher"
                + ") as all_users"
        );
        rs.next();
        int totalRecords = rs.getInt("total");
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);

        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }
        if (currentPage < 1) {
            currentPage = 1;
        }

        rs.close();
        stmt.close();

        // LẤY DỮ LIỆU PHÂN TRANG
        int start = (currentPage - 1) * recordsPerPage;

        String query
                = "SELECT * FROM ("
                + "SELECT 'admin' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM admin "
                + "UNION ALL "
                + "SELECT 'user' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM user "
                + "UNION ALL "
                + "SELECT 'publisher' AS source, id, name, email, role, status, contact, gender, last_login, lock_reason, locked_at FROM publisher "
                + ") as combined "
                + "ORDER BY id DESC "
                + "LIMIT " + start + ", " + recordsPerPage;

        stmt = con.createStatement();
        rs = stmt.executeQuery(query);
%>

<!-- ========== GIAO DIỆN ========== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
    body {
        background-color: #f5f6fa;
    }
    .card {
        border-radius: 15px;
    }
    .btn-sm {
        padding: 4px 8px;
        font-size: 14px;
    }
    .table th, .table td {
        vertical-align: middle !important;
    }
    #editForm {
        animation: fadeIn 0.3s ease-in-out;
    }
    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    .locked-row {
        background-color: #ffe6e6 !important;
    }
    .inactive-warning {
        background-color: #fff3cd !important;
    }

    /* Pagination styles */
    .pagination-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 20px;
        flex-wrap: wrap;
        gap: 15px;
    }
    .pagination-info {
        color: #6c757d;
        font-size: 14px;
    }
    .pagination {
        margin-bottom: 0;
    }
    .page-link {
        color: #0d6efd;
        border-radius: 5px;
        margin: 0 2px;
    }
    .page-item.active .page-link {
        background-color: #0d6efd;
        border-color: #0d6efd;
    }
    .records-per-page {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .records-per-page select {
        width: auto;
        display: inline-block;
    }
</style>

<div class="container py-5">
    <div class="card shadow-lg border-0">
        <div class="card-header bg-primary text-white text-center py-3 rounded-top">
            <h3 class="fw-bold mb-0">👤 Account Management</h3>
        </div>
        <div class="card-body p-4">

            <!-- AUTO LOCK PANEL -->
            <div class="alert alert-warning mb-4">
                <h5 class="fw-semibold mb-3">🔒 Auto Lock Inactive Accounts</h5>
                <form method="post" action="users.jsp" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="autolock">
                    <div class="col-md-4">
                        <label class="form-label">Lock accounts inactive for (days):</label>
                        <input type="number" name="daysInactive" class="form-control" value="90" min="1" required>
                    </div>
                    <div class="col-md-8">
                        <button class="btn btn-warning px-4" onclick="return confirm('Are you sure you want to lock all inactive accounts?')">
                            <i class="bi bi-lock-fill"></i> Run Auto Lock
                        </button>
                        <small class="text-muted d-block mt-2">
                            Accounts with no login activity for the specified days will be locked automatically.
                        </small>
                    </div>
                </form>
            </div>

            <!-- ADD USER FORM --> 
            <h5 class="fw-semibold mb-3 text-secondary">➕ Add New User</h5>
            <form method="post" action="users.jsp" class="row g-3 mb-4">
                <input type="hidden" name="action" value="add">
                <div class="col-md-3">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Role</label>
                    <select name="role" class="form-select">
                        <option>User</option><option>Admin</option><option>Publisher</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option>Active</option><option>Inactive</option><option>Locked</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Contact</label>
                    <input type="text" name="contact" class="form-control">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-select">
                        <option>Male</option><option>Female</option><option>Other</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Table</label>
                    <select name="targetTable" class="form-select">
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                        <option value="publisher">Publisher</option>
                    </select>
                </div>
                <div class="col-12 text-end">
                    <button class="btn btn-success px-4 rounded-3">Add User</button>
                </div>
            </form>

            <!-- RECORDS PER PAGE & SEARCH -->
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-3">
                <div class="records-per-page">
                    <label class="form-label mb-0">Show:</label>
                    <select class="form-select form-select-sm" onchange="changeRecordsPerPage(this.value)">
                        <option value="5" <%= recordsPerPage == 5 ? "selected" : ""%>>5</option>
                        <option value="10" <%= recordsPerPage == 10 ? "selected" : ""%>>10</option>
                        <option value="25" <%= recordsPerPage == 25 ? "selected" : ""%>>25</option>
                        <option value="50" <%= recordsPerPage == 50 ? "selected" : ""%>>50</option>
                        <option value="100" <%= recordsPerPage == 100 ? "selected" : ""%>>100</option>
                    </select>
                    <span class="text-muted">records per page</span>
                </div>
                <input type="text" id="searchInput" class="form-control" style="max-width: 300px;" placeholder="🔍 Search users..." onkeyup="searchUsers()">
            </div>

            <!-- TABLE -->
            <div class="table-responsive">
                <table class="table table-striped align-middle text-center" id="usersTable">
                    <thead class="table-primary">
                        <tr>
                        <th>Table</th><th>ID</th><th>Name</th><th>Email</th><th>Role</th>
                        <th>Status</th><th>Last Login</th><th>Contact</th><th>Gender</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                            while (rs.next()) {
                                String status = rs.getString("status");
                                java.sql.Timestamp lastLogin = rs.getTimestamp("last_login");
                                String lockReason = rs.getString("lock_reason");

                                long daysSinceLogin = -1;
                                if (lastLogin != null) {
                                    long diff = System.currentTimeMillis() - lastLogin.getTime();
                                    daysSinceLogin = diff / (1000 * 60 * 60 * 24);
                                }

                                String rowClass = "";
                                if ("Locked".equals(status)) {
                                    rowClass = "locked-row";
                                } else if (daysSinceLogin > 60) {
                                    rowClass = "inactive-warning";
                                }
                        %>
                        <tr class="<%= rowClass%>">
                        <td><%= rs.getString("source")%></td>
                        <td><%= rs.getInt("id")%></td>
                        <td><%= rs.getString("name")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("role")%></td>
                        <td>
                        <span class="badge bg-<%= "Active".equals(status) ? "success" : ("Locked".equals(status) ? "danger" : "secondary")%>">
                            <%= status%>
                        </span>
                        <% if (lockReason != null) {%>
                        <br><small class="text-danger"><%= lockReason%></small>
                        <% }%>
                        </td>
                        <td>
                            <%= lastLogin != null ? sdf.format(lastLogin) : "Never"%>
                            <% if (daysSinceLogin > 0) {%>
                            <br><small class="text-muted">(<%= daysSinceLogin%> days ago)</small>
                            <% }%>
                        </td>
                        <td><%= rs.getString("contact")%></td>
                        <td><%= rs.getString("gender")%></td>
                        <td>
                        <button class="btn btn-sm btn-outline-primary me-1" 
                                onclick="fillEditForm('<%= rs.getString("source")%>', '<%= rs.getInt("id")%>', '<%= rs.getString("name")%>', '<%= rs.getString("email")%>', '<%= rs.getString("role")%>', '<%= status%>', '<%= rs.getString("contact")%>', '<%= rs.getString("gender")%>')">
                            <i class="bi bi-pencil-square"></i>
                        </button>

                        <% if (!"Locked".equals(status)) {%>
                        <button class="btn btn-sm btn-outline-danger me-1" onclick="lockAccount('<%= rs.getString("source")%>', <%= rs.getInt("id")%>)">
                            <i class="bi bi-lock-fill"></i>
                        </button>
                        <% } else {%>
                        <form method="post" action="users.jsp" class="d-inline">
                            <input type="hidden" name="action" value="unlock">
                            <input type="hidden" name="id" value="<%= rs.getInt("id")%>">
                            <input type="hidden" name="targetTable" value="<%= rs.getString("source")%>">
                            <input type="hidden" name="page" value="<%= currentPage%>">
                            <input type="hidden" name="recordsPerPage" value="<%= recordsPerPage%>">
                            <button class="btn btn-sm btn-outline-success me-1">
                                <i class="bi bi-unlock-fill"></i>
                            </button>
                        </form>
                        <% }%>

                        <form method="post" action="users.jsp" class="d-inline">
                            <input type="hidden" name="action" value="reset">
                            <input type="hidden" name="id" value="<%= rs.getInt("id")%>">
                            <input type="hidden" name="targetTable" value="<%= rs.getString("source")%>">
                            <input type="hidden" name="page" value="<%= currentPage%>">
                            <input type="hidden" name="recordsPerPage" value="<%= recordsPerPage%>">
                            <button class="btn btn-sm btn-outline-warning me-1">
                                <i class="bi bi-key"></i>
                            </button>
                        </form>

                        <form method="post" action="users.jsp" class="d-inline" onsubmit="return confirmDelete(event)">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= rs.getInt("id")%>">
                            <input type="hidden" name="targetTable" value="<%= rs.getString("source")%>">
                            <input type="hidden" name="page" value="<%= currentPage%>">
                            <input type="hidden" name="recordsPerPage" value="<%= recordsPerPage%>">
                            <button class="btn btn-sm btn-outline-danger">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                        </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container">
                <div class="pagination-info">
                    Showing <%= Math.min(start + 1, totalRecords)%> to <%= Math.min(start + recordsPerPage, totalRecords)%> of <%= totalRecords%> entries
                </div>

                <nav aria-label="Page navigation">
                    <ul class="pagination">
                        <!-- First Page -->
                        <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                            <a class="page-link" href="?page=1&recordsPerPage=<%= recordsPerPage%>">
                                <i class="bi bi-chevron-double-left"></i>
                            </a>
                        </li>

                        <!-- Previous Page -->
                        <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                            <a class="page-link" href="?page=<%= currentPage - 1%>&recordsPerPage=<%= recordsPerPage%>">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>

                        <!-- Page Numbers -->
                        <%
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);

                            for (int i = startPage; i <= endPage; i++) {
                        %>
                        <li class="page-item <%= i == currentPage ? "active" : ""%>">
                            <a class="page-link" href="?page=<%= i%>&recordsPerPage=<%= recordsPerPage%>"><%= i%></a>
                        </li>
                        <% }%>

                        <!-- Next Page -->
                        <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                            <a class="page-link" href="?page=<%= currentPage + 1%>&recordsPerPage=<%= recordsPerPage%>">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>

                        <!-- Last Page -->
                        <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                            <a class="page-link" href="?page=<%= totalPages%>&recordsPerPage=<%= recordsPerPage%>">
                                <i class="bi bi-chevron-double-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>

            <!-- EDIT FORM -->
            <div id="editForm" class="card bg-light border-0 p-3 mt-4 shadow-sm" style="display:none;">
                <h5 class="text-primary mb-3 fw-semibold">✏️ Edit Account</h5>
                <form method="post" action="users.jsp" class="row g-3">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editId">
                    <input type="hidden" name="targetTable" id="editTargetTable">
                    <input type="hidden" name="page" value="<%= currentPage%>">
                    <input type="hidden" name="recordsPerPage" value="<%= recordsPerPage%>">

                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Name</label>
                        <input type="text" id="editName" name="name" class="form-control" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Email</label>
                        <input type="email" id="editEmail" name="email" class="form-control" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Role</label>
                        <select id="editRole" name="role" class="form-select">
                            <option>User</option><option>Admin</option><option>Publisher</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Status</label>
                        <select id="editStatus" name="status" class="form-select">
                            <option>Active</option><option>Inactive</option><option>Locked</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Contact</label>
                        <input type="text" id="editContact" name="contact" class="form-control">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-semibold">Gender</label>
                        <select id="editGender" name="gender" class="form-select">
                            <option>Male</option><option>Female</option><option>Other</option>
                        </select>
                    </div>
                    <div class="col-12 text-end mt-3">
                        <button class="btn btn-info px-4 rounded-3">💾 Update</button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<script>
    function searchUsers() {
        let filter = document.getElementById("searchInput").value.toLowerCase();
        document.querySelectorAll("#usersTable tbody tr").forEach(row => {
            row.style.display = row.innerText.toLowerCase().includes(filter) ? "" : "none";
        });
    }

    function fillEditForm(table, id, name, email, role, status, contact, gender) {
        document.getElementById("editId").value = id;
        document.getElementById("editTargetTable").value = table;
        document.getElementById("editName").value = name;
        document.getElementById("editEmail").value = email;
        document.getElementById("editRole").value = role;
        document.getElementById("editStatus").value = status;
        document.getElementById("editContact").value = contact;
        document.getElementById("editGender").value = gender;
        document.getElementById("editForm").style.display = "block";
        window.scrollTo({top: document.getElementById("editForm").offsetTop, behavior: 'smooth'});
    }

    function confirmDelete(e) {
        e.preventDefault();
        Swal.fire({
            title: 'Are you sure?',
            text: "This account will be permanently deleted.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed)
                e.target.submit();
        });
    }

    function lockAccount(table, id) {
        Swal.fire({
            title: 'Lock Account',
            input: 'text',
            inputLabel: 'Reason for locking (optional)',
            inputPlaceholder: 'Enter lock reason...',
            showCancelButton: true,
            confirmButtonText: 'Lock',
            confirmButtonColor: '#dc3545'
        }).then((result) => {
            if (result.isConfirmed) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'users.jsp';

                const fields = {
                    action: 'lock',
                    id: id,
                    targetTable: table,
                    lockReason: result.value || 'Manually locked by admin',
                    page: '<%= currentPage%>',
                    recordsPerPage: '<%= recordsPerPage%>'
                };

                for (let key in fields) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = key;
                    input.value = fields[key];
                    form.appendChild(input);
                }

                document.body.appendChild(form);
                form.submit();
            }
        });
    }

    function changeRecordsPerPage(value) {
        window.location.href = '?page=1&recordsPerPage=' + value;
    }

    <% if (toastMsg != null) {%>
    window.onload = function () {
        Swal.fire({
            toast: true,
            icon: '<%= toastType%>',
            title: '<%= toastMsg%>',
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
    };
    <% } %>
</script>

<%
    } catch (Exception e) {
        out.println("<div class='alert alert-danger text-center mt-3'>❌ Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        if (rs != null) {
            rs.close();
        }
        if (stmt != null) {
            stmt.close();
        }
        if (ps != null) {
            ps.close();
        }
        if (con != null) {
            con.close();
        }
    }
%>