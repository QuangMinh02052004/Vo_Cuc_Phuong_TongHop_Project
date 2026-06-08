--
-- PostgreSQL database dump
--

\restrict ngtpBP8IYuhYSWqpKJl6O3Sc3P16rLSrEP1ufdP4lYuTy5ECbm9jVlNjs2Fm08U

-- Dumped from database version 17.8 (130b160)
-- Dumped by pg_dump version 17.9 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: TH_ActivityLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_ActivityLog" (
    id integer NOT NULL,
    action character varying(50) NOT NULL,
    description text,
    "bookingId" integer,
    "seatNumber" integer,
    "userName" character varying(100),
    date character varying(20),
    route character varying(100),
    "timeSlot" character varying(10),
    "createdAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_ActivityLog_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_ActivityLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_ActivityLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_ActivityLog_id_seq" OWNED BY public."TH_ActivityLog".id;


--
-- Name: TH_Bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_Bookings" (
    id integer NOT NULL,
    "timeSlotId" integer,
    phone character varying(20),
    name character varying(200),
    gender character varying(10),
    nationality character varying(100),
    "pickupMethod" character varying(50),
    "pickupAddress" character varying(500),
    "dropoffMethod" character varying(50),
    "dropoffAddress" character varying(500),
    note text,
    "seatNumber" integer,
    amount numeric(18,2),
    paid numeric(18,2) DEFAULT 0,
    "timeSlot" character varying(10),
    date character varying(20),
    route character varying(100),
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    "callStatus" character varying(50) DEFAULT 'Chưa gọi'::character varying,
    printed boolean DEFAULT false
);


--
-- Name: TH_Bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_Bookings_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_Bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_Bookings_id_seq" OWNED BY public."TH_Bookings".id;


--
-- Name: TH_CustomerMessages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_CustomerMessages" (
    id integer NOT NULL,
    "requestId" integer,
    direction character varying(5) DEFAULT 'out'::character varying NOT NULL,
    content text,
    "senderName" character varying(200),
    "senderEmail" character varying(200),
    "createdAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_CustomerMessages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_CustomerMessages_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_CustomerMessages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_CustomerMessages_id_seq" OWNED BY public."TH_CustomerMessages".id;


--
-- Name: TH_CustomerRequests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_CustomerRequests" (
    id integer NOT NULL,
    type character varying(50) DEFAULT 'inquiry'::character varying,
    name character varying(200),
    phone character varying(20),
    "bookingRef" character varying(50),
    message text,
    status character varying(20) DEFAULT 'new'::character varying,
    "assignedTo" character varying(100),
    "adminNote" text,
    source character varying(30) DEFAULT 'manual'::character varying,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    email character varying(200),
    "replyMessage" text,
    "repliedAt" timestamp without time zone,
    "repliedBy" character varying(100)
);


--
-- Name: TH_CustomerRequests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_CustomerRequests_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_CustomerRequests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_CustomerRequests_id_seq" OWNED BY public."TH_CustomerRequests".id;


--
-- Name: TH_Drivers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_Drivers" (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_Drivers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_Drivers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_Drivers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_Drivers_id_seq" OWNED BY public."TH_Drivers".id;


--
-- Name: TH_Routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_Routes" (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    "routeType" character varying(50) DEFAULT 'quoc_lo'::character varying,
    price numeric(18,2) DEFAULT 0,
    duration character varying(50),
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    "fromStation" character varying(100),
    "toStation" character varying(100),
    "busType" character varying(50) DEFAULT 'Ghế ngồi'::character varying,
    seats integer DEFAULT 28,
    distance character varying(50),
    "operatingStart" character varying(10) DEFAULT '03:30'::character varying,
    "operatingEnd" character varying(10) DEFAULT '18:00'::character varying,
    "intervalMinutes" integer DEFAULT 30
);


--
-- Name: TH_Routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_Routes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_Routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_Routes_id_seq" OWNED BY public."TH_Routes".id;


--
-- Name: TH_SeatLocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_SeatLocks" (
    id integer NOT NULL,
    "timeSlotId" integer NOT NULL,
    "seatNumber" integer NOT NULL,
    "lockedBy" character varying(100) NOT NULL,
    "lockedByUserId" integer,
    "lockedAt" timestamp without time zone DEFAULT now(),
    "expiresAt" timestamp without time zone NOT NULL,
    date character varying(20) NOT NULL,
    route character varying(100) NOT NULL
);


--
-- Name: TH_SeatLocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_SeatLocks_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_SeatLocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_SeatLocks_id_seq" OWNED BY public."TH_SeatLocks".id;


--
-- Name: TH_StaffTasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_StaffTasks" (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    "assignedTo" character varying(100),
    "createdBy" character varying(100),
    date character varying(20),
    "dueTime" character varying(10),
    status character varying(20) DEFAULT 'pending'::character varying,
    priority character varying(10) DEFAULT 'normal'::character varying,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_StaffTasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_StaffTasks_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_StaffTasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_StaffTasks_id_seq" OWNED BY public."TH_StaffTasks".id;


--
-- Name: TH_TimeSlots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_TimeSlots" (
    id integer NOT NULL,
    "time" character varying(10) NOT NULL,
    date character varying(20),
    type character varying(50),
    code character varying(20),
    driver character varying(100),
    phone character varying(20),
    route character varying(100),
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_TimeSlots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_TimeSlots_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_TimeSlots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_TimeSlots_id_seq" OWNED BY public."TH_TimeSlots".id;


--
-- Name: TH_Users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_Users" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    "fullName" character varying(100),
    role character varying(20) DEFAULT 'employee'::character varying,
    active boolean DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    email character varying(100),
    phone character varying(20)
);


--
-- Name: TH_Users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_Users_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_Users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_Users_id_seq" OWNED BY public."TH_Users".id;


--
-- Name: TH_VehicleStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_VehicleStatus" (
    id integer NOT NULL,
    "vehicleId" integer,
    status character varying(30) DEFAULT 'ready'::character varying,
    note text,
    "updatedBy" character varying(100),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_VehicleStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_VehicleStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_VehicleStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_VehicleStatus_id_seq" OWNED BY public."TH_VehicleStatus".id;


--
-- Name: TH_Vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TH_Vehicles" (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    type character varying(50) NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: TH_Vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TH_Vehicles_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TH_Vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TH_Vehicles_id_seq" OWNED BY public."TH_Vehicles".id;


--
-- Name: TH_ActivityLog id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_ActivityLog" ALTER COLUMN id SET DEFAULT nextval('public."TH_ActivityLog_id_seq"'::regclass);


--
-- Name: TH_Bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Bookings" ALTER COLUMN id SET DEFAULT nextval('public."TH_Bookings_id_seq"'::regclass);


--
-- Name: TH_CustomerMessages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_CustomerMessages" ALTER COLUMN id SET DEFAULT nextval('public."TH_CustomerMessages_id_seq"'::regclass);


--
-- Name: TH_CustomerRequests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_CustomerRequests" ALTER COLUMN id SET DEFAULT nextval('public."TH_CustomerRequests_id_seq"'::regclass);


--
-- Name: TH_Drivers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Drivers" ALTER COLUMN id SET DEFAULT nextval('public."TH_Drivers_id_seq"'::regclass);


--
-- Name: TH_Routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Routes" ALTER COLUMN id SET DEFAULT nextval('public."TH_Routes_id_seq"'::regclass);


--
-- Name: TH_SeatLocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_SeatLocks" ALTER COLUMN id SET DEFAULT nextval('public."TH_SeatLocks_id_seq"'::regclass);


--
-- Name: TH_StaffTasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_StaffTasks" ALTER COLUMN id SET DEFAULT nextval('public."TH_StaffTasks_id_seq"'::regclass);


--
-- Name: TH_TimeSlots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_TimeSlots" ALTER COLUMN id SET DEFAULT nextval('public."TH_TimeSlots_id_seq"'::regclass);


--
-- Name: TH_Users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Users" ALTER COLUMN id SET DEFAULT nextval('public."TH_Users_id_seq"'::regclass);


--
-- Name: TH_VehicleStatus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_VehicleStatus" ALTER COLUMN id SET DEFAULT nextval('public."TH_VehicleStatus_id_seq"'::regclass);


--
-- Name: TH_Vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Vehicles" ALTER COLUMN id SET DEFAULT nextval('public."TH_Vehicles_id_seq"'::regclass);


--
-- Data for Name: TH_ActivityLog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_ActivityLog" (id, action, description, "bookingId", "seatNumber", "userName", date, route, "timeSlot", "createdAt") FROM stdin;
1	call_status	Ghế 1 - Sáng: Phòng vé đã gọi	101	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:29:15.113088
2	transfer	Chuyển "Sáng" từ Ghế 1 → Ghế 1	101	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:30	2026-03-29 03:29:39.35494
3	call_status	Ghế 2 - Sang: Phòng vé gọi không nghe	100	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:29:54.85403
4	call_status	Ghế 3 - minh: Phòng vé đã gọi	106	3	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:34:06.960035
5	call_status	Ghế 2 - Sang: Tài xế đã gọi	100	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:35:19.739865
6	call_status	Ghế 2 - Sang: Tài xế đã gọi	100	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:35:22.657367
7	delete	Xóa: Sang - Ghế 2 - SĐT: 0329088302	100	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:37:07.380175
8	transfer	Chuyển "Sáng" từ Ghế 1 → Ghế 2	101	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:37:35.012468
9	call_status	Ghế 2 - Sáng: Chưa gọi	101	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:37:39.448444
10	call_status	Ghế 2 - Sáng: Phòng vé đã gọi	101	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:40:27.880763
11	call_status	Ghế 2 - Sáng: Phòng vé gọi không nghe (04:00)	101	2	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:40:56.593852
12	call_status	Ghế 3 - minh: Số điện thoại không đúng (04:00)	106	3	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:41:03.584766
13	transfer	Chuyển "Sáng" từ Ghế 2 → Ghế 1 - Chuyến 04:30	101	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:30	2026-03-29 03:41:25.292872
14	edit	Sửa: Kim Yến - Ghế 1 - SĐT: 0949994588 - Chuyến 08:00 - Trả: Tại bến	103	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	08:00	2026-03-29 03:41:53.347094
15	call_status	Ghế 1 - Kim Yến: Chưa gọi (08:00)	103	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	08:00	2026-03-29 03:42:22.137552
16	call_status	Ghế 1 - Kim Yến: Tài xế báo hủy (08:00)	103	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	08:00	2026-03-29 03:42:31.025909
17	call_status	Ghế 1 - Kim Yến: Chưa gọi (08:00)	103	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	08:00	2026-03-29 03:42:36.598659
18	edit	Sửa: Kim Yến - Ghế 1 - SĐT: 0949994588 - Chuyến 08:00 - Trả: Tại bến	103	1	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	08:00	2026-03-29 03:53:45.609668
19	call_status	Ghế 3 - minh: Tài xế đã gọi	106	3	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	04:00	2026-03-29 03:54:34.303176
20	add	Thêm: minh - Ghế 3 - SĐT: 0908724146 - Chuyến 03:30 - Trả: 24 - Khu Công Nghệ Cao	\N	3	Quản lý 1	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	03:30	2026-03-29 13:48:35.923002
21	call_status	Ghế 1 - ngọc: Chưa gọi (05:00)	110	1	Quản lý 1	03-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	05:00	2026-04-02 22:02:16.423022
22	call_status	Ghế 1 - ngọc: Chưa gọi (05:00)	110	1	Quản lý 1	03-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	05:00	2026-04-02 22:02:17.069837
23	call_status	Ghế 1 - ngọc: Phòng vé đã gọi (05:00)	110	1	Quản lý 1	03-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	05:00	2026-04-02 22:02:17.878426
24	call_status	Ghế 1 - ngọc: Chưa gọi (05:00)	110	1	Quản lý 1	03-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	05:00	2026-04-02 22:02:20.585132
25	transfer	Chuyển "công" từ Ghế 1 → Ghế 1 - Chuyến 06:00	113	1	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 01:19:05.869817
26	transfer	Chuyển "ngọc" từ Ghế 2 → Ghế 2 - Chuyến 06:00	114	2	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 01:19:06.868211
27	transfer	Chuyển "xuân" từ Ghế 3 → Ghế 3 - Chuyến 06:00	115	3	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 01:19:07.904672
28	transfer	Chuyển "công" từ Ghế 1 → Ghế 1 - Chuyến 09:00	113	1	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	09:00	2026-04-06 01:20:33.948286
29	transfer	Chuyển "công" từ Ghế 1 → Ghế 1 - Chuyến 06:00	113	1	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 05:08:48.553313
30	transfer	Chuyển "thảo" từ Ghế 1 → Ghế 4 - Chuyến 06:00	111	4	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 05:09:08.868249
31	transfer	Chuyển "ngọc" từ Ghế 2 → Ghế 5 - Chuyến 06:00	112	5	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:00	2026-04-06 05:09:09.624849
32	transfer	Chuyển ngọc: Ghế 2 (06:00) → Ghế 1 (06:30)	114	1	Administrator	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	06:30	2026-04-09 01:48:03.153625
33	edit	Sửa vé: vô danh 30,4 - Ghế 2 - SĐT 0786022791 - Chuyến 11:00 - Trả: 36 - Công Viên 30/4	117	2	Administrator	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	11:00	2026-04-09 03:35:46.624175
34	edit	Sửa vé: vô danh - Ghế 2 - SĐT 0786022791 - Chuyến 11:00 - Trả: 36 - Công Viên 30/4	117	2	Administrator	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	11:00	2026-04-09 03:36:16.774425
35	edit	Sửa vé: vô danh - Ghế 2 - SĐT 0786022791 - Chuyến 11:00 - Trả: 36 - Công Viên 30/4	117	2	Administrator	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	11:00	2026-04-09 03:36:20.954858
36	edit	Sửa vé: vô danh - Ghế 2 - SĐT 0786022791 - Chuyến 11:00 - Trả: 36 - Công Viên 30/4	117	2	Administrator	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	11:00	2026-04-09 03:36:56.517697
37	add	Thêm vé: minh - Ghế 1 - SĐT 0908724146 - Chuyến 05:30 - Trả: 24 - Khu Công Nghệ Cao	\N	1	Administrator	11-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	05:30	2026-04-10 23:14:32.045974
38	add	Thêm vé: minh - Ghế 1 - SĐT 0908724146 - Chuyến 17:00 - Trả: 24 - Khu Công Nghệ Cao	\N	1	Administrator	11-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	17:00	2026-04-11 09:52:04.657398
\.


