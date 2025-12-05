package controller;

import dao.SocialDAO;
import dao.BookDAO;
import entity.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/SocialShareServlet")
public class SocialShareServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String BASE_URL = "http://localhost:8080/BookStore";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String platform = request.getParameter("platform");
        String bookIdParam = request.getParameter("bookId");
        
        if ("track".equals(action) && platform != null && bookIdParam != null) {
            try {
                int bookId = Integer.parseInt(bookIdParam);
                SocialDAO socialDAO = new SocialDAO();
                socialDAO.trackShare(bookId, platform);
                
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else if ("getLinks".equals(action) && bookIdParam != null) {
            generateShareLinks(response, bookIdParam);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void generateShareLinks(HttpServletResponse response, String bookIdParam) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            int bookId = Integer.parseInt(bookIdParam);
            BookDAO bookDAO = new BookDAO();
            Book book = bookDAO.getBookById(bookId);

            if (book != null) {
                String bookName = book.getName();
                String author = book.getAuthor();
                String bookUrl = BASE_URL + "/book-detail.jsp?id=" + bookId;
                
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"success\":true,");
                json.append("\"bookName\":\"").append(escapeJson(bookName)).append("\",");
                json.append("\"bookUrl\":\"").append(bookUrl).append("\",");
                // ... (Logic tạo link social media giữ nguyên như cũ, chỉ thay thế data bằng book.get...)
                json.append("\"facebook\":\"https://www.facebook.com/sharer/sharer.php?u=").append(URLEncoder.encode(bookUrl, StandardCharsets.UTF_8)).append("\"");
                json.append("}");
                
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"success\":false, \"error\":\"Book not found\"}");
            }
        } catch (Exception e) {
            response.getWriter().write("{\"success\":false, \"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\"", "\\\"").replace("\n", " ");
    }
}