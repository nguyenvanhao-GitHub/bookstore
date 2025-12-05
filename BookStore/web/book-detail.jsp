<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.BookDAO, dao.ReviewDAO" %>
<%@ page import="entity.Book, entity.Review" %>
<%@ page import="java.util.List, java.util.Locale, java.text.NumberFormat, java.text.SimpleDateFormat" %>
<%@ page import="utils.LanguageHelper" %>

<%
    // 1. Thiết lập định dạng tiền tệ
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

    // 2. Lấy ID sách từ request (Logic kiểm tra giữ nguyên)
    String bookIdParam = request.getParameter("id");
    if (bookIdParam == null || bookIdParam.isEmpty()) {
        response.sendRedirect("categories.jsp");
        return;
    }

    int bookId = -1;
    try {
        bookId = Integer.parseInt(bookIdParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("categories.jsp");
        return;
    }

    // 3. Sử dụng DAO để lấy thông tin sách (Logic giữ nguyên)
    BookDAO bookDAO = new BookDAO();
    Book book = bookDAO.getBookById(bookId);

    if (book == null) {
        response.sendRedirect("categories.jsp?error=notfound");
        return;
    }

    // 4. Sử dụng DAO để lấy thông tin đánh giá (Logic giữ nguyên)
    ReviewDAO reviewDAO = new ReviewDAO();
    double avgRating = reviewDAO.getAverageRating(bookId);
    int totalReviews = reviewDAO.getTotalReviews(bookId);
    List<Review> reviews = reviewDAO.getReviewsByBookId(bookId);

    // 5. Chuẩn bị dữ liệu hiển thị (Logic giữ nguyên)
    String title = book.getName();
    String author = book.getAuthor();
    String category = book.getCategory();
    String image = (book.getImage() != null && !book.getImage().isEmpty()) ? book.getImage() : "images/default-book.jpg";
    String description = book.getDescription();
    double price = book.getPrice();
    int stock = book.getStock();
    String publisher = book.getPublisherEmail();
    String formattedDate = "N/A";

    String userEmail = (String) session.getAttribute("userEmail");
%>

<jsp:include page="header.jsp" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>

    /* Giữ nguyên CSS của bạn */

    :root {

        --primary-color: #2563eb;

        --secondary-color: #1e40af;

        --success-color: #16a34a;

        --danger-color: #dc2626;

        --warning-color: #f59e0b;

        --text-primary: #1f2937;

        --text-secondary: #6b7280;

        --border-color: #e5e7eb;

        --bg-light: #f9fafb;

    }



    .book-detail-page {

        background-color: var(--bg-light);

        padding: 30px 0 60px;

        min-height: 100vh;

    }



    .breadcrumb-nav {

        background: white;

        padding: 15px 0;

        margin-bottom: 30px;

        border-bottom: 1px solid var(--border-color);

        margin-top: 10px;

    }



    .breadcrumb {

        margin: 0;

        background: transparent;

        padding: 0;

    }



    .breadcrumb-item a {

        color: var(--text-secondary);

        text-decoration: none;

    }



    .breadcrumb-item.active {

        color: var(--text-primary);

        font-weight: 500;

    }



    .product-container {

        background: white;

        border-radius: 12px;

        box-shadow: 0 1px 3px rgba(0,0,0,0.1);

        overflow: hidden;

    }



    .image-section {

        padding: 40px;

        display: flex;

        align-items: center;

        justify-content: center;

        background: #fff;

        border-right: 1px solid var(--border-color);

    }



    .book-image-wrapper {

        position: relative;

        max-width: 400px;

        width: 100%;

    }



    .book-image-wrapper img {

        width: 100%;

        height: auto;

        border-radius: 8px;

        box-shadow: 0 10px 30px rgba(0,0,0,0.15);

        cursor: pointer;

        transition: transform 0.3s ease;

    }



    .book-image-wrapper img:hover {

        transform: scale(1.05);

    }



    .zoom-indicator {

        position: absolute;

        bottom: 15px;

        right: 15px;

        background: rgba(0,0,0,0.7);

        color: white;

        padding: 8px 12px;

        border-radius: 6px;

        font-size: 12px;

        pointer-events: none;

    }



    .info-section {

        padding: 40px;

    }



    .category-badge {

        display: inline-block;

        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

        color: white;

        padding: 6px 16px;

        border-radius: 20px;

        font-size: 13px;

        font-weight: 600;

        text-transform: uppercase;

        letter-spacing: 0.5px;

        margin-bottom: 15px;

    }



    .book-title {

        font-size: 32px;

        font-weight: 700;

        color: var(--text-primary);

        margin: 15px 0 10px;

        line-height: 1.3;

    }



    .book-meta {

        display: flex;

        flex-wrap: wrap;

        gap: 20px;

        margin: 20px 0;

        padding: 20px 0;

        border-top: 1px solid var(--border-color);

        border-bottom: 1px solid var(--border-color);

    }



    .meta-item {

        display: flex;

        align-items: center;

        gap: 8px;

        color: var(--text-secondary);

        font-size: 14px;

    }



    .meta-item i {

        color: var(--primary-color);

        font-size: 16px;

    }



    .meta-item strong {

        color: var(--text-primary);

        font-weight: 600;

    }



    .price-section {

        background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);

        padding: 25px;

        border-radius: 10px;

        margin: 25px 0;

    }



    .price-label {

        font-size: 14px;

        color: var(--text-secondary);

        margin-bottom: 8px;

        font-weight: 500;

    }



    .current-price {

        font-size: 36px;

        font-weight: 700;

        color: var(--danger-color);

        display: block;

    }



    .stock-badge {

        display: inline-flex;

        align-items: center;

        gap: 8px;

        padding: 10px 18px;

        border-radius: 25px;

        font-weight: 600;

        font-size: 14px;

        margin: 20px 0;

    }



    .stock-badge.in-stock {

        background: #dcfce7;

        color: var(--success-color);

    }



    .stock-badge.out-of-stock {

        background: #fee2e2;

        color: var(--danger-color);

    }



    .action-buttons {

        display: flex;

        gap: 15px;

        margin: 30px 0;

    }



    .btn-add-cart {

        flex: 1;

        background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);

        color: white;

        border: none;

        padding: 16px 32px;

        border-radius: 10px;

        font-size: 16px;

        font-weight: 600;

        display: flex;

        align-items: center;

        justify-content: center;

        gap: 10px;

        cursor: pointer;

        transition: all 0.3s ease;

        box-shadow: 0 4px 15px rgba(37, 99, 235, 0.3);

    }



    .btn-add-cart:hover {

        transform: translateY(-2px);

        box-shadow: 0 6px 20px rgba(37, 99, 235, 0.4);

    }



    .btn-add-cart i {

        font-size: 18px;

    }



    .description-section {

        margin: 30px 0;

    }



    .section-title {

        font-size: 20px;

        font-weight: 700;

        color: var(--text-primary);

        margin-bottom: 15px;

        display: flex;

        align-items: center;

        gap: 10px;

    }



    .section-title i {

        color: var(--primary-color);

    }



    .description-text {

        color: var(--text-secondary);

        line-height: 1.8;

        font-size: 15px;

    }



    .review-container {

        background: white;

        border-radius: 12px;

        padding: 40px;

        margin-top: 30px;

        box-shadow: 0 1px 3px rgba(0,0,0,0.1);

    }



    .review-header {

        display: flex;

        justify-content: space-between;

        align-items: center;

        margin-bottom: 30px;

        padding-bottom: 20px;

        border-bottom: 2px solid var(--border-color);

    }



    .rating-summary {

        display: flex;

        align-items: center;

        gap: 20px;

    }



    .rating-score {

        font-size: 48px;

        font-weight: 700;

        color: var(--warning-color);

    }



    .rating-stars {

        font-size: 24px;

        color: var(--warning-color);

    }



    .rating-count {

        color: var(--text-secondary);

        font-size: 14px;

    }



    .review-form {

        background: var(--bg-light);

        padding: 25px;

        border-radius: 10px;

        margin-bottom: 30px;

    }



    .star-rating {

        display: flex;

        flex-direction: row-reverse;

        justify-content: flex-end;

        gap: 5px;

        margin: 15px 0;

    }



    .star-rating input[type="radio"] {

        display: none;

    }



    .star-rating label {

        font-size: 28px;

        cursor: pointer;

        color: #ddd;

        transition: color 0.2s;

    }



    .star-rating input[type="radio"]:checked ~ label,

    .star-rating label:hover,

    .star-rating label:hover ~ label {

        color: var(--warning-color);

    }



    .review-textarea {

        width: 100%;

        padding: 15px;

        border: 2px solid var(--border-color);

        border-radius: 8px;

        font-size: 14px;

        resize: vertical;

        min-height: 100px;

        transition: border-color 0.3s;

    }



    .review-textarea:focus {

        outline: none;

        border-color: var(--primary-color);

    }



    .btn-submit-review {

        background: var(--success-color);

        color: white;

        border: none;

        padding: 12px 30px;

        border-radius: 8px;

        font-weight: 600;

        cursor: pointer;

        transition: all 0.3s;

    }



    .btn-submit-review:hover {

        background: #15803d;

        transform: translateY(-1px);

    }



    .review-list {

        display: flex;

        flex-direction: column;

        gap: 20px;

    }



    .review-item {

        padding: 20px;

        background: var(--bg-light);

        border-radius: 10px;

        border-left: 4px solid var(--primary-color);

    }



    .review-header-item {

        display: flex;

        justify-content: space-between;

        align-items: center;

        margin-bottom: 10px;

    }



    .reviewer-name {

        font-weight: 600;

        color: var(--text-primary);

    }



    .review-stars {

        color: var(--warning-color);

        font-size: 16px;

    }



    .review-comment {

        color: var(--text-secondary);

        line-height: 1.6;

        margin: 10px 0;

    }



    .review-date {

        font-size: 12px;

        color: var(--text-secondary);

    }



    .modal {

        display: none;

        position: fixed;

        z-index: 9999;

        left: 0;

        top: 0;

        width: 100%;

        height: 100%;

        background-color: rgba(0, 0, 0, 0.95);

        animation: fadeIn 0.3s;

    }



    @keyframes fadeIn {

        from {
            opacity: 0;
        }

        to {
            opacity: 1;
        }

    }



    .modal-content {

        display: block;

        width: auto;

        max-width: 90%;

        max-height: 90vh;

        margin: auto;

        position: absolute;

        top: 50%;

        left: 50%;

        transform: translate(-50%, -50%);

        border-radius: 8px;

    }



    .close {

        position: absolute;

        top: 20px;

        right: 35px;

        color: white;

        font-size: 45px;

        font-weight: bold;

        cursor: pointer;

        transition: color 0.3s;

        z-index: 10000;

    }



    .close:hover {
        color: #ccc;
    }



    /* Responsive CSS giữ nguyên như bản gốc */

    @media (max-width: 1200px) {

        .book-title {
            font-size: 2rem;
        }

        .current-price {
            font-size: 2.2rem;
        }

    }

    @media (max-width: 992px) {

        .image-section {
            padding: 25px;
            border-right: none;
            border-bottom: 1px solid var(--border-color);
        }

        .info-section {
            padding: 30px;
        }

        .book-title {
            font-size: 1.8rem;
        }

        .current-price {
            font-size: 2rem;
        }

        .book-meta {
            gap: 15px;
        }

    }

    @media (max-width: 768px) {

        .image-section {
            padding: 20px;
        }

        .book-title {
            font-size: 1.6rem;
        }

        .current-price {
            font-size: 1.8rem;
        }

        .book-meta {
            flex-direction: column;
            gap: 12px;
        }

        .action-buttons {
            flex-direction: column;
        }

        .btn-add-cart {
            width: 100%;
            padding: 14px;
            font-size: 1rem;
        }

        .review-container {
            padding: 20px;
        }

        .review-item {
            padding: 15px;
        }

        .rating-score {
            font-size: 2.2rem;
        }

    }

    @media (max-width: 576px) {

        .book-title {
            font-size: 1.4rem;
        }

        .current-price {
            font-size: 1.6rem;
        }

        .category-badge {
            padding: 5px 12px;
            font-size: 12px;
        }

        .meta-item {
            font-size: 13px;
        }

        .review-textarea {
            font-size: 13px;
            padding: 12px;
        }

        .btn-submit-review {
            width: 100%;
            padding: 12px;
        }

    }