--
-- Data for Name: TH_Bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_Bookings" (id, "timeSlotId", phone, name, gender, nationality, "pickupMethod", "pickupAddress", "dropoffMethod", "dropoffAddress", note, "seatNumber", amount, paid, "timeSlot", date, route, "createdAt", "updatedAt", "callStatus", printed) FROM stdin;
77	31096	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603268604]	1	120000.00	0.00	11:00	26-03-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:22:42.688151	2026-03-26 13:22:42.688151	Chưa gọi	f
78	31012	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603263757]	1	120000.00	0.00	09:00	26-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:23:58.513246	2026-03-26 13:23:58.513246	Chưa gọi	f
79	31012	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603260416]	2	120000.00	0.00	09:00	26-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:24:12.06769	2026-03-26 13:24:12.06769	Chưa gọi	f
94	31511	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603266432]	6	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:53:23.062937	2026-03-26 22:53:23.062937	Chưa gọi	f
76	31432	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603264189]	1	120000.00	0.00	11:00	27-03-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:19:39.739191	2026-03-26 23:25:33.846279	Chưa gọi	f
96	31432	0908724146	minh			Website		Bến xe		[DatVe: VCP202603265547]	3	120000.00	0.00	11:00	27-03-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 23:19:55.261712	2026-03-26 23:41:29.370041	Chưa gọi	f
75	31355	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603267579]	1	120000.00	120000.00	17:00	27-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:17:57.041395	2026-03-26 23:45:40.441348	Chưa gọi	f
102	31775	0977112382	thảo	\N	\N	Tại bến	tại bến	Dọc đường	47. Ngã 3 Trị An	giao thảo 1	1	80000.00	80000.00	08:00	29-03-2026	Sài Gòn- Long Khánh	2026-03-29 00:49:46.423722	2026-03-29 00:49:46.423722	Chưa gọi	f
107	31278	0979189663	thúy đào	\N	\N	Tại bến	tại bến	Dọc đường	36. Công Viên 30/4	giao thúy đào 1 Thùng xốp	1	100000.00	100000.00	10:30	29-03-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-03-29 03:05:40.42182	2026-03-29 03:05:40.42182	Chưa gọi	f
108	31278	0977112382	thảo	\N	\N	Tại bến	tại bến	Dọc đường	47. Ngã 3 Trị An	giao thảo 1 Bao	2	80000.00	80000.00	10:30	29-03-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-03-29 03:06:38.870121	2026-03-29 03:06:38.870121	Chưa gọi	f
103	31639	0949994588	Kim Yến			Tại bến		Tại bến		2 ghế	1	110000.00	0.00	08:00	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-29 00:52:04.134989	2026-03-29 03:53:45.57982	Chưa gọi	f
112	32522	0967503440	ngọc	\N	\N	Tại bến	tại bến	Dọc đường	58. Bưu điện Trảng Bom	giao ngọc 1 Thùng xốp	5	80000.00	80000.00	06:00	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:55:03.919267	2026-04-06 05:09:09.126642	Chưa gọi	f
124	33107	0908724146	minh			Website		Bến xe	24 - Khu Công Nghệ Cao	2 ghế	1	110000.00	0.00	17:00	11-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 09:52:04.660343	2026-04-11 09:52:11.573581	Chưa gọi	t
125	33240	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202604118553]	1	120000.00	0.00	11:00	11-04-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 23:08:58.486408	2026-04-11 23:08:58.486408	Chưa gọi	f
126	33761	0396958081	Bùi Ngọc Hải Tiến			Website		Bến xe		[DatVe: VCP202604269686]	1	120000.00	0.00	13:30	26-04-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-04-26 00:12:14.802783	2026-04-26 00:12:14.802783	Chưa gọi	f
106	31631	0908724146	minh			Website		Bến xe	24 - Khu Công Nghệ Cao	2 ghế	3	110000.00	0.00	04:00	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-29 01:17:12.308791	2026-03-29 03:54:33.733794	Tài xế đã gọi	f
80	31012	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603264970]	3	120000.00	0.00	09:00	26-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:29:13.048865	2026-03-26 13:29:13.048865	Chưa gọi	f
81	31012	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603265636]	4	120000.00	0.00	09:00	26-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:29:32.846615	2026-03-26 13:29:32.846615	Chưa gọi	f
82	31215	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269923]	1	110000.00	0.00	09:00	27-03-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:32:22.276728	2026-03-26 13:32:22.276728	Chưa gọi	f
109	31630	0908724146	minh			Website		Bến xe	24 - Khu Công Nghệ Cao	2 ghế	3	110000.00	0.00	03:30	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-29 13:48:34.413549	2026-03-29 13:48:34.413549	Chưa gọi	f
83	31481	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603260215]	1	130000.00	0.00	05:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:35:04.798007	2026-03-26 13:35:04.798007	Chưa gọi	f
84	31482	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603266458]	1	130000.00	0.00	11:00	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:36:22.16647	2026-03-26 13:36:22.16647	Chưa gọi	f
74	31056	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603263059]	1	120000.00	0.00	18:00	26-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:17:22.103176	2026-03-26 13:17:22.103176	Chưa gọi	f
85	31482	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603261041]	2	130000.00	0.00	11:00	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:36:36.964906	2026-03-26 13:36:36.964906	Chưa gọi	f
86	31483	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603263988]	1	130000.00	0.00	06:00	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:44:54.612671	2026-03-26 13:44:54.612671	Chưa gọi	f
88	31511	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269693]	1	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:32.315023	2026-03-26 22:21:32.315023	Chưa gọi	f
89	31511	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269693]	2	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:32.774525	2026-03-26 22:21:32.774525	Chưa gọi	f
90	31511	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269693]	3	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:33.213601	2026-03-26 22:21:33.213601	Chưa gọi	f
91	31511	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269693]	4	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:33.652927	2026-03-26 22:21:33.652927	Chưa gọi	f
92	31511	0908724146	Lê Quang Minh			Website		Bến xe		[DatVe: VCP202603269693]	5	130000.00	0.00	07:30	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:34.091923	2026-03-26 22:21:34.091923	Chưa gọi	f
93	31482	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603262477]	3	130000.00	0.00	11:00	27-03-2026	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:24:42.202614	2026-03-26 22:24:42.202614	Chưa gọi	f
95	31432	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603260963]	2	120000.00	0.00	11:00	27-03-2026	Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 23:16:49.409598	2026-03-26 23:20:35.285574	Chưa gọi	f
97	31328	0908724146	minh			Website		Bến xe		[DatVe: VCP202603265547]	1	110000.00	0.00	03:30	27-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-27 01:32:16.698307	2026-03-27 01:32:16.698307	Chưa gọi	f
98	31571	0977112382	thảo	\N	\N	Tại bến	tại bến	Dọc đường	47. Ngã 3 Trị An	giao thảo 1 Bao	1	80000.00	80000.00	16:00	28-03-2026	Sài Gòn- Long Khánh	2026-03-28 08:37:46.108968	2026-03-28 08:37:46.108968	Chưa gọi	f
99	31629	1	VÔ DANH KM41	\N	\N	Tại bến	tại bến	Dọc đường	00 - DỌC ĐƯỜNG	giao VÔ DANH KM41 1 Thùng xốp	1	100000.00	100000.00	06:00	29-03-2026	Sài Gòn- Long Khánh	2026-03-28 22:47:39.10848	2026-03-28 22:47:39.10848	Chưa gọi	f
111	32522	0977112382	thảo	\N	\N	Tại bến	tại bến	Dọc đường	47. Ngã 3 Trị An	giao thảo 1 Bao	4	80000.00	80000.00	06:00	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:27.567492	2026-04-06 05:09:08.354205	Chưa gọi	f
119	32653	0919262113	thu	\N	\N	Tại bến	tại bến	Dọc đường	35. Chợ Sặt	giao thu 1 Thùng	4	80000.00	80000.00	11:00	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 03:34:24.411915	2026-04-09 03:34:24.411915	Chưa gọi	f
115	32522	0977687057	xuân	\N	\N	Tại bến	tại bến	Dọc đường	37. Bệnh Viện Thánh Tâm	giao xuân 1 Thùng	3	80000.00	80000.00	06:00	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-06 01:15:28.916085	2026-04-06 01:19:07.393506	Chưa gọi	f
110	31833	0967503440	ngọc	\N	\N	Tại bến	tại bến	Dọc đường	58. Bưu điện Trảng Bom	giao ngọc 1 Thùng xốp	1	100000.00	100000.00	05:00	03-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:01:25.606504	2026-04-02 22:02:20.067211	Chưa gọi	f
104	31641	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603292122]	1	120000.00	0.00	09:00	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-29 01:07:41.589683	2026-03-29 01:07:41.589683	Chưa gọi	f
105	31787	02519999975	Quản trị viên			Website		Bến xe		[DatVe: VCP202603299469]	1	130000.00	0.00	11:00	29-03-2026	Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:51.672314	2026-03-29 01:08:51.672314	Chưa gọi	f
114	32523	0967503440	ngọc	\N	\N	Tại bến	tại bến	Dọc đường	58. Bưu điện Trảng Bom	giao ngọc 2 thùng xốp	1	240000.00	240000.00	06:30	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-06 01:14:51.3208	2026-04-09 01:48:02.611636	Chưa gọi	f
113	32522	0911854535	công	\N	\N	Tại bến	tại bến	Dọc đường	46. Chợ chiều Thanh Hoá	giao công 1 Thùng xốp	1	80000.00	80000.00	06:00	06-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-06 01:14:50.180566	2026-04-06 05:08:46.655574	Chưa gọi	f
101	31632	0329088302	Sáng			Dọc đường	02 - Ngã 4 Trần Phú-Lê Hồng Phong	Tại bến		1 ghế	1	110000.00	0.00	04:30	29-03-2026	Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 23:17:47.976985	2026-03-29 03:41:24.724335	Phòng vé gọi không nghe	f
116	32653	0376670275	loan	\N	\N	Tại bến	tại bến	Dọc đường	51. Nhà thờ Tân Bắc	giao loan 2 thùng	1	240000.00	240000.00	11:00	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 03:32:48.310349	2026-04-09 03:32:48.310349	Chưa gọi	f
118	32653	0967503440	ngọc	\N	\N	Tại bến	tại bến	Dọc đường	58. Bưu điện Trảng Bom	giao ngọc 1 Thùng xốp	3	80000.00	80000.00	11:00	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 03:34:01.027719	2026-04-09 03:34:01.027719	Chưa gọi	f
120	32910	0899465931	đạt a	\N	\N	Tại bến	tại bến	Dọc đường	65. Thu phí Bầu Cá	giao đạt a 1 Bao	1	70000.00	70000.00	06:30	10-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 23:05:59.417843	2026-04-09 23:05:59.417843	Chưa gọi	f
117	32653	0786022791	vô danh	\N	\N	Tại bến	tại bến	Dọc đường	36 - Công Viên 30/4	giao vô danh 1 Thùng	2	100000.00	100000.00	11:00	09-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 03:33:31.438608	2026-04-09 03:36:56.521177	Chưa gọi	f
122	32922	0977112382	thảo	\N	\N	Tại bến	tại bến	Dọc đường	47. Ngã 3 Trị An	giao thảo 1 Bao	2	80000.00	80000.00	12:30	10-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 05:26:25.269147	2026-04-10 05:26:25.269147	Chưa gọi	f
123	33084	0908724146	minh			Website		Bến xe	24 - Khu Công Nghệ Cao	2 ghế	1	110000.00	0.00	05:30	11-04-2026	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:33.504127	2026-04-11 09:51:38.826745	Chưa gọi	t
\.


--
-- Data for Name: TH_CustomerMessages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_CustomerMessages" (id, "requestId", direction, content, "senderName", "senderEmail", "createdAt") FROM stdin;
1	6	out	gì	Administrator	cskh@vocucphuong.com	2026-04-12 00:22:32.817168
2	6	in		lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:22:59.210047
3	6	in		lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:27:50.340233
4	6	in		lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:29:55.505179
5	6	out	con cu	Administrator	cskh@vocucphuong.com	2026-04-12 00:32:38.200611
6	6	in		lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:33:10.874902
7	7	out	điên hả	Administrator	cskh@vocucphuong.com	2026-04-12 00:36:28.651036
8	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:38:18.924619
9	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:41:20.905437
10	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:49:12.851962
11	7	out	cặc	Administrator	cskh@vocucphuong.com	2026-04-12 00:49:15.404007
12	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:49:41.629696
13	7	out	gì	Administrator	cskh@vocucphuong.com	2026-04-12 00:56:59.694149
14	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 00:57:25.124782
15	7	out	quanque	Administrator	cskh@vocucphuong.com	2026-04-12 01:01:05.253946
16	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 01:01:38.475909
17	7	out	cac	Administrator	cskh@vocucphuong.com	2026-04-12 01:05:07.736399
18	7	in	(không có nội dung)	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 01:05:37.936407
19	7	in	📧 Khách đã trả lời qua email (tiêu đề: "Re: [Phản hồi] Hỏi thông tin - Xe Võ Cúc Phương"). Xem nội dung đầy đủ tại hộp thư cskh@vocucphuong.com	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 01:10:31.453923
20	7	out	hello	Administrator	cskh@vocucphuong.com	2026-04-12 04:43:31.553807
21	7	in	📧 Khách trả lời — tiêu đề: "Re: [Phản hồi] Hỏi thông tin - Xe Võ Cúc Phương"	lequangminh951@gmail.com	lequangminh951@gmail.com	2026-04-12 04:44:01.112046
\.


--
-- Data for Name: TH_CustomerRequests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_CustomerRequests" (id, type, name, phone, "bookingRef", message, status, "assignedTo", "adminNote", source, "createdAt", "updatedAt", email, "replyMessage", "repliedAt", "repliedBy") FROM stdin;
7	inquiry	minh	0908724146		[ý kiến ] ádasgasghasgfasg	processing		\N	website	2026-04-12 00:34:32.384352	2026-04-12 04:44:01.34159	lequangminh951@gmail.com	hello	2026-04-12 04:43:31.789367	Administrator
1	inquiry	minh	0908724146		[ý kiến ] hehe	resolved			website	2026-04-09 05:27:33.247954	2026-04-09 22:53:23.832578	\N	\N	\N	\N
2	inquiry	minh	0877414135		[ý kiến] haha	processing		chặn khách này cho trẫm	website	2026-04-09 23:02:40.290412	2026-04-09 23:39:17.897807	mincubu0205@gmail.com	khùng hong	2026-04-09 23:39:17.897807	Administrator
3	inquiry	minh	0908724146		[ý kiến] hahaaaa	processing		\N	website	2026-04-09 23:38:05.834731	2026-04-11 23:00:52.675478	minhcubu020504@gmail.com	cucu	2026-04-11 23:00:52.675478	Administrator
4	inquiry	minh	0908724146		[ý kiến ] cucucucucu	resolved		chặn	website	2026-04-09 23:40:07.081086	2026-04-11 23:02:19.28655	lequangminh951@gmail.com	có điên không	2026-04-11 23:02:19.28655	Administrator
5	inquiry	minh	0908724146		[ý kiến ] uiuiuiuiuiui	new		\N	website	2026-04-12 00:09:47.415501	2026-04-12 00:09:47.415501	lequangminh951@gmail.com	\N	\N	\N
6	inquiry	minh	0908724146		[ý kiến ] 12314a56s4đá	processing		\N	website	2026-04-12 00:22:20.130393	2026-04-12 00:33:11.082461	lequangminh951@gmail.com	con cu	2026-04-12 00:32:38.423186	Administrator
\.


--
-- Data for Name: TH_Drivers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_Drivers" (id, name, phone, "createdAt", "updatedAt") FROM stdin;
24	Khoa A	0906789002	2026-01-25 08:05:28.728084	2026-01-25 08:05:28.728084
25	Tài	0896545442	2026-01-25 08:05:28.730787	2026-01-25 08:05:28.730787
26	Thái B	0886234172	2026-01-25 08:05:28.7357	2026-01-25 08:05:28.7357
27	Chiến B	0908272652	2026-01-25 08:05:28.737432	2026-01-25 08:05:28.737432
29	Tươi	0946224421	2026-01-25 08:05:28.741465	2026-01-25 08:05:28.741465
28	Thanh C	0865402618	2026-01-25 08:05:28.742964	2026-01-25 08:05:28.742964
30	Thắng	0939442227	2026-01-25 08:05:28.752934	2026-01-25 08:05:28.752934
31	Tuấn D	0943485017	2026-01-25 08:05:28.756438	2026-01-25 08:05:28.756438
32	Thành B	0944356062	2026-01-25 08:05:28.762253	2026-01-25 08:05:28.762253
33	Bằng	0917842009	2026-01-25 08:05:28.768391	2026-01-25 08:05:28.768391
34	Hiệp	0987974779	2026-01-25 08:05:28.772852	2026-01-25 08:05:28.772852
35	Khánh	0933338306	2026-01-25 08:05:28.773569	2026-01-25 08:05:28.773569
36	Tú	0933381033	2026-01-25 08:05:28.780508	2026-01-25 08:05:28.780508
38	Quyền	0977563853	2026-01-25 08:05:28.790684	2026-01-25 08:05:28.790684
37	Mỹ	0899959507	2026-01-25 08:05:28.791346	2026-01-25 08:05:28.791346
39	Thành A	0918529169	2026-01-25 08:05:28.795089	2026-01-25 08:05:28.795089
40	Hồng	0912101116	2026-01-25 08:05:28.799185	2026-01-25 08:05:28.799185
41	Luân Tải	0937067244	2026-01-25 08:05:28.803503	2026-01-25 08:05:28.803503
42	Phương	0919189509	2026-01-25 08:05:28.812734	2026-01-25 08:05:28.812734
43	Huy	0707080882	2026-01-25 08:05:28.818147	2026-01-25 08:05:28.818147
45	Sang	0867551191	2026-01-25 08:05:28.823975	2026-01-25 08:05:28.823975
44	Châu	0397399578	2026-01-25 08:05:28.823144	2026-01-25 08:05:28.823144
46	Kiều	 0941710982	2026-01-25 08:05:28.827288	2026-01-25 08:05:28.827288
47	Cường A	0981859216	2026-01-25 08:05:28.828731	2026-01-25 08:05:28.828731
48	Đủ	0336447448	2026-01-25 08:05:28.840176	2026-01-25 08:05:28.840176
49	An	0365018079	2026-01-25 08:05:28.85064	2026-01-25 08:05:28.85064
50	Vũ	0828959161	2026-01-25 08:05:28.851855	2026-01-25 08:05:28.851855
52	Hùng H	0986757007	2026-01-25 08:05:28.863034	2026-01-25 08:05:28.863034
51	Tuấn Bãi	0853052016	2026-01-25 08:05:28.861715	2026-01-25 08:05:28.861715
53	Khương	0917050200	2026-01-25 08:05:28.87051	2026-01-25 08:05:28.87051
54	Hùng Râu	  0362766839	2026-01-25 08:05:28.869469	2026-01-25 08:05:28.869469
55	Nhân B	 0908323315	2026-01-25 08:05:28.8801	2026-01-25 08:05:28.8801
56	Sỹ	0972032838	2026-01-25 08:05:28.886039	2026-01-25 08:05:28.886039
57	Thanh Bắc	0918026316	2026-01-25 08:05:28.893843	2026-01-25 08:05:28.893843
58	Khiêm	0918334999	2026-01-25 08:05:28.899598	2026-01-25 08:05:28.899598
59	Hiếu A	0934648601	2026-01-25 08:05:28.907396	2026-01-25 08:05:28.907396
60	Ẩn	0915998441	2026-01-25 08:05:28.912583	2026-01-25 08:05:28.912583
61	Ân	0919949093	2026-01-25 08:05:28.919645	2026-01-25 08:05:28.919645
62	Hồ	0961763128	2026-01-25 08:05:28.929896	2026-01-25 08:05:28.929896
64	Trí	0937250697	2026-01-25 08:05:28.933436	2026-01-25 08:05:28.933436
63	Sơn	0979391020	2026-01-25 08:05:28.932433	2026-01-25 08:05:28.932433
65	Hùng S	0918911239	2026-01-25 08:05:28.940934	2026-01-25 08:05:28.940934
66	Tiến	0967554875	2026-01-25 08:05:28.944396	2026-01-25 08:05:28.944396
68	Phong M	0978293459	2026-01-25 08:05:28.95287	2026-01-25 08:05:28.95287
67	Thuận	0931773922	2026-01-25 08:05:28.953215	2026-01-25 08:05:28.953215
69	Tuấn M	0907632900	2026-01-25 08:05:28.955858	2026-01-25 08:05:28.955858
70	Luân M	0908481060	2026-01-25 08:05:28.962977	2026-01-25 08:05:28.962977
72	Cường M	0789202368	2026-01-25 08:05:28.974548	2026-01-25 08:05:28.974548
71	Tuấn X	0866213424	2026-01-25 08:05:28.974978	2026-01-25 08:05:28.974978
73	Công	0903637191	2026-01-25 08:05:28.981283	2026-01-25 08:05:28.981283
75	Phú C	0971686386	2026-01-25 08:05:28.985537	2026-01-25 08:05:28.985537
74	Hùng B	0977602116	2026-01-25 08:05:28.983824	2026-01-25 08:05:28.983824
76	Long	  0974918551	2026-01-25 08:05:28.995124	2026-01-25 08:05:28.995124
77	Thụy	0975201508	2026-01-25 08:05:28.992649	2026-01-25 08:05:28.992649
79	Minh M	0344255898	2026-01-25 08:05:29.006727	2026-01-25 08:05:29.006727
78	Khánh M	0973676980	2026-01-25 08:05:29.004015	2026-01-25 08:05:29.004015
80	Tuấn N	  0925379879	2026-01-25 08:05:29.007827	2026-01-25 08:05:29.007827
81	Năm Cắt	0908494277	2026-01-25 08:05:29.011407	2026-01-25 08:05:29.011407
82	Tuấn X	0939291382	2026-04-09 01:33:00.163897	2026-04-09 01:33:00.163897
\.


--
-- Data for Name: TH_Routes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_Routes" (id, name, "routeType", price, duration, "isActive", "createdAt", "updatedAt", "fromStation", "toStation", "busType", seats, distance, "operatingStart", "operatingEnd", "intervalMinutes") FROM stdin;
4	Long Khánh - Sài Gòn (Cao tốc)	cao_toc	120000.00	1.5 giờ	t	2026-03-26 10:08:38.588855	2026-03-26 10:08:38.588855	Long Khánh	Sài Gòn	Ghế ngồi	28	80 km	03:30	18:00	30
5	Long Khánh - Sài Gòn (Quốc lộ)	quoc_lo	110000.00	2 giờ	t	2026-03-26 10:08:38.588855	2026-03-26 10:08:38.588855	Long Khánh	Sài Gòn	Ghế ngồi	28	80 km	03:30	18:00	30
6	Sài Gòn - Long Khánh (Cao tốc)	cao_toc	120000.00	1.5 giờ	t	2026-03-26 10:08:38.588855	2026-03-26 10:08:38.588855	Sài Gòn	Long Khánh	Ghế ngồi	28	80 km	05:30	20:00	30
7	Sài Gòn - Long Khánh (Quốc lộ)	quoc_lo	110000.00	~ 2 giờ 30 phút	t	2026-03-26 10:08:38.588855	2026-03-26 10:08:38.588855	Sài Gòn	Long Khánh	Ghế ngồi	28	80 km	05:30	20:00	30
13	Sài Gòn - Xuân Lộc (Cao tốc)	cao_toc	130000.00	2 giờ ~ 4 giờ	t	2026-03-26 10:38:49.726306	2026-03-26 10:38:49.726306	Sài Gòn	Xuân Lộc	Ghế ngồi	28	80 km	05:30	18:30	30
14	Sài Gòn - Xuân Lộc (Quốc lộ)	quoc_lo	130000.00	1.5 giờ ~ 4 tiếng	t	2026-03-26 10:38:50.56049	2026-03-26 13:00:01.03738	Sài Gòn	Xuân Lộc	Ghế ngồi	28	110 km	05:30	06:30	30
15	Xuân Lộc - Sài Gòn (Cao tốc)	cao_toc	150000.00	3 giờ	t	2026-03-26 10:38:51.4189	2026-03-26 13:00:27.321412	Xuân Lộc	Sài Gòn	Ghế ngồi	28	110 km	03:30	17:00	30
16	Xuân Lộc - Sài Gòn (Quốc lộ)	quoc_lo	140000.00	4 giờ	t	2026-03-26 10:38:52.251173	2026-03-26 13:00:54.07607	Xuân Lộc	Sài Gòn	Ghế ngồi	28	80 km	03:30	17:00	30
\.


--
-- Data for Name: TH_SeatLocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_SeatLocks" (id, "timeSlotId", "seatNumber", "lockedBy", "lockedByUserId", "lockedAt", "expiresAt", date, route) FROM stdin;
\.


