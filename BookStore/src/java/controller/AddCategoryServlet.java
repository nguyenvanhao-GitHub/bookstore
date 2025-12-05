package controller;

import dao.CategoryDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/AddCategoryServlet")
public class AddCategoryServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("categoryName");
        String desc = request.getParameter("categoryDescription");
        
        HttpSession session = request.getSession();
        
        if (name == null || desc == null) {
            setAlert(session, "error", "Lỗi", "Vui lòng nhập đủ thông tin");
        } else {
            CategoryDAO dao = new CategoryDAO();
            if (dao.addCategory(name, desc)) {
                setAlert(session, "success", "Thành công", "Đã thêm danh mục mới");
            } else {
                setAlert(session, "error", "Lỗi", "Không thể thêm danh mục");
            }
        }
        response.sendRedirect("publisher/manage-categories.jsp");
    }
    
    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}