package controller;

import dao.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/RemoveFromWishlistServlet")
public class RemoveFromWishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        Object userIdObj = request.getSession().getAttribute("userId");

        if (userIdObj == null) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập.\"}");
            return;
        }

        try {
            int userId = (Integer) userIdObj;
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            
            WishlistDAO dao = new WishlistDAO();
            if (dao.removeFromWishlist(userId, bookId)) {
                response.getWriter().write("{\"status\":\"success\",\"message\":\"Đã xóa khỏi danh sách yêu thích!\"}");
            } else {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Không thể xóa hoặc sách không tồn tại.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi dữ liệu.\"}");
        }
    }
}