--
-- Data for Name: TH_StaffTasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_StaffTasks" (id, title, description, "assignedTo", "createdBy", date, "dueTime", status, priority, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: TH_TimeSlots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_TimeSlots" (id, "time", date, type, code, driver, phone, route, "createdAt", "updatedAt") FROM stdin;
31421	05:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:01.221521	2026-03-26 13:18:01.221521
31422	06:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:01.659557	2026-03-26 13:18:01.659557
31423	06:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:02.098305	2026-03-26 13:18:02.098305
31424	07:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:02.53661	2026-03-26 13:18:02.53661
31425	07:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:02.973924	2026-03-26 13:18:02.973924
31426	08:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:03.411817	2026-03-26 13:18:03.411817
31427	08:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:03.850009	2026-03-26 13:18:03.850009
31428	09:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:04.287942	2026-03-26 13:18:04.287942
31429	09:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:04.725909	2026-03-26 13:18:04.725909
31430	10:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:05.163733	2026-03-26 13:18:05.163733
31431	10:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:05.602392	2026-03-26 13:18:05.602392
31432	11:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:06.040502	2026-03-26 13:18:06.040502
31433	11:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:06.479217	2026-03-26 13:18:06.479217
31434	12:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:06.917305	2026-03-26 13:18:06.917305
31435	12:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:07.354722	2026-03-26 13:18:07.354722
31436	13:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:07.793395	2026-03-26 13:18:07.793395
31437	13:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:08.231183	2026-03-26 13:18:08.231183
31438	14:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:08.669241	2026-03-26 13:18:08.669241
31439	14:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:09.107099	2026-03-26 13:18:09.107099
31440	15:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:09.545026	2026-03-26 13:18:09.545026
31441	15:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:09.982959	2026-03-26 13:18:09.982959
31442	16:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:10.421221	2026-03-26 13:18:10.421221
31443	16:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:10.858974	2026-03-26 13:18:10.858974
31444	17:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:11.29697	2026-03-26 13:18:11.29697
31445	17:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:11.735387	2026-03-26 13:18:11.735387
31446	18:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:12.173221	2026-03-26 13:18:12.173221
31447	18:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:12.610937	2026-03-26 13:18:12.610937
31448	19:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:13.048625	2026-03-26 13:18:13.048625
31449	19:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:13.495087	2026-03-26 13:18:13.495087
31450	20:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:18:13.932853	2026-03-26 13:18:13.932853
31451	03:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:49.314234	2026-03-26 13:33:49.314234
31452	04:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:49.757263	2026-03-26 13:33:49.757263
31453	04:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:50.199687	2026-03-26 13:33:50.199687
31454	05:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:50.642453	2026-03-26 13:33:50.642453
31455	05:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:51.084893	2026-03-26 13:33:51.084893
31456	06:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:51.527961	2026-03-26 13:33:51.527961
31457	06:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:51.970205	2026-03-26 13:33:51.970205
31458	07:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:52.412328	2026-03-26 13:33:52.412328
31459	07:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:52.854716	2026-03-26 13:33:52.854716
31460	08:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:53.297568	2026-03-26 13:33:53.297568
31461	08:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:53.740054	2026-03-26 13:33:53.740054
31462	09:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:54.182383	2026-03-26 13:33:54.182383
31463	09:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:54.62509	2026-03-26 13:33:54.62509
31464	10:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:55.068302	2026-03-26 13:33:55.068302
31465	10:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:55.510337	2026-03-26 13:33:55.510337
31466	11:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:55.951867	2026-03-26 13:33:55.951867
31467	11:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:56.393971	2026-03-26 13:33:56.393971
31468	12:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:56.836508	2026-03-26 13:33:56.836508
31469	12:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:57.278991	2026-03-26 13:33:57.278991
31470	13:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:57.721448	2026-03-26 13:33:57.721448
31471	13:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:58.164278	2026-03-26 13:33:58.164278
31472	14:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:58.60639	2026-03-26 13:33:58.60639
31473	14:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:59.049407	2026-03-26 13:33:59.049407
31474	15:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:59.491413	2026-03-26 13:33:59.491413
31475	15:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:33:59.933581	2026-03-26 13:33:59.933581
31476	16:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:34:00.375479	2026-03-26 13:34:00.375479
31477	16:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:34:00.819816	2026-03-26 13:34:00.819816
31478	17:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:34:01.262731	2026-03-26 13:34:01.262731
31479	17:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:34:01.70583	2026-03-26 13:34:01.70583
31480	18:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:34:02.148909	2026-03-26 13:34:02.148909
31481	05:30	27-03-2026	Xe 28G	\N	\N	\N	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:35:04.356697	2026-03-26 13:35:04.356697
31482	11:00	27-03-2026	Xe 28G	\N	\N	\N	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:36:21.712428	2026-03-26 13:36:21.712428
31483	06:00	27-03-2026	Xe 28G	\N	\N	\N	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 13:44:54.167364	2026-03-26 13:44:54.167364
31511	07:30	27-03-2026	Xe 28G	\N	\N	\N	Quốc Lộ 1A - Xuân Lộc (Quốc lộ)	2026-03-26 22:21:31.862566	2026-03-26 22:21:31.862566
31512	03:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:45.887162	2026-03-26 22:22:45.887162
31513	04:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:46.321819	2026-03-26 22:22:46.321819
31514	04:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:46.755472	2026-03-26 22:22:46.755472
31515	05:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:47.190036	2026-03-26 22:22:47.190036
31516	05:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:47.623943	2026-03-26 22:22:47.623943
31517	06:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:48.057327	2026-03-26 22:22:48.057327
31484	05:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:35.540298	2026-03-26 13:46:35.540298
31485	06:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:35.99868	2026-03-26 13:46:35.99868
31486	06:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:36.456196	2026-03-26 13:46:36.456196
31487	07:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:36.914182	2026-03-26 13:46:36.914182
31488	07:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:37.371824	2026-03-26 13:46:37.371824
31489	08:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:37.829404	2026-03-26 13:46:37.829404
31490	08:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:38.287023	2026-03-26 13:46:38.287023
31491	09:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:38.744605	2026-03-26 13:46:38.744605
31492	09:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:39.202676	2026-03-26 13:46:39.202676
31493	10:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:39.660097	2026-03-26 13:46:39.660097
31494	10:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:40.118501	2026-03-26 13:46:40.118501
31495	11:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:40.576036	2026-03-26 13:46:40.576036
31496	11:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:41.033336	2026-03-26 13:46:41.033336
31497	12:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:41.491645	2026-03-26 13:46:41.491645
31498	12:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:41.949011	2026-03-26 13:46:41.949011
31499	13:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:42.406963	2026-03-26 13:46:42.406963
31500	13:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:42.864584	2026-03-26 13:46:42.864584
31501	14:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:43.32249	2026-03-26 13:46:43.32249
31502	14:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:43.779851	2026-03-26 13:46:43.779851
31503	15:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:44.236986	2026-03-26 13:46:44.236986
31504	15:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:44.6952	2026-03-26 13:46:44.6952
31505	16:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:45.15274	2026-03-26 13:46:45.15274
31506	16:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:45.61022	2026-03-26 13:46:45.61022
31507	17:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:46.073493	2026-03-26 13:46:46.073493
31508	17:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:46.541535	2026-03-26 13:46:46.541535
31509	18:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:46.998781	2026-03-26 13:46:46.998781
31510	18:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 13:46:47.455939	2026-03-26 13:46:47.455939
31518	06:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:48.490905	2026-03-26 22:22:48.490905
31519	07:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:48.924683	2026-03-26 22:22:48.924683
31520	07:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:49.358873	2026-03-26 22:22:49.358873
31521	08:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:49.792896	2026-03-26 22:22:49.792896
31522	08:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:50.226534	2026-03-26 22:22:50.226534
31523	09:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:50.66072	2026-03-26 22:22:50.66072
31524	09:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:51.098073	2026-03-26 22:22:51.098073
31525	10:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:51.531749	2026-03-26 22:22:51.531749
31526	10:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:51.965288	2026-03-26 22:22:51.965288
31527	11:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:52.398699	2026-03-26 22:22:52.398699
31528	11:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:52.833694	2026-03-26 22:22:52.833694
31529	12:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:53.26734	2026-03-26 22:22:53.26734
31530	12:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:53.701166	2026-03-26 22:22:53.701166
31531	13:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:54.135117	2026-03-26 22:22:54.135117
31532	13:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:54.570543	2026-03-26 22:22:54.570543
31533	14:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:55.004135	2026-03-26 22:22:55.004135
31534	14:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:55.437574	2026-03-26 22:22:55.437574
31535	15:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:55.870929	2026-03-26 22:22:55.870929
31536	15:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:56.304422	2026-03-26 22:22:56.304422
31537	16:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:56.738237	2026-03-26 22:22:56.738237
31538	16:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:57.175642	2026-03-26 22:22:57.175642
31539	17:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-26 22:22:57.609651	2026-03-26 22:22:57.609651
32878	03:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32879	04:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32880	04:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32881	05:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32882	05:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32883	06:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32884	06:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32885	07:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32886	07:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32887	08:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32888	08:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32889	09:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32890	09:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32891	10:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32892	10:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32893	11:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32894	11:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32895	12:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32896	12:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32897	13:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32898	13:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
31540	05:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-26 22:23:46.254275	2026-03-26 22:23:46.254275
31541	06:00	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-26 22:23:46.714996	2026-03-26 22:23:46.714996
31542	06:30	27-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-26 22:23:47.175556	2026-03-26 22:23:47.175556
31543	03:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:55.931612	2026-03-26 22:23:55.931612
31544	04:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:56.391991	2026-03-26 22:23:56.391991
31545	04:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:56.852236	2026-03-26 22:23:56.852236
31546	05:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:57.312386	2026-03-26 22:23:57.312386
31547	05:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:57.772817	2026-03-26 22:23:57.772817
31548	06:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:58.233213	2026-03-26 22:23:58.233213
31549	06:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:58.693675	2026-03-26 22:23:58.693675
31550	07:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:59.154326	2026-03-26 22:23:59.154326
31551	07:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:23:59.614926	2026-03-26 22:23:59.614926
31552	08:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:00.075191	2026-03-26 22:24:00.075191
31553	08:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:00.537585	2026-03-26 22:24:00.537585
31554	09:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:01.002931	2026-03-26 22:24:01.002931
31555	09:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:01.463679	2026-03-26 22:24:01.463679
31556	10:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:01.924116	2026-03-26 22:24:01.924116
31557	10:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:02.384311	2026-03-26 22:24:02.384311
31558	11:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:02.844614	2026-03-26 22:24:02.844614
31559	11:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:03.304861	2026-03-26 22:24:03.304861
31560	12:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:03.765239	2026-03-26 22:24:03.765239
31561	12:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:04.229443	2026-03-26 22:24:04.229443
31562	13:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:04.690404	2026-03-26 22:24:04.690404
31563	13:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:05.151149	2026-03-26 22:24:05.151149
31564	14:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:05.616269	2026-03-26 22:24:05.616269
31565	14:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:06.076922	2026-03-26 22:24:06.076922
31566	15:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:06.537438	2026-03-26 22:24:06.537438
31567	15:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:06.997883	2026-03-26 22:24:06.997883
31568	16:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:07.458341	2026-03-26 22:24:07.458341
31569	16:30	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:07.918934	2026-03-26 22:24:07.918934
31570	17:00	27-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-26 22:24:08.381411	2026-03-26 22:24:08.381411
32899	14:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32900	14:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32901	15:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32902	15:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32903	16:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32904	16:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32905	17:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32906	17:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32907	18:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 22:53:11.749098	2026-04-09 22:53:11.749098
32908	05:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32909	06:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32910	06:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32911	07:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32912	07:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32913	08:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32914	08:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32915	09:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32916	09:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32917	10:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32918	10:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32919	11:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32920	11:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32921	12:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32922	12:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32923	13:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32924	13:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32925	14:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32926	14:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32927	15:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32928	15:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32929	16:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32930	16:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32931	17:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32932	17:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32933	18:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32934	18:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32935	19:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32936	19:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
32937	20:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 22:57:17.278449	2026-04-09 22:57:17.278449
31355	17:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:51.574757	2026-03-27 01:06:47.207412
31571	16:00	28-03-2026	Xe 28G	\N	\N	\N	Sài Gòn- Long Khánh	2026-03-28 08:37:45.629278	2026-03-28 08:37:45.629278
31572	03:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:53.350542	2026-03-28 08:37:53.350542
31573	04:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:53.797196	2026-03-28 08:37:53.797196
31574	04:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:54.242814	2026-03-28 08:37:54.242814
31575	05:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:54.688266	2026-03-28 08:37:54.688266
31576	05:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:55.133305	2026-03-28 08:37:55.133305
31577	06:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:55.578535	2026-03-28 08:37:55.578535
31578	06:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:56.023435	2026-03-28 08:37:56.023435
31579	07:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:56.469257	2026-03-28 08:37:56.469257
31580	07:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:56.914354	2026-03-28 08:37:56.914354
31581	08:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:57.359535	2026-03-28 08:37:57.359535
31582	08:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:57.80514	2026-03-28 08:37:57.80514
31583	09:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:58.250083	2026-03-28 08:37:58.250083
31584	09:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:58.6956	2026-03-28 08:37:58.6956
31585	10:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:59.140646	2026-03-28 08:37:59.140646
31586	10:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:37:59.585873	2026-03-28 08:37:59.585873
31587	11:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:00.030847	2026-03-28 08:38:00.030847
31588	11:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:00.476194	2026-03-28 08:38:00.476194
31589	12:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:00.921288	2026-03-28 08:38:00.921288
31590	12:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:01.367535	2026-03-28 08:38:01.367535
31591	13:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:01.812734	2026-03-28 08:38:01.812734
31592	13:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:02.258394	2026-03-28 08:38:02.258394
31593	14:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:02.703479	2026-03-28 08:38:02.703479
31594	14:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:03.148978	2026-03-28 08:38:03.148978
31595	15:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:03.594198	2026-03-28 08:38:03.594198
31596	15:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:04.039537	2026-03-28 08:38:04.039537
31597	16:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:04.48486	2026-03-28 08:38:04.48486
31598	16:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:04.930405	2026-03-28 08:38:04.930405
31599	17:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:05.375683	2026-03-28 08:38:05.375683
31600	17:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:05.820805	2026-03-28 08:38:05.820805
31601	18:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-28 08:38:06.266267	2026-03-28 08:38:06.266267
31602	05:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:10.97933	2026-03-28 08:38:10.97933
31603	06:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:11.424488	2026-03-28 08:38:11.424488
31604	06:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:11.869821	2026-03-28 08:38:11.869821
31605	07:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:12.315287	2026-03-28 08:38:12.315287
31606	07:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:12.760687	2026-03-28 08:38:12.760687
31607	08:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:13.206028	2026-03-28 08:38:13.206028
31608	08:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:13.651241	2026-03-28 08:38:13.651241
31609	09:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:14.096412	2026-03-28 08:38:14.096412
31610	09:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:14.541293	2026-03-28 08:38:14.541293
31611	10:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:14.986546	2026-03-28 08:38:14.986546
31612	10:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:15.436275	2026-03-28 08:38:15.436275
31613	11:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:15.881676	2026-03-28 08:38:15.881676
31614	11:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:16.32665	2026-03-28 08:38:16.32665
31615	12:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:16.771972	2026-03-28 08:38:16.771972
31616	12:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:17.216853	2026-03-28 08:38:17.216853
31617	13:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:17.661859	2026-03-28 08:38:17.661859
31618	13:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:18.10678	2026-03-28 08:38:18.10678
31619	14:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:18.551684	2026-03-28 08:38:18.551684
31620	14:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:18.997346	2026-03-28 08:38:18.997346
31621	15:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:19.44243	2026-03-28 08:38:19.44243
31622	15:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:19.8874	2026-03-28 08:38:19.8874
31623	16:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:20.332888	2026-03-28 08:38:20.332888
31624	16:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:20.778253	2026-03-28 08:38:20.778253
31625	17:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:21.223067	2026-03-28 08:38:21.223067
31626	17:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:21.66801	2026-03-28 08:38:21.66801
31627	18:00	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:22.114107	2026-03-28 08:38:22.114107
31628	18:30	28-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-28 08:38:22.559199	2026-03-28 08:38:22.559199
31629	06:00	29-03-2026	Xe 28G	\N	\N	\N	Sài Gòn- Long Khánh	2026-03-28 22:47:30.178882	2026-03-28 22:47:30.178882
31630	03:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:14.865566	2026-03-28 22:52:14.865566
31631	04:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:15.296882	2026-03-28 22:52:15.296882
31632	04:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:15.728165	2026-03-28 22:52:15.728165
31633	05:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:16.159762	2026-03-28 22:52:16.159762
31634	05:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:16.590422	2026-03-28 22:52:16.590422
31635	06:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:17.021038	2026-03-28 22:52:17.021038
31636	06:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:17.451519	2026-03-28 22:52:17.451519
31637	07:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:17.88248	2026-03-28 22:52:17.88248
31638	07:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:18.312999	2026-03-28 22:52:18.312999
32938	03:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
31639	08:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:18.743952	2026-03-28 22:52:18.743952
31640	08:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:19.17719	2026-03-28 22:52:19.17719
31641	09:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:19.607991	2026-03-28 22:52:19.607991
31642	09:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:20.038699	2026-03-28 22:52:20.038699
31643	10:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:20.469808	2026-03-28 22:52:20.469808
31644	10:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:20.900498	2026-03-28 22:52:20.900498
31645	11:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:21.330926	2026-03-28 22:52:21.330926
31646	11:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:21.761336	2026-03-28 22:52:21.761336
31647	12:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:22.191799	2026-03-28 22:52:22.191799
31648	12:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:22.622404	2026-03-28 22:52:22.622404
31649	13:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:23.052836	2026-03-28 22:52:23.052836
31650	13:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:23.483337	2026-03-28 22:52:23.483337
31651	14:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:23.914056	2026-03-28 22:52:23.914056
31652	14:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:24.344726	2026-03-28 22:52:24.344726
31653	15:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:24.775228	2026-03-28 22:52:24.775228
31654	15:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:25.206159	2026-03-28 22:52:25.206159
31655	16:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:25.63769	2026-03-28 22:52:25.63769
31656	16:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:26.068233	2026-03-28 22:52:26.068233
31657	17:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:26.498693	2026-03-28 22:52:26.498693
31658	17:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:26.929072	2026-03-28 22:52:26.929072
31659	18:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-28 22:52:27.359305	2026-03-28 22:52:27.359305
32939	04:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32940	04:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32941	05:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32942	05:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32943	06:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32944	06:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32945	07:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32946	07:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32947	08:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32948	08:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32949	09:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32950	09:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32951	10:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32952	10:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32953	11:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32954	11:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32955	12:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32956	12:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32957	13:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32958	13:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32959	14:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32960	14:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32961	15:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32962	15:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32963	16:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32964	16:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32965	17:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32966	17:30	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32967	18:00	10-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 22:59:53.705473	2026-04-09 22:59:53.705473
32968	05:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32969	06:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32970	06:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32971	07:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32972	07:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32973	08:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32974	08:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32975	09:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32976	09:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32977	10:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32978	10:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32979	11:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32980	11:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32981	12:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32982	12:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32983	13:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32984	13:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32985	14:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32986	14:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32987	15:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
31660	05:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-28 22:52:57.002446	2026-03-28 22:52:57.002446
31661	06:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-28 22:52:57.44585	2026-03-28 22:52:57.44585
31662	06:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-03-28 22:52:57.889361	2026-03-28 22:52:57.889361
31663	03:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:04.753616	2026-03-28 22:53:04.753616
31664	04:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:05.19662	2026-03-28 22:53:05.19662
31665	04:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:05.640163	2026-03-28 22:53:05.640163
31666	05:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:06.083191	2026-03-28 22:53:06.083191
31667	05:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:06.526221	2026-03-28 22:53:06.526221
31668	06:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:06.969963	2026-03-28 22:53:06.969963
31669	06:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:07.412994	2026-03-28 22:53:07.412994
31670	07:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:07.856038	2026-03-28 22:53:07.856038
31671	07:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:08.299301	2026-03-28 22:53:08.299301
31672	08:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:08.74333	2026-03-28 22:53:08.74333
31673	08:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:09.186596	2026-03-28 22:53:09.186596
31674	09:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:09.630124	2026-03-28 22:53:09.630124
31675	09:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:10.073257	2026-03-28 22:53:10.073257
31676	10:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:10.517544	2026-03-28 22:53:10.517544
31677	10:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:10.96074	2026-03-28 22:53:10.96074
31678	11:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:11.403793	2026-03-28 22:53:11.403793
31679	11:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:11.847127	2026-03-28 22:53:11.847127
31680	12:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:12.29037	2026-03-28 22:53:12.29037
31681	12:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:12.733373	2026-03-28 22:53:12.733373
31682	13:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:13.176238	2026-03-28 22:53:13.176238
31683	13:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:13.619373	2026-03-28 22:53:13.619373
31684	14:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:14.062819	2026-03-28 22:53:14.062819
31685	14:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:14.505822	2026-03-28 22:53:14.505822
31686	15:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:14.949025	2026-03-28 22:53:14.949025
31687	15:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:15.392065	2026-03-28 22:53:15.392065
31688	16:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:15.83516	2026-03-28 22:53:15.83516
31689	16:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:16.28819	2026-03-28 22:53:16.28819
31690	17:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-03-28 22:53:16.731616	2026-03-28 22:53:16.731616
31691	03:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:18.275107	2026-03-28 22:55:18.275107
31692	04:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:18.693509	2026-03-28 22:55:18.693509
31693	04:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:19.112272	2026-03-28 22:55:19.112272
31694	05:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:19.530657	2026-03-28 22:55:19.530657
31695	05:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:19.949468	2026-03-28 22:55:19.949468
31696	06:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:20.368034	2026-03-28 22:55:20.368034
31697	06:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:20.786273	2026-03-28 22:55:20.786273
31698	07:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:21.204481	2026-03-28 22:55:21.204481
31699	07:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:21.622954	2026-03-28 22:55:21.622954
31700	08:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:22.041254	2026-03-28 22:55:22.041254
31701	08:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:22.459479	2026-03-28 22:55:22.459479
31702	09:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:22.877826	2026-03-28 22:55:22.877826
31703	09:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:23.29659	2026-03-28 22:55:23.29659
31704	10:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:23.715392	2026-03-28 22:55:23.715392
31705	10:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:24.133899	2026-03-28 22:55:24.133899
31706	11:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:24.552496	2026-03-28 22:55:24.552496
31707	11:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:24.978879	2026-03-28 22:55:24.978879
31708	12:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:25.398319	2026-03-28 22:55:25.398319
31709	12:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:25.817681	2026-03-28 22:55:25.817681
31710	13:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:26.235944	2026-03-28 22:55:26.235944
31711	13:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:26.654116	2026-03-28 22:55:26.654116
31712	14:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:27.072794	2026-03-28 22:55:27.072794
31713	14:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:27.491069	2026-03-28 22:55:27.491069
31714	15:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:27.909315	2026-03-28 22:55:27.909315
31715	15:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:28.328959	2026-03-28 22:55:28.328959
31716	16:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:28.747475	2026-03-28 22:55:28.747475
31717	16:30	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:29.166407	2026-03-28 22:55:29.166407
31718	17:00	29-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 22:55:29.595976	2026-03-28 22:55:29.595976
31719	03:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:06.618688	2026-03-28 23:11:06.618688
31720	04:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:07.143475	2026-03-28 23:11:07.143475
31721	04:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:07.590778	2026-03-28 23:11:07.590778
31722	03:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:07.984858	2026-03-28 23:11:07.984858
31723	05:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:08.041693	2026-03-28 23:11:08.041693
31724	04:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:08.446475	2026-03-28 23:11:08.446475
31725	05:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:08.494018	2026-03-28 23:11:08.494018
31726	04:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:08.899911	2026-03-28 23:11:08.899911
31727	06:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:08.945897	2026-03-28 23:11:08.945897
31728	05:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:09.353811	2026-03-28 23:11:09.353811
31729	06:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:09.393097	2026-03-28 23:11:09.393097
31730	05:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:09.807398	2026-03-28 23:11:09.807398
31731	07:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:09.839996	2026-03-28 23:11:09.839996
31732	06:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:10.261201	2026-03-28 23:11:10.261201
31733	07:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:10.28952	2026-03-28 23:11:10.28952
31734	06:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:10.715817	2026-03-28 23:11:10.715817
31735	08:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:10.736305	2026-03-28 23:11:10.736305
31736	07:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:11.16972	2026-03-28 23:11:11.16972
31737	08:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:11.182769	2026-03-28 23:11:11.182769
31738	07:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:11.625574	2026-03-28 23:11:11.625574
31739	09:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:11.629067	2026-03-28 23:11:11.629067
31740	09:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.075738	2026-03-28 23:11:12.075738
31741	08:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.079407	2026-03-28 23:11:12.079407
31742	10:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.522656	2026-03-28 23:11:12.522656
31743	08:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.532812	2026-03-28 23:11:12.532812
31744	10:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.968862	2026-03-28 23:11:12.968862
31745	09:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:12.986093	2026-03-28 23:11:12.986093
31746	11:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:13.417042	2026-03-28 23:11:13.417042
31747	09:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:13.439851	2026-03-28 23:11:13.439851
31748	11:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:13.867226	2026-03-28 23:11:13.867226
31749	10:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:13.892956	2026-03-28 23:11:13.892956
31750	12:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:14.313652	2026-03-28 23:11:14.313652
31751	10:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:14.34626	2026-03-28 23:11:14.34626
31752	12:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:14.760277	2026-03-28 23:11:14.760277
31753	11:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:14.800037	2026-03-28 23:11:14.800037
31754	13:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:15.207115	2026-03-28 23:11:15.207115
31755	11:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:15.254113	2026-03-28 23:11:15.254113
31756	13:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:15.653361	2026-03-28 23:11:15.653361
31757	12:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:15.707539	2026-03-28 23:11:15.707539
31758	14:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:16.100192	2026-03-28 23:11:16.100192
31759	12:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:16.161137	2026-03-28 23:11:16.161137
31760	14:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:16.546118	2026-03-28 23:11:16.546118
31761	13:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:16.615919	2026-03-28 23:11:16.615919
31762	15:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:16.996801	2026-03-28 23:11:16.996801
31763	13:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:17.069291	2026-03-28 23:11:17.069291
31764	15:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:17.44343	2026-03-28 23:11:17.44343
31765	14:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:17.523826	2026-03-28 23:11:17.523826
31766	16:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:17.89121	2026-03-28 23:11:17.89121
31767	14:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:17.978039	2026-03-28 23:11:17.978039
31768	16:30	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:18.341306	2026-03-28 23:11:18.341306
31769	15:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:18.431944	2026-03-28 23:11:18.431944
31770	17:00	30-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:18.787957	2026-03-28 23:11:18.787957
31771	15:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:18.885498	2026-03-28 23:11:18.885498
31772	16:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:19.339115	2026-03-28 23:11:19.339115
31773	16:30	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:19.793143	2026-03-28 23:11:19.793143
31774	17:00	28-03-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-03-28 23:11:20.246948	2026-03-28 23:11:20.246948
32988	15:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32989	16:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32990	16:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32991	17:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32992	17:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32993	18:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32994	18:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32995	19:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32996	19:30	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32997	20:00	10-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 22:59:54.399925	2026-04-09 22:59:54.399925
32998	05:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
32999	06:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33000	06:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33001	07:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33002	07:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33003	08:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33004	08:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33005	09:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33006	09:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33007	10:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33008	10:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33009	11:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33010	11:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33011	12:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33012	12:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
31775	08:00	29-03-2026	Xe 28G	\N	\N	\N	Sài Gòn- Long Khánh	2026-03-29 00:49:45.97567	2026-03-29 00:49:45.97567
31833	05:00	03-04-2026	Xe 28G	\N	\N	\N	Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:01:25.120729	2026-04-02 22:01:25.120729
31834	03:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:29.143449	2026-04-02 22:01:29.143449
31835	04:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:29.598179	2026-04-02 22:01:29.598179
31836	04:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:30.052788	2026-04-02 22:01:30.052788
31837	05:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:30.507195	2026-04-02 22:01:30.507195
31838	05:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:30.961486	2026-04-02 22:01:30.961486
31839	06:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:31.416349	2026-04-02 22:01:31.416349
31840	06:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:31.87045	2026-04-02 22:01:31.87045
31841	07:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:32.324959	2026-04-02 22:01:32.324959
31842	07:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:32.778918	2026-04-02 22:01:32.778918
31843	08:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:33.233043	2026-04-02 22:01:33.233043
31844	08:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:33.688464	2026-04-02 22:01:33.688464
31845	09:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:34.142793	2026-04-02 22:01:34.142793
31846	09:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:34.598605	2026-04-02 22:01:34.598605
31847	10:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:35.05319	2026-04-02 22:01:35.05319
31848	10:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:35.507441	2026-04-02 22:01:35.507441
31849	11:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:35.961841	2026-04-02 22:01:35.961841
31850	11:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:36.416136	2026-04-02 22:01:36.416136
31851	12:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:36.87092	2026-04-02 22:01:36.87092
31852	12:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:37.325409	2026-04-02 22:01:37.325409
31853	13:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:37.779731	2026-04-02 22:01:37.779731
31854	13:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:38.233998	2026-04-02 22:01:38.233998
31855	14:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:38.688086	2026-04-02 22:01:38.688086
31856	14:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:39.142001	2026-04-02 22:01:39.142001
31857	15:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:39.596352	2026-04-02 22:01:39.596352
31858	15:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:40.050592	2026-04-02 22:01:40.050592
31859	16:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:40.504602	2026-04-02 22:01:40.504602
31860	16:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:40.958831	2026-04-02 22:01:40.958831
31861	17:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:41.413258	2026-04-02 22:01:41.413258
31862	17:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:41.867377	2026-04-02 22:01:41.867377
31863	18:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-02 22:01:42.321341	2026-04-02 22:01:42.321341
31864	05:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:45.272027	2026-04-02 22:01:45.272027
31865	06:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:45.725802	2026-04-02 22:01:45.725802
31866	06:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:46.179426	2026-04-02 22:01:46.179426
31867	07:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:46.633599	2026-04-02 22:01:46.633599
31868	07:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:47.087724	2026-04-02 22:01:47.087724
31869	08:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:47.541953	2026-04-02 22:01:47.541953
31870	08:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:47.996053	2026-04-02 22:01:47.996053
31871	09:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:48.450233	2026-04-02 22:01:48.450233
31872	09:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:48.904645	2026-04-02 22:01:48.904645
31873	10:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:49.358486	2026-04-02 22:01:49.358486
31874	10:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:49.812617	2026-04-02 22:01:49.812617
31875	11:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:50.266806	2026-04-02 22:01:50.266806
31876	11:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:50.721356	2026-04-02 22:01:50.721356
31877	12:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:51.175343	2026-04-02 22:01:51.175343
31878	12:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:51.629618	2026-04-02 22:01:51.629618
31879	13:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:52.083362	2026-04-02 22:01:52.083362
31880	13:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:52.537461	2026-04-02 22:01:52.537461
31881	14:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:52.991231	2026-04-02 22:01:52.991231
31882	14:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:53.445298	2026-04-02 22:01:53.445298
31883	15:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:53.899106	2026-04-02 22:01:53.899106
31884	15:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:54.353121	2026-04-02 22:01:54.353121
31885	16:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:54.807798	2026-04-02 22:01:54.807798
31886	16:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:55.261946	2026-04-02 22:01:55.261946
31887	17:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:55.715784	2026-04-02 22:01:55.715784
31888	17:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:56.169703	2026-04-02 22:01:56.169703
31889	18:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:56.623684	2026-04-02 22:01:56.623684
31890	18:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:57.078043	2026-04-02 22:01:57.078043
31891	19:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:57.532154	2026-04-02 22:01:57.532154
31892	19:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:57.985905	2026-04-02 22:01:57.985905
31893	20:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:01:58.439703	2026-04-02 22:01:58.439703
31894	05:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:30.321922	2026-04-02 22:02:30.321922
31895	06:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:30.787706	2026-04-02 22:02:30.787706
31896	06:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:31.24154	2026-04-02 22:02:31.24154
31897	07:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:31.696086	2026-04-02 22:02:31.696086
31898	07:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:32.150078	2026-04-02 22:02:32.150078
31899	08:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:32.603977	2026-04-02 22:02:32.603977
31900	08:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:33.057926	2026-04-02 22:02:33.057926
31901	09:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:33.511884	2026-04-02 22:02:33.511884
31776	05:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:29.906712	2026-03-29 01:08:29.906712
31777	06:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:30.409524	2026-03-29 01:08:30.409524
31778	06:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:30.821704	2026-03-29 01:08:30.821704
31779	07:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:31.233713	2026-03-29 01:08:31.233713
31780	07:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:31.645923	2026-03-29 01:08:31.645923
31781	08:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:32.058188	2026-03-29 01:08:32.058188
31782	08:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:32.470463	2026-03-29 01:08:32.470463
31783	09:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:32.882628	2026-03-29 01:08:32.882628
31784	09:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:33.294832	2026-03-29 01:08:33.294832
31785	10:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:33.707095	2026-03-29 01:08:33.707095
31786	10:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:34.119265	2026-03-29 01:08:34.119265
31787	11:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:34.531303	2026-03-29 01:08:34.531303
31788	11:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:34.943605	2026-03-29 01:08:34.943605
31789	12:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:35.356192	2026-03-29 01:08:35.356192
31790	12:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:35.768949	2026-03-29 01:08:35.768949
31791	13:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:36.181304	2026-03-29 01:08:36.181304
31792	13:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:36.593615	2026-03-29 01:08:36.593615
31793	14:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:37.005842	2026-03-29 01:08:37.005842
31794	14:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:37.418035	2026-03-29 01:08:37.418035
31795	15:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:37.830696	2026-03-29 01:08:37.830696
31796	15:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:38.24292	2026-03-29 01:08:38.24292
31797	16:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:38.656502	2026-03-29 01:08:38.656502
31798	16:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:39.068693	2026-03-29 01:08:39.068693
31799	17:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:39.480938	2026-03-29 01:08:39.480938
31800	17:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:39.893846	2026-03-29 01:08:39.893846
31801	18:00	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:40.305981	2026-03-29 01:08:40.305981
31802	18:30	29-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-29 01:08:40.718433	2026-03-29 01:08:40.718433
31902	09:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:33.965785	2026-04-02 22:02:33.965785
31903	10:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:34.419771	2026-04-02 22:02:34.419771
31904	10:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:34.873599	2026-04-02 22:02:34.873599
31905	11:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:35.336014	2026-04-02 22:02:35.336014
31906	11:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:35.789821	2026-04-02 22:02:35.789821
31907	12:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:36.243501	2026-04-02 22:02:36.243501
31908	12:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:36.697528	2026-04-02 22:02:36.697528
31909	13:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:37.151455	2026-04-02 22:02:37.151455
31910	13:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:37.605512	2026-04-02 22:02:37.605512
31911	14:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:38.0592	2026-04-02 22:02:38.0592
31912	14:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:38.513247	2026-04-02 22:02:38.513247
31913	15:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:38.966838	2026-04-02 22:02:38.966838
31914	15:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:39.421115	2026-04-02 22:02:39.421115
31915	16:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:39.874669	2026-04-02 22:02:39.874669
31916	16:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:40.32832	2026-04-02 22:02:40.32832
31917	17:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:40.781855	2026-04-02 22:02:40.781855
31918	17:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:41.236776	2026-04-02 22:02:41.236776
31919	18:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:41.690438	2026-04-02 22:02:41.690438
31920	18:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:42.146721	2026-04-02 22:02:42.146721
31921	19:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:42.605577	2026-04-02 22:02:42.605577
31922	19:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:43.058994	2026-04-02 22:02:43.058994
31923	20:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:02:43.51266	2026-04-02 22:02:43.51266
31924	05:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:49.069477	2026-04-02 22:02:49.069477
31925	06:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:49.524822	2026-04-02 22:02:49.524822
31926	06:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:49.979328	2026-04-02 22:02:49.979328
31927	07:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:50.433952	2026-04-02 22:02:50.433952
31928	07:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:50.888843	2026-04-02 22:02:50.888843
31929	08:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:51.342489	2026-04-02 22:02:51.342489
31930	08:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:51.796619	2026-04-02 22:02:51.796619
31931	09:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:52.250404	2026-04-02 22:02:52.250404
31932	09:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:52.704845	2026-04-02 22:02:52.704845
31933	10:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:53.15893	2026-04-02 22:02:53.15893
31934	10:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:53.619025	2026-04-02 22:02:53.619025
31935	11:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:54.072804	2026-04-02 22:02:54.072804
31936	11:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:54.526855	2026-04-02 22:02:54.526855
31937	12:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:54.984636	2026-04-02 22:02:54.984636
31938	12:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:55.438907	2026-04-02 22:02:55.438907
31939	13:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:55.893141	2026-04-02 22:02:55.893141
31940	13:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:56.346941	2026-04-02 22:02:56.346941
31941	14:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:56.800723	2026-04-02 22:02:56.800723
31942	14:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:57.25464	2026-04-02 22:02:57.25464
31943	15:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:57.7084	2026-04-02 22:02:57.7084
31944	15:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:58.162214	2026-04-02 22:02:58.162214
31803	05:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:53.302102	2026-03-29 03:13:53.302102
31804	06:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:53.736258	2026-03-29 03:13:53.736258
31805	06:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:54.169329	2026-03-29 03:13:54.169329
31806	07:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:54.602372	2026-03-29 03:13:54.602372
31807	07:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:55.035539	2026-03-29 03:13:55.035539
31808	08:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:55.46874	2026-03-29 03:13:55.46874
31809	08:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:55.90174	2026-03-29 03:13:55.90174
31810	09:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:56.33459	2026-03-29 03:13:56.33459
31811	09:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:56.767465	2026-03-29 03:13:56.767465
31812	10:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:57.200745	2026-03-29 03:13:57.200745
31813	10:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:57.633916	2026-03-29 03:13:57.633916
31814	11:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:58.0669	2026-03-29 03:13:58.0669
31815	11:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:58.502619	2026-03-29 03:13:58.502619
31816	12:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:58.936085	2026-03-29 03:13:58.936085
31817	12:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:59.369411	2026-03-29 03:13:59.369411
31818	13:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:13:59.802651	2026-03-29 03:13:59.802651
31819	13:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:00.236594	2026-03-29 03:14:00.236594
31820	14:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:00.669632	2026-03-29 03:14:00.669632
31821	14:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:01.102498	2026-03-29 03:14:01.102498
31822	15:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:01.535755	2026-03-29 03:14:01.535755
31823	15:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:01.969124	2026-03-29 03:14:01.969124
31824	16:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:02.402537	2026-03-29 03:14:02.402537
31825	16:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:02.835247	2026-03-29 03:14:02.835247
31826	17:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:03.27198	2026-03-29 03:14:03.27198
31827	17:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:03.705681	2026-03-29 03:14:03.705681
31828	18:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:04.139875	2026-03-29 03:14:04.139875
31829	18:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:04.573009	2026-03-29 03:14:04.573009
31830	19:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:05.006217	2026-03-29 03:14:05.006217
31831	19:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:05.439142	2026-03-29 03:14:05.439142
31832	20:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-29 03:14:05.872221	2026-03-29 03:14:05.872221
31945	16:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:58.616384	2026-04-02 22:02:58.616384
31946	16:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:59.070312	2026-04-02 22:02:59.070312
31947	17:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:59.527169	2026-04-02 22:02:59.527169
31948	17:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:02:59.981404	2026-04-02 22:02:59.981404
31949	18:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:03:00.435925	2026-04-02 22:03:00.435925
31950	18:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:03:00.889416	2026-04-02 22:03:00.889416
31951	19:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:03:01.343392	2026-04-02 22:03:01.343392
31952	19:30	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:03:01.79712	2026-04-02 22:03:01.79712
31953	20:00	02-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-02 22:03:02.25278	2026-04-02 22:03:02.25278
31954	05:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:03.951763	2026-04-02 22:03:03.951763
31955	06:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:04.405516	2026-04-02 22:03:04.405516
31956	06:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:04.859409	2026-04-02 22:03:04.859409
31957	07:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:05.313544	2026-04-02 22:03:05.313544
31958	07:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:05.767405	2026-04-02 22:03:05.767405
31959	08:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:06.221147	2026-04-02 22:03:06.221147
31960	08:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:06.676803	2026-04-02 22:03:06.676803
31961	09:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:07.130802	2026-04-02 22:03:07.130802
31962	09:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:07.585701	2026-04-02 22:03:07.585701
31963	10:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:08.039742	2026-04-02 22:03:08.039742
31964	10:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:08.493694	2026-04-02 22:03:08.493694
31965	11:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:08.947698	2026-04-02 22:03:08.947698
31966	11:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:09.401543	2026-04-02 22:03:09.401543
31967	12:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:09.855497	2026-04-02 22:03:09.855497
31968	12:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:10.309636	2026-04-02 22:03:10.309636
31969	13:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:10.764062	2026-04-02 22:03:10.764062
31970	13:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:11.217597	2026-04-02 22:03:11.217597
31971	14:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:11.672284	2026-04-02 22:03:11.672284
31972	14:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:12.126304	2026-04-02 22:03:12.126304
31973	15:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:12.58025	2026-04-02 22:03:12.58025
31974	15:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:13.034695	2026-04-02 22:03:13.034695
31975	16:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:13.488402	2026-04-02 22:03:13.488402
31976	16:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:13.941875	2026-04-02 22:03:13.941875
31977	17:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:14.396356	2026-04-02 22:03:14.396356
31978	17:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:14.855427	2026-04-02 22:03:14.855427
31979	18:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:15.309422	2026-04-02 22:03:15.309422
31980	18:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:15.763554	2026-04-02 22:03:15.763554
31981	19:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:16.217111	2026-04-02 22:03:16.217111
31982	19:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:16.670834	2026-04-02 22:03:16.670834
31983	20:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-02 22:03:17.124886	2026-04-02 22:03:17.124886
33013	13:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
31984	06:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-03 09:19:12.519283	2026-04-03 09:19:12.519283
31985	03:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:26.339957	2026-04-03 09:19:26.339957
31986	04:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:26.765927	2026-04-03 09:19:26.765927
31987	04:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:27.191925	2026-04-03 09:19:27.191925
31988	05:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:27.617542	2026-04-03 09:19:27.617542
31989	05:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:28.043052	2026-04-03 09:19:28.043052
31990	06:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:28.468702	2026-04-03 09:19:28.468702
31991	06:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:28.894491	2026-04-03 09:19:28.894491
31993	07:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:29.320055	2026-04-03 09:19:29.320055
31994	07:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:29.751001	2026-04-03 09:19:29.751001
31996	08:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:30.17647	2026-04-03 09:19:30.17647
31998	08:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:30.695827	2026-04-03 09:19:30.695827
32000	09:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:31.121534	2026-04-03 09:19:31.121534
32002	09:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:31.547298	2026-04-03 09:19:31.547298
32004	10:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:31.972686	2026-04-03 09:19:31.972686
32006	10:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:32.398302	2026-04-03 09:19:32.398302
32008	11:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:32.824191	2026-04-03 09:19:32.824191
32010	11:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:33.2499	2026-04-03 09:19:33.2499
32011	12:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:33.675781	2026-04-03 09:19:33.675781
32013	12:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:34.101616	2026-04-03 09:19:34.101616
32015	13:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:34.527522	2026-04-03 09:19:34.527522
32017	13:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:34.9534	2026-04-03 09:19:34.9534
32019	14:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:35.378967	2026-04-03 09:19:35.378967
32021	14:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:35.804494	2026-04-03 09:19:35.804494
32023	15:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:36.230544	2026-04-03 09:19:36.230544
32025	15:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:36.656271	2026-04-03 09:19:36.656271
32026	16:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:37.081971	2026-04-03 09:19:37.081971
32028	16:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:37.508017	2026-04-03 09:19:37.508017
32030	17:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:37.934545	2026-04-03 09:19:37.934545
32032	17:30	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:38.362089	2026-04-03 09:19:38.362089
32034	18:00	03-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-03 09:19:38.788074	2026-04-03 09:19:38.788074
32072	03:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:43.213234	2026-04-04 02:16:43.213234
32073	04:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:43.682115	2026-04-04 02:16:43.682115
32074	03:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:43.698045	2026-04-04 02:16:43.698045
32075	04:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:44.126893	2026-04-04 02:16:44.126893
32076	04:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:44.140486	2026-04-04 02:16:44.140486
32077	04:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:44.556561	2026-04-04 02:16:44.556561
32078	05:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:44.598462	2026-04-04 02:16:44.598462
32079	05:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:44.985671	2026-04-04 02:16:44.985671
32080	05:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:45.056868	2026-04-04 02:16:45.056868
33014	13:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33015	14:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33016	14:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33017	15:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33018	15:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33019	16:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33020	16:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33021	17:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33022	17:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33023	18:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33024	18:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 22:59:55.552539	2026-04-09 22:59:55.552539
33025	05:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 22:59:56.248473	2026-04-09 22:59:56.248473
33026	06:00	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 22:59:56.248473	2026-04-09 22:59:56.248473
33027	06:30	10-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 22:59:56.248473	2026-04-09 22:59:56.248473
33028	03:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33029	04:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33030	04:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33031	05:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33032	05:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33033	06:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33034	06:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33035	07:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33036	07:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33037	08:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33038	08:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33039	09:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33040	09:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33041	10:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33042	10:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
32045	05:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:53.379934	2026-04-03 09:19:53.379934
32046	06:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:53.831478	2026-04-03 09:19:53.831478
32047	06:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:54.283119	2026-04-03 09:19:54.283119
32048	07:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:54.735176	2026-04-03 09:19:54.735176
32049	07:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:55.187692	2026-04-03 09:19:55.187692
32050	08:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:55.63978	2026-04-03 09:19:55.63978
32051	08:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:56.091616	2026-04-03 09:19:56.091616
32052	09:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:56.543151	2026-04-03 09:19:56.543151
32053	09:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:56.9954	2026-04-03 09:19:56.9954
32054	10:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:57.446936	2026-04-03 09:19:57.446936
32055	10:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:57.898414	2026-04-03 09:19:57.898414
32056	11:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:58.349773	2026-04-03 09:19:58.349773
32057	11:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:58.801377	2026-04-03 09:19:58.801377
32058	12:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:59.253054	2026-04-03 09:19:59.253054
32059	12:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:19:59.705171	2026-04-03 09:19:59.705171
32060	13:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:00.156663	2026-04-03 09:20:00.156663
32061	13:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:00.608213	2026-04-03 09:20:00.608213
32062	14:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:01.059651	2026-04-03 09:20:01.059651
32063	14:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:01.511587	2026-04-03 09:20:01.511587
32064	15:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:01.963079	2026-04-03 09:20:01.963079
32065	15:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:02.415502	2026-04-03 09:20:02.415502
32066	16:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:02.867112	2026-04-03 09:20:02.867112
32067	16:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:03.319594	2026-04-03 09:20:03.319594
32068	17:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:03.770892	2026-04-03 09:20:03.770892
32069	17:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:04.22226	2026-04-03 09:20:04.22226
32070	18:00	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:04.673937	2026-04-03 09:20:04.673937
32071	18:30	03-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-03 09:20:05.133898	2026-04-03 09:20:05.133898
32081	05:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:45.414602	2026-04-04 02:16:45.414602
32082	06:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:45.514851	2026-04-04 02:16:45.514851
32083	06:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:45.843757	2026-04-04 02:16:45.843757
32084	06:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:45.97568	2026-04-04 02:16:45.97568
32085	06:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:46.272572	2026-04-04 02:16:46.272572
32086	07:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:46.433812	2026-04-04 02:16:46.433812
32087	07:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:46.701487	2026-04-04 02:16:46.701487
32088	07:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:46.892111	2026-04-04 02:16:46.892111
32089	07:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:47.130117	2026-04-04 02:16:47.130117
32090	08:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:47.368609	2026-04-04 02:16:47.368609
32091	08:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:47.58147	2026-04-04 02:16:47.58147
32092	08:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:47.835028	2026-04-04 02:16:47.835028
32093	08:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:48.011493	2026-04-04 02:16:48.011493
32094	09:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:48.299564	2026-04-04 02:16:48.299564
32095	09:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:48.450028	2026-04-04 02:16:48.450028
32096	09:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:48.757126	2026-04-04 02:16:48.757126
32097	09:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:48.879491	2026-04-04 02:16:48.879491
32098	10:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:49.215218	2026-04-04 02:16:49.215218
32099	10:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:49.316372	2026-04-04 02:16:49.316372
32100	10:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:49.673668	2026-04-04 02:16:49.673668
32101	10:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:49.745529	2026-04-04 02:16:49.745529
32102	11:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:50.131865	2026-04-04 02:16:50.131865
32103	11:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:50.174409	2026-04-04 02:16:50.174409
32104	11:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:50.589734	2026-04-04 02:16:50.589734
32105	11:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:50.603546	2026-04-04 02:16:50.603546
32106	12:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:51.032315	2026-04-04 02:16:51.032315
32107	12:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:51.047249	2026-04-04 02:16:51.047249
32108	12:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:51.462142	2026-04-04 02:16:51.462142
32109	12:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:51.505439	2026-04-04 02:16:51.505439
32110	13:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:51.890932	2026-04-04 02:16:51.890932
32111	13:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:51.963522	2026-04-04 02:16:51.963522
32112	13:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:52.320741	2026-04-04 02:16:52.320741
32113	13:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:52.429162	2026-04-04 02:16:52.429162
32114	14:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:52.753169	2026-04-04 02:16:52.753169
32115	14:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:52.886863	2026-04-04 02:16:52.886863
32116	14:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:53.182312	2026-04-04 02:16:53.182312
32117	14:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:53.344681	2026-04-04 02:16:53.344681
32118	15:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:53.611282	2026-04-04 02:16:53.611282
32119	15:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:53.802933	2026-04-04 02:16:53.802933
32120	15:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:54.040146	2026-04-04 02:16:54.040146
32121	15:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:54.260845	2026-04-04 02:16:54.260845
32122	16:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:54.472064	2026-04-04 02:16:54.472064
32123	16:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:54.718519	2026-04-04 02:16:54.718519
32124	16:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:54.900802	2026-04-04 02:16:54.900802
32125	16:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:55.176493	2026-04-04 02:16:55.176493
32126	17:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:55.330711	2026-04-04 02:16:55.330711
32127	17:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:55.634465	2026-04-04 02:16:55.634465
32128	17:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:55.759824	2026-04-04 02:16:55.759824
32129	17:30	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:56.092859	2026-04-04 02:16:56.092859
32130	18:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 02:16:56.217002	2026-04-04 02:16:56.217002
32131	18:00	04-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 02:16:56.551012	2026-04-04 02:16:56.551012
32132	05:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:02.064364	2026-04-04 02:17:02.064364
32133	06:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:02.493526	2026-04-04 02:17:02.493526
32134	06:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:02.922729	2026-04-04 02:17:02.922729
32135	07:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:03.356405	2026-04-04 02:17:03.356405
32136	07:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:03.789172	2026-04-04 02:17:03.789172
32137	08:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:04.217998	2026-04-04 02:17:04.217998
32138	08:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:04.646803	2026-04-04 02:17:04.646803
32139	09:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:05.075862	2026-04-04 02:17:05.075862
32140	09:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:05.504597	2026-04-04 02:17:05.504597
32141	10:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:05.933813	2026-04-04 02:17:05.933813
32142	10:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:06.365981	2026-04-04 02:17:06.365981
32143	11:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:06.794942	2026-04-04 02:17:06.794942
32144	11:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:07.223527	2026-04-04 02:17:07.223527
32145	12:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:07.652399	2026-04-04 02:17:07.652399
32146	12:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:08.081109	2026-04-04 02:17:08.081109
32147	13:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:08.509674	2026-04-04 02:17:08.509674
32148	13:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:08.938788	2026-04-04 02:17:08.938788
32149	14:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:09.367729	2026-04-04 02:17:09.367729
32150	14:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:09.796764	2026-04-04 02:17:09.796764
32151	15:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:10.225392	2026-04-04 02:17:10.225392
32152	15:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:10.654326	2026-04-04 02:17:10.654326
32153	16:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:11.090027	2026-04-04 02:17:11.090027
32154	16:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:11.519079	2026-04-04 02:17:11.519079
32155	17:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:11.948062	2026-04-04 02:17:11.948062
32156	17:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:12.376608	2026-04-04 02:17:12.376608
32157	18:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:12.805869	2026-04-04 02:17:12.805869
32158	18:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:13.235851	2026-04-04 02:17:13.235851
32159	19:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:13.664479	2026-04-04 02:17:13.664479
32160	19:30	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:14.093291	2026-04-04 02:17:14.093291
32161	20:00	04-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 02:17:14.522014	2026-04-04 02:17:14.522014
32162	05:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:26.419266	2026-04-04 02:17:26.419266
32163	06:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:26.863518	2026-04-04 02:17:26.863518
32164	06:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:27.308118	2026-04-04 02:17:27.308118
32165	07:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:27.752819	2026-04-04 02:17:27.752819
32166	07:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:28.196606	2026-04-04 02:17:28.196606
32167	08:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:28.640813	2026-04-04 02:17:28.640813
32168	08:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:29.086776	2026-04-04 02:17:29.086776
32169	09:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:29.531011	2026-04-04 02:17:29.531011
32170	09:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:29.975457	2026-04-04 02:17:29.975457
32171	10:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:30.419614	2026-04-04 02:17:30.419614
32172	10:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:30.864037	2026-04-04 02:17:30.864037
32173	11:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:31.309797	2026-04-04 02:17:31.309797
32174	11:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:31.753992	2026-04-04 02:17:31.753992
32175	12:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:32.198356	2026-04-04 02:17:32.198356
32176	12:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:32.642862	2026-04-04 02:17:32.642862
32177	13:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:33.087706	2026-04-04 02:17:33.087706
32178	13:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:33.531645	2026-04-04 02:17:33.531645
32179	14:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:33.975829	2026-04-04 02:17:33.975829
32180	14:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:34.420456	2026-04-04 02:17:34.420456
32181	15:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:34.865113	2026-04-04 02:17:34.865113
32182	15:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:35.310383	2026-04-04 02:17:35.310383
32183	16:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:35.754599	2026-04-04 02:17:35.754599
32184	16:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:36.199347	2026-04-04 02:17:36.199347
32185	17:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:36.643686	2026-04-04 02:17:36.643686
32186	17:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:37.087926	2026-04-04 02:17:37.087926
32187	18:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:37.531761	2026-04-04 02:17:37.531761
32188	18:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-04 02:17:37.975799	2026-04-04 02:17:37.975799
32189	05:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-04 02:17:43.915663	2026-04-04 02:17:43.915663
32190	06:00	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-04 02:17:44.361134	2026-04-04 02:17:44.361134
32191	06:30	04-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-04 02:17:44.805751	2026-04-04 02:17:44.805751
33043	11:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33044	11:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
32192	03:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32193	04:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32194	04:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32195	05:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32196	05:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32197	06:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32198	06:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32199	07:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32200	07:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32201	08:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32202	08:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32203	09:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32204	09:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32205	10:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32206	10:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32207	11:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32208	11:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32209	12:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32210	12:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32211	13:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32212	13:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32213	14:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32214	14:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32215	15:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32216	15:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32217	16:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32218	16:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32219	17:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32220	17:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32221	18:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-04 06:19:55.850145	2026-04-04 06:19:55.850145
32222	03:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32223	04:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32224	04:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32225	05:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32226	05:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32227	06:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32228	06:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32229	07:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32230	07:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32231	08:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32232	08:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32233	09:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32234	09:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32235	10:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32236	10:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32237	11:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32238	11:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32239	12:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32240	12:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32241	13:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32242	13:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32243	14:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32244	14:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32245	15:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32246	15:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32247	16:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32248	16:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32249	17:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32250	17:30	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32251	18:00	05-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-04 06:20:00.729204	2026-04-04 06:20:00.729204
32252	05:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32253	06:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32254	06:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32255	07:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32256	07:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32257	08:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32258	08:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32259	09:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32260	09:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32261	10:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32262	10:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32263	11:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32264	11:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32265	12:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32266	12:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32267	13:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32268	13:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32269	14:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32270	14:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32271	15:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32272	15:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32273	16:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32274	16:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32275	17:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32276	17:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32277	18:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32278	18:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32279	19:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32280	19:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32281	20:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-04 06:20:08.692015	2026-04-04 06:20:08.692015
32282	05:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32283	06:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32284	06:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32285	07:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32286	07:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32287	08:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32288	08:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32289	09:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32290	09:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32291	10:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32292	10:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32293	11:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32294	11:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32295	12:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32296	12:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32297	13:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32298	13:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32299	14:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32300	14:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32301	15:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32302	15:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32303	16:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32304	16:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32305	17:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32306	17:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32307	18:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32308	18:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32309	19:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32310	19:30	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
32311	20:00	05-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:20:13.544914	2026-04-04 06:20:13.544914
33045	12:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33046	12:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33047	13:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33048	13:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33049	14:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33050	14:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33051	15:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33052	15:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33053	16:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33054	16:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33055	17:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 22:59:56.938461	2026-04-09 22:59:56.938461
33056	03:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33057	04:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33058	04:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33059	05:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33060	05:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33061	06:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33062	06:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33063	07:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33064	07:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
32312	05:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32313	06:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32314	07:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32315	07:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32316	08:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32317	08:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32318	09:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32319	09:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32320	10:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32321	10:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32322	11:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32323	11:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32324	12:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32325	12:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32326	13:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32327	13:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32328	14:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32329	14:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32330	15:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32331	15:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32332	16:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32333	16:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32334	17:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32335	17:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32336	18:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32337	18:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32338	19:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32339	19:30	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32340	20:00	03-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:21:15.569291	2026-04-04 06:21:15.569291
32341	05:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32342	06:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32343	06:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32344	07:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32345	07:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32346	08:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32347	08:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32348	09:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32349	09:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32350	10:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32351	10:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32352	11:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32353	11:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32354	12:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32355	12:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32356	13:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32357	13:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32358	14:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32359	14:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32360	15:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32361	15:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32362	16:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32363	16:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32364	17:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32365	17:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32366	18:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32367	18:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32368	19:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32369	19:30	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32370	20:00	01-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:36:59.960361	2026-04-04 06:36:59.960361
32371	05:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32372	06:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32373	06:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32374	07:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32375	07:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32376	08:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32377	08:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32378	09:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32379	09:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32380	10:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32381	10:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32382	11:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32383	11:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32384	12:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32385	12:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32386	13:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32387	13:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32388	14:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32389	14:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32390	15:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32391	15:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32392	16:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32393	16:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32394	17:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32395	17:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32396	18:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32397	18:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32398	19:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32399	19:30	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32400	20:00	31-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:02.846226	2026-04-04 06:37:02.846226
32401	05:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32402	06:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32403	06:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32404	07:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32405	07:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32406	08:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32407	08:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32408	09:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32409	09:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32410	10:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32411	10:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32412	11:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32413	11:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32414	12:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32415	12:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32416	13:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32417	13:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32418	14:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32419	14:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32420	15:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32421	15:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32422	16:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32423	16:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32424	17:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32425	17:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32426	18:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32427	18:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32428	19:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32429	19:30	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
32430	20:00	30-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-04 06:37:05.482562	2026-04-04 06:37:05.482562
33065	08:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33066	08:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33067	09:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33068	09:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33069	10:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33070	10:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33071	11:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33072	11:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33073	12:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33074	12:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33075	13:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33076	13:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33077	14:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33078	14:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33079	15:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33080	15:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33081	16:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33082	16:30	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
33083	17:00	10-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 22:59:57.632673	2026-04-09 22:59:57.632673
32431	03:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32432	04:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32433	04:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32434	05:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32435	05:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32436	06:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32437	06:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32438	07:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32439	07:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32440	08:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32441	08:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32442	09:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32443	09:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32444	10:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32445	10:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32446	11:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32447	11:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32448	12:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32449	12:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32450	13:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32451	13:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32452	14:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32453	14:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32454	15:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32455	15:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32456	16:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32457	16:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32458	17:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32459	17:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32460	18:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-05 23:48:38.583828	2026-04-05 23:48:38.583828
32461	05:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32462	06:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32463	06:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32464	07:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32465	07:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32466	08:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32467	08:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32468	09:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32469	09:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32470	10:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32471	10:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32472	11:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32473	11:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32474	12:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32475	12:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32476	13:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32477	13:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32478	14:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32479	14:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32480	15:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32481	15:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32482	16:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32483	16:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32484	17:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32485	17:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32486	18:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32487	18:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32488	19:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32489	19:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32490	20:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-05 23:48:45.346133	2026-04-05 23:48:45.346133
32491	07:00	06-04-2026	Xe 28G	\N	\N	\N	Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:24.566331	2026-04-05 23:49:24.566331
32492	03:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32493	04:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32494	04:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32495	05:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32496	05:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32497	06:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32498	06:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32499	07:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32500	08:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32501	08:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32502	09:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32503	09:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32504	10:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32505	10:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32506	11:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32507	11:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32508	12:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32509	12:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32510	13:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32511	13:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32512	14:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32513	14:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32514	15:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32515	15:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32516	16:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32517	16:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32518	17:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32519	17:30	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32520	18:00	06-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-05 23:49:29.110807	2026-04-05 23:49:29.110807
32521	05:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
33084	05:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
32523	06:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32524	07:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32525	07:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32526	08:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32527	08:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32528	09:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32529	09:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32530	10:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32531	10:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32532	11:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32533	11:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32534	12:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32535	12:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32536	13:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32537	13:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32538	14:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32539	14:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32540	15:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32541	15:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32542	16:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32543	16:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32544	17:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32545	17:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32546	18:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32547	18:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32548	19:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32549	19:30	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32550	20:00	06-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-05 23:49:57.30061
32551	05:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-05 23:50:48.525431	2026-04-05 23:50:48.525431
32552	06:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-05 23:50:48.525431	2026-04-05 23:50:48.525431
32553	06:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-05 23:50:48.525431	2026-04-05 23:50:48.525431
32554	03:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32555	04:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32556	04:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32557	05:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32558	05:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32559	06:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32560	06:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32561	07:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32562	07:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32563	08:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32564	08:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32565	09:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32566	09:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32567	10:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32568	10:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32569	11:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32570	11:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32571	12:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32572	12:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32573	13:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32574	13:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32575	14:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32576	14:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32577	15:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32578	15:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32579	16:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32580	16:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
32581	17:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-05 23:50:53.583936	2026-04-05 23:50:53.583936
33085	06:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33086	06:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33087	07:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33088	07:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33089	08:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33090	08:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33091	09:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33092	09:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33093	10:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33094	10:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33095	11:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33096	11:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33097	12:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33098	12:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33099	13:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33100	13:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33101	14:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33102	14:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33103	15:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33104	15:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33105	16:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33106	16:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33107	17:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33108	17:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33109	18:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33110	18:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33111	19:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33112	19:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
33113	20:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-10 23:14:09.848415	2026-04-10 23:14:09.848415
32522	06:00	06-04-2026	Xe 28G	60B04103, 51B26030	Bằng, Chiến B		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-05 23:49:57.30061	2026-04-09 01:25:16.477688
33114	03:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33115	04:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33116	04:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
32582	03:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32583	04:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32584	04:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32585	05:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32586	05:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32587	06:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32588	06:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32589	07:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32590	07:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32591	08:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32592	08:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32593	09:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32594	09:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32595	10:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32596	10:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32597	11:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32598	11:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32599	12:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32600	12:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32601	13:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32602	13:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32603	14:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32604	14:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32605	15:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32606	15:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32607	16:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32608	16:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32609	17:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32610	17:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32611	18:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-09 00:59:32.605796	2026-04-09 00:59:32.605796
32612	05:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32613	06:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32614	06:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32615	07:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32616	07:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32617	08:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32618	08:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32619	09:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32620	09:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32621	10:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32622	10:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32623	11:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32624	11:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32625	12:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32626	12:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32627	13:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32628	13:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32629	14:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32630	14:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32631	15:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32632	15:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32633	16:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32634	16:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32635	17:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32636	17:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32637	18:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32638	18:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32639	19:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32640	19:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
32641	20:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:00:00.37403	2026-04-09 01:00:00.37403
33117	05:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33118	05:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33119	06:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33120	06:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33121	07:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33122	07:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
32643	06:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32644	06:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32645	07:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32646	07:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32647	08:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32648	08:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32649	09:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32650	09:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32651	10:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32652	10:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32653	11:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32654	11:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32655	12:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32656	12:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32657	13:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32658	13:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32659	14:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32660	14:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32661	15:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32662	15:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32663	16:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32664	16:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32665	17:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32666	17:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32667	18:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32668	18:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32669	19:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32670	19:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
32671	20:00	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:08:40.878838
33123	08:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33124	08:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33125	09:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33126	09:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33127	10:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
32642	05:30	09-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:08:40.878838	2026-04-09 01:33:19.044881
33128	10:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33129	11:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33130	11:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33131	12:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33132	12:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33133	13:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33134	13:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33135	14:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33136	14:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33137	15:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33138	15:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33139	16:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33140	16:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33141	17:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33142	17:30	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33143	18:00	11-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-11 00:15:44.686781	2026-04-11 00:15:44.686781
33144	05:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33145	06:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33146	06:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33147	07:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33148	07:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33149	08:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33150	08:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33151	09:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33152	09:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33153	10:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33154	10:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33155	11:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33156	11:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33157	12:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33158	12:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33159	13:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33160	13:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33161	14:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33162	14:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
32672	03:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32673	04:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32674	04:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32675	05:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32676	05:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32677	06:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32678	06:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32679	07:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32680	07:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32681	08:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32682	08:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32683	09:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32684	09:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32685	10:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32686	10:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32687	11:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32688	11:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32689	12:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32690	12:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32691	13:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32692	13:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32693	14:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32694	14:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32695	15:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32696	15:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32697	16:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32698	16:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32699	17:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32700	17:30	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32701	18:00	09-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-09 01:14:48.359645	2026-04-09 01:14:48.359645
32702	05:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32703	06:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32704	06:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32705	07:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32706	07:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32707	08:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32708	08:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32709	09:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32710	09:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32711	10:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32712	10:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32713	11:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32714	11:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32715	12:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32716	12:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32717	13:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32718	13:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32719	14:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32720	14:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32721	15:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32722	15:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32723	16:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32724	16:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32725	17:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32726	17:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32727	18:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32728	18:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32729	19:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32730	19:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32731	20:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:14:58.379045	2026-04-09 01:14:58.379045
32732	05:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32733	06:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32734	06:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32735	07:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32736	07:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32737	08:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32738	08:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32739	09:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32740	09:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32741	10:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32742	10:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32743	11:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32744	11:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32745	12:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32746	12:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32747	13:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32748	13:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32749	14:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32750	14:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32751	15:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32752	15:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32753	16:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32754	16:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32755	17:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32756	17:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32757	18:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32758	18:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32759	19:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32760	19:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
32761	20:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-09 01:15:00.492914	2026-04-09 01:15:00.492914
33163	15:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33164	15:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33165	16:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33166	16:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33167	17:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33168	17:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33169	18:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33170	18:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33171	19:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33172	19:30	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
33173	20:00	08-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 00:16:02.727294	2026-04-11 00:16:02.727294
32762	05:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32763	06:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32764	06:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32765	07:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32766	07:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32767	08:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32768	08:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32769	09:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32770	09:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32771	10:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32772	10:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32773	11:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32774	11:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32775	12:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32776	12:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32777	13:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32778	13:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32779	14:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32780	14:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32781	15:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32782	15:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32783	16:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32784	16:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32785	17:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32786	17:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32787	18:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32788	18:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32789	19:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32790	19:30	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32791	20:00	07-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-09 01:47:47.293359	2026-04-09 01:47:47.293359
32792	05:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32793	06:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32794	06:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32795	07:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32796	07:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32797	08:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32798	08:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32799	09:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32800	09:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32801	10:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32802	10:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32803	11:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32804	11:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32805	12:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32806	12:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32807	13:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32808	13:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32809	14:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32810	14:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32811	15:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32812	15:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32813	16:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32814	16:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32815	17:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32816	17:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32817	18:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32818	18:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-09 05:22:48.493211	2026-04-09 05:22:48.493211
32819	05:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 05:22:49.139074	2026-04-09 05:22:49.139074
32820	06:00	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 05:22:49.139074	2026-04-09 05:22:49.139074
32821	06:30	09-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-09 05:22:49.139074	2026-04-09 05:22:49.139074
32822	03:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32823	04:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32824	04:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32825	05:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32826	05:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32827	06:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32828	06:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32829	07:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32830	07:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32831	08:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32832	08:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32833	09:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32834	09:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32835	10:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32836	10:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32837	11:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32838	11:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32839	12:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32840	12:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32841	13:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32842	13:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32843	14:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32844	14:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32845	15:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32846	15:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32847	16:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32848	16:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32849	17:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-09 05:22:49.772179	2026-04-09 05:22:49.772179
32850	03:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32851	04:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32852	04:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32853	05:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32854	05:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32855	06:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32856	06:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32857	07:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32858	07:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32859	08:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32860	08:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32861	09:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32862	09:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32863	10:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32864	10:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32865	11:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32866	11:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32867	12:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32868	12:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32869	13:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32870	13:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32871	14:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32872	14:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32873	15:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32874	15:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32875	16:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32876	16:30	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
32877	17:00	09-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-09 05:22:50.407229	2026-04-09 05:22:50.407229
33174	05:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33175	06:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33176	06:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33177	07:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33178	07:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33179	08:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33180	08:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33181	09:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33182	09:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33183	10:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33184	10:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33185	11:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33186	11:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33187	12:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33188	12:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33189	13:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33190	13:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33191	14:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33192	14:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33193	15:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33194	15:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33195	16:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33196	16:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33197	17:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33198	17:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33199	18:00	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33200	18:30	06-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-11 04:12:38.084023	2026-04-11 04:12:38.084023
33201	03:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33202	04:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33203	04:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33204	05:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33205	05:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33206	06:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33207	06:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33208	07:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33209	07:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33210	08:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33211	08:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33212	09:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33213	09:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33214	10:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33215	10:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33216	11:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33217	11:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33218	12:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33219	12:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33220	13:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33221	13:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33222	14:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33223	14:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33224	15:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33225	15:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33226	16:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33227	16:30	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33228	17:00	06-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-11 04:12:39.24658	2026-04-11 04:12:39.24658
33229	05:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33230	06:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33231	06:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33232	07:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33233	07:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33234	08:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33235	08:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33236	09:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33237	09:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33238	10:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33239	10:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33240	11:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33241	11:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33242	12:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33243	12:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33244	13:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33245	13:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33246	14:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33247	14:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33248	15:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33249	15:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33250	16:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33251	16:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33252	17:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33253	17:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33254	18:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33255	18:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33256	19:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33257	19:30	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33258	20:00	11-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-11 08:04:37.585485	2026-04-11 08:04:37.585485
33262	07:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33263	07:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33264	08:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33265	08:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33266	09:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33268	10:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33269	10:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33270	11:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33271	11:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33272	12:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33273	12:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33274	13:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33275	13:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33276	14:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33277	14:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33279	15:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33280	16:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33281	16:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33283	17:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33284	18:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33285	18:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33286	19:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33287	19:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33288	20:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-11 22:57:47.064024
33261	06:30	12-04-2026	Xe 28G	60B04669	An		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 10:35:35.6557
33282	17:00	12-04-2026	Xe 28G		Thanh Bắc, An		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 09:50:46.292501
33278	15:00	12-04-2026	Xe 28G		An		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 09:57:32.595472
33267	09:30	12-04-2026	Xe 28G	60B04669	An		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 10:06:39.840167
33260	06:00	12-04-2026	Xe 28G	60B04669	Bằng		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 10:02:57.535327
33259	05:30	12-04-2026	Xe 28G	50F-01031	Bằng, Chiến B		Sài Gòn - Long Khánh (Quốc lộ)	2026-04-11 22:57:47.064024	2026-04-12 10:17:49.821661
33292	05:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33293	05:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33294	06:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33295	06:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33296	07:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33298	08:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33299	08:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33300	09:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33301	09:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33302	10:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33303	10:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33304	11:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33305	11:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33306	12:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33307	12:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33308	13:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33309	13:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33310	14:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33311	14:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33312	15:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33313	15:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33314	16:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33315	16:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33316	17:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33317	17:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33318	18:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 00:12:44.627163
33319	03:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33320	04:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33321	04:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33322	05:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33323	05:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33324	06:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33325	06:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33326	07:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33327	07:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33328	08:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33329	08:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33330	09:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33331	09:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33332	10:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33333	10:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33334	11:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33335	11:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33336	12:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33337	12:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33338	13:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33339	13:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33340	14:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33341	14:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33342	15:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33343	15:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33344	16:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33345	16:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33346	17:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33347	17:30	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33348	18:00	12-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-12 00:12:45.305874	2026-04-12 00:12:45.305874
33349	05:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33350	06:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33351	06:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33352	07:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33353	07:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33354	08:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33355	08:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33356	09:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33357	09:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33358	10:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33290	04:00	12-04-2026	Xe 28G		Chiến B		Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 10:16:47.83069
33291	04:30	12-04-2026	Xe 28G	60B04669	Bằng, An, Chiến B		Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 10:46:29.040533
33359	10:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33360	11:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33361	11:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33362	12:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33363	12:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33364	13:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33365	13:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33366	14:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33367	14:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33368	15:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33369	15:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33370	16:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33371	16:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33372	17:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33373	17:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33374	18:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33375	18:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33376	19:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33377	19:30	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33378	20:00	12-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-12 00:12:45.964155	2026-04-12 00:12:45.964155
33379	05:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33380	06:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33381	06:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33382	07:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33383	07:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33384	08:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33385	08:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33386	09:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33387	09:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33388	10:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33389	10:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33390	11:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33391	11:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33392	12:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33393	12:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33394	13:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33395	13:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33396	14:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33397	14:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33398	15:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33399	15:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33400	16:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33401	16:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33402	17:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33403	17:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33404	18:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33405	18:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-12 00:12:47.272459	2026-04-12 00:12:47.272459
33406	05:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-12 00:12:47.94704	2026-04-12 00:12:47.94704
33407	06:00	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-12 00:12:47.94704	2026-04-12 00:12:47.94704
33408	06:30	12-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-12 00:12:47.94704	2026-04-12 00:12:47.94704
33409	03:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33410	04:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33411	04:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33412	05:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33413	05:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33414	06:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33415	06:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33416	07:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33417	07:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33418	08:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33419	08:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33420	09:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33421	09:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33422	10:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33423	10:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33424	11:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33425	11:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33426	12:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33427	12:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33428	13:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33429	13:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33430	14:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33431	14:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33432	15:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33433	15:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33434	16:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33435	16:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33436	17:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-12 00:12:48.599882	2026-04-12 00:12:48.599882
33437	03:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33438	04:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33439	04:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33440	05:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33441	05:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33442	06:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33443	06:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33444	07:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33445	07:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33446	08:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33447	08:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33448	09:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33449	09:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33450	10:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33451	10:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33452	11:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33453	11:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33454	12:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33455	12:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33456	13:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33457	13:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33458	14:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33459	14:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33460	15:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33461	15:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33462	16:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33463	16:30	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33464	17:00	12-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-12 00:12:49.255417	2026-04-12 00:12:49.255417
33526	04:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33289	03:30	12-04-2026	Xe 28G	60B04669, 60F-01031	An, Chiến B		Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 10:46:57.651935
33465	05:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33466	06:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33467	06:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33468	07:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33469	07:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33470	08:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33471	08:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33472	09:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33473	09:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33474	10:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33475	10:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33476	11:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33477	11:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33478	12:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33479	12:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33480	13:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33481	13:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33482	14:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33483	14:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33484	15:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33485	15:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33486	16:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33487	16:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33488	17:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33489	17:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33490	18:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33491	18:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33492	19:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33493	19:30	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33494	20:00	19-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-18 23:25:41.786508	2026-04-18 23:25:41.786508
33495	05:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33496	06:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33497	06:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33498	07:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33499	07:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33500	08:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33501	08:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33502	09:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33503	09:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33504	10:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33505	10:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33506	11:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33507	11:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33508	12:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33509	12:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33510	13:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33511	13:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33512	14:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33513	14:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33514	15:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33515	15:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33516	16:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33517	16:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33518	17:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33519	17:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33520	18:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33521	18:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33522	19:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33523	19:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33524	20:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-04-20 23:14:53.022249	2026-04-20 23:14:53.022249
33527	04:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33528	05:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33529	05:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33530	06:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33531	06:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33532	07:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33533	07:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33297	07:30	12-04-2026	Xe 28G		Chiến B		Long Khánh - Sài Gòn (Cao tốc)	2026-04-12 00:12:44.627163	2026-04-12 10:15:38.037426
33534	08:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33535	08:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33536	09:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33537	09:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33538	10:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33539	10:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33540	11:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33541	11:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33542	12:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33543	12:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33544	13:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33545	13:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33546	14:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33547	14:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33548	15:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33549	15:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33550	16:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33551	16:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33552	17:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33553	17:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33554	18:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:19.386973
33555	03:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33556	04:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33557	04:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33558	05:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33559	05:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33560	06:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33561	06:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33562	07:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33563	07:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33564	08:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33565	08:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33566	09:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33567	09:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33568	10:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33569	10:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33570	11:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33571	11:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33572	12:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33573	12:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33574	13:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33575	13:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33576	14:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33577	14:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33578	15:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33579	15:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33580	16:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33581	16:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33582	17:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33583	17:30	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33584	18:00	21-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-20 23:21:20.237811	2026-04-20 23:21:20.237811
33585	05:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33586	06:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33587	06:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33588	07:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33589	07:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33590	08:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33591	08:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33592	09:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33593	09:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33594	10:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33595	10:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33596	11:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33597	11:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33598	12:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33599	12:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33600	13:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33601	13:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33602	14:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33603	14:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33604	15:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33605	15:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33606	16:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33607	16:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33608	17:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33609	17:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33610	18:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33611	18:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33612	19:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33613	19:30	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33614	20:00	21-04-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-04-20 23:21:20.912098	2026-04-20 23:21:20.912098
33615	05:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33616	06:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33617	06:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33618	07:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33619	07:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33620	08:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33621	08:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33622	09:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33623	09:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33624	10:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33625	10:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33626	11:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33627	11:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33628	12:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33629	12:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33630	13:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33631	13:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33632	14:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33633	14:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33634	15:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33635	15:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33636	16:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33637	16:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33638	17:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33639	17:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33640	18:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33641	18:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-04-20 23:21:22.261203	2026-04-20 23:21:22.261203
33642	05:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-20 23:21:22.940904	2026-04-20 23:21:22.940904
33643	06:00	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-20 23:21:22.940904	2026-04-20 23:21:22.940904
33644	06:30	21-04-2026	Xe 28G				Sài Gòn - Xuân Lộc (Quốc lộ)	2026-04-20 23:21:22.940904	2026-04-20 23:21:22.940904
33645	03:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33646	04:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33647	04:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33648	05:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33649	05:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33650	06:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33651	06:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33652	07:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33653	07:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33654	08:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33655	08:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33656	09:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33657	09:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33658	10:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33659	10:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33660	11:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33661	11:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33662	12:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33663	12:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33664	13:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33665	13:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33666	14:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33667	14:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33668	15:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33669	15:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33670	16:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33671	16:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33672	17:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Cao tốc)	2026-04-20 23:21:23.614388	2026-04-20 23:21:23.614388
33673	03:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33674	04:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33675	04:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33676	05:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33677	05:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33678	06:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33679	06:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33680	07:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33681	07:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33682	08:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33683	08:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33684	09:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33685	09:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33686	10:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33687	10:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33688	11:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33689	11:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33690	12:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33691	12:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33692	13:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33693	13:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33694	14:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33695	14:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33696	15:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33697	15:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33698	16:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33699	16:30	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33700	17:00	21-04-2026	Xe 28G				Xuân Lộc - Sài Gòn (Quốc lộ)	2026-04-20 23:21:24.301883	2026-04-20 23:21:24.301883
33525	03:30	21-04-2026	Xe 28G	50F-01031	Chiến B		Long Khánh - Sài Gòn (Cao tốc)	2026-04-20 23:21:19.386973	2026-04-20 23:21:47.582201
33701	03:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33702	04:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33703	04:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33704	05:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33705	05:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33706	06:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33707	06:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33708	07:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33709	07:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33710	08:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33711	08:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33712	09:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33713	09:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33714	10:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33715	10:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33716	11:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33717	11:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33718	12:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33719	12:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33720	13:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33721	13:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33722	14:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33723	14:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33724	15:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33725	15:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33726	16:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33727	16:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33728	17:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33729	17:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33730	18:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-04-24 00:11:11.693452	2026-04-24 00:11:11.693452
33731	03:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33732	04:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33733	04:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33734	05:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33735	05:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33736	06:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33737	06:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33738	07:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33739	07:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33740	08:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33741	08:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33742	09:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33743	09:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33744	10:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33745	10:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33746	11:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33747	11:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33748	12:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33749	12:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33750	13:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33751	13:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33752	14:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33753	14:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33754	15:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33755	15:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33756	16:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33757	16:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33758	17:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33759	17:30	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33760	18:00	24-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-24 08:27:36.455745	2026-04-24 08:27:36.455745
33761	13:30	26-04-2026	Xe 28G	\N	\N	\N	Sài Gòn - Long Khánh (Cao tốc)	2026-04-26 00:12:14.238615	2026-04-26 00:12:14.238615
33762	03:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33763	04:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33764	04:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33765	05:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33766	05:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33767	06:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33768	06:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33770	07:30	27-04-2026	Xe 28G	60F-01031	Chiến B		Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:26:17.176435
33771	08:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33772	08:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33773	09:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33774	09:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33775	10:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33776	10:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33777	11:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33778	11:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33779	12:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33780	12:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33781	13:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33782	13:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33783	14:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33784	14:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33785	15:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33786	15:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33787	16:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33788	16:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33789	17:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33790	17:30	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33791	18:00	27-04-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:24:45.730162
33769	07:00	27-04-2026	Xe 28G	60B04103	Bằng		Long Khánh - Sài Gòn (Quốc lộ)	2026-04-26 23:24:45.730162	2026-04-26 23:25:39.861637
31001	03:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:21.201154	2026-03-26 10:44:21.201154
31002	04:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:21.713699	2026-03-26 10:44:21.713699
31003	04:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:22.230706	2026-03-26 10:44:22.230706
31004	05:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:22.756378	2026-03-26 10:44:22.756378
31005	05:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:23.279682	2026-03-26 10:44:23.279682
31006	06:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:23.802318	2026-03-26 10:44:23.802318
31007	06:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:24.323112	2026-03-26 10:44:24.323112
31008	07:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:24.835308	2026-03-26 10:44:24.835308
31009	07:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:25.346396	2026-03-26 10:44:25.346396
31010	08:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:25.875343	2026-03-26 10:44:25.875343
31011	08:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:26.380894	2026-03-26 10:44:26.380894
31012	09:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:26.899138	2026-03-26 10:44:26.899138
31013	09:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:27.415667	2026-03-26 10:44:27.415667
31014	05:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:27.785119	2026-03-26 10:44:27.785119
31015	10:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:27.917812	2026-03-26 10:44:27.917812
31016	06:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:28.28036	2026-03-26 10:44:28.28036
31017	10:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:28.41312	2026-03-26 10:44:28.41312
31018	06:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:28.793369	2026-03-26 10:44:28.793369
31019	11:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:28.90784	2026-03-26 10:44:28.90784
31020	07:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:29.298508	2026-03-26 10:44:29.298508
31021	11:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:29.410746	2026-03-26 10:44:29.410746
31022	07:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:29.801306	2026-03-26 10:44:29.801306
31023	12:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:29.890877	2026-03-26 10:44:29.890877
31024	08:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:30.310728	2026-03-26 10:44:30.310728
31025	12:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:30.384537	2026-03-26 10:44:30.384537
31026	08:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:30.817239	2026-03-26 10:44:30.817239
31027	13:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:30.87724	2026-03-26 10:44:30.87724
31028	09:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:31.325507	2026-03-26 10:44:31.325507
31029	13:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:31.373968	2026-03-26 10:44:31.373968
31030	09:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:31.831628	2026-03-26 10:44:31.831628
31031	14:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:31.860897	2026-03-26 10:44:31.860897
31032	10:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:32.323272	2026-03-26 10:44:32.323272
31033	14:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:33.627227	2026-03-26 10:44:33.627227
31034	05:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:34.116013	2026-03-26 10:44:34.116013
31035	15:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:34.138148	2026-03-26 10:44:34.138148
31036	10:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:34.15078	2026-03-26 10:44:34.15078
31037	06:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:34.630682	2026-03-26 10:44:34.630682
31038	11:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:34.63996	2026-03-26 10:44:34.63996
31039	15:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:34.646387	2026-03-26 10:44:34.646387
31040	11:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:35.136547	2026-03-26 10:44:35.136547
31041	06:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:35.140092	2026-03-26 10:44:35.140092
31042	07:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:35.639839	2026-03-26 10:44:35.639839
31043	12:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:35.644387	2026-03-26 10:44:35.644387
31044	07:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:36.145747	2026-03-26 10:44:36.145747
31045	16:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:37.078342	2026-03-26 10:44:37.078342
31046	12:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:37.425357	2026-03-26 10:44:37.425357
31047	08:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:37.992028	2026-03-26 10:44:37.992028
31048	08:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:38.596364	2026-03-26 10:44:38.596364
31049	16:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:39.024334	2026-03-26 10:44:39.024334
31050	13:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:39.317661	2026-03-26 10:44:39.317661
31051	17:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:39.521423	2026-03-26 10:44:39.521423
31052	13:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:39.818203	2026-03-26 10:44:39.818203
31053	17:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:40.02414	2026-03-26 10:44:40.02414
31054	14:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:40.330903	2026-03-26 10:44:40.330903
31055	09:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:40.42795	2026-03-26 10:44:40.42795
31056	18:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 10:44:40.534318	2026-03-26 10:44:40.534318
31057	14:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:40.816545	2026-03-26 10:44:40.816545
31059	15:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:41.300506	2026-03-26 10:44:41.300506
31061	15:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:41.793257	2026-03-26 10:44:41.793257
31062	09:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:42.221182	2026-03-26 10:44:42.221182
31064	16:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:42.285474	2026-03-26 10:44:42.285474
31065	10:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:42.713565	2026-03-26 10:44:42.713565
31067	16:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:42.814748	2026-03-26 10:44:42.814748
31068	10:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:43.213098	2026-03-26 10:44:43.213098
31070	17:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:43.311839	2026-03-26 10:44:43.311839
31071	11:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:43.717438	2026-03-26 10:44:43.717438
31073	17:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:43.827072	2026-03-26 10:44:43.827072
31058	05:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:41.24833	2026-03-26 10:44:41.24833
31075	11:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:44.224713	2026-03-26 10:44:44.224713
31077	18:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:44.319842	2026-03-26 10:44:44.319842
31060	06:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:41.749585	2026-03-26 10:44:41.749585
31079	12:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:44.736297	2026-03-26 10:44:44.736297
31081	18:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:44.835017	2026-03-26 10:44:44.835017
31063	06:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:42.249882	2026-03-26 10:44:42.249882
31083	12:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:45.230108	2026-03-26 10:44:45.230108
31085	19:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:45.329012	2026-03-26 10:44:45.329012
31066	07:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:42.752072	2026-03-26 10:44:42.752072
31087	13:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:45.71506	2026-03-26 10:44:45.71506
31089	19:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:45.827867	2026-03-26 10:44:45.827867
31069	07:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:43.249654	2026-03-26 10:44:43.249654
31091	13:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:46.198752	2026-03-26 10:44:46.198752
31093	20:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 10:44:46.333371	2026-03-26 10:44:46.333371
31072	08:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:43.747207	2026-03-26 10:44:43.747207
31095	14:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:46.693808	2026-03-26 10:44:46.693808
31097	14:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:47.184177	2026-03-26 10:44:47.184177
31080	09:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:44.766866	2026-03-26 10:44:44.766866
31084	09:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:45.26941	2026-03-26 10:44:45.26941
31088	10:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:45.756863	2026-03-26 10:44:45.756863
31092	10:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:46.260531	2026-03-26 10:44:46.260531
31096	11:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:46.764296	2026-03-26 10:44:46.764296
31098	11:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:47.266374	2026-03-26 10:44:47.266374
31099	15:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:47.67838	2026-03-26 10:44:47.67838
31101	15:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:48.182	2026-03-26 10:44:48.182
31076	08:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:44.253515	2026-03-26 10:44:44.253515
31104	16:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:48.696265	2026-03-26 10:44:48.696265
31107	16:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:49.210833	2026-03-26 10:44:49.210833
31110	17:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:49.725052	2026-03-26 10:44:49.725052
31113	17:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:50.215486	2026-03-26 10:44:50.215486
31116	18:00	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:50.712665	2026-03-26 10:44:50.712665
31119	18:30	26-03-2026	Xe 28G				Sài Gòn - Xuân Lộc (Cao tốc)	2026-03-26 10:44:51.210985	2026-03-26 10:44:51.210985
31100	12:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:47.762686	2026-03-26 10:44:47.762686
31102	12:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:48.304634	2026-03-26 10:44:48.304634
31105	13:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:48.794812	2026-03-26 10:44:48.794812
31108	13:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:49.278105	2026-03-26 10:44:49.278105
31111	14:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:49.771378	2026-03-26 10:44:49.771378
31114	14:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:50.263413	2026-03-26 10:44:50.263413
31117	15:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:50.758977	2026-03-26 10:44:50.758977
31120	15:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:51.253001	2026-03-26 10:44:51.253001
31122	16:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:51.761714	2026-03-26 10:44:51.761714
31124	16:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:52.263716	2026-03-26 10:44:52.263716
31126	17:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:52.817111	2026-03-26 10:44:52.817111
31128	17:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:53.303556	2026-03-26 10:44:53.303556
31130	18:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:53.822613	2026-03-26 10:44:53.822613
31132	18:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:54.309564	2026-03-26 10:44:54.309564
31134	19:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:54.800277	2026-03-26 10:44:54.800277
31136	19:30	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:55.297557	2026-03-26 10:44:55.297557
31138	20:00	26-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 10:44:55.809491	2026-03-26 10:44:55.809491
31178	03:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:28.572972	2026-03-26 12:56:28.572972
31179	04:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:29.108179	2026-03-26 12:56:29.108179
31180	04:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:29.618705	2026-03-26 12:56:29.618705
31181	05:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:30.132604	2026-03-26 12:56:30.132604
31182	05:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:30.66061	2026-03-26 12:56:30.66061
31183	06:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:31.182024	2026-03-26 12:56:31.182024
31184	06:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:31.705136	2026-03-26 12:56:31.705136
31185	07:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:32.217971	2026-03-26 12:56:32.217971
31186	07:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:32.727851	2026-03-26 12:56:32.727851
31187	08:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:33.250803	2026-03-26 12:56:33.250803
31188	08:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:33.781637	2026-03-26 12:56:33.781637
31189	09:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:34.315154	2026-03-26 12:56:34.315154
31190	09:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:34.840178	2026-03-26 12:56:34.840178
31191	10:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:35.3594	2026-03-26 12:56:35.3594
31192	10:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:35.877488	2026-03-26 12:56:35.877488
31193	11:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:36.403546	2026-03-26 12:56:36.403546
31194	11:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:36.909473	2026-03-26 12:56:36.909473
31195	12:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:37.436708	2026-03-26 12:56:37.436708
31196	12:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:37.970469	2026-03-26 12:56:37.970469
31197	13:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:38.487634	2026-03-26 12:56:38.487634
31198	13:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:38.995861	2026-03-26 12:56:38.995861
31199	14:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:39.535945	2026-03-26 12:56:39.535945
31200	14:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:40.063991	2026-03-26 12:56:40.063991
31201	15:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:40.581277	2026-03-26 12:56:40.581277
31202	15:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:41.099423	2026-03-26 12:56:41.099423
31203	16:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:41.61462	2026-03-26 12:56:41.61462
31204	16:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:42.117022	2026-03-26 12:56:42.117022
31205	17:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:42.621527	2026-03-26 12:56:42.621527
31206	17:30	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:43.110972	2026-03-26 12:56:43.110972
31207	18:00	26-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 12:56:43.620243	2026-03-26 12:56:43.620243
31208	05:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:14.243575	2026-03-26 12:57:14.243575
31209	06:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:14.760101	2026-03-26 12:57:14.760101
31210	06:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:15.273956	2026-03-26 12:57:15.273956
31211	07:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:15.776629	2026-03-26 12:57:15.776629
31212	07:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:16.278183	2026-03-26 12:57:16.278183
31213	08:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:16.786425	2026-03-26 12:57:16.786425
31214	08:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:17.298018	2026-03-26 12:57:17.298018
31215	09:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:17.801251	2026-03-26 12:57:17.801251
31216	09:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:18.318039	2026-03-26 12:57:18.318039
31217	10:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:18.842355	2026-03-26 12:57:18.842355
31218	10:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:19.351625	2026-03-26 12:57:19.351625
31219	11:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:21.162015	2026-03-26 12:57:21.162015
31220	11:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:21.699935	2026-03-26 12:57:21.699935
31221	12:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:22.204479	2026-03-26 12:57:22.204479
31222	12:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:22.701151	2026-03-26 12:57:22.701151
31223	13:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:23.211033	2026-03-26 12:57:23.211033
31224	13:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:23.727053	2026-03-26 12:57:23.727053
31225	14:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:24.24547	2026-03-26 12:57:24.24547
31226	14:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:24.777004	2026-03-26 12:57:24.777004
31227	15:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:25.291479	2026-03-26 12:57:25.291479
31228	15:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:25.804887	2026-03-26 12:57:25.804887
31229	16:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:26.335076	2026-03-26 12:57:26.335076
31230	16:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:26.836706	2026-03-26 12:57:26.836706
31231	05:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:27.098732	2026-03-26 12:57:27.098732
31232	17:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:27.341291	2026-03-26 12:57:27.341291
31233	06:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:27.620912	2026-03-26 12:57:27.620912
31234	17:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:27.833049	2026-03-26 12:57:27.833049
31235	06:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:28.123607	2026-03-26 12:57:28.123607
31236	18:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:28.334523	2026-03-26 12:57:28.334523
31237	07:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:28.636001	2026-03-26 12:57:28.636001
31238	18:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:28.828005	2026-03-26 12:57:28.828005
31239	07:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:29.138445	2026-03-26 12:57:29.138445
31240	19:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:29.338844	2026-03-26 12:57:29.338844
31241	08:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:29.655042	2026-03-26 12:57:29.655042
31242	19:30	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:29.83092	2026-03-26 12:57:29.83092
31243	08:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:30.151808	2026-03-26 12:57:30.151808
31244	20:00	27-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:30.323217	2026-03-26 12:57:30.323217
31245	09:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:32.708447	2026-03-26 12:57:32.708447
31246	09:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:34.670929	2026-03-26 12:57:34.670929
31247	10:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:35.184278	2026-03-26 12:57:35.184278
31248	10:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:36.198221	2026-03-26 12:57:36.198221
31249	11:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:36.693948	2026-03-26 12:57:36.693948
31250	11:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:37.194202	2026-03-26 12:57:37.194202
31251	12:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:37.704183	2026-03-26 12:57:37.704183
31252	12:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:38.21659	2026-03-26 12:57:38.21659
31253	13:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:38.707169	2026-03-26 12:57:38.707169
31254	13:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:39.214305	2026-03-26 12:57:39.214305
31255	14:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:39.717725	2026-03-26 12:57:39.717725
31256	14:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:40.224517	2026-03-26 12:57:40.224517
31257	15:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:40.739089	2026-03-26 12:57:40.739089
31258	15:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:41.244567	2026-03-26 12:57:41.244567
31259	16:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:43.033995	2026-03-26 12:57:43.033995
31260	16:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:45.580749	2026-03-26 12:57:45.580749
31261	17:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:46.104385	2026-03-26 12:57:46.104385
31262	17:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:46.612468	2026-03-26 12:57:46.612468
31263	18:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:47.114772	2026-03-26 12:57:47.114772
31264	18:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:47.879814	2026-03-26 12:57:47.879814
31265	19:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:48.394685	2026-03-26 12:57:48.394685
31266	19:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:48.889585	2026-03-26 12:57:48.889585
31267	20:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 12:57:49.512967	2026-03-26 12:57:49.512967
31268	05:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:44.448055	2026-03-26 13:02:44.448055
31269	06:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:44.953757	2026-03-26 13:02:44.953757
31270	06:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:45.476754	2026-03-26 13:02:45.476754
31271	07:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:45.979436	2026-03-26 13:02:45.979436
31272	07:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:46.479777	2026-03-26 13:02:46.479777
31273	08:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:46.988606	2026-03-26 13:02:46.988606
31274	08:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:47.526148	2026-03-26 13:02:47.526148
31275	09:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:48.068218	2026-03-26 13:02:48.068218
31276	09:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:48.576393	2026-03-26 13:02:48.576393
31277	10:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:49.085932	2026-03-26 13:02:49.085932
31278	10:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:49.584238	2026-03-26 13:02:49.584238
31279	11:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:51.408055	2026-03-26 13:02:51.408055
31280	11:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:51.917812	2026-03-26 13:02:51.917812
31281	12:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:52.477813	2026-03-26 13:02:52.477813
31282	12:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:52.989296	2026-03-26 13:02:52.989296
31283	13:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:53.499799	2026-03-26 13:02:53.499799
31284	13:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:54.000206	2026-03-26 13:02:54.000206
31285	14:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:54.509875	2026-03-26 13:02:54.509875
31286	14:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:55.01636	2026-03-26 13:02:55.01636
31287	15:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:55.529529	2026-03-26 13:02:55.529529
31288	15:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:56.035879	2026-03-26 13:02:56.035879
31289	16:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:56.544843	2026-03-26 13:02:56.544843
31290	16:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:57.052601	2026-03-26 13:02:57.052601
31291	17:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:57.564694	2026-03-26 13:02:57.564694
31292	17:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:58.062099	2026-03-26 13:02:58.062099
31293	18:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:58.560221	2026-03-26 13:02:58.560221
31294	18:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:59.087678	2026-03-26 13:02:59.087678
31295	19:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:02:59.645431	2026-03-26 13:02:59.645431
31296	19:30	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:03:00.142782	2026-03-26 13:03:00.142782
31297	20:00	29-03-2026	Xe 28G				Sài Gòn - Long Khánh (Quốc lộ)	2026-03-26 13:03:00.652044	2026-03-26 13:03:00.652044
31298	03:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:13.245924	2026-03-26 13:03:13.245924
31299	04:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:13.792579	2026-03-26 13:03:13.792579
31300	04:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:14.312869	2026-03-26 13:03:14.312869
31301	05:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:14.820563	2026-03-26 13:03:14.820563
31302	05:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:15.320055	2026-03-26 13:03:15.320055
31303	06:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:15.822459	2026-03-26 13:03:15.822459
31304	06:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:16.32107	2026-03-26 13:03:16.32107
31305	07:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:16.812913	2026-03-26 13:03:16.812913
31306	07:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:17.300302	2026-03-26 13:03:17.300302
31307	08:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:17.80181	2026-03-26 13:03:17.80181
31308	08:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:18.302871	2026-03-26 13:03:18.302871
31309	09:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:18.789162	2026-03-26 13:03:18.789162
31310	09:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:19.343416	2026-03-26 13:03:19.343416
31311	10:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:19.836638	2026-03-26 13:03:19.836638
31312	10:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:20.386446	2026-03-26 13:03:20.386446
31313	11:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:20.881696	2026-03-26 13:03:20.881696
31314	11:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:21.397752	2026-03-26 13:03:21.397752
31315	12:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:21.922707	2026-03-26 13:03:21.922707
31316	12:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:22.424107	2026-03-26 13:03:22.424107
31317	13:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:22.93573	2026-03-26 13:03:22.93573
31318	13:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:23.447994	2026-03-26 13:03:23.447994
31319	14:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:23.952167	2026-03-26 13:03:23.952167
31320	14:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:24.463677	2026-03-26 13:03:24.463677
31321	15:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:24.965286	2026-03-26 13:03:24.965286
31322	15:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:25.469153	2026-03-26 13:03:25.469153
31323	16:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:25.973218	2026-03-26 13:03:25.973218
31324	16:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:26.495012	2026-03-26 13:03:26.495012
31325	17:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:27.108198	2026-03-26 13:03:27.108198
31326	17:30	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:27.638642	2026-03-26 13:03:27.638642
31327	18:00	29-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:03:28.15018	2026-03-26 13:03:28.15018
31329	04:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:40.443801	2026-03-26 13:06:40.443801
31330	04:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:40.872592	2026-03-26 13:06:40.872592
31331	05:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:41.300625	2026-03-26 13:06:41.300625
31332	05:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:41.727955	2026-03-26 13:06:41.727955
31333	06:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:42.155987	2026-03-26 13:06:42.155987
31334	06:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:42.584601	2026-03-26 13:06:42.584601
31335	07:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:43.012612	2026-03-26 13:06:43.012612
31336	07:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:43.439586	2026-03-26 13:06:43.439586
31337	08:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:43.870562	2026-03-26 13:06:43.870562
31338	08:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:44.298293	2026-03-26 13:06:44.298293
31339	09:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:44.728009	2026-03-26 13:06:44.728009
31340	09:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:45.157968	2026-03-26 13:06:45.157968
31341	10:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:45.585813	2026-03-26 13:06:45.585813
31342	10:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:46.017225	2026-03-26 13:06:46.017225
31343	11:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:46.444567	2026-03-26 13:06:46.444567
31344	11:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:46.871932	2026-03-26 13:06:46.871932
31345	12:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:47.299678	2026-03-26 13:06:47.299678
31346	12:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:47.726869	2026-03-26 13:06:47.726869
31347	13:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:48.154917	2026-03-26 13:06:48.154917
31348	13:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:48.581693	2026-03-26 13:06:48.581693
31349	14:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:49.009252	2026-03-26 13:06:49.009252
31350	14:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:49.436452	2026-03-26 13:06:49.436452
31351	15:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:49.863949	2026-03-26 13:06:49.863949
31352	15:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:50.290978	2026-03-26 13:06:50.290978
31353	16:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:50.720148	2026-03-26 13:06:50.720148
31354	16:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:51.147189	2026-03-26 13:06:51.147189
31356	17:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:52.001887	2026-03-26 13:06:52.001887
31357	18:00	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:52.429029	2026-03-26 13:06:52.429029
31358	03:30	30-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:06:57.844786	2026-03-26 13:06:57.844786
31359	04:00	30-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:06:58.357819	2026-03-26 13:06:58.357819
31360	04:30	30-03-2026	Xe 28G				Long Khánh - Sài Gòn (Quốc lộ)	2026-03-26 13:07:00.12687	2026-03-26 13:07:00.12687
31361	03:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:11.682125	2026-03-26 13:07:11.682125
31362	04:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:12.101874	2026-03-26 13:07:12.101874
31363	04:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:12.52932	2026-03-26 13:07:12.52932
31364	05:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:12.948737	2026-03-26 13:07:12.948737
31365	05:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:13.368129	2026-03-26 13:07:13.368129
31366	06:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:13.787604	2026-03-26 13:07:13.787604
31367	06:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:14.206919	2026-03-26 13:07:14.206919
31368	07:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:14.626226	2026-03-26 13:07:14.626226
31369	07:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:15.046165	2026-03-26 13:07:15.046165
31370	08:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:15.465286	2026-03-26 13:07:15.465286
31371	08:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:15.884813	2026-03-26 13:07:15.884813
31372	09:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:16.312564	2026-03-26 13:07:16.312564
31373	09:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:16.731751	2026-03-26 13:07:16.731751
31374	10:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:17.152046	2026-03-26 13:07:17.152046
31375	10:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:17.571437	2026-03-26 13:07:17.571437
31376	11:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:17.996843	2026-03-26 13:07:17.996843
31377	11:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:18.416266	2026-03-26 13:07:18.416266
31378	12:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:18.835684	2026-03-26 13:07:18.835684
31379	12:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:19.2551	2026-03-26 13:07:19.2551
31380	13:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:19.674454	2026-03-26 13:07:19.674454
31381	13:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:20.093921	2026-03-26 13:07:20.093921
31382	14:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:20.513234	2026-03-26 13:07:20.513234
31383	14:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:20.932637	2026-03-26 13:07:20.932637
31384	15:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:21.351957	2026-03-26 13:07:21.351957
31385	15:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:21.771176	2026-03-26 13:07:21.771176
31386	16:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:22.190608	2026-03-26 13:07:22.190608
31387	16:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:22.610173	2026-03-26 13:07:22.610173
31328	03:30	27-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:06:40.011149	2026-03-27 01:28:20.174685
31388	17:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:23.03055	2026-03-26 13:07:23.03055
31389	17:30	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:23.45008	2026-03-26 13:07:23.45008
31390	18:00	28-03-2026	Xe 28G				Long Khánh - Sài Gòn (Cao tốc)	2026-03-26 13:07:23.869971	2026-03-26 13:07:23.869971
31391	05:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:36.670007	2026-03-26 13:07:36.670007
31392	06:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:37.096438	2026-03-26 13:07:37.096438
31393	06:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:37.522866	2026-03-26 13:07:37.522866
31394	07:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:37.949758	2026-03-26 13:07:37.949758
31395	07:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:38.376215	2026-03-26 13:07:38.376215
31396	08:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:38.804533	2026-03-26 13:07:38.804533
31397	08:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:39.231019	2026-03-26 13:07:39.231019
31398	09:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:39.657525	2026-03-26 13:07:39.657525
31399	09:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:40.08389	2026-03-26 13:07:40.08389
31400	10:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:40.510428	2026-03-26 13:07:40.510428
31401	10:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:40.951073	2026-03-26 13:07:40.951073
31402	11:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:41.377801	2026-03-26 13:07:41.377801
31403	11:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:41.804232	2026-03-26 13:07:41.804232
31404	12:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:42.231636	2026-03-26 13:07:42.231636
31405	12:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:42.658125	2026-03-26 13:07:42.658125
31406	13:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:43.084338	2026-03-26 13:07:43.084338
31407	13:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:43.510452	2026-03-26 13:07:43.510452
31408	14:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:43.937133	2026-03-26 13:07:43.937133
31409	14:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:44.364177	2026-03-26 13:07:44.364177
31410	15:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:44.790397	2026-03-26 13:07:44.790397
31411	15:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:45.216814	2026-03-26 13:07:45.216814
31412	16:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:45.643532	2026-03-26 13:07:45.643532
31413	16:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:46.070616	2026-03-26 13:07:46.070616
31414	17:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:46.497566	2026-03-26 13:07:46.497566
31415	17:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:46.924386	2026-03-26 13:07:46.924386
31416	18:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:47.350861	2026-03-26 13:07:47.350861
31417	18:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:47.777443	2026-03-26 13:07:47.777443
31418	19:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:48.204221	2026-03-26 13:07:48.204221
31419	19:30	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:48.630616	2026-03-26 13:07:48.630616
31420	20:00	28-03-2026	Xe 28G				Sài Gòn - Long Khánh (Cao tốc)	2026-03-26 13:07:49.05702	2026-03-26 13:07:49.05702
\.


