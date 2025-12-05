// File: src/java/controller/BookRecommendationServlet.java
package controller;

import com.google.gson.Gson;
import dao.BookDAO;
import entity.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/BookRecommendationServlet")
public class BookRecommendationServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String type = request.getParameter("type"); // category, author, user, popular, similar
        String value = request.getParameter("value");
        String bookIdStr = request.getParameter("bookId");
        
        HttpSession session = request.getSession(false);
        String userEmail = (session != null) ? (String) session.getAttribute("userEmail") : null;
        
        BookDAO dao = new BookDAO();
        List<Book> recommendations;
        int bookId = 0;
        
        try {
            if (bookIdStr != null && !bookIdStr.isEmpty()) {
                bookId = Integer.parseInt(bookIdStr);
            }
            
            // Điều hướng gọi hàm DAO dựa trên type
            if ("category".equals(type) && value != null) {
                recommendations = dao.getBooksByCategory(value, bookId);
            } else if ("author".equals(type) && value != null) {
                recommendations = dao.getBooksByAuthor(value, bookId);
            } else if ("user".equals(type) && userEmail != null) {
                recommendations = dao.getPersonalizedRecommendations(userEmail);
            } else if ("similar".equals(type) && bookId > 0) {
                recommendations = dao.getSimilarBooks(bookId);
            } else {
                // Mặc định hoặc type="popular"
                recommendations = dao.getPopularBooks();
            }
            
            // Trả về JSON
            response.setContentType("application/json;charset=UTF-8");
            response.setHeader("Cache-Control", "no-cache");
            
            Gson gson = new Gson();
            String json = gson.toJson(recommendations);
            response.getWriter().write(json);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}