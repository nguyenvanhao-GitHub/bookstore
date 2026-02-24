<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.OrderDAO, dao.BookDAO" %>
<%@ page import="entity.Order, entity.Book" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap" %>
<%@ page import="java.text.NumberFormat, java.util.Locale, java.text.SimpleDateFormat" %>
<%@ page import="com.google.gson.*" %> <%@ include file="header.jsp" %>

<%
    OrderDAO orderDAO = new OrderDAO();
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

    int totalRecords = orderDAO.countOrders();
    int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
    int start = (currentPage - 1) * recordsPerPage;
    if (start < 0) {
        start = 0;
    }

    int Completed = orderDAO.countOrdersByStatus("delivered");
    int Pending = orderDAO.countOrdersByStatus("pending");
    int Cancelled = orderDAO.countOrdersByStatus("cancelled");
    int Paid = orderDAO.countOrdersByStatus("paid");

    List<Order> orders = orderDAO.getAllOrders(start, recordsPerPage);

    BookDAO bookDAO = new BookDAO();
    List<Book> allBooks = bookDAO.getAllBooks();
    Map<String, String> bookImages = new HashMap<>();

    if (allBooks != null) {
        for (Book b : allBooks) {
            String img = b.getImage();
            if (img != null && !img.startsWith("http")) {
                img = "../" + img; // Thêm ../ cho admin view
            }
            bookImages.put(b.getName().trim(), img);
        }
    }

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<style>
    .admin-wrapper {
        max-width: 1400px;
        margin: 0 auto;
    }
    .stats-card {
        border: none;
        border-radius: 12px;
        padding: 20px;
        color: white;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }
    .bg-gradient-primary {
        background: linear-gradient(135deg, #4e73df 0%, #224abe 100%);
    }
    .bg-gradient-warning {
        background: linear-gradient(135deg, #f6c23e 0%, #dda20a 100%);
    }
    .bg-gradient-success {
        background: linear-gradient(135deg, #1cc88a 0%, #13855c 100%);
    }
    .bg-gradient-danger  {
        background: linear-gradient(135deg, #e74a3b 0%, #be2617 100%);
    }
    .stats-card .icon {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 2.5rem;
        opacity: 0.2;
    }
    .action-btn {
        width: 34px;
        height: 34px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        border: none;
        transition: all 0.2s;
        margin: 0 3px;
    }
    .action-btn:hover {
        opacity: 0.85;
        transform: scale(1.1);
    }
    .status-badge {
        padding: 6px 12px;
        border-radius: 30px;
        font-size: 0.75rem;
        font-weight: 600;
        text-transform: uppercase;
    }

    .book-thumb {
        width: 45px;
        height: 65px;
        object-fit: cover;
        border-radius: 4px;
        border: 1px solid #dee2e6;
        background-color: #f8f9fa;
    }
</style>

<script>document.querySelector('a[href="orders.jsp"]').classList.add('active');</script>

<div class="container-fluid py-4 bg-light">
    <div class="admin-wrapper">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="mb-1 fw-bold text-dark"><i class="fas fa-chart-line me-2 text-primary"></i>Quản Lý Đơn Hàng</h4>
                <p class="text-muted small mb-0">Tổng quan và xử lý các đơn đặt hàng.</p>
            </div>
            <button class="btn btn-sm btn-white border shadow-sm fw-bold" onclick="location.reload()">
                <i class="fas fa-sync-alt me-1 text-primary"></i> Làm mới
            </button>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-xl-3 col-md-6">
                <div class="stats-card bg-gradient-primary">
                    <p class="mb-1 opacity-75 small text-uppercase fw-bold">Tổng Đơn</p>
                    <h3 class="fw-bold mb-0"><%= totalRecords%></h3>
                    <i class="fas fa-clipboard-list icon"></i>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stats-card bg-gradient-warning">
                    <p class="mb-1 opacity-75 small text-uppercase fw-bold">Chờ Xử Lý</p>
                    <h3 class="fw-bold mb-0"><%= Pending%></h3>
                    <i class="fas fa-clock icon"></i>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stats-card bg-gradient-success">
                    <p class="mb-1 opacity-75 small text-uppercase fw-bold">Thành Công</p>
                    <h3 class="fw-bold mb-0"><%= Completed + Paid%></h3>
                    <i class="fas fa-check-circle icon"></i>
                </div>
            </div>
            <div class="col-xl-3 col-md-6">
                <div class="stats-card bg-gradient-danger">
                    <p class="mb-1 opacity-75 small text-uppercase fw-bold">Đã Hủy</p>
                    <h3 class="fw-bold mb-0"><%= Cancelled%></h3>
                    <i class="fas fa-times-circle icon"></i>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary"><i class="fas fa-list me-2"></i>Danh sách chi tiết</h6>
                <span class="badge bg-light text-secondary border">Trang <%= currentPage%> / <%= totalPages%></span>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                        <th class="ps-4" width="10%">Mã Đơn</th>
                        <th width="25%">Khách Hàng</th>
                        <th width="15%">Ngày Đặt</th>
                        <th width="15%">Trạng Thái</th>
                        <th width="15%">Tổng Tiền</th>
                        <th class="text-center" width="20%">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (orders.isEmpty()) { %>
                        <tr><td colspan="6" class="text-center py-5 text-muted">Không có dữ liệu hiển thị.</td></tr>
                        <% } else {
                            int rowNum = start;
                            for (Order order : orders) {
                                String orderId = order.getId();
                                String status = order.getStatus();
                                String modalId = "modal_" + rowNum++;

                                String badgeClass = "bg-secondary";
                                String statusText = status;
                                if (status.equalsIgnoreCase("delivered") || status.equalsIgnoreCase("paid")) {
                                    badgeClass = "bg-success";
                                    statusText = "Hoàn thành";
                                } else if (status.equalsIgnoreCase("shipping")) {
                                    badgeClass = "bg-info text-dark";
                                    statusText = "Đang giao hàng";
                                } else if (status.equalsIgnoreCase("pending")) {
                                    badgeClass = "bg-warning text-dark";
                                    statusText = "Chờ xử lý";
                                } else if (status.equalsIgnoreCase("cancelled")) {
                                    badgeClass = "bg-danger";
                                    statusText = "Đã hủy";
                                }
                        %>
                        <tr>
                        <td class="ps-4 fw-bold text-dark">#<%= orderId%></td>
                        <td>
                            <div class="d-flex flex-column">
                                <span class="fw-bold text-dark small">
                                    <%= (order.getCustomerName() != null) ? order.getCustomerName() : "N/A"%>
                                </span>
                                <small class="text-muted" style="font-size: 0.75rem;">
                                    <%= (order.getEmail() != null) ? order.getEmail() : ""%>
                                </small>
                            </div>
                        </td>
                        <td class="text-muted small"><%= sdf.format(order.getOrderDate())%></td>
                        <td><span class="badge status-badge <%= badgeClass%>"><%= statusText%></span></td>
                        <td class="fw-bold text-success"><%= currencyVN.format(order.getTotalAmount())%></td>
                        <td class="text-center">
                        <button class="action-btn bg-info text-white" data-bs-toggle="modal" data-bs-target="#<%= modalId%>" title="Xem chi tiết">
                            <i class="fas fa-eye small"></i>
                        </button>
                        <button class="action-btn bg-warning text-white" onclick="openUpdateModal('<%= orderId%>', '<%= status%>')" title="Cập nhật">
                            <i class="fas fa-edit small"></i>
                        </button>
                        <button class="action-btn bg-danger text-white" onclick="confirmDelete('<%= orderId%>')" title="Xóa đơn">
                            <i class="fas fa-trash small"></i>
                        </button>
                        </td>
                        </tr>
                        <% }
                            } %>
                    </tbody>
                </table>
            </div>

            <% if (totalPages > 1) {%>
            <div class="card-footer bg-white py-3">
                <nav>
                    <ul class="pagination pagination-sm justify-content-end mb-0">
                        <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                            <a class="page-link" href="?page=<%= currentPage - 1%>">Trước</a>
                        </li>
                        <% for (int i = 1; i <= totalPages; i++) {%>
                        <li class="page-item <%= i == currentPage ? "active" : ""%>">
                            <a class="page-link" href="?page=<%= i%>"><%= i%></a>
                        </li>
                        <% }%>
                        <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                            <a class="page-link" href="?page=<%= currentPage + 1%>">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
            <% } %>
        </div>
    </div>
</div>

<%
    int modalCount = start;
    for (Order order : orders) {
        String modalId = "modal_" + modalCount++;

        String cusName = (order.getCustomerName() != null) ? order.getCustomerName() : "N/A";
        String cusEmail = (order.getEmail() != null) ? order.getEmail() : "N/A";
        String cusPhone = (order.getPhone() != null && !order.getPhone().isEmpty()) ? order.getPhone() : "Chưa cập nhật";

        String addrDetail = (order.getAddress() != null) ? order.getAddress() : "";
        String addrCity = (order.getCity() != null) ? order.getCity() : "";
        String addrState = (order.getState() != null) ? order.getState() : "";

        String fullAddress = addrDetail;
        if (!addrState.isEmpty()) {
            fullAddress += ", " + addrState;
        }
        if (!addrCity.isEmpty()) {
            fullAddress += ", " + addrCity;
        }
        if (fullAddress.trim().isEmpty()) {
            fullAddress = "Chưa có địa chỉ";
        }

        String booksString = order.getBooks();
%>
<div class="modal fade" id="<%= modalId%>" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0">
            <div class="modal-header bg-white border-bottom">
                <h5 class="modal-title fw-bold text-primary"><i class="fas fa-file-invoice me-2"></i>Chi Tiết Đơn Hàng #<%= order.getId()%></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body bg-light" id="printArea_<%= modalId%>">
                <div class="card shadow-sm border-0 mb-3">
                    <div class="card-body py-3">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <h6 class="text-uppercase text-secondary small fw-bold mb-3">Khách hàng</h6>
                                <p class="mb-1"><strong class="me-2"><i class="far fa-user text-primary"></i></strong><%= cusName%></p>
                                <p class="mb-1"><strong class="me-2"><i class="far fa-envelope text-primary"></i></strong><%= cusEmail%></p>
                                <p class="mb-0"><strong class="me-2"><i class="fas fa-phone-alt text-primary"></i></strong><%= cusPhone%></p>
                            </div>
                            <div class="col-md-6 ps-md-4">
                                <h6 class="text-uppercase text-secondary small fw-bold mb-3">Giao hàng & Thanh toán</h6>
                                <p class="mb-1"><strong class="me-2"><i class="fas fa-map-marker-alt text-danger"></i></strong><%= fullAddress%></p>
                                <p class="mb-1"><strong class="me-2"><i class="fas fa-shipping-fast text-info"></i></strong>Zipcode: <%= (order.getZipCode() != null) ? order.getZipCode() : "N/A"%></p>
                                <p class="mb-0"><strong class="me-2"><i class="far fa-credit-card text-success"></i></strong><%= order.getPaymentMethod()%></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white fw-bold small text-uppercase">Danh sách sản phẩm</div>
                    <div class="card-body p-0">
                        <table class="table table-sm table-striped mb-0 align-middle">
                            <thead class="table-light"><tr><th class="ps-3" width="50">#</th><th width="70">Ảnh</th><th>Thông tin sách</th><th class="text-center">SL</th><th class="text-end pe-3">Thành tiền</th></tr></thead>
                            <tbody>
                                <%
                                    // --- PHẦN SỬA ĐỔI QUAN TRỌNG: PARSE JSON ---
                                    Gson gson = new Gson();
                                    try {
                                        // 1. Cố gắng parse JSON
                                        JsonArray items = gson.fromJson(booksString, JsonArray.class);
                                        int count = 1;
                                        for (JsonElement el : items) {
                                            JsonObject item = el.getAsJsonObject();

                                            String bName = item.has("bookname") ? item.get("bookname").getAsString() : "Sản phẩm";
                                            String bAuthor = item.has("author") ? item.get("author").getAsString() : "";
                                            int bQty = item.has("quantity") ? item.get("quantity").getAsInt() : 1;
                                            double bSubtotal = item.has("subtotal") ? item.get("subtotal").getAsDouble() : 0.0;

                                            // Xử lý ảnh: Ưu tiên ảnh trong JSON
                                            String bImage = item.has("image") ? item.get("image").getAsString() : "";

                                            // Nếu JSON ko có ảnh, tìm trong Map bookImages đã load
                                            if (bImage.isEmpty()) {
                                                bImage = bookImages.getOrDefault(bName.trim(), "");
                                            }

                                            // Xử lý đường dẫn ảnh cho admin (thêm ../ nếu là đường dẫn tương đối)
                                            if (!bImage.isEmpty() && !bImage.startsWith("http")) {
                                                if (!bImage.startsWith("../")) {
                                                    bImage = "../" + bImage;
                                                }
                                            } else if (bImage.isEmpty()) {
                                                bImage = "https://via.placeholder.com/50x70?text=NoImg";
                                            }
                                %>
                                <tr>
                                <td class="ps-3 small text-muted"><%= count++%></td>
                                <td>
                                    <img src="<%= bImage%>" class="book-thumb" alt="Book" onerror="this.src='https://via.placeholder.com/50x70?text=Err'">
                                </td>
                                <td>
                                    <div class="fw-bold text-dark small"><%= bName%></div>
                                    <% if (!bAuthor.isEmpty()) {%>
                                    <div class="text-muted fst-italic" style="font-size: 0.75rem;"><%= bAuthor%></div>
                                    <% }%>
                                </td>
                                <td class="text-center"><span class="badge bg-light text-dark border"><%= bQty%></span></td>
                                <td class="text-end pe-3 text-primary fw-bold"><%= currencyVN.format(bSubtotal)%></td>
                                </tr>
                                <%
                                    }
                                } catch (Exception e) {
                                    // 2. Fallback cho dữ liệu cũ (Dạng chuỗi text)
                                    String[] bookEntries = (booksString != null) ? booksString.split(",(?![^()]*\\))") : new String[0];
                                    for (int i = 0; i < bookEntries.length; i++) {
                                        String entry = bookEntries[i].trim();
                                        if (entry.isEmpty()) {
                                            continue;
                                        }

                                        String bName = entry;
                                        String bQty = "1";
                                        if (entry.contains("(x")) {
                                            bName = entry.substring(0, entry.lastIndexOf("(x")).trim();
                                            bQty = entry.substring(entry.lastIndexOf("(x") + 2, entry.lastIndexOf(")")).trim();
                                        }

                                        String imgUrl = bookImages.getOrDefault(bName.trim(), "https://via.placeholder.com/50x70?text=NoImg");
                                %>
                                <tr>
                                <td class="ps-3 small text-muted"><%= i + 1%></td>
                                <td>
                                    <img src="<%= imgUrl%>" class="book-thumb" alt="Book" onerror="this.src='https://via.placeholder.com/50x70?text=Err'">
                                </td>
                                <td>
                                    <div class="fw-bold text-dark small"><%= bName%></div>
                                </td>
                                <td class="text-center"><span class="badge bg-light text-dark border"><%= bQty%></span></td>
                                <td class="text-end pe-3 text-muted">-</td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                            <tfoot class="bg-white">
                                <tr>
                                <td colspan="4" class="text-end text-uppercase text-secondary small fw-bold pt-3">Tổng thanh toán:</td>
                                <td class="text-end pe-3 pt-3"><h5 class="mb-0 text-danger fw-bold"><%= currencyVN.format(order.getTotalAmount())%></h5></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-sm btn-primary" onclick="printOrder('printArea_<%= modalId%>')"><i class="fas fa-print me-1"></i> In Hóa Đơn</button>
            </div>
        </div>
    </div>
</div>
<% }%>

<div class="modal fade" id="updateStatusModal" tabindex="-1">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form id="updateStatusForm" action="../UpdateOrderStatusServlet" method="post">
                <div class="modal-header bg-warning text-dark border-0">
                    <h6 class="modal-title fw-bold"><i class="fas fa-edit me-2"></i>Cập nhật trạng thái</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="orderId" id="updateOrderId">
                    <input type="hidden" id="rawCurrentStatus">

                    <div class="mb-2">
                        <label class="small text-muted fw-bold">Hiện tại:</label>
                        <input type="text" class="form-control form-control-sm fw-bold mb-3" id="currentStatusDisplay" readonly style="background-color: #f8f9fa;">
                    </div>

                    <div class="mb-1">
                        <label class="small text-muted fw-bold">Trạng thái mới:</label>
                        <select name="status" id="newStatusSelect" class="form-select form-select-sm border-warning">
                            <option value="pending">⏳ Pending (Chờ xử lý)</option>
                            <option value="shipping">🚚 Shipping (Đang giao)</option>
                            <option value="delivered">✅ Delivered (Đã giao)</option>
                            <option value="cancelled">❌ Cancelled (Hủy đơn)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" onclick="submitUpdateStatus()" class="btn btn-sm btn-warning fw-bold text-dark">
                        <i class="fas fa-save me-1"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
                        // --- HÀM IN HÓA ĐƠN MỚI (FIX LỖI) ---
                        function printOrder(divId) {
                            // 1. Lấy nội dung HTML của phần hóa đơn
                            var content = document.getElementById(divId).innerHTML;

                            // 2. Mở một cửa sổ mới (Popup)
                            var printWindow = window.open('', 'PRINT', 'height=800,width=1000');

                            // 3. Viết nội dung vào cửa sổ mới (Kèm theo CSS để không bị vỡ giao diện)
                            printWindow.document.write('<!DOCTYPE html><html><head><title>In Hóa Đơn</title>');

                            // Quan trọng: Đặt đường dẫn gốc để load ảnh đúng (vì ảnh dùng đường dẫn tương đối ../)
                            printWindow.document.write('<base href="' + window.location.href + '">');

                            // Load Bootstrap & FontAwesome cho đẹp
                            printWindow.document.write('<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">');
                            printWindow.document.write('<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">');

                            // CSS tùy chỉnh cho trang in
                            printWindow.document.write('<style>');
                            printWindow.document.write('body { font-family: "Segoe UI", sans-serif; background-color: #fff; padding: 20px; }');
                            printWindow.document.write('.book-thumb { width: 50px; height: 75px; object-fit: cover; border: 1px solid #ddd; margin-right: 10px; }');
                            printWindow.document.write('.card { border: none !important; box-shadow: none !important; }'); // Bỏ viền card khi in
                            printWindow.document.write('.table thead th { background-color: #f8f9fa !important; border-bottom: 2px solid #dee2e6; }');
                            printWindow.document.write('</style>');

                            printWindow.document.write('</head><body>');
                            printWindow.document.write(content); // Chèn nội dung hóa đơn vào
                            printWindow.document.write('</body></html>');

                            // 4. Kết thúc ghi và gọi lệnh in
                            printWindow.document.close();
                            printWindow.focus();

                            // Đợi 500ms để ảnh và CSS tải xong rồi mới bật hộp thoại in
                            setTimeout(function () {
                                printWindow.print();
                                printWindow.close();
                            }, 500);
                        }

                        // --- CÁC HÀM KHÁC GIỮ NGUYÊN ---

                        function openUpdateModal(orderId, currentStatus) {
                            document.getElementById('updateOrderId').value = orderId;
                            const rawStatus = currentStatus.toLowerCase();
                            document.getElementById('rawCurrentStatus').value = rawStatus;

                            let displayStatus = rawStatus;
                            if (rawStatus === 'pending')
                                displayStatus = 'Pending (Chờ xử lý)';
                            else if (rawStatus === 'shipping')
                                displayStatus = 'Shipping (Đang giao)';
                            else if (rawStatus === 'delivered')
                                displayStatus = 'Delivered (Đã giao)';
                            else if (rawStatus === 'cancelled')
                                displayStatus = 'Cancelled (Đã hủy)';
                            else if (rawStatus === 'paid')
                                displayStatus = 'Paid (Đã thanh toán)';

                            document.getElementById('currentStatusDisplay').value = displayStatus;

                            let selectValue = (rawStatus === 'paid') ? 'pending' : rawStatus;
                            document.getElementById('newStatusSelect').value = selectValue;

                            var myModal = new bootstrap.Modal(document.getElementById('updateStatusModal'));
                            myModal.show();
                        }

                        function submitUpdateStatus() {
                            const currentRaw = document.getElementById('rawCurrentStatus').value;
                            const newStatus = document.getElementById('newStatusSelect').value;

                            if (currentRaw === 'delivered') {
                                Swal.fire({icon: 'error', title: 'Lỗi', text: 'Đơn hàng đã giao thành công, không thể sửa.'});
                                return;
                            }
                            if (currentRaw === 'cancelled') {
                                Swal.fire({icon: 'error', title: 'Lỗi', text: 'Đơn hàng đã hủy không thể khôi phục.'});
                                return;
                            }
                            if (currentRaw === 'shipping' && newStatus === 'pending') {
                                Swal.fire({icon: 'error', title: 'Lỗi Logic', text: 'Hàng đang giao không thể quay lại trạng thái Chờ xử lý!'});
                                return;
                            }
                            if (currentRaw === 'shipping' && newStatus === 'cancelled') {
                                Swal.fire({
                                    icon: 'warning', title: 'Cảnh báo', text: 'Đơn đang giao. Bạn có chắc chắn muốn hủy (phải báo hoàn hàng)?',
                                    showCancelButton: true, confirmButtonText: 'Vẫn Hủy', confirmButtonColor: '#d33'
                                }).then((result) => {
                                    if (result.isConfirmed)
                                        processUpdate();
                                });
                                return;
                            }
                            processUpdate();
                        }

                        function processUpdate() {
                            const form = document.getElementById('updateStatusForm');
                            const formData = new URLSearchParams(new FormData(form));

                            Swal.fire({title: 'Đang xử lý...', allowOutsideClick: false, didOpen: () => Swal.showLoading()});

                            fetch(form.action, {method: 'POST', body: formData})
                                    .then(response => {
                                        if (response.ok) {
                                            Swal.fire({icon: 'success', title: 'Thành công!', text: 'Trạng thái đã được cập nhật.'})
                                                    .then(() => location.reload());
                                        } else {
                                            Swal.fire({icon: 'error', title: 'Lỗi!', text: 'Không thể cập nhật (Có thể do lỗi server).'});
                                        }
                                    })
                                    .catch(error => {
                                        Swal.fire({icon: 'error', title: 'Lỗi kết nối!', text: 'Vui lòng kiểm tra mạng.'});
                                    });
                        }

                        function confirmDelete(orderId) {
                            Swal.fire({
                                title: 'Xác nhận xóa?',
                                text: "Bạn có chắc muốn xóa đơn hàng #" + orderId + "?",
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#e74a3b',
                                cancelButtonColor: '#858796',
                                confirmButtonText: 'Xóa ngay',
                                cancelButtonText: 'Không'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    var form = document.createElement("form");
                                    form.method = "POST";
                                    form.action = "../DeleteOrderServlet";
                                    var input = document.createElement("input");
                                    input.type = "hidden";
                                    input.name = "orderId";
                                    input.value = orderId;
                                    form.appendChild(input);
                                    document.body.appendChild(form);
                                    form.submit();
                                }
                            });
                        }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>