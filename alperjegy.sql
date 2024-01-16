-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 16, 2024 at 08:39 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `alperjegy`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `BuyTicket` (IN `p_ticketType_id` INT, IN `p_user_id` INT)   BEGIN
  DECLARE v_price INT;
  
  -- Start a new transaction
  START TRANSACTION;
  
  -- Get the price of the ticket
  SELECT price INTO v_price FROM ticket_types WHERE ticketType_id = p_ticketType_id;
  
  -- Insert a row into the transactions table
  INSERT INTO transactions(user_id, amount, transaction_date) VALUES(p_user_id, v_price, NOW());
  
  -- Insert a row into the tickets table with the transaction ID and the generated UUID
  INSERT INTO tickets(ticket_id, transaction_id, ticketType_id) VALUES(UUID(), LAST_INSERT_ID(), p_ticketType_id);
  
  -- Commit the transaction
  COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateTicket` (IN `p_ticketType_id` INT, IN `p_transaction_id` INT)   BEGIN
  DECLARE v_uuid CHAR(36);
  SET v_uuid = UUID();
  INSERT INTO tickets(ticket_id, ticketType_id, transaction_id, valid_date, expiry_date)
  VALUES (v_uuid, p_ticketType_id, p_transaction_id, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateTransaction` (IN `p_user_id` INT, IN `p_amount` INT)   BEGIN
  INSERT INTO transactions(user_id, amount, transaction_date)
  VALUES (p_user_id, p_amount, CURRENT_TIMESTAMP);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserTickets` (IN `p_username` VARCHAR(255))   BEGIN
  SELECT t.ticket_id, tt.ticket_type, tt.city, t.expiry_date
  FROM tickets t
  JOIN transactions tr ON t.transaction_id = tr.transaction_id
  JOIN users u ON tr.user_id = u.user_id
  JOIN ticket_types tt ON t.ticketType_id = tt.ticketType_id
  WHERE u.username = p_username
  ORDER BY CASE WHEN t.expiry_date < NOW() THEN 1 ELSE 0 END, t.expiry_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUser` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
    SET @salted_password = CONCAT(p_password, '1337');
    SET @hashed_password = SHA2(@salted_password, 256);
    INSERT INTO users(username, password) VALUES (p_username, UNHEX(@hashed_password));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateTicket` (IN `ticketID` CHAR(36))   BEGIN
  UPDATE tickets
  SET valid_date = NOW(),
      expiry_date = DATE_ADD(NOW(), INTERVAL 60 MINUTE)
  WHERE ticket_id = ticketID;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `LoginUser` (`p_username` VARCHAR(255), `p_password` VARCHAR(255)) RETURNS TINYINT(1)  BEGIN
    SET @salted_password = CONCAT(p_password, '1337');
    SET @hashed_password = SHA2(@salted_password, 256);
    SET @user_exists = (SELECT COUNT(*) FROM users WHERE username = p_username AND password = UNHEX(@hashed_password));
    RETURN @user_exists > 0;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `city_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`city_name`) VALUES
('Budapest'),
('Debrecen'),
('Pécs'),
('Szeged');

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `line_company` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `companies`
--

INSERT INTO `companies` (`line_company`) VALUES
('BKK Budapest'),
('DKV Debrecen'),
('Szegedi K.T.'),
('Tüke busz'),
('Volanbusz');

-- --------------------------------------------------------

--
-- Stand-in structure for view `displayalltickets`
-- (See below for the actual view)
--
CREATE TABLE `displayalltickets` (
`ticket_id` char(36)
,`ticket_type` varchar(30)
,`line_company` varchar(30)
);

-- --------------------------------------------------------

--
-- Table structure for table `line_tickets`
--

CREATE TABLE `line_tickets` (
  `line_id` varchar(10) NOT NULL,
  `ticket_type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `line_types`
--

CREATE TABLE `line_types` (
  `line_type` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `line_types`
--

INSERT INTO `line_types` (`line_type`) VALUES
('Bus'),
('HEV'),
('Metro'),
('Tram'),
('Trolley');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `ticket_id` char(36) NOT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `ticketType_id` int(11) DEFAULT NULL,
  `valid_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`ticket_id`, `transaction_id`, `ticketType_id`, `valid_date`, `expiry_date`) VALUES
