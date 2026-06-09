-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Aug 31, 2025 at 04:24 PM
-- Server version: 10.11.10-MariaDB
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u214573487_ai_call_center`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `role` varchar(999) DEFAULT 'admin',
  `email` varchar(999) DEFAULT NULL,
  `password` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `uid`, `role`, `email`, `password`, `createdAt`) VALUES
(1, 'XhbfYkIAC1bYGhUodfJppmRCEUyGQJCZ', 'admin', 'admin@admin.com', '$2b$10$8a0sqP3jLvUYYNohQv/5NuN1QWZBqd1INTSbt54XXfi49oQNVWNXu', '2024-09-11 14:33:26');

-- --------------------------------------------------------

--
-- Table structure for table `agents`
--

CREATE TABLE `agents` (
  `id` int(11) NOT NULL,
  `owner_uid` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `role` varchar(999) DEFAULT 'agent',
  `email` varchar(999) DEFAULT NULL,
  `password` varchar(999) DEFAULT NULL,
  `name` varchar(999) DEFAULT NULL,
  `mobile` varchar(999) DEFAULT NULL,
  `comments` longtext DEFAULT NULL,
  `call_force` longtext DEFAULT NULL,
  `is_active` int(1) DEFAULT 1,
  `createdAt` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `agents`
--

INSERT INTO `agents` (`id`, `owner_uid`, `uid`, `role`, `email`, `password`, `name`, `mobile`, `comments`, `call_force`, `is_active`, `createdAt`) VALUES
(5, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'fZCuuZWqSHMdyoATlGSBLJGsNMzYRRoE', 'agent', 'agent@agent.com', '$2b$10$nHUGNlv3jhJlp5jkQWymg.OQDpmrqIsQGNKw/Qvz3U2YOu3aeccOS', 'Nina', '99989999898', 'some comments', '{\"id\":8,\"uid\":\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\",\"agent\":null,\"title\":\"test\",\"short_des\":\"complete it boi\",\"task_id\":\"Q2LGNj\",\"device\":\"{\\\"id\\\":7,\\\"device_id\\\":\\\"viWiz\\\",\\\"uid\\\":\\\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\\\",\\\"title\\\":\\\"Device A\\\",\\\"sid\\\":\\\"AC8f8d8160cff27026fcf115390af19f07\\\",\\\"token\\\":\\\"4b91378bd9de61314e4e5f1c2c4874bf\\\",\\\"api_key\\\":\\\"SKcfddbe60d49895bca5c5b367041c0a46\\\",\\\"api_secret\\\":\\\"OXnO4tfoGUCcBKGujfEIiTVIjfptjR3s\\\",\\\"outgoing_app_sid\\\":\\\"APd2a82df4e365b2176ba248012b67a2a2\\\",\\\"number\\\":\\\"19787170755\\\",\\\"connected_id\\\":\\\"3Ugy8\\\",\\\"other\\\":null,\\\"ivr\\\":\\\"{\\\\\\\"active\\\\\\\":true,\\\\\\\"flow\\\\\\\":{\\\\\\\"id\\\\\\\":55,\\\\\\\"uid\\\\\\\":\\\\\\\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\\\\\\\",\\\\\\\"flow_id\\\\\\\":\\\\\\\"ZRbNzN\\\\\\\",\\\\\\\"title\\\\\\\":\\\\\\\"Ai Call\\\\\\\",\\\\\\\"for_incoming\\\\\\\":1,\\\\\\\"createdAt\\\\\\\":\\\\\\\"2025-02-28T02:29:38.000Z\\\\\\\",\\\\\\\"label\\\\\\\":\\\\\\\"Ai Call\\\\\\\"}}\\\",\\\"ivr_out\\\":\\\"{\\\\\\\"active\\\\\\\":false,\\\\\\\"flow\\\\\\\":{\\\\\\\"id\\\\\\\":53,\\\\\\\"uid\\\\\\\":\\\\\\\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\\\\\\\",\\\\\\\"flow_id\\\\\\\":\\\\\\\"wFMnuI\\\\\\\",\\\\\\\"title\\\\\\\":\\\\\\\"Testing flow\\\\\\\",\\\\\\\"for_incoming\\\\\\\":1,\\\\\\\"createdAt\\\\\\\":\\\\\\\"2024-11-09T03:36:08.000Z\\\\\\\",\\\\\\\"label\\\\\\\":\\\\\\\"Testing flow\\\\\\\"}}\\\",\\\"ivr_dial\\\":\\\"{\\\\\\\"active\\\\\\\":false,\\\\\\\"flow\\\\\\\":{}}\\\",\\\"createdAt\\\":\\\"2024-11-15T01:46:53.000Z\\\"}\",\"status\":\"INITIATED\",\"createdAt\":\"2025-03-24T03:06:03.000Z\",\"label\":\"test\"}', 1, '2024-10-25 10:35:06');

-- --------------------------------------------------------

--
-- Table structure for table `agent_incoming`
--

CREATE TABLE `agent_incoming` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `sid` varchar(999) DEFAULT NULL,
  `owner_uid` varchar(999) DEFAULT NULL,
  `call_from` varchar(999) DEFAULT NULL,
  `call_to` varchar(999) DEFAULT NULL,
  `device` longtext DEFAULT NULL,
  `agent` longtext DEFAULT NULL,
  `duration` varchar(999) DEFAULT NULL,
  `agent_comments` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_key`
--

CREATE TABLE `ai_key` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `key_type` varchar(999) DEFAULT NULL COMMENT 'openai or gemini',
  `data` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `beta_call_log`
--

CREATE TABLE `beta_call_log` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `sid` varchar(999) DEFAULT NULL,
  `other` longtext DEFAULT NULL,
  `source` varchar(999) DEFAULT NULL,
  `flow_id` varchar(999) DEFAULT NULL,
  `device_id` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `beta_campaign`
--

CREATE TABLE `beta_campaign` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) NOT NULL,
  `campaign_id` varchar(999) NOT NULL,
  `title` varchar(999) NOT NULL,
  `phonebook_id` varchar(999) NOT NULL,
  `device_id` varchar(999) NOT NULL,
  `status` varchar(999) DEFAULT 'PENDING',
  `total_contacts` int(11) DEFAULT 0,
  `completed_contacts` int(11) DEFAULT 0,
  `createdAt` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `beta_campaign`
--

INSERT INTO `beta_campaign` (`id`, `uid`, `campaign_id`, `title`, `phonebook_id`, `device_id`, `status`, `total_contacts`, `completed_contacts`, `createdAt`) VALUES
(3, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'DoFlHRcq', 'testing', 'xpLyA', 'viWiz', 'COMPLETED', 2, 2, '2025-08-20 10:20:27'),
(4, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'sNDsgsC4', 'agina', 'xpLyA', 'viWiz', 'COMPLETED', 1, 1, '2025-08-20 14:01:58');

-- --------------------------------------------------------

--
-- Table structure for table `beta_campaign_log`
--