--
-- Data for Name: TH_Users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_Users" (id, username, password, "fullName", role, active, "createdAt", "updatedAt", email, phone) FROM stdin;
2	quanly1	$2a$10$UhLdIJK/ClOXrtCUqgvPYuiTHWvgxUUdvC.5noKDp/QO9hFN3gMc.	Quản lý 1	manager	t	2026-01-15 17:09:37.922277	2026-01-15 17:09:37.922277	\N	\N
3	nhanvien1	$2a$10$UhLdIJK/ClOXrtCUqgvPYuiTHWvgxUUdvC.5noKDp/QO9hFN3gMc.	Nhân viên 1	employee	t	2026-01-15 17:09:37.922277	2026-01-15 17:09:37.922277	\N	\N
1	admin	$2a$10$UhLdIJK/ClOXrtCUqgvPYuiTHWvgxUUdvC.5noKDp/QO9hFN3gMc.	Administrator	admin	t	2026-01-15 17:09:37.922277	2026-01-15 17:09:37.922277	lequangminh951@gmail.com	0908724146
\.


--
-- Data for Name: TH_VehicleStatus; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_VehicleStatus" (id, "vehicleId", status, note, "updatedBy", "updatedAt") FROM stdin;
\.


--
-- Data for Name: TH_Vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TH_Vehicles" (id, code, type, "createdAt", "updatedAt") FROM stdin;
306	28G	51B26879	2026-03-27 01:14:51.383341	2026-03-27 01:14:51.383341
307	28G	51B23033	2026-04-09 01:29:56.354864	2026-04-09 01:29:56.354864
313	50F-01057	50F-01057	2026-04-09 01:44:50.400308	2026-04-09 01:44:50.400308
314	51B-04068	51B-04068	2026-04-12 09:55:41.317124	2026-04-12 09:55:41.317124
316	60F-01031	60F-01031	2026-04-12 10:17:22.833303	2026-04-12 10:17:22.833303
266	28G	60B02574	2026-01-25 08:47:43.630565	2026-01-25 08:47:43.630565
267	28G	51B23831	2026-01-25 08:47:43.643982	2026-01-25 08:47:43.643982
268	28G	51B26186	2026-01-25 08:47:43.645698	2026-01-25 08:47:43.645698
269	28G	60B05480	2026-01-25 08:47:43.648715	2026-01-25 08:47:43.648715
270	28G	60B04650	2026-01-25 08:47:43.651835	2026-01-25 08:47:43.651835
271	28G	60B03434	2026-01-25 08:47:43.660283	2026-01-25 08:47:43.660283
272	28G	51B23094	2026-01-25 08:47:43.663264	2026-01-25 08:47:43.663264
273	28G	60B02860	2026-01-25 08:47:43.673491	2026-01-25 08:47:43.673491
274	28G	60B02817	2026-01-25 08:47:43.674314	2026-01-25 08:47:43.674314
275	28G	60B02324	2026-01-25 08:47:43.685349	2026-01-25 08:47:43.685349
276	28G	60B03642	2026-01-25 08:47:43.691473	2026-01-25 08:47:43.691473
277	28G	51B27642	2026-01-25 08:47:43.69615	2026-01-25 08:47:43.69615
278	28G	60B03598	2026-01-25 08:47:43.697464	2026-01-25 08:47:43.697464
279	28G	51B27452	2026-01-25 08:47:43.701941	2026-01-25 08:47:43.701941
280	28G	60B03157	2026-01-25 08:47:43.710671	2026-01-25 08:47:43.710671
281	28G	51B23949	2026-01-25 08:47:43.714832	2026-01-25 08:47:43.714832
282	28G	60B04564	2026-01-25 08:47:43.720184	2026-01-25 08:47:43.720184
283	28G	60B02397	2026-01-25 08:47:43.720794	2026-01-25 08:47:43.720794
284	28G	60B03597	2026-01-25 08:48:25.570982	2026-01-25 08:48:25.570982
285	28G	51B27642	2026-01-25 08:48:25.583043	2026-01-25 08:48:25.583043
286	28G	60B04647	2026-01-25 08:48:25.586263	2026-01-25 08:48:25.586263
287	28G	60B05352	2026-01-25 08:48:25.587435	2026-01-25 08:48:25.587435
288	28G	51B27795	2026-01-25 08:48:25.597276	2026-01-25 08:48:25.597276
289	28G	51B26542	2026-01-25 08:48:25.598637	2026-01-25 08:48:25.598637
290	28G	60B03435	2026-01-25 08:48:25.595392	2026-01-25 08:48:25.595392
291	28G	60B02522	2026-01-25 08:48:25.601581	2026-01-25 08:48:25.601581
292	28G	60B04643	2026-01-25 08:48:25.608725	2026-01-25 08:48:25.608725
293	28G	51B23870	2026-01-25 08:48:25.609419	2026-01-25 08:48:25.609419
294	28G	51B26030	2026-01-25 08:48:25.617844	2026-01-25 08:48:25.617844
296	28G	51B26411	2026-01-25 08:48:25.618891	2026-01-25 08:48:25.618891
295	28G	60B04627	2026-01-25 08:48:25.619495	2026-01-25 08:48:25.619495
297	28G	51B23033	2026-01-25 08:48:25.635128	2026-01-25 08:48:25.635128
298	28G	60B05307	2026-01-25 08:48:25.635955	2026-01-25 08:48:25.635955
299	28G	51B23831	2026-01-25 08:48:25.638647	2026-01-25 08:48:25.638647
300	28G	60B02574	2026-01-25 08:48:25.64376	2026-01-25 08:48:25.64376
301	28G	60B03598	2026-01-25 08:48:25.646263	2026-01-25 08:48:25.646263
302	28G	60B04103	2026-01-25 08:48:25.647793	2026-01-25 08:48:25.647793
303	28G	50H31935	2026-01-25 08:48:25.654367	2026-01-25 08:48:25.654367
304	28G	60B03228	2026-01-25 08:48:25.654947	2026-01-25 08:48:25.654947
305	28G	51B23094	2026-01-25 08:48:25.655435	2026-01-25 08:48:25.655435
247	28G	51B26018	2026-01-25 08:47:43.558817	2026-01-25 08:47:43.558817
256	28G	60B02574	2026-01-25 08:47:43.595438	2026-01-25 08:47:43.595438
257	28G	60B03157	2026-01-25 08:47:43.598432	2026-01-25 08:47:43.598432
243	28G	60B02324	2026-01-25 08:47:43.555931	2026-01-25 08:47:43.555931
245	28G	60B02817	2026-01-25 08:47:43.557764	2026-01-25 08:47:43.557764
250	28G	60B02397	2026-01-25 08:47:43.570563	2026-01-25 08:47:43.570563
242	28G	60B04466	2026-01-25 08:47:43.555597	2026-01-25 08:47:43.555597
251	28G	60B03107	2026-01-25 08:47:43.571641	2026-01-25 08:47:43.571641
258	28G	60B03642	2026-01-25 08:47:43.599126	2026-01-25 08:47:43.599126
253	28G	51B26186	2026-01-25 08:47:43.582358	2026-01-25 08:47:43.582358
252	28G	60B04564	2026-01-25 08:47:43.575021	2026-01-25 08:47:43.575021
259	28G	60B05480	2026-01-25 08:47:43.604318	2026-01-25 08:47:43.604318
248	28G	60B04671	2026-01-25 08:47:43.559151	2026-01-25 08:47:43.559151
255	28G	60B04424	2026-01-25 08:47:43.592073	2026-01-25 08:47:43.592073
249	28G	60B04349	2026-01-25 08:47:43.569948	2026-01-25 08:47:43.569948
254	28G	50H31437	2026-01-25 08:47:43.583573	2026-01-25 08:47:43.583573
246	28G	51B23949	2026-01-25 08:47:43.558005	2026-01-25 08:47:43.558005
244	28G	60B02860	2026-01-25 08:47:43.557454	2026-01-25 08:47:43.557454
240	28G	51B26025	2026-01-25 08:47:43.554731	2026-01-25 08:47:43.554731
241	28G	51B27452	2026-01-25 08:47:43.555224	2026-01-25 08:47:43.555224
262	28G	60B03651	2026-01-25 08:47:43.612362	2026-01-25 08:47:43.612362
263	28G	60B05296	2026-01-25 08:47:43.623074	2026-01-25 08:47:43.623074
265	28G	60B03938	2026-01-25 08:47:43.629874	2026-01-25 08:47:43.629874
261	28G	60B03434	2026-01-25 08:47:43.610139	2026-01-25 08:47:43.610139
260	28G	60B04650	2026-01-25 08:47:43.605907	2026-01-25 08:47:43.605907
264	28G	60B04669	2026-01-25 08:47:43.623787	2026-01-25 08:47:43.623787
\.


