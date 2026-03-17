CREATE DATABASE  IF NOT EXISTS `skillswap_campus` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `skillswap_campus`;
-- MySQL dump 10.13  Distrib 8.0.42, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: skillswap_campus
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '0d73e412-02ed-11f1-b537-b064e243a986:1-51';

--
-- Table structure for table `Activity_Log`
--

DROP TABLE IF EXISTS `Activity_Log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Activity_Log` (
  `Log_ID` int NOT NULL AUTO_INCREMENT,
  `Action_Type` varchar(100) NOT NULL,
  `Timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `User_ID` int NOT NULL,
  PRIMARY KEY (`Log_ID`),
  KEY `User_ID` (`User_ID`),
  CONSTRAINT `activity_log_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `Users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Activity_Log`
--

LOCK TABLES `Activity_Log` WRITE;
/*!40000 ALTER TABLE `Activity_Log` DISABLE KEYS */;
INSERT INTO `Activity_Log` VALUES (1,'User Login','2026-03-16 16:37:08',1),(2,'Profile Updated','2026-03-16 16:37:08',2),(3,'Skill Added','2026-03-16 16:37:08',3),(4,'Exchange Request Sent','2026-03-16 16:37:08',4),(5,'Exchange Accepted','2026-03-16 16:37:08',5),(6,'Exchange Completed','2026-03-16 16:37:08',6),(7,'Review Submitted','2026-03-16 16:37:08',7),(8,'Message Sent','2026-03-16 16:37:08',8),(9,'Notification Viewed','2026-03-16 16:37:08',9),(10,'User Logout','2026-03-16 16:37:08',10);
/*!40000 ALTER TABLE `Activity_Log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Admins`
--

DROP TABLE IF EXISTS `Admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Admins` (
  `User_ID` int NOT NULL,
  `Admin_Level` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`User_ID`),
  CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `Users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Admins`
--

LOCK TABLES `Admins` WRITE;
/*!40000 ALTER TABLE `Admins` DISABLE KEYS */;
INSERT INTO `Admins` VALUES (11,'Level 1'),(12,'Level 1'),(13,'Level 2'),(14,'Level 2'),(15,'Level 3'),(16,'Level 1'),(17,'Level 2'),(18,'Level 3'),(19,'Level 1'),(20,'Level 2');
/*!40000 ALTER TABLE `Admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Exchange_Requests`
--

DROP TABLE IF EXISTS `Exchange_Requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Exchange_Requests` (
  `Request_ID` int NOT NULL AUTO_INCREMENT,
  `Status` enum('Pending','Accepted','Rejected','In Progress','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `Preferred_Date` date DEFAULT NULL,
  `Preferred_Time` time DEFAULT NULL,
  `Created_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Sender_ID` int NOT NULL,
  `Receiver_ID` int NOT NULL,
  `Requested_Skill_ID` int NOT NULL,
  `Offered_Skill_ID` int NOT NULL,
  PRIMARY KEY (`Request_ID`),
  KEY `Sender_ID` (`Sender_ID`),
  KEY `Receiver_ID` (`Receiver_ID`),
  KEY `Requested_Skill_ID` (`Requested_Skill_ID`),
  KEY `Offered_Skill_ID` (`Offered_Skill_ID`),
  CONSTRAINT `exchange_requests_ibfk_1` FOREIGN KEY (`Sender_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `exchange_requests_ibfk_2` FOREIGN KEY (`Receiver_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `exchange_requests_ibfk_3` FOREIGN KEY (`Requested_Skill_ID`) REFERENCES `Skills` (`Skill_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `exchange_requests_ibfk_4` FOREIGN KEY (`Offered_Skill_ID`) REFERENCES `Skills` (`Skill_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Exchange_Requests`
--

LOCK TABLES `Exchange_Requests` WRITE;
/*!40000 ALTER TABLE `Exchange_Requests` DISABLE KEYS */;
INSERT INTO `Exchange_Requests` VALUES (1,'Pending','2026-04-01','15:00:00','2026-03-16 16:36:14',1,4,2,1),(2,'Accepted','2026-04-02','13:00:00','2026-03-16 16:36:14',2,5,3,10),(3,'Completed','2026-04-03','11:00:00','2026-03-16 16:36:14',3,6,5,4),(4,'Pending','2026-04-04','16:00:00','2026-03-16 16:36:14',4,7,6,2),(5,'Accepted','2026-04-05','10:00:00','2026-03-16 16:36:14',5,8,7,3),(6,'Completed','2026-04-06','12:00:00','2026-03-16 16:36:14',6,9,8,5),(7,'Pending','2026-04-07','14:00:00','2026-03-16 16:36:14',7,10,9,6),(8,'Rejected','2026-04-08','15:30:00','2026-03-16 16:36:14',8,1,1,7),(9,'Accepted','2026-04-09','13:30:00','2026-03-16 16:36:14',9,2,10,8),(10,'Completed','2026-04-10','11:30:00','2026-03-16 16:36:14',10,3,4,9);
/*!40000 ALTER TABLE `Exchange_Requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Messages`
--

DROP TABLE IF EXISTS `Messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Messages` (
  `Message_ID` int NOT NULL AUTO_INCREMENT,
  `Content` text NOT NULL,
  `Timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Sender_ID` int NOT NULL,
  `Receiver_ID` int NOT NULL,
  PRIMARY KEY (`Message_ID`),
  KEY `Sender_ID` (`Sender_ID`),
  KEY `Receiver_ID` (`Receiver_ID`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`Sender_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`Receiver_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Messages`
--

LOCK TABLES `Messages` WRITE;
/*!40000 ALTER TABLE `Messages` DISABLE KEYS */;
INSERT INTO `Messages` VALUES (1,'Hi, are you available tomorrow?','2026-03-16 16:36:43',1,4),(2,'Yes, what time works for you?','2026-03-16 16:36:43',4,1),(3,'Let’s meet at the library.','2026-03-16 16:36:43',2,5),(4,'Sounds good!','2026-03-16 16:36:43',5,2),(5,'Can we reschedule?','2026-03-16 16:36:43',3,6),(6,'Sure, how about Friday?','2026-03-16 16:36:43',6,3),(7,'Thanks for the lesson!','2026-03-16 16:36:43',7,10),(8,'No problem!','2026-03-16 16:36:43',10,7),(9,'I sent a request for tutoring.','2026-03-16 16:36:43',8,1),(10,'Got it, I will review it.','2026-03-16 16:36:43',1,8);
/*!40000 ALTER TABLE `Messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notifications`
--

DROP TABLE IF EXISTS `Notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notifications` (
  `Notification_ID` int NOT NULL AUTO_INCREMENT,
  `Message` varchar(255) NOT NULL,
  `Status` enum('Read','Unread') NOT NULL DEFAULT 'Unread',
  `Created_At` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `User_ID` int NOT NULL,
  PRIMARY KEY (`Notification_ID`),
  KEY `User_ID` (`User_ID`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `Users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notifications`
--

LOCK TABLES `Notifications` WRITE;
/*!40000 ALTER TABLE `Notifications` DISABLE KEYS */;
INSERT INTO `Notifications` VALUES (1,'Your exchange request was accepted','Unread','2026-03-16 16:36:55',1),(2,'You received a new message','Unread','2026-03-16 16:36:55',2),(3,'Your exchange request was completed','Read','2026-03-16 16:36:55',3),(4,'You received a review','Unread','2026-03-16 16:36:55',4),(5,'Your profile was updated','Read','2026-03-16 16:36:55',5),(6,'A new skill request was sent','Unread','2026-03-16 16:36:55',6),(7,'Reminder for tomorrow’s exchange','Unread','2026-03-16 16:36:55',7),(8,'You received a rating','Read','2026-03-16 16:36:55',8),(9,'Exchange request rejected','Unread','2026-03-16 16:36:55',9),(10,'Admin updated system guidelines','Read','2026-03-16 16:36:55',10);
/*!40000 ALTER TABLE `Notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Reviews`
--

DROP TABLE IF EXISTS `Reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Reviews` (
  `Review_ID` int NOT NULL AUTO_INCREMENT,
  `Rating` int NOT NULL,
  `Comment` text,
  `Date_Posted` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Request_ID` int NOT NULL,
  `Reviewer_ID` int NOT NULL,
  `Reviewee_ID` int NOT NULL,
  PRIMARY KEY (`Review_ID`),
  UNIQUE KEY `Request_ID` (`Request_ID`),
  KEY `Reviewer_ID` (`Reviewer_ID`),
  KEY `Reviewee_ID` (`Reviewee_ID`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`Request_ID`) REFERENCES `Exchange_Requests` (`Request_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`Reviewer_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`Reviewee_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Reviews`
--

LOCK TABLES `Reviews` WRITE;
/*!40000 ALTER TABLE `Reviews` DISABLE KEYS */;
INSERT INTO `Reviews` VALUES (1,5,'Great tutoring session!','2026-03-16 16:36:26',3,3,6),(2,4,'Very helpful explanation.','2026-03-16 16:36:26',6,6,9),(3,5,'Learned a lot about design.','2026-03-16 16:36:26',10,10,3),(4,4,'Good communication.','2026-03-16 16:36:26',2,2,5),(5,5,'Excellent teaching.','2026-03-16 16:36:26',5,5,8),(6,4,'Very patient teacher.','2026-03-16 16:36:26',7,7,10),(7,3,'Helpful but rushed.','2026-03-16 16:36:26',9,9,2),(8,5,'Highly recommended!','2026-03-16 16:36:26',4,4,7),(9,4,'Good exchange session.','2026-03-16 16:36:26',8,8,1),(10,5,'Very clear explanations.','2026-03-16 16:36:26',1,1,4);
/*!40000 ALTER TABLE `Reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Skill_Categories`
--

DROP TABLE IF EXISTS `Skill_Categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Skill_Categories` (
  `Category_ID` int NOT NULL AUTO_INCREMENT,
  `Category_Name` varchar(100) NOT NULL,
  PRIMARY KEY (`Category_ID`),
  UNIQUE KEY `Category_Name` (`Category_Name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Skill_Categories`
--

LOCK TABLES `Skill_Categories` WRITE;
/*!40000 ALTER TABLE `Skill_Categories` DISABLE KEYS */;
INSERT INTO `Skill_Categories` VALUES (1,'Academic'),(3,'Data Science'),(4,'Design'),(7,'Fitness'),(6,'Language'),(5,'Music'),(2,'Programming'),(8,'Sports'),(10,'Video Editing'),(9,'Writing');
/*!40000 ALTER TABLE `Skill_Categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Skills`
--

DROP TABLE IF EXISTS `Skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Skills` (
  `Skill_ID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(100) NOT NULL,
  `Description` text,
  `Experience_Level` enum('Beginner','Intermediate','Advanced') NOT NULL,
  `Status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `User_ID` int NOT NULL,
  `Category_ID` int NOT NULL,
  PRIMARY KEY (`Skill_ID`),
  KEY `User_ID` (`User_ID`),
  KEY `Category_ID` (`Category_ID`),
  CONSTRAINT `skills_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `Students` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `skills_ibfk_2` FOREIGN KEY (`Category_ID`) REFERENCES `Skill_Categories` (`Category_ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Skills`
--

LOCK TABLES `Skills` WRITE;
/*!40000 ALTER TABLE `Skills` DISABLE KEYS */;
INSERT INTO `Skills` VALUES (1,'Python Programming','Teach Python basics','Intermediate','Active',1,2),(2,'Calculus Tutoring','Help with calculus homework','Advanced','Active',4,1),(3,'Photoshop Basics','Learn photo editing','Beginner','Active',5,4),(4,'Excel Skills','Learn spreadsheets','Intermediate','Active',3,1),(5,'Public Speaking','Improve presentation skills','Advanced','Active',6,8),(6,'Physics Lab Help','Understand physics experiments','Intermediate','Active',7,1),(7,'Biology Tutoring','Help with biology concepts','Advanced','Active',8,1),(8,'Essay Writing','Improve writing skills','Intermediate','Active',9,9),(9,'CAD Design','Learn engineering drawing','Intermediate','Active',10,4),(10,'Java Programming','Object-oriented programming','Advanced','Active',2,2);
/*!40000 ALTER TABLE `Skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Students`
--

DROP TABLE IF EXISTS `Students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Students` (
  `User_ID` int NOT NULL,
  `Bio` text,
  `Profile_Picture` varchar(255) DEFAULT NULL,
  `Availability_Schedule` varchar(255) DEFAULT NULL,
  `Credit_Balance` int DEFAULT '0',
  PRIMARY KEY (`User_ID`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `Users` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Students`
--

LOCK TABLES `Students` WRITE;
/*!40000 ALTER TABLE `Students` DISABLE KEYS */;
INSERT INTO `Students` VALUES (1,'CS student who tutors programming and math.','alison.jpg','Mon/Wed 2PM-5PM',10),(2,'Enjoys web development and teaching Java.','dhruhi.jpg','Tue/Thu 1PM-4PM',8),(3,'Data science student who likes Excel and Python.','pranavi.jpg','Mon/Fri 10AM-1PM',12),(4,'Math major who offers calculus help.','kevin.jpg','Wed/Fri 3PM-6PM',6),(5,'Designer focused on UI/UX and Photoshop.','sofia.jpg','Tue/Thu 5PM-8PM',9),(6,'Business student with public speaking skills.','daniel.jpg','Mon/Wed 11AM-2PM',7),(7,'Physics major who can teach lab skills.','emily.jpg','Fri 1PM-5PM',5),(8,'Biology student who offers science tutoring.','ryan.jpg','Tue 9AM-12PM',11),(9,'English major who helps with essays.','mia.jpg','Thu/Fri 2PM-6PM',10),(10,'Engineering student who teaches CAD basics.','noah.jpg','Sat 10AM-2PM',4);
/*!40000 ALTER TABLE `Students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `User_ID` int NOT NULL AUTO_INCREMENT,
  `Full_Name` varchar(100) NOT NULL,
  `University_Email` varchar(100) NOT NULL,
  `Password_Hash` varchar(255) NOT NULL,
  `Major` varchar(100) DEFAULT NULL,
  `Role` enum('Student','Admin') NOT NULL,
  `Date_Created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`User_ID`),
  UNIQUE KEY `University_Email` (`University_Email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,'Alison Lau','alison.lau@sjsu.edu','hash1','Computer Science','Student','2026-03-16 16:30:13'),(2,'Dhruhi Sheth','dhruhidharmesh.sheth@sjsu.edu','hash2','Software Engineering','Student','2026-03-16 16:30:13'),(3,'Pranavi Immanni','pranavi.immanni@sjsu.edu','hash3','Data Science','Student','2026-03-16 16:30:13'),(4,'Kevin Tran','kevin.tran@sjsu.edu','hash4','Mathematics','Student','2026-03-16 16:30:13'),(5,'Sofia Martinez','sofia.martinez@sjsu.edu','hash5','Graphic Design','Student','2026-03-16 16:30:13'),(6,'Daniel Kim','daniel.kim@sjsu.edu','hash6','Business','Student','2026-03-16 16:30:13'),(7,'Emily Chen','emily.chen@sjsu.edu','hash7','Physics','Student','2026-03-16 16:30:13'),(8,'Ryan Patel','ryan.patel@sjsu.edu','hash8','Biology','Student','2026-03-16 16:30:13'),(9,'Mia Gonzalez','mia.gonzalez@sjsu.edu','hash9','English','Student','2026-03-16 16:30:13'),(10,'Noah Singh','noah.singh@sjsu.edu','hash10','Mechanical Engineering','Student','2026-03-16 16:30:13'),(11,'Admin One','admin1@sjsu.edu','adminhash1','Administration','Admin','2026-03-16 16:30:13'),(12,'Admin Two','admin2@sjsu.edu','adminhash2','Administration','Admin','2026-03-16 16:30:13'),(13,'Admin Three','admin3@sjsu.edu','adminhash3','Administration','Admin','2026-03-16 16:30:13'),(14,'Admin Four','admin4@sjsu.edu','adminhash4','Administration','Admin','2026-03-16 16:30:13'),(15,'Admin Five','admin5@sjsu.edu','adminhash5','Administration','Admin','2026-03-16 16:30:13'),(16,'Admin Six','admin6@sjsu.edu','adminhash6','Administration','Admin','2026-03-16 16:30:13'),(17,'Admin Seven','admin7@sjsu.edu','adminhash7','Administration','Admin','2026-03-16 16:30:13'),(18,'Admin Eight','admin8@sjsu.edu','adminhash8','Administration','Admin','2026-03-16 16:30:13'),(19,'Admin Nine','admin9@sjsu.edu','adminhash9','Administration','Admin','2026-03-16 16:30:13'),(20,'Admin Ten','admin10@sjsu.edu','adminhash10','Administration','Admin','2026-03-16 16:30:13');
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-17 11:07:29
