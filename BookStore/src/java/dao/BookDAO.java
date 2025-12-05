package dao;

import context.DBContext;
import entity.Book;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    DBContext db = new DBContext();

    // 1. Chức năng Thêm sách (Từ AddBookServlet)
    public boolean addBook(Book book) {
        String sql = "INSERT INTO books (image, name, author, price, stock, description, publisher_email, category, pdf_preview_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, book.getImage());
            ps.setString(2, book.getName());
            ps.setString(3, book.getAuthor());
            ps.setDouble(4, book.getPrice());
            ps.setInt(5, book.getStock());
            ps.setString(6, book.getDescription());
            ps.setString(7, book.getPublisherEmail());
            ps.setString(8, book.getCategory());
            ps.setString(9, book.getPdfPreviewPath()); // [MỚI]

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Book> getBooksByPublisher(String email, int start, int total) {
        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm LIMIT ?, ? cho phân trang
        String sql = "SELECT * FROM books WHERE publisher_email = ? ORDER BY id DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, start);
            ps.setInt(3, total);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // Giả định hàm mapResultSetToBook(rs) tồn tại và hoạt động đúng
                list.add(mapResultSetToBook(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy sách theo Category (Từ BookRecommendationServlet)
    public List<Book> getBooksByCategory(String category, int excludeBookId) {
        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm pdf_preview_path
        String sql = "SELECT id, name, author, price, category, image, pdf_preview_path FROM books WHERE category = ? AND id != ? ORDER BY RAND() LIMIT 6";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setInt(2, excludeBookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBookBasic(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Book> getBooksByCategoryName(String categoryName) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE category = ? ORDER BY name LIMIT 12";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, categoryName);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Book b = new Book();
                b.setId(rs.getInt("id"));
                b.setName(rs.getString("name"));
                b.setAuthor(rs.getString("author"));
                b.setPrice(rs.getDouble("price"));
                b.setImage(rs.getString("image"));
                b.setPublisherEmail(rs.getString("publisher_email"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Lấy sách theo Author (Từ BookRecommendationServlet)
    public List<Book> getBooksByAuthor(String author, int excludeBookId) {
        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm pdf_preview_path
        String sql = "SELECT id, name, author, price, category, image, pdf_preview_path FROM books WHERE author = ? AND id != ? ORDER BY RAND() LIMIT 6";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, author);
            ps.setInt(2, excludeBookId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBookBasic(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Lấy sách phổ biến (Từ BookRecommendationServlet)
    public List<Book> getPopularBooks() {
        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm b.pdf_preview_path
        String sql = "SELECT b.id, b.name, b.author, b.price, b.category, b.image, b.pdf_preview_path, COUNT(c.book_id) as order_count " // Sửa c.id -> c.book_id nếu cần, hoặc giữ nguyên tùy DB
                + "FROM books b LEFT JOIN cart c ON b.id = c.book_id "
                + "GROUP BY b.id ORDER BY order_count DESC, RAND() LIMIT 6";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToBookBasic(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Gợi ý cá nhân hóa (Logic phức tạp từ BookRecommendationServlet)
    public List<Book> getPersonalizedRecommendations(String userEmail) {
        List<Book> list = new ArrayList<>();
        try (Connection conn = db.getConnection()) {
            // B1: Tìm các category user hay mua nhất
            String catSql = "SELECT b.category, COUNT(*) as count FROM orders o "
                    + "JOIN cart c ON o.email = c.user_email JOIN books b ON c.book_id = b.id "
                    + "WHERE o.email = ? GROUP BY b.category ORDER BY count DESC LIMIT 3";

            List<String> favCategories = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(catSql)) {
                ps.setString(1, userEmail);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    favCategories.add(rs.getString("category"));
                }
            }

            if (favCategories.isEmpty()) {
                return getPopularBooks();
            }

            // B2: Lấy sách thuộc category đó nhưng chưa mua
            StringBuilder sql = new StringBuilder("SELECT DISTINCT b.id, b.name, b.author, b.price, b.category, b.image FROM books b WHERE b.category IN (");
            for (int i = 0; i < favCategories.size(); i++) {
                sql.append(i == 0 ? "?" : ",?");
            }
            sql.append(") AND b.id NOT IN (SELECT DISTINCT c.book_id FROM cart c JOIN orders o ON c.user_email = o.email WHERE o.email = ?) ORDER BY RAND() LIMIT 6");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int index = 1;
                for (String cat : favCategories) {
                    ps.setString(index++, cat);
                }
                ps.setString(index, userEmail);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    list.add(mapResultSetToBookBasic(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Lấy sách tương tự (Logic phức tạp từ BookRecommendationServlet)
    public List<Book> getSimilarBooks(int bookId) {
        Book currentBook = getBookById(bookId);
        if (currentBook == null) {
            return getPopularBooks();
        }

        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm pdf_preview_path
        String sql = "SELECT id, name, author, price, category, image, pdf_preview_path FROM books "
                + "WHERE (category = ? OR author = ?) AND id != ? "
                + "ORDER BY CASE WHEN category = ? AND author = ? THEN 1 WHEN category = ? THEN 2 ELSE 3 END, RAND() LIMIT 6";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String cat = currentBook.getCategory();
            String auth = currentBook.getAuthor();
            ps.setString(1, cat);
            ps.setString(2, auth);
            ps.setInt(3, bookId);
            ps.setString(4, cat);
            ps.setString(5, auth);
            ps.setString(6, cat);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBookBasic(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Helper: Lấy thông tin cơ bản 1 sách
    // Thêm vào trong class BookDAO
    public Book getBookById(int id) {
        String sql = "SELECT * FROM books WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToBook(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Helper: Map ResultSet to Object để tránh lặp code
    // Helper: Map ResultSet to Object cơ bản (Thêm pdf_preview_path)
    private Book mapResultSetToBookBasic(ResultSet rs) throws SQLException {
        return new Book(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("author"),
                rs.getDouble("price"),
                rs.getString("category"),
                rs.getString("image"),
                rs.getString("pdf_preview_path") // [MỚI] Thêm trường này
        );
    }

    public boolean updateBook(Book book) {
        boolean hasImage = book.getImage() != null && !book.getImage().isEmpty();
        boolean hasPdf = book.getPdfPreviewPath() != null && !book.getPdfPreviewPath().isEmpty();

        StringBuilder sql = new StringBuilder("UPDATE books SET name=?, author=?, price=?, category=?, stock=?, description=?");
        if (hasImage) {
            sql.append(", image=?");
        }
        if (hasPdf) {
            sql.append(", pdf_preview_path=?");
        }
        sql.append(" WHERE id=?");

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            ps.setString(index++, book.getName());
            ps.setString(index++, book.getAuthor());
            ps.setDouble(index++, book.getPrice());
            ps.setString(index++, book.getCategory());
            ps.setInt(index++, book.getStock());
            ps.setString(index++, book.getDescription());

            if (hasImage) {
                ps.setString(index++, book.getImage());
            }
            if (hasPdf) {
                ps.setString(index++, book.getPdfPreviewPath());
            }

            ps.setInt(index++, book.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteBook(int id) {
        String sql = "DELETE FROM books WHERE id=?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Book> searchBooks(String query) {
        List<Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm pdf_preview_path
        String sql = "SELECT id, name, author, price, image, category, pdf_preview_path FROM books "
                + "WHERE LOWER(name) LIKE ? OR LOWER(author) LIKE ? OR LOWER(category) LIKE ? "
                + "ORDER BY CASE WHEN LOWER(name) LIKE ? THEN 1 WHEN LOWER(author) LIKE ? THEN 2 ELSE 3 END, name ASC LIMIT 12";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + query.toLowerCase() + "%";
            String exact = query.toLowerCase() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, exact);
            ps.setString(5, exact);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBookBasic(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Book> getFeaturedBooks() {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT * FROM books LIMIT 20";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToBook(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách sách trong Wishlist của user Dùng cho: wishlist.jsp
     */
    public List<Book> getWishlistBooks(int userId) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT b.* FROM wishlist w JOIN books b ON w.book_id = b.id WHERE w.user_id = ? ORDER BY w.id DESC"; // Sắp xếp theo lúc thêm
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBook(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Helper để map dữ liệu gọn hơn
    private Book mapResultSetToBook(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getInt("id"));
        b.setName(rs.getString("name"));
        b.setAuthor(rs.getString("author"));
        b.setPrice(rs.getDouble("price"));
        b.setImage(rs.getString("image"));
        b.setCategory(rs.getString("category"));
        b.setStock(rs.getInt("stock"));
        b.setDescription(rs.getString("description"));
        b.setPublisherEmail(rs.getString("publisher_email"));
        b.setPdfPreviewPath(rs.getString("pdf_preview_path"));
        try {
            b.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
        }
        return b;
    }
    
    // File: java/dao/BookDAO.java

    // 1. Đếm tổng số sách trong 1 danh mục (để tính số trang)
    public int countBooksByCategory(String category) {
        String sql = "SELECT COUNT(*) FROM books WHERE category = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 2. Lấy sách theo danh mục có phân trang (LIMIT, OFFSET)
    public List<Book> getBooksByCategoryPaginated(String category, int start, int total) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE category = ? ORDER BY id DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setInt(2, start);
            ps.setInt(3, total);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToBook(rs)); // Sử dụng hàm map đã có
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //hàm lấy danh sách sách có phân trang cho Admin
    public List<entity.Book> getAllBooks(int start, int total) {
        List<entity.Book> list = new ArrayList<>();
        // [CẬP NHẬT SQL] Thêm pdf_preview_path vào câu SELECT
        String sql = "SELECT id, name, author, price, stock, category, image, pdf_preview_path FROM books ORDER BY id DESC LIMIT ?, ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, start);
            ps.setInt(2, total);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                entity.Book b = new entity.Book();
                b.setId(rs.getInt("id"));
                b.setName(rs.getString("name"));
                b.setAuthor(rs.getString("author"));
                b.setPrice(rs.getDouble("price"));
                b.setStock(rs.getInt("stock"));
                b.setCategory(rs.getString("category"));
                b.setImage(rs.getString("image"));
                b.setPdfPreviewPath(rs.getString("pdf_preview_path")); // [BỔ SUNG]
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm tổng số sách
    public int countBooks() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM books")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Đếm sách thêm hôm nay
    public int countBooksAddedToday() {
        try (Connection conn = db.getConnection(); ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM books WHERE DATE(created_at) = CURDATE()")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Thêm vào class BookDAO
    // Lấy danh sách sách của một Publisher cụ thể
    public List<Book> getBooksByPublisher(String email) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE publisher_email = ? ORDER BY id DESC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // Sử dụng hàm map đã có hoặc tạo mới object
                Book b = new Book();
                b.setId(rs.getInt("id"));
                b.setImage(rs.getString("image"));
                b.setName(rs.getString("name"));
                b.setAuthor(rs.getString("author"));
                b.setPrice(rs.getDouble("price"));
                b.setCategory(rs.getString("category"));
                b.setStock(rs.getInt("stock"));
                b.setDescription(rs.getString("description"));
                b.setPdfPreviewPath(rs.getString("pdf_preview_path")); // Nếu có
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số sách của Publisher
    public int countBooksByPublisher(String email) {
        String sql = "SELECT COUNT(*) FROM books WHERE publisher_email = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy sách mới thêm trong 24h của Publisher (cho Dashboard)
    public List<Book> getRecentBooksByPublisher(String email) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE publisher_email = ? AND created_at >= NOW() - INTERVAL 1 DAY";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Book b = new Book();
                b.setId(rs.getInt("id"));
                b.setImage(rs.getString("image"));
                b.setName(rs.getString("name"));
                b.setAuthor(rs.getString("author"));
                b.setPrice(rs.getDouble("price"));
                b.setCategory(rs.getString("category"));
                b.setStock(rs.getInt("stock"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean increaseStock(int bookId, int quantity) {
        String sql = "UPDATE books SET stock = stock + ? WHERE id = ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, bookId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getBookIdByName(String bookName) {
        // Chỉ trả về ID của sách đầu tiên khớp tên
        String sql = "SELECT id FROM books WHERE name LIKE ?";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            // Sử dụng LIKE để tìm kiếm linh hoạt hơn
            ps.setString(1, "%" + bookName.trim() + "%");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1; // Trả về -1 nếu không tìm thấy
    }

    // Thêm vào class BookDAO.java
    /**
     * Lấy danh sách sách nổi bật có phân trang
     *
     * @param page Trang hiện tại (bắt đầu từ 1)
     * @param pageSize Số sách trên mỗi trang
     * @return Danh sách sách
     */
    public List<Book> getFeaturedBooks(int page, int pageSize) throws ClassNotFoundException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE stock > 0 ORDER BY id DESC LIMIT ? OFFSET ?";

        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int offset = (page - 1) * pageSize;
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Book book = new Book();
                book.setId(rs.getInt("id"));
                book.setName(rs.getString("name"));
                book.setAuthor(rs.getString("author"));
                book.setCategory(rs.getString("category"));
                book.setPrice(rs.getDouble("price"));
                book.setImage(rs.getString("image"));
                book.setStock(rs.getInt("stock"));
                book.setDescription(rs.getString("description"));
                book.setPublisherEmail(rs.getString("publisher_email"));
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }

    /**
     * Đếm tổng số sách có sẵn
     *
     * @return Tổng số sách
     */
    public int getTotalFeaturedBooks() throws ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM books WHERE stock > 0";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
