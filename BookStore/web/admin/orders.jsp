<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.OrderDAO" %>
<%@ page import="entity.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.regex.Pattern, java.util.regex.Matcher" %>
<%@ include file="header.jsp" %>

<%
    // Khởi tạo DAO
    OrderDAO orderDAO = new OrderDAO();

    // 1. Phân trang
    int currentPage = 1;
    int recordsPerPage = 10;
    
    try {
        if (request.getParameter("page") != null) currentPage = Integer.parseInt(request.getParameter("page"));
        if (request.getParameter("records") != null) recordsPerPage = Integer.parseInt(request.getParameter("records"));
    } catch (NumberFormatException e) { currentPage = 1; }

    int totalRecords = orderDAO.countOrders();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    int start = (currentPage - 1) * recordsPerPage;
    int end = Math.min(start + recordsPerPage, totalRecords);
    
    // Đảm bảo currentPage không vượt quá totalPages
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    if (start < 0) start = 0;
    
    // 2. Lấy dữ liệu thống kê từ DAO
    int Completed = orderDAO.countOrdersByStatus("delivered");
    int Pending = orderDAO.countOrdersByStatus("pending");
    int Cancelled = orderDAO.countOrdersByStatus("cancelled");
    
    // 3. Lấy danh sách đơn hàng đã phân trang
    List<Order> orders = orderDAO.getAllOrders(start, recordsPerPage);

    // 4. Định dạng
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<script>document.querySelector('a[href="orders.jsp"]').classList.add('active');</script>

