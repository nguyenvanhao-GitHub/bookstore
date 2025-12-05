import java.security.MessageDigest;
import java.util.Base64;

public class TestAdminDAO {

    public static void main(String[] args) {
        String inputPassword = "12345"; 
       
        // Hash và Salt LẤY TỪ DB:
        String storedHash = "b+787F0z3x4B3I7S3T3E2x2N2W6U3R5f1H6C2f5L5T1I0V1J0M0W4c4k="; 
        String salt = "QJ3Nlq/pE2u4bXj7Fz8jKw=="; 
        // ----------------------------------------------------------------------

        System.out.println("--- BẮT ĐẦU KIỂM TRA MẬT KHẨU ADMIN ---");
        System.out.println("1. Mật khẩu bạn đang kiểm tra: " + inputPassword);
        System.out.println("2. Salt từ DB: " + salt);
        System.out.println("3. Hash mong muốn (Stored Hash): " + storedHash);
        System.out.println("----------------------------------------");

        try {
            String newHash = hashPassword(inputPassword, salt);
            
            System.out.println("4. Hash được tạo ra từ mật khẩu của bạn: " + newHash);

            // 5. So sánh kết quả
            if (newHash.equals(storedHash)) {
                System.out.println("\n KẾT QUẢ: HASH KHỚP. Mật khẩu gốc đã đúng.");
            } else {
                System.out.println("\n KẾT QUẢ: HASH KHÔNG KHỚP. Bạn đang nhập sai mật khẩu gốc.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Lỗi trong quá trình Hash.");
        }
    }

    /**
     * Hàm Hash mật khẩu - Copy từ AdminDAO.java để đảm bảo logic nhất quán.
     */
    private static String hashPassword(String password, String salt) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        // Đảm bảo thứ tự và phương pháp băm là giống nhau
        md.update(salt.getBytes()); 
        return Base64.getEncoder().encodeToString(md.digest(password.getBytes()));
    }
}