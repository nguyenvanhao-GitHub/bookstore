<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="utils.LanguageHelper" %>
<%@ page import="dao.CartDAO" %>
<%@ page import="entity.CartItem" %>

<%
    // ==================== LANGUAGE SETUP ====================
    String langParam = request.getParameter("lang");
    if (langParam != null) {
        LanguageHelper.setLanguage(request, langParam);
    }

    String currentLang = (String) session.getAttribute("lang");
    if (currentLang == null) {
        currentLang = "vi";
        session.setAttribute("lang", currentLang);
    }
%>

<%
    // ==================== SESSION DATA ====================
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    boolean isLoggedIn = (userName != null && userEmail != null);
%>

<%
    // ==================== CART DATA (MVC Refactored) ====================
    int totalItems = 0;
    double totalPrice = 0.0;
    List<CartItem> displayCartItems = new ArrayList<>();

    Locale localeVN = new Locale("vi", "VN");
    NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);

    if (isLoggedIn) {
        try {
            CartDAO cartDAO = new CartDAO();
            List<CartItem> allCartItems = cartDAO.getCartItems(userEmail);

            // Tính tổng số lượng và tổng tiền
            for (CartItem item : allCartItems) {
                totalItems += item.getQuantity();
                // Giả sử giá trong DB là USD, nhân 300 ra VND (logic cũ của bạn)
                totalPrice += (item.getPrice() * 300) * item.getQuantity();
            }

            // Chỉ lấy 5 sản phẩm mới nhất để hiển thị trong dropdown
            if (allCartItems.size() > 5) {
                displayCartItems = allCartItems.subList(0, 5);
            } else {
                displayCartItems = allCartItems;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<%
    // ==================== CACHE CONTROL ====================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="<%= currentLang%>">
    <head>
        <!-- ==================== META TAGS ==================== -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="E-Books - Your Digital Library. Discover thousands of books online.">
        <meta name="keywords" content="ebooks, books, online library, digital books">
        <meta name="author" content="E-Books">

        <title>E-Books - Your Digital Library</title>

        <!-- ==================== FAVICON ==================== -->
        <link rel="icon" type="image/svg+xml" href="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/svgs/solid/book-reader.svg">

        <!-- ==================== FONTS ==================== -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

        <!-- ==================== STYLESHEETS ==================== -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
        <link rel="stylesheet" href="CSS/style.css">
        <link rel="stylesheet" href="CSS/theme.css">
        <link rel="stylesheet" href="CSS/responsive-header.css">

    </head>
    <body>
        <!-- ==================== MAIN HEADER ==================== -->
        <header class="main-header" role="banner">

            <!-- ===== PRIMARY NAVBAR ===== -->
            <nav class="primary-navbar" role="navigation" aria-label="Main navigation">
                <div class="container-fluid">
                    <div class="navbar-content">

                        <!-- Logo -->
                        <a class="brand-logo" href="index.jsp" aria-label="E-Books Home">
                            <i class="fas fa-book-reader" aria-hidden="true"></i>
                            <span>E-Books</span>
                        </a>

                        <!-- Desktop Navigation -->
                        <ul class="nav-links d-none d-lg-flex" role="menubar" class="active">
                            <li role="none">
                                <a href="index.jsp#home" role="menuitem">
                                    <%= LanguageHelper.getText(request, "nav.home")%>
                                </a>
                            </li>
                            <li role="none">
                                <a href="index.jsp#Featuredbooks" role="menuitem"> 
                                    <%= LanguageHelper.getText(request, "nav.featured")%>
                                </a>
                            </li>
                            <li role="none">
                                <a href="categories.jsp" role="menuitem">
                                    <%= LanguageHelper.getText(request, "nav.explore")%>
                                </a>
                            </li>
                            <li role="none">
                                <a href="about.jsp" role="menuitem">
                                    <%= LanguageHelper.getText(request, "nav.about")%>
                                </a>
                            </li>
                            <li role="none">
                                <a href="contact.jsp" role="menuitem">
                                    <%= LanguageHelper.getText(request, "nav.contact")%>
                                </a>
                            </li>
                        </ul>

                        <!-- Right Actions -->
                        <div class="nav-right d-flex align-items-center">

                            <!-- Desktop Search -->
                            <div class="search-container me-3">
                                <input 
                                    type="search" 
                                    class="search-input" 
                                    id="searchInput" 
                                    placeholder="<%= LanguageHelper.getText(request, "nav.search.placeholder")%>"
                                    aria-label="Search books"
                                    autocomplete="off">
                                <i class="fas fa-search search-icon" aria-hidden="true"></i>

                                <div class="search-results" id="searchResults" role="listbox" aria-label="Search results"></div>
                            </div>

                            <!-- Language Selector -->
                            <div class="action-item language-selector d-none d-lg-block">
                                <button class="action-btn" aria-label="Change language" aria-haspopup="true" aria-expanded="false">
                                    <% if ("en".equals(currentLang)) { %>
                                    <img src="images/flags/gb.png" alt="English" width="24" height="24">
                                    <% } else { %>
                                    <img src="images/flags/vn.png" alt="Tiếng Việt" width="24" height="24">
                                    <% }%>
                                </button>
                                <div class="action-dropdown" role="menu">
                                    <a href="?lang=vi" class="dropdown-item" role="menuitem">
                                        <img src="images/flags/vn.png" alt="" width="20" height="20">
                                        <span>Tiếng Việt</span>
                                    </a>
                                    <a href="?lang=en" class="dropdown-item" role="menuitem">
                                        <img src="images/flags/gb.png" alt="" width="20" height="20">
                                        <span>English</span>
                                    </a>
                                </div>
                            </div>

                            <!-- Cart -->
                            <div class="action-item cart-dropdown-wrapper">
                                <button class="action-btn" aria-label="Shopping cart, <%= totalItems%> items" aria-haspopup="true" aria-expanded="false">
                                    <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                                    <% if (totalItems > 0) {%>
                                    <span class="badge" aria-label="<%= totalItems%> items"><%= totalItems%></span>
                                    <% }%>
                                </button>
                                <div class="action-dropdown cart-dropdown" role="dialog" aria-label="Shopping cart">
                                    <div class="dropdown-header">
                                        <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                                        <%= LanguageHelper.getText(request, "cart.new.items")%>
                                    </div>

                                    <% if (displayCartItems.isEmpty()) {%>
                                    <div class="empty-state">
                                        <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                                        <p><%= LanguageHelper.getText(request, "cart.empty")%></p>
                                    </div>
                                    <% } else { %>
                                    <div class="cart-items">
                                        <% for (CartItem item : displayCartItems) {%>
                                        <div class="cart-item">
                                            <img src="<%= item.getImage()%>" 
                                                 alt="<%= item.getBookName()%>"
                                                 loading="lazy"
                                                 width="60"
                                                 height="80">
                                            <div class="item-details">
                                                <h6><%= item.getBookName()%></h6>
                                                <p>
                                                    <i class="fas fa-user" aria-hidden="true"></i> 
                                                    <%= item.getAuthor()%>
                                                </p>
                                                <div class="item-footer">
                                                    <span class="price">
                                                        <%= currencyVN.format(item.getPrice() * 300)%>
                                                    </span>
                                                    <span class="quantity">x<%= item.getQuantity()%></span>
                                                </div>
                                            </div>
                                        </div>
                                        <% }%>
                                    </div>
                                    <div class="dropdown-footer">
                                        <div class="total-row">
                                            <span>
                                                <%= LanguageHelper.getText(request, "cart.total")%> 
                                                (<%= totalItems%>)
                                            </span>
                                            <strong><%= currencyVN.format(totalPrice)%></strong>
                                        </div>
                                        <div class="action-buttons">
                                            <a href="cart.jsp" class="btn-outline">
                                                <%= LanguageHelper.getText(request, "cart.view")%>
                                            </a>
                                            <a href="checkout.jsp" class="btn-primary">
                                                <%= LanguageHelper.getText(request, "cart.checkout")%>
                                            </a>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            </div>

                            <!-- User -->
                            <% if (!isLoggedIn) { %>
                            <a href="login.jsp" class="action-item" aria-label="Login">
                                <button class="action-btn">
                                    <i class="fas fa-user" aria-hidden="true"></i>
                                </button>
                            </a>
                            <% } else {%>
                            <div class="action-item user-dropdown-wrapper">
                                <button class="action-btn user-btn" aria-label="User menu" aria-haspopup="true" aria-expanded="false">
                                    <div class="user-avatar" aria-hidden="true">
                                        <%= userName.substring(0, 1).toUpperCase()%>
                                    </div>
                                </button>

                                <div class="action-dropdown user-dropdown" role="menu">
                                    <div class="user-info">
                                        <div class="user-avatar large" aria-hidden="true">
                                            <%= userName.substring(0, 1).toUpperCase()%>
                                        </div>
                                        <div class="user-details">
                                            <div class="user-name"><%= userName%></div>
                                            <div class="user-email"><%= userEmail%></div>
                                        </div>
                                    </div>

                                    <div class="user-menu-list">
                                        <a href="profile.jsp" class="dropdown-item" role="menuitem">
                                            <i class="fas fa-user" aria-hidden="true"></i>
                                            <span><%= LanguageHelper.getText(request, "user.profile")%></span>
                                        </a>
                                        <a href="orders.jsp" class="dropdown-item" role="menuitem">
                                            <i class="fas fa-box" aria-hidden="true"></i>
                                            <span><%= LanguageHelper.getText(request, "user.orders")%></span>
                                        </a>
                                        <a href="wishlist.jsp" class="dropdown-item" role="menuitem">
                                            <i class="fas fa-heart" aria-hidden="true"></i>
                                            <span><%= LanguageHelper.getText(request, "user.wishlist")%></span>
                                        </a>
                                        <a href="settings.jsp" class="dropdown-item" role="menuitem">
                                            <i class="fas fa-cog" aria-hidden="true"></i>
                                            <span><%= LanguageHelper.getText(request, "user.settings")%></span>
                                        </a>

                                        <div class="dropdown-divider" role="separator"></div>

                                        <form action="LogoutServlet" method="post" class="logout-form">
                                            <button type="submit" class="dropdown-item logout-btn" role="menuitem">
                                                <i class="fas fa-sign-out-alt" aria-hidden="true"></i>
                                                <span><%= LanguageHelper.getText(request, "user.logout")%></span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <% }%>

                            <!-- Mobile Menu Toggle -->
                            <button class="mobile-menu-btn d-lg-none" data-bs-toggle="offcanvas" data-bs-target="#mobileMenu" aria-label="Open mobile menu" aria-controls="mobileMenu" aria-expanded="false">
                                <i class="fas fa-bars" aria-hidden="true"></i>
                            </button>

                        </div>
                    </div>
                </div>
            </nav>

            <!-- ===== MOBILE SEARCH BAR ===== -->
            <div class="mobile-search d-lg-none">
                <div class="container-fluid">
                    <div class="search-box">
                        <input type="search" id="searchInputMobile" placeholder="<%= LanguageHelper.getText(request, "nav.search.placeholder")%>" aria-label="Search books" autocomplete="off">
                        <button class="search-submit" aria-label="Search">
                            <i class="fas fa-search" aria-hidden="true"></i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ===== MOBILE MENU OFFCANVAS ===== -->
            <div class="offcanvas offcanvas-start" tabindex="-1" id="mobileMenu" aria-labelledby="mobileMenuLabel">
                <div class="offcanvas-header">
                    <a class="brand-logo" href="index.jsp" id="mobileMenuLabel">
                        <i class="fas fa-book-reader" aria-hidden="true"></i>
                        <span>E-Books</span>
                    </a>
                    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close menu"></button>
                </div>

                <div class="offcanvas-body">
                    <% if (isLoggedIn) {%>
                    <div class="mobile-user-card">
                        <div class="user-avatar large" aria-hidden="true">
                            <%= userName.substring(0, 1).toUpperCase()%>
                        </div>
                        <div>
                            <div class="user-name"><%= userName%></div>
                            <div class="user-email"><%= userEmail%></div>
                        </div>
                    </div>
                    <% }%>

                    <nav class="mobile-nav-section" aria-label="Mobile navigation">
                        <h6><%= LanguageHelper.getText(request, "menu.navigation")%></h6>
                        <a href="index.jsp#home" class="mobile-nav-item">
                            <i class="fas fa-home" aria-hidden="true"></i>
                            <%= LanguageHelper.getText(request, "nav.home")%>
                        </a>
                        <!-- Các link khác giữ nguyên -->
                        <a href="categories.jsp" class="mobile-nav-item">
                            <i class="fas fa-th-large" aria-hidden="true"></i>
                            <%= LanguageHelper.getText(request, "nav.explore")%>
                        </a>
                        <a href="contact.jsp" class="mobile-nav-item">
                            <i class="fas fa-envelope" aria-hidden="true"></i>
                            <%= LanguageHelper.getText(request, "nav.contact")%>
                        </a>
                    </nav>

                    <!-- Language Selector Mobile -->
                    <div class="mobile-language">
                        <span>
                            <i class="fas fa-globe" aria-hidden="true"></i> 
                            <%= LanguageHelper.getText(request, "menu.language")%>
                        </span>
                        <div class="language-toggle">
                            <a href="?lang=vi" class="<%= "vi".equals(currentLang) ? "active" : ""%>">VN</a>
                            <a href="?lang=en" class="<%= "en".equals(currentLang) ? "active" : ""%>">EN</a>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="Js/search.js"></script>
        <script src="Js/theme.js"></script>
    </body>
</html>