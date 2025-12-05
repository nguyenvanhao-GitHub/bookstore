package controller;
import dao.SubscriberDAO;
import utils.EmailUtils;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/SubscribeServlet")
public class SubscribeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        SubscriberDAO dao = new SubscriberDAO();
        
        if (dao.addSubscriber(email)) {
            try {
                EmailUtils.send(email, "Đăng ký thành công!", "<h3>Cảm ơn bạn đã đăng ký E-Books!</h3>");
            } catch (Exception ignored) {}
            
            setAlert(req.getSession(), "success", "Đăng ký thành công", "Cảm ơn bạn!");
        } else {
            setAlert(req.getSession(), "error", "Lỗi", "Có thể email này đã đăng ký rồi.");
        }
        resp.sendRedirect("index.jsp");
    }
    private void setAlert(HttpSession s, String i, String t, String m) {
        s.setAttribute("alertIcon", i); s.setAttribute("alertTitle", t); s.setAttribute("alertMessage", m);
    }
}