--
-- Name: TH_ActivityLog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_ActivityLog_id_seq"', 38, true);


--
-- Name: TH_Bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_Bookings_id_seq"', 126, true);


--
-- Name: TH_CustomerMessages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_CustomerMessages_id_seq"', 21, true);


--
-- Name: TH_CustomerRequests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_CustomerRequests_id_seq"', 7, true);


--
-- Name: TH_Drivers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_Drivers_id_seq"', 82, true);


--
-- Name: TH_Routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_Routes_id_seq"', 16, true);


--
-- Name: TH_SeatLocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_SeatLocks_id_seq"', 96, true);


--
-- Name: TH_StaffTasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_StaffTasks_id_seq"', 1, false);


--
-- Name: TH_TimeSlots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_TimeSlots_id_seq"', 33791, true);


--
-- Name: TH_Users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_Users_id_seq"', 3, true);


--
-- Name: TH_VehicleStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_VehicleStatus_id_seq"', 1, false);


--
-- Name: TH_Vehicles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TH_Vehicles_id_seq"', 316, true);


--
-- Name: TH_ActivityLog TH_ActivityLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_ActivityLog"
    ADD CONSTRAINT "TH_ActivityLog_pkey" PRIMARY KEY (id);


--
-- Name: TH_Bookings TH_Bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Bookings"
    ADD CONSTRAINT "TH_Bookings_pkey" PRIMARY KEY (id);


