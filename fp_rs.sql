-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 21, 2024 at 07:24 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fp_rs`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `example_procedure` ()   BEGIN
    SELECT * FROM dokter;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `fp_penyakit_limit_6` ()   BEGIN
    SELECT * FROM penyakit limit 6;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `show_resep_by_pasien_and_dokter` (IN `pasien_id` VARCHAR(5), IN `dokter_id` VARCHAR(5))   BEGIN
    DECLARE resep_count INT;

    SELECT COUNT(*)
    INTO resep_count
    FROM resep
    WHERE id_pasien = pasien_id AND id_dokter = dokter_id;

    CASE
        WHEN resep_count > 0 THEN
            SELECT CONCAT( dokter_id, ' kepada pasien ', pasien_id, ' adalah: ', resep_count) AS result;
        ELSE
            SELECT 'Tidak ada resep yang diberikan oleh dokter kepada pasien dengan ID tersebut' AS result;
    END CASE;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_dokter` (`dokter_id` VARCHAR(5), `hari` VARCHAR(10)) RETURNS VARCHAR(30) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE dokter_name VARCHAR(30);

    SELECT d.nama
    INTO dokter_name
    FROM dokter d
    JOIN jadwal_dokter jd ON d.id_dokter = jd.id_dokter
    WHERE d.id_dokter = dokter_id AND jd.hari = hari;

    RETURN dokter_name;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `nama_dokter` () RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE dokter_names TEXT DEFAULT '';
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_name VARCHAR(30);

    -- Cursor untuk iterasi nama dokter
    DECLARE dokter_cursor CURSOR FOR 
    SELECT nama FROM dokter;

    -- Handler untuk akhir dari cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN dokter_cursor;

    read_loop: LOOP
        FETCH dokter_cursor INTO temp_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET dokter_names = CONCAT(dokter_names, temp_name, ', ');
    END LOOP;

    CLOSE dokter_cursor;

    -- Menghilangkan koma terakhir
    IF CHAR_LENGTH(dokter_names) > 0 THEN
        SET dokter_names = LEFT(dokter_names, CHAR_LENGTH(dokter_names) - 2);
    END IF;

    RETURN dokter_names;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dokter`
--

CREATE TABLE `dokter` (
  `id_dokter` varchar(5) NOT NULL,
  `nama` varchar(30) NOT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `alamat` varchar(30) DEFAULT NULL,
  `gaji` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dokter`
--

INSERT INTO `dokter` (`id_dokter`, `nama`, `gender`, `alamat`, `gaji`) VALUES
('D001', 'Slamet', 'L', 'Condongcatur', 10000000),
('D002', 'Wulan', 'P', 'Seturan', 12000000),
('D003', 'Udin', 'L', 'Babarsari', 11000000),
('D004', 'Rohmat', 'L', 'Depok', 13000000),
('D005', 'Panjul', 'L', 'Bantul', 9000000),
('D006', 'Fernando', 'L', 'Wonosari', 14000000),
('D007', 'Rusmin', 'L', 'Parangtritis', 11500000);

-- --------------------------------------------------------

--
-- Table structure for table `dokter_log`
--

