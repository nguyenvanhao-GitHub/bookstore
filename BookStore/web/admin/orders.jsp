<%@page import="java.text.NumberFormat"%>
<%@ include file="header.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.util.regex.*" %>

<%  
    int totalorder = 0;
    int Completed = 0;
    int Pending = 0;
    int Cancelled = 0;

    try {
        Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
                "root", ""
        );
        Statement stmt = conn.createStatement();

        ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) FROM orders");
        if (rs1.next()) {
            totalorder = rs1.getInt(1);
        }

        ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE status='delivered'");
        if (rs2.next()) {
            Completed = rs2.getInt(1);
        }

        ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE status='pending'");
        if (rs3.next()) {
            Pending = rs3.getInt(1);
        }

        ResultSet rs4 = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE status='cancelled'");
        if (rs4.next()) {
            Cancelled = rs4.getInt(1);
        }

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<%
    String alert = (String) session.getAttribute("alert");
    if (alert != null) {
%>
<script>
    window.onload = () => {
        Swal.fire({text: '<%= alert%>'});
    }
</script>
<%
        session.removeAttribute("alert");
    }
%>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        document.querySelector('a[href="orders.jsp"]').classList.add('active');
    });
</script>

<style>
    .book-image-small {
        width: 50px;
        height: 70px;
        object-fit: cover;
        border-radius: 4px;
        border: 1px solid #ddd;
    }
    .order-item-row:hover {
        background-color: #f8f9fa;
    }
</style>