--
-- Name: TH_CustomerMessages TH_CustomerMessages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_CustomerMessages"
    ADD CONSTRAINT "TH_CustomerMessages_pkey" PRIMARY KEY (id);


--
-- Name: TH_CustomerRequests TH_CustomerRequests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_CustomerRequests"
    ADD CONSTRAINT "TH_CustomerRequests_pkey" PRIMARY KEY (id);


--
-- Name: TH_Drivers TH_Drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Drivers"
    ADD CONSTRAINT "TH_Drivers_pkey" PRIMARY KEY (id);


--
-- Name: TH_Routes TH_Routes_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Routes"
    ADD CONSTRAINT "TH_Routes_name_key" UNIQUE (name);


--
-- Name: TH_Routes TH_Routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Routes"
    ADD CONSTRAINT "TH_Routes_pkey" PRIMARY KEY (id);


--
-- Name: TH_SeatLocks TH_SeatLocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_SeatLocks"
    ADD CONSTRAINT "TH_SeatLocks_pkey" PRIMARY KEY (id);


--
-- Name: TH_StaffTasks TH_StaffTasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_StaffTasks"
    ADD CONSTRAINT "TH_StaffTasks_pkey" PRIMARY KEY (id);


--
-- Name: TH_TimeSlots TH_TimeSlots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_TimeSlots"
    ADD CONSTRAINT "TH_TimeSlots_pkey" PRIMARY KEY (id);