CREATE TABLE `beta_campaign_log` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) NOT NULL,
  `campaign_id` varchar(999) NOT NULL,
  `contact_mobile` varchar(999) NOT NULL,
  `twilio_sid` varchar(999) DEFAULT NULL,
  `status` varchar(999) DEFAULT 'INITIATED',
  `duration` varchar(999) DEFAULT NULL,
  `error` longtext DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `beta_campaign_log`
--

INSERT INTO `beta_campaign_log` (`id`, `uid`, `campaign_id`, `contact_mobile`, `twilio_sid`, `status`, `duration`, `error`, `createdAt`) VALUES
(15, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'wbBainqO', '918430088300', 'CA8f71be2cc1b990cdaf82282267a849cf', 'NO-ANSWER', '00:00:00', NULL, '2025-08-20 10:04:05'),
(16, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'wbBainqO', '918430088300', 'CAc8b221bbceff88bf263b8e8dd20e4060', 'COMPLETED', '00:36:00', NULL, '2025-08-20 10:04:10'),
(17, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'DoFlHRcq', '918430088300', 'CA41e8a1f7b1c8a9f25faefecbe53fb965', 'NO-ANSWER', '00:00:00', NULL, '2025-08-20 10:20:32'),
(18, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'DoFlHRcq', '918430088300', 'CA179b4899efe70fb2e4d12c25cc8ab226', 'COMPLETED', '00:35:00', NULL, '2025-08-20 10:20:36'),
(19, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'sNDsgsC4', '918430088300', 'CA9a234b9d208ab2ba6f110968ba106a5e', 'COMPLETED', '00:16:00', NULL, '2025-08-20 14:02:02');

-- --------------------------------------------------------

--
-- Table structure for table `beta_flows`
--

