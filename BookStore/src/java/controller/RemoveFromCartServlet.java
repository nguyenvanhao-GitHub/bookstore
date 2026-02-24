package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import dao.CartDAO;

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        
        if (userEmail == null) { 
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return; 
        }

        try {
            int bookId = Integer.parseInt(req.getParameter("cartItemId"));
            
            if (new CartDAO().removeFromCart(bookId, userEmail)) {
                setAlert(session, "success", "Đã xóa", "Sản phẩm đã được xóa khỏi giỏ hàng.");
            } else {
                setAlert(session, "error", "Lỗi", "Không thể xóa sản phẩm này.");
            }
            
            resp.setStatus(HttpServletResponse.SC_OK);
            
        } catch (NumberFormatException e) { 
            setAlert(session, "error", "Lỗi", "Dữ liệu không hợp lệ."); 
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void setAlert(HttpSession s, String i, String t, String m) {
        s.setAttribute("alertIcon", i); 
        s.setAttribute("alertTitle", t); 
        s.setAttribute("alertMessage", m);
    }
}