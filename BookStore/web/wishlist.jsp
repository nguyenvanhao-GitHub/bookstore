<%@ page import="dao.WishlistDAO" %>
<%@ page import="entity.Book" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Kiểm tra đăng nhập
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Gọi DAO lấy dữ liệu
    WishlistDAO wishlistDAO = new WishlistDAO();
    List<Book> wishlistItems = wishlistDAO.getWishlistByUserId(userId);
    int totalItems = wishlistItems.size();

    // Tính tổng giá trị (Logic: giá * 300 như các trang khác)
    double totalValue = wishlistDAO.getTotalWishlistValue(userId) * 300;
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Danh sách yêu thích - BookStore</title>
        <jsp:include page="header.jsp" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <style>
            /* CSS giữ nguyên từ file cũ của bạn */
            :root {
                --primary-color: #2563eb;
                --danger-color: #dc2626;
                --text-primary: #1f2937;
                --text-secondary: #6b7280;
                --bg-light: #f9fafb;
                --pink-color: #ec4899;
            }
            body {
                background-color: var(--bg-light);
            }
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
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.1);
                }
            }
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
            .wishlist-container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 0 20px 80px;
            }
            .col-md-3 {
                margin-bottom: 30px;
            }
            .card {
                border: none;
                border-radius: 20px;
                overflow: hidden;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
                transition: all 0.4s;
                height: 100%;
                background: white;
                position: relative;
            }
            .card:hover {
                transform: translateY(-10px);
                box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
            }
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
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.05);
                }
            }
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
                color: white;
            }
            @media (max-width: 768px) {
                .wishlist-header h2 {
                    font-size: 28px;
                }
                .wishlist-stats {
                    flex-direction: column;
                    gap: 15px;
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
    </head>
    <body>

        <div class="wishlist-header">
            <h2>
                <i class="fas fa-heart"></i> Danh sách yêu thích
            </h2>
            <div class="wishlist-stats">
                <div class="stat-item">
                    <span class="stat-number"><%= totalItems%></span>
                    <span class="stat-label">Sản phẩm</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number"><%= String.format("%,.0f", totalValue)%> đ</span>
                    <span class="stat-label">Tổng giá trị</span>
                </div>
            </div>
        </div>

        <div class="wishlist-container">
            <div class="row">
                <% if (wishlistItems.isEmpty()) { %>
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
                <% } else {
                    for (Book book : wishlistItems) {
                        double bookPrice = book.getPrice() * 300;
                        String bookImage = (book.getImage() != null && !book.getImage().isEmpty()) ? book.getImage() : "images/default-book.jpg";
                %>
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-img-wrapper">
                            <img src="<%= bookImage%>" class="card-img-top" alt="<%= book.getName()%>" onerror="this.src='images/default-book.jpg'">
                            <div class="wishlist-badge">
                                <i class="fas fa-heart"></i> Yêu thích
                            </div>
                            <button class="btn-remove" onclick="removeFromWishlist(<%= book.getId()%>, event)">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title" title="<%= book.getName()%>"><%= book.getName()%></h5>
                            <p class="card-text text-danger"><%= String.format("%,.0f", bookPrice)%> VNĐ</p>
                            <div class="card-actions">
                                <a href="book-detail.jsp?id=<%= book.getId()%>" class="btn-view">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                                <form action="AddToCart" method="POST" style="display:none;" id="add-cart-<%= book.getId()%>">
                                    <input type="hidden" name="bookId" value="<%= book.getId()%>">
                                    <input type="hidden" name="bookName" value="<%= book.getName()%>">
                                    <input type="hidden" name="author" value="<%= book.getAuthor()%>">
                                    <input type="hidden" name="publisherEmail" value="<%= book.getPublisherEmail()%>">

                                    <input type="hidden" name="price" value="<%= book.getPrice()%>">
                                    <input type="hidden" name="image" value="<%= bookImage%>">
                                </form>
                                <button class="btn-cart" onclick="document.getElementById('add-cart-<%= book.getId()%>').submit();">
                                    <i class="fas fa-shopping-cart"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>  
                <%  }
                    }
                %>
            </div>
        </div>

        <script>
            function removeFromWishlist(bookId, event) {
                event.stopPropagation();

                Swal.fire({
                    title: 'Xác nhận xóa',
                    text: 'Bạn có chắc muốn xóa sách này khỏi danh sách yêu thích?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc2626',
                    cancelButtonColor: '#6b7280',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        fetch('RemoveFromWishlistServlet', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'bookId=' + bookId
                        })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.status === 'success') {
                                        Swal.fire({
                                            icon: 'success',
                                            title: 'Đã xóa!',
                                            showConfirmButton: false,
                                            timer: 1000
                                        }).then(() => location.reload());
                                    } else {
                                        Swal.fire('Lỗi', data.message, 'error');
                                    }
                                })
                                .catch(err => Swal.fire('Lỗi', 'Không thể kết nối đến server.', 'error'));
                    }
                });
            }
        </script>

        <jsp:include page="footer.jsp" />
    </body>
</html>