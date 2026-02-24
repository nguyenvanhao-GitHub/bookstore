package controller;

import dao.OrderDAO;
import dao.BookDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {
    private static final Pattern BOOK_PARSE_PATTERN = Pattern.compile("([^()]+)\\s*\\(x(\\d+)\\)");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("orderId");
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");

        if (orderId == null || userEmail == null) {
            setAlert(session, "error", "Lỗi", "Không thể thực hiện thao tác.");
            response.sendRedirect("orders.jsp"); 
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        BookDAO bookDAO = new BookDAO();
        boolean success = false;

        try {
            String currentStatus = orderDAO.getOrderStatus(orderId);

            if (!"pending".equalsIgnoreCase(currentStatus)) {
                setAlert(session, "error", "Không thể hủy", "Đơn hàng đã được xử lý hoặc đang giao.");
                response.sendRedirect("orders.jsp");
                return;
            }

            // Logic hoàn kho (Giữ nguyên)
            String booksSummary = orderDAO.getBooksSummary(orderId);
            Matcher matcher = BOOK_PARSE_PATTERN.matcher(booksSummary);
            boolean rollbackSuccess = true;
            while (matcher.find()) {
                String bookName = matcher.group(1).trim();
                int quantity = Integer.parseInt(matcher.group(2));
                int bookId = bookDAO.getBookIdByName(bookName);
                if (bookId != -1) {
                    if(!bookDAO.increaseStock(bookId, quantity)) rollbackSuccess = false;
                }
            }

            if (rollbackSuccess && orderDAO.updateOrderStatus(orderId, "cancelled")) {
                success = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (success) {
            setAlert(session, "success", "Thành công", "Đơn hàng đã được hủy.");
        } else {
            setAlert(session, "error", "Thất bại", "Có lỗi xảy ra khi hủy đơn hàng.");
        }
        
        // Kiểm tra xem người dùng là user hay admin để redirect đúng chỗ
        String role = (String) session.getAttribute("userRole");
        if("admin".equals(role)) {
            response.sendRedirect("admin/orders.jsp");
        } else {
            response.sendRedirect("orders.jsp");
        }
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}