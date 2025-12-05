package controller;

import dao.BookDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteBookServlet")
public class DeleteBookServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            BookDAO dao = new BookDAO();
            boolean success = dao.deleteBook(id);
            
            setAlert(request.getSession(), success ? "success" : "error", 
                     success ? "Đã xóa!" : "Lỗi", 
                     success ? "Sách đã được xóa." : "Không thể xóa sách.");
        } catch (Exception e) {
            setAlert(request.getSession(), "error", "Lỗi", "ID sách không hợp lệ.");
        }
        response.sendRedirect("publisher/manage-books.jsp");
    }
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}