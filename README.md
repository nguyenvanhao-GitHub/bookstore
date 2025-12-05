# 📚 E-Books Digital Library

Nền tảng thương mại điện tử chuyên về sách kỹ thuật số, được xây dựng bằng **Java Servlet**, **JSP** và **MySQL**. Hệ thống cung cấp trải nghiệm toàn diện cho 3 nhóm người dùng: **Khách hàng**, **Nhà xuất bản** và **Quản trị viên**.

![Home Page](BookStore/web/images/screenshots/home.png)

## 🌟 Tính Năng Nổi Bật

### 👤 Khách Hàng (Customer)
- **Tìm kiếm & Duyệt sách:** Tìm theo tên, tác giả, danh mục với bộ lọc thông minh.
- **Giỏ hàng & Thanh toán:** - Thêm/sửa/xóa sản phẩm trong giỏ.
  - Thanh toán **COD** hoặc Online qua ví **VNPay**.
  - Nhận email xác nhận đơn hàng tự động.
- **Tài khoản:** - Đăng ký/Đăng nhập (có tính năng "Ghi nhớ đăng nhập").
  - Quản lý hồ sơ, đổi mật khẩu, xem lịch sử đơn hàng.
  - Wishlist (Danh sách yêu thích).
- **Tương tác:** Đánh giá & bình luận sách, gửi liên hệ hỗ trợ.
- **Đa ngôn ngữ:** Hỗ trợ Tiếng Việt & Tiếng Anh.

### 📝 Nhà Xuất Bản (Publisher)
- **Dashboard riêng:** Thống kê doanh thu, số sách bán ra (Biểu đồ trực quan).
- **Quản lý sách:** Đăng tải sách mới (kèm ảnh bìa, file PDF preview), chỉnh sửa thông tin, quản lý kho.
- **Quản lý danh mục:** Tạo và quản lý các danh mục sách.

### 🛡️ Quản Trị Viên (Admin)
- **Dashboard thống kê:** Tổng quan doanh thu, đơn hàng, người dùng mới (Chart.js).
- **Quản lý toàn hệ thống:**
  - Quản lý người dùng (Khóa/Mở khóa tài khoản, Tự động khóa user không hoạt động).
  - Quản lý đơn hàng (Xem chi tiết, cập nhật trạng thái, in hóa đơn).
  - Quản lý đánh giá & bình luận (Kiểm duyệt nội dung).
  - Quản lý Subscriber & gửi Newsletter hàng loạt.

## 🛠️ Công Nghệ Sử Dụng

| Lớp (Layer) | Công nghệ |
|-------------|-----------|
| **Frontend** | JSP, JSTL, HTML5, CSS3, Bootstrap 5, JavaScript (SweetAlert2, Chart.js) |
| **Backend** | Java Servlets, DAO Pattern, Session Management |
| **Database** | MySQL (JDBC) |  
| **Thanh toán**| Tích hợp cổng thanh toán **VNPay** (Sandbox) |
| **Tiện ích** | JavaMail (Gửi email), Gson (JSON API), Apache Commons |

## 🚀 Hướng Dẫn Cài Đặt

### 1. Yêu cầu hệ thống
- JDK 8 trở lên (Khuyên dùng JDK 17 hoặc 21).
- Apache Tomcat 9/10.
- MySQL Server.
- NetBeans IDE (hoặc IntelliJ IDEA/Eclipse).

### 2. Cài đặt Database
1. Mở MySQL Workbench hoặc phpMyAdmin.
2. Tạo database mới tên `bookstore`.
3. Import file SQL từ thư mục `Database(SQL)/bookstore.sql` (nếu có) hoặc chạy script tạo bảng.

### 3. Cấu hình Code
1. Mở file `src/java/context/DBContext.java`:
   - Cập nhật `DB_USER` và `DB_PASS` khớp với MySQL của bạn.
2. Mở file `src/java/utils/EmailUtils.java`:
   - Cập nhật `EMAIL` và `PASSWORD` (App Password) để tính năng gửi mail hoạt động.
3. Thêm các file `.jar` trong thư mục `JARS/` vào thư viện của dự án (Classpath).

### 4. Chạy Dự Án
1. Mở dự án trong NetBeans.
2. Clean & Build dự án.
3. Nhấn **Run** để deploy lên Tomcat.
4. Truy cập: `http://localhost:8080/BookStore`

## 📂 Cấu Trúc Dự Án
Bookstore-JspServlet/
│
├── JARS/                           # Thư viện phụ thuộc (External Libraries)
│   ├── commons-lang3-3.13.0.jar
│   ├── gson-2.10.1.jar
│   ├── jakarta.activation-2.0.1.jar
│   ├── jakarta.mail-2.0.1.jar
│   ├── jakarta.mail-api-2.0.1.jar
│   ├── json-20210307.jar
│   └── mysql-connector-j-9.1.0.jar
│
└── BookStore/                      # Thư mục chính của dự án (NetBeans Project)
    │
    ├── src/java/                   # Java Source Code (Backend)
    │   ├── config/                 # Cấu hình hệ thống (VNPayConfig...)
    │   ├── context/                # Kết nối Database (DBContext)
    │   ├── controller/             # Servlets xử lý logic (MVC Controllers)
    │   ├── dao/                    # Data Access Objects (Truy vấn DB)
    │   ├── entity/                 # Data Models (POJO Classes)
    │   ├── resources/              # File đa ngôn ngữ (messages_vi/en.properties)
    │   └── utils/                  # Tiện ích (Email, Password Hash, Language...)
    │
    ├── web/                        # Web Root (Frontend)
    │   │
    │   ├── admin/                  # Module dành cho Admin
    │   │   ├── css/                # CSS riêng cho trang Admin
    │   │   ├── js/                 # JS riêng cho trang Admin
    │   │   └── *.jsp               # Các trang giao diện Admin
    │   │
    │   ├── publisher/              # Module dành cho Nhà xuất bản
    │   │   ├── css/                # CSS riêng cho Publisher
    │   │   ├── js/                 # JS riêng cho Publisher
    │   │   └── *.jsp               # Các trang giao diện Publisher
    │   │
    │   ├── CSS/                    # CSS chung cho User (Customer)
    │   ├── Js/                     # JS chung cho User
    │   ├── images/                 # Hình ảnh (Sách, Banner, Avatar...)
    │   │
    │   ├── META-INF/               # Cấu hình Context (Database Resource)
    │   ├── WEB-INF/                # Cấu hình Web App
    │   │   └── web.xml             # Deployment Descriptor
    │   │
    │   └── *.jsp                   # Các trang công khai (Home, Login, Cart...)
    │
    ├── nbproject/                  # Cấu hình dự án của NetBeans
    └── build.xml                   # Ant Build Script

## 🤝 Đóng Góp
Mọi ý kiến đóng góp xin vui lòng gửi Pull Request hoặc tạo Issue trên GitHub.

---
© 2025 E-Books Library Project.