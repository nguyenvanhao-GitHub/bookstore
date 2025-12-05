package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteCategoryServlet")
public class DeleteCategoryServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy tham số
        String categoryIdStr = request.getParameter("categoryId");
        HttpSession session = request.getSession();

        try {
            // 2. Validate và chuyển đổi dữ liệu
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                int id = Integer.parseInt(categoryIdStr);
                
                // 3. Gọi DAO
                CategoryDAO dao = new CategoryDAO();
                boolean success = dao.deleteCategory(id);
                
                // 4. Phản hồi kết quả qua Session (để JSP hiển thị Alert)
                if (success) {
                    setAlert(session, "success", "Thành công", "Đã xóa danh mục!");
                } else {
                    setAlert(session, "error", "Thất bại", "Không thể xóa danh mục này (có thể do lỗi DB).");
                }
            } else {
                setAlert(session, "error", "Lỗi", "ID danh mục không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            setAlert(session, "error", "Lỗi", "Định dạng ID không đúng.");
        } catch (Exception e) {
            e.printStackTrace();
            setAlert(session, "error", "Lỗi hệ thống", e.getMessage());
        }

        // 5. Điều hướng
        response.sendRedirect("publisher/manage-categories.jsp");
    }

    // Helper set thông báo cho Session
    private void setAlert(HttpSession session, String icon, String title, String message) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", message);
    }
}