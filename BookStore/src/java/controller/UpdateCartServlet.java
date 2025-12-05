package controller;

import com.google.gson.Gson;
import dao.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Cấu hình phản hồi JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        Map<String, Object> jsonResponse = new HashMap<>();
        
        if (userEmail == null) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Vui lòng đăng nhập lại.");
            new Gson().toJson(jsonResponse, response.getWriter());
            return;
        }
        
        try {
            int bookId = Integer.parseInt(request.getParameter("cartItemId"));
            int newQuantity = Integer.parseInt(request.getParameter("quantity"));
            
            if (newQuantity < 1) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Số lượng không hợp lệ.");
            } else {
                CartDAO cartDAO = new CartDAO();
                String result = cartDAO.updateCartQuantity(bookId, userEmail, newQuantity);
                
                if ("SUCCESS".equals(result)) {
                    jsonResponse.put("status", "success");
                    jsonResponse.put("message", "Cập nhật thành công.");
                } else if ("OUT_OF_STOCK".equals(result)) {
                    jsonResponse.put("status", "warning");
                    jsonResponse.put("message", "Kho không đủ hàng!");
                } else {
                    jsonResponse.put("status", "error");
                    jsonResponse.put("message", "Lỗi cập nhật: " + result);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Lỗi hệ thống.");
        }
        
        new Gson().toJson(jsonResponse, response.getWriter());
    }
}