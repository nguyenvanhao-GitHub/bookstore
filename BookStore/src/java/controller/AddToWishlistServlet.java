package controller;

import dao.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/AddToWishlistServlet")
public class AddToWishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        
        // Lấy userId từ Session (Giả sử bạn lưu userId là Integer)
        // Nếu bạn lưu User object thì: User user = (User) session.getAttribute("user"); int userId = user.getId();
        Object userIdObj = request.getSession().getAttribute("userId");
        
        if (userIdObj == null) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để sử dụng tính năng này.\"}");
            return;
        }
        
        int userId = (Integer) userIdObj;
        String bookIdParam = request.getParameter("bookId");
        
        try {
            int bookId = Integer.parseInt(bookIdParam);
            WishlistDAO dao = new WishlistDAO();
            String result = dao.addToWishlist(userId, bookId);
            
            if ("SUCCESS".equals(result)) {
                response.getWriter().write("{\"status\":\"success\",\"message\":\"Đã thêm vào danh sách yêu thích!\"}");
            } else if ("EXISTS".equals(result)) {
                response.getWriter().write("{\"status\":\"info\",\"message\":\"Sách này đã có trong danh sách yêu thích.\"}");
            } else {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống, vui lòng thử lại.\"}");
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Dữ liệu sách không hợp lệ.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống.\"}");
        }
    }
}