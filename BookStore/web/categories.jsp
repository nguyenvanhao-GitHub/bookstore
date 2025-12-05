<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat, java.util.Locale, java.util.List, java.util.ArrayList" %>
<%@ page import="utils.LanguageHelper" %>
<%@ page import="dao.CategoryDAO, dao.BookDAO" %>
<%@ page import="entity.Category, entity.Book" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Categories - BookStore</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link rel="stylesheet" href="CSS/style.css">
        <style>
            /* --- CSS CHUẨN HÓA CARD SÁCH (Dùng chung cho Categories và Nổi bật) --- */

            /* Khung bao ngoài của một cuốn sách */
            .book-card {
                background: #fff;
                border-radius: 8px;      /* Bo tròn góc nhẹ */
                overflow: hidden;        /* Ẩn phần ảnh/nội dung tràn ra ngoài */
                box-shadow: 0 2px 5px rgba(0,0,0,0.08); /* Đổ bóng nhẹ tạo chiều sâu */
                transition: all 0.3s ease; /* Hiệu ứng mượt mà khi hover */
                height: 100%;            /* Đảm bảo các card trong cùng hàng cao bằng nhau */
                border: none;            /* Xóa border mặc định nếu có */
            }

            /* Hiệu ứng khi di chuột vào card sách */
            .book-card:hover {
                transform: translateY(-5px); /* Nổi lên trên một chút */
                box-shadow: 0 8px 20px rgba(0,0,0,0.12); /* Bóng đổ sâu hơn */
            }

            /* Khung chứa hình ảnh - QUAN TRỌNG ĐỂ CHUẨN HÓA KÍCH THƯỚC */
            .book-image-container {
                position: relative;
                width: 100%;
                /* Mẹo tạo tỷ lệ khung hình cố định (Aspect Ratio) */
                /* padding-top = (Chiều cao mong muốn / Chiều rộng) * 100% */
                /* Ví dụ: Tỷ lệ 2:3 (ảnh bìa sách chuẩn) -> (3/2)*100 = 150% */
                padding-top: 145%;
                background-color: #f0f2f5; /* Màu nền placeholder nhẹ khi ảnh đang tải */
                overflow: hidden;
            }

            /* Hình ảnh bên trong khung */
            .book-image-container img {
                position: absolute; /* Tuyệt đối so với .book-image-container */
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                /* CỰC KỲ QUAN TRỌNG: Ảnh lấp đầy khung, tự cắt phần thừa, KHÔNG BỊ MÉO */
                object-fit: cover;
                transition: transform 0.5s ease; /* Hiệu ứng zoom mượt mà */
            }

            /* Hiệu ứng zoom ảnh nhẹ khi di chuột vào card */
            .book-card:hover .book-image-container img {
                transform: scale(1.08); /* Zoom ảnh lên 8% */
            }

            /* Phần thông tin sách bên dưới ảnh */
            .book-info {
                padding: 15px;
                text-align: center;
            }

            /* Tên sách */
            .book-info h5 {
                font-size: 1.05rem;
                font-weight: 600;
                margin-bottom: 6px;
                /* Cắt tên sách nếu quá dài (chỉ hiện 1 dòng + dấu ...) */
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .book-info h5 a {
                color: #2c3e50;
                text-decoration: none;
                transition: color 0.2s;
            }

            .book-info h5 a:hover {
                color: #007bff; /* Đổi màu khi hover tên sách */
            }

            /* Tên tác giả */
            .book-author {
                font-size: 0.9rem;
                color: #6c757d;
                margin-bottom: 10px;
            }

            /* Giá tiền */
            .book-info .price {
                font-weight: 700;
                font-size: 1.1rem;
            }

            /* Nút "Xem chi tiết" (Overlay) */
            .book-overlay {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.4); /* Nền tối mờ */
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0; /* Ẩn mặc định */
                transition: opacity 0.3s ease;
                z-index: 2;
            }

            /* Hiện overlay khi hover vào phần ảnh */
            .book-image-container:hover .book-overlay {
                opacity: 1;
            }

            .quick-view {
                transform: translateY(20px); /* Nút trượt từ dưới lên */
                transition: all 0.3s ease;
                opacity: 0;
            }

            .book-image-container:hover .quick-view {
                transform: translateY(0);
                opacity: 1;
            }
        </style>
    </head>
    <body>

        <jsp:include page="header.jsp" />

        <%
            Locale localeVN = new Locale("vi", "VN");
            NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

            CategoryDAO catDAO = new CategoryDAO();
            BookDAO bookDAO = new BookDAO();
            List<Category> categories = catDAO.getAllCategories();

            // 1. Lấy tham số từ URL
            String selectedCategory = request.getParameter("category");
            if (selectedCategory == null || selectedCategory.isEmpty()) {
                selectedCategory = "all";
            }

            // 2. Cấu hình phân trang
            int currentPage = 1;
            int recordsPerPage = 12; // Số sách mỗi trang
            if (request.getParameter("page") != null) {
                try {
                    currentPage = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }
            int start = (currentPage - 1) * recordsPerPage;
        %>

        <main class="main-content">
            <section class="category-search-section">
                <div class="container">
                    <div class="search-container my-5">
                        <div class="row justify-content-center">
                            <div class="col-md-12 text-center">
                                <h2 class="mb-4 fw-bold">Danh Mục Sách</h2>
                                <div class="category-filter d-flex flex-wrap justify-content-center gap-2">
                                    <a href="?category=all" class="btn filter-btn <%= "all".equals(selectedCategory) ? "active" : ""%>">
                                        <%= LanguageHelper.getText(request, "category.all")%>
                                    </a>

                                    <% for (Category cat : categories) {
                                            String catName = cat.getName();
                                            String categoryKey = catName.toLowerCase().trim();
                                            String displayText = LanguageHelper.getText(request, "category." + categoryKey);
                                            boolean isActive = catName.equals(selectedCategory);
                                    %>
                                    <a href="?category=<%= catName%>" class="btn filter-btn <%= isActive ? "active" : ""%>">
                                        <%= displayText%>
                                    </a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="category-books-section">
                <div class="container">

                    <%
                        // TRƯỜNG HỢP 1: Xem TẤT CẢ (Hiển thị dạng Hub - mỗi danh mục 4 cuốn)
                        if ("all".equals(selectedCategory)) {
                            for (Category cat : categories) {
                                String categoryKey = cat.getName().toLowerCase().trim();
                                String displayCategory = LanguageHelper.getText(request, "category." + categoryKey);
                                // Lấy 4 sách mới nhất để preview (dùng hàm phân trang với limit 4)
                                List<Book> previewBooks = bookDAO.getBooksByCategoryPaginated(cat.getName(), 0, 4);

                                if (!previewBooks.isEmpty()) {
                    %>
                    <div class="category-section mb-5">
                        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                            <h3 class="section-title mb-0 text-primary"><%= displayCategory%></h3>
                            <a href="?category=<%= cat.getName()%>" class="btn btn-sm btn-outline-primary">
                                Xem tất cả <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                        <div class="row">
                            <% for (Book b : previewBooks) {
                                    String formattedPrice = currencyVN.format(b.getPrice() * 300);
                            %>
                            <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                                <div class="book-card">

                                    <div class="book-image-container">
                                        <img src="<%= b.getImage()%>" alt="<%= b.getName()%>" loading="lazy">

                                        <div class="book-overlay">
                                            <a href="book-detail.jsp?id=<%= b.getId()%>" class="btn btn-light btn-sm fw-bold quick-view px-3">
                                                <i class="fas fa-eye me-2"></i>Xem chi tiết
                                            </a>
                                        </div>
                                    </div>

                                    <div class="book-info">
                                        <h5>
                                            <a href="book-detail.jsp?id=<%= b.getId()%>" title="<%= b.getName()%>">
                                                <%= b.getName()%>
                                            </a>
                                        </h5>
                                        <p class="book-author text-truncate mb-2"><small><%= b.getAuthor()%></small></p>
                                        <div class="price"><%= formattedPrice%></div>
                                    </div> 
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <%      }
                        }
                    } // TRƯỜNG HỢP 2: Xem CHI TIẾT 1 Danh mục (Có phân trang)
                    else {
                        // Tính toán phân trang
                        int totalBooks = bookDAO.countBooksByCategory(selectedCategory);
                        int totalPages = (int) Math.ceil(totalBooks * 1.0 / recordsPerPage);
                        List<Book> books = bookDAO.getBooksByCategoryPaginated(selectedCategory, start, recordsPerPage);

                        String displayCatName = selectedCategory; // Có thể map lại language nếu cần
                    %>
                    <div class="category-detail-section">
                        <h2 class="section-title text-center mb-4"><%= displayCatName%> <span class="text-muted fs-5">(<%= totalBooks%> sách)</span></h2>

                        <% if (books.isEmpty()) { %>
                        <div class="alert alert-info text-center">
                            <i class="fas fa-info-circle me-2"></i> Chưa có sách nào trong danh mục này.
                        </div>
                        <% } else { %>
                        <div class="row">
                            <% for (Book b : books) {
                                    String formattedPrice = currencyVN.format(b.getPrice() * 300);
                            %>
                            <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                                <div class="book-card h-100 shadow-sm border-0">
                                    <div class="book-image-container position-relative overflow-hidden">
                                        <img src="<%= b.getImage()%>" class="img-fluid w-100" style="height: 300px; object-fit: cover;" alt="<%= b.getName()%>">
                                        <div class="book-overlay">
                                            <a href="book-detail.jsp?id=<%= b.getId()%>" class="btn btn-light quick-view">Xem chi tiết</a>
                                        </div>
                                    </div>
                                    <div class="book-info p-3 text-center">
                                        <h5 class="text-truncate"><a href="book-detail.jsp?id=<%= b.getId()%>" class="text-decoration-none text-dark"><%= b.getName()%></a></h5>
                                        <p class="text-muted small mb-1"><%= b.getAuthor()%></p>
                                        <div class="price fw-bold text-success"><%= formattedPrice%></div>
                                    </div> 
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <% if (totalPages > 1) {%>
                        <div class="pagination-container mt-5">
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center">
                                    <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= currentPage - 1%>">Trước</a>
                                    </li>

                                    <% for (int i = 1; i <= totalPages; i++) {%>
                                    <li class="page-item <%= i == currentPage ? "active" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= i%>"><%= i%></a>
                                    </li>
                                    <% }%>

                                    <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= currentPage + 1%>">Sau</a>
                                    </li>
                                </ul>
                            </nav>
                        </div>
                        <% } %>
                        <% } %>
                    </div>
                    <% }%>

                </div>
            </section>
        </main>

        <jsp:include page="footer.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>