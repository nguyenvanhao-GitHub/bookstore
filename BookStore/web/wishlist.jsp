<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="header.jsp" />

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    :root {
        --primary-color: #2563eb;
        --danger-color: #dc2626;
        --text-primary: #1f2937;
        --text-secondary: #6b7280;
        --border-color: #e5e7eb;
        --bg-light: #f9fafb;
        --pink-color: #ec4899;
    }

    body {
        background-color: var(--bg-light);
    }

    /* Page Header */
    .wishlist-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 50px 0;
        margin-bottom: 40px;
        border-radius: 0 0 30px 30px;
        box-shadow: 0 10px 40px rgba(102, 126, 234, 0.3);
    }

    .wishlist-header h2 {
        color: white;
        font-size: 38px;
        font-weight: 700;
        margin: 0;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 15px;
    }

    .wishlist-header h2 i {
        font-size: 42px;
        animation: heartbeat 1.5s ease-in-out infinite;
    }

    @keyframes heartbeat {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }

    /* Stats */
    .wishlist-stats {
        display: flex;
        justify-content: center;
        gap: 30px;
        margin-top: 25px;
    }

    .stat-item {
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(10px);
        padding: 15px 30px;
        border-radius: 15px;
        color: white;
        text-align: center;
    }

    .stat-number {
        font-size: 28px;
        font-weight: 700;
        display: block;
    }

    .stat-label {
        font-size: 14px;
        opacity: 0.9;
    }

    /* Container */
    .wishlist-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 20px 80px;
    }

    /* Card Styles */
    .col-md-3 {
        margin-bottom: 30px;
    }

    .card {
        border: none;
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        height: 100%;
        background: white;
        position: relative;
    }

    .card:hover {
        transform: translateY(-10px);
        box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
    }

    /* Image Wrapper */
    .card-img-wrapper {
        position: relative;
        overflow: hidden;
        background: var(--bg-light);
    }

    .card-img-top {
        width: 100%;
        height: 320px;
        object-fit: cover;
        transition: transform 0.5s ease;
    }

    .card:hover .card-img-top {
        transform: scale(1.1);
    }

    /* Wishlist Badge */
    .wishlist-badge {
        position: absolute;
        top: 15px;
        left: 15px;
        background: linear-gradient(135deg, var(--pink-color), #db2777);
        color: white;
        padding: 8px 15px;
        border-radius: 25px;
        font-size: 12px;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 5px;
        z-index: 2;
        animation: pulse 2s infinite;
    }

    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }

    /* Remove Button */
    .btn-remove {
        position: absolute;
        top: 15px;
        right: 15px;
        background: rgba(220, 38, 38, 0.95);
        color: white;
        border: none;
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.3s ease;
        z-index: 2;
        opacity: 0;
        font-size: 16px;
    }

    .card:hover .btn-remove {
        opacity: 1;
    }

    .btn-remove:hover {
        background: #991b1b;
        transform: rotate(90deg) scale(1.1);
    }

    /* Card Body */
    .card-body {
        padding: 25px;
        display: flex;
        flex-direction: column;
    }

    .card-title {
        font-size: 16px;
        font-weight: 700;
        color: var(--text-primary);
        margin-bottom: 12px;
        line-height: 1.4;
        min-height: 44px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .card-text {
        font-size: 22px;
        font-weight: 700;
        color: var(--danger-color) !important;
        margin-bottom: 15px;
    }

    /* Action Buttons */
    .card-actions {
        display: flex;
        gap: 10px;
        margin-top: auto;
    }

    .btn-view {
        flex: 2;
        background: linear-gradient(135deg, var(--primary-color), #1e40af);
        border: none;
        padding: 12px 20px;
        border-radius: 10px;
        font-weight: 600;
        font-size: 14px;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        color: white;
        text-decoration: none;
    }

    .btn-view:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(37, 99, 235, 0.4);
        background: linear-gradient(135deg, #1e40af, var(--primary-color));
        color: white;
        text-decoration: none;
    }

    .btn-cart {
        flex: 1;
        background: white;
        border: 2px solid var(--primary-color);
        color: var(--primary-color);
        padding: 12px;
        border-radius: 10px;
        font-weight: 600;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .btn-cart:hover {
        background: var(--primary-color);
        color: white;
        transform: translateY(-2px);
    }

    /* Empty State */
    .empty-wishlist {
        text-align: center;
        padding: 80px 20px;
        background: white;
        border-radius: 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        margin: 0 auto;
        max-width: 600px;
    }

    .empty-wishlist i {
        font-size: 100px;
        color: #e5e7eb;
        margin-bottom: 25px;
    }

    .empty-wishlist h3 {
        font-size: 24px;
        color: var(--text-primary);
        margin-bottom: 10px;
        font-weight: 700;
    }

    .empty-wishlist p {
        font-size: 16px;
        color: var(--text-secondary);
        margin: 0 0 25px 0;
    }

    .empty-wishlist a {
        display: inline-block;
        background: linear-gradient(135deg, var(--primary-color), #1e40af);
        color: white;
        padding: 15px 35px;
        border-radius: 12px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.3s ease;
    }

    .empty-wishlist a:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 30px rgba(37, 99, 235, 0.4);
        text-decoration: none;
        color: white;
    }

    /* Error State */
    .error-message {
        text-align: center;
        padding: 60px 20px;
        background: white;
        border-radius: 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        margin: 0 auto;
        max-width: 600px;
    }

    .error-message i {
        font-size: 80px;
        color: var(--danger-color);
        margin-bottom: 20px;
    }

    .error-message p {
        font-size: 18px;
        color: var(--danger-color);
        margin: 0;
        font-weight: 600;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .wishlist-header h2 {
            font-size: 28px;
        }

        .wishlist-header h2 i {
            font-size: 32px;
        }

        .wishlist-stats {
            flex-direction: column;
            gap: 15px;
        }

        .stat-item {
            padding: 12px 20px;
        }

        .col-md-3 {
            flex: 0 0 100%;
            max-width: 100%;
        }

        .card-img-top {
            height: 250px;
        }
    }

    @media (min-width: 768px) and (max-width: 991px) {
        .col-md-3 {
            flex: 0 0 50%;
            max-width: 50%;
        }
    }
</style>

<!-- Page Header -->
<div class="wishlist-header">
    <h2>
        <i class="fas fa-heart"></i>
        Danh sách yêu thích
    </h2>
    <%
        Connection connCount = null;
        PreparedStatement stmtCount = null;
        ResultSet rsCount = null;
        int totalItems = 0;
        double totalValue = 0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connCount = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8", "root", "");
            stmtCount = connCount.prepareStatement(
                "SELECT COUNT(*) as total, COALESCE(SUM(b.price), 0) as total_value FROM wishlist w JOIN books b ON w.book_id = b.id WHERE w.user_id = ?"
            );
            stmtCount.setInt(1, userId);
            rsCount = stmtCount.executeQuery();
            if (rsCount.next()) {
                totalItems = rsCount.getInt("total");
                totalValue = rsCount.getDouble("total_value") * 300;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error counting wishlist: " + e.getMessage());
        } finally {
            try {
                if (rsCount != null) rsCount.close();
                if (stmtCount != null) stmtCount.close();
                if (connCount != null) connCount.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
    <div class="wishlist-stats">
        <div class="stat-item">
            <span class="stat-number"><%= totalItems %></span>
            <span class="stat-label">Sản phẩm</span>
        </div>
        <div class="stat-item">
            <span class="stat-number"><%= String.format("%,.0f", totalValue) %> đ</span>
            <span class="stat-label">Tổng giá trị</span>
        </div>
    </div>
</div>

<!-- Main Content -->
<div class="wishlist-container">
    <div class="row">
        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore?useUnicode=true&characterEncoding=UTF-8", "root", "");
                
                // Kiểm tra xem bảng wishlist có cột created_at không
                String sql = "SELECT b.id, b.name, b.image, b.price FROM wishlist w JOIN books b ON w.book_id = b.id WHERE w.user_id = ?";
                
                // Thử thêm ORDER BY created_at nếu có
                try {
                    DatabaseMetaData meta = conn.getMetaData();
                    ResultSet columns = meta.getColumns(null, null, "wishlist", "created_at");
                    if (columns.next()) {
                        sql += " ORDER BY w.created_at DESC";
                    }
                    columns.close();
                } catch (Exception e) {
                    // Nếu không có cột created_at, bỏ qua
                }
                
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();
                
                boolean hasItem = false;
                while (rs.next()) {
                    hasItem = true;
                    int bookId = rs.getInt("id");
                    String bookName = rs.getString("name");
                    String bookImage = rs.getString("image");
                    double bookPrice = rs.getDouble("price") * 300;
        %>
                    <div class="col-md-3">
                        <div class="card">
                            <div class="card-img-wrapper">
                                <img src="<%= bookImage %>" class="card-img-top" alt="<%= bookName %>" onerror="this.src='images/default-book.jpg'">
                                <div class="wishlist-badge">
                                    <i class="fas fa-heart"></i>
                                    Yêu thích
                                </div>
                                <button class="btn-remove" onclick="removeFromWishlist(<%= bookId %>, event)">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                            <div class="card-body">
                                <h5 class="card-title"><%= bookName %></h5>
                                <p class="card-text text-danger"><%= String.format("%,.0f", bookPrice) %> VNĐ</p>
                                <div class="card-actions">
                                    <a href="book-detail.jsp?id=<%= bookId %>" class="btn-view">
                                        <i class="fas fa-eye"></i> Xem chi tiết
                                    </a>
                                    <button class="btn-cart" onclick="window.location.href='book-detail.jsp?id=<%= bookId %>'">
                                        <i class="fas fa-shopping-cart"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
        <%
                }
                if (!hasItem) {
        %>
            <div class="col-12">
                <div class="empty-wishlist">
                    <i class="fas fa-heart-broken"></i>
                    <h3>Danh sách yêu thích trống</h3>
                    <p>Bạn chưa có sách nào trong danh sách yêu thích.<br>Hãy khám phá và thêm những cuốn sách bạn yêu thích!</p>
                    <a href="categories.jsp">
                        <i class="fas fa-book"></i> Khám phá sách ngay
                    </a>
                </div>
            </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("❌ Error loading wishlist: " + e.getMessage());
        %>
            <div class="col-12">
                <div class="error-message">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p>Lỗi khi tải danh sách yêu thích.</p>
                </div>
            </div>
        <%
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
    </div>
</div>

<script>
    // Remove from wishlist
    function removeFromWishlist(bookId, event) {
        event.stopPropagation();
        
        Swal.fire({
            title: 'Xác nhận xóa',
            text: 'Bạn có chắc muốn xóa sách này khỏi danh sách yêu thích?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc2626',
            cancelButtonColor: '#6b7280',
            confirmButtonText: '<i class="fas fa-trash"></i> Xóa',
            cancelButtonText: 'Hủy',
            reverseButtons: true
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading
                Swal.fire({
                    title: 'Đang xóa...',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                // Send request
                fetch('RemoveFromWishlistServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'bookId=' + bookId
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.status === 'success') {
                        Swal.fire({
                            icon: 'success',
                            title: 'Đã xóa!',
                            text: data.message,
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Lỗi!',
                            text: data.message,
                            confirmButtonColor: '#dc2626'
                        });
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: 'Không thể kết nối đến server. Vui lòng thử lại sau.',
                        confirmButtonColor: '#dc2626'
                    });
                });
            }
        });
    }
</script>

<jsp:include page="footer.jsp" />