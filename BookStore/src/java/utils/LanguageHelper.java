package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.ResourceBundle;
import java.text.NumberFormat;
import java.util.PropertyResourceBundle;

/**
 * LanguageHelper - Utility class để xử lý đa ngôn ngữ
 * Hỗ trợ Tiếng Việt (vi) và English (en)
 */
public class LanguageHelper {
    
    // Constants
    private static final String SESSION_LANG_KEY = "lang";
    private static final String RESOURCE_BUNDLE_BASE = "messages";
    private static final String DEFAULT_LANG = "vi";
    
    /**
     * Lấy ngôn ngữ hiện tại từ session
     * @param request HttpServletRequest
     * @return Mã ngôn ngữ ("vi" hoặc "en")
     */
    public static String getCurrentLanguage(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String lang = (String) session.getAttribute(SESSION_LANG_KEY);
        
        if (lang == null || lang.isEmpty()) {
            lang = DEFAULT_LANG;
            session.setAttribute(SESSION_LANG_KEY, lang);
        }
        
        return lang;
    }
    
    public static ResourceBundle getBundleUTF8(String baseName) {
    ResourceBundle.Control utf8Control = new ResourceBundle.Control() {
        @Override
        public ResourceBundle newBundle(String baseName, Locale locale, String format,
                ClassLoader loader, boolean reload)
                throws IllegalAccessException, InstantiationException, IOException {

            String bundleName = toBundleName(baseName, locale);
            String resourceName = toResourceName(bundleName, "properties");
            InputStream stream = loader.getResourceAsStream(resourceName);

            if (stream != null) {
                try (InputStreamReader reader = new InputStreamReader(stream, StandardCharsets.UTF_8)) {
                    return new PropertyResourceBundle(reader);
                }
            }
            return super.newBundle(baseName, locale, format, loader, reload);
        }
    };

    return ResourceBundle.getBundle(baseName, utf8Control);
}

    /**
     * Set ngôn ngữ vào session
     * @param request HttpServletRequest
     * @param lang Mã ngôn ngữ ("vi" hoặc "en")
     */
    public static void setLanguage(HttpServletRequest request, String lang) {
        if (lang != null && (lang.equals("vi") || lang.equals("en"))) {
            HttpSession session = request.getSession();
            session.setAttribute(SESSION_LANG_KEY, lang);
        }
    }
    
    /**
     * Lấy Locale hiện tại
     * @param request HttpServletRequest
     * @return Locale object
     */
    public static Locale getLocale(HttpServletRequest request) {
        String lang = getCurrentLanguage(request);
        
        if ("en".equals(lang)) {
            return new Locale("en", "US");
        } else {
            return new Locale("vi", "VN");
        }
    }
    
    /**
     * Lấy ResourceBundle theo ngôn ngữ hiện tại
     * @param request HttpServletRequest
     * @return ResourceBundle
     */
    private static ResourceBundle getResourceBundle(HttpServletRequest request) {
        String lang = getCurrentLanguage(request);
        Locale locale = getLocale(request);
        
        try {
            return ResourceBundle.getBundle(RESOURCE_BUNDLE_BASE + "_" + lang, locale);
        } catch (Exception e) {
            // Fallback to default
            return ResourceBundle.getBundle(RESOURCE_BUNDLE_BASE + "_vi", new Locale("vi", "VN"));
        }
    }
    
    /**
     * Lấy text theo key từ resource bundle
     * @param request HttpServletRequest
     * @param key Key trong properties file
     * @return Text đã được dịch
     */
    public static String getText(HttpServletRequest request, String key) {
        try {
            ResourceBundle bundle = getResourceBundle(request);
            return bundle.getString(key);
        } catch (Exception e) {
            System.err.println("Missing translation key: " + key);
            return "[" + key + "]"; // Trả về key để dễ debug
        }
    }
    
    /**
     * Lấy text với parameters (dạng {0}, {1}, ...)
     * @param request HttpServletRequest
     * @param key Key trong properties file
     * @param params Parameters để replace
     * @return Text đã được format
     */
    public static String getText(HttpServletRequest request, String key, Object... params) {
        try {
            String text = getText(request, key);
            
            // Replace {0}, {1}, {2}... với parameters
            for (int i = 0; i < params.length; i++) {
                text = text.replace("{" + i + "}", String.valueOf(params[i]));
            }
            
            return text;
        } catch (Exception e) {
            return "[" + key + "]";
        }
    }
    
    /**
     * Format tiền tệ theo locale
     * @param request HttpServletRequest
     * @param amount Số tiền
     * @return Chuỗi tiền tệ đã format
     */
    public static String formatCurrency(HttpServletRequest request, double amount) {
        Locale locale = getLocale(request);
        NumberFormat formatter = NumberFormat.getCurrencyInstance(locale);
        return formatter.format(amount);
    }
    
    /**
     * Format số theo locale
     * @param request HttpServletRequest
     * @param number Số cần format
     * @return Chuỗi số đã format
     */
    public static String formatNumber(HttpServletRequest request, long number) {
        Locale locale = getLocale(request);
        NumberFormat formatter = NumberFormat.getNumberInstance(locale);
        return formatter.format(number);
    }
    
    /**
     * Kiểm tra có phải Tiếng Việt không
     * @param request HttpServletRequest
     * @return true nếu là Tiếng Việt
     */
    public static boolean isVietnamese(HttpServletRequest request) {
        return "vi".equals(getCurrentLanguage(request));
    }
    
    /**
     * Kiểm tra có phải English không
     * @param request HttpServletRequest
     * @return true nếu là English
     */
    public static boolean isEnglish(HttpServletRequest request) {
        return "en".equals(getCurrentLanguage(request));
    }
    
    /**
     * Lấy tên ngôn ngữ hiển thị
     * @param request HttpServletRequest
     * @return Tên ngôn ngữ
     */
    public static String getLanguageName(HttpServletRequest request) {
        return isVietnamese(request) ? "Tiếng Việt" : "English";
    }
}