('0d1307e1-b422-11ee-9968-088fc33bd31e', 7, 1, '2024-01-16 06:48:04', '2024-01-16 07:48:04'),
('0f750bd7-b41d-11ee-9968-088fc33bd31e', 3, 2, '2024-01-16 00:12:36', '2024-01-16 03:12:36'),
('2058c459-b421-11ee-9968-088fc33bd31e', 5, 23, NULL, NULL),
('44bd4407-b421-11ee-9968-088fc33bd31e', 6, NULL, NULL, NULL),
('4cf025ab-b469-11ee-9968-088fc33bd31e', 12, 25, NULL, NULL),
('6121bb46-b422-11ee-9968-088fc33bd31e', 8, 26, '2024-01-16 06:50:30', '2024-01-16 07:50:30'),
('817fea1a-b422-11ee-9968-088fc33bd31e', 9, 2, NULL, NULL),
('9f597174-b462-11ee-9968-088fc33bd31e', 10, 1, '2024-01-16 14:30:02', '2024-01-16 15:30:02'),
('b8bcaead-b420-11ee-9968-088fc33bd31e', 4, 23, NULL, NULL),
('c280c872-b47e-11ee-9968-088fc33bd31e', 13, 26, '2024-01-16 17:51:26', '2024-01-16 18:51:26'),
('c86f35fa-b41c-11ee-9968-088fc33bd31e', 1, 1, '2024-01-16 14:52:49', '2024-01-16 15:52:49'),
('d0c5e0fb-b41c-11ee-9968-088fc33bd31e', 2, 5, '2024-01-16 06:10:37', '2024-01-16 07:10:37'),
('db2d1086-b465-11ee-9968-088fc33bd31e', 11, 25, '2024-01-16 15:12:18', '2024-01-16 16:12:18');

-- --------------------------------------------------------

--
-- Table structure for table `ticket_types`
--

