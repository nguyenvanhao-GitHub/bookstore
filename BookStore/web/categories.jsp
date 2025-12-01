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
        <link rel="icon" type="image/png" sizes="32x32" href="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/svgs/solid/book-reader.svg">
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>

        <!-- Include Header -->
        <jsp:include page="header.jsp" />

        <%
            Locale localeVN = new Locale("vi", "VN");
            NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
        %>

        <main class="main-content">
            <!-- Category Search Section -->
            <section class="category-search-section">
                <div class="container">
                    <div class="search-container my-5">
                        <div class="row justify-content-center">
                            <div class="col-md-10 col-lg-8">
                                <div class="search-results" id="categorySearchResults"></div>

                                <!-- Category Filter Buttons -->
                                <div class="category-filter">
                                    <button class="btn filter-btn active" data-category="all">
                                        <%= LanguageHelper.getText(request, "category.all")%>
                                    </button>
                                    <%
                                        try {
                                            Class.forName("com.mysql.cj.jdbc.Driver");
                                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
                                            Statement stmt = conn.createStatement();
                                            ResultSet rs = stmt.executeQuery("SELECT * FROM category ORDER BY name");

                                            while (rs.next()) {
                                                String categoryName = rs.getString("name");
                                                String categoryKey = categoryName.toLowerCase().trim();
                                                String displayText = LanguageHelper.getText(request, "category." + categoryKey);
                                    %>
                                    <button class="btn filter-btn" data-category="<%= displayText%>">
                                        <%= displayText%>
                                    </button>
                                    <%
                                            }
                                            rs.close();
                                            stmt.close();
                                            conn.close();
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                            out.println("<div class='alert alert-danger'>Error loading categories: " + e.getMessage() + "</div>");
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Books by Category Section -->
            <section class="category-books-section">
                <div class="container">
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bookstore", "root", "");
                            Statement categoryStmt = conn.createStatement();
                            ResultSet categoryRs = categoryStmt.executeQuery("SELECT * FROM category ORDER BY name");

                            while (categoryRs.next()) {
                                String categoryName = categoryRs.getString("name");
                                String categoryKey = categoryName.toLowerCase().trim();
                                String displayCategory = LanguageHelper.getText(request, "category." + categoryKey);
                    %>
                    <div class="category-section" data-category="<%= displayCategory%>">
                        <h2 class="section-title"><%= displayCategory%></h2>

                        <div class="row">
                            <%
                                PreparedStatement bookStmt = conn.prepareStatement("SELECT * FROM books WHERE category = ? ORDER BY name LIMIT 12");
                                bookStmt.setString(1, categoryName);
                                ResultSet bookRs = bookStmt.executeQuery();

                                boolean hasBooks = false;
                                while (bookRs.next()) {
                                    hasBooks = true;
                                    double priceInRupees = bookRs.getDouble("price");
                                    double priceInVND = priceInRupees * 300;
                                    String formattedPrice = currencyVN.format(priceInVND);
                            %>
                            <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                                <div class="book-card" data-category="<%= displayCategory%>">
                                    <div class="book-image-container">
                                        <img src="<%= bookRs.getString("image")%>" 
                                             alt="<%= bookRs.getString("name")%>"
                                             loading="lazy">
                                        <div class="book-overlay">
                                            <a href="book-detail.jsp?id=<%= bookRs.getInt("id")%>" 
                                               class="btn quick-view">
                                                <%= LanguageHelper.getText(request, "book.view.books")%>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="book-info">
                                        <h3><%= bookRs.getString("name")%></h3>
                                        <p class="book-author">
                                            <i class="fas fa-pen-fancy"></i>
                                            <%= bookRs.getString("author")%>
                                        </p>
                                        <p class="book-author">
                                            <i class="fas fa-building"></i>
                                            <%= bookRs.getString("publisher_email")%>
                                        </p>
                                        <div class="price">
                                            <%= formattedPrice%>
                                        </div>
                                        <div class="category-tag"><%= displayCategory%></div>
                                    </div> 
                                </div>
                            </div>
                            <%
                                }

                                if (!hasBooks) {
                            %>
                            <div class="col-12">
                                <div class="alert alert-info text-center">
                                    <i class="fas fa-info-circle me-2"></i>
                                    <%= LanguageHelper.getText(request, "category.no.books")%>
                                </div>
                            </div>
                            <%
                                }

                                bookRs.close();
                                bookStmt.close();
                            %>
                        </div>
                    </div>
                    <%
                            }
                            categoryRs.close();
                            categoryStmt.close();
                            conn.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<div class='alert alert-danger'>Error loading books: " + e.getMessage() + "</div>");
                        }
                    %>
                </div>
            </section>
        </main>

        <!-- Include Footer -->
        <jsp:include page="footer.jsp" />

        <!-- JavaScript Dependencies -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="Js/search.js"></script>

        <script>
        // Category Filter Functionality
            document.addEventListener('DOMContentLoaded', function () {
                const filterButtons = document.querySelectorAll('.filter-btn');
                const categorySections = document.querySelectorAll('.category-section');

                filterButtons.forEach(button => {
                    button.addEventListener('click', function () {
                        const category = this.getAttribute('data-category');

                        // Update active button
                        filterButtons.forEach(btn => btn.classList.remove('active'));
                        this.classList.add('active');

                        // Filter categories
                        if (category === 'all') {
                            categorySections.forEach(section => {
                                section.style.display = 'block';
                            });
                        } else {
                            categorySections.forEach(section => {
                                if (section.getAttribute('data-category') === category) {
                                    section.style.display = 'block';
                                } else {
                                    section.style.display = 'none';
                                }
                            });
                        }

                        // Smooth scroll to first visible category
                        setTimeout(() => {
                            const firstVisible = document.querySelector('.category-section[style="display: block;"]');
                            if (firstVisible) {
                                firstVisible.scrollIntoView({behavior: 'smooth', block: 'start'});
                            }
                        }, 100);
                    });
                });
            });
        </script>

    </body>
</html>