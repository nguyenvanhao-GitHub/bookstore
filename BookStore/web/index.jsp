<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="utils.LanguageHelper" %>

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
    
</head>
<body>

<!-- Include Header -->
<jsp:include page="header.jsp" />

<main class="main-content">
    <!-- Hero Section with Slideshow -->
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

            <!-- Navigation Arrows -->
            <button class="prev" onclick="changeSlide(-1)" aria-label="Previous slide">
                <i class="fas fa-chevron-left"></i>
            </button>
            <button class="next" onclick="changeSlide(1)" aria-label="Next slide">
                <i class="fas fa-chevron-right"></i>
            </button>

            <!-- Dots Navigation -->
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
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
                        PreparedStatement ps = conn.prepareStatement("SELECT * FROM books LIMIT 20");
                        ResultSet rs = ps.executeQuery();

                        Locale localeVN = new Locale("vi", "VN");
                        NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

                        while (rs.next()) {
                            double priceInRupees = rs.getDouble("price");
                            double priceInVND = priceInRupees * 300;
                            String formattedPrice = currencyVN.format(priceInVND);
                %>
                <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                    <div class="book-card">
                        <div class="book-image-container">
                            <img src="<%= rs.getString("image") %>" alt="<%= rs.getString("name") %>">
                            <div class="book-overlay">
                                <a class="btn quick-view" href="book-detail.jsp?id=<%= rs.getInt("id") %>">
                                    <%= LanguageHelper.getText(request, "book.view.books") %>
                                </a>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3><%= rs.getString("name") %></h3>
                            <p class="book-author">
                                <i class="fas fa-pen-fancy"></i>
                                <%= rs.getString("author") %>
                            </p>
                            <div class="price"><%= formattedPrice %></div>
                            <div class="category-tag"><%= rs.getString("category") %></div>
                        </div>
                    </div>
                </div>
                <%
                        }
                        rs.close();
                        ps.close();
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<div class='col-12'><div class='alert alert-danger'>Error loading books: " + e.getMessage() + "</div></div>");
                    }
                %>
            </div>
        </div>
    </section>
</main>

<!-- Include Footer -->
<jsp:include page="footer.jsp" />

<!-- JavaScript Dependencies -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="Js/search.js"></script>
<script src="Js/slideshow.js"></script>

</body>
</html>