CREATE TABLE `ticket_types` (
  `ticketType_id` int(11) NOT NULL,
  `ticket_type` varchar(30) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ticket_types`
--

INSERT INTO `ticket_types` (`ticketType_id`, `ticket_type`, `city`, `price`, `expiration_time`) VALUES
(1, 'Single-Ticket', 'Pécs', 400, '1001-01-01 02:00:00'),
(2, 'Single-Ticket', 'Budapest', 400, '1001-01-01 02:00:00'),
(3, 'Single-Ticket', 'Debrecen', 400, '1001-01-01 02:00:00'),
(4, 'Single-Ticket', 'Szeged', 400, '1001-01-01 02:00:00'),
(5, 'Airport Shuttle Single', 'Budapest', 2200, '1001-01-01 02:00:00'),
(6, '30-minute Ticket', 'Budapest', 530, '1001-01-01 00:30:00'),
(7, '24-hour Travelcard', 'Budapest', 2500, '1001-01-01 00:00:00'),
(8, 'Monthly Budapest-pass', 'Budapest', 9500, '1001-01-01 00:00:00'),
(9, 'Monthly Student-pass', 'Budapest', 3450, '1001-01-01 00:00:00'),
(10, 'Full Price 450 km', NULL, 5643, '1001-01-01 00:00:00'),
(11, 'Full Price 100 km', NULL, 1767, '1001-01-01 00:00:00'),
(12, 'Full Price 20 km', NULL, 475, '1001-01-01 00:00:00'),
(13, '50% discount 450 km', NULL, 2822, '1001-01-01 00:00:00'),
(14, '90% discount 450 km', NULL, 565, '1001-01-01 00:00:00'),
(15, 'Single-Ticket', 'Debrecen', 440, '1001-01-01 02:00:00'),
(16, 'One hour ticket', 'Debrecen', 500, '1001-01-01 01:00:00'),
(17, 'Single-Ticket', 'Debrecen', 440, '1001-01-01 02:00:00'),
(18, 'Single-Ticket', 'Szeged', 500, '1001-01-01 02:00:00'),
(19, '60-minute Ticket', 'Szeged', 550, '1001-01-01 01:00:00'),
(20, 'Single-Ticket', 'Szeged', 500, '1001-01-01 02:00:00'),
(21, 'Single-Ticket', 'Szeged', 500, '1001-01-01 02:00:00'),
(22, '30-Day pass', 'Szeged', 8800, '1001-01-30 00:00:00'),
(23, 'Monthly Student', 'Szeged', 5280, '1001-01-30 00:00:00'),
(24, '24-hour ticket', 'Szeged', 1380, '1001-01-01 00:00:00'),
(25, 'Student-Ticket', 'Budapest', 200, NULL),
(26, 'Student-Ticket', 'Pécs', 200, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `transaction_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transaction_id`, `user_id`, `amount`, `transaction_date`) VALUES
(1, 23, 400, '2024-01-16 06:10:10'),
(2, 23, 2200, '2024-01-16 06:10:24'),
(3, 23, 400, '2024-01-16 06:12:09'),
(4, NULL, 5280, '2024-01-16 06:38:21'),
(5, NULL, 5280, '2024-01-16 06:41:15'),
(6, 23, NULL, '2024-01-16 06:42:16'),
(7, 23, 400, '2024-01-16 06:47:52'),
(8, 24, 200, '2024-01-16 06:50:13'),
(9, 24, 400, '2024-01-16 06:51:07'),
(10, 24, 400, '2024-01-16 14:29:52'),
(11, 23, 200, '2024-01-16 14:53:01'),
(12, 23, 200, '2024-01-16 15:17:41'),
(13, 24, 200, '2024-01-16 17:51:17');

-- --------------------------------------------------------

--
-- Table structure for table `transport_lines`
--

CREATE TABLE `transport_lines` (
  `line_id` varchar(10) NOT NULL,
  `line_city` varchar(20) NOT NULL,
  `line_company` varchar(30) DEFAULT NULL,
  `line_type` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(15) DEFAULT NULL,
  `password` binary(32) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `first_name` varchar(25) DEFAULT NULL,
  `last_name` varchar(25) DEFAULT NULL,
  `gender` varchar(25) DEFAULT NULL,
  `birthDate` date DEFAULT NULL,
  `country_code` smallint(6) DEFAULT NULL,
  `phone_number` int(11) DEFAULT NULL,
  `country` varchar(25) DEFAULT NULL,
  `state` varchar(25) DEFAULT NULL,
  `city` varchar(25) DEFAULT NULL,
  `zip_code` varchar(10) DEFAULT NULL,
  `address1` varchar(40) DEFAULT NULL,
  `address2` varchar(40) DEFAULT NULL,
  `registerDate` datetime DEFAULT current_timestamp(),
  `params` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `first_name`, `last_name`, `gender`, `birthDate`, `country_code`, `phone_number`, `country`, `state`, `city`, `zip_code`, `address1`, `address2`, `registerDate`, `params`) VALUES
(21, 'test', 0x0123000000000000000000000000000000000000000000000000000000000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2023-12-14 11:21:19', NULL),
(23, 'alper', 0xf0fbdf664abbf1ca7292e68be9e38c147cfa5310cc952c35ec8748e9f6c95c01, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-14 22:32:49', NULL),
(24, 'test2', 0x8766b053c4d1064ca7c2a10a73fd3cdf42f7736b1f869151a1646c7e6c9e07f0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-16 06:49:39', NULL),
(25, 'test3', 0xfd3691fa6c5cbb664a0a13b9928ea66b313d84df24bcea5cea4501bad10d9fc6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-16 22:33:16', NULL);

-- --------------------------------------------------------

--
-- Structure for view `displayalltickets`
--
DROP TABLE IF EXISTS `displayalltickets`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `displayalltickets`  AS SELECT `t`.`ticket_id` AS `ticket_id`, `tt`.`ticket_type` AS `ticket_type`, `tl`.`line_company` AS `line_company` FROM ((`tickets` `t` join `ticket_types` `tt` on(`t`.`ticketType_id` = `tt`.`ticketType_id`)) join `transport_lines` `tl` on(`tt`.`city` = `tl`.`line_city`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`city_name`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`line_company`);

--
-- Indexes for table `line_tickets`
--
ALTER TABLE `line_tickets`
  ADD PRIMARY KEY (`line_id`,`ticket_type`),
  ADD KEY `ticket_type` (`ticket_type`);

--
-- Indexes for table `line_types`
--
ALTER TABLE `line_types`
  ADD PRIMARY KEY (`line_type`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `transaction_id` (`transaction_id`),
  ADD KEY `ticketType_id` (`ticketType_id`);

--
-- Indexes for table `ticket_types`
--
ALTER TABLE `ticket_types`
  ADD PRIMARY KEY (`ticketType_id`),
  ADD KEY `city` (`city`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `transport_lines`
--
ALTER TABLE `transport_lines`
  ADD PRIMARY KEY (`line_id`,`line_city`),
  ADD KEY `line_city` (`line_city`),
  ADD KEY `line_company` (`line_company`),
  ADD KEY `line_type` (`line_type`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ticket_types`
--
ALTER TABLE `ticket_types`
  MODIFY `ticketType_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `line_tickets`
--
ALTER TABLE `line_tickets`
  ADD CONSTRAINT `line_tickets_ibfk_1` FOREIGN KEY (`line_id`) REFERENCES `transport_lines` (`line_id`),
  ADD CONSTRAINT `line_tickets_ibfk_2` FOREIGN KEY (`ticket_type`) REFERENCES `ticket_types` (`ticketType_id`);

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`),
  ADD CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`ticketType_id`) REFERENCES `ticket_types` (`ticketType_id`);

--
-- Constraints for table `ticket_types`
--
ALTER TABLE `ticket_types`
  ADD CONSTRAINT `ticket_types_ibfk_1` FOREIGN KEY (`city`) REFERENCES `cities` (`city_name`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `transport_lines`
--
ALTER TABLE `transport_lines`
  ADD CONSTRAINT `transport_lines_ibfk_1` FOREIGN KEY (`line_city`) REFERENCES `cities` (`city_name`),
  ADD CONSTRAINT `transport_lines_ibfk_2` FOREIGN KEY (`line_company`) REFERENCES `companies` (`line_company`),
  ADD CONSTRAINT `transport_lines_ibfk_3` FOREIGN KEY (`line_type`) REFERENCES `line_types` (`line_type`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