CREATE TABLE `beta_flows` (
  `id` int(11) NOT NULL,
  `is_active` int(11) DEFAULT 1,
  `uid` varchar(999) DEFAULT NULL,
  `flow_id` varchar(999) DEFAULT NULL,
  `source` varchar(999) DEFAULT NULL,
  `name` varchar(999) DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `call_campaign`
--

CREATE TABLE `call_campaign` (
  `id` int(11) NOT NULL,
  `campaign_id` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `device_id` longtext DEFAULT NULL,
  `phonebook` longtext DEFAULT NULL,
  `status` varchar(999) DEFAULT NULL,
  `schedule` datetime DEFAULT NULL,
  `active` int(1) DEFAULT 1,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `call_campaign_log`
--

CREATE TABLE `call_campaign_log` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `broadcast_id` varchar(999) DEFAULT NULL,
  `device` longtext DEFAULT NULL,
  `twilio_sid` varchar(999) DEFAULT NULL,
  `call_to` varchar(999) DEFAULT NULL,
  `call_from` varchar(999) DEFAULT NULL,
  `call_duration` varchar(999) DEFAULT NULL,
  `err` longtext DEFAULT NULL,
  `variables` longtext DEFAULT NULL,
  `status` varchar(999) NOT NULL DEFAULT 'INITIATED',
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `call_force_log`
--

CREATE TABLE `call_force_log` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `agent` varchar(999) DEFAULT NULL,
  `task_id` varchar(999) DEFAULT NULL,
  `call_from` varchar(999) DEFAULT NULL,
  `contact_json` longtext DEFAULT NULL,
  `call_to` varchar(999) DEFAULT NULL,
  `agent_comments` longtext DEFAULT NULL,
  `call_duration` varchar(999) DEFAULT NULL,
  `status` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `sid` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `call_force_log`
--

INSERT INTO `call_force_log` (`id`, `uid`, `agent`, `task_id`, `call_from`, `contact_json`, `call_to`, `agent_comments`, `call_duration`, `status`, `createdAt`, `sid`) VALUES
(15, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', NULL, 'Q2LGNj', '+19787170755', '{\"id\":6,\"uid\":\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\",\"phonebook_id\":\"YhD2q\",\"phonebook_name\":\"Customers\",\"name\":\"Codeyon\",\"mobile\":\"19782481662\",\"var1\":null,\"var2\":null,\"var3\":null,\"var4\":null,\"var5\":null,\"createdAt\":\"2024-10-19T03:30:06.000Z\"}', '+19782481662', NULL, NULL, 'INITIATED', '2025-03-24 08:36:03', 'CAfedfcf7fb09811d63b5b791e4230959a'),
(16, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', NULL, 'Q2LGNj', '+19787170755', '{\"id\":7,\"uid\":\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\",\"phonebook_id\":\"YhD2q\",\"phonebook_name\":\"Customers\",\"name\":\"Codeyon with var\",\"mobile\":\"19782481662\",\"var1\":\"one\",\"var2\":\"two\",\"var3\":\"three\",\"var4\":\"four\",\"var5\":\"five\",\"createdAt\":\"2024-10-19T03:30:36.000Z\"}', '+19782481662', NULL, NULL, 'INITIATED', '2025-03-24 08:36:03', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `call_force_task`
--

CREATE TABLE `call_force_task` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `agent` longtext DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `short_des` longtext DEFAULT NULL,
  `task_id` varchar(999) DEFAULT NULL,
  `device` longtext DEFAULT NULL,
  `status` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `call_force_task`
--

INSERT INTO `call_force_task` (`id`, `uid`, `agent`, `title`, `short_des`, `task_id`, `device`, `status`, `createdAt`) VALUES
(8, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', NULL, 'test', 'complete it boi', 'Q2LGNj', '{\"id\":7,\"device_id\":\"viWiz\",\"uid\":\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\",\"title\":\"Device A\",\"sid\":\"AC8f8d8160cff27026fcf115390af19f07\",\"token\":\"4b91378bd9de61314e4e5f1c2c4874bf\",\"api_key\":\"SKcfddbe60d49895bca5c5b367041c0a46\",\"api_secret\":\"OXnO4tfoGUCcBKGujfEIiTVIjfptjR3s\",\"outgoing_app_sid\":\"APd2a82df4e365b2176ba248012b67a2a2\",\"number\":\"19787170755\",\"connected_id\":\"3Ugy8\",\"other\":null,\"ivr\":\"{\\\"active\\\":true,\\\"flow\\\":{\\\"id\\\":55,\\\"uid\\\":\\\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\\\",\\\"flow_id\\\":\\\"ZRbNzN\\\",\\\"title\\\":\\\"Ai Call\\\",\\\"for_incoming\\\":1,\\\"createdAt\\\":\\\"2025-02-28T02:29:38.000Z\\\",\\\"label\\\":\\\"Ai Call\\\"}}\",\"ivr_out\":\"{\\\"active\\\":false,\\\"flow\\\":{\\\"id\\\":53,\\\"uid\\\":\\\"OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ\\\",\\\"flow_id\\\":\\\"wFMnuI\\\",\\\"title\\\":\\\"Testing flow\\\",\\\"for_incoming\\\":1,\\\"createdAt\\\":\\\"2024-11-09T03:36:08.000Z\\\",\\\"label\\\":\\\"Testing flow\\\"}}\",\"ivr_dial\":\"{\\\"active\\\":false,\\\"flow\\\":{}}\",\"createdAt\":\"2024-11-15T01:46:53.000Z\"}', 'INITIATED', '2025-03-24 08:36:03');

-- --------------------------------------------------------

--
-- Table structure for table `call_log`
--

CREATE TABLE `call_log` (
  `id` int(11) NOT NULL,
  `device_id` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `call_id` varchar(999) DEFAULT NULL,
  `mobile_to` varchar(999) DEFAULT NULL,
  `mobile_from` varchar(999) DEFAULT NULL,
  `status` varchar(999) DEFAULT NULL,
  `call_duration` varchar(999) DEFAULT NULL,
  `route` varchar(999) DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

CREATE TABLE `contact` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `phonebook_id` varchar(999) DEFAULT NULL,
  `phonebook_name` varchar(999) DEFAULT NULL,
  `name` varchar(999) DEFAULT NULL,
  `mobile` varchar(999) DEFAULT NULL,
  `var1` longtext DEFAULT NULL,
  `var2` longtext DEFAULT NULL,
  `var3` longtext DEFAULT NULL,
  `var4` longtext DEFAULT NULL,
  `var5` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contact`
--

INSERT INTO `contact` (`id`, `uid`, `phonebook_id`, `phonebook_name`, `name`, `mobile`, `var1`, `var2`, `var3`, `var4`, `var5`, `createdAt`) VALUES
(9, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'xpLyA', 'codeyon', 'mine', '919690309316', 'one', 'two', 'three', 'four', 'five', '2025-08-20 09:22:27');

-- --------------------------------------------------------

--
-- Table structure for table `contact_form`
--

CREATE TABLE `contact_form` (
  `id` int(11) NOT NULL,
  `email` varchar(999) DEFAULT NULL,
  `name` varchar(999) DEFAULT NULL,
  `mobile` varchar(999) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contact_form`
--

INSERT INTO `contact_form` (`id`, `email`, `name`, `mobile`, `content`, `createdAt`) VALUES
(1, 'email@gmail.com', 'John do', '+91999999999', 'hello, what are the charges', '2024-02-28 07:57:12');

-- --------------------------------------------------------

--
-- Table structure for table `device`
--

CREATE TABLE `device` (
  `id` int(11) NOT NULL,
  `device_id` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `sid` varchar(999) DEFAULT NULL,
  `token` varchar(999) DEFAULT NULL,
  `api_key` varchar(999) DEFAULT NULL,
  `api_secret` varchar(999) DEFAULT NULL,
  `outgoing_app_sid` varchar(999) DEFAULT NULL,
  `number` varchar(999) DEFAULT NULL,
  `connected_id` varchar(999) DEFAULT NULL,
  `other` longtext DEFAULT NULL,
  `ivr` longtext DEFAULT NULL,
  `ivr_out` longtext DEFAULT NULL,
  `ivr_dial` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `voice_agent` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faq`
--

CREATE TABLE `faq` (
  `id` int(11) NOT NULL,
  `question` longtext DEFAULT NULL,
  `answer` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `faq`
--

INSERT INTO `faq` (`id`, `question`, `answer`, `createdAt`) VALUES
(9, 'What features does Sonivo offer for call center management?', 'Sonivo includes a range of powerful features, including SIP integration, a call dialer, an AI-powered call assistant, a drag-and-drop call flow builder, and real-time analytics to help you manage and optimize your call center operations.', '2024-11-08 13:31:41'),
(10, 'How does the AI call assistant work?', 'The AI call assistant uses natural language processing to understand and respond to customer inquiries in real time. It handles routine questions, freeing up agents for complex interactions and improving response times.', '2024-11-08 13:31:50'),
(11, 'Can I customize call flows for different scenarios?', 'Yes! Sonivo’s call flow builder allows you to create and customize call paths based on specific needs. It’s designed as a drag-and-drop tool, making it easy to build, test, and adjust call flows for optimal customer journeys.', '2024-11-08 13:31:58'),
(12, 'Is Sonivo compatible with my current SIP provider?', 'Sonivo is designed to integrate seamlessly with most SIP providers, making it easy to connect with your existing telephony infrastructure. Our support team can assist with setup to ensure a smooth integration.', '2024-11-08 13:32:04'),
(13, 'Do you offer a free trial?', 'Yes! We offer a 7-day free trial with access to all premium features. This allows you to explore the full functionality of Sonivo before committing to a plan.', '2024-11-08 13:32:11'),
(14, 'How secure is my data on Sonivo?', 'We prioritize security and implement robust measures to protect your data. Sonivo uses encryption for data in transit and at rest, and we adhere to industry standards to ensure your information remains secure.', '2024-11-08 13:32:17'),
(15, 'What kind of support is available if I need help?', 'Our support team is here to assist you! We offer a range of resources, including user guides, video tutorials, and community forums. For personalized assistance, you can reach our team via email or live chat.', '2024-11-08 13:32:24'),
(16, 'How does Sonivo’s real-time analytics work?', 'Sonivo’s real-time analytics provides insights into call metrics, agent performance, and customer interactions. You can monitor key metrics, analyze patterns, and make data-driven adjustments to improve your call center’s efficiency.', '2024-11-08 13:32:29');

-- --------------------------------------------------------

--
-- Table structure for table `flow`
--

CREATE TABLE `flow` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `flow_id` varchar(999) DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `for_incoming` int(1) DEFAULT 1,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `flow`
--

INSERT INTO `flow` (`id`, `uid`, `flow_id`, `title`, `for_incoming`, `createdAt`) VALUES
(58, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'qUWYbN', 'test', 1, '2025-04-05 16:05:21');

-- --------------------------------------------------------

--
-- Table structure for table `flow_response`
--

CREATE TABLE `flow_response` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `text` longtext DEFAULT NULL,
  `caller_number` varchar(999) DEFAULT NULL,
  `my_number` varchar(999) DEFAULT NULL,
  `digit` varchar(999) DEFAULT NULL,
  `broadcast_id` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `flow_response`
--

INSERT INTO `flow_response` (`id`, `uid`, `text`, `caller_number`, `my_number`, `digit`, `broadcast_id`, `createdAt`) VALUES
(14, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'Call back: +19786361859', '+19786361859', '+19782481662', 'NA', 'CaNVJU', '2024-11-09 11:31:24'),
(15, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'Call back: +19786361859', '+19786361859', '+19782481662', 'NA', 'CaNVJU', '2024-11-09 12:01:31');

-- --------------------------------------------------------

--
-- Table structure for table `google_credentials`
--

CREATE TABLE `google_credentials` (
  `id` int(11) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `credential_id` varchar(255) NOT NULL,
  `service_account_json` text NOT NULL,
  `project_id` varchar(255) NOT NULL,
  `client_email` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `google_credentials`
--

INSERT INTO `google_credentials` (`id`, `uid`, `credential_id`, `service_account_json`, `project_id`, `client_email`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'creds', '{}', 'xxxxxxxxxxxx', 'xxxxxxxxxxxx@xxxxxx.com', 1, '2025-08-18 13:31:14', '2025-08-31 13:04:44');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `device_id` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `geo` longtext DEFAULT NULL,
  `body` longtext DEFAULT NULL,
  `msg_from` varchar(999) DEFAULT NULL,
  `msg_to` varchar(999) DEFAULT NULL,
  `route` varchar(999) DEFAULT NULL,
  `trash` int(1) DEFAULT 0,
  `important` int(1) DEFAULT 0,
  `recipient` varchar(999) DEFAULT NULL,
  `twilio_number` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `device_id`, `uid`, `geo`, `body`, `msg_from`, `msg_to`, `route`, `trash`, `important`, `recipient`, `twilio_number`, `createdAt`) VALUES
(2, 'DfyerO', 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', NULL, 'Hello there this is incoming message', '+19782481662', '+19786361859', 'INCOMING', 0, 0, '+19782481662', '+19786361859', '2024-09-26 07:46:53'),
(3, 'DfyerO', 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', NULL, 'Hello again this is a test message again sent from the webapp', '+19786361859', '+19782481662', 'OUTGOING', 0, 0, '+19782481662', '+19786361859', '2024-09-26 07:53:06');

-- --------------------------------------------------------

--
-- Table structure for table `model`
--

CREATE TABLE `model` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `type` varchar(999) DEFAULT NULL COMMENT 'gemini or openai',
  `model_code` varchar(999) DEFAULT NULL,
  `temprature` varchar(999) DEFAULT NULL,
  `max_token` varchar(999) DEFAULT NULL,
  `train_text` longtext DEFAULT NULL,
  `history_number` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `model`
--

INSERT INTO `model` (`id`, `uid`, `title`, `type`, `model_code`, `temprature`, `max_token`, `train_text`, `history_number`, `createdAt`) VALUES
(2, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'Model Test updated', 'openai', 'gpt-3.5-turbo', '0.4', '200', 'you are bot', '4', '2024-09-13 14:49:02'),
(3, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'gemin ai  updated', 'gemini', 'gpt-3.5-turbo', '0.4', '200', 'you are helpful bot', '4', '2024-09-13 15:04:52');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `payment_mode` varchar(999) DEFAULT NULL,
  `amount` varchar(999) DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `s_token` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `uid`, `payment_mode`, `amount`, `data`, `s_token`, `createdAt`) VALUES
(1, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_dqxp32XL9iS84rkGn0qUGDJxgk4FTB85', NULL, '2024-02-27 16:42:39'),
(2, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_kRgrG7W8VkmxjGdN9Y2hGSDgpRLLNfvE', NULL, '2024-02-27 16:43:40'),
(3, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_eKKkcWJoPucKohudnSQeRosVvrCrXcKh', NULL, '2024-02-27 16:44:28'),
(4, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_3c4ftk9IScaHBRw5e2PcWD3JybtvsS1R', NULL, '2024-02-27 16:44:56'),
(5, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_dwxUDZ8wvnAAfElrLyWcROWEtLtGMvzw', NULL, '2024-02-27 16:45:29'),
(6, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', 'STRIPE_gK9jBs2OfZe9S6CgWqYVrQrzzH3eDte5', 'cs_test_a1PeoPzWmC8fFWpBpUFgyLTfAmB7iSMCsj3Q2WouI0zqzJ0enxWTxV1Td2', '2024-02-27 16:46:02'),
(7, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '29', 'STRIPE_2FDktdAjiTouevxzdZPRvunGyIrNSlKJ', 'cs_test_a1VyGDjUiyxfhzVHNXbUx5d0rBSGFYalbFZRDtuILLPWX3OexKz6xss2kC', '2024-02-27 16:46:47'),
(8, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '29', '{\"id\":\"cs_test_a1XHP01IGKVfrxCdXR0MX3dME7qPnt2UdWcj2b1rjo5Azqici3CbEDN9WU\",\"object\":\"checkout.session\",\"after_expiration\":null,\"allow_promotion_codes\":null,\"amount_subtotal\":2900,\"amount_total\":2900,\"automatic_tax\":{\"enabled\":false,\"liability\":null,\"status\":null},\"billing_address_collection\":null,\"cancel_url\":\"http://localhost:3001/api/user/stripe_payment?order=STRIPE_JEe0ovSmj1ojVXPwArX5VI8QaQxkaS0k&plan=8\",\"client_reference_id\":null,\"client_secret\":null,\"consent\":null,\"consent_collection\":null,\"created\":1709101095,\"currency\":\"usd\",\"currency_conversion\":null,\"custom_fields\":[],\"custom_text\":{\"after_submit\":null,\"shipping_address\":null,\"submit\":null,\"terms_of_service_acceptance\":null},\"customer\":null,\"customer_creation\":\"if_required\",\"customer_details\":{\"address\":{\"city\":\"city\",\"country\":\"IN\",\"line1\":\"address\",\"line2\":null,\"postal_code\":\"110011\",\"state\":\"DL\"},\"email\":\"email@gmail.com\",\"name\":\"name\",\"phone\":null,\"tax_exempt\":\"none\",\"tax_ids\":[]},\"customer_email\":null,\"expires_at\":1709187495,\"invoice\":null,\"invoice_creation\":{\"enabled\":false,\"invoice_data\":{\"account_tax_ids\":null,\"custom_fields\":null,\"description\":null,\"footer\":null,\"issuer\":null,\"metadata\":{},\"rendering_options\":null}},\"livemode\":false,\"locale\":\"en\",\"metadata\":{},\"mode\":\"payment\",\"payment_intent\":\"pi_3OogTRSJ7RHyuQ0A0RAOOH4O\",\"payment_link\":null,\"payment_method_collection\":\"always\",\"payment_method_configuration_details\":null,\"payment_method_options\":{},\"payment_method_types\":[\"card\"],\"payment_status\":\"paid\",\"phone_number_collection\":{\"enabled\":false},\"recovered_from\":null,\"setup_intent\":null,\"shipping_address_collection\":null,\"shipping_cost\":null,\"shipping_details\":null,\"shipping_options\":[],\"status\":\"complete\",\"submit_type\":null,\"subscription\":null,\"success_url\":\"http://localhost:3001/api/user/stripe_payment?order=STRIPE_JEe0ovSmj1ojVXPwArX5VI8QaQxkaS0k&plan=8\",\"total_details\":{\"amount_discount\":0,\"amount_shipping\":0,\"amount_tax\":0},\"ui_mode\":\"hosted\",\"url\":null}', 'cs_test_a1XHP01IGKVfrxCdXR0MX3dME7qPnt2UdWcj2b1rjo5Azqici3CbEDN9WU', '2024-02-28 06:18:14'),
(9, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '99', '{\"id\":\"cs_test_a1vJ4h0O6qHsFPI5xRVzu0xNyPJja6suv4lBv0dKrSNLmW2UdVoWacjuwC\",\"object\":\"checkout.session\",\"after_expiration\":null,\"allow_promotion_codes\":null,\"amount_subtotal\":9900,\"amount_total\":9900,\"automatic_tax\":{\"enabled\":false,\"liability\":null,\"status\":null},\"billing_address_collection\":null,\"cancel_url\":\"http://localhost:3001/api/user/stripe_payment?order=STRIPE_F65zhJWwDfSDvpeaIpSDzvyTerzyYFTp&plan=9\",\"client_reference_id\":null,\"client_secret\":null,\"consent\":null,\"consent_collection\":null,\"created\":1709101186,\"currency\":\"usd\",\"currency_conversion\":null,\"custom_fields\":[],\"custom_text\":{\"after_submit\":null,\"shipping_address\":null,\"submit\":null,\"terms_of_service_acceptance\":null},\"customer\":null,\"customer_creation\":\"if_required\",\"customer_details\":{\"address\":{\"city\":\"city\",\"country\":\"IN\",\"line1\":\"address\",\"line2\":null,\"postal_code\":\"110010\",\"state\":\"DL\"},\"email\":\"email@gmail.com\",\"name\":\"name\",\"phone\":null,\"tax_exempt\":\"none\",\"tax_ids\":[]},\"customer_email\":null,\"expires_at\":1709187586,\"invoice\":null,\"invoice_creation\":{\"enabled\":false,\"invoice_data\":{\"account_tax_ids\":null,\"custom_fields\":null,\"description\":null,\"footer\":null,\"issuer\":null,\"metadata\":{},\"rendering_options\":null}},\"livemode\":false,\"locale\":\"en\",\"metadata\":{},\"mode\":\"payment\",\"payment_intent\":\"pi_3OogUuSJ7RHyuQ0A0SSTfKx2\",\"payment_link\":null,\"payment_method_collection\":\"always\",\"payment_method_configuration_details\":null,\"payment_method_options\":{},\"payment_method_types\":[\"card\"],\"payment_status\":\"paid\",\"phone_number_collection\":{\"enabled\":false},\"recovered_from\":null,\"setup_intent\":null,\"shipping_address_collection\":null,\"shipping_cost\":null,\"shipping_details\":null,\"shipping_options\":[],\"status\":\"complete\",\"submit_type\":null,\"subscription\":null,\"success_url\":\"http://localhost:3001/api/user/stripe_payment?order=STRIPE_F65zhJWwDfSDvpeaIpSDzvyTerzyYFTp&plan=9\",\"total_details\":{\"amount_discount\":0,\"amount_shipping\":0,\"amount_tax\":0},\"ui_mode\":\"hosted\",\"url\":null}', 'cs_test_a1vJ4h0O6qHsFPI5xRVzu0xNyPJja6suv4lBv0dKrSNLmW2UdVoWacjuwC', '2024-02-28 06:19:45'),
(11, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '29', 'STRIPE_9NfMadmhVY7EipWgNRa2cKHMi0Z7eon3', 'cs_test_a1o5hbpRwjdib7ljjoWyfI64yG6gDyhIryjkjgRrKFuhbwuZKzD8UuP0qt', '2024-02-28 06:49:20'),
(12, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '0', 'STRIPE_cmltSh007UFjH5eJILltM2YOgySYAwfl', NULL, '2024-02-29 16:50:29'),
(13, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'OFFLINE', '0', '{\"plan\":{\"id\":12,\"title\":\"Trial plan\",\"short_description\":\"this is a trial plan for 10 days\",\"allow_tag\":1,\"allow_note\":1,\"allow_chatbot\":1,\"contact_limit\":\"100\",\"allow_api\":1,\"is_trial\":1,\"price\":0,\"price_strike\":null,\"plan_duration_in_days\":\"10\",\"createdAt\":\"2024-02-26T06:59:02.000Z\"}}', NULL, '2024-02-29 16:53:17'),
(14, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'OFFLINE', '0', '{\"plan\":{\"id\":12,\"title\":\"Trial plan\",\"short_description\":\"this is a trial plan for 10 days\",\"allow_tag\":1,\"allow_note\":1,\"allow_chatbot\":1,\"contact_limit\":\"100\",\"allow_api\":1,\"is_trial\":1,\"price\":0,\"price_strike\":null,\"plan_duration_in_days\":\"10\",\"createdAt\":\"2024-02-26T06:59:02.000Z\"}}', NULL, '2024-02-29 16:54:27'),
(16, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '100', 'STRIPE_M3SIgdJ6o6LHJMBSlqAKD4CAvd8BUlpt', NULL, '2024-11-06 12:41:21'),
(17, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'STRIPE', '100', 'STRIPE_VxwoMAtJfWBukWTvOwA5EDN0oolV7EYq', NULL, '2024-11-06 12:41:31'),
(18, 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'OFFLINE', '0', '{\"plan\":{\"id\":5,\"title\":\"Trial\",\"is_trial\":1,\"price\":\"\",\"price_crossed\":\"\",\"short_des\":\"Experience all premium features with our 7-day free trial, no commitment required. Dive into our tools and see how they elevate your workflow!\",\"dialer\":1,\"call_broadcast\":1,\"messaging\":1,\"phonebook_limit\":\"1000\",\"agent_access\":1,\"device_limit\":\"1\",\"days\":\"7\",\"createdAt\":\"2024-11-08T07:24:00.000Z\"}}', NULL, '2024-11-08 13:33:51');

-- --------------------------------------------------------

--
-- Table structure for table `page`
--

CREATE TABLE `page` (
  `id` int(11) NOT NULL,
  `slug` varchar(999) DEFAULT NULL,
  `title` varchar(999) DEFAULT NULL,
  `image` varchar(999) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `permanent` int(1) DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `page`
--

INSERT INTO `page` (`id`, `slug`, `title`, `image`, `content`, `permanent`, `createdAt`) VALUES
(3, 'privacy-policy', 'Privacy policy', 'yLUH6z8H3bQJzraErEpz7CQWepftq7D6.png', '<p>hey i am privacy policy updated</p>', 1, '2024-02-28 09:21:17'),
(4, 'terms-and-conditions', 'termns', 'yLUH6z8H3bQJzraErEpz7CQWepftq7D6.png', '<p>Terms Page updated</p>', 1, '2024-02-28 09:26:11'),
(17, 'welcome-to-sonivo', 'Welcome to Sonivo', 'kTYMNhfyMWbq42FbL8cCEh7OnUmhwxhb.png', '<p>\"Welcome to Sonivo, the AI-powered call center solution designed to enhance your communication workflow. With advanced SIP integration, intelligent call flow building, and an AI assistant, Sonivo helps you deliver exceptional customer experiences. Our platform provides an intuitive interface, dynamic call handling, and automation capabilities that streamline every call and maximize your team’s efficiency. Discover how Sonivo can transform your call center operations.\"</p>', 0, '2024-11-08 13:10:08'),
(20, 'choose-your-plan', 'Choose Your Plan', 'yndlU61dqgBq1GCmvPoWbXWHmUxxXRIC.png', '<p><strong>Free Trial</strong></p><p>\"Try Sonivo free for 7 days! Get full access to premium features, including the AI assistant, call flow builder, and real-time analytics. Experience the power of Sonivo before you commit.\"</p><p><strong>Gold Plan</strong></p><p>\"Perfect for small teams, the Gold Plan includes priority support, SIP integration, and access to basic AI functionalities. Take your call center to the next level with streamlined communication tools.\"</p><p><strong>Platinum Plan</strong></p><p>\"Designed for growing businesses, the Platinum Plan offers all Gold features plus unlimited AI assistant usage, advanced call flow customization, and detailed analytics. Maximize productivity and customer engagement with Platinum.\"</p><p><strong>Enterprise</strong></p><p>\"Need something custom? Our Enterprise plan provides fully tailored solutions, personalized support, and flexible pricing. Reach out to discuss a plan that fits your unique business needs.\"</p>', 0, '2024-11-08 13:11:04'),
(21, 'were-here-to-help', 'We’re Here to Help', 'Of52VRiJ5KyKtEPMDhH4AA4z9GTRxefV.png', '<p>\"Whether you’re setting up Sonivo for the first time or troubleshooting a specific feature, our support team is ready to assist you. Explore our resources, including:</p><p><br></p><ul><li><strong>User Guides</strong>: Step-by-step guides to help you configure and use every feature of Sonivo.</li><li><strong>Video Tutorials</strong>: Watch and learn with our video walkthroughs.</li><li><strong>Community Forum</strong>: Join our user community to share tips and ask questions.</li><li><strong>Contact Support</strong>: Reach out directly to our support team for personalized help via email or live chat.</li></ul><p>At Sonivo, we’re committed to ensuring your call center operates smoothly and efficiently.\"</p>', 0, '2024-11-08 13:11:16');

-- --------------------------------------------------------

--
-- Table structure for table `partners`
--

CREATE TABLE `partners` (
  `id` int(11) NOT NULL,
  `filename` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `partners`
--

INSERT INTO `partners` (`id`, `filename`, `createdAt`) VALUES
(67, '2EnpOWgUY3kPfvBfxg92dH6DlInQJXug.png', '2024-11-06 12:09:09'),
(68, '10WwkFpsYZOBwwKAQyDrgMOJoQ4Wa8Qs.png', '2024-11-06 12:09:12'),
(69, 'xz2oQebmDUeBUeTUZKpEmRzP18ARF2sc.png', '2024-11-06 12:09:14'),
(70, '1SvTfxBd20bCrxsrE1wTOGi60ZDHdDe1.png', '2024-11-06 12:09:16'),
(71, 'WaDwfQblHrCR94NhktSReKDurLWRBQuC.png', '2024-11-06 12:09:18'),
(72, 'QV68lvZNINr3DhCiV7nw6eivK2qm6zBA.png', '2024-11-06 12:09:20'),
(73, 'Uz9MHoTNrnMwhHXbSu8PnjHyuASFgo3y.png', '2024-11-06 12:09:22'),
(74, 'kW2ZrKfsPAhQKRb6EThCP0KMAqgNgrJI.png', '2024-11-06 12:09:24');

-- --------------------------------------------------------

--
-- Table structure for table `phonebook`
--

CREATE TABLE `phonebook` (
  `id` int(11) NOT NULL,
  `name` varchar(999) DEFAULT NULL,
  `uid` varchar(999) DEFAULT NULL,
  `phonebook_id` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `phonebook`
--

INSERT INTO `phonebook` (`id`, `name`, `uid`, `phonebook_id`, `createdAt`) VALUES
(5, 'codeyon', 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'xpLyA', '2025-08-20 09:21:40');

-- --------------------------------------------------------

--
-- Table structure for table `plan`
--

CREATE TABLE `plan` (
  `id` int(11) NOT NULL,
  `title` varchar(999) DEFAULT NULL,
  `is_trial` int(1) DEFAULT 0,
  `price` varchar(999) DEFAULT NULL,
  `price_crossed` varchar(999) DEFAULT NULL,
  `short_des` longtext DEFAULT NULL,
  `dialer` int(1) DEFAULT 1,
  `call_broadcast` int(1) DEFAULT 1,
  `messaging` int(1) DEFAULT 1,
  `phonebook_limit` varchar(999) DEFAULT NULL,
  `agent_access` int(1) DEFAULT 1,
  `device_limit` varchar(999) DEFAULT NULL,
  `days` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `plan`
--

INSERT INTO `plan` (`id`, `title`, `is_trial`, `price`, `price_crossed`, `short_des`, `dialer`, `call_broadcast`, `messaging`, `phonebook_limit`, `agent_access`, `device_limit`, `days`, `createdAt`) VALUES
(5, 'Trial', 1, '', '', 'Experience all premium features with our 7-day free trial, no commitment required. Dive into our tools and see how they elevate your workflow!', 1, 1, 1, '1000', 1, '1', '7', '2024-11-08 12:54:00'),
(6, 'Gold', 0, '99', '1999', 'Unlock exclusive access with the Gold Plan, featuring advanced tools, priority support, and extended usage limits. Perfect for growing teams aiming to boost productivity and efficiency!', 1, 0, 1, '10000', 1, '5', '30', '2024-11-08 12:58:05'),
(7, 'Platinum', 0, '199', '399', 'Gain unlimited access to all premium features with the Platinum Plan, including personalized support and priority upgrades. Ideal for power users and enterprises seeking maximum performance and flexibility!', 1, 1, 1, '9968', 1, '1', '30', '2024-11-08 12:59:33');

-- --------------------------------------------------------

--
-- Table structure for table `smtp`
--

CREATE TABLE `smtp` (
  `id` int(11) NOT NULL,
  `email` varchar(999) DEFAULT NULL,
  `host` varchar(999) DEFAULT NULL,
  `port` varchar(999) DEFAULT NULL,
  `password` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `smtp`
--

INSERT INTO `smtp` (`id`, `email`, `host`, `port`, `password`, `createdAt`) VALUES
(1, 'email@gmail.com', 'smtp@gmail.com', '465', 'password', '2024-02-28 16:44:12');

-- --------------------------------------------------------

--
-- Table structure for table `temp_var`
--

CREATE TABLE `temp_var` (
  `id` int(11) NOT NULL,
  `unique_id` varchar(999) DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `temp_var`
--

INSERT INTO `temp_var` (`id`, `unique_id`, `data`, `createdAt`) VALUES
(10, 'mnCYEm', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 13:34:38'),
(11, 'ZSC6tF', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 13:36:33'),
(12, 'bYXHD9', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 13:40:14'),
(13, 'NSFJvm', '{\"data\":{\"id\":1,\"email\":\"george.bluth@reqres.in\",\"first_name\":\"George\",\"last_name\":\"Bluth\",\"avatar\":\"https://reqres.in/img/faces/1-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 13:42:57'),
(14, 'nPyrkx', '{\"data\":{\"id\":1,\"email\":\"george.bluth@reqres.in\",\"first_name\":\"George\",\"last_name\":\"Bluth\",\"avatar\":\"https://reqres.in/img/faces/1-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 13:43:34'),
(15, 'LHINIQ', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-16 14:32:42'),
(16, 'Btw7Sn', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-17 13:34:47'),
(17, 'OCpaxM', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 08:56:14'),
(18, 'RRqeTn', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 12:05:44'),
(19, 'dAasBp', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 12:08:16'),
(20, 'UObnq1', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 12:08:37'),
(21, 'JltVoW', '{\"data\":{\"id\":1,\"email\":\"george.bluth@reqres.in\",\"first_name\":\"George\",\"last_name\":\"Bluth\",\"avatar\":\"https://reqres.in/img/faces/1-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 12:14:16'),
(22, 'Mv7E86', '{\"data\":{\"id\":3,\"email\":\"emma.wong@reqres.in\",\"first_name\":\"Emma\",\"last_name\":\"Wong\",\"avatar\":\"https://reqres.in/img/faces/3-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 12:19:27'),
(23, '590J4E', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 15:46:43'),
(24, 'y8X4d7', '{\"data\":{\"id\":2,\"email\":\"janet.weaver@reqres.in\",\"first_name\":\"Janet\",\"last_name\":\"Weaver\",\"avatar\":\"https://reqres.in/img/faces/2-image.jpg\"},\"support\":{\"url\":\"https://reqres.in/#support-heading\",\"text\":\"To keep ReqRes free, contributions towards server costs are appreciated!\"}}', '2024-10-21 15:47:37'),
(25, 'tDZ4BK', '{\"status\":\"success\",\"data\":{\"orderId\":\"12345\",\"productName\":\"Premium Software License\",\"productDescription\":\"One-year license for premium software\",\"purchaseDate\":\"2024-01-01\",\"price\":99.99,\"currency\":\"USD\",\"status\":\"Active\",\"supportContact\":\"support@example.com\"},\"delivery\":\"On November 12 till 10PM\"}', '2024-11-09 09:18:53'),
(26, '1Xa7nS', '{\"status\":\"success\",\"data\":{\"orderId\":\"12345\",\"productName\":\"Premium Software License\",\"productDescription\":\"One-year license for premium software\",\"purchaseDate\":\"2024-01-01\",\"price\":99.99,\"currency\":\"USD\",\"status\":\"Active\",\"supportContact\":\"support@example.com\"},\"delivery\":\"On November 12 till 10PM\"}', '2024-11-09 11:29:25'),
(27, 'FL35Rp', '{\"status\":\"success\",\"data\":{\"orderId\":\"12345\",\"productName\":\"Premium Software License\",\"productDescription\":\"One-year license for premium software\",\"purchaseDate\":\"2024-01-01\",\"price\":99.99,\"currency\":\"USD\",\"status\":\"Active\",\"supportContact\":\"support@example.com\"},\"delivery\":\"On November 12 till 10PM\"}', '2024-11-09 11:56:13'),
(28, 'OV4bqx', '{\"status\":\"success\",\"data\":{\"orderId\":\"12345\",\"productName\":\"Premium Software License\",\"productDescription\":\"One-year license for premium software\",\"purchaseDate\":\"2024-01-01\",\"price\":99.99,\"currency\":\"USD\",\"status\":\"Active\",\"supportContact\":\"support@example.com\"},\"delivery\":\"On November 12 till 10PM\"}', '2024-11-09 11:59:48');

-- --------------------------------------------------------

--
-- Table structure for table `testimonial`
--

CREATE TABLE `testimonial` (
  `id` int(11) NOT NULL,
  `title` varchar(999) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `reviewer_name` varchar(999) DEFAULT NULL,
  `reviewer_position` varchar(999) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `testimonial`
--

INSERT INTO `testimonial` (`id`, `title`, `description`, `reviewer_name`, `reviewer_position`, `createdAt`) VALUES
(5, 'Sonivo has completely transformed', '\"Sonivo has completely transformed our customer support operations. The AI call assistant handles routine inquiries with ease, allowing our team to focus on more complex cases. We’ve seen a huge boost in productivity and customer satisfaction!\"', '— Megan L.', 'Customer Support Manager', '2024-11-08 13:30:29'),
(6, 'The call flow ', '\"The call flow builder is a game-changer! Designing and updating our call flows used to be a hassle, but with Sonivo, we can quickly create dynamic paths that improve our caller experience. Highly recommended!\"', '— Samir P.', 'Operations Director', '2024-11-08 13:30:47'),
(7, 'As a growing business', '\"As a growing business, Sonivo has been essential for scaling our call center. The seamless SIP integration and intuitive call dialer make managing calls simple, and the AI assistant ensures our customers receive prompt, accurate responses.\"', '— Carlos G.', 'Founder & CEO', '2024-11-08 13:31:02'),
(8, 'We were hesitant', '\"We were hesitant to adopt an AI call assistant, but Sonivo exceeded our expectations. The real-time analytics and insights have allowed us to optimize our processes, and the support team has been fantastic!\"', '— Emily R.', 'Call Center Lead', '2024-11-08 13:31:17');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `role` varchar(999) DEFAULT 'user',
  `uid` varchar(999) DEFAULT NULL,
  `name` varchar(999) DEFAULT NULL,
  `email` varchar(999) DEFAULT NULL,
  `password` varchar(999) DEFAULT NULL,
  `mobile` varchar(999) DEFAULT NULL,
  `timezone` varchar(999) DEFAULT NULL,
  `plan` longtext DEFAULT NULL,
  `plan_expire` varchar(999) DEFAULT NULL,
  `trial` int(1) DEFAULT 0,
  `api_key` varchar(999) DEFAULT NULL,
  `user_timezone` varchar(999) DEFAULT 'Asia/Kolkata',
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `role`, `uid`, `name`, `email`, `password`, `mobile`, `timezone`, `plan`, `plan_expire`, `trial`, `api_key`, `user_timezone`, `createdAt`) VALUES
(2, 'user', 'OQZWIGRtR9QmY3BgnZR6QHWdOCegxYTJ', 'John', 'user@user.com', '$2b$10$9yNORBw7zB6FV9cJ7eK/VevfXndZPKcpap2QZGyVoiRk2JA0c2Xo2', '19992893831', NULL, '{\"id\":7,\"title\":\"Platinum\",\"is_trial\":0,\"price\":\"199\",\"price_crossed\":\"399\",\"short_des\":\"Gain unlimited access to all premium features with the Platinum Plan, including personalized support and priority upgrades. Ideal for power users and enterprises seeking maximum performance and flexibility!\",\"dialer\":1,\"call_broadcast\":1,\"messaging\":1,\"phonebook_limit\":\"9968\",\"agent_access\":1,\"device_limit\":\"1\",\"days\":\"30\",\"createdAt\":\"2024-11-08T07:29:33.000Z\"}', '1756992496202', 1, NULL, 'Asia/Kolkata', '2024-09-12 08:43:38');

-- --------------------------------------------------------

--
-- Table structure for table `web_private`
--

CREATE TABLE `web_private` (
  `id` int(11) NOT NULL,
  `pay_offline_id` varchar(999) DEFAULT NULL,
  `pay_offline_key` longtext DEFAULT NULL,
  `offline_active` int(1) DEFAULT 0,
  `pay_stripe_id` varchar(999) DEFAULT NULL,
  `pay_stripe_key` varchar(999) DEFAULT NULL,
  `stripe_active` int(1) DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `pay_paypal_id` varchar(999) DEFAULT NULL,
  `pay_paypal_key` varchar(999) DEFAULT NULL,
  `paypal_active` varchar(999) DEFAULT NULL,
  `rz_id` varchar(999) DEFAULT NULL,
  `rz_key` varchar(999) DEFAULT NULL,
  `rz_active` varchar(999) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `web_private`
--

INSERT INTO `web_private` (`id`, `pay_offline_id`, `pay_offline_key`, `offline_active`, `pay_stripe_id`, `pay_stripe_key`, `stripe_active`, `createdAt`, `pay_paypal_id`, `pay_paypal_key`, `paypal_active`, `rz_id`, `rz_key`, `rz_active`) VALUES
(1, 'Pay offline', 'Pay offline on this account number xxxxxxxxx\nand send a screenshot to us on this email xxx@xxx.com', 1, 'pk_test_51NGI3WSJ7RHyuQ0ARpYwHAK6WJYygcXmJTwwcVZsvusgQUSDMybxIpwt86U8uSp5RFBhAn3O9xxxxxxxxxxxxxxxxxxxxxxxxx', 'sk_test_51NGI3WSJ7RHyuQ0AG7eC7wD7kJrpTFKCnNaj3IwIIUVbJcPxE33YonYSyjJt9fEqEfEHWtpZ72Hy0Txxxxxxxxxxxxxxxxxxxxxxxxx', 1, '2024-02-26 17:06:06', 'AaYOfHVy-uNKyKa0FO-7tb6_hST-hToVAFqGgIuQ2yhWxolZkaXANI2oQBEoOBg9IGIS7rshj4qOM3qd', 'EDqUS14FS084QnzFH7RA7FEzBGXIRUEJ31XL2tkGOe0qmLbt8DunPjj_O0Gb721q-7vOhRZWoKPViPCx', '1', 'id', 'key', '1');

-- --------------------------------------------------------

--
-- Table structure for table `web_public`
--

CREATE TABLE `web_public` (
  `id` int(11) NOT NULL,
  `currency_code` varchar(999) DEFAULT NULL,
  `logo` varchar(999) DEFAULT NULL,
  `app_name` varchar(999) DEFAULT NULL,
  `custom_home` varchar(999) DEFAULT NULL,
  `is_custom_home` int(1) DEFAULT 0,
  `meta_description` longtext DEFAULT NULL,
  `currency_symbol` varchar(999) DEFAULT NULL,
  `chatbot_screen_tutorial` varchar(999) DEFAULT NULL,
  `broadcast_screen_tutorial` varchar(999) DEFAULT NULL,
  `home_page_tutorial` varchar(999) DEFAULT NULL,
  `login_header_footer` int(1) DEFAULT 1,
  `exchange_rate` varchar(999) DEFAULT NULL,
  `google_client_id` varchar(999) DEFAULT NULL,
  `google_login_active` int(11) DEFAULT 1,
  `rtl` int(11) DEFAULT 0,
  `fb_login_app_id` varchar(999) DEFAULT NULL,
  `fb_login_app_sec` varchar(999) DEFAULT NULL,
  `fb_login_active` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `web_public`
--

INSERT INTO `web_public` (`id`, `currency_code`, `logo`, `app_name`, `custom_home`, `is_custom_home`, `meta_description`, `currency_symbol`, `chatbot_screen_tutorial`, `broadcast_screen_tutorial`, `home_page_tutorial`, `login_header_footer`, `exchange_rate`, `google_client_id`, `google_login_active`, `rtl`, `fb_login_app_id`, `fb_login_app_sec`, `fb_login_active`) VALUES
(1, 'USD', 'p3v6PjgmKVqXnG3pg1ivUTHmox7o1a3E.png', 'Sonivo ai', 'https://google.com', 0, 'Sonivo - AI Call Center solution with SIP integration, AI call assistant, and advanced call dialer. Build seamless call flows with our drag-and-drop flow builder, and boost customer satisfaction with real-time analytics. Streamline your call center operations and elevate customer service with Sonivo.', '$', 'https://youtu.be/grYkwWNEmOI', 'https://youtu.be/grYkwWNEmOI', 'https://youtu.be/grYkwWNEmOI', 1, '1', 'xxxx@xxxx.com', 1, 0, '1026848205373161', 'fa68a36e6a0bc1d69882c4e75fa3b688', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `agent_incoming`
--
ALTER TABLE `agent_incoming`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ai_key`
--
ALTER TABLE `ai_key`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `beta_call_log`
--
ALTER TABLE `beta_call_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `beta_campaign`
--
ALTER TABLE `beta_campaign`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `campaign_id` (`campaign_id`) USING HASH;

--
-- Indexes for table `beta_campaign_log`
--
ALTER TABLE `beta_campaign_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `beta_flows`
--
ALTER TABLE `beta_flows`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `call_campaign`
--
ALTER TABLE `call_campaign`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `call_campaign_log`
--
ALTER TABLE `call_campaign_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `call_force_log`
--
ALTER TABLE `call_force_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `call_force_task`
--
ALTER TABLE `call_force_task`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `call_log`
--
ALTER TABLE `call_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `contact`
--
ALTER TABLE `contact`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `contact_form`
--
ALTER TABLE `contact_form`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `device`
--
ALTER TABLE `device`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `flow`
--
ALTER TABLE `flow`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `flow_response`
--
ALTER TABLE `flow_response`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `google_credentials`
--
ALTER TABLE `google_credentials`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `credential_id` (`credential_id`),
  ADD KEY `idx_uid` (`uid`),
  ADD KEY `idx_credential_id` (`credential_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `model`
--
ALTER TABLE `model`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `page`
--
ALTER TABLE `page`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `partners`
--
ALTER TABLE `partners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `phonebook`
--
ALTER TABLE `phonebook`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `plan`
--
ALTER TABLE `plan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `smtp`
--
ALTER TABLE `smtp`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `temp_var`
--
ALTER TABLE `temp_var`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `testimonial`
--
ALTER TABLE `testimonial`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `web_private`
--
ALTER TABLE `web_private`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `web_public`
--
ALTER TABLE `web_public`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `agents`
--
ALTER TABLE `agents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `agent_incoming`
--
ALTER TABLE `agent_incoming`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `ai_key`
--
ALTER TABLE `ai_key`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `beta_call_log`
--
ALTER TABLE `beta_call_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `beta_campaign`
--
ALTER TABLE `beta_campaign`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `beta_campaign_log`
--
ALTER TABLE `beta_campaign_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `beta_flows`
--
ALTER TABLE `beta_flows`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `call_campaign`
--
ALTER TABLE `call_campaign`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `call_campaign_log`
--
ALTER TABLE `call_campaign_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `call_force_log`
--
ALTER TABLE `call_force_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `call_force_task`
--
ALTER TABLE `call_force_task`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `call_log`
--
ALTER TABLE `call_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `contact`
--
ALTER TABLE `contact`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `contact_form`
--
ALTER TABLE `contact_form`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `device`
--
ALTER TABLE `device`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `flow`
--
ALTER TABLE `flow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `flow_response`
--
ALTER TABLE `flow_response`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `google_credentials`
--
ALTER TABLE `google_credentials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `model`
--
ALTER TABLE `model`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `page`
--
ALTER TABLE `page`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `partners`
--
ALTER TABLE `partners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT for table `phonebook`
--
ALTER TABLE `phonebook`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `plan`
--
ALTER TABLE `plan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `smtp`
--
ALTER TABLE `smtp`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `temp_var`
--
ALTER TABLE `temp_var`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `testimonial`
--
ALTER TABLE `testimonial`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `web_private`
--
ALTER TABLE `web_private`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `web_public`
--
ALTER TABLE `web_public`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