</style>

<main class="book-detail-page">
    <div class="breadcrumb-nav">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp"><i class="fas fa-home"></i> <%= LanguageHelper.getText(request, "book.breadcrumb.home")%></a></li>
                    <li class="breadcrumb-item"><a href="categories.jsp"><%= LanguageHelper.getText(request, "book.breadcrumb.category")%></a></li>
                    <li class="breadcrumb-item active" aria-current="page"><%= title%></li>
                </ol>
            </nav>
        </div>
    </div>

    <div class="container">
        <div class="product-container">
            <div class="row g-0">
                <div class="col-lg-5">
                    <div class="image-section">
                        <div class="book-image-wrapper">
                            <img src="<%= image%>" alt="<%= title%>" id="bookImage" onerror="this.src='images/default-book.jpg'">
                            <div class="zoom-indicator">
                                <i class="fas fa-search-plus"></i> <%= LanguageHelper.getText(request, "book.zoom")%>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-7">
                    <div class="info-section">
                        <span class="category-badge"><%= category%></span>

                        <h1 class="book-title"><%= title%></h1>

                        <div class="book-meta">
                            <div class="meta-item">
                                <i class="fas fa-user-edit"></i>
                                <span><%= LanguageHelper.getText(request, "book.author")%>: <strong><%= author%></strong></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-building"></i>
                                <span><%= LanguageHelper.getText(request, "book.publisher")%>: <strong><%= publisher != null ? publisher : LanguageHelper.getText(request, "common.updating")%></strong></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-calendar-alt"></i>
                                <span><%= LanguageHelper.getText(request, "book.publish.date")%>: <strong><%= formattedDate%></strong></span>
                            </div>
                        </div>

                        <div class="price-section">
                            <div class="price-label"><%= LanguageHelper.getText(request, "book.price.label")%></div>
                            <%
                                double priceInVND = price * 300;
                                String formattedPrice = currencyVN.format(priceInVND);
                            %>
                            <span class="current-price"><%= formattedPrice%></span>
                        </div>

                        <% if (stock > 0) {%>
                        <span class="stock-badge in-stock">
                            <i class="fas fa-check-circle"></i>
                               Còn hàng (<%= stock %> cuốn)

                        </span>
                        <% } else {%>
                        <span class="stock-badge out-of-stock">
                            <i class="fas fa-times-circle"></i>
                            <%= LanguageHelper.getText(request, "book.outstock")%>
                        </span>
                        <% }%>

                        <div class="action-buttons">
                            <form id="addToCartForm" action="AddToCart" method="POST" style="flex: 1;">
                                <input type="hidden" name="bookId" value="<%= book.getId()%>">
                                <input type="hidden" name="bookName" value="<%= title%>">
                                <input type="hidden" name="author" value="<%= author%>">
                                <input type="hidden" name="publisherEmail" value="<%= publisher%>">
                                <input type="hidden" name="price" value="<%= price%>">
                                <input type="hidden" name="image" value="<%= image%>">
                                <button type="submit" class="btn-add-cart" <%= stock <= 0 ? "disabled" : ""%>>
                                    <i class="fas fa-shopping-cart"></i>
                                    <%= LanguageHelper.getText(request, "book.addcart")%>
                                </button>
                            </form>
                        </div>

                        <button type="button" class="btn-add-cart" 
                                style="background: linear-gradient(135deg, #ec4899, #db2777);"
                                onclick="addToWishlist(<%= bookId%>)">
                            <i class="fas fa-heart"></i> <%= LanguageHelper.getText(request, "book.addwishlist")%>
                        </button>

                        <div class="description-section">
                            <h3 class="section-title">
                                <i class="fas fa-info-circle"></i>
                                <%= LanguageHelper.getText(request, "book.description")%>
                            </h3>
                            <p class="description-text">
                                <%= description != null && !description.trim().isEmpty() ? description : LanguageHelper.getText(request, "book.description.empty")%>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="review-container">
            <div class="review-header">
                <div>
                    <h3 class="section-title">
                        <i class="fas fa-star"></i>
                        <%= LanguageHelper.getText(request, "book.review.title")%>
                    </h3>
                </div>
                <div class="rating-summary">
                    <div class="rating-score"><%= totalReviews > 0 ? String.format("%.1f", avgRating) : "0.0"%></div>
                    <div>
                        <div class="rating-stars">
                            <%
                                int fullStars = (int) Math.round(avgRating);
                                for (int i = 0; i < 5; i++) {
                                    if (i < fullStars) {
                            %>
                            <i class="fas fa-star"></i>
                            <% } else { %>
                            <i class="far fa-star"></i>
                            <%      }
                                }
                            %>
                        </div>
                            <div class="rating-count"><%= totalReviews %> đánh giá</div>
                    </div>
                </div>
            </div>

            <% if (userEmail != null) {%>
            <div class="review-form">
                <h4 style="margin-bottom: 15px; color: var(--text-primary);"><%= LanguageHelper.getText(request, "book.review.write")%></h4>
                <form action="AddReviewServlet" method="post" onsubmit="return validateReviewForm()">
                    <input type="hidden" name="bookId" value="<%= bookId%>">

                    <label style="display: block; margin-bottom: 8px; font-weight: 600;"><%= LanguageHelper.getText(request, "book.review.selectstars")%>:</label>
                    <div class="star-rating">
                        <input type="radio" name="rating" value="5" id="star5" required><label for="star5">★</label>
                        <input type="radio" name="rating" value="4" id="star4"><label for="star4">★</label>
                        <input type="radio" name="rating" value="3" id="star3"><label for="star3">★</label>
                        <input type="radio" name="rating" value="2" id="star2"><label for="star2">★</label>
                        <input type="radio" name="rating" value="1" id="star1"><label for="star1">★</label>
                    </div>

                    <textarea name="comment" id="reviewComment" class="review-textarea" 
                              placeholder="<%= LanguageHelper.getText(request, "book.review.placeholder")%>" required></textarea>

                    <button type="submit" class="btn-submit-review">
                        <i class="fas fa-paper-plane"></i> <%= LanguageHelper.getText(request, "book.review.submit")%>
                    </button>
                </form>
            </div>
            <% } else {%>
            <div class="alert alert-info" style="background: #e0f2fe; color: #0369a1; padding: 15px; border-radius: 8px; border-left: 4px solid #0284c7;">
                <i class="fas fa-info-circle"></i> 
                <%= LanguageHelper.getText(request, "book.review.login")%>. Vui lòng <a href="login.jsp" style="color: #0369a1; font-weight: 600;"><%= LanguageHelper.getText(request, "nav.login")%></a> để gửi đánh giá.
            </div>
            <% } %>

            <div class="review-list">
                <%
                    if (reviews != null && !reviews.isEmpty()) {
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                        for (Review r : reviews) {
                            // Logic che email (giữ nguyên)
                            String reviewerEmail = r.getUserEmail();
                            String maskedEmail = "Anonymous";
                            if (reviewerEmail != null && reviewerEmail.contains("@")) {
                                maskedEmail = reviewerEmail.substring(0, Math.min(3, reviewerEmail.indexOf('@')))
                                        + "***@" + reviewerEmail.substring(reviewerEmail.indexOf('@') + 1);
                            }
                %>
                <div class="review-item">
                    <div class="review-header-item">
                        <span class="reviewer-name">
                            <i class="fas fa-user-circle"></i> <%= maskedEmail%>
                        </span>
                        <span class="review-stars">
                            <% for (int i = 0; i < r.getRating(); i++) { %>
                            <i class="fas fa-star"></i>
                            <% }%>
                        </span>
                    </div>
                    <p class="review-comment"><%= r.getComment()%></p>
                    <small class="review-date">
                        <i class="far fa-clock"></i> 
                        <%= sdf.format(r.getCreatedAt())%>
                    </small>
                </div>
                <%      }
                } else {%>
                <div style="text-align: center; padding: 40px; color: var(--text-secondary);">
                    <i class="far fa-comment" style="font-size: 48px; margin-bottom: 15px; opacity: 0.5;"></i>
                    <p><%= LanguageHelper.getText(request, "book.review.none")%></p>
                </div>
                <% }%>
            </div>
        </div>
    </div>
