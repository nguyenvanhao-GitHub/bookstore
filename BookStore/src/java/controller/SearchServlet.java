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

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String query = request.getParameter("query");

        if (query == null || query.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        try {
            BookDAO bookDAO = new BookDAO();
            List<Book> books = bookDAO.searchBooks(query.trim());

            Gson gson = new Gson();
            String json = gson.toJson(books);

            response.getWriter().write(json);

        } catch (Exception e) {
            e.printStackTrace();

            response.getWriter().write("[]");
        }
    }
}
