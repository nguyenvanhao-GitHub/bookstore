<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ page import="utils.LanguageHelper" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= LanguageHelper.getText(request, "error.title") %> - BookStore</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/CSS/style.css">
</head>
<body>
    <div class="container">
        <div class="error-container">
            <h1><%= LanguageHelper.getText(request, "error.heading") %></h1>
            <p><%= LanguageHelper.getText(request, "error.message") %></p>
            <% if (response.getStatus() == 404) { %>
                <p><%= LanguageHelper.getText(request, "error.404") %></p>
            <% } else { %>
                <p><%= LanguageHelper.getText(request, "error.general") %></p>
            <% } %>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn">
                <%= LanguageHelper.getText(request, "error.back.home") %>
            </a>
        </div>
    </div>
</body>
</html>