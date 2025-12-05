package controller;

import com.google.gson.Gson;
import dao.BookDAO;
import entity.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Cấu hình response header để trả về JSON UTF-8
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 2. Lấy từ khóa tìm kiếm
        String query = request.getParameter("query");
        
        // 3. Xử lý trường hợp query rỗng
        if (query == null || query.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }
        
        try {
            // 4. Gọi DAO để tìm kiếm
            BookDAO bookDAO = new BookDAO();
            List<Book> books = bookDAO.searchBooks(query.trim());
            
            // 5. Chuyển đổi List<Book> sang JSON string dùng Gson
            Gson gson = new Gson();
            String json = gson.toJson(books);
            
            // 6. Trả kết quả về client
            response.getWriter().write(json);
            
        } catch (Exception e) {
            e.printStackTrace();
            // Trả về mảng rỗng nếu có lỗi để frontend không bị treo
            response.getWriter().write("[]");
        }
    }
}