-- ==========================================================
-- CẤU HÌNH BAN ĐẦU (QUAN TRỌNG ĐỂ TRÁNH LỖI)
-- ==========================================================
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Tạo và chọn Database
CREATE DATABASE IF NOT EXISTS `bookstore` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bookstore`;

-- ==========================================================
-- 1. STORED PROCEDURES (ĐÃ XÓA DEFINER)
-- ==========================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS `AutoLockInactiveAccounts`$$
CREATE PROCEDURE `AutoLockInactiveAccounts` (IN `days_inactive` INT)
BEGIN
    DECLARE locked_count INT DEFAULT 0;
    
    -- Khóa tài khoản USER không hoạt động
    UPDATE `user`
    SET status = 'Locked',
        lock_reason = CONCAT('Auto-locked: Inactive for ', days_inactive, ' days'),
        locked_at = NOW()
    WHERE status = 'Active'
      AND (last_login IS NULL OR last_login < DATE_SUB(NOW(), INTERVAL days_inactive DAY));
    
    SET locked_count = locked_count + ROW_COUNT();
    
    -- Khóa tài khoản ADMIN không hoạt động (bảo vệ admin id=4)
    UPDATE `admin`
    SET status = 'Locked',
        lock_reason = CONCAT('Auto-locked: Inactive for ', days_inactive, ' days'),
        locked_at = NOW()
    WHERE status = 'Active'
      AND id != 4  -- Bảo vệ admin chính
      AND (last_login IS NULL OR last_login < DATE_SUB(NOW(), INTERVAL days_inactive DAY));
    
    SET locked_count = locked_count + ROW_COUNT();
    
    -- Khóa tài khoản PUBLISHER không hoạt động
    UPDATE `publisher`
    SET status = 'Locked',
        lock_reason = CONCAT('Auto-locked: Inactive for ', days_inactive, ' days'),
        locked_at = NOW()
    WHERE status = 'Active'
      AND (last_login IS NULL OR last_login < DATE_SUB(NOW(), INTERVAL days_inactive DAY));
    
    SET locked_count = locked_count + ROW_COUNT();
    
    -- Trả về số tài khoản đã khóa
    SELECT locked_count AS total_locked;
END$$

DELIMITER ;

-- ==========================================================
-- 2. TABLES & DATA
-- ==========================================================

-- --------------------------------------------------------
-- Table: admin
-- --------------------------------------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `contact` varchar(20) DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_logout` datetime DEFAULT NULL,
  `status` enum('Active','Inactive','Locked') DEFAULT 'Inactive',
  `lock_reason` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_admin_status` (`status`),
  KEY `idx_admin_last_login` (`last_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `admin` (`id`, `name`, `email`, `contact`, `gender`, `password`, `role`, `last_login`, `last_logout`, `status`, `lock_reason`, `locked_at`, `salt`) VALUES
(6, 'Nguyễn Văn Hảo', 'admin@gmail.com', '0356508089', 'Male', '123456789', 'Admin', '2025-12-05 00:00:26', NULL, 'Active', NULL, NULL, NULL);

