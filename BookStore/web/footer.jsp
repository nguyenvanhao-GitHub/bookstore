<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="utils.LanguageHelper" %>

<!-- Footer -->
<footer class="footer">
    <div class="container">
        <div class="row">
            <div class="col-lg-4 mb-4">
                <h3><%= LanguageHelper.getText(request, "footer.about.title") %></h3>
                <p><%= LanguageHelper.getText(request, "footer.about.desc") %></p>
            </div>
            <div class="col-lg-4 mb-4">
                <h3><%= LanguageHelper.getText(request, "footer.quicklinks") %></h3>
                <ul class="footer-links">
                    <li><a href="index.jsp"><%= LanguageHelper.getText(request, "footer.quicklinks.home") %></a></li>
                    <li><a href="categories.jsp"><%= LanguageHelper.getText(request, "footer.quicklinks.categories") %></a></li>
                    <li><a href="about.jsp"><%= LanguageHelper.getText(request, "footer.quicklinks.about") %></a></li>
                    <li><a href="contact.jsp"><%= LanguageHelper.getText(request, "footer.quicklinks.contact") %></a></li>
                    <li><a href="#"><%= LanguageHelper.getText(request, "footer.quicklinks.privacy") %></a></li>
                    <li><a href="#"><%= LanguageHelper.getText(request, "footer.quicklinks.terms") %></a></li> 
                </ul>
            </div>
            <div class="col-lg-4 mb-4">
                <h3><%= LanguageHelper.getText(request, "footer.connect") %></h3>
                <div class="social-links">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="vanhao2510"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-linkedin-in"></i></a>
                </div>
                <div class="mt-3">
                    <p><%= LanguageHelper.getText(request, "footer.newsletter") %></p>
                    <form class="subscribe-form" action="SubscribeServlet" method="post">
                        <div class="input-group">
                            <input type="email" name="email" class="form-control" 
                                placeholder="<%= LanguageHelper.getText(request, "footer.email.placeholder") %>" required>
                            <button class="btn btn-accent" type="submit">
                                <%= LanguageHelper.getText(request, "footer.subscribe") %>
                            </button>
                        </div>
                    </form>                    
                </div>
            </div>
        </div>
        <div class="text-center mt-4">
            <p><%= LanguageHelper.getText(request, "footer.copyright") %></p>
        </div>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="js/main.js"></script>
</body>
</html>