<!-- Main Content -->
<div class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <button id="sidebar-toggle" class="btn btn-primary d-md-none">
            <i class="fas fa-bars"></i>
        </button>
        <h2 class="mb-0">Order Management</h2>
    </div>

    <!-- Order Statistics -->
    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-primary text-white"><i class="fas fa-shopping-bag"></i></div>
                <h3><%= totalorder%></h3>
                <p class="text-muted mb-0">Total Orders</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-success text-white"><i class="fas fa-check-circle"></i></div>
                <h3><%= Completed%></h3>
                <p class="text-muted mb-0">Completed</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-warning text-white"><i class="fas fa-clock"></i></div>
                <h3><%= Pending%></h3>
                <p class="text-muted mb-0">Pending</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <div class="icon bg-danger text-white"><i class="fas fa-times-circle"></i></div>
                <h3><%= Cancelled%></h3>
                <p class="text-muted mb-0">Cancelled</p>
            </div>
        </div>
    </div>

    <!-- Orders Table -->
    <div class="card">
        <div class="card-body">
            <h5 class="card-title">All Orders</h5>
            <table class="table admin-table">
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
                        try {
                            Connection conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
                                    "root", ""
                            );
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT * FROM orders ORDER BY order_date DESC");

                            Locale localeVN = new Locale("vi", "VN");
                            NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
                            
                            int rowNum = 0;
                            while (rs.next()) {
                                String orderId = rs.getString("id");
                                double totalUSD = rs.getDouble("total_amount");
                                double totalVND = totalUSD;
                                String formattedTotal = currencyVN.format(totalVND);
                                String modalId = "modal_" + rowNum;
                                rowNum++;
                    %>
                    <tr>
                        <td><%= orderId%></td>
                        <td><%= rs.getString("customer_name")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("order_date")%></td>
                        <td>
                            <% String status = rs.getString("status");%>
                            <span class="badge bg-<%= status.equals("delivered") ? "success" : status.equals("cancelled") ? "danger" : "warning"%>">
                                <%= status.equals("pending") ? "Processing" : status.substring(0, 1).toUpperCase() + status.substring(1)%>
                            </span>
                        </td>
                        <td><%= formattedTotal%></td>
                        <td>
                            <button class="btn btn-sm btn-primary me-1" data-bs-toggle="modal" data-bs-target="#<%= modalId%>">
                                <i class="fas fa-eye"></i>
                            </button>
                            <button class="btn btn-sm btn-warning me-1" data-bs-toggle="modal" data-bs-target="#updateStatusModal" onclick="setOrderId('<%= orderId%>')">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-danger" onclick="confirmDelete('<%= orderId%>')">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Order Details Modals -->
<%
    try {
        Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
                "root", ""
        );
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM orders ORDER BY order_date DESC");

        Locale localeVN = new Locale("vi", "VN");
        NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
        
        int modalNum = 0;
        while (rs.next()) {
            String orderId = rs.getString("id");
            String modalId = "modal_" + modalNum;
            modalNum++;
            
            double totalUSD = rs.getDouble("total_amount");
            double totalVND = totalUSD;
            String formattedTotal = currencyVN.format(totalVND);
            

            String booksString = rs.getString("books");
            
            // Split by comma to get individual book entries
            String[] bookEntries = booksString != null ? booksString.split(",(?![^()]*\\))") : new String[0];
            
            // Calculate total quantity
            int totalQuantity = 0;
            Pattern qtyPattern = Pattern.compile("\\(x(\\d+)\\)");
            
            for (String entry : bookEntries) {
                Matcher matcher = qtyPattern.matcher(entry);
                if (matcher.find()) {
                    totalQuantity += Integer.parseInt(matcher.group(1));
                } else {
                    totalQuantity += 1;
                }
            }
            
            double pricePerUnit = totalQuantity > 0 ? totalVND / totalQuantity : 0;
%>
<div class="modal fade" id="<%= modalId%>" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">
                    <i class="fas fa-receipt me-2"></i>Order Details #<%= orderId%>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <h6 class="text-primary"><i class="fas fa-user me-2"></i>Customer Information</h6>
                        <div class="ps-3">
                            <p class="mb-2"><strong>Name:</strong> <%= rs.getString("customer_name")%></p>
                            <p class="mb-2"><strong>Email:</strong> <%= rs.getString("email")%></p>
                            <p class="mb-2"><strong>Phone:</strong> <%= rs.getString("phone")%></p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <h6 class="text-primary"><i class="fas fa-map-marker-alt me-2"></i>Shipping Address</h6>
                        <div class="ps-3">
                            <p class="mb-1"><%= rs.getString("address")%></p>
                            <p class="mb-1"><%= rs.getString("city")%>, <%= rs.getString("state")%></p>
                            <p class="mb-1">Zipcode: <%= rs.getString("zipcode")%></p>
                        </div>
                    </div>
                </div>
                
                <hr>
                
                <h6 class="text-primary mb-3">
                    <i class="fas fa-box me-2"></i>Order Items
                </h6>
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th width="60" class="text-center">#</th>
                                <th width="80">Image</th>
                                <th width="100">Book ID</th>
                                <th>Book Name</th>
                                <th width="100" class="text-center">Quantity</th>
                                <th width="150" class="text-end">Unit Price</th>
                                <th width="150" class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                PreparedStatement pstmt = conn.prepareStatement(
                                    "SELECT id, name, image, price FROM books WHERE name = ?"
                                );
                                
                                double orderSubtotal = 0;
                                for (int i = 0; i < bookEntries.length; i++) {
                                    String entry = bookEntries[i].trim();
                                    if (entry.isEmpty()) continue;
                                    
                                    // Extract book name and quantity
                                    String bookName = entry;
                                    int quantity = 1;
                                    
                                    Matcher matcher = qtyPattern.matcher(entry);
                                    if (matcher.find()) {
                                        quantity = Integer.parseInt(matcher.group(1));
                                        // Remove (x1) part to get clean book name
                                        bookName = entry.replaceAll("\\s*\\(x\\d+\\)\\s*$", "").trim();
                                    }
                                    
                                    // Get book details from database
                                    String bookId = "N/A";
                                    String bookImage = "images/default-book.jpg";
                                    double bookPrice = pricePerUnit;
                                    
                                    try {
                                        pstmt.setString(1, bookName);
                                        ResultSet rsBook = pstmt.executeQuery();
                                        if (rsBook.next()) {
                                            bookId = rsBook.getString("id");
                                            bookImage = rsBook.getString("image");
                                            // Use actual price from database
                                            double dbPrice = rsBook.getDouble("price") * 300; // Convert to VND
                                            if (dbPrice > 0) {
                                                bookPrice = dbPrice;
                                            }
                                        }
                                        rsBook.close();
                                    } catch (Exception e) {
                                        // Use default values if book not found
                                    }
                                    
                                    double itemSubtotal = bookPrice * quantity;
                                    orderSubtotal += itemSubtotal;
                            %>
                            <tr class="order-item-row">
                                <td class="text-center"><%= (i + 1) %></td>
                                <td class="text-center">
                                    <img src="../<%= bookImage%>" alt="Book" class="book-image-small">
                                </td>
                                <td><code><%= bookId%></code></td>
                                <td><strong><%= bookName%></strong></td>
                                <td class="text-center">
                                    <span class="badge bg-secondary fs-6"><%= quantity%></span>
                                </td>
                                <td class="text-end text-success fw-bold">
                                    <%= currencyVN.format(bookPrice)%>
                                </td>
                                <td class="text-end">
                                    <strong class="text-primary"><%= currencyVN.format(itemSubtotal)%></strong>
                                </td>
                            </tr>
                            <%
                                }
                                pstmt.close();
                            %>
                        </tbody>
                        <tfoot class="table-light">
                            <tr>
                                <td colspan="6" class="text-end">
                                    <strong class="fs-5">Total Amount:</strong>
                                </td>
                                <td class="text-end">
                                    <h5 class="mb-0 text-success"><%= formattedTotal%></h5>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
                
                <div class="mt-3 p-3 bg-light rounded">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <strong><i class="fas fa-info-circle me-2"></i>Order Status:</strong>
                        </div>
                        <div class="col-md-6 text-end">
                            <% String status = rs.getString("status");%>
                            <span class="badge bg-<%= status.equals("delivered") ? "success" : status.equals("cancelled") ? "danger" : "warning"%>" style="font-size: 1.1rem; padding: 10px 20px;">
                                <i class="fas fa-<%= status.equals("delivered") ? "check-circle" : status.equals("cancelled") ? "times-circle" : "clock"%> me-2"></i>
                                <%= status.equals("pending") ? "Processing" : status.substring(0, 1).toUpperCase() + status.substring(1)%>
                            </span>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6">
                            <small class="text-muted">
                                <i class="fas fa-calendar me-1"></i>Order Date: <%= rs.getString("order_date")%>
                            </small>
                        </div>
                        <div class="col-md-6 text-end">
                            <small class="text-muted">
                                <i class="fas fa-credit-card me-1"></i>Payment: <%= rs.getString("payment_method")%>
                            </small>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i>Close
                </button>
                <button type="button" class="btn btn-primary" onclick="window.print()">
                    <i class="fas fa-print me-1"></i>Print Invoice
                </button>
            </div>
        </div>
    </div>
</div>
<%
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!-- Update Status Modal -->
<div class="modal fade" id="updateStatusModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="../UpdateOrderStatusServlet" method="post" id="updateStatusForm">
                <div class="modal-header">
                    <h5 class="modal-title">Update Order Status</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="orderId" id="orderIdInput">
                    <div class="mb-3">
                        <label class="form-label">Order Status</label>
                        <select name="status" class="form-select" required>
                            <option value="pending">Pending</option>
                            <option value="delivered">Delivered</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Status</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function setOrderId(id) {
        document.getElementById("orderIdInput").value = id;
    }

    function confirmDelete(orderId) {
        Swal.fire({
            title: "Are you sure?",
            text: "This order will be permanently deleted!",
            icon: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, delete it!",
            cancelButtonText: "Cancel",
            confirmButtonColor: "#d33"
        }).then((result) => {
            if (result.isConfirmed) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "../DeleteOrderServlet";
                const input = document.createElement("input");
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

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
<script src="js/admin-script.js"></script>
</body>
</html>