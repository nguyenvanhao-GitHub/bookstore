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

@WebServlet("/EditBookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 50,      // 50MB (Cho phép file PDF)
    maxRequestSize = 1024 * 1024 * 100   // 100MB
)
public class EditBookServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            int id = Integer.parseInt(request.getParameter("bookId"));
            String name = request.getParameter("bookName");
            String author = request.getParameter("bookAuthor");
            double price = Double.parseDouble(request.getParameter("bookPrice"));
            String category = request.getParameter("bookCategory");
            int stock = Integer.parseInt(request.getParameter("bookStock"));
            String description = request.getParameter("bookDescription");
            
            String appPath = request.getServletContext().getRealPath("");

            // 1. Xử lý upload Ảnh (Image)
            String dbImagePath = handleUpload(request.getPart("bookImage"), appPath, "images" + File.separator + "books");
            
            // 2. Xử lý upload PDF (Preview) - [MỚI]
            String dbPdfPath = handleUpload(request.getPart("bookPdf"), appPath, "books_preview");

            // 3. Tạo object Book
            Book book = new Book();
            book.setId(id);
            book.setName(name);
            book.setAuthor(author);
            book.setPrice(price);
            book.setCategory(category);
            book.setStock(stock);
            book.setDescription(description);
            
            // Nếu có upload mới thì set, không thì để null (DAO sẽ giữ nguyên giá trị cũ)
            if (dbImagePath != null) {
                // Chuyển về path chuẩn web (dùng dấu /)
                book.setImage("images/books/" + new File(dbImagePath).getName());
            }
            
            if (dbPdfPath != null) {
                // Chuyển về path chuẩn web
                book.setPdfPreviewPath("books_preview/" + new File(dbPdfPath).getName());
            }

            // Gọi DAO
            BookDAO dao = new BookDAO();
            boolean success = dao.updateBook(book);

            setAlert(request.getSession(), success ? "success" : "error", 
                     success ? "Thành công" : "Lỗi", 
                     success ? "Cập nhật sách thành công!" : "Không thể cập nhật sách.");

        } catch (Exception e) {
            e.printStackTrace();
            setAlert(request.getSession(), "error", "Lỗi hệ thống", e.getMessage());
        }
        response.sendRedirect("publisher/manage-books.jsp");
    }

    // Hàm tiện ích upload
    private String handleUpload(Part part, String appPath, String saveDir) throws IOException {
        if (part == null || part.getSize() == 0 || part.getSubmittedFileName().isEmpty()) return null;
        
        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        // Thêm timestamp để tránh trùng tên
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
        
        String fullSavePath = appPath + File.separator + saveDir;
        File fileDir = new File(fullSavePath);
        if (!fileDir.exists()) fileDir.mkdirs();
        
        String filePath = fullSavePath + File.separator + uniqueFileName;
        part.write(filePath);
        
        return filePath;
    }

    private void setAlert(HttpSession session, String icon, String title, String msg) {
        session.setAttribute("alertIcon", icon);
        session.setAttribute("alertTitle", title);
        session.setAttribute("alertMessage", msg);
    }
}