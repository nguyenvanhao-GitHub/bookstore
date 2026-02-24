package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/UpdateOrderStatusServlet")
public class UpdateOrderStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("status");

        OrderDAO dao = new OrderDAO();

        String currentStatus = dao.getOrderStatus(orderId);

        if (currentStatus == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn hàng.");
            return;
        }

        currentStatus = currentStatus.toLowerCase();
        newStatus = newStatus.toLowerCase();

        if ("delivered".equals(currentStatus) || "cancelled".equals(currentStatus)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Đơn hàng đã kết thúc (Giao xong/Hủy), không thể chỉnh sửa!");
            return;
        }

        if ("shipping".equals(currentStatus) && "pending".equals(newStatus)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Đơn đang giao không thể quay lại trạng thái Chờ xử lý.");
            return;
        }

        if ("shipping".equals(currentStatus) && "cancelled".equals(newStatus)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Đơn đang giao. Vui lòng liên hệ vận chuyển để hoàn hàng trước khi Hủy.");
            return;
        }

        boolean isUpdated = dao.updateOrderStatus(orderId, newStatus);

        if (isUpdated) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi Database: Không thể cập nhật.");
        }
    }
}