<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-shopping-bag"></i> Order Management</h2>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-primary text-white"><i class="fas fa-list"></i></div>
                <h3><%= totalRecords %></h3>
                <p class="text-muted mb-0">Total Orders</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-success text-white"><i class="fas fa-check"></i></div>
                <h3><%= Completed %></h3>
                <p class="text-muted mb-0">Delivered</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-warning text-white"><i class="fas fa-clock"></i></div>
                <h3><%= Pending %></h3>
                <p class="text-muted mb-0">Pending</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-danger text-white"><i class="fas fa-times"></i></div>
                <h3><%= Cancelled %></h3>
                <p class="text-muted mb-0">Cancelled</p>
            </div>
        </div>
    </div>
    <div class="card shadow-sm">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="card-title mb-0">All Orders</h5>
            <div class="text-muted small">
                Hiển thị <%= totalRecords > 0 ? start + 1 : 0 %> - <%= end %> / <%= totalRecords %> đơn hàng
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table admin-table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <th>Email</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Total</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (orders.isEmpty()) {
                            out.println("<tr><td colspan='7' class='text-center py-4 text-muted'>No orders found.</td></tr>");
                        } else {
                            int rowNum = start; // Dùng cho modal ID
                            for (Order order : orders) {
                                String orderId = order.getId();
                                String status = order.getStatus();
                                String formattedTotal = currencyVN.format(order.getTotalAmount());
                                String modalId = "modal_" + rowNum;
                                rowNum++;
                        %>
                        <tr>
                            <td><%= orderId%></td>
                            <td><%= order.getCustomerName()%></td>
                            <td><%= order.getEmail()%></td>
                            <td><%= sdf.format(order.getOrderDate())%></td>
                            <td>
                                <span class="badge bg-<%= status.equals("delivered") ? "success" : status.equals("cancelled") ? "danger" : "warning"%>">
                                    <%= status.equals("pending") ? "Processing" : status.substring(0, 1).toUpperCase() + status.substring(1)%>
                                </span>
                            </td>
                            <td class="fw-bold text-success"><%= formattedTotal%></td>
                            <td>
                                <button class="btn btn-sm btn-primary me-1" data-bs-toggle="modal" data-bs-target="#<%= modalId%>" title="View Details"><i class="fas fa-eye"></i></button>
                                <button class="btn btn-sm btn-warning me-1" data-bs-toggle="modal" data-bs-target="#updateStatusModal" onclick="setOrderId('<%= orderId%>')" title="Update Status"><i class="fas fa-edit"></i></button>
                                <button class="btn btn-sm btn-danger" onclick="confirmDelete('<%= orderId%>')" title="Delete Order"><i class="fas fa-trash"></i></button>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <% if (totalPages > 1) { %>
        <div class="card-footer bg-white py-3">
            <nav aria-label="Order Pagination">
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

<%
    List<Order> allOrders = orders;

    int modalNum = start; // Bắt đầu lại số modal ID
    for (Order order : allOrders) {
        String orderId = order.getId();
        String modalId = "modal_" + modalNum;
        modalNum++;
        
        String booksString = order.getBooks();
        String[] bookEntries = booksString != null ? booksString.split(",(?![^()]*\\))") : new String[0];
        
        String formattedTotal = currencyVN.format(order.getTotalAmount());
%>
<div class="modal fade" id="<%= modalId%>" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title"><i class="fas fa-receipt me-2"></i>Order Details #<%= orderId%></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <h6 class="text-primary"><i class="fas fa-user me-2"></i>Customer Information</h6>
                        <div class="ps-3">
                            <p class="mb-2"><strong>Name:</strong> <%= order.getCustomerName()%></p>
                            <p class="mb-2"><strong>Email:</strong> <%= order.getEmail()%></p>
                            <p class="mb-2"><strong>Phone:</strong> <%= order.getPhone()%></p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <h6 class="text-primary"><i class="fas fa-map-marker-alt me-2"></i>Shipping Address</h6>
                        <div class="ps-3">
                            <p class="mb-1"><%= order.getAddress()%></p>
                            <p class="mb-1"><%= order.getCity()%>, <%= order.getState()%></p>
                            <p class="mb-1">Zipcode: <%= order.getZipCode()%></p>
                        </div>
                    </div>
                </div>
                <hr>
                
                <h6 class="text-primary mb-3"><i class="fas fa-box me-2"></i>Order Items</h6>
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th width="60">#</th>
                                <th>Book Name</th>
                                <th class="text-center">Qty</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            for (int i = 0; i < bookEntries.length; i++) { 
                                String entry = bookEntries[i].trim();
                                if(entry.isEmpty()) continue;
                                
                                Pattern pattern = Pattern.compile("([^()]+)\\s*\\(x(\\d+)\\)");
                                Matcher matcher = pattern.matcher(entry);
                                String bookName = entry;
                                String quantity = "1";
                                
                                if (matcher.find()) {
                                    bookName = matcher.group(1).trim();
                                    quantity = matcher.group(2).trim();
                                } else if (entry.contains("(x")) {
                                    bookName = entry.substring(0, entry.indexOf("(x")).trim();
                                    quantity = entry.substring(entry.indexOf("(x") + 2, entry.length() - 1).trim();
                                }
                            %>
                            <tr>
                                <td><%= i + 1 %></td>
                                <td><%= bookName %></td>
                                <td class="text-center"><span class="badge bg-secondary"><%= quantity %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                        <tfoot class="table-light">
                            <tr>
                                <td colspan="2" class="text-end"><strong class="fs-5">Total Amount:</strong></td>
                                <td class="text-end"><h5 class="mb-0 text-success"><%= formattedTotal%></h5></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                
                <div class="mt-3 p-3 bg-light rounded">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <strong><i class="fas fa-info-circle me-2"></i>Order Status:</strong>
                            <% String status = order.getStatus();%>
                            <span class="badge bg-<%= status.equals("delivered") ? "success" : status.equals("cancelled") ? "danger" : "warning"%> ms-2">
                                <%= status.toUpperCase() %>
                            </span>
                        </div>
                        
                        <div class="col-md-6 text-end">
                            <small class="text-muted d-block">
                                <i class="fas fa-credit-card me-1"></i>Payment: <strong><%= order.getPaymentMethod() %></strong>
                            </small>
                            
                            <% 
                                String transId = order.getTransactionId();
                               if (transId != null && !transId.isEmpty()) { 
                            %>
                            <small class="text-info d-block mt-1">
                                <i class="fas fa-receipt me-1"></i>Trans ID: <strong><%= transId %></strong>
                            </small>
                            <% } %>
                        </div>
                        </div>
                    <div class="row mt-2">
                        <div class="col-12"><small class="text-muted"><i class="fas fa-calendar me-1"></i>Order Date: <%= sdf.format(order.getOrderDate())%></small></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="window.print()">Print Invoice</button>
            </div>
        </div>
    </div>
</div>
<% } %>

<div class="modal fade" id="updateStatusModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../UpdateOrderStatusServlet" method="post">
                <div class="modal-header">
                    <h5 class="modal-title">Update Status</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="orderId" id="orderIdInput">
                    <div class="mb-3">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="pending">Pending</option>
                            <option value="delivered">Delivered</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function setOrderId(id) { document.getElementById("orderIdInput").value = id; }
    function confirmDelete(orderId) {
        Swal.fire({
            title: "Are you sure?", text: "Delete this order?", icon: "warning", showCancelButton: true, confirmButtonColor: "#d33", confirmButtonText: "Yes"
        }).then((result) => {
            if (result.isConfirmed) {
                var form = document.createElement("form");
                form.method = "POST";
                form.action = "../DeleteOrderServlet"; 
                var input = document.createElement("input");
                input.type = "hidden"; input.name = "orderId"; input.value = orderId;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        });
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>