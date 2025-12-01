package config;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * VNPay Configuration - Cấu hình chuẩn từ VNPay
 */
public class VNPayConfig {
    
    // ✅ Cấu hình VNPay Sandbox - Lấy từ email đăng ký
    public static String vnp_PayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static String vnp_ReturnUrl = "http://localhost:8081/BookStore/VNPayReturnServlet";
    public static String vnp_TmnCode = "7WX4QWV7"; // Terminal ID
    public static String vnp_HashSecret = "YLW29DYASIQMH92UG57LZFOOVBS1YJ7X"; // Secret Key
    
    /**
     * Tạo URL thanh toán VNPay
     * @param orderId Mã đơn hàng
     * @param amount Số tiền (VND)
     * @param orderInfo Thông tin đơn hàng
     * @param ipAddress IP của khách hàng
     * @return URL thanh toán
     */
    public static String createPaymentUrl(String orderId, long amount, String orderInfo, String ipAddress) 
            throws UnsupportedEncodingException {
        
        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(amount * 100)); // ✅ VNPay yêu cầu nhân 100
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", orderId);
        vnp_Params.put("vnp_OrderInfo", orderInfo);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", ipAddress);
        
        // ✅ Tạo thời gian
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        String vnp_CreateDate = new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
        
        // ✅ Thời gian hết hạn: 15 phút
        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);
        
        // ✅ Build query string và hash
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                // ✅ Build hash data (không encode)
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                
                // ✅ Build query string (có encode)
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }
        
        String queryUrl = query.toString();
        String vnp_SecureHash = hmacSHA512(vnp_HashSecret, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
        String paymentUrl = vnp_PayUrl + "?" + queryUrl;
        
        System.out.println("========== VNPay Payment URL ==========");
        System.out.println("Order ID: " + orderId);
        System.out.println("Amount: " + amount + " VND");
        System.out.println("Hash Data: " + hashData.toString());
        System.out.println("Secure Hash: " + vnp_SecureHash);
        System.out.println("Payment URL: " + paymentUrl);
        System.out.println("=======================================");
        
        return paymentUrl;
    }
    
    /**
     * Xác thực chữ ký từ VNPay khi return
     * @param fields Các tham số return từ VNPay
     * @return true nếu hợp lệ
     */
    public static boolean verifyPayment(Map<String, String> fields) {
        String vnp_SecureHash = fields.get("vnp_SecureHash");
        
        // ✅ Remove secure hash khỏi params trước khi tính toán
        fields.remove("vnp_SecureHashType");
        fields.remove("vnp_SecureHash");
        
        // ✅ Sort params
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                hashData.append(fieldName);
                hashData.append('=');
                try {
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }
        
        String signValue = hmacSHA512(vnp_HashSecret, hashData.toString());
        
        System.out.println("========== VNPay Verify ==========");
        System.out.println("Hash Data: " + hashData.toString());
        System.out.println("Calculated Hash: " + signValue);
        System.out.println("VNPay Hash: " + vnp_SecureHash);
        System.out.println("Valid: " + signValue.equals(vnp_SecureHash));
        System.out.println("==================================");
        
        return signValue.equals(vnp_SecureHash);
    }
    
    /**
     * Mã hóa HMAC SHA512
     */
    public static String hmacSHA512(String key, String data) {
        try {
            if (key == null || data == null) {
                throw new NullPointerException();
            }
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            ex.printStackTrace();
            return "";
        }
    }
    
    /**
     * Lấy địa chỉ IP của client
     */
    public static String getIpAddress(jakarta.servlet.http.HttpServletRequest request) {
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }
    
    /**
     * Lấy message lỗi từ VNPay response code
     */
    public static String getResponseMessage(String responseCode) {
        switch (responseCode) {
            case "00": return "Giao dịch thành công";
            case "07": return "Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường).";
            case "09": return "Thẻ/Tài khoản chưa đăng ký dịch vụ InternetBanking.";
            case "10": return "Xác thực thông tin thẻ/tài khoản không đúng quá 3 lần.";
            case "11": return "Đã hết hạn chờ thanh toán.";
            case "12": return "Thẻ/Tài khoản bị khóa.";
            case "13": return "Nhập sai mật khẩu xác thực giao dịch (OTP).";
            case "24": return "Khách hàng hủy giao dịch.";
            case "51": return "Tài khoản không đủ số dư.";
            case "65": return "Tài khoản đã vượt quá hạn mức giao dịch trong ngày.";
            case "75": return "Ngân hàng thanh toán đang bảo trì.";
            case "79": return "Nhập sai mật khẩu thanh toán quá số lần quy định.";
            default: return "Giao dịch thất bại. Mã lỗi: " + responseCode;
        }
    }
}