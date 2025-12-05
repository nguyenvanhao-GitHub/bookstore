package controller;

import dao.OrderDAO;
import dao.BookDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Map;

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {

    // Regex để phân tích chuỗi "Book Name (xQuantity)"
    private static final Pattern BOOK_PARSE_PATTERN = Pattern.compile("([^()]+)\\s*\\(x(\\d+)\\)");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("orderId");
        String userEmail = (String) request.getSession().getAttribute("userEmail"); // Bảo mật

        if (orderId == null || userEmail == null) {
            response.sendRedirect("orders.jsp?cancelFail=1");
            return;
        }
        
        OrderDAO orderDAO = new OrderDAO();
        BookDAO bookDAO = new BookDAO();
        boolean success = false;
        boolean rollbackSuccessful = true;
        
        try {
            // 1. LẤY VÀ XÁC MINH TRẠNG THÁI
            String currentStatus = orderDAO.getOrderStatus(orderId); 

            if (!"pending".equalsIgnoreCase(currentStatus)) {
                // Lỗi logic: Đơn hàng đã xử lý, không được hủy.
                response.sendRedirect("orders.jsp?cancelFail=1");
                return;
            }

            String booksSummary = orderDAO.getBooksSummary(orderId);
            
            // 2. PHÂN TÍCH CHUỖI VÀ HOÀN KHO
            Matcher matcher = BOOK_PARSE_PATTERN.matcher(booksSummary);
            
            while (matcher.find()) {
                String bookName = matcher.group(1).trim();
                int quantity = Integer.parseInt(matcher.group(2));
                
                // Tra cứu Book ID (dựa trên hàm BookDAO.getBookIdByName)
                int bookId = bookDAO.getBookIdByName(bookName); 

                if (bookId != -1) {
                    if (!bookDAO.increaseStock(bookId, quantity)) {
                        rollbackSuccessful = false;
                        // Ghi log lỗi nghiêm trọng: Thao tác DB thất bại.
                    }
                } else {
                    rollbackSuccessful = false;
                    // Ghi log lỗi: Không tìm thấy ID sách để hoàn kho.
                }
            }

            // 3. CẬP NHẬT TRẠNG THÁI ĐƠN HÀNG (Chỉ khi hoàn kho thành công)
            if (rollbackSuccessful) {
                if (orderDAO.updateOrderStatus(orderId, "cancelled")) {
                    success = true;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            success = false;
        }

        // 4. CHUYỂN HƯỚNG
        if (success) {
            response.sendRedirect("orders.jsp?cancelSuccess=1");
        } else {
            response.sendRedirect("orders.jsp?cancelFail=1");
        }
    }
}