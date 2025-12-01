<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="utils.LanguageHelper" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="<%= LanguageHelper.getCurrentLanguage(request) %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= LanguageHelper.getText(request, "help.title") %> - BookStore</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        h1 {
            font-size: 2rem;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        h1 i { color: #667eea; }
        .faq-item {
            margin-bottom: 20px;
        }
        .faq-item h3 {
            font-size: 1.1rem;
            color: #444;
            cursor: pointer;
            background: #f0f0f0;
            padding: 12px 15px;
            border-radius: 8px;
            transition: background 0.3s;
        }
        .faq-item h3:hover { background: #e0e0e0; }
        .faq-item p {
            margin: 10px 15px;
            color: #555;
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><i class="fas fa-question-circle"></i> <%= LanguageHelper.getText(request, "help.heading") %></h1>
        
        <div class="faq-item">
            <h3><%= LanguageHelper.getText(request, "help.faq.cart.question") %></h3>
            <p><%= LanguageHelper.getText(request, "help.faq.cart.answer") %></p>
        </div>
        
        <div class="faq-item">
            <h3><%= LanguageHelper.getText(request, "help.faq.payment.question") %></h3>
            <p><%= LanguageHelper.getText(request, "help.faq.payment.answer") %></p>
        </div>
        
        <div class="faq-item">
            <h3><%= LanguageHelper.getText(request, "help.faq.support.question") %></h3>
            <p><%= LanguageHelper.getText(request, "help.faq.support.answer") %></p>
        </div>
    </div>
    <script>
        document.querySelectorAll('.faq-item h3').forEach(header => {
            header.addEventListener('click', () => {
                const p = header.nextElementSibling;
                p.style.display = (p.style.display === 'block') ? 'none' : 'block';
            });
        });
    </script>
</body>
</html>