</main>

<div id="imageModal" class="modal">
    <span class="close" onclick="closeImageModal()">&times;</span>
    <img class="modal-content" id="fullImage" alt="Book Image">
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>

        // Validate form trước khi submit (Sử dụng keys)
        function validateReviewForm() {
            const rating = document.querySelector('input[name="rating"]:checked');
            const comment = document.getElementById('reviewComment').value.trim();

            if (!rating) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu đánh giá!',
                    text: '<%= LanguageHelper.getText(request, "book.review.error.missing")%>',
                    confirmButtonColor: '#f59e0b'
                });
                return false;
            }

            if (comment.length < 10) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Nội dung quá ngắn!',
                    text: '<%= LanguageHelper.getText(request, "book.review.error.short")%>',
                    confirmButtonColor: '#f59e0b'
                });
                return false;
            }
            return true;
        }

        // Image modal (Giữ nguyên)
        document.getElementById("bookImage").addEventListener("click", function () {
            let modal = document.getElementById("imageModal");
            let modalImg = document.getElementById("fullImage");
            modal.style.display = "block";
            modalImg.src = this.src;
        });

        function closeImageModal() {
            document.getElementById("imageModal").style.display = "none";
        }

        window.onclick = function (event) {
            let modal = document.getElementById("imageModal");
            if (event.target == modal) {
                modal.style.display = "none";
            }
        };

        // Star rating interaction

        const starRatingContainer = document.querySelector('.star-rating');

        if (starRatingContainer) {

            const starLabels = starRatingContainer.querySelectorAll('label');

            starLabels.forEach(label => {

                label.addEventListener('click', function () {

                    const rating = this.previousElementSibling.value;

                    updateStarDisplay(rating);

                });

                label.addEventListener('mouseover', function () {

                    const rating = this.previousElementSibling.value;

                    updateStarDisplay(rating);

                });

            });



            starRatingContainer.addEventListener('mouseout', function () {

                const checked = starRatingContainer.querySelector('input:checked');

                if (checked) {

                    updateStarDisplay(checked.value);

                } else {

                    starLabels.forEach(l => l.style.color = '#ddd');

                }

            });



            function updateStarDisplay(rating) {

                starLabels.forEach((label) => {

                    const labelValue = label.previousElementSibling.value;

                    label.style.color = (labelValue <= rating) ? '#f59e0b' : '#ddd';

                });

            }

        }

        // Wishlist AJAX (Cần đảm bảo Swal.fire dùng keys)
        function addToWishlist(bookId) {
            fetch("AddToWishlistServlet", {
                method: "POST",
                headers: {"Content-Type": "application/x-www-form-urlencoded"},
                body: "bookId=" + bookId
            })
                    .then(response => response.json())
                    .then(data => {
                        Swal.fire({
                            icon: data.status === "success" ? "success" : data.status === "info" ? "info" : "error",
                            title: data.message,
                            confirmButtonColor: "#2563eb"
                        });
                    })
                    .catch(() => {
                        Swal.fire({
                            icon: "error",
                            title: "<%= LanguageHelper.getText(request, "error.title")%>",
                            text: "<%= LanguageHelper.getText(request, "msg.error.general")%>", // Dùng key chung
                            confirmButtonColor: "#dc2626"
                        });
                    });
        }

        // Cart AJAX (Cần đảm bảo Swal.fire dùng keys)
        document.getElementById('addToCartForm').addEventListener('submit', function (e) {
            e.preventDefault();
            const formData = new FormData(this);
            const params = new URLSearchParams(formData);

            fetch('AddToCart', {method: 'POST', body: params})
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'success') {
                            Swal.fire({
                                icon: 'success',
                                title: data.title,
                                text: data.message,
                                imageAlt: '<%= LanguageHelper.getText(request, "book.image.alt")%>', // Giả định key
                                showCancelButton: true,
                                confirmButtonText: '<%= LanguageHelper.getText(request, "cart.view")%>',
                                cancelButtonText: '<%= LanguageHelper.getText(request, "btn.close")%>', // Dùng key Đóng
                                confirmButtonColor: '#2563eb',
                                cancelButtonColor: '#6b7280'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    window.location.href = 'cart.jsp';
                                }
                            });
                        } else if (data.status === 'warning') {
                            Swal.fire({
                                icon: 'warning',
                                title: data.title,
                                text: data.message,
                                confirmButtonText: '<%= LanguageHelper.getText(request, "nav.login")%>'
                            }).then(() => {
                                if (data.redirect)
                                    window.location.href = data.redirect;
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: data.title,
                                text: data.message
                            });
                        }
                    })
                    .catch(error => {
                        Swal.fire({
                            icon: 'error',
                            title: '<%= LanguageHelper.getText(request, "error.title")%>',
                            text: '<%= LanguageHelper.getText(request, "msg.error.general")%>' // Dùng key lỗi chung
                        });
                    });
        });
</script>