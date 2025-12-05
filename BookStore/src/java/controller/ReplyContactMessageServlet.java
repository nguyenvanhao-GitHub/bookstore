package controller;

import utils.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/ReplyContactMessageServlet")
public class ReplyContactMessageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String to = request.getParameter("recipients");
        String subject = request.getParameter("subject");
        String messageContent = request.getParameter("message");

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            EmailUtils.send(to, subject, messageContent);
            showAlert(out, "success", "Đã gửi phản hồi!", "Email đã được gửi thành công.", "admin/contact.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            showAlert(out, "error", "Lỗi gửi mail", e.getMessage(), "admin/contact.jsp");
        }
    }

    private void showAlert(PrintWriter out, String icon, String title, String text, String url) {
        out.println("<!DOCTYPE html><html><head><script src='https://cdn.jsdelivr.net/npm/sweetalert2@11'></script></head><body>");
        out.println("<script>");
        out.println("Swal.fire({icon:'" + icon + "', title:'" + title + "', text:'" + text + "'})");
        out.println(".then(() => { window.location='" + url + "'; });");
        out.println("</script></body></html>");
    }
}