-- --------------------------------------------------------
-- Table: books
-- --------------------------------------------------------
DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `category` varchar(255) NOT NULL,
  `stock` int(11) NOT NULL,
  `description` text NOT NULL,
  `publisher_email` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `pdf_preview_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `books` (`id`, `image`, `name`, `author`, `price`, `category`, `stock`, `description`, `publisher_email`, `created_at`, `pdf_preview_path`) VALUES
(9, 'images/books/s-l1600.webp', 'Sci Fi Adventure, Escape From Desolation', 'Robert F. Glahe', 140.49, 'Action ', 16, 'Book One: Inclusion, Signed', 'akshit@gmail.com', '2025-04-02 08:35:26', NULL),
(10, 'images/books/211004050.jpg', 'Splinter Effect', 'Andrew Ludington', 89.25, 'Action ', 17, 'In this action-packed debut.', 'akshit@gmail.com', '2025-04-02 08:40:19', NULL),
(11, 'images/books/the-hidden-hindu-3-original-imagu7sacwcydkas.webp', 'The Hidden Hindu', 'Gupta Akshat', 34.90, 'Action ', 15, 'Akshat Gupta is a national bestselling author, a TEDx speaker and an excelling screenwriter and dialogue writer in the Indian film industry.', 'akshit@gmail.com', '2025-04-02 08:47:55', NULL),
(12, 'images/books/the-scarlet-letter-original-imagbyzczjmjx5eh.webp', 'The Scarlet Letter', 'Hawthorne Nathaniel', 200.00, 'Action ', 15, 'The Scarlet Letter  (English, Paperback, Hawthorne Nathaniel)', 'akshit@gmail.com', '2025-04-02 08:55:07', NULL),
(13, 'images/books/the-secret-of-the-nagas-shiva-trilogy-book-2-original-imah7h2ysnqes5ah.webp', 'The Secret Of The Nagas', 'Tripathi Amish', 310.00, 'Action ', 29, 'The Secret Of The Nagas (Shiva Trilogy Book 2)  (English, Paperback, Tripathi Amish)', 'akshit@gmail.com', '2025-04-02 08:57:41', NULL),
(14, 'images/books/81Budsu1XBL._AC_UY327_FMwebp_QL65_.webp', 'HARRY POTTER AND THE ORDER OF THE PHOENIX - 5', 'J.K. Rowline', 550.00, 'Fantasy', 38, 'Dark times have come to Hogwarts. After the Dementors\' attack on his cousin Dudley, Harry Potter knows that Voldemort will stop at nothing to find him.', 'akshit@gmail.com', '2025-04-02 09:00:43', NULL),
(15, 'images/books/81NPFB3iTkL._SY466_.jpg', 'Harry Potter and the Order of Phoenix', 'J.K.Rowling', 850.00, 'Fantasy', 48, 'Let the magic of J.K. Rowling\'s classic Harry Potter series transport you to Hogwarts School of Witchcraft and Wizardry.', 'akshit@gmail.com', '2025-04-02 09:01:59', NULL),
(16, 'images/books/71jKeGU9nKL._SY466_.jpg', 'The Hobbit', 'J.R.R. Tolkien', 312.00, 'Fantasy', 12, 'The Hobbit (Film tie-in edition)', 'akshit@gmail.com', '2025-04-02 09:07:13', NULL),
(17, 'images/books/81U6F6IaPzL._SY466_.jpg', 'Plop: A Horror Short Story', 'Samuel Small', 200.00, 'Horror', 50, 'Plop: A Horror Short Story (Samuel Small Horror Book 1) Kindle Edition', 'sunny@gmail.com', '2025-04-02 14:53:22', NULL),
(18, 'images/books/91TBcPLZqJL._SY466_.jpg', 'The Wind on the Haunted Hill', ' Ruskin Bond', 150.60, 'Horror', 11, 'The Wind on the Haunted Hill Paperback – 1 January 2018\r\nby Ruskin Bond (Author)', 'sunny@gmail.com', '2025-04-02 14:54:43', NULL),
(19, 'images/books/51apiITyKaL._SY445_SX342_.jpg', 'Right Behind You', 'Neil D\'Silva', 500.50, 'Horror', 9, 'Right Behind You | Horror Books for Teens and Adults | A Collection of Horror and Paranormal Short Stories', 'sunny@gmail.com', '2025-04-02 14:56:25', NULL),
(20, 'images/books/51cDJwaroAL._SY445_SX342_.jpg', 'The Haunting of Delhi City', 'Jatin Bhasin', 400.30, 'Horror', 19, 'The Haunting of Delhi City : Tales of the Supernatural', 'sunny@gmail.com', '2025-04-02 14:57:49', NULL),
(21, 'images/books/71U8PEXHcOL._SY466_.jpg', 'Playthings', 'Neil D\'Silva', 219.23, 'Horror', 50, 'Playthings: Toys Of Terror', 'sunny@gmail.com', '2025-04-02 14:59:53', NULL),
(22, 'images/books/610PYeHzOuL._SY466_.jpg', 'Dracula', 'Bram Stoker', 193.24, 'Gothic', 45, 'Dracula Paperback – 1 January 2013\r\nby Bram Stoker (Author)', 'sunny@gmail.com', '2025-04-02 15:17:14', NULL),
(23, 'images/books/71umXQdz6hL._SY466_.jpg', 'The Red Hollow', 'Natalie Marlow', 515.45, 'Gothic', 22, 'The Red Hollow (William Garrett Novels)', 'sunny@gmail.com', '2025-04-02 15:19:02', NULL),
(24, 'images/books/41UYhd2WSjL._SY445_SX342_.jpg', 'Seven Gothic', 'Isak Dinesen', 200.30, 'Gothic', 22, 'Seven Gothic Tales Paperback – 31 October 2002\r\nby Isak Dinesen (Author)', 'sunny@gmail.com', '2025-04-02 15:25:04', NULL),
(25, 'images/books/71EvX+rGkhL._SY466_.jpg', 'Gothic Tales', 'Elizabeth Gaskell', 360.30, 'Gothic', 60, 'Gothic Tales Paperback – 14 August 2000\r\nby Elizabeth Gaskell (Author)', 'sunny@gmail.com', '2025-04-02 15:27:14', NULL),
(26, 'images/books/41b8CtayNnL._SX342_SY445_.jpg', 'Frankenstein', 'Mary Shelley', 500.00, 'Gothic', 20, 'Frankenstein | Gothic Horror & Mystery Classic | Unabridged English Novel', 'sunny@gmail.com', '2025-04-02 15:28:40', NULL),
(28, 'images/books/71SaAoEqWiL._SY425_.jpg', 'A Changing Light', 'Edith Maxwell', 1200.00, 'Mystery', 80, 'A Changing Light: 7 (Quaker Midwife Mysteries) ', 'jay@gmail.com', '2025-04-02 15:33:39', NULL),
(29, 'images/books/41GuDX+jKsL._SY445_SX342_.jpg', 'And Then There Were None', 'Agatha Christie', 3000.00, 'Mystery', 67, 'And Then There Were None: The World’s Favourite Agatha Christie Book', 'jay@gmail.com', '2025-04-02 15:35:20', NULL),
(30, 'images/books/41Vg30m+9jL._SY445_SX342_.jpg', 'The Murder at Sissingham Hall', 'Clara Benson', 2100.00, 'Mystery', 30, 'The Murder at Sissingham Hall (An Angela Marchmont Mystery Book 1) Kindle Edition', 'jay@gmail.com', '2025-04-02 15:37:05', NULL),
(31, 'images/books/81+ceFx9BcL._SY466_.jpg', 'Never Lie', 'The Housemaid Freida McFadden', 3200.00, 'Mystery', 23, 'Never Lie : A Totally Gripping Thriller with Mind-bending Twists', 'jay@gmail.com', '2025-04-02 15:39:30', NULL),
(32, 'images/books/61tjQbGegnL._SY466_.jpg', 'The Mysteries of Udolpho', 'Ann Ward Radcliffe', 2100.00, 'Mystery', 56, 'The Mysteries of Udolpho: A Gothic Masterpiece Kindle Edition', 'jay@gmail.com', '2025-04-02 15:41:00', NULL),
(33, 'images/books/41mmACzEktL._SY445_SX342_.jpg', 'An Historical Mystery', 'Honoré de Balzac', 340.00, 'Historical', 45, 'An Historical Mystery Kindle Edition\r\nby Honoré de Balzac (Author), Katharine Prescott Wormeley (Translator)', 'jay@gmail.com', '2025-04-02 15:44:16', NULL),
(34, 'images/books/81ZZBIeTjqL._SY425_.jpg', 'History Mystery', 'SHARMA NATASHA', 800.00, 'Historical', 30, 'History Mystery: Tughlaq And The Stolen', 'jay@gmail.com', '2025-04-02 15:46:56', NULL),
(35, 'images/books/81u62U5GuQL._SY466_.jpg', 'Bilingual Book English/Spanish', 'Ariel Sanders', 788.00, 'Historical', 62, 'Bilingual Book English/Spanish for Intermediate Learners: Syndicate - A Thrilling Crime Mystery (The Dark Series) (Spanish Edition)', 'jay@gmail.com', '2025-04-02 15:48:43', NULL),
(36, 'images/books/71XQfLqWG2L._SY466_.jpg', 'Ashva', 'Krishna Deo Mistry', 430.00, 'Science', 23, 'Ashva Kindle Edition\r\nby Krishna Deo Mistry (Author) ', 'jay@gmail.com', '2025-04-02 16:20:00', NULL),
(37, 'images/books/81EIFBObjoL._SY466_.jpg', 'Time Trap', 'Micah Caida', 280.00, 'Science', 50, 'Time Trap: Red Moon science fiction, time travel trilogy book 1 (Red Moon Trilogy)', 'jay@gmail.com', '2025-04-02 16:21:46', NULL),
(38, 'images/books/51CF4m7T8fL._SY445_SX342_.jpg', 'Relativity', 'Albert Einstein', 500.00, 'Science', 30, 'Relativity: The Special And The General Theory by Albert Einstein | Concepts of Physics, Relativity, General Relativity & Quantum Mechanics | Conceptual Physics, University Physics & Calculus Core', 'jay@gmail.com', '2025-04-02 16:23:40', NULL),
(39, 'images/books/81DAK5xNjQL._SY425_.jpg', 'Black Holes', 'Stephen Hawking', 1500.00, 'Science', 60, 'Black Holes (L) : The Reith Lectures', 'jay@gmail.com', '2025-04-02 16:25:43', NULL),
(40, 'images/books/61-ovgbVVwL._SX342_SY445_.jpg', 'My Inventions', 'Nikola Tesla', 1500.00, 'Science', 60, 'My Inventions, Autobiography of Nikola Tesla', 'anis@gmail.com', '2025-04-02 16:38:07', NULL),
(41, 'images/books/41KiyP6vx1L._SY445_SX342_.jpg', 'Science and Magic', 'Aditya Upadhaya', 450.00, 'Science', 23, 'Science and Magic - The Search Begins', 'anis@gmail.com', '2025-04-02 16:39:51', NULL),
(42, 'images/books/51vRNIgDcfL._SY445_SX342_.jpg', 'Orbital', 'Samantha Harvey', 230.00, 'Science', 23, 'Orbital: Winner of the Booker Prize 2024', 'anis@gmail.com', '2025-04-02 16:41:16', NULL),
(43, 'images/books/61SwQvI0aKL._SY466_.jpg', 'Reset', 'Janet Elizabeth Henderson', 3400.00, 'Romantic', 25, 'Reset: Romantic Thriller: 7 (Benson Security)', 'anis@gmail.com', '2025-04-02 16:55:05', NULL),
(44, 'images/books/71il8051uQL._SY466_.jpg', 'The Girl Who Wants', 'Amy Vansant', 1200.00, 'Romantic', 80, 'The Girl Who Wants: An addictive romantic thriller packed with twists and dangerous family secrets.', 'anis@gmail.com', '2025-04-02 16:59:52', NULL),
(45, 'images/books/41bXuOUzOIL._SY445_SX342_.jpg', 'Lead from the Front', ' Sudeep Krishna, Purav Gandhi', 566.00, 'Action ', 27, 'Lead from the Front : Inspiring military stories of courage, leadership and resilience', 'akshit@gmail.com', '2025-04-04 01:20:04', NULL),
(46, 'images/books/519FnsjuzpL._SY445_SX342_.jpg', 'The Book That Wouldn’t Burn', ' Mark Lawrence', 1200.00, 'Action ', 40, 'The Book That Wouldn’t Burn: Book 1 (The Library Trilogy)', 'akshit@gmail.com', '2025-04-04 01:21:22', NULL),
(47, 'images/books/81T+O7ResjL._SY466_.jpg', 'The Gollancz', ' Tarun K. Saint', 4000.00, 'Science', 45, 'The Gollancz Book of South Asian Science Fiction Volume 2', 'akshit@gmail.com', '2025-04-04 01:23:35', NULL),
(48, 'images/books/7129AhYq1GL._SY466_.jpg', 'ACTION', 'J Krishnamurti ', 344.00, 'Action ', 21, 'ACTION: THE TEACHINGS OF J. KRISHNAMURTI', 'akshit@gmail.com', '2025-04-04 01:28:03', NULL),
(49, 'images/books/81Aoq-Asg8L._SY385_.jpg', 'Nectar on the Seven Hills', ' Prabhu Ram', 5000.00, 'Fantasy', 48, 'Nectar on the Seven Hills - The Pure Seed - An Epic Fusion of Indian Mythology | Fantasy Adventure', 'akshit@gmail.com', '2025-04-04 01:31:52', NULL),
(50, 'images/books/91g4YHEkGkL._SY342_.jpg', 'Ghosts of The Silent Hills', ' Anita Krishan', 5500.00, 'Horror', 50, 'Ghosts of The Silent Hills: Stories based on true hauntings', 'anis@gmail.com', '2025-04-04 08:28:47', NULL),
(51, 'images/books/81b1PP4RK1L._SY466_.jpg', 'That Night', ' UPADHYAY NIDHI', 2000.00, 'Horror', 70, 'That Night: Four Friends, Twenty Years, One Haunting Secret [Paperback] Nidhi Upadhyay', 'anis@gmail.com', '2025-04-04 08:30:53', NULL),
(52, 'images/books/41MsKF3GfEL._SY445_SX342_.jpg', 'Hidden Pictures', ' Jason Rekulak', 5000.00, 'Horror', 54, 'Hidden Pictures Paperback – 6 June 2023\r\nby Jason Rekulak (Author), Will Staehle (Illustrator), Doogie Horner (Illustrator)', 'anis@gmail.com', '2025-04-04 08:32:09', NULL),
(53, 'images/books/81X7pb2R5iL._SY342_.jpg', 'Dracula (Deluxe Hardbound Edition)', ' Bram Stoker', 34.00, 'Gothic', 99, 'Dracula (Deluxe Hardbound Edition): A Timeless Novel of Gothic Fiction Vampire Novel Horror Classic Transylvania Victorian Era Supernatural Creatures ... and Bloodlust Perfect for Horror', 'anis@gmail.com', '2025-04-04 08:34:32', NULL),
(54, 'images/books/7182rdXnV1L._SY466_.jpg', 'Young Gothic', ' M.A. Bennett', 300.00, 'Gothic', 25, 'Young Gothic Paperback\r\nby M.A. Bennett (Author)\r\n', 'anis@gmail.com', '2025-04-04 08:36:40', NULL),
(55, 'images/books/91JWQ95s5NL._SY466_.jpg', 'MEXICAN GOTHIC', ' Silvia Moreno-Garcia', 8000.00, 'Gothic', 30, 'MEXICAN GOTHIC Paperback\r\nby Silvia Moreno-Garcia (Author)', 'anis@gmail.com', '2025-04-04 08:37:57', NULL),
(56, 'images/books/61cVI3aJp4L._SY466_.jpg', 'THE UNEXPECTED LEADER', ' Joel Sadhanand', 3090.00, 'Mystery', 50, 'THE UNEXPECTED LEADER Paperback – 9 December 2020\r\nby Joel Sadhanand (Author)', 'anis@gmail.com', '2025-04-04 08:40:16', NULL),
(57, 'images/books/71YMKj-3PiL._SY466_.jpg', 'Casino Royale', ' Ian Fleming', 4000.00, 'Mystery', 40, 'Casino Royale: A James Bond Novel | A Spy Thriller', 'anis@gmail.com', '2025-04-04 08:42:11', NULL),
(58, 'images/books/51SGfpyA6hL._SY445_SX342_.jpg', 'The Secret Key', 'Lena Jones', 5000.00, 'Mystery', 48, 'The Secret Key: Agatha Oddly (1)', 'anis@gmail.com', '2025-04-04 08:43:32', NULL),
(59, 'images/books/71NDa85qT7L._SY425_.jpg', 'Shivaji', 'Ranjit Desai ', 1150.00, 'Historical', 80, 'Shivaji: The Great Maratha Paperback\r\nby Ranjit Desai (Author), Vikrant Pande (Translator)', 'sunny@gmail.com', '2025-04-04 08:46:40', NULL),
(60, 'images/books/419Lf6xEQKL._SY445_SX342_.jpg', 'Too Good to Be True', ' Prajakta Koli', 900.00, 'Romantic', 80, 'Too Good to Be True : A smart, funny will-they-won’t-they romance by mostlysane', 'sunny@gmail.com', '2025-04-04 08:48:58', NULL),
(62, 'images/books/51NLZxGANRL._SY445_SX342_.jpg', 'It Ain\'t Over...', ' Robert M. Kerns', 830.89, 'Space ', 90, 'It Ain\'t Over...: An Epic Space Opera Adventure (Cole & Srexx Book 1)', 'sunny@gmail.com', '2025-04-04 08:54:14', NULL),
(65, 'images/books/51t-uiSjF1L._SY445_SX342_.jpg', 'Space Opera', ' Catherynne M. Valente', 900.67, 'Space ', 78, 'Space Opera: HUGO AWARD FINALIST FOR BEST NOVEL 2019', 'sunny@gmail.com', '2025-04-04 09:00:33', NULL),
(66, 'images/books/71IbfWECC0L._SY466_.jpg', 'Krishna: The Man & His Philosophy', ' Osho', 1100.00, 'Philosophy', 77, 'Krishna: The Man & His Philosophy PaperbackEdition\r\nby Osho (Author)', 'sunny@gmail.com', '2025-04-04 09:04:36', NULL),
(67, 'images/books/41vGTDTsdTL._SY445_SX342_.jpg', 'Physics & Philosophy', ' W Heisenberg', 900.56, 'Philosophy', 78, 'Physics & Philosophy Paperback\r\nby W Heisenberg (Author)', 'sunny@gmail.com', '2025-04-04 09:06:11', NULL),
(68, 'images/books/71fTsm3pM5L._SY342_.jpg', 'As A Man Thinketh', ' James Allen', 5100.00, 'Philosophy', 76, 'As A Man Thinketh by James Allen [Premium Paperback] |Philosophy & Human Psychology Book for Personal Growth | Self Help to Think Better Thoughts | Self Improvement Book | The Art Of Contrary Thinking', 'sunny@gmail.com', '2025-04-04 09:08:05', NULL),
(69, 'images/books/51MB4Tc-cFL._SY466_.jpg', 'The Book of life', ' J. Krishnamurti ', 900.78, 'Philosophy', 88, 'The Book of life Paperback\r\nby J. Krishnamurti (Author)', 'sunny@gmail.com', '2025-04-04 09:09:37', NULL),
(71, 'images/books/81RWCtFmVgL._SY342_.jpg', '365 Science Experiments', ' Om Books Editorial Team', 730.78, 'Soft ', 30, 'Encyclopedia : 365 Science Experiments (365 Series)', 'akshit@gmail.com', '2025-04-04 09:15:47', NULL),
(72, 'images/books/51Jwr7dxY1S._SY385_.jpg', 'NCERT Science (PCB) for Class 11 Books Set 11', ' YOUR SCHOOL POINT', 1200.00, 'Soft ', 80, 'NCERT Science (PCB) for Class 11 Books Set 11 (English Medium) (5 Books) Hardcover', 'akshit@gmail.com', '2025-04-04 09:23:00', NULL),
(73, 'images/books/61mpcp01mEL._SY385_.jpg', 'Planet Coloring Book', ' Harper Hall ', 100.90, 'Soft ', 80, 'Planet Coloring Book Paperback\r\nby Harper Hall (Author)\r\n', 'akshit@gmail.com', '2025-04-04 09:25:09', NULL),
(74, 'images/books/51OpvbdQQ3L._SY445_SX342_.jpg', 'The Family Upstairs', 'Lisa Jewell', 1200.67, 'Thriller', 90, 'The Family Upstairs Paperback\r\nby Lisa Jewell (Author)', 'akshit@gmail.com', '2025-04-04 09:28:33', NULL),
(75, 'images/books/81keZ6LpNWL._SY466_.jpg', 'The Housemaid', ' Freida McFadden ', 900.34, 'Thriller', 89, 'The Housemaid : An addictive psychological thriller with mind-bending twists', 'akshit@gmail.com', '2025-04-04 09:30:02', NULL),
(76, 'images/books/71sa1DXwbfL._SY466_.jpg', 'The Boyfriend', ' Freida McFadden ', 230.60, 'Thriller', 90, 'The Boyfriend: The Riveting New Psychological Thriller from BESTSELLING author of THE HOUSEMAID', 'akshit@gmail.com', '2025-04-04 09:31:18', NULL),
(77, 'images/books/810fMTMuZML._SY425_.jpg', 'Girl, Alone', ' Blake Pierce', 90.00, 'Thriller', 30, 'Girl, Alone (An Ella Dark FBI Suspense Thriller—Book 1)', 'akshit@gmail.com', '2025-04-04 09:32:28', NULL),
(78, 'images/books/kimetsu_no_yaiba.jpg', 'TV ANIME “ KIMETSU NO YAIBA ” KOUSHIKI KI', '吾峠 呼世晴', 3200.00, 'Anime', 10, 'TVアニメ『鬼滅の刃』 公式キャラクターズブック 壱ノ巻 (ジャンプコミックス セレクション)\r\n\r\nTVアニメ『鬼滅の刃』初の公式ブック!!\r\n表紙、ポスター(表面)は新規描きおろしのイラスト使用。ファン待望の綴じ込みスペシャルシール付。\r\n壱ノ巻は、竈門炭治郎、禰豆子のイラストギャラリー、ヒストリー、設定資料などキャラクターの魅力を1冊に凝縮。\r\n総ページ62Pのハンディーな1冊!!', 'haonguyen2004hy@gmail.com', '2025-10-09 13:40:00', NULL),
(79, 'images/books/dragon_ball.jpg', 'Dragon Ball Sparking! ZERO Rei Buto Sho', 'Vジャンプ編集部', 415.00, 'Anime', 9, 'ドラゴンボール Sparking! ZERO 零武闘書 - Dragon Ball Sparking! ZERO Rei Buto Sho\r\n\r\n発売時点での参戦キャラクターを全掲載!! 合計182人キャラクターデータを徹底チェック!!\r\n\r\nエピソードバトルの全ルートを徹底攻略!! & 参戦キャラクターの必殺技や能力を網羅!!\r\n\r\n4つのパートで本作を遊び尽くそう!!\r\n\r\n(1)キャラクター編 登場キャラクターの持つ技や能力を分析し、闘いに備えよう!!\r\n\r\n(2)エピソードバトル編 8つのエピソードを攻略! IFルートの分岐もすべて闘い抜こう!!\r\n\r\n(3)バトル&知識編 修業方法やカスタムバトル攻略など、勝つための知識を伝授!!\r\n\r\n(4)データ編 チャレンジ、ミッションなどの報酬集めに役立つデータを掲載!!\r\n\r\nPS5、Xbox Series X|S、Steam版 封入デジタルコードつき!\r\n\r\n解放には高難易度バトルクリアの必要がある「孫悟飯(未来)」「孫悟飯(未来)超サイヤ人」「バーダック」をすぐに使える解放権! さらにSparking!モードが強化される性能アイテムも!!\r\n\r\nデジタルコード有効期限/2025年10月9日23:59まで', 'haonguyen2004hy@gmail.com', '2025-10-09 13:59:51', NULL),
(80, 'images/books/onepiece.jpg', 'ONE PIECE 学園 - One Piece Gakuen 7', 'Sohei Koji', 140.17, 'Anime', 1, 'ONE PIECE 学園 - One Piece Gakuen 7\r\n\r\n転入生として初めて学校に通う事になったウタは、幼馴染のルフィと同じクラスになる。だが2人の関係を気にしたハンコックが!? あのキャラ達が学校で大暴れ!! 『ONE PIECE』のスピンオフ学園コメディ!!', 'haonguyen2004hy@gmail.com', '2025-10-09 14:04:59', NULL),
(81, 'images/books/jujutsu_kaisen.jpg', 'Jujutsu Kaisen 26', '芥見 下々', 152.00, 'Anime', 6, '呪術廻戦 26 - Jujutsu Kaisen 26\r\n\r\n桁違いの規模で繰り広げられる五条vs.宿儺の最強決戦…! 領域の同時展開と焼き切れた術式の修復を繰り返しながらの戦闘は、魔虚羅召喚と五条の領域展開が不可能となった事で均衡が崩れたかに見えたが──!?', 'haonguyen2004hy@gmail.com', '2025-10-09 14:25:44', NULL),
(82, 'images/books/totoro.jpg', 'Tonari No Totoro - My Neighbor Totoro Miyazaki Hayao Imageboard Collection 3', '宮﨑 駿', 1638.02, 'Anime', 8, 'となりのトトロ 宮﨑駿イメージボード全集 - Tonari No Totoro - My Neighbor Totoro ', 'haonguyen2004hy@gmail.com', '2025-10-11 16:20:23', NULL);

-- --------------------------------------------------------
-- Table: cart (ĐÃ SỬA LỖI CẤU TRÚC)
-- --------------------------------------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `book_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `bookname` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `publisher_email` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`book_id`,`user_email`),
  KEY `idx_user_email` (`user_email`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `cart` (`book_id`, `user_email`, `bookname`, `author`, `publisher_email`, `price`, `image`, `quantity`, `created_at`, `updated_at`) VALUES
(14, 'sonaniakshit684@gmail.com', 'HARRY POTTER AND THE ORDER OF THE PHOENIX - 5', 'J.K. Rowling', 'akshit@gmail.com', 550.00, 'images/books/81Budsu1XBL._AC_UY327_FMwebp_QL65_.webp', 1, '2025-04-13 23:33:10', '2025-11-08 11:45:01'),
(15, 'sonaniakshit684@gmail.com', 'Harry Potter and the Order of Phoenix', 'J.K. Rowling', 'akshit@gmail.com', 450.00, 'images/books/81NPFB3iTkL._SY466_.jpg', 1, '2025-04-13 23:33:03', '2025-11-08 11:45:01'),
(58, 'sonaniakshit684@gmail.com', 'The Secret Key', 'Lena Jones', 'anis@gmail.com', 5000.00, 'images/books/51SGfpyA6hL._SY445_SX342_.jpg', 2, '2025-04-13 23:33:38', '2025-11-08 11:45:01'),
(66, 'sonaniakshit684@gmail.com', 'Krishna: The Man & His Philosophy', ' Osho', 'sunny@gmail.com', 1100.00, 'images/books/71IbfWECC0L._SY466_.jpg', 3, '2025-04-13 19:17:53', '2025-11-08 11:45:01'),
(69, 'manish@gmail.com', 'The Book of life', ' J. Krishnamurti ', 'sunny@gmail.com', 900.78, 'images/books/51MB4Tc-cFL._SY466_.jpg', 1, '2025-04-14 02:00:29', '2025-11-08 11:45:01'),
(80, 'luffy1672k4@gmail.com', 'ONE PIECE 学園 - One Piece Gakuen 7', 'Sohei Koji', 'haonguyen2004hy@gmail.com', 140.17, 'images/books/onepiece.jpg', 1, '2025-12-02 08:12:46', '2025-12-02 08:12:46');

-- --------------------------------------------------------
-- Table: category
-- --------------------------------------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `category` (`id`, `name`, `description`, `created_at`) VALUES
(8, 'Action ', 'Action fiction', '2025-04-01 19:52:36'),
(9, 'Fantasy', 'Fantasy fiction', '2025-04-01 19:53:09'),
(10, 'Horror', 'Horror fiction', '2025-04-01 19:53:44'),
(11, 'Gothic', 'Gothic fiction', '2025-04-01 19:54:04'),
(12, 'Mystery', 'Mystery fiction', '2025-04-01 19:54:41'),
(13, 'Historical', 'Historical mystery', '2025-04-01 19:55:15'),
(14, 'Science', 'Science fiction', '2025-04-01 19:56:23'),
(15, 'Romantic', 'Romantic Thriller', '2025-04-01 19:56:47'),
(16, 'Space ', 'Space opera', '2025-04-01 19:57:06'),
(18, 'Soft ', 'Soft science fiction', '2025-04-01 19:57:35'),
(19, 'Thriller', 'Thriller fiction vip', '2025-04-01 19:58:12'),
(20, 'Philosophy', 'Philosophy', '2025-04-01 19:58:40'),
(21, 'Anime', 'Anime Manga', '2025-10-09 06:46:03');

-- --------------------------------------------------------
-- Table: contact_messages
-- --------------------------------------------------------
DROP TABLE IF EXISTS `contact_messages`;
CREATE TABLE `contact_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `subject` varchar(200) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `contact_messages` (`id`, `name`, `email`, `subject`, `message`, `submitted_at`) VALUES
(1, 'Nguyễn Văn An', 'an@gmail.com', 'Hỏi về sách mới', 'Shop có sách tiếng Anh giao tiếp không?', '2025-10-11 08:53:55'),
(2, 'Trần Thị Bích', 'bich@gmail.com', 'Vấn đề thanh toán', 'Tôi không thanh toán được qua Momo, xin hỗ trợ.', '2025-10-11 08:53:55'),
(3, 'Lê Minh Châu', 'chau@gmail.com', 'Đăng ký nhận tin', 'Tôi muốn được nhận thông tin khuyến mãi hàng tuần.', '2025-10-11 08:53:55');

-- --------------------------------------------------------
-- Table: orders
-- --------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` varchar(50) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `books` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT 'Direct Order',
  `status` varchar(20) DEFAULT 'pending',
  `transaction_id` varchar(100) DEFAULT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancelled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_customer_email` (`email`),
  KEY `idx_order_status` (`status`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orders` (`id`, `customer_name`, `email`, `phone`, `address`, `city`, `state`, `zipcode`, `books`, `total_amount`, `payment_method`, `status`, `transaction_id`, `order_date`, `cancelled_at`) VALUES
('02510357', 'abc', 'abc@gmail.com', '0356508089', 'Doi 5 - Tien Hoa - Tien Lu - Hung Yen', 'Hưng Yên', 'Hanoi', '700000', 'Lead from the Front (x4)', 679200.00, 'COD', 'delivered', NULL, '2025-12-04 06:37:05', NULL),
('84763713', 'abc', 'abc@gmail.com', '0356508089', 'Doi 5 - Tien Hoa - Tien Lu - Hung Yen', 'Hưng Yên', 'Hanoi', '700000', '呪術廻戦 26 - Jujutsu Kaisen 26 (x1)', 45600.00, 'COD', 'delivered', NULL, '2025-12-04 03:13:02', NULL);

-- --------------------------------------------------------
-- Table: publisher
-- --------------------------------------------------------
DROP TABLE IF EXISTS `publisher`;
CREATE TABLE `publisher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `contact` varchar(20) DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_logout` datetime DEFAULT NULL,
  `status` enum('Active','Inactive','Locked') DEFAULT 'Inactive',
  `lock_reason` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_publisher_status` (`status`),
  KEY `idx_publisher_last_login` (`last_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `publisher` (`id`, `name`, `email`, `contact`, `gender`, `password`, `role`, `last_login`, `last_logout`, `status`, `lock_reason`, `locked_at`, `salt`) VALUES
(22, 'anis mansuri', 'anis@gmail.com', '6745728493', 'Male', '4/g6DC3AGAeTnuqRN2Zb24Fjw/RNV1GFnBA72xAs6QE=', 'publisher', '2025-11-01 16:03:10', '2025-11-01 16:10:20', 'Inactive', NULL, NULL, 'TY50p2npMJwfP8DSV0BILQ=='),
(23, 'akshit sonani', 'akshit@gmail.com', '7778813428', 'Male', 'ak5DnOvE6RR4mUZpfvBjrXu4Alp3ty52ff4FxLkRJ1I=', 'publisher', '2025-11-08 10:34:57', '2025-11-08 10:37:15', 'Inactive', NULL, NULL, '4oWPl/EagZ0TqJ2eJ5ba1Q=='),
(24, 'jay heruwala', 'jay@gmail.com', '868768768', 'Male', 'wEAqqexu9PXR0rrGIR6seFTTovH8R2CIf2UhSNbKtGE=', 'publisher', '2025-11-01 16:00:02', '2025-11-01 16:01:13', 'Inactive', NULL, NULL, '8SS87Psof5dkzftKKaBhGw=='),
(25, 'sunny thakor', 'sunny@gmail.com', '6745728493', 'Male', 'lzJT1t7ew7Umak/nyarwKO+8GsSqm5FpWj/fxcH76Ko=', 'publisher', '2025-11-01 16:01:48', '2025-11-01 16:02:07', 'Inactive', NULL, NULL, 'RMZd07Rjz16fCDNuYQkAyA=='),
(26, 'Nguyễn Văn Hảo', 'haonguyen2004hy@gmail.com', '0356508089', 'Male', '7ZnmkwiFLHfE3dLX1cpUBPU8eugKbbTsxJh+7PrWnM4=', 'publisher', '2025-12-04 23:24:52', '2025-12-04 23:25:16', 'Active', NULL, NULL, 'y2FBlpXcSX4PvuOt31mflw==');

-- --------------------------------------------------------
-- Table: remember_me_tokens
-- --------------------------------------------------------
DROP TABLE IF EXISTS `remember_me_tokens`;
CREATE TABLE `remember_me_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`token`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `remember_me_tokens` (`id`, `user_id`, `token`, `email`, `created_at`, `expires_at`) VALUES
(6, 21, 'oldiOGnlgj3mLNT31PRcUDf9TLtTnPICVNPUhms-7Bk', 'haonguyen2004hy@gmail.com', '2025-11-27 06:28:43', '2025-12-27 06:28:43'),
(84, 22, 'edR2HzRX9yyBDAjQc07F26mMl2KioGvq4Z-P2GNq71M', 'luffy1672k4@gmail.com', '2025-12-02 01:17:44', '2026-01-01 01:17:44'),
(156, 11, 'xaSXHHgy_jNwjGZxmhJTg37hSb6GTufmyZ53vcZ9OGE', 'abc@gmail.com', '2025-12-04 17:08:21', '2026-01-03 17:08:21');

-- --------------------------------------------------------
-- Table: reviews
-- --------------------------------------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_email` varchar(255) NOT NULL,
  `book_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_book` (`user_email`,`book_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `reviews` (`id`, `user_email`, `book_id`, `rating`, `comment`, `created_at`) VALUES
(1, 'haonguyen2004hy@gmail.com', 78, 5, 'VERY GOOD', '2025-11-06 08:12:50'),
(2, 'haonguyen2004hy@gmail.com', 81, 5, 'VERY GOOD', '2025-11-06 08:13:29'),
(3, 'haonguyen2004hy@gmail.com', 80, 5, 'VERY GOOD', '2025-11-06 08:16:28'),
(4, 'haonguyen2004hy@gmail.com', 82, 5, 'VERY GOOD', '2025-11-06 08:18:19'),
(6, 'haonguyen2004hy@gmail.com', 79, 5, 'VERY GOOD', '2025-11-06 09:30:33'),
(7, 'haonguyen2004hy@gmail.com', 38, 5, 'VERY GOOD', '2025-11-06 09:31:45'),
(8, 'haonguyen2004hy@gmail.com', 21, 5, 'VERY GOOD', '2025-11-06 09:32:21'),
(9, 'haonguyen2004hy@gmail.com', 16, 5, 'VERY GOOD', '2025-11-06 09:32:39'),
(10, 'haonguyen2004hy@gmail.com', 15, 5, 'GOOD', '2025-11-06 09:33:06'),
(11, 'haonguyen2004hy@gmail.com', 23, 5, 'GOOD', '2025-11-06 09:33:22'),
(18, 'abc@gmail.com', 77, 5, 'QUA TE, PHIM TE', '2025-12-04 17:03:42'),
(19, 'abc@gmail.com', 76, 2, 'QUA TE, PHIM TE', '2025-12-04 17:03:58');

-- --------------------------------------------------------
-- Table: subscriber
-- --------------------------------------------------------
DROP TABLE IF EXISTS `subscriber`;
CREATE TABLE `subscriber` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `subscribed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `subscriber` (`id`, `email`, `subscribed_at`) VALUES
(3, 'leminhchau@gmail.com', '2025-10-11 08:53:40'),
(4, 'phamhoang@gmail.com', '2025-10-11 08:53:40'),
(5, 'doanthuylinh@gmail.com', '2025-10-11 08:53:40'),
(6, 'hoangnam@yahoo.com', '2025-10-11 08:53:40'),
(7, 'anhngoc@gmail.com', '2025-10-11 08:53:40'),
(8, 'ngocanh@gmail.com', '2025-10-11 08:53:40'),
(9, 'minhquan@gmail.com', '2025-10-11 08:53:40'),
(15, 'haonguyen2004hy@gmail.com', '2025-11-06 06:44:22'),
(20, 'abc@gmail.com', '2025-12-04 17:02:06'),
(21, 'haon67819@gmail.com', '2025-12-04 17:02:29'),
(23, 'admin@gmail.com', '2025-12-04 17:02:40');

-- --------------------------------------------------------
-- Table: user
-- --------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `contact` varchar(20) DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_logout` datetime DEFAULT NULL,
  `status` enum('Active','Inactive','Locked') DEFAULT 'Inactive',
  `lock_reason` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `salt` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_user_status` (`status`),
  KEY `idx_user_last_login` (`last_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `user` (`id`, `name`, `email`, `contact`, `gender`, `password`, `role`, `last_login`, `last_logout`, `status`, `lock_reason`, `locked_at`, `salt`) VALUES
(11, 'abc', 'abc@gmail.com', '23', 'Male', 'TAn1gjXMmUByEUvhzKAfYQ1YaZ8eWR7wUffUlyPOE+w=', 'User', '2025-12-05 00:08:21', '2025-12-04 23:18:19', 'Active', NULL, NULL, 'nQFpu0Lk/4eI9PqN5q1gDQ=='),
(12, 'manish desai', 'manish@gmail.com', '9876543526', 'Male', 'jfHxlKarLcvTnKVa/1VmG7ThoqZx7jsBdodQzWn5DBo=', 'User', '2025-11-13 15:43:18', '2025-11-13 15:43:34', 'Inactive', NULL, NULL, '9fdLyplkxUG6/n9aKLvIyA=='),
(13, 'ashwin desai', 'ashwin@gmail.com', '9853624315', 'Male', 'VXz25lcOtL61DYvG3ID/pomhpvQPTrrm0qXse0f8Vkc=', 'User', NULL, NULL, 'Inactive', NULL, NULL, 'O3FgLZTUTn965LWS0oQthA=='),
(14, 'jignesh desai', 'jignesh@gmail.com', '9824516278', 'Male', 'wmtxfhSttB5b8R5TcN5JbEMeb52hJuxLTs0N5FR23pQ=', 'User', NULL, NULL, 'Inactive', NULL, NULL, 'DzOw+SDzFfjwc3SJbJBNag=='),
(16, 'Akshit Sonani', 'sonaniakshit684@gmail.com', '7894565621332', 'Female', 'VQQHruvf/P4rXNhqOSG/A8fN+CB7NhFtSzthKwQXvTw=', 'User', '2025-11-13 15:45:31', '2025-11-13 15:45:44', 'Inactive', NULL, NULL, '1KGGl8weMPe8BHj61dfK3Q=='),
(17, 'anis mansuri', 'kanu7869292@gmail.com', '9876543219', 'Male', 'Gqorpb76Xdiyb5ikLBcvNx9Ma+zI856tT2sOjnD2GRk=', 'User', '2025-04-13 23:56:00', NULL, 'Inactive', NULL, NULL, '4PaqecRNTlewOZV5rnDIJA=='),
(19, 'haonguyen', 'haon67819@gmail.com', '0385361352', 'Male', 'ZH7OfP2vod6g+FrUG8KcTPfZccnCZrWsHNn8HTWkXgg=', 'User', '2025-11-08 13:34:36', '2025-11-04 23:23:06', 'Active', NULL, NULL, 'RGtIpNmA1/lC+rYLrYI8XA=='),
(21, 'Nguyễn Văn Hảo', 'haonguyen2004hy@gmail.com', '0356508089', 'Male', 'gySdRHjnFeZ8rjR3Lf03J+CpzzY653oWBYrYyUzhf8k=', 'User', '2025-11-27 13:28:43', '2025-11-27 12:42:33', 'Active', NULL, NULL, '5ardYtekjjNc7FD9jvg+2A=='),
(22, 'Quyền Đức Tiệp', 'luffy1672k4@gmail.com', '0963710736', 'Male', '2AmBNkFJ57v0foZRqORuB24ZBBH1/fyL1ysQjp1hFlk=', 'User', '2025-12-02 08:17:44', '2025-12-02 08:17:23', 'Locked', 'spam', '2025-12-04 18:40:41', '1SBNvdvKpjha7Rh22vPTQw==');

-- --------------------------------------------------------
-- Table: wishlist
-- --------------------------------------------------------
DROP TABLE IF EXISTS `wishlist`;
CREATE TABLE `wishlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_wishlist_user` (`user_id`),
  KEY `fk_wishlist_book` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `wishlist` (`id`, `user_id`, `book_id`, `added_at`) VALUES
(1, 21, 81, '2025-11-08 02:51:51'),
(2, 21, 78, '2025-11-08 02:52:28'),
(3, 21, 79, '2025-11-08 02:52:35'),
(4, 21, 80, '2025-11-08 02:52:39'),
(7, 11, 78, '2025-12-01 09:47:34'),
(8, 11, 82, '2025-12-01 09:47:43'),
(9, 11, 81, '2025-12-01 09:47:48'),
(11, 11, 79, '2025-12-03 18:20:40'),
(12, 11, 10, '2025-12-04 03:13:29');

-- ==========================================================
-- 3. VIEWS & EVENTS
-- ==========================================================

DROP VIEW IF EXISTS `accounts_at_risk`;
CREATE ALGORITHM=UNDEFINED VIEW `accounts_at_risk` AS 
SELECT 'user' AS `account_type`, `user`.`id` AS `id`, `user`.`name` AS `name`, `user`.`email` AS `email`, `user`.`status` AS `status`, `user`.`last_login` AS `last_login`, CASE WHEN `user`.`last_login` is null THEN 999999 ELSE to_days(current_timestamp()) - to_days(`user`.`last_login`) END AS `days_inactive` FROM `user` WHERE `user`.`status` = 'Active' AND (`user`.`last_login` is null OR `user`.`last_login` < current_timestamp() - interval 60 day)
UNION ALL 
SELECT 'admin' AS `account_type`,`admin`.`id` AS `id`,`admin`.`name` AS `name`,`admin`.`email` AS `email`,`admin`.`status` AS `status`,`admin`.`last_login` AS `last_login`,case when `admin`.`last_login` is null then 999999 else to_days(current_timestamp()) - to_days(`admin`.`last_login`) end AS `days_inactive` from `admin` where `admin`.`status` = 'Active' and `admin`.`id` <> 4 and (`admin`.`last_login` is null or `admin`.`last_login` < current_timestamp() - interval 60 day) 
UNION ALL 
SELECT 'publisher' AS `account_type`,`publisher`.`id` AS `id`,`publisher`.`name` AS `name`,`publisher`.`email` AS `email`,`publisher`.`status` AS `status`,`publisher`.`last_login` AS `last_login`,case when `publisher`.`last_login` is null then 999999 else to_days(current_timestamp()) - to_days(`publisher`.`last_login`) end AS `days_inactive` from `publisher` where `publisher`.`status` = 'Active' and (`publisher`.`last_login` is null or `publisher`.`last_login` < current_timestamp() - interval 60 day) order by `days_inactive` desc;

DELIMITER $$

DROP EVENT IF EXISTS `daily_auto_lock_inactive_accounts`$$
CREATE EVENT `daily_auto_lock_inactive_accounts` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-14 02:00:00' ON COMPLETION NOT PRESERVE ENABLE DO CALL AutoLockInactiveAccounts(90)$$

DROP EVENT IF EXISTS `cleanup_expired_tokens`$$
CREATE EVENT `cleanup_expired_tokens` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-22 15:39:02' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM `remember_me_tokens` WHERE `expires_at` < NOW()$$

DELIMITER ;

-- ==========================================================
-- 4. CONSTRAINTS (KHÓA NGOẠI)
-- ==========================================================

ALTER TABLE `cart`
  ADD CONSTRAINT `cart_book_fk` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cart_user_fk` FOREIGN KEY (`user_email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `remember_me_tokens`
  ADD CONSTRAINT `fk_remember_me_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE;

ALTER TABLE `wishlist`
  ADD CONSTRAINT `fk_wishlist_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  ADD CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

-- BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;