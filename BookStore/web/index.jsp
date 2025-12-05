<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat, java.util.Locale, java.util.List" %>
<%@ page import="utils.LanguageHelper" %>
<%@ page import="dao.BookDAO" %>
<%@ page import="entity.Book" %>

<%
    // Phân trang
    int pageSize = 8; // Số sách trên mỗi trang
    int currentPage = 1;
    
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    BookDAO bookDAO = new BookDAO();
    int totalBooks = bookDAO.getTotalFeaturedBooks();
    int totalPages = (int) Math.ceil((double) totalBooks / pageSize);
    
    // Đảm bảo trang hiện tại không vượt quá tổng số trang
    if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
    }
    
    List<Book> featuredBooks = bookDAO.getFeaturedBooks(currentPage, pageSize);
    
    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Books - Your Digital Library</title>
    <link rel="icon" type="image/png" sizes="32x32" href="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/svgs/solid/book-reader.svg">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    
    <style>
        /* Pagination Styles */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 40px;
            gap: 10px;
        }
        
        .pagination {
            display: flex;
            gap: 8px;
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .pagination .page-item {
            display: inline-block;
        }
        
        .pagination .page-link {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 40px;
            height: 40px;
            padding: 8px 12px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            color: #374151;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            background: white;
        }
        
        .pagination .page-link:hover {
            background: #f3f4f6;
            border-color: #2563eb;
            color: #2563eb;
            transform: translateY(-2px);
        }
        
        .pagination .page-item.active .page-link {
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
            color: white;
            border-color: #2563eb;
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.3);
        }
        
        .pagination .page-item.disabled .page-link {
            opacity: 0.5;
            cursor: not-allowed;
            pointer-events: none;
        }
        
        .page-info {
            color: #6b7280;
            font-size: 14px;
            margin: 0 15px;
        }
        
        @media (max-width: 576px) {
            .pagination .page-link {
                min-width: 35px;
                height: 35px;
                padding: 6px 10px;
                font-size: 14px;
            }
            
            .page-info {
                font-size: 12px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="header.jsp" />

<main class="main-content">
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="slideshow-container">
            <div class="slides fade active">
                <img src="images/slideshow/bookslide (1).jpg" alt="Book Collection">
                <div class="slide-content">
                    <h1><%= LanguageHelper.getText(request, "hero.browse.title") %></h1>
                    <p class="lead"><%= LanguageHelper.getText(request, "hero.browse.desc") %></p>
                </div>
            </div>
            <div class="slides fade">
                <img src="images/slideshow/bookslide (2).jpg" alt="Reading Time">
                <div class="slide-content">
                    <h1><%= LanguageHelper.getText(request, "hero.read.title") %></h1>
                    <p class="lead"><%= LanguageHelper.getText(request, "hero.read.desc") %></p>
                </div>
            </div>
            <div class="slides fade">
                <img src="images/slideshow/bookslide (3).jpg" alt="Special Offers">
                <div class="slide-content">
                    <h1><%= LanguageHelper.getText(request, "hero.offers.title") %></h1>
                    <p class="lead"><%= LanguageHelper.getText(request, "hero.offers.desc") %></p>
                </div>
            </div>
            <div class="slides fade">
                <img src="images/slideshow/bookslide (4).jpg" alt="Digital Reading">
                <div class="slide-content">
                    <h1><%= LanguageHelper.getText(request, "hero.digital.title") %></h1>
                    <p class="lead"><%= LanguageHelper.getText(request, "hero.digital.desc") %></p>
                </div>
            </div>

            <button class="prev" onclick="changeSlide(-1)" aria-label="Previous slide">
                <i class="fas fa-chevron-left"></i>
            </button>
            <button class="next" onclick="changeSlide(1)" aria-label="Next slide">
                <i class="fas fa-chevron-right"></i>
            </button>

            <div class="dots-container">
                <span class="dot active" onclick="currentSlide(1)" aria-label="Slide 1"></span>
                <span class="dot" onclick="currentSlide(2)" aria-label="Slide 2"></span>
                <span class="dot" onclick="currentSlide(3)" aria-label="Slide 3"></span>
                <span class="dot" onclick="currentSlide(4)" aria-label="Slide 4"></span>
            </div>
        </div>
    </section>

    <!-- Featured Books Section -->
    <section id="Featuredbooks" class="new-books-section">
        <div class="container">
            <h2 class="section-title"><%= LanguageHelper.getText(request, "featured.books.title") %></h2>
            
            <div class="row">
                <%
                    if (featuredBooks.isEmpty()) {
                %>
                    <div class='col-12'>
                        <div class='alert alert-info text-center'>
                            <i class='fas fa-info-circle'></i> Đang cập nhật sách...
                        </div>
                    </div>
                <%
                    } else {
                        for (Book b : featuredBooks) {
                            double priceVND = b.getPrice() * 300;
                            String formattedPrice = currencyVN.format(priceVND);
                %>
                <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                    <div class="book-card">
                        <div class="book-image-container">
                            <img src="<%= b.getImage() %>" alt="<%= b.getName() %>" onerror="this.src='images/default-book.jpg'">
                            <div class="book-overlay">
                                <a class="btn quick-view" href="book-detail.jsp?id=<%= b.getId() %>">
                                    <%= LanguageHelper.getText(request, "book.view.books") %>
                                </a>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3><%= b.getName() %></h3>
                            <p class="book-author">
                                <i class="fas fa-pen-fancy"></i>
                                <%= b.getAuthor() %>
                            </p>
                            <div class="price"><%= formattedPrice %></div>
                            <div class="category-tag"><%= b.getCategory() %></div>
                        </div>
                    </div>
                </div>
                <%      }
                    }
                %>
            </div>

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="pagination-container">
                <nav aria-label="Page navigation">
                    <ul class="pagination">
                        <!-- Previous Button -->
                        <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage - 1 %>#Featuredbooks" aria-label="Previous">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </li>

                        <%
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            
                            // Hiển thị trang đầu
                            if (startPage > 1) {
                        %>
                            <li class="page-item">
                                <a class="page-link" href="?page=1#Featuredbooks">1</a>
                            </li>
                            <% if (startPage > 2) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            <% } %>
                        <% } %>

                        <!-- Các trang ở giữa -->
                        <% for (int i = startPage; i <= endPage; i++) { %>
                            <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                <a class="page-link" href="?page=<%= i %>#Featuredbooks"><%= i %></a>
                            </li>
                        <% } %>

                        <!-- Hiển thị trang cuối -->
                        <% if (endPage < totalPages) { %>
                            <% if (endPage < totalPages - 1) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            <% } %>
                            <li class="page-item">
                                <a class="page-link" href="?page=<%= totalPages %>#Featuredbooks"><%= totalPages %></a>
                            </li>
                        <% } %>

                        <!-- Next Button -->
                        <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                            <a class="page-link" href="?page=<%= currentPage + 1 %>#Featuredbooks" aria-label="Next">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
                
                <div class="page-info">
                    Trang <%= currentPage %> / <%= totalPages %> (Tổng <%= totalBooks %> sách)
                </div>
            </div>
            <% } %>
        </div>
    </section>
</main>

<jsp:include page="footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="Js/search.js"></script>
<script src="Js/slideshow.js"></script>

<script>
    // Smooth scroll to books section when clicking pagination
    document.addEventListener('DOMContentLoaded', function() {
        if (window.location.hash === '#Featuredbooks') {
            setTimeout(function() {
                document.getElementById('Featuredbooks').scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }, 100);
        }
    });
</script>

</body>
</html>