package controller;

import dao.BookDAO;
import entity.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.*;

@WebServlet("/AddBookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 50,      // 50MB (Cho phép file PDF lớn)
    maxRequestSize = 1024 * 1024 * 100   // 100MB
)
public class AddBookServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        try {
            String appPath = request.getServletContext().getRealPath("");
            
            // 1. Xử lý Ảnh (Image)
            String imagePath = handleUpload(request.getPart("bookImage"), appPath, "images" + File.separator + "books");
            
            // 2. Xử lý PDF (Preview) - [MỚI]
            String pdfPath = handleUpload(request.getPart("bookPdf"), appPath, "books_preview");

            // 3. Lấy dữ liệu form
            String name = request.getParameter("bookName");
            String author = request.getParameter("bookAuthor");
            double price = Double.parseDouble(request.getParameter("bookPrice"));
            int stock = Integer.parseInt(request.getParameter("bookStock"));
            String description = request.getParameter("bookDescription");
            String publisherEmail = request.getParameter("publisherEmail");
            String category = request.getParameter("bookCategory");

            // 4. Tạo Object và lưu
            // Lưu path vào DB dạng relative: "images/books/abc.jpg"
            String dbImagePath = (imagePath != null) ? "images/books/" + new File(imagePath).getName() : null;
            String dbPdfPath = (pdfPath != null) ? "books_preview/" + new File(pdfPath).getName() : null;

            Book newBook = new Book(name, author, price, stock, description, publisherEmail, category, dbImagePath, dbPdfPath);
            
            if (new BookDAO().addBook(newBook)) {
                setAlert(request.getSession(), "success", "Thành công", "Đã thêm sách mới!");
            } else {
                setAlert(request.getSession(), "error", "Lỗi", "Lỗi cơ sở dữ liệu.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            setAlert(request.getSession(), "error", "Lỗi hệ thống", e.getMessage());
        }
        response.sendRedirect("publisher/manage-books.jsp");
    }

    // Hàm tiện ích upload file
    private String handleUpload(Part part, String appPath, String saveDir) throws IOException {
        if (part == null || part.getSize() == 0 || part.getSubmittedFileName().isEmpty()) return null;
        
        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        // Tránh trùng tên file
        fileName = System.currentTimeMillis() + "_" + fileName;
        
        String fullSavePath = appPath + File.separator + saveDir;
        File fileDir = new File(fullSavePath);
        if (!fileDir.exists()) fileDir.mkdirs();
        
        String filePath = fullSavePath + File.separator + fileName;
        part.write(filePath);
        return filePath;
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}