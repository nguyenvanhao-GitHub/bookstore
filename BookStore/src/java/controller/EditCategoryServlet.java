package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/EditCategoryServlet")
public class EditCategoryServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("categoryId"));
            String name = request.getParameter("categoryName");
            String desc = request.getParameter("categoryDescription");

            CategoryDAO dao = new CategoryDAO();
            boolean success = dao.updateCategory(id, name, desc);

            setAlert(request.getSession(), success ? "success" : "error", 
                     success ? "Thành công" : "Lỗi", 
                     success ? "Cập nhật danh mục thành công!" : "Thất bại.");
            
        } catch (Exception e) {
            setAlert(request.getSession(), "error", "Lỗi", "Dữ liệu không hợp lệ.");
        }
        response.sendRedirect("publisher/manage-categories.jsp");
    }
    
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}