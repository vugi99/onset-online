-- --------------------------------------------------------
-- Hôte:                         127.0.0.1
-- Version du serveur:           10.5.4-MariaDB - mariadb.org binary distribution
-- SE du serveur:                Win64
-- HeidiSQL Version:             11.2.0.6228
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Listage de la structure de la base pour online
CREATE DATABASE IF NOT EXISTS `online` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `online`;

-- Listage de la structure de la table online. accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `accountid` int(11) NOT NULL AUTO_INCREMENT,
  `steam_id` varchar(255) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `bank_cash` int(11) NOT NULL DEFAULT 0,
  `cash` int(11) NOT NULL DEFAULT 0,
  `create_chara` int(11) NOT NULL DEFAULT 1,
  `clothes` text COLLATE utf8mb4_bin DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `xp` int(11) NOT NULL DEFAULT 0,
  `is_banned` int(11) NOT NULL DEFAULT 0,
  `garages` text COLLATE utf8mb4_bin DEFAULT NULL,
  `weapons` text COLLATE utf8mb4_bin DEFAULT NULL,
  `animations` text COLLATE utf8mb4_bin DEFAULT NULL,
  `energy_bars` int(11) NOT NULL DEFAULT 0,
  `criminal_bonus` int(11) NOT NULL DEFAULT 0,
  `special_vehicles` text COLLATE utf8mb4_bin DEFAULT NULL,
  `playtime` int(11) unsigned NOT NULL DEFAULT 0,
  `friends` text COLLATE utf8mb4_bin DEFAULT NULL,
  `friends_settings` text COLLATE utf8mb4_bin DEFAULT NULL,
  `friends_requests` text COLLATE utf8mb4_bin DEFAULT NULL,
  `houses` text COLLATE utf8mb4_bin DEFAULT NULL,
  `hat` int(11) NOT NULL DEFAULT 0,
  `heist_phase` int(11) NOT NULL DEFAULT 0,
  `cqb_record` text COLLATE utf8mb4_bin DEFAULT NULL,
  `bunkers` text COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`accountid`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Les données exportées n'étaient pas sélectionnées.

-- Listage de la structure de la table online. cqb_records
CREATE TABLE IF NOT EXISTS `cqb_records` (
  `recordid` int(11) NOT NULL AUTO_INCREMENT,
  `record` text COLLATE utf8mb4_bin DEFAULT NULL,
  `steamid` varchar(255) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `name` tinytext COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`recordid`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Les données exportées n'étaient pas sélectionnées.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