--
-- Name: TH_Users TH_Users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Users"
    ADD CONSTRAINT "TH_Users_pkey" PRIMARY KEY (id);


--
-- Name: TH_Users TH_Users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Users"
    ADD CONSTRAINT "TH_Users_username_key" UNIQUE (username);


--
-- Name: TH_VehicleStatus TH_VehicleStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_VehicleStatus"
    ADD CONSTRAINT "TH_VehicleStatus_pkey" PRIMARY KEY (id);


--
-- Name: TH_Vehicles TH_Vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Vehicles"
    ADD CONSTRAINT "TH_Vehicles_pkey" PRIMARY KEY (id);


--
-- Name: TH_SeatLocks UQ_SeatLock; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_SeatLocks"
    ADD CONSTRAINT "UQ_SeatLock" UNIQUE ("timeSlotId", "seatNumber", date, route);


--
-- Name: TH_TimeSlots unique_timeslot_date_time_route; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_TimeSlots"
    ADD CONSTRAINT unique_timeslot_date_time_route UNIQUE (date, "time", route);


--
-- Name: UQ_TimeSlot_date_time_route; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQ_TimeSlot_date_time_route" ON public."TH_TimeSlots" USING btree (date, "time", route);


--
-- Name: TH_Bookings TH_Bookings_timeSlotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_Bookings"
    ADD CONSTRAINT "TH_Bookings_timeSlotId_fkey" FOREIGN KEY ("timeSlotId") REFERENCES public."TH_TimeSlots"(id) ON DELETE CASCADE;


--
-- Name: TH_CustomerMessages TH_CustomerMessages_requestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_CustomerMessages"
    ADD CONSTRAINT "TH_CustomerMessages_requestId_fkey" FOREIGN KEY ("requestId") REFERENCES public."TH_CustomerRequests"(id) ON DELETE CASCADE;


--
-- Name: TH_VehicleStatus TH_VehicleStatus_vehicleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TH_VehicleStatus"
    ADD CONSTRAINT "TH_VehicleStatus_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES public."TH_Vehicles"(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ngtpBP8IYuhYSWqpKJl6O3Sc3P16rLSrEP1ufdP4lYuTy5ECbm9jVlNjs2Fm08U

