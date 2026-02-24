<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat, java.util.Locale, java.util.List, java.util.ArrayList" %>
<%@ page import="utils.LanguageHelper" %>
<%@ page import="dao.CategoryDAO, dao.BookDAO" %>
<%@ page import="entity.Category, entity.Book" %>

<!DOCTYPE html>
<html lang="<%= "vi".equals(session.getAttribute("lang")) ? "vi" : "en" %>">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= LanguageHelper.getText(request, "book.breadcrumb.category") %> - BookStore</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link rel="stylesheet" href="CSS/style.css">
        <style>
            .book-card { background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.08); transition: all 0.3s ease; height: 100%; border: none; }
            .book-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0,0,0,0.12); }
            .book-image-container { position: relative; width: 100%; padding-top: 145%; background-color: #f0f2f5; overflow: hidden; }
            .book-image-container img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease; }
            .book-card:hover .book-image-container img { transform: scale(1.08); }
            .book-info { padding: 15px; text-align: center; }
            .book-info h5 { font-size: 1.05rem; font-weight: 600; margin-bottom: 6px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
            .book-info h5 a { color: #2c3e50; text-decoration: none; transition: color 0.2s; }
            .book-info h5 a:hover { color: #007bff; }
            .book-author { font-size: 0.9rem; color: #6c757d; margin-bottom: 10px; }
            .book-info .price { font-weight: 700; font-size: 1.1rem; }
            .book-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.4); display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s ease; z-index: 2; }
            .book-image-container:hover .book-overlay { opacity: 1; }
            .quick-view { transform: translateY(20px); transition: all 0.3s ease; opacity: 0; }
            .book-image-container:hover .quick-view { transform: translateY(0); opacity: 1; }
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

            String selectedCategory = request.getParameter("category");
            if (selectedCategory == null || selectedCategory.isEmpty()) {
                selectedCategory = "all";
            }

            int currentPage = 1;
            int recordsPerPage = 12;
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
                                <h2 class="mb-4 fw-bold"><%= LanguageHelper.getText(request, "book.breadcrumb.category")%></h2>
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
                        if ("all".equals(selectedCategory)) {
                            for (Category cat : categories) {
                                String categoryKey = cat.getName().toLowerCase().trim();
                                String displayCategory = LanguageHelper.getText(request, "category." + categoryKey);
                                List<Book> previewBooks = bookDAO.getBooksByCategoryPaginated(cat.getName(), 0, 4);

                                if (!previewBooks.isEmpty()) {
                    %>
                    <div class="category-section mb-5">
                        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                            <h3 class="section-title mb-0 text-primary"><%= displayCategory%></h3>
                            <a href="?category=<%= cat.getName()%>" class="btn btn-sm btn-outline-primary">
                                <%= LanguageHelper.getText(request, "featured.view.all")%> <i class="fas fa-arrow-right"></i>
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
                                                <i class="fas fa-eye me-2"></i><%= LanguageHelper.getText(request, "book.view")%>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="book-info">
                                        <h5><a href="book-detail.jsp?id=<%= b.getId()%>" title="<%= b.getName()%>"><%= b.getName()%></a></h5>
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
                        } 
                        else {
                            int totalBooks = bookDAO.countBooksByCategory(selectedCategory);
                            int totalPages = (int) Math.ceil(totalBooks * 1.0 / recordsPerPage);
                            List<Book> books = bookDAO.getBooksByCategoryPaginated(selectedCategory, start, recordsPerPage);

                            String displayCatName = selectedCategory;
                            String key = "category." + selectedCategory.toLowerCase().trim();
                            displayCatName = LanguageHelper.getText(request, key);
                            if (displayCatName.startsWith("???")) displayCatName = selectedCategory; 
                    %>
                    <div class="category-detail-section">
                        <h2 class="section-title text-center mb-4">
                            <%= displayCatName%> 
                            <span class="text-muted fs-5">
                                (<%= totalBooks%> <%= LanguageHelper.getText(request, "books")%>)
                            </span>
                        </h2>

                        <% if (books.isEmpty()) { %>
                        <div class="alert alert-info text-center">
                            <i class="fas fa-info-circle me-2"></i> <%= LanguageHelper.getText(request, "category.empty") %>
                        </div>
                        <% } else { %>
                        
                        <div class="row">
                            <% for (Book b : books) {
                                    String formattedPrice = currencyVN.format(b.getPrice() * 300);
                            %>
                            <div class="col-lg-3 col-md-6 col-sm-6 mb-4">
                                <div class="book-card">
                                    <div class="book-image-container">
                                        <img src="<%= b.getImage()%>" alt="<%= b.getName()%>" loading="lazy">
                                        <div class="book-overlay">
                                            <a href="book-detail.jsp?id=<%= b.getId()%>" class="btn btn-light btn-sm fw-bold quick-view px-3">
                                                <i class="fas fa-eye me-2"></i><%= LanguageHelper.getText(request, "book.view_detail") %>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="book-info">
                                        <h5><a href="book-detail.jsp?id=<%= b.getId()%>" title="<%= b.getName()%>"><%= b.getName()%></a></h5>
                                        <p class="book-author text-truncate mb-2"><small><%= b.getAuthor()%></small></p>
                                        <div class="price"><%= formattedPrice%></div>
                                    </div> 
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <% if (totalPages > 1) {%>
                        <div class="pagination-container mt-5">
                            
                            <div class="text-center mb-3 text-muted small">
                                <%= LanguageHelper.getText(request, "page") %> <%= currentPage %> / <%= totalPages %> 
                                (<%= LanguageHelper.getText(request, "total") %>: <%= totalBooks %> <%= LanguageHelper.getText(request, "books") %>)
                            </div>

                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center">
                                    <li class="page-item <%= currentPage == 1 ? "disabled" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= currentPage - 1%>">
                                            <%= LanguageHelper.getText(request, "pagination.previous") %>
                                        </a>
                                    </li>

                                    <% for (int i = 1; i <= totalPages; i++) {%>
                                    <li class="page-item <%= i == currentPage ? "active" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= i%>"><%= i%></a>
                                    </li>
                                    <% }%>

                                    <li class="page-item <%= currentPage == totalPages ? "disabled" : ""%>">
                                        <a class="page-link" href="?category=<%= selectedCategory%>&page=<%= currentPage + 1%>">
                                            <%= LanguageHelper.getText(request, "pagination.next") %>
                                        </a>
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