CREATE TABLE `dokter_log` (
  `id_dokter` varchar(5) NOT NULL,
  `nama` varchar(30) NOT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `alamat` varchar(30) DEFAULT NULL,
  `gaji` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_dokter`
--

CREATE TABLE `jadwal_dokter` (
  `id_jadwal` varchar(5) NOT NULL,
  `hari` varchar(10) DEFAULT NULL,
  `shift` varchar(10) DEFAULT NULL,
  `id_dokter` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jadwal_dokter`
--

INSERT INTO `jadwal_dokter` (`id_jadwal`, `hari`, `shift`, `id_dokter`) VALUES
('J001', 'Senin', 'Pagi', 'D001'),
('J002', 'Selasa', 'Siang', 'D002'),
('J003', 'Rabu', 'Malam', 'D003'),
('J004', 'Kamis', 'Pagi', 'D004'),
('J005', 'Jumat', 'Siang', 'D005'),
('J006', 'Sabtu', 'Malam', 'D006'),
('J007', 'Minggu', 'Pagi', 'D007');

-- --------------------------------------------------------

--
-- Table structure for table `obat`
--

CREATE TABLE `obat` (
  `id_obat` varchar(5) NOT NULL,
  `obat` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `obat`
--

INSERT INTO `obat` (`id_obat`, `obat`) VALUES
('O001', 'Paracetamol'),
('O002', 'Ibuprofen'),
('O003', 'Metformin'),
('O004', 'Lisinopril'),
('O005', 'Albuterol'),
('O006', 'Remdesivir'),
('O007', 'Sumatriptan');

-- --------------------------------------------------------

--
-- Table structure for table `pasien`
--

CREATE TABLE `pasien` (
  `id_pasien` varchar(5) NOT NULL,
  `nama` varchar(30) NOT NULL,
  `tgl_lahir` datetime DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `alamat` varchar(30) DEFAULT NULL,
  `periksa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pasien`
--

INSERT INTO `pasien` (`id_pasien`, `nama`, `tgl_lahir`, `gender`, `alamat`, `periksa`) VALUES
('P001', 'Udin', '1990-01-01 00:00:00', 'L', 'Depok', 5),
('P002', 'Raul', '1985-05-05 00:00:00', 'L', 'Depok', 3),
('P003', 'Budi', '2000-10-10 00:00:00', 'L', 'Depok', 2),
('P004', 'Sinta', '1995-08-08 00:00:00', 'P', 'Bantul', 4),
('P005', 'Ricard', '1988-03-03 00:00:00', 'L', 'Bantul', 1),
('P006', 'Ronald', '1992-07-07 00:00:00', 'P', 'Gunungkidul', 6),
('P007', 'Steven', '1999-09-09 00:00:00', 'L', 'Gunungkidul', 7);

-- --------------------------------------------------------

--
-- Table structure for table `penyakit`
--

CREATE TABLE `penyakit` (
  `id_penyakit` varchar(5) NOT NULL,
  `penyakit` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `penyakit`
--

INSERT INTO `penyakit` (`id_penyakit`, `penyakit`) VALUES
('P001', 'Flu'),
('P002', 'Demam'),
('P003', 'Diabetes'),
('P004', 'Hipertensi'),
('P005', 'Asma'),
('P006', 'Hepatitis'),
('P007', 'Migraine');

-- --------------------------------------------------------

--
-- Table structure for table `resep`
--

CREATE TABLE `resep` (
  `id_resep` int(11) NOT NULL,
  `hari` varchar(10) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `id_pasien` varchar(5) DEFAULT NULL,
  `id_penyakit` varchar(5) DEFAULT NULL,
  `id_obat` varchar(5) DEFAULT NULL,
  `id_dokter` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resep`
--

INSERT INTO `resep` (`id_resep`, `hari`, `tanggal`, `id_pasien`, `id_penyakit`, `id_obat`, `id_dokter`) VALUES
(2, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002'),
(3, 'Rabu', '2024-07-23', 'P003', 'P003', 'O003', 'D003'),
(4, 'Kamis', '2024-07-24', 'P004', 'P004', 'O004', 'D004'),
(5, 'Jumat', '2024-07-25', 'P005', 'P005', 'O005', 'D005'),
(6, 'Sabtu', '2024-07-26', 'P006', 'P006', 'O006', 'D006'),
(7, 'Minggu', '2024-07-27', 'P007', 'P007', 'O007', 'D007'),
(12, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002'),
(20, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002'),
(21, 'Senin', '2024-07-21', 'P001', 'P001', 'O001', 'D001');

--
-- Triggers `resep`
--
DELIMITER $$
CREATE TRIGGER `after_delete_resep` AFTER DELETE ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('DELETE', OLD.id_resep, OLD.hari, OLD.tanggal, OLD.id_pasien, OLD.id_penyakit, OLD.id_obat, OLD.id_dokter);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_resep` AFTER INSERT ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('INSERT', NEW.id_resep, NEW.hari, NEW.tanggal, NEW.id_pasien, NEW.id_penyakit, NEW.id_obat, NEW.id_dokter);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_resep` AFTER UPDATE ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('UPDATE', NEW.id_resep, NEW.hari, NEW.tanggal, NEW.id_pasien, NEW.id_penyakit, NEW.id_obat, NEW.id_dokter);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_resep` BEFORE DELETE ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('DELETE', OLD.id_resep, OLD.hari, OLD.tanggal, OLD.id_pasien, OLD.id_penyakit, OLD.id_obat, OLD.id_dokter);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_resep` BEFORE INSERT ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('INSERT', NEW.id_resep, NEW.hari, NEW.tanggal, NEW.id_pasien, NEW.id_penyakit, NEW.id_obat, NEW.id_dokter);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_resep` BEFORE UPDATE ON `resep` FOR EACH ROW BEGIN
    INSERT INTO resep_log (operation_type, id_resep, hari, tanggal, id_pasien, id_penyakit, id_obat, id_dokter)
    VALUES ('UPDATE', OLD.id_resep, OLD.hari, OLD.tanggal, OLD.id_pasien, OLD.id_penyakit, OLD.id_obat, OLD.id_dokter);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `resep_log`
--

CREATE TABLE `resep_log` (
  `log_id` int(11) NOT NULL,
  `operation_type` varchar(10) DEFAULT NULL,
  `id_resep` int(11) DEFAULT NULL,
  `hari` varchar(10) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `id_pasien` varchar(5) DEFAULT NULL,
  `id_penyakit` varchar(5) DEFAULT NULL,
  `id_obat` varchar(5) DEFAULT NULL,
  `id_dokter` varchar(5) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resep_log`
--

INSERT INTO `resep_log` (`log_id`, `operation_type`, `id_resep`, `hari`, `tanggal`, `id_pasien`, `id_penyakit`, `id_obat`, `id_dokter`, `timestamp`) VALUES
(2, 'INSERT', 21, 'Senin', '2024-07-21', 'P001', 'P001', 'O001', 'D001', '2024-07-21 16:01:56'),
(3, 'INSERT', 21, 'Senin', '2024-07-21', 'P001', 'P001', 'O001', 'D001', '2024-07-21 16:01:56'),
(4, 'DELETE', 1, 'Senin', '2024-07-21', 'P001', 'P001', 'O001', 'D001', '2024-07-21 16:01:56'),
(5, 'DELETE', 1, 'Senin', '2024-07-21', 'P001', 'P001', 'O001', 'D001', '2024-07-21 16:01:56'),
(11, 'INSERT', 20, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002', '2024-07-21 16:37:42'),
(12, 'INSERT', 20, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002', '2024-07-21 16:37:42'),
(15, 'INSERT', 12, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002', '2024-07-21 16:44:27'),
(16, 'INSERT', 12, 'Selasa', '2024-07-22', 'P002', 'P002', 'O002', 'D002', '2024-07-21 16:44:27');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_horizontal`
-- (See below for the actual view)
--
CREATE TABLE `v_horizontal` (
`id_dokter` varchar(5)
,`nama_dokter` varchar(30)
,`gender_dokter` varchar(1)
,`alamat_dokter` varchar(30)
,`hari` varchar(10)
,`shift` varchar(10)
,`id_pasien` varchar(5)
,`nama_pasien` varchar(30)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_resep_dokter_obat`
-- (See below for the actual view)
--
CREATE TABLE `v_resep_dokter_obat` (
`id_resep` int(11)
,`hari` varchar(10)
,`tanggal` date
,`id_pasien` varchar(5)
,`id_penyakit` varchar(5)
,`id_obat` varchar(5)
,`id_dokter` varchar(5)
,`nama_dokter` varchar(30)
,`obat` varchar(30)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_resep_dokter_obat_check`
-- (See below for the actual view)
--
CREATE TABLE `v_resep_dokter_obat_check` (
`id_resep` int(11)
,`hari` varchar(10)
,`tanggal` date
,`id_pasien` varchar(5)
,`id_penyakit` varchar(5)
,`id_obat` varchar(5)
,`id_dokter` varchar(5)
,`nama_dokter` varchar(30)
,`obat` varchar(30)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_vertical`
-- (See below for the actual view)
--
CREATE TABLE `v_vertical` (
`id_pasien` varchar(5)
,`nama_pasien` varchar(30)
,`tgl_lahir` datetime
,`gender_pasien` varchar(1)
,`penyakit` varchar(30)
);

-- --------------------------------------------------------

--
-- Structure for view `v_horizontal`
--
DROP TABLE IF EXISTS `v_horizontal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_horizontal`  AS SELECT `d`.`id_dokter` AS `id_dokter`, `d`.`nama` AS `nama_dokter`, `d`.`gender` AS `gender_dokter`, `d`.`alamat` AS `alamat_dokter`, `j`.`hari` AS `hari`, `j`.`shift` AS `shift`, `p`.`id_pasien` AS `id_pasien`, `p`.`nama` AS `nama_pasien` FROM ((`dokter` `d` join `jadwal_dokter` `j` on(`d`.`id_dokter` = `j`.`id_dokter`)) join `pasien` `p` on(`p`.`periksa` = `d`.`id_dokter`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_resep_dokter_obat`
--
DROP TABLE IF EXISTS `v_resep_dokter_obat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_resep_dokter_obat`  AS SELECT `r`.`id_resep` AS `id_resep`, `r`.`hari` AS `hari`, `r`.`tanggal` AS `tanggal`, `r`.`id_pasien` AS `id_pasien`, `r`.`id_penyakit` AS `id_penyakit`, `r`.`id_obat` AS `id_obat`, `r`.`id_dokter` AS `id_dokter`, `d`.`nama` AS `nama_dokter`, `o`.`obat` AS `obat` FROM ((`resep` `r` join `dokter` `d` on(`r`.`id_dokter` = `d`.`id_dokter`)) join `obat` `o` on(`r`.`id_obat` = `o`.`id_obat`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_resep_dokter_obat_check`
--
DROP TABLE IF EXISTS `v_resep_dokter_obat_check`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_resep_dokter_obat_check`  AS SELECT `v_resep_dokter_obat`.`id_resep` AS `id_resep`, `v_resep_dokter_obat`.`hari` AS `hari`, `v_resep_dokter_obat`.`tanggal` AS `tanggal`, `v_resep_dokter_obat`.`id_pasien` AS `id_pasien`, `v_resep_dokter_obat`.`id_penyakit` AS `id_penyakit`, `v_resep_dokter_obat`.`id_obat` AS `id_obat`, `v_resep_dokter_obat`.`id_dokter` AS `id_dokter`, `v_resep_dokter_obat`.`nama_dokter` AS `nama_dokter`, `v_resep_dokter_obat`.`obat` AS `obat` FROM `v_resep_dokter_obat` WHERE `v_resep_dokter_obat`.`tanggal` > '2024-01-01' ;

-- --------------------------------------------------------

--
-- Structure for view `v_vertical`
--
DROP TABLE IF EXISTS `v_vertical`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_vertical`  AS SELECT `p`.`id_pasien` AS `id_pasien`, `p`.`nama` AS `nama_pasien`, `p`.`tgl_lahir` AS `tgl_lahir`, `p`.`gender` AS `gender_pasien`, `pe`.`penyakit` AS `penyakit` FROM (`pasien` `p` join `penyakit` `pe` on(`pe`.`id_penyakit` = `p`.`periksa`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `dokter`
--
ALTER TABLE `dokter`
  ADD PRIMARY KEY (`id_dokter`),
  ADD KEY `id_dokter` (`id_dokter`);

--
-- Indexes for table `dokter_log`
--
ALTER TABLE `dokter_log`
  ADD PRIMARY KEY (`id_dokter`,`nama`);

--
-- Indexes for table `jadwal_dokter`
--
ALTER TABLE `jadwal_dokter`
  ADD PRIMARY KEY (`id_jadwal`),
  ADD KEY `id_dokter` (`id_dokter`),
  ADD KEY `id_jadwal` (`id_jadwal`,`id_dokter`);

--
-- Indexes for table `obat`
--
ALTER TABLE `obat`
  ADD PRIMARY KEY (`id_obat`),
  ADD KEY `id_obat` (`id_obat`);

--
-- Indexes for table `pasien`
--
ALTER TABLE `pasien`
  ADD PRIMARY KEY (`id_pasien`),
  ADD KEY `id_pasien` (`id_pasien`,`tgl_lahir`),
  ADD KEY `idx_pasien_id_nama` (`id_pasien`,`nama`);

--
-- Indexes for table `penyakit`
--
ALTER TABLE `penyakit`
  ADD PRIMARY KEY (`id_penyakit`),
  ADD KEY `id_penyakit` (`id_penyakit`);

--
-- Indexes for table `resep`
--
ALTER TABLE `resep`
  ADD PRIMARY KEY (`id_resep`),
  ADD KEY `id_pasien` (`id_pasien`),
  ADD KEY `id_penyakit` (`id_penyakit`),
  ADD KEY `id_obat` (`id_obat`),
  ADD KEY `id_dokter` (`id_dokter`),
  ADD KEY `id_resep` (`id_resep`,`id_pasien`,`id_penyakit`,`id_obat`,`id_dokter`),
  ADD KEY `idx_resep_pasien_dokter` (`id_pasien`,`id_dokter`);

--
-- Indexes for table `resep_log`
--
ALTER TABLE `resep_log`
  ADD PRIMARY KEY (`log_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `resep_log`
--
ALTER TABLE `resep_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `jadwal_dokter`
--
ALTER TABLE `jadwal_dokter`
  ADD CONSTRAINT `jadwal_dokter_ibfk_1` FOREIGN KEY (`id_dokter`) REFERENCES `dokter` (`id_dokter`);

--
-- Constraints for table `resep`
--
ALTER TABLE `resep`
  ADD CONSTRAINT `resep_ibfk_1` FOREIGN KEY (`id_pasien`) REFERENCES `pasien` (`id_pasien`),
  ADD CONSTRAINT `resep_ibfk_2` FOREIGN KEY (`id_penyakit`) REFERENCES `penyakit` (`id_penyakit`),
  ADD CONSTRAINT `resep_ibfk_3` FOREIGN KEY (`id_obat`) REFERENCES `obat` (`id_obat`),
  ADD CONSTRAINT `resep_ibfk_4` FOREIGN KEY (`id_dokter`) REFERENCES `dokter` (`id_dokter`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
