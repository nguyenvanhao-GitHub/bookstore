package controller;

import dao.ContactDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteContactMessageServlet")
public class DeleteContactMessageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                new ContactDAO().deleteMessage(id);
            } catch (Exception e) { e.printStackTrace(); }
        }
        response.sendRedirect("admin/contact.jsp");
    }
}