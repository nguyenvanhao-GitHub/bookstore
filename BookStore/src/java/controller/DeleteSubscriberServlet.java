package controller;

import dao.SubscriberDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteSubscriberServlet")
public class DeleteSubscriberServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                new SubscriberDAO().deleteSubscriber(id);
            } catch (Exception e) { e.printStackTrace(); }
        }
        response.sendRedirect("admin/subscriber.jsp");
    }
}