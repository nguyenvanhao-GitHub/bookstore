package controller;

import com.google.gson.Gson;
import dao.CartDAO;
import entity.CartItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/AddToCart")
public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        Map<String, Object> jsonResponse = new HashMap<>();

        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail == null || userEmail.trim().isEmpty()) {
            jsonResponse.put("status", "warning");
            jsonResponse.put("title", "Yêu cầu đăng nhập");
            jsonResponse.put("message", "Vui lòng đăng nhập để mua hàng.");
            jsonResponse.put("redirect", "login.jsp");
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }

        String bookIdStr = request.getParameter("bookId");
        String bookName = request.getParameter("bookName");
        String author = request.getParameter("author");
        String publisherEmail = request.getParameter("publisherEmail");
        String priceStr = request.getParameter("price");
        String image = request.getParameter("image");

        try {
            int bookId = Integer.parseInt(bookIdStr);
            double price = Double.parseDouble(priceStr);
            int quantityToAdd = 1;

            CartItem item = new CartItem(bookId, bookName, author, price, image, quantityToAdd);
            item.setUserEmail(userEmail);
            item.setPublisherEmail(publisherEmail);

            CartDAO cartDAO = new CartDAO();
            String result = cartDAO.addToCart(item);

            if ("SUCCESS".equals(result)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("title", "Đã thêm vào giỏ!");
                jsonResponse.put("message", bookName + " đã được thêm vào giỏ hàng.");
                jsonResponse.put("imageUrl", image);
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("title", "Lỗi");
                jsonResponse.put("message", result);
            }

        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("title", "Lỗi hệ thống");
            jsonResponse.put("message", e.getMessage());
        }

        // Trả về JSON
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}
