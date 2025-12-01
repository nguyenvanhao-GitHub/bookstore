
# MVC REFACTORING MAPPING GUIDE

## 1. UTILITY & CONFIG CLASSES (→ src/java/services)
Location: src/java/utils/ & src/java/config/

### Utilities (Helpers & Shared Logic):
- utils/RememberMeUtil.java          → services/RememberMeService.java (+ AuthService)
- utils/LanguageHelper.java          → services/LanguageService.java
- config/VNPayConfig.java             → services/PaymentConfigService.java

---

## 2. DATABASE ACCESS LAYER (→ src/java/dao)
Create generic DAOs for each table entity:

### Entity DAOs to Create:
- UserDAO.java                  (SELECT, INSERT, UPDATE, DELETE on user table)
- PublisherDAO.java             (SELECT, INSERT, UPDATE, DELETE on publisher table)
- BookDAO.java                  (SELECT, INSERT, UPDATE, DELETE on books table)
- CartDAO.java                  (SELECT, INSERT, UPDATE, DELETE on cart table)
- OrderDAO.java                 (SELECT, INSERT, UPDATE, DELETE on orders table)
- WishlistDAO.java              (SELECT, INSERT, UPDATE, DELETE on wishlist table)
- CategoryDAO.java              (SELECT, INSERT, UPDATE, DELETE on category table)
- ReviewDAO.java                (SELECT, INSERT, UPDATE, DELETE on reviews table)
- NotificationDAO.java          (SELECT, INSERT, UPDATE, DELETE on notifications table)

### Pattern:
Each DAO should:
1. Have a private static DB connection config (URL, USER, PASS).
2. Provide CRUD methods (create, read, update, delete, list).
3. Be instantiated by services/controllers as needed.
4. Handle prepared statements and resource cleanup.

---

## 3. MODEL CLASSES (→ src/java/models)
Create entity POJOs to represent database records:

### Models to Create:
- User.java                     (id, name, email, contact, gender, salt, role, status, etc.)
- Publisher.java                (id, name, email, contact, gender, role, etc.)
- Book.java                     (id, name, author, price, stock, category, image, etc.)
- Cart.java                     (book_id, user_email, bookname, quantity, price, etc.)
- Order.java                    (id, user_email, total_price, status, created_at, etc.)
- Wishlist.java                 (user_id, book_id, created_at)
- Category.java                 (id, name, description)
- Review.java                   (id, user_id, book_id, rating, comment, created_at, etc.)
- Notification.java             (id, user_id, message, type, created_at, etc.)

### Pattern for Models:
1. Private fields matching database columns.
2. Getter/setter methods for all fields.
3. No-arg constructor.
4. Optional: toString(), equals(), hashCode().

---

## 4. SERVICE LAYER REFACTORING (→ src/java/services)
Merge servlet logic (from controllers) into service classes:

### Services to Create:
- AuthService.java              (Login, Signup, PasswordReset, Remember Me logic)
- BookService.java              (Search, Filter, Recommend, Get Details logic)
- CartService.java              (Add, Remove, Update, Calculate Total logic)
- OrderService.java             (Create, Update Status, Cancel, Get History logic)
- WishlistService.java          (Add, Remove, Get List logic)
- PaymentService.java           (VNPay integration, Payment processing logic)
- UserService.java              (Profile, Update, Get User Details logic)
- NotificationService.java      (Send, Mark Read, Get Notifications logic)
- CategoryService.java          (List, Add, Edit, Delete categories logic)
- ReviewService.java            (Add, Delete, Get Reviews logic)

### Pattern for Services:
1. Inject DAOs via constructor or factory method.
2. Perform business logic and validation.
3. Return model objects or DTOs (Data Transfer Objects).
4. Handle exceptions and logging.

---

## 5. CONTROLLER REFACTORING (ALREADY DONE)
Location: src/java/controllers/ (copies under package staging.controllers)

### Current Servlets → Controllers:
All 41 Servlet files have been copied to controllers/ with package staging.controllers.
Next step: Reduce each controller to call service methods instead of direct DB logic.

---

## 6. VIEW LAYER (ALREADY STAGED)
Location: web/WEB-INF/views/ & web/assets/

### Already Created:
- web/WEB-INF/views/includes/header.jsp   (Centralized header include)
- web/WEB-INF/views/includes/footer.jsp   (Centralized footer include)
- web/WEB-INF/views/*.jsp (staging copies of pages)
- web/assets/css/                (CSS staging)
- web/assets/js/                 (JS staging)
- web/assets/images/             (Images staging)

---

## IMPLEMENTATION SEQUENCE (Recommended):

1. **Phase 1: Create Models** (Fast)
   - Write 9 model POJOs with getters/setters.
   - Unit test each model.

2. **Phase 2: Create DAOs** (Medium)
   - Write 9 DAO classes with CRUD methods.
   - Each DAO handles database transactions for one entity.
   - Test DAOs with sample queries.

3. **Phase 3: Create Services** (Medium)
   - Write 10 service classes that use DAOs.
   - Extract business logic from controllers into services.
   - Add validation and error handling.

4. **Phase 4: Refactor Controllers** (Medium)
   - Update each controller to call service methods instead of direct DB code.
   - Remove duplicate logic.
   - Keep request/response handling.

5. **Phase 5: Update web.xml & Routes** (Fast)
   - Update servlet mappings to point to refactored controllers.
   - Add servlet filters for auth/logging if needed.

6. **Phase 6: Test & Deploy** (Long)
   - Run smoke tests on all flows.
   - Validate database connections.
   - Deploy and monitor.

---

## NOTES:
- Keep originals in src/java/root as backups during refactoring.
- Use package staging.* for staged copies to avoid conflicts.
- After refactoring complete, delete roots and un-stage (remove staging prefix).
- Consider using a connection pooling library (e.g., HikariCP) for DAOs.
