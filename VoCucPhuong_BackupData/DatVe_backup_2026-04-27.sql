--
-- PostgreSQL database dump
--

\restrict CWEQrp8j3hwO1xOPYOSVgqOpVpLe83VyqmFdm289o8KLioHIr6yAjf21FJ39dK9

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
-- Name: NhapHangUsers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NhapHangUsers" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    "fullName" character varying(100) NOT NULL,
    station character varying(100),
    role character varying(20) DEFAULT 'user'::character varying,
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT now(),
    "lastLogin" timestamp without time zone
);


--
-- Name: NhapHangUsers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NhapHangUsers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NhapHangUsers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NhapHangUsers_id_seq" OWNED BY public."NhapHangUsers".id;


--
-- Name: ProductLogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ProductLogs" (
    "logId" integer NOT NULL,
    "productId" character varying(50),
    action character varying(20) NOT NULL,
    field character varying(100),
    "oldValue" text,
    "newValue" text,
    "changedBy" character varying(100),
    "changedAt" timestamp without time zone DEFAULT now(),
    "ipAddress" character varying(50)
);


--
-- Name: ProductLogs_logId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ProductLogs_logId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ProductLogs_logId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ProductLogs_logId_seq" OWNED BY public."ProductLogs"."logId";


--
-- Name: Products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Products" (
    id character varying(50) NOT NULL,
    "senderName" character varying(100),
    "senderPhone" character varying(20),
    "senderStation" character varying(100),
    "receiverName" character varying(100) NOT NULL,
    "receiverPhone" character varying(20) NOT NULL,
    station character varying(100) NOT NULL,
    "productType" character varying(200) NOT NULL,
    quantity character varying(50),
    vehicle character varying(100),
    insurance numeric(12,2) DEFAULT 0,
    "totalAmount" numeric(12,2) DEFAULT 0,
    "paymentStatus" character varying(20) DEFAULT 'unpaid'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    "deliveryStatus" character varying(20),
    employee character varying(100),
    "createdBy" character varying(100),
    "sendDate" timestamp without time zone DEFAULT now(),
    "deliveredAt" timestamp without time zone,
    notes text,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: Stations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Stations" (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(255),
    phone character varying(20),
    "isActive" boolean DEFAULT true
);


--
-- Name: Stations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Stations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Stations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Stations_id_seq" OWNED BY public."Stations".id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    type character varying(100) NOT NULL,
    provider character varying(100) NOT NULL,
    provider_account_id character varying(255) NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type character varying(100),
    scope character varying(500),
    id_token text,
    session_state character varying(255)
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id character varying(255) NOT NULL,
    booking_code character varying(100) NOT NULL,
    user_id character varying(255),
    customer_name character varying(255) NOT NULL,
    customer_phone character varying(50) NOT NULL,
    customer_email character varying(255),
    route_id character varying(255) NOT NULL,
    schedule_id character varying(255),
    date date NOT NULL,
    departure_time character varying(50) NOT NULL,
    seats integer DEFAULT 1 NOT NULL,
    total_price integer NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    qr_code text,
    ticket_url character varying(500),
    checked_in boolean DEFAULT false NOT NULL,
    checked_in_at timestamp without time zone,
    checked_in_by character varying(255),
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT bookings_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'PAID'::character varying, 'CANCELLED'::character varying, 'COMPLETED'::character varying])::text[])))
);


--
-- Name: buses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buses (
    id character varying(255) NOT NULL,
    license_plate character varying(50) NOT NULL,
    bus_type character varying(100) NOT NULL,
    total_seats integer NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: internal_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(100),
    phone character varying(20),
    role character varying(20) DEFAULT 'user'::character varying,
    station character varying(100),
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: internal_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internal_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internal_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internal_users_id_seq OWNED BY public.internal_users.id;


--
-- Name: nh_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nh_counters (
    id integer NOT NULL,
    counter_key character varying(100) NOT NULL,
    value integer DEFAULT 0 NOT NULL,
    station character varying(100) NOT NULL,
    date_key character varying(20) NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: nh_counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nh_counters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nh_counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nh_counters_id_seq OWNED BY public.nh_counters.id;


--
-- Name: nh_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nh_products (
    id character varying(50) NOT NULL,
    sender_name character varying(100) NOT NULL,
    sender_phone character varying(20) NOT NULL,
    sender_station character varying(100) NOT NULL,
    receiver_name character varying(100) NOT NULL,
    receiver_phone character varying(20) NOT NULL,
    receiver_station character varying(100) NOT NULL,
    product_type character varying(200) NOT NULL,
    quantity integer DEFAULT 1,
    vehicle character varying(100),
    insurance numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) DEFAULT 0,
    payment_status character varying(20) DEFAULT 'unpaid'::character varying,
    employee character varying(100),
    created_by character varying(100),
    send_date date NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id character varying(255) NOT NULL,
    booking_id character varying(255) NOT NULL,
    amount integer NOT NULL,
    method character varying(50) NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    transaction_id character varying(255),
    paid_at timestamp without time zone,
    metadata text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY ((ARRAY['CASH'::character varying, 'BANK_TRANSFER'::character varying, 'QRCODE'::character varying, 'VNPAY'::character varying, 'MOMO'::character varying])::text[]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying, 'REFUNDED'::character varying])::text[])))
);


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routes (
    id character varying(255) NOT NULL,
    origin character varying(255) NOT NULL,
    destination character varying(255) NOT NULL,
    price integer NOT NULL,
    duration character varying(100) NOT NULL,
    bus_type character varying(100) NOT NULL,
    distance character varying(100),
    description text,
    route_map_image character varying(500),
    thumbnail_image character varying(500),
    images text,
    from_lat double precision,
    from_lng double precision,
    to_lat double precision,
    to_lng double precision,
    operating_start character varying(50) NOT NULL,
    operating_end character varying(50) NOT NULL,
    interval_minutes integer DEFAULT 30 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id character varying(255) NOT NULL,
    route_id character varying(255) NOT NULL,
    bus_id character varying(255) NOT NULL,
    date date NOT NULL,
    departure_time character varying(50) NOT NULL,
    available_seats integer NOT NULL,
    total_seats integer NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    session_token character varying(500) NOT NULL,
    user_id character varying(255) NOT NULL,
    expires timestamp without time zone NOT NULL
);


--
-- Name: stations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stations (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    full_name character varying(150) NOT NULL,
    address character varying(255),
    phone character varying(20),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: stations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stations_id_seq OWNED BY public.stations.id;


--
-- Name: th_bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.th_bookings (
    id integer NOT NULL,
    time_slot_id integer,
    customer_name character varying(100) NOT NULL,
    customer_phone character varying(20) NOT NULL,
    pickup_type character varying(50),
    pickup_address character varying(255),
    dropoff_type character varying(50),
    dropoff_address character varying(255),
    seat_number character varying(50),
    amount numeric(10,2) DEFAULT 0,
    payment_status character varying(20) DEFAULT 'unpaid'::character varying,
    route character varying(100),
    notes text,
    source character varying(50) DEFAULT 'TONGHOP'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: th_bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.th_bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: th_bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.th_bookings_id_seq OWNED BY public.th_bookings.id;


--
-- Name: th_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.th_customers (
    id integer NOT NULL,
    phone character varying(20) NOT NULL,
    full_name character varying(100) NOT NULL,
    pickup_type character varying(50),
    pickup_location character varying(200),
    dropoff_type character varying(50),
    dropoff_location character varying(200),
    notes text,
    total_bookings integer DEFAULT 0,
    last_booking_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: th_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.th_customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: th_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.th_customers_id_seq OWNED BY public.th_customers.id;


--
-- Name: th_freight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.th_freight (
    id integer NOT NULL,
    time_slot_id integer,
    sender_name character varying(100),
    sender_phone character varying(20),
    receiver_name character varying(100),
    receiver_phone character varying(20),
    receiver_address character varying(255),
    description text NOT NULL,
    weight numeric(10,2),
    quantity integer DEFAULT 1,
    freight_charge numeric(10,2) DEFAULT 0,
    cod_amount numeric(10,2) DEFAULT 0,
    status character varying(20) DEFAULT 'pending'::character varying,
    special_instructions text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: th_freight_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.th_freight_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: th_freight_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.th_freight_id_seq OWNED BY public.th_freight.id;


--
-- Name: th_timeslots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.th_timeslots (
    id integer NOT NULL,
    "time" character varying(10) NOT NULL,
    date character varying(20) NOT NULL,
    route character varying(100),
    type character varying(50) DEFAULT 'Xe 28G'::character varying,
    code character varying(50),
    driver character varying(100),
    phone character varying(20),
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: th_timeslots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.th_timeslots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: th_timeslots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.th_timeslots_id_seq OWNED BY public.th_timeslots.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified timestamp without time zone,
    password character varying(255),
    name character varying(255) NOT NULL,
    phone character varying(50),
    avatar character varying(500),
    role character varying(50) DEFAULT 'USER'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['USER'::character varying, 'STAFF'::character varying, 'ADMIN'::character varying])::text[])))
);


--
-- Name: NhapHangUsers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NhapHangUsers" ALTER COLUMN id SET DEFAULT nextval('public."NhapHangUsers_id_seq"'::regclass);


--
-- Name: ProductLogs logId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductLogs" ALTER COLUMN "logId" SET DEFAULT nextval('public."ProductLogs_logId_seq"'::regclass);


--
-- Name: Stations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations" ALTER COLUMN id SET DEFAULT nextval('public."Stations_id_seq"'::regclass);


--
-- Name: internal_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_users ALTER COLUMN id SET DEFAULT nextval('public.internal_users_id_seq'::regclass);


--
-- Name: nh_counters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nh_counters ALTER COLUMN id SET DEFAULT nextval('public.nh_counters_id_seq'::regclass);


--
-- Name: stations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations ALTER COLUMN id SET DEFAULT nextval('public.stations_id_seq'::regclass);


--
-- Name: th_bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_bookings ALTER COLUMN id SET DEFAULT nextval('public.th_bookings_id_seq'::regclass);


--
-- Name: th_customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_customers ALTER COLUMN id SET DEFAULT nextval('public.th_customers_id_seq'::regclass);


--
-- Name: th_freight id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_freight ALTER COLUMN id SET DEFAULT nextval('public.th_freight_id_seq'::regclass);


--
-- Name: th_timeslots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_timeslots ALTER COLUMN id SET DEFAULT nextval('public.th_timeslots_id_seq'::regclass);


--
-- Data for Name: NhapHangUsers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."NhapHangUsers" (id, username, password, "fullName", station, role, "isActive", "createdAt", "lastLogin") FROM stdin;
\.


--
-- Data for Name: ProductLogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ProductLogs" ("logId", "productId", action, field, "oldValue", "newValue", "changedBy", "changedAt", "ipAddress") FROM stdin;
\.


--
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Products" (id, "senderName", "senderPhone", "senderStation", "receiverName", "receiverPhone", station, "productType", quantity, vehicle, insurance, "totalAmount", "paymentStatus", status, "deliveryStatus", employee, "createdBy", "sendDate", "deliveredAt", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Stations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Stations" (id, code, name, address, phone, "isActive") FROM stdin;
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (id, user_id, type, provider, provider_account_id, refresh_token, access_token, expires_at, token_type, scope, id_token, session_state) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, booking_code, user_id, customer_name, customer_phone, customer_email, route_id, schedule_id, date, departure_time, seats, total_price, status, qr_code, ticket_url, checked_in, checked_in_at, checked_in_by, notes, created_at, updated_at) FROM stdin;
142bc7e7-f5c7-4460-9ea8-a204e9c8f51d	VCP202601122479	\N	Quản trị viên	02519999975	lequangminh951@gmail.com	1	\N	2026-01-12	12:00	1	120000	PENDING	\N	\N	f	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-14 13:09:20.424275
1cf16c19-bbdd-4d2c-9074-816dc5021082	VCP202512148366	\N	Minh	0908724146	lequangminh951@gmail.com	3	\N	2025-12-14	13:00	1	120000	PENDING	\N	\N	f	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-14 13:09:20.424275
7f848954-c97f-449d-9b0d-598869a9736b	VCP202601126571	\N	Quản trị viên	02519999975	admin@vocucphuong.com	1	\N	2026-01-12	04:30	1	120000	PAID	\N	\N	t	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-14 13:09:20.424275
a29554b5-4794-4199-b62a-92c2807af784	VCP202511306203	\N	minh	0908724146	lequangminh951@gmail.com	1	\N	2025-11-30	18:00	1	120000	PAID	\N	\N	f	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-14 13:09:20.424275
d7d8c08f-fd1e-4159-8fee-ccb528b5170a	VCP202601121279	\N	Quản trị viên	02519999975	lequangminh951@gmail.com	1	\N	2026-01-12	15:00	1	120000	PAID	\N	\N	f	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-14 13:09:20.424275
5624e641-2b35-465d-867d-17edd56e9e24	VCP202601142133	6bad496e-4bea-46ec-b7ea-d7c5c27ebbab	Lê Quang Minh	0908724146	mincubu020504@gmail.com	1	\N	2026-01-15	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-14 13:41:27.499	2026-01-14 13:41:27.499
f38e097b-1df5-49b1-96d4-2c32cc520c45	VCP202601141132	6bad496e-4bea-46ec-b7ea-d7c5c27ebbab	Lê Quang Minh	0908724146	mincubu020504@gmail.com	1	\N	2026-01-15	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-14 15:20:59.74	2026-01-14 15:20:59.74
e2011bd5-f416-41cb-9035-3f767ab84f7f	VCP202601157134	6bad496e-4bea-46ec-b7ea-d7c5c27ebbab	Lê Quang Minh	0908724146	mincubu020504@gmail.com	1	\N	2026-01-15	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 00:11:05.955	2026-01-15 00:11:05.955
fe35187a-3dbc-430e-9592-1b1655d923de	VCP202601151523	\N	Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-01-15	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 00:12:03.76	2026-01-15 00:12:03.76
e89506cb-efbe-41f7-9c1a-f4e4fba2408b	VCP202601150981	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	2	\N	2026-01-15	09:00	1	110000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 00:19:51.579	2026-01-15 00:19:51.579
0f8dcba1-d06a-4599-888f-4bdf26f0ab76	VCP202601156906	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-01-15	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 01:12:56.054	2026-01-15 01:12:56.054
fa1285bc-a44b-4ebd-9087-94aab1849f13	VCP202601156442	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	1	\N	2026-01-15	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 07:47:06.266	2026-01-15 07:47:06.266
5d28e769-db9b-4ff8-9e3c-67b2b4c9c69e	VCP202601152377	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	lequangminh951@gmail.com	1	\N	2026-01-15	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-15 07:47:17.504	2026-01-15 07:47:17.504
97eab092-b67d-409d-ad9f-d77f97de10a5	VCP202601161032	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	1	\N	2026-01-16	10:30	1	120000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAApmSURBVO3BgW0cSRAEwaoG/Xc5Xw7M4jHSHtlSRpRfIkkLTCRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISX/kNbfO3APKkbd4A5KRtToA8aZsTIG9omxtA/iZtcwPIk7b5WwC5MZGkJSaStMREkpaYSNISE0laYiJJS3zlJUB+mra5BeRG29wCctI2T4C8oW1uADlpmydAbrTNG4D8NEB+mrb50yaStMREkpaYSNISE0laYiJJS0wkaYmJJC3xlW/SNm8A8mltcwLkSdvcAPKkbU6AnLTNG9rmVtucAHkDkJO22aRt3gDk0yaStMREkpaYSNISE0laYiJJS0wkaYmv6H9pm08DctI2T4CctM0JkDe0zQmQJ21zA8iTtrkB5EnbnADRvYkkLTGRpCUmkrTERJKWmEjSEhNJWuIr+l+AnLTNSdt8h7Y5AfKGtnkDkBtto7/LRJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJb7yTYD8C4DcaptbQE7a5g1APq1tToDcapsTILfa5gTIG4D8LSaStMREkpaYSNISE0laYiJJS0wkaYmvvKRt/iZtcwLkpG2eALkB5EnbnAA5aZsnQE7a5gTISds8AfKGtjkBctI2T4CctM0b2uZfMJGkJSaStMREkpaYSNISE0laYiJJS3zlNwD5VwA5aZtbbXOjbZ4A+RcAOWmbW23z0wD5100kaYmJJC0xkaQlJpK0xESSlphI0hITSVqi/JJv0DYnQE7a5g1AnrTNCZCTtnkC5KRt3gDkpG1uAXlD25wAudU2J0BO2uY7AHlD25wAudU2J0BuTCRpiYkkLTGRpCUmkrTERJKWmEjSEl/5DW3zhra5BeRfAORJ29wA8qRtbrTNCZBbbXMC5AmQnwTIrbY5AfK3mEjSEhNJWmIiSUtMJGmJiSQtMZGkJcov+QZtcwLkVtvcAHKrbU6APGmbEyC32ubTgChpmxtAnrTNG4CctM0bgNyYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xFe+CZAbbXMLyE8D5KRtbgG50TZPgJy0zQ0gt9rm04A8AXLSNidt8wTISducAHnSNjeAPGmbP20iSUtMJGmJiSQtMZGkJSaStMREkpb4ym9omxMgT9rmBMgtICdtcwLkO7TNTwLkDUButc0JkJO2eQLkpG1utc0JkFttc6NtngA5aZuTtnkC5E+bSNISE0laYiJJS0wkaYmJJC0xkaQlvvIbgNwCctI2J0CetM0JkJO2eQLkBMhJ2zwBcqNtnrTNG4CcAPm0tlEC5FbbvKFtToDcmEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStET5JZfa5g1ATtrmDUCetM0NIE/a5gTIG9rmDUButM0TIG9omxMgJ23zBMhJ25wAedI2N4Dcaps3ALkxkaQlJpK0xESSlphI0hITSVpiIklLlF9yqW1OgDxpmxtAnrTNCZBPa5snQN7QNjeAPGmbnwTISdu8AciTtjkBcqttToCctM0TIFtMJGmJiSQtMZGkJSaStMREkpaYSNISX1mmbW61zS0gJ23zhrY5AXILyBuA3GibNwB50jY32uYJkBttc6ttToA8aZsTILfa5gTIjYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUuUX3KpbT4NyBvaRr8HyEnbnAB50jYnQN7QNreAvKFtToC8oW3eAOTGRJKWmEjSEhNJWmIiSUtMJGmJiSQt8ZXfAOQNbXPSNk+AnLTNCZA3tM0TICdtcwvISdt8GpA3tM0JkCdtcwLkpG1utc0b2uYEyN9iIklLTCRpiYkkLTGRpCUmkrTERJKWKL/kUtucAPkObXMC5KRtngA5aZs3ADlpmzcAudU2nwbkpG1uAfm0trkF5KRtngC50TZPgPxpE0laYiJJS0wkaYmJJC0xkaQlJpK0xFd+A5BPa5snQE7a5gTIk7b5WwA5aZsnQD4NyEnbnAD5Dm3zaW1zAuRvMZGkJSaStMREkpaYSNISE0laYiJJS0wkaYnyS17QNreA3GqbEyAnbfMEyI22eQLkRtvcAnKrbX4SICdt8wTIT9I2T4D86yaStMREkpaYSNISE0laYiJJS0wkaYmv/Ia2+WmAnLTNG9rm04B8ByCf1jYnbXOrbW4A2aRtngB5Q9ucALkxkaQlJpK0xESSlphI0hITSVpiIklLfOU3ADlpm+/QNidATtrmFpBbbfMGID9J22wC5A1tc6ttToCcAHlD23zaRJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJb7yG9rmBMiTtjlpmze0zQmQJ21zA8gtICdt89O0zQmQW21zAuRW27yhbU6AnLTNEyA32uYJkBtAPm0iSUtMJGmJiSQtMZGkJSaStMREkpb4ym8ActI2t4CctM0TIDfa5haQk7bZpG1uATlpmze0jX5P25wAOWmbW0BuTCRpiYkkLTGRpCUmkrTERJKWmEjSEuWXXGqbEyBP2uYGkFttcwvIjbZ5AuSkbU6APGmbNwDZom3eAORf0TYnQJ60zQmQGxNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpYov+QFbfMEyEnb3ALyaW1zC8gb2uYGkCdt86cBedI2J0Butc2nATlpm1tATtrmFpCTtnkC5E+bSNISE0laYiJJS0wkaYmJJC0xkaQlyi+51DYnQJ60zQmQN7TNpwG51TZ/CyCf1jZvAHKrbX4aICdtcwLkSducALkxkaQlJpK0xESSlphI0hITSVpiIklLfOU3ALkF5NOA3GqbG23zBiC32uYEyJO2udE2t4D8C4C8oW1uATlpm0+bSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xFd+Q9v8LYA8AXLSNidAnrTNCZBbbXMC5BaQk7Y5AXKrbW4AedI2J0BO2uYJkDe0zQmQN7TNTzKRpCUmkrTERJKWmEjSEhNJWmIiSUt85SVAfpq2udU2J0BO2uYJkBttc6ttbgG50TYnQJ4A+bS2OQHyHYB8GpBbbfOnTSRpiYkkLTGRpCUmkrTERJKWmEjSEl/5Jm3zBiCf1jYnQJ60zQmQEyBK2uYEyBMgJ21z0jZPgNxom+/QNidAfpKJJC0xkaQlJpK0xESSlphI0hITSVpiIklLfEX/C5CTtrkF5A1tcwPIT9M2J0BO2uYJkBMgJ23zHYCctM0b2uYEyBMgf9pEkpaYSNISE0laYiJJS0wkaYmJJC3xFf0vbXMC5KRtbgH5adpmCyC32ubTgNwCctI2T4CctM2ttjkBcmMiSUtMJGmJiSQtMZGkJSaStMREkpb4yjcBsgmQk7Y5AXKrbU6A3AJyC8if1ja32uYWkBMgfwsgt4CctM0TIH/aRJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJb7ykrb5VwC51TZ6BuQnaZsnQN7QNm8A8oa2OQFyYyJJS0wkaYmJJC0xkaQlJpK0xESSlii/RJIWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISE0laYiJJS0wkaYmJJC3xH0wF13quKrfHAAAAAElFTkSuQmCC	\N	f	\N	\N	\N	2026-01-16 02:55:58.84	2026-01-16 02:55:58.84
c487f0e1-e671-48ca-9f3b-1b7bcaaf8e9a	VCP202601168372	192af0e0-f17c-4d1e-9a9e-b2bc89fa8c34	Nguyễn Từ Quỳnh Hương	0896412657	myngoc0626@gmail.com	1	\N	2026-01-16	10:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-16 04:07:36.432	2026-01-16 04:07:36.432
e58900fe-5648-400e-8f45-d9a863ad4b2b	VCP202601168432	\N	Bùi Mỹ Ngọc	0708095252	\N	3	\N	2026-01-16	14:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-16 07:01:55.014	2026-01-16 07:01:55.014
ae173274-4959-4532-8b39-2cf1be2808c6	VCP202601161937	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-16	15:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-16 08:27:38.617	2026-01-16 08:27:38.617
f1dc1d7e-030a-4f42-8446-eee00f298bf1	VCP202601175123	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-18	05:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-17 13:38:43.75	2026-01-17 13:38:43.75
59e70e61-5630-4363-bef7-c47a40ed94aa	VCP202601170416	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-18	06:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-17 14:02:18.896	2026-01-17 14:02:18.896
4f639785-7442-4161-9fda-a3cf396faaae	VCP202601175617	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-17	09:00	1	120000	PAID	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAApySURBVO3BgW0dSxIEwarG89/lPDkwi8OIS7L1M6L8EUlaYCJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+OQvtM2/Asgb2uYJkJO2OQFyq21uATlpm98EyBva5gmQN7TNvwLIjYkkLTGRpCUmkrTERJKWmEjSEhNJWuKTlwD5bdrmDW3zBiC32uYGkCdt89WAPGmbEyAnbXMLyBva5gTILSC/Tdt8tYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUt88kPa5g1AfhMgT9rmBMhJ2zwBcqNtbgHZBMhJ25wAedI2v0nbvAHId5tI0hITSVpiIklLTCRpiYkkLTGRpCU+0a/VNidAbrXNCZAnbXPSNidAlADRvYkkLTGRpCUmkrTERJKWmEjSEhNJWuIT/V/a5g1ATtrmVtucADlpm1tATtrmBMgTICdtcwLkFpA3tM0JED2bSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xCc/BMgmQG60zRva5g1A3gDkDUBO2uYJkJO2OQHyBMhvAuRfMZGkJSaStMREkpaYSNISE0laYiJJS3zykrb5l7TNCZBbQE7a5gTIk7a50TZPgJy0zQmQk7Z5AuSkbU6APGmbEyAnbfMEyEnbnAC51Tb/BRNJWmIiSUtMJGmJiSQtMZGkJSaStMQnfwGI/k7b3GibJ0BO2ua7tc0JkFtATtrmDUCetM0bgPzXTSRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWuKTH9I2N4DcapvfBsh3A3Krbb5a27wByK22OQHyhra5BeSkbZ4A2WIiSUtMJGmJiSQtMZGkJSaStMREkpb45BcCctI2t4CctM1PaJsTICdtcwvISds8AXLSNidAbrXNG9rmRttsAuRJ27wByFebSNISE0laYiJJS0wkaYmJJC0xkaQlPvkLbXMC5Fbb3AJy0jYnQG61zS0gJ21zAuRJ29wA8tsAOWmbk7Z5AuQNbXMC5KRtngA5aZs3APlNJpK0xESSlphI0hITSVpiIklLTCRpiYkkLVH+yA9omxtANmmbnwDkRtt8NyBP2uYEyEnbPAFy0jYnQJ60zQmQN7TNCZA3tM0tIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJT/5C25wAeQLkpG3e0DYnQJ60zQmQ36Zt3gDkpG1OgJy0zRMgJ21zAuQNbfMEyEnbnAB50jZvaJs3APlqE0laYiJJS0wkaYmJJC0xkaQlJpK0xCd/AchJ29wCcqttToD8NkB+k7a5BeSkbb5b2zwBcgLkpG1uAflubfMEyEnb3GqbEyA3JpK0xESSlphI0hITSVpiIklLTCRpiYkkLVH+yH9E29wC8oa2+a8D8tu0zQmQW21zAuQNbfMEyEnb3ALy1SaStMREkpaYSNISE0laYiJJS0wkaYlPXtI2PwHICZCTtrnVNidANgHypG1OgNxom1tA3gDkVtucADlpmydATtrmDUBO2uZJ25wAuTGRpCUmkrTERJKWmEjSEhNJWmIiSUt88hIgT9rmBpAnbfOGtvlNgDxpmxMgJ23zBMhv0ja3gJy0zS0gJ21zAuQNQJ60zRuAfLWJJC0xkaQlJpK0xESSlphI0hITSVpiIklLfPIX2uYNQE7a5gmQN7TNCZCTtnkC5EbbvAHIrbY5AXILyEnb/DZtc6NtbgF5A5BbbXMC5MZEkpaYSNISE0laYiJJS0wkaYmJJC3xyV8AcqttbgC51TZvaJsTIE/a5gTIb9M2J0BO2uYEyC0gt9rmBMittjkBctI2t9rmu7XNd5tI0hITSVpiIklLTCRpiYkkLTGRpCU++Qtt84a2OQHypG1OgJy0zRMgN9rmCZCTtjkB8hOAnLTNCZCTtnkC5Ebb3GqbfwWQJ23zBiBfbSJJS0wkaYmJJC0xkaQlJpK0xESSlvjkFwJy0jZPgJy0zRva5lbb/CZt8wTICZAbQG61zQmQJ23z3drmFpAbbfMEyBva5gTIjYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUuUP/ID2uYEyL+ibX4bIL9J2zwB8oa2uQHkJ7TNDSBvaJsnQL7aRJKWmEjSEhNJWmIiSUtMJGmJiSQt8clfaJvv1jY/AchJ25wAedI2N4A8aZsbbfMGICdAfgKQk7Z5Q9ucALkF5KRtngA5aZsTIE/a5gTIjYkkLTGRpCUmkrTERJKWmEjSEhNJWuKTX6htbgG50TZvaJsnQE7a5haQk7Z5A5CTtrkF5KRtToA8aZsTILfa5gTIdwPypG22mEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMQnfwHISds8AXLSNidAnrTNDSC3gJy0zZO2OQHy2wA5aZsTICdt86RtToB8t7Z5AuSkbW4B2QTIV5tI0hITSVpiIklLTCRpiYkkLTGRpCU+eQmQN7TNEyDfrW1+m7Y5AXKrbU6A3AByq23e0DZvAHLSNrfa5gTILSAnbXMLyI2JJC0xkaQlJpK0xESSlphI0hITSVqi/JEXtM0bgNxqmxMgT9rmBMhJ2zwBcqNtngA5aZsTILfa5g1AbrTNEyA32uYJkDe0zRuAnLTNCZDvNpGkJSaStMREkpaYSNISE0laYiJJS0wkaYnyRy61zQmQJ23z3YCctM0TICdtswmQk7Z5AuS7tc0JkJO2eQLkRtvcAvKGtnkDkFttcwLkxkSSlphI0hITSVpiIklLTCRpiYkkLVH+yCJt818B5KRt3gBkk7Y5AXKrbU6A3Gqb3wbIjbZ5AuSrTSRpiYkkLTGRpCUmkrTERJKWmEjSEp8sA+QntM0NILfa5gTIG9rmv6Jt3tA2N4C8oW2etM0NIE/a5gTIjYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUt88hfa5l8B5Ce0zQmQN7TNLSAnbXMC5KRtngD5bkB+m7Y5AfIGICdt890mkrTERJKWmEjSEhNJWmIiSUtMJGmJT14C5Ldpm1tATtrmpG2eAPluQE7a5knbfLe2OQHy3drmJwD5TYA8aZuvNpGkJSaStMREkpaYSNISE0laYiJJS3zyQ9rmDUA2aZsTICdtcwvICZAnbXMC5AaQW21zAuQNQG61zUnb/EuAfLWJJC0xkaQlJpK0xESSlphI0hITSVpiIklLfKL/S9vcAHKrbd7QNidA3tA2bwDyhra5BeQGkCdtcwLkpG1utc0bgNyYSNISE0laYiJJS0wkaYmJJC0xkaQlPtFfA3KrbU6A3GqbG23zBMgNILfa5qRtNgFy0jY/AciNtnkC5KtNJGmJiSQtMZGkJSaStMREkpaYSNISn/wQIJsAudE2T4Bs0jYnQG60zRMgm7TNCZBbQG4AedI2N4B8t4kkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUt88pK2+a9om1ttcwPIEyAnbXMLyI22OQHypG1uANkEyJO2uQHkDW1zC8iNiSQtMZGkJSaStMREkpaYSNISE0laovwRSVpgIklLTCRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMT/AA9T1o0N+9+6AAAAAElFTkSuQmCC	\N	f	\N	\N	\N	2026-01-17 01:52:12.158	2026-01-18 03:03:19.84
fdb3e17a-a4cc-4473-bebb-78e7dc0fb7f6	VCP202601161344	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-16	16:00	1	120000	PAID	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-16 08:27:13.336	2026-01-18 03:03:23.509
119c6073-c8ad-4845-b99f-9c40206cf2c8	VCP202512146942	\N	Nguyễn Văn A	0987654321	user@example.com	3	\N	2025-12-14	11:00	1	120000	PAID	\N	\N	f	\N	\N	\N	2026-01-14 13:09:20.424275	2026-01-18 03:03:34.842
53a6f6a9-a0af-4917-ba6e-cc2a21215323	VCP202601146179	6bad496e-4bea-46ec-b7ea-d7c5c27ebbab	Lê Quang Minh	0908724146	mincubu020504@gmail.com	1	\N	2026-01-15	18:00	1	120000	PAID	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-14 13:41:49.953	2026-01-18 03:03:37.345
47d17ea8-a6e1-48bb-8abf-dfa7c5d3963b	VCP202601170912	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	3	\N	2026-01-18	05:30	1	120000	PAID	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-17 13:34:47.614	2026-01-18 03:03:46.975
7efdd906-d5ad-43c1-9a1e-0f4b75d36d1c	VCP202601188905	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-20	15:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-18 03:37:34.876	2026-01-18 03:37:34.876
7f0bf8f0-d782-4cd5-890f-2ede1d8bbf7b	VCP202601183337	192af0e0-f17c-4d1e-9a9e-b2bc89fa8c34	Nguyễn Từ Quỳnh Hương	0896412657	myngoc0626@gmail.com	3	\N	2026-01-18	11:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-18 23:28:32.157	2026-01-18 23:28:32.157
c52957bf-0555-40b0-a586-bce087896f5d	VCP202601180585	192af0e0-f17c-4d1e-9a9e-b2bc89fa8c34	Nguyễn Từ Quỳnh Hương	0896412657	lequangminh951@gmail.com	3	\N	2026-01-18	05:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-18 23:30:44.252	2026-01-18 23:30:44.252
196276e5-1073-4f74-acff-eb20e7608a15	VCP202601203653	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-20	11:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-20 14:04:37.056	2026-01-20 14:04:37.056
2c61bdfd-7ed2-4dbb-834c-c55074436131	VCP202601202889	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	8	\N	2026-01-21	03:30	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-20 14:18:56.16	2026-01-20 14:18:56.16
d60bcffa-4912-4771-9a99-9fb2a67fb168	VCP202601207188	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-20	11:00	8	960000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-20 14:49:55.941	2026-01-20 14:49:55.941
916e4912-7feb-485b-a93e-9e24ed3dec72	VCP202601225094	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-22	11:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-22 00:58:28.163	2026-01-22 00:58:28.163
777e07a0-2155-4850-b228-252156fcfa62	VCP202601267988	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-01-26	08:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-26 01:20:40.626	2026-01-26 01:20:40.626
272b9c7b-f12f-4e8d-a482-4281711c6f13	VCP202601260601	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	8	\N	2026-01-26	13:30	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-26 06:12:12.352	2026-01-26 06:12:12.352
3d06d579-1f53-4f98-a324-2473c689d6c9	VCP202601204427	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-01-21	11:00	8	960000	PAID	data:image/png;base64,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	\N	f	\N	\N	\N	2026-01-20 14:50:19.878	2026-01-28 05:33:49.747
56c1ba28-8885-47a0-a404-e4f6553b3bda	VCP202602210447	\N	Đại	0932091758	vandai.nguyen877@gmail.com	4	\N	2026-02-21	12:00	1	110000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAAonSURBVO3BgW0dSxIEwaoG/Xc5Tw7M4jDiPrL1M6L8EUlaYCJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+MpfaJt/BZA3tM0TICdtcwvISdvcAnLSNjeAPGmbG0De0DZPgLyhbf4VQG5MJGmJiSQtMZGkJSaStMREkpaYSNISX3kJkN+mbd7QNp8G5Enb3ADypG2+W9vcAnLSNreAvKFtToDcAvLbtM13m0jSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMRXfkjbvAHIbwLkSducADlpm1tATtrmFpAbbfMTgJy0zQmQJ23zm7TNG4B82kSSlphI0hITSVpiIklLTCRpiYkkLfEVrQTkVtucAHnSNidtcwLkBMitttkEiO5NJGmJiSQtMZGkJSaStMREkpaYSNISX9H/pW0+rW3eAOSkbW4BOWmbNwB5A5A3tM0JED2bSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xFd+CJBNgNxom1tAbrXNDSBvAPJpbfMEyEnbnAB5AuQ3AfKvmEjSEhNJWmIiSUtMJGmJiSQtMZGkJb7ykrb5l7TNCZBbQE7a5gTIG9rmCZCTtjkBctI2T4CctM0JkCdtcwLkpG2eADlpmxMgt9rmv2AiSUtMJGmJiSQtMZGkJSaStMREkpb4yl8Aop/RNk+AnLTNp7XNCZBbQE7a5g1AnrTNG4D8100kaYmJJC0xkaQlJpK0xESSlphI0hITSVriKz+kbW4AudU2mwA5aZtbQG61zXdrmzcAudU2J0De0Da3gJy0zRMgW0wkaYmJJC0xkaQlJpK0xESSlphI0hJfeUnb/IS2OQFy0jY/oW1OgNxqmxMgnwbkVtvcaJs3tM0mQN7QNk+AfLeJJC0xkaQlJpK0xESSlphI0hITSVqi/JFLbXMC5Enb/CZAfpu2OQHypG1uANmkbU6A/IS2OQFy0jZPgJy0zS0gJ21zAuTTJpK0xESSlphI0hITSVpiIklLTCRpiYkkLfGVvwDkFpCTtnkDkDe0zae1zRMgJ21zq21OgJy0zQmQJ21zAuRW29wA8gYgbwDypG1OgJy0zS0gNyaStMREkpaYSNISE0laYiJJS0wkaYnyRy61zQmQJ21zA8iTtrkB5EnbnAA5aZtNgHxa2zwBctI2vw2Qk7Y5AfKkbW4AudU2t4B8t4kkLTGRpCUmkrTERJKWmEjSEhNJWuIrfwHISds8AXKjbW4BeUPb3AKySducADlpm08D8oa2uQXk09rmCZA3tM0JkBsTSVpiIklLTCRpiYkkLTGRpCUmkrTERJKWKH/kP6JtbgE5aZtNgNxqm+8G5A1t8wTISducALnVNidA3tA2T4CctM0tIN9tIklLTCRpiYkkLTGRpCUmkrTERJKWKH/kBW3zE4DcaJsnQN7QNp8G5KRtngD5bm1zC8hv0zYnQE7a5gmQk7a5BeRG29wCcmMiSUtMJGmJiSQtMZGkJSaStMREkpYof+SXaZt/BZAnbXMC5FbbvAHISducALnVNjeA3GqbW0BO2uYEyK22OQHypG3eAOS7TSRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWqL8kUtt8wYgJ21zC8ittjkB8oa2eQOQ36RtngA5aZtbQE7aZhMgt9rmBMittjkBcmMiSUtMJGmJiSQtMZGkJSaStMREkpb4yl8AcqttbgC51TZvaJsTIG8A8qRt3tA2J0B+EyBP2uYEyK22OQFy0ja32ubT2ubTJpK0xESSlphI0hITSVpiIklLTCRpia+8pG1utc0JkCdtcwLk09rmJwB5A5CTtrkB5Enb3GibW23zrwDypG3eAOS7TSRpiYkkLTGRpCUmkrTERJKWmEjSEuWPXGqbNwA5aZsnQE7a5gTIk7Z5A5CTtrkF5EbbPAFyo20+DciTttkEyI22eQLkRtvcAnJjIklLTCRpiYkkLTGRpCUmkrTERJKWmEjSEuWP/IC2OQHyr2ibJ0De0DYnQD6tbW4BeUPb3ADyE9rmBpB/xUSSlphI0hITSVpiIklLTCRpiYkkLfGVZdpmEyC32ubT2ua3aZsbQJ4AOWmbN7TNCZBbQE7a5gmQk7a5BeS7TSRpiYkkLTGRpCUmkrTERJKWmEjSEl/5C23zhra5BeRG27yhbZ4A+bS2eQOQG23zE9rmBMittjkB8mlAnrTNFhNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpb4ykuA3GqbEyBP2uYNQG60zZO2OQHyhra5BeSkbU6AvAHIp7XNEyAnbXMLyH/dRJKWmEjSEhNJWmIiSUtMJGmJiSQt8ZW/AOSkbZ4AeQMQJW1zAuRW25wAuQHkDW1zq23eAOSkbW61zQmQn9A2J0BuTCRpiYkkLTGRpCUmkrTERJKWmEjSEuWPvKBtbgE5aZsnQE7a5gTIk7Y5AfJpbfMEyG/SNreA3GibJ0ButM0TIG9omzcAOWmbEyCfNpGkJSaStMREkpaYSNISE0laYiJJS0wkaYnyRy61zQmQJ21zA8gb2uYJkBtt818B5A1tcwLkpG2eALnRNreAvKFt3gDkVtucALkxkaQlJpK0xESSlphI0hITSVpiIklLlD+ySNv8NkButc0JkJO22QTIG9rmBMittjkBcqttfhsgN9rmCZDvNpGkJSaStMREkpaYSNISE0laYiJJS3xlGSA/oW1O2uYWkJO2OQFyq21uAbnRNv8VbXMDyBva5knb3ADypG1OgNyYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xFf+Qtv8K4D8hLY5AfIGIJ8G5KRtngC50Ta3gPw2bXMC5A1ATtrm0yaStMREkpaYSNISE0laYiJJS0wkaYmvvATIb9M2t4DcaJsnQH6TtnkC5NPa5gTICZAnbXOjbX4CkN8EyJO2+W4TSVpiIklLTCRpiYkkLTGRpCUmkrTEV35I27wByG8C5EnbnAA5aZtbQE6APGmbG0BuATlpmxMgbwByq21O2uZfAuS7TSRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWuIr+r+0zQ0gT4CctM0JkCdtc9I2J0B+m7Y5AfKGtrkF5AaQJ21zAuSkbW61zRuA3JhI0hITSVpiIklLTCRpiYkkLTGRpCW+or8G5FbbnAD5tLZ5AuQ3aZtNgJy0zU8AcqNtngD5bhNJWmIiSUtMJGmJiSQtMZGkJSaStMRXfgiQTYDcaJtbbXMLyEnb3GqbEyAnbXMLyEnbnAD5CW1zAuQWkBtAnrTNDSCfNpGkJSaStMREkpaYSNISE0laYiJJS0wkaYmvvKRt/iva5haQk7Y5AfKkbd4A5AaQk7ZRAuRJ29wA8oa2uQXkxkSSlphI0hITSVpiIklLTCRpiYkkLVH+iCQtMJGkJSaStMREkpaYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVrifxE3t2qDwuRfAAAAAElFTkSuQmCC	\N	f	\N	\N	\N	2026-02-21 04:55:00.406	2026-02-21 04:55:00.406
40281af6-56d7-4cfc-9659-d3330ff1498f	VCP202603081856	\N	Nguyễn Anh Tuấn	0379898926	\N	1	\N	2026-03-09	03:30	1	120000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAAp1SURBVO3BgXEcy5IEwcyy1V/lOCrQc9+aHACFF+7lj0jSAhNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xCd/oW1+CyDfoW1OgJy0zRMgJ21zC8iNtrkF5KRtToC8oW2eAHlD2/wWQG5MJGmJiSQtMZGkJSaStMREkpaYSNISn7wEyE/TNm9om98CyJO2uQHkq7XNLSBvaJsTILeA/DRt869NJGmJiSQtMZGkJSaStMREkpaYSNISE0la4pNv0jZvAPKTAHnSNidt8wYgJ21zC8gb2uYNQE7a5gTIk7b5SdrmDUC+2kSSlphI0hITSVpiIklLTCRpiYkkLfGJvhWQk7Y5AXKrbU6APGmbk7b5akBO2uanAaJ7E0laYiJJS0wkaYmJJC0xkaQlJpK0xCf6n7TNG9rmDW1zAuSkbW4B+UmA3ALyhrY5AaJnE0laYiJJS0wkaYmJJC0xkaQlJpK0xESSlvjkmwDZBMiNtvkOQG4A+Wpt8wTISdvcAnLSNidAngD5SYD8FhNJWmIiSUtMJGmJiSQtMZGkJSaStMQnL2mb36RtToDcAnLSNrfa5gTISds8AXLSNidAvhqQJ21zAuSkbZ4AOWmbEyC32ua/YCJJS0wkaYmJJC0xkaQlJpK0xESSlvjkLwDRzwTkpG1+CyAnbfMGIE/a5g1A/usmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8ck3aZsbQG61zSZAbrXNCZCTtnnSNl+tbU6AnAC51TYnQN7QNreAnLTNEyBbTCRpiYkkLTGRpCUmkrTERJKWmEjSEp+8pG2eADlpm5O2uQXkpG1utc2ttjkBctI2vwWQJ21zo23e0DabALnVNreA/GsTSVpiIklLTCRpiYkkLTGRpCUmkrTEJ3+hbU6APGmbG0CetM1J25wAeUPbPAFy0jYnQJ60zRuAnLTNG4CctM0JkCdtcwLkVtucADlpmydATtrmDUB+kokkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUuUP/IN2uYGkJ+mbU6APGmbNwA5aZsTIG9omxMgT9rmBMgb2uYEyJO2OQHyhrY5AfKkbb4akBsTSVpiIklLTCRpiYkkLTGRpCUmkrTEJ3+hbU6AvKFtngA5aZsTIE/a5kbbfIe2OQHyhrY5AXLSNk+AnLTNLSA32uYJkJO2OQHypG02AfKvTSRpiYkkLTGRpCUmkrTERJKWmEjSEp/8BSAnbfPTAHkDECVATtrmqwG5BeSkbW4B+Wpt8wTISdvcapsTIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8clLgDxpm6/WNreAnLTNJkButc0JkBtAbgG51TY3gNxqmxMgT4DcaJvvAORfm0jSEhNJWmIiSUtMJGmJiSQtMZGkJcofeUHbPAFyo22eALnRNk+A3Gib/wogN9rmFpCTtrkF5FbbnAA5aZsnQE7a5haQG21zC8iNiSQtMZGkJSaStMREkpaYSNISE0laovyRH6ZtToA8aZs3AHlD25wAudU2J0BO2uYJkJO2OQFyq21uALnVNreAnLTNCZBbbXMC5EnbvAHIvzaRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJT17SNreAnLTNEyA/Sdu8oW3eAOSnAXLSNidt8wTIG9rmRtvcAvIGILfa5gTIjYkkLTGRpCUmkrTERJKWmEjSEhNJWuKTv9A2Xw3Irbb5akButc0JkCdt84a2OQFy0jYnQJ60zQ0gT9rmBMittjkBctI2t9rmq7XNV5tI0hITSVpiIklLTCRpiYkkLTGRpCU++QtAbrXNSducAHnSNidAvlrbPAFyo22+A5CTtjkBctI2t4CctM2ttvktgDxpmzcA+dcmkrTERJKWmEjSEhNJWmIiSUtMJGmJ8kde0Da3gJy0zRMgJ21zC8hJ27wByK22OQFy0jZPgPxrbfMEyBvaZhMgN9rmCZAbbXMLyI2JJC0xkaQlJpK0xESSlphI0hITSVpiIklLfPIX2uarAbkF5KRtnrTNCZCTtnkC5CcBomdAvkPb3ADyW0wkaYmJJC0xkaQlJpK0xESSlphI0hKfLNM2bwDypG1O2uYEyHcAcqNtNmmbEyBPgJy0zRva5gTILSAnbfMEyEnb3ALyr00kaYmJJC0xkaQlJpK0xESSlphI0hKfvATIk7Y5aZtbQG60zRMgJ21z0ja3gJy0zRMgJ23zBiAnbXMC5EnbnAC51TYnQG61zQmQrwbkSdtsMZGkJSaStMREkpaYSNISE0laYiJJS0wkaYlP/gKQk7Z5AuSkbU6APGmbrwbkpG2eALkB5DsAOWmbG23zBMhJ25wAeUPbPAFy0ja3gGzSNidAbkwkaYmJJC0xkaQlJpK0xESSlphI0hLlj7ygbZ4A+S9om1tAbrXNDSC/Rdt8ByA32uYJkJO2OQHyhra5BeTGRJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckP1DYnQJ60zQ0gT9rmBMgtIDfa5gmQr9Y2bwDyBiA32uYNQJ60zY22eQLkpG1OgHy1iSQtMZGkJSaStMREkpaYSNISE0laYiJJS5Q/cqltToA8aZs3ALnRNk+A3GibnwbISds8AfLV2uYEyEnbPAFyo21uAXlD27wByK22OQFyYyJJS0wkaYmJJC0xkaQlJpK0xESSlih/5Bu0zQmQk7b5aYCctM0tICdtcwvIb9E2J0Butc0JkFtt89MAudE2T4D8axNJWmIiSUtMJGmJiSQtMZGkJSaStET5I/p/tc0NILfa5gTIrba5BeRG23w1IE/a5gaQJ21zA8gb2uYNQJ60zQmQGxNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpb45C+0zW8B5BaQk7a5BeSrAXnSNidAToCctM0TIDfa5haQn6ZtToC8AchJ23y1iSQtMZGkJSaStMREkpaYSNISE0la4pOXAPlp2uYWkBtAfhogJ23zBMhJ25wAudU2J0BOgDxpmxtt8x2A/CRAnrTNvzaRpCUmkrTERJKWmEjSEhNJWmIiSUt88k3a5g1AfpK2+WmAnAC5BeQGkFttcwLkDUButc1J2/wmQP61iSQtMZGkJSaStMREkpaYSNISE0laYiJJS3yi/0nb3ADypG1OgNxqm5O2OQHypG1uADlpmydAToC8oW1uAbkB5EnbnAA5aZtbbfMGIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJT/TXgNwCctI2t4CctM1J2zwBcqNtvlrb/DRATtrmOwC50TZPgPxrE0laYiJJS0wkaYmJJC0xkaQlJpK0xCffBMgmQG60zRMgJ0BO2uZJ27yhbU6A3ADypG1OgJwA+Q5tcwLkFpAbQJ60zQ0gX20iSUtMJGmJiSQtMZGkJSaStMREkpaYSNISn7ykbf4r2uZW29wAcqttbgH519rmVtucANkEyJO2uQHkDW1zC8iNiSQtMZGkJSaStMREkpaYSNISE0laovwRSVpgIklLTCRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJSaStMT/AWmU6mrfzY+GAAAAAElFTkSuQmCC	\N	f	\N	\N	\N	2026-03-08 16:55:33.951	2026-03-08 16:55:33.951
fc8f343b-ff6b-4be6-ace5-6d20509357e9	VCP202603226990	\N	minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-22	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-22 08:43:35.586	2026-03-22 08:43:35.586
006661bb-50cc-40be-9164-6f91ffb2cad5	VCP202603236768	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-03-24	06:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-23 14:29:24.64	2026-03-23 14:29:24.64
f83c054a-b3c6-4f3d-bd03-bc961e5ac6ca	VCP202603266788	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	13:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 05:59:53.768	2026-03-26 05:59:53.768
e34a4ca5-2ec5-4edc-99fc-5de1a55e7e33	VCP202603261055	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	2	\N	2026-03-26	13:30	1	110000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 06:00:38.031	2026-03-26 06:00:38.031
baf1f628-0c40-418b-a818-6ce89fc68128	VCP202603264140	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 10:12:10.576	2026-03-26 10:12:10.576
8fdbe4d9-71cf-4ede-9e33-ac2086bf0e0a	VCP202603263059	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	1	\N	2026-03-26	18:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:17:18.24	2026-03-26 13:17:18.24
b516fa12-03a4-4b5d-83a4-ae9b5724b09d	VCP202603267579	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-27	17:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:17:53.008	2026-03-26 13:17:53.008
91343bbf-0a55-46ed-96fc-43ede222585b	VCP202603264189	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-03-27	11:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:19:36.987	2026-03-26 13:19:36.987
0464db63-2ea4-4618-bd23-ccd20aa7c2e8	VCP202603268604	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	3	\N	2026-03-26	11:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:22:40.603	2026-03-26 13:22:40.603
235cd683-b079-483a-8b3a-e32ef61b12df	VCP202603263757	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:23:54.45	2026-03-26 13:23:54.45
bb586736-91f7-4dc1-96af-e9a0dcfa1af3	VCP202603260416	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:24:09.175	2026-03-26 13:24:09.175
b74300aa-2a9c-465a-a4b5-7b6bab153af3	VCP202603264970	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:29:09.133	2026-03-26 13:29:09.133
de1605af-7dc8-4892-87da-577cc06b3bc2	VCP202603265636	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	1	\N	2026-03-26	09:00	1	120000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAApeSURBVO3BgW0dSxIEwarG89/lvO/ALA4jLsmWMqL8J5K0wESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckfaJu/BZA3tM0tICdt8wTISdvcAnKjbb4bkDe0zRMgb2ibvwWQGxNJWmIiSUtMJGmJiSQtMZGkJSaStMQnLwHy27TNG9rmDW3z3YA8aZst2uYWkDe0zQmQW0B+m7b5ahNJWmIiSUtMJGmJiSQtMZGkJSaStMREkpb45Ie0zRuA/CZAfkLbnAA5aZtbQN7QNidATtrmCZCTtjkB8qRtfpO2eQOQ7zaRpCUmkrTERJKWmEjSEhNJWmIiSUt8on9O25wAedI2J21zAuSkbZ4A+VsA0b2JJC0xkaQlJpK0xESSlphI0hITSVriE/1f2ua7tc0JkFtATtrmFpDv1jYnQG4BeUPbnADRs4kkLTGRpCUmkrTERJKWmEjSEhNJWmIiSUt88kOAbALkRtv8BCA3gHw3IE/a5kbbPAFy0jYnQJ4A+U2A/C0mkrTERJKWmEjSEhNJWmIiSUtMJGmJT17SNn+TtjkBcgvISdvcapsTICdt8wTISducADlpmydATtrmBMiTtjkBctI2T4CctM0JkFtt8y+YSNISE0laYiJJS0wkaYmJJC0xkaQlPvkDQPQeILeAnLTNd2ubEyC3gJy0zRuAPGmbNwD5100kaYmJJC0xkaQlJpK0xESSlphI0hITSVrikx/SNjeA3GobJUBO2uZJ23y1tnkC5AaQW21zAuQNbXMLyEnbPAGyxUSSlphI0hITSVpiIklLTCRpiYkkLfHJDwFy0ja32uYEyEnb/IS2OQFy0jZPgJy0zQmQJ21zA8ittrkB5Enb3GibTYA8aZs3APlqE0laYiJJS0wkaYmJJC0xkaQlJpK0RPlPLrXNCZAnbfMGICdtcwLkVtucALnVNidAnrTNCZA3tM0JkDe0zQmQn9A2J0BO2uYJkJO2eQOQ32QiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISn/wBIG8A8gYgbwBy0jZvaJsnQE7a5gTIG9rmBMiTtjkB8oa2OQHyBiBvAPKkbW60zS0gNyaStMREkpaYSNISE0laYiJJS0wkaYnyn1xqmxMgP6FtbgB50jY3gDxpm+8G5Fbb3ABy0jZPgJy0zQmQJ23zBiAnbXMC5Enb3AByq21uAflqE0laYiJJS0wkaYmJJC0xkaQlJpK0xCd/AMhJ27wByBMgv0nbPAHyL2ib3wbIjba5BeS7tc0TIG9omxMgNyaStMREkpaYSNISE0laYiJJS0wkaYmJJC1R/pMf0DYnQG61zRuA3GibTYC8oW1OgLyhbZ4AOWmbEyC32uYEyBva5gmQk7a5BeSrTSRpiYkkLTGRpCUmkrTERJKWmEjSEp+8pG2eALnRNreAnLTNrbY5AfKkbb4bkJO2eQLkBpCTtrkF5A1AbrXNCZCTtnkC5KRt3gDkpG2etM0JkBsTSVpiIklLTCRpiYkkLTGRpCUmkrTEJy8B8qRtvlvbvAHISdvcAnKrbd7QNidAvlvbnAC51Ta3gJy0zQmQNwB50jZvAPLVJpK0xESSlphI0hITSVpiIklLTCRpiYkkLfHJH2ibNwA5aZtbQE7a5knbnAC5BeQ3AfKGtjkB8qRtbrTNEyBvaJsbbXMLyBuA3GqbEyA3JpK0xESSlphI0hITSVpiIklLTCRpiU/+AJBbbXMDyK22eUPbnAC51TYnQH5C25wAOQHy3YA8aZsTILfa5gTISdvcapvv1jbfbSJJS0wkaYmJJC0xkaQlJpK0xESSlvjkJW1zq21OgDxpmxMg361tngA5AfLbADlpmxMgJ21zC8hJ29xqm78FkCdt8wYgX20iSUtMJGmJiSQtMZGkJSaStMREkpb45CVAnrTNCZCTtnkC5KRtbgE5aZtbbXMDyBva5gmQEyC/CZAnbfPd2uYWkBtt8wTIG9rmBMiNiSQtMZGkJSaStMREkpaYSNISE0laYiJJS3yyDJBbQG61zQmQk7a5BeQWkBtA3tA2J0CetM1J25wAeQOQn9A2N4D8LSaStMREkpaYSNISE0laYiJJS0wkaYlPlmmbnwDkpG1OgDxpm5O2OQHyhrb5bYC8AchJ27yhbU6A3AJy0jZPgJy0zW8ykaQlJpK0xESSlphI0hITSVpiIklLfPKStrnVNreA3GibJ21zo22eADlpmze0zRuAvKFtbgB50jYnQG61zQmQ7wbkSdvcAPLdJpK0xESSlphI0hITSVpiIklLTCRpiYkkLfHJH2ibEyA/oW1uAHlD29wCctI2PwHISducADlpm1tAvlvbPAFy0ja3gGzSNidAbkwkaYmJJC0xkaQlJpK0xESSlphI0hLlP3lB27wByCZtcwvIG9rmDUB+k7b5CUButM0TICdtcwLkDW1zC8iNiSQtMZGkJSaStMREkpaYSNISE0la4pO/TNvcAPKkbU6AnAB5Q9s8AXIC5FbbnLTNG4C8AciNtnkDkCdtc6NtngA5aZsTIN9tIklLTCRpiYkkLTGRpCUmkrTERJKWmEjSEp/8gbY5AfLbADlpmydA3tA2b2ibEyDfDcittjkB8tu0zQmQW0BO2uZW25wAudU2J0BuTCRpiYkkLTGRpCUmkrTERJKWmEjSEp/8ASCbtM2ttrkB5BaQk7Z5Q9s8AXLSNm8ActI2J0CetM0NILfa5rcBcqNtngD5ahNJWmIiSUtMJGmJiSQtMZGkJSaStMQnfxkgb2ibEyC3gJy0zQmQW21zAuRJ29xom39F29wA8oa2edI2N4A8aZsTIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckfaJu/BZBbbXMC5EnbnAD5bYB8tbZ5AuRG29wC8tu0zQmQNwA5aZvvNpGkJSaStMREkpaYSNISE0laYiJJS3zyEiC/TdvcAnKjbZ4A+W5ANmmbEyAnQJ60zY22+QlAfhMgT9rmq00kaYmJJC0xkaQlJpK0xESSlphI0hKf/JC2eQOQTdrmBMhJ29wCcqttToC8AchJ25wAeQOQW21z0jZ/EyBfbSJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hKf6P/SNt+tbU6APGmbk7Y5AfKGtjkB8qRtToC8oW1uAbkB5EnbnAA5aZtbbfMGIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJT/THgNxqmxMgJ23zBMhJ25y0zRMgX61t3tA2vw2Qk7b5CUButM0TIF9tIklLTCRpiYkkLTGRpCUmkrTERJKW+OSHANkEyI22eQLkBpCf0DYnQE6AnLTNrbY5AfIT2uYEyC0gN4A8aZsbQL7bRJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJT55Sdv8K9rmt2mbNwC50TZ6BuRJ29wA8oa2uQXkxkSSlphI0hITSVpiIklLTCRpiYkkLVH+E0laYCJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTE/wBj/86DjowMMQAAAABJRU5ErkJggg==	\N	f	\N	\N	\N	2026-03-26 13:29:30.046	2026-03-26 13:29:30.046
1ae2394d-8941-4fc3-a1e0-bc6fe57861b2	VCP202603269923	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	4	\N	2026-03-27	09:00	1	110000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:32:17.946	2026-03-26 13:32:17.946
8e7718df-3a3a-4223-abb2-9d8f4be68c33	VCP202603260215	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	6	\N	2026-03-27	05:30	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:35:01.914	2026-03-26 13:35:01.914
c0b22c28-10c0-461c-b26e-ac1d85f89b15	VCP202603266458	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	6	\N	2026-03-27	11:00	1	130000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAApWSURBVO3BgXEcSRIEwcwy6K9yPBXo+bMmZ4Eiw738EklaYCJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+MpvaJu/BZAnbfMGIDfa5haQN7TNCZB/RdvcAPKkbf4WQG5MJGmJiSQtMZGkJSaStMREkpaYSNISX3kJkJ+mbW4BudE2T9rmBpAnbfOGtrnRNreAnLTNpwH5aYD8NG3zp00kaYmJJC0xkaQlJpK0xESSlphI0hITSVriK9+kbd4A5NPa5gTIk7Y5AXLSNk+A3GibNwC51TYnQE7a5haQk7bZpG3eAOTTJpK0xESSlphI0hITSVpiIklLTCRpia/oP2mbNwA5aZtbbXMDyKe1zRMgN4A8aZsbQJ60zQkQ3ZtI0hITSVpiIklLTCRpiYkkLTGRpCW+ov8EyEnbnLTNLSC32uYEyBva5gTIp7WN/i4TSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+Mo3AfIvAHKrbU6APAFy0jZvAHIDyJO2OQFyAuRW25wAudU2J0DeAORvMZGkJSaStMREkpaYSNISE0laYiJJS3zlJW3zN2mbEyAnbfMEyBva5gTISds8AXLSNidATtrmCZCTtjkB8qRtToCctM0TICdt84a2+RdMJGmJiSQtMZGkJSaStMREkpaYSNISX/kNQP4VQE7a5g1ATtrmCZC/RducADlpm1tt89MA+ddNJGmJiSQtMZGkJSaStMREkpaYSNISE0laovySb9A2J0BO2uYNQJ60zQmQk7Z5AuSkbd4A5FbbnAB5Q9vcAPKGtvkOQN7QNidAbrXNCZAbE0laYiJJS0wkaYmJJC0xkaQlJpK0xFd+Q9u8oW1OgCgB8qRtbrTNEyA32uYEyBva5haQTwNyq21OgDwBssVEkpaYSNISE0laYiJJS0wkaYmJJC1RfskP0zYnQJ60zQ0gt9rmDUButc2nAflJ2uYWkFttcwPIk7b5NCAnbXMLyI2JJC0xkaQlJpK0xESSlphI0hITSVpiIklLfGWZtrkF5NOA3GqbW0ButM2ttrkB5Fbb3AJy0jYnQJ4AOWmbk7Z5AuSkbU6APGmbG0CetM2fNpGkJSaStMREkpaYSNISE0laYiJJS3zlN7TNCZCfpm1OgNwCctI2SoDcapsTILfa5g1tcwLkVtvcaJsnQG60zRMgf9pEkpaYSNISE0laYiJJS0wkaYmJJC3xld8A5A1ATtrmCZAbbfMEyBuA3GibJ21zA8iTtvlJ2uYEyBMgJ22zCZBbbfOGtjkBcmMiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISX/kNbXMLyA0gt9rmBMiTtjkBcqttToCcALnVNm8AcqNtngC50Ta3gJy0zRMgJ21zAuRW25wAeQLkpG1+kokkLTGRpCUmkrTERJKWmEjSEhNJWqL8kkttcwLkDW3zBMintc0tIG9omxMgJ21zC8hJ27wByK22uQHkSducALnVNidATtrmCZAtJpK0xESSlphI0hITSVpiIklLTCRpia98k7b5tLa5BeQEyN8CyBuAnLTNG9rmDW3zBMiNtrnVNidAnrTNCZBbbXMC5MZEkpaYSNISE0laYiJJS0wkaYmJJC0xkaQlvvKStnkDkFtAbrXNG4CctM0JkFtt82lAbgG5AeRW23wakCdtcwLkFpCTtvlJJpK0xESSlphI0hITSVpiIklLTCRpifJLfpi2uQXkpG1OgLyhbZ4A+bS2eQOQk7Y5AfId2uYEyEnbPAFy0jafBuRW27wByI2JJC0xkaQlJpK0xESSlphI0hITSVqi/JK/SNucADlpm78JkJO2OQFyq23eAORG29wC8mltcwvISds8AXKjbZ4A+dMmkrTERJKWmEjSEhNJWmIiSUtMJGmJr/yGtrkF5EbbPAFy0jabADlpm1tATtrmCZA/DciTtjkBcgLkO7TNp7XNCZC/xUSSlphI0hITSVpiIklLTCRpiYkkLTGRpCXKL3lB29wCcqttToCctM0tICdt8wTISdvcAvKGtrkB5A1tcwvIT9I2T4D8JG1zC8iNiSQtMZGkJSaStMREkpaYSNISE0la4iu/oW1OgDxpmzcAOWmbW0BO2uYNQG61zQmQW0ButM0JkO/QNjeAbNI2T4DcAPJpE0laYiJJS0wkaYmJJC0xkaQlJpK0xFf+Mm1zAuSkbZ60zQmQW23zLwCyCZA3tM2ttjkBcgLkDW3zBMifNpGkJSaStMREkpaYSNISE0laYiJJS0wkaYnyS75B2/wkQJ60zQ0gm7TNEyAnbXMC5FbbnAC51TYnQG61zQmQk7Z5AuRG2zwB8oa2OQFyYyJJS0wkaYmJJC0xkaQlJpK0xESSlvjKNwHyk7TNG9rmFpCTtnkC5AaQJ21zAuSkbd7QNvo9bbPFRJKWmEjSEhNJWmIiSUtMJGmJiSQtUX7JpbY5AfKkbU6A3GqbNwD5tLY5AfKkbT4NyE/SNm8A8q9omxMgT9rmBMiNiSQtMZGkJSaStMREkpaYSNISE0laYiJJS5Rf8oK2eQLkpG1OgOj/a5sTICdt8wTIjbY5AfKkbU6A3GqbTwNy0ja3gJy0zS0gJ23zBMifNpGkJSaStMREkpaYSNISE0laYiJJS5RfcqltToA8aZsTICdt8wTISdv8NEBO2ubTgDxpmxMgP0nbPAFy0jYnQG61zU8D5KRtToA8aZsTIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJ8kv0f7XNTwLkDW3z0wC50TZvAHKrbU6AvKFtngC50Ta3gNyYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xFd+Q9v8LYA8AfKGtjkBcqttToB8GpBbbfNpQE7a5gmQN7TNCZA3tM1PMpGkJSaStMREkpaYSNISE0laYiJJS3zlJUB+mra51TY3gDwBcqNtbrXNCZBbbXPSNidAngB5Q9uctM0JkO8A5NOA3GqbP20iSUtMJGmJiSQtMZGkJSaStMREkpb4yjdpmzcA+TQgt9rmBpDv0DY/SducAHkC5KRtTtrmCZAbbfMd2uYEyE8ykaQlJpK0xESSlphI0hITSVpiIklLTCRpia/oPwFy0jYnQJ4AOWmbk7Z5A5AnQE7a5kbb3AJy0jZPgJwAOWmb7wDkpG3e0DYnQJ4A+dMmkrTERJKWmEjSEhNJWmIiSUtMJGmJr+g/aZsTICdtcwvISds8AXLSNrfa5gaQk7a51TYnQG61zacBuQXkpG2eADlpm1ttcwLkxkSSlphI0hITSVpiIklLTCRpiYkkLVF+yaW2OQHy07TNCZBbbXMC5Enb3ACiZ23zBMintc0JkE3a5gmQP20iSUtMJGmJiSQtMZGkJSaStMREkpaYSNISX3lJ2/wrgNwConcAeUPbPAHyhrZ5A5A3tM0JkBsTSVpiIklLTCRpiYkkLTGRpCUmkrRE+SWStMBEkpaYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpif8BvDTcXT8bazkAAAAASUVORK5CYII=	\N	f	\N	\N	\N	2026-03-26 13:36:19.103	2026-03-26 13:36:19.103
29affeb1-798f-45f5-a655-d64decbf07ee	VCP202603263988	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	6	\N	2026-03-27	06:00	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 13:44:50.682	2026-03-26 13:44:50.682
50369e1d-de1c-49ff-b698-c00b5d286198	VCP202603261041	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	6	\N	2026-03-27	11:00	1	130000	PAID	data:image/png;base64,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	\N	t	2026-03-26 22:18:44.073	946327fe-acd5-4581-aa42-769e394e70c0	\N	2026-03-26 13:36:34.278	2026-03-26 22:18:44.073
4aec7705-ead4-45a2-83fb-8ee18afc9d4b	VCP202603269693	\N	Lê Quang Minh	0908724146	lequangminh951@gmail.com	6	\N	2026-03-27	07:30	5	650000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 22:21:28.606	2026-03-26 22:21:28.606
c7b07e84-aa0b-401c-8891-0a3f85aefd00	VCP202603262477	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	6	\N	2026-03-27	11:00	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 22:24:39.445	2026-03-26 22:24:39.445
61fa943e-028b-4a1b-b33e-aed41ada3536	VCP202603266432	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	6	\N	2026-03-27	07:30	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 22:53:20.246	2026-03-26 22:53:20.246
ead75f59-95fe-4f72-9abf-4059d202eb91	VCP202603260963	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	6	\N	2026-03-27	08:00	1	120000	PENDING	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAAAqCSURBVO3BgW0dSxIEwarG89/lPDkwi8OIS7L1M6L8EUlaYCJJS0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+OQvtM2/Asgb2uYJkBtt8wTISdvcAnKjbU6APGmbG0De0DZPgLyhbf4VQG5MJGmJiSQtMZGkJSaStMREkpaYSNISn7wEyG/TNm9om1ttcwLkuwF50jY3gHy3trkF5A1tcwLkFpDfpm2+2kSSlphI0hITSVpiIklLTCRpiYkkLTGRpCU++SFt8wYgvwmQJ21z0jYnQJ60zQmQk7a5BeSkbU6A3AJy0jZPgJy0zQmQJ23zm7TNG4B8t4kkLTGRpCUmkrTERJKWmEjSEhNJWuIT/VpA3tA2J0CetM1J25wAOWmbJ0D+FUB0byJJS0wkaYmJJC0xkaQlJpK0xESSlvhE/5e2eQOQk7Y5AXILyEnb3ALy3drmBMgtIG9omxMgejaRpCUmkrTERJKWmEjSEhNJWmIiSUtMJGmJT34IkE2A3GibN7TNEyA3gHw3IE/a5gTISds8AXLSNidAngD5TYD8KyaStMREkpaYSNISE0laYiJJS0wkaYlPXtI2/5K2OQFyC8hJ25wAedI2J0BO2uYJkJO2OQFy0jZPgJy0zQmQJ21zAuSkbZ4AOWmbEyC32ua/YCJJS0wkaYmJJC0xkaQlJpK0xESSlvjkLwDRe4DcAnLSNt+tbU6APGmbEyAnbfMGIE/a5g1A/usmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckPaZsbQG61zb+ibZ4AOQFyq22+Wtu8AcittjkB8oa2uQXkpG2eANliIklLTCRpiYkkLTGRpCUmkrTERJKW+OQXAnKrbU6AnLTNT2ibEyC32uY3AXKrbd7QNjfaZhMgt9rmFpCvNpGkJSaStMREkpaYSNISE0laYiJJS3zyF9rmBMgTICdtcwvISducALnVNidAbrXNCZAnbXMC5KRtngA5aZs3ADlpm1tA3tA2J0BO2uYJkJO2+W5AvttEkpaYSNISE0laYiJJS0wkaYmJJC0xkaQlPvkLQG61zQmQNwB5A5CTtnlD2zwB8pu0zQmQJ21zAuQNbXMC5A1A3gDkVtuctM0tIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJ8kcutc0JkJ/QNjeAPGmbG0CetM1vAuRJ29wActI2T4CctM1vA+SkbU6APGmbG0CetM0JkJO2eQLkq00kaYmJJC0xkaQlJpK0xESSlphI0hKf/AUgJ23zBiBPgPwmbfMEyH9B23w3IG9om1tAvlvbPAFy0ja32uYEyI2JJC0xkaQlJpK0xESSlphI0hITSVpiIklLlD/yA9rmBMgb2uYWkJO2+VcAeUPbnAB5Q9s8AXLSNidAbrXNCZA3tM0TICdtcwvIV5tI0hITSVpiIklLTCRpiYkkLTGRpCXKH3lB2zwBcqNtngC50TZPgNxom98GyEnb3AJyo21uATlpmydA3tA2J0BO2uYJkJO2uQXkRtvcAnJjIklLTCRpiYkkLTGRpCUmkrTERJKW+OQlQJ60zQ0gT9rmu7XNCZAnbXMC5FbbvAHIb9I2J0Butc0tICdtcwLkDUCetM0bgHy1iSQtMZGkJSaStMREkpaYSNISE0laYiJJS5Q/cqlt3gDkpG2eALnRNreAvKFtToA8aZsTIJu0zRuAnLTNJkButc0JkFttcwLkxkSSlphI0hITSVpiIklLTCRpiYkkLfHJXwByq21uALnVNidAnrTNSducAHnSNidAfpu2OQFy0jYnQN4A5EnbnAC51TYnQE7a5lbbfLe2+W4TSVpiIklLTCRpiYkkLTGRpCUmkrTEJy9pm1ttcwLkSducADlpmydAbrTNEyCbADlpm+8G5KRtbrXNvwLIk7Z5A5CvNpGkJSaStMREkpaYSNISE0laYiJJS3zyEiBP2uYEyEnbPAFy0jZvaJtbbXMDyBva5gmQEyA32uYNQJ60zXdrm1tAbrTNEyBvaJsTIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckyQG4BudU2J0BO2uYWkFtAbgB5Q9ucALnVNidA3gDkJ7TNDSBvAPKkbb7aRJKWmEjSEhNJWmIiSUtMJGmJiSQt8ckybfMTgJy0zQmQJ21z0ja3gNxom/8KICdt84a2OQFyC8hJ2zwBctI2J0CeAPlqE0laYiJJS0wkaYmJJC0xkaQlJpK0xCd/oW1OgNxqm1tAbrTNk7a50TZPgJy0zQmQJ23z3YC8oW1OgNxqmxMgt9rmBMh3A/KkbbaYSNISE0laYiJJS0wkaYmJJC0xkaQlJpK0xCc/BMgb2uYGkDe0zS0gJ23zBMhJ29wCctI2J0BO2uYJkN+kbZ4AOWmbW0A2aZsTIDcmkrTERJKWmEjSEhNJWmIiSUtMJGmJ8kd+mbY5AbJJ29wC8oa2eQOQ79Y2vw2QG23zBMhJ25wAedI23w3IjYkkLTGRpCUmkrTERJKWmEjSEhNJWqL8kRe0zRMgb2ibG0CetM0JkO/WNk+AnLTNCZAnbfPdgNxomydAbrTNEyBvaJs3ADlpmxMg320iSUtMJGmJiSQtMZGkJSaStMREkpaYSNISn/yFtjkBcqttToDcAnLSNk+AvKFt3tA2J0C+G5BbbXMC5LdpmxMgt4CctM2ttjkBcqttToDcmEjSEhNJWmIiSUtMJGmJiSQtMZGkJT75C0Butc0JkDe0za22uQHkFpCTtnlD2zwBctI2bwBy0jYnQJ60zQ0gt9rmtwFyo22eAPlqE0laYiJJS0wkaYmJJC0xkaQlJpK0xCc/BMgbgLyhbd4A5KRtToDcapsTIE/a5kbb/Fe0zQ0gb2ibJ21zA8iTtjkBcmMiSUtMJGmJiSQtMZGkJSaStMREkpaYSNISn/yFtvlXALkF5FbbnAD5bYCctM0JkJO2eQLkRtvcAvLbtM0JkDcAOWmb7zaRpCUmkrTERJKWmEjSEhNJWmIiSUt88hIgv03b3ALyBiDfDcgbgLyhbU6AnAB50jY32uYnAPlNgDxpm682kaQlJpK0xESSlphI0hITSVpiIklLfPJD2uYNQL5b27wByEnb3AJyq21uALkF5KRtToC8Acittjlpm38JkK82kaQlJpK0xESSlphI0hITSVpiIklLTCRpiU/0f2mbNwA5aZsTIE/a5qRtToD8Nm1zAuQNbXMLyA0gT9rmBMhJ29xqmzcAuTGRpCUmkrTERJKWmEjSEhNJWmIiSUt8or8G5Lu1zRMgJ21z0jZPgGzRNr8NkJO2+QlAbrTNEyBfbSJJS0wkaYmJJC0xkaQlJpK0xESSlvjkhwDZBMiNtrkF5LdpmxMgJ23zhrY5AfIT2uYEyC0gN4A8aZsbQL7bRJKWmEjSEhNJWmIiSUtMJGmJiSQtMZGkJT55Sdv8V7TNLSBvaJs3ALkB5KRtlAB50jY3gLyhbW4BuTGRpCUmkrTERJKWmEjSEhNJWmIiSUuUPyJJC0wkaYmJJC0xkaQlJpK0xESSlphI0hITSVpiIklLTCRpiYkkLTGRpCUmkrTERJKW+B/TA/pd597pFQAAAABJRU5ErkJggg==	\N	f	\N	\N	\N	2026-03-26 23:16:44.942	2026-03-26 23:16:44.942
4e4b4559-b03a-4a20-83b6-dccd1bb0d100	VCP202603265547	\N	minh	0908724146	lequangminh951@gmail.com	6	\N	2026-03-27	09:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-26 23:19:52.62	2026-03-26 23:19:52.62
86a658bd-2300-4ef7-b450-084daad71ecd	VCP202603292122	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	4	\N	2026-03-29	09:00	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-29 01:07:37.878	2026-03-29 01:07:37.878
3b8f9186-33ba-4797-9b03-53b316850ee0	VCP202603299469	946327fe-acd5-4581-aa42-769e394e70c0	Quản trị viên	02519999975	admin@vocucphuong.com	13	\N	2026-03-29	11:00	1	130000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-03-29 01:08:50.023	2026-03-29 01:08:50.023
9dbbcfdf-a4df-420b-981e-6e25fb143aff	VCP202604118553	ae614573-6938-484c-b3b6-d054baefa0fa	Lê Quang Minh	0908724146	lequangminh951@gmail.com	6	\N	2026-04-11	11:00	1	120000	PAID	data:image/png;base64,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	\N	t	2026-04-11 23:48:54.566	946327fe-acd5-4581-aa42-769e394e70c0	\N	2026-04-11 23:08:53.724	2026-04-11 23:48:54.566
3138760f-c4d3-48f5-9ff4-be8e13f63f74	VCP202604269686	\N	Bùi Ngọc Hải Tiến	0396958081	buingochaitien@gmail.com	6	\N	2026-04-26	13:30	1	120000	PENDING	data:image/png;base64,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	\N	f	\N	\N	\N	2026-04-26 00:12:12.072	2026-04-26 00:12:12.072
\.


--
-- Data for Name: buses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.buses (id, license_plate, bus_type, total_seats, status, created_at, updated_at) FROM stdin;
49E6E250-AF1A-4398-9308-69A7224ACB4D	51B-12351	Limousine	24	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
52D3A4FB-2B4F-4E10-8E2C-E6844A0B70C5	51B-12346	Ghế ngồi	45	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
6B39525B-194C-43AD-96D7-24BCB26DCDF1	51B-12348	Giường nằm	36	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
762BA7D3-F349-426E-9EBF-11D88CA4B81A	51B-12347	Ghế ngồi	45	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
86B2609C-F79B-49F7-B737-47B1953C4411	51B-12349	Giường nằm	36	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
97B0D070-8B6F-4FC2-A457-F8630E7802B8	51B-12345	Ghế ngồi	45	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
B7316D00-4748-4CEA-A05D-1A13B69E9492	51B-12352	Ghế ngồi	45	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
CBE6DC9E-E061-4F6E-B187-D88D53AF35EE	51B-12350	Limousine	24	ACTIVE	2026-01-14 13:09:20.355215	2026-01-14 13:09:20.355215
\.


--
-- Data for Name: internal_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.internal_users (id, username, password, full_name, email, phone, role, station, is_active, last_login, created_at, updated_at) FROM stdin;
1	admin	$2b$10$L//n6IhUznsaoY7FrfZc3./tVW0gHJSgVdJ5wFFAufgjdBlQ5xTiq	Quản Trị Viên	admin@vocucphuong.com	\N	admin	\N	t	\N	2026-01-15 06:46:05.132473	2026-01-15 06:46:05.132473
\.


--
-- Data for Name: nh_counters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nh_counters (id, counter_key, value, station, date_key, last_updated) FROM stdin;
\.


--
-- Data for Name: nh_products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nh_products (id, sender_name, sender_phone, sender_station, receiver_name, receiver_phone, receiver_station, product_type, quantity, vehicle, insurance, total_amount, payment_status, employee, created_by, send_date, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, amount, method, status, transaction_id, paid_at, metadata, created_at, updated_at) FROM stdin;
771e6b87-2f0b-45fd-8249-2e6f3c0f6bdb	5624e641-2b35-465d-867d-17edd56e9e24	120000	QRCODE	PENDING	\N	\N	\N	2026-01-14 13:41:27.499	2026-01-14 13:41:27.499
720e084f-29fc-4549-b974-d83f0b1a8dc3	f38e097b-1df5-49b1-96d4-2c32cc520c45	120000	QRCODE	PENDING	\N	\N	\N	2026-01-14 15:20:59.74	2026-01-14 15:20:59.74
8ef9e632-5fee-4782-95b3-9b90f0cf0c96	e2011bd5-f416-41cb-9035-3f767ab84f7f	120000	QRCODE	PENDING	\N	\N	\N	2026-01-15 00:11:05.955	2026-01-15 00:11:05.955
69d37b5a-b60b-4ba4-8d47-270629181eba	fe35187a-3dbc-430e-9592-1b1655d923de	120000	QRCODE	PENDING	\N	\N	\N	2026-01-15 00:12:03.76	2026-01-15 00:12:03.76
06707f69-9dbe-4222-8367-96c38d68be7f	e89506cb-efbe-41f7-9c1a-f4e4fba2408b	110000	QRCODE	PENDING	\N	\N	\N	2026-01-15 00:19:51.579	2026-01-15 00:19:51.579
f12834b0-a6aa-44ff-8d18-90a61f6a38a5	0f8dcba1-d06a-4599-888f-4bdf26f0ab76	120000	QRCODE	PENDING	\N	\N	\N	2026-01-15 01:12:56.054	2026-01-15 01:12:56.054
5dc6b47c-3a6f-4f84-89d3-88a2027113c6	fa1285bc-a44b-4ebd-9087-94aab1849f13	120000	QRCODE	PENDING	\N	\N	\N	2026-01-15 07:47:06.266	2026-01-15 07:47:06.266
b7aaddbe-df9d-4993-881e-bcea56228d94	5d28e769-db9b-4ff8-9e3c-67b2b4c9c69e	120000	QRCODE	PENDING	\N	\N	\N	2026-01-15 07:47:17.504	2026-01-15 07:47:17.504
95a59f6e-4e29-410f-aacc-40ed2da0e337	97eab092-b67d-409d-ad9f-d77f97de10a5	120000	QRCODE	PENDING	\N	\N	\N	2026-01-16 02:55:58.84	2026-01-16 02:55:58.84
735ec1f3-e3eb-46d6-851f-e5449103f7bb	c487f0e1-e671-48ca-9f3b-1b7bcaaf8e9a	120000	QRCODE	PENDING	\N	\N	\N	2026-01-16 04:07:36.432	2026-01-16 04:07:36.432
9851673b-11bb-4622-ad1d-8c86362d442d	e58900fe-5648-400e-8f45-d9a863ad4b2b	120000	QRCODE	PENDING	\N	\N	\N	2026-01-16 07:01:55.014	2026-01-16 07:01:55.014
d9420cb5-a2f8-4a47-ae85-2da4eb6190d4	ae173274-4959-4532-8b39-2cf1be2808c6	120000	QRCODE	PENDING	\N	\N	\N	2026-01-16 08:27:38.617	2026-01-16 08:27:38.617
30695d2f-e63b-4661-bd6d-27a49807adb4	f1dc1d7e-030a-4f42-8446-eee00f298bf1	120000	QRCODE	PENDING	\N	\N	\N	2026-01-17 13:38:43.75	2026-01-17 13:38:43.75
c00b03b3-645f-4b76-b16d-20bb08571e54	59e70e61-5630-4363-bef7-c47a40ed94aa	120000	QRCODE	PENDING	\N	\N	\N	2026-01-17 14:02:18.896	2026-01-17 14:02:18.896
f2275baa-7d4e-4f67-b382-7eda70218886	4f639785-7442-4161-9fda-a3cf396faaae	120000	BANK_TRANSFER	COMPLETED	\N	2026-01-18 03:03:20.497	null	2026-01-17 01:52:12.158	2026-01-18 03:03:20.497
0a51aca6-afe1-4108-ae88-38bb33bdc675	fdb3e17a-a4cc-4473-bebb-78e7dc0fb7f6	120000	BANK_TRANSFER	COMPLETED	\N	2026-01-18 03:03:24.159	null	2026-01-16 08:27:13.336	2026-01-18 03:03:24.159
3fed7921-f4ff-4f9f-beac-625a0a2bc728	119c6073-c8ad-4845-b99f-9c40206cf2c8	120000	BANK_TRANSFER	COMPLETED	\N	2026-01-18 03:03:35.48	null	2026-01-18 03:03:35.48	2026-01-18 03:03:35.48
cedf0714-5d1c-4278-8cb9-c71d59adf7ec	53a6f6a9-a0af-4917-ba6e-cc2a21215323	120000	BANK_TRANSFER	COMPLETED	\N	2026-01-18 03:03:37.983	null	2026-01-14 13:41:49.953	2026-01-18 03:03:37.983
23d01149-e5dc-48cd-8969-5c669511fe7b	47d17ea8-a6e1-48bb-8abf-dfa7c5d3963b	120000	BANK_TRANSFER	COMPLETED	\N	2026-01-18 03:03:47.612	null	2026-01-17 13:34:47.614	2026-01-18 03:03:47.612
fcbd7bf9-0411-4df8-9f45-a7bd8028569f	7efdd906-d5ad-43c1-9a1e-0f4b75d36d1c	120000	QRCODE	PENDING	\N	\N	\N	2026-01-18 03:37:34.876	2026-01-18 03:37:34.876
d0f8631f-0803-4338-98c5-f1df1e0c63d5	7f0bf8f0-d782-4cd5-890f-2ede1d8bbf7b	120000	QRCODE	PENDING	\N	\N	\N	2026-01-18 23:28:32.157	2026-01-18 23:28:32.157
8b525f46-2665-4544-8b26-fc66197c7db3	c52957bf-0555-40b0-a586-bce087896f5d	120000	QRCODE	PENDING	\N	\N	\N	2026-01-18 23:30:44.252	2026-01-18 23:30:44.252
b65f6d36-5ba9-4d4d-a246-bc7d56a26b2e	196276e5-1073-4f74-acff-eb20e7608a15	120000	QRCODE	PENDING	\N	\N	\N	2026-01-20 14:04:37.056	2026-01-20 14:04:37.056
d18d5b10-0e12-48cd-bf3f-c90ee9abb694	2c61bdfd-7ed2-4dbb-834c-c55074436131	130000	QRCODE	PENDING	\N	\N	\N	2026-01-20 14:18:56.16	2026-01-20 14:18:56.16
1e64676d-4e3d-491b-b49b-515a99633354	d60bcffa-4912-4771-9a99-9fb2a67fb168	960000	QRCODE	PENDING	\N	\N	\N	2026-01-20 14:49:55.941	2026-01-20 14:49:55.941
cdcbd3a5-9ed3-4a3b-872b-f5ee0e2aa039	916e4912-7feb-485b-a93e-9e24ed3dec72	120000	QRCODE	PENDING	\N	\N	\N	2026-01-22 00:58:28.163	2026-01-22 00:58:28.163
011d09b2-0851-4b71-b3ec-b977ebfc6dcc	777e07a0-2155-4850-b228-252156fcfa62	120000	QRCODE	PENDING	\N	\N	\N	2026-01-26 01:20:40.626	2026-01-26 01:20:40.626
78ae28c6-e658-415d-bb50-0b39cce97851	272b9c7b-f12f-4e8d-a482-4281711c6f13	130000	QRCODE	PENDING	\N	\N	\N	2026-01-26 06:12:12.352	2026-01-26 06:12:12.352
3a450f0b-6353-4d48-8197-08de6309eb4d	3d06d579-1f53-4f98-a324-2473c689d6c9	960000	BANK_TRANSFER	COMPLETED	\N	2026-01-28 05:33:50.433	null	2026-01-20 14:50:19.878	2026-01-28 05:33:50.433
4d44b4bd-18c7-42a4-be79-44908fe0ff29	56c1ba28-8885-47a0-a404-e4f6553b3bda	110000	QRCODE	PENDING	\N	\N	\N	2026-02-21 04:55:00.406	2026-02-21 04:55:00.406
45348ef0-6a6d-4f98-96de-c7b42c6066d0	40281af6-56d7-4cfc-9659-d3330ff1498f	120000	QRCODE	PENDING	\N	\N	\N	2026-03-08 16:55:33.951	2026-03-08 16:55:33.951
2a364687-2a3f-4dde-b60a-e2d7e6e94fe0	fc8f343b-ff6b-4be6-ace5-6d20509357e9	120000	QRCODE	PENDING	\N	\N	\N	2026-03-22 08:43:35.586	2026-03-22 08:43:35.586
9bf1a4a5-b286-4a25-bc09-77f079635ca5	006661bb-50cc-40be-9164-6f91ffb2cad5	120000	QRCODE	PENDING	\N	\N	\N	2026-03-23 14:29:24.64	2026-03-23 14:29:24.64
d0409d45-5170-4eef-b8b7-7c30b3a1c11f	f83c054a-b3c6-4f3d-bd03-bc961e5ac6ca	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 05:59:53.768	2026-03-26 05:59:53.768
905e7733-abb4-498c-902a-acd674e5fe78	e34a4ca5-2ec5-4edc-99fc-5de1a55e7e33	110000	QRCODE	PENDING	\N	\N	\N	2026-03-26 06:00:38.031	2026-03-26 06:00:38.031
daa25722-3897-478e-b9d7-d9f3daffb843	baf1f628-0c40-418b-a818-6ce89fc68128	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 10:12:10.576	2026-03-26 10:12:10.576
10476538-e758-443c-a7a9-9699399bb348	8fdbe4d9-71cf-4ede-9e33-ac2086bf0e0a	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:17:18.24	2026-03-26 13:17:18.24
64b590f6-3598-4da8-8027-621c01d9a292	b516fa12-03a4-4b5d-83a4-ae9b5724b09d	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:17:53.008	2026-03-26 13:17:53.008
48bdfcb3-0351-418d-8056-793f55b08b73	91343bbf-0a55-46ed-96fc-43ede222585b	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:19:36.987	2026-03-26 13:19:36.987
de1052e9-89a0-45c4-90cd-d3c9da054f8e	0464db63-2ea4-4618-bd23-ccd20aa7c2e8	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:22:40.603	2026-03-26 13:22:40.603
18357dd3-e9b6-4f6a-9737-a9410d8dbfc4	235cd683-b079-483a-8b3a-e32ef61b12df	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:23:54.45	2026-03-26 13:23:54.45
67c8771a-ecf8-48f1-b521-e8579d1b88b6	bb586736-91f7-4dc1-96af-e9a0dcfa1af3	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:24:09.175	2026-03-26 13:24:09.175
6b0b4071-5f1b-456d-803e-c490f986411a	b74300aa-2a9c-465a-a4b5-7b6bab153af3	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:29:09.133	2026-03-26 13:29:09.133
782a961c-ccb4-45bb-a8b2-acb53805463a	de1605af-7dc8-4892-87da-577cc06b3bc2	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:29:30.046	2026-03-26 13:29:30.046
a649220b-4ee0-410c-ac3c-825115bcf9e3	1ae2394d-8941-4fc3-a1e0-bc6fe57861b2	110000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:32:17.946	2026-03-26 13:32:17.946
a87a96c8-35ea-4a49-a082-33138d2d24b4	8e7718df-3a3a-4223-abb2-9d8f4be68c33	130000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:35:01.914	2026-03-26 13:35:01.914
afe18252-bab1-4ed8-a710-a10cea460b37	c0b22c28-10c0-461c-b26e-ac1d85f89b15	130000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:36:19.103	2026-03-26 13:36:19.103
28d9be8e-06d9-43a8-87b2-2964346cc679	29affeb1-798f-45f5-a655-d64decbf07ee	130000	QRCODE	PENDING	\N	\N	\N	2026-03-26 13:44:50.682	2026-03-26 13:44:50.682
5e27b25c-cf7b-4edf-be4d-458a725cb62c	50369e1d-de1c-49ff-b698-c00b5d286198	130000	BANK_TRANSFER	COMPLETED	\N	2026-03-26 22:18:17.764	null	2026-03-26 13:36:34.278	2026-03-26 22:18:17.764
f915c196-7f77-498a-879e-37875916173c	4aec7705-ead4-45a2-83fb-8ee18afc9d4b	650000	QRCODE	PENDING	\N	\N	\N	2026-03-26 22:21:28.606	2026-03-26 22:21:28.606
48eec66d-3e26-4327-a14a-91728a7043d9	c7b07e84-aa0b-401c-8891-0a3f85aefd00	130000	QRCODE	PENDING	\N	\N	\N	2026-03-26 22:24:39.445	2026-03-26 22:24:39.445
8eed351a-cbe3-44f3-a79b-87d265301e0b	61fa943e-028b-4a1b-b33e-aed41ada3536	130000	QRCODE	PENDING	\N	\N	\N	2026-03-26 22:53:20.246	2026-03-26 22:53:20.246
cabc56fc-a1b3-4cff-ad92-ae3a1d98feab	ead75f59-95fe-4f72-9abf-4059d202eb91	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 23:16:44.942	2026-03-26 23:16:44.942
18a741fa-0dea-403c-82e0-5640ce8b1923	4e4b4559-b03a-4a20-83b6-dccd1bb0d100	120000	QRCODE	PENDING	\N	\N	\N	2026-03-26 23:19:52.62	2026-03-26 23:19:52.62
eb6ea35c-4048-451c-86b5-fbec55a9ff82	86a658bd-2300-4ef7-b450-084daad71ecd	120000	QRCODE	PENDING	\N	\N	\N	2026-03-29 01:07:37.878	2026-03-29 01:07:37.878
0cf2e900-decb-4efd-b889-3e47f4cef8c2	3b8f9186-33ba-4797-9b03-53b316850ee0	130000	QRCODE	PENDING	\N	\N	\N	2026-03-29 01:08:50.023	2026-03-29 01:08:50.023
8a27daa2-726c-4f2f-a01f-cd6df8e71ad0	9dbbcfdf-a4df-420b-981e-6e25fb143aff	120000	QRCODE	COMPLETED	CASH_CHECKIN_1775951334108	2026-04-11 23:48:54.108	\N	2026-04-11 23:08:53.724	2026-04-11 23:48:54.108
4647e0e8-de8e-4f60-a2f9-c90c6fd6d3ba	3138760f-c4d3-48f5-9ff4-be8e13f63f74	120000	QRCODE	PENDING	\N	\N	\N	2026-04-26 00:12:12.072	2026-04-26 00:12:12.072
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.routes (id, origin, destination, price, duration, bus_type, distance, description, route_map_image, thumbnail_image, images, from_lat, from_lng, to_lat, to_lng, operating_start, operating_end, interval_minutes, is_active, created_at, updated_at) FROM stdin;
8	Xuân Lộc	Long Khánh (Quốc lộ)	130000	1.5 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:30	19:00	30	f	2026-01-14 13:09:20.285603	2026-01-14 13:09:20.285603
15	Xuân Lộc	Sài Gòn (Cao tốc)	150000	3 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	03:30	17:00	30	t	2026-03-26 23:46:16.293109	2026-03-26 23:46:16.293109
1	Long Khánh	Sài Gòn (Cao tốc)	140000	1.5 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:00	18:00	30	f	2026-01-14 13:09:20.285603	2026-01-14 13:09:20.285603
13	Sài Gòn	Xuân Lộc (Cao tốc)	150000	2 giờ ~ 4 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:30	18:30	30	t	2026-03-26 23:46:16.293109	2026-03-26 23:46:16.293109
14	Sài Gòn	Xuân Lộc (Quốc lộ)	150000	1.5 giờ ~ 4 tiếng	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:30	06:30	30	t	2026-03-26 23:46:16.293109	2026-03-26 23:46:16.293109
16	Xuân Lộc	Sài Gòn (Quốc lộ)	150000	4 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	03:30	17:00	30	t	2026-03-26 23:46:16.293109	2026-03-26 23:46:16.293109
2	Long Khánh	Sài Gòn (Quốc lộ)	130000	2 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:00	18:00	30	f	2026-01-14 13:09:20.285603	2026-01-14 13:09:20.285603
3	Sài Gòn	Long Khánh (Cao tốc)	140000	1.5 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:00	18:00	30	f	2026-01-14 13:09:20.285603	2026-01-14 13:09:20.285603
4	Long Khánh	Sài Gòn (Cao tốc)	140000	1.5 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	03:30	18:00	30	t	2026-01-14 13:09:20.285603	2026-03-26 23:46:16.293109
5	Long Khánh	Sài Gòn (Quốc lộ)	130000	2 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	03:30	18:00	30	t	2026-01-14 13:09:20.285603	2026-03-26 23:46:16.293109
6	Sài Gòn	Long Khánh (Cao tốc)	140000	1.5 giờ	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:30	20:00	30	t	2026-01-14 13:09:20.285603	2026-03-26 23:46:16.293109
7	Sài Gòn	Long Khánh (Quốc lộ)	130000	~ 2 giờ 30 phút	Ghế ngồi	\N	\N	\N	\N	\N	\N	\N	\N	\N	05:30	20:00	30	t	2026-01-14 13:09:20.285603	2026-03-26 23:46:16.293109
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schedules (id, route_id, bus_id, date, departure_time, available_seats, total_seats, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, session_token, user_id, expires) FROM stdin;
\.


--
-- Data for Name: stations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stations (id, code, name, full_name, address, phone, is_active, created_at) FROM stdin;
1	01	AN ĐỒNG	01 - AN ĐỒNG	An Đồng, Hải Phòng	0123456789	t	2026-01-15 06:46:05.182731
2	02	BÌNH DƯƠNG	02 - BÌNH DƯƠNG	Bình Dương	0123456790	t	2026-01-15 06:46:05.182731
3	03	CẦU GIẤY	03 - CẦU GIẤY	Cầu Giấy, Hà Nội	0123456791	t	2026-01-15 06:46:05.182731
4	04	ĐỒNG NAI	04 - ĐỒNG NAI	Đồng Nai	0123456792	t	2026-01-15 06:46:05.182731
5	05	LONG KHÁNH	05 - LONG KHÁNH	Long Khánh, Đồng Nai	0123456793	t	2026-01-15 06:46:05.182731
6	06	SÀI GÒN	06 - SÀI GÒN	TP. Hồ Chí Minh	0123456794	t	2026-01-15 06:46:05.182731
\.


--
-- Data for Name: th_bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.th_bookings (id, time_slot_id, customer_name, customer_phone, pickup_type, pickup_address, dropoff_type, dropoff_address, seat_number, amount, payment_status, route, notes, source, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: th_customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.th_customers (id, phone, full_name, pickup_type, pickup_location, dropoff_type, dropoff_location, notes, total_bookings, last_booking_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: th_freight; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.th_freight (id, time_slot_id, sender_name, sender_phone, receiver_name, receiver_phone, receiver_address, description, weight, quantity, freight_charge, cod_amount, status, special_instructions, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: th_timeslots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.th_timeslots (id, "time", date, route, type, code, driver, phone, created_at) FROM stdin;
1	05:30	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
2	06:00	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
3	06:30	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
4	07:00	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
5	07:30	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
6	08:00	15-01-2026	Sài Gòn - Long Khánh	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
7	05:00	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
8	05:30	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
9	06:00	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
10	06:30	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
11	07:00	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
12	07:30	15-01-2026	Long Khánh - Sài Gòn	Xe 28G	\N	\N	\N	2026-01-15 06:46:05.238949
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, email_verified, password, name, phone, avatar, role, created_at, updated_at) FROM stdin;
ae614573-6938-484c-b3b6-d054baefa0fa	lequangminh951@gmail.com	\N	$2b$10$wrX5HZ5FCULZkU/iC0Gq3Oo3NO1SmD25WgNORa/3O8M9SwrjHDis.	Lê Quang Minh	0908724146	\N	USER	2026-01-14 13:09:20.215732	2026-01-14 13:09:20.215732
deb1ff70-2930-4752-adc7-1ff2430c538d	mincubu0205@gmail.com	\N	$2b$10$txOW3vK5fTDtg.EXlxmF3.zjOdICycMsh8I1TYxZf5pVA0uLRI8Oq	Lê Quang Minh	0908724146	\N	USER	2026-01-14 13:09:20.215732	2026-01-14 13:09:20.215732
6bad496e-4bea-46ec-b7ea-d7c5c27ebbab	mincubu020504@gmail.com	\N	$2b$10$66oFMD5qqd5a8bmPNDr23OCi6xq1JKJJpUSRd69ek.2.Sw0EN.bTu	Lê Quang Minh	0908724146	\N	USER	2026-01-14 13:25:59.884	2026-01-14 13:25:59.884
9370c6ed-899c-42d2-b87a-f881a5229ad7	staff@vocucphuong.com	\N	$2b$10$e3rV.z6oPsx/w7i3tx4SAuCteKb7gQFy67RX.VHYBqFQ.hAhPTxlC	Nhân viên	02519999975	\N	STAFF	2026-01-14 13:09:20.215732	2026-01-14 13:09:20.215732
946327fe-acd5-4581-aa42-769e394e70c0	admin@vocucphuong.com	\N	$2b$10$e3rV.z6oPsx/w7i3tx4SAuCteKb7gQFy67RX.VHYBqFQ.hAhPTxlC	Quản trị viên	02519999975	\N	ADMIN	2026-01-14 13:09:20.215732	2026-01-14 13:09:20.215732
192af0e0-f17c-4d1e-9a9e-b2bc89fa8c34	myngoc0626@gmail.com	\N	$2b$10$SeUlvzd8LQ3CHAQWZ0uceu5kqOClJ4Z/v5CZS/5hL/mKzReYyZ8m2	Nguyễn Từ Quỳnh Hương	0896412657	\N	USER	2026-01-16 04:06:34.146	2026-01-16 04:06:34.146
\.


--
-- Name: NhapHangUsers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."NhapHangUsers_id_seq"', 1, false);


--
-- Name: ProductLogs_logId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."ProductLogs_logId_seq"', 1, false);


--
-- Name: Stations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."Stations_id_seq"', 1, false);


--
-- Name: internal_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.internal_users_id_seq', 1, true);


--
-- Name: nh_counters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nh_counters_id_seq', 1, false);


--
-- Name: stations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stations_id_seq', 6, true);


--
-- Name: th_bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.th_bookings_id_seq', 1, false);


--
-- Name: th_customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.th_customers_id_seq', 1, false);


--
-- Name: th_freight_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.th_freight_id_seq', 1, false);


--
-- Name: th_timeslots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.th_timeslots_id_seq', 12, true);


--
-- Name: NhapHangUsers NhapHangUsers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NhapHangUsers"
    ADD CONSTRAINT "NhapHangUsers_pkey" PRIMARY KEY (id);


--
-- Name: NhapHangUsers NhapHangUsers_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NhapHangUsers"
    ADD CONSTRAINT "NhapHangUsers_username_key" UNIQUE (username);


--
-- Name: ProductLogs ProductLogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductLogs"
    ADD CONSTRAINT "ProductLogs_pkey" PRIMARY KEY ("logId");


--
-- Name: Products Products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "Products_pkey" PRIMARY KEY (id);


--
-- Name: Stations Stations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations"
    ADD CONSTRAINT "Stations_pkey" PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_provider_provider_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_provider_provider_account_id_key UNIQUE (provider, provider_account_id);


--
-- Name: bookings bookings_booking_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_code_key UNIQUE (booking_code);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: buses buses_license_plate_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buses
    ADD CONSTRAINT buses_license_plate_key UNIQUE (license_plate);


--
-- Name: buses buses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buses
    ADD CONSTRAINT buses_pkey PRIMARY KEY (id);


--
-- Name: internal_users internal_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_users
    ADD CONSTRAINT internal_users_pkey PRIMARY KEY (id);


--
-- Name: internal_users internal_users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_users
    ADD CONSTRAINT internal_users_username_key UNIQUE (username);


--
-- Name: nh_counters nh_counters_counter_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nh_counters
    ADD CONSTRAINT nh_counters_counter_key_key UNIQUE (counter_key);


--
-- Name: nh_counters nh_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nh_counters
    ADD CONSTRAINT nh_counters_pkey PRIMARY KEY (id);


--
-- Name: nh_products nh_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nh_products
    ADD CONSTRAINT nh_products_pkey PRIMARY KEY (id);


--
-- Name: payments payments_booking_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_key UNIQUE (booking_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_route_id_bus_id_date_departure_time_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_route_id_bus_id_date_departure_time_key UNIQUE (route_id, bus_id, date, departure_time);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_token_key UNIQUE (session_token);


--
-- Name: stations stations_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_code_key UNIQUE (code);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (id);


--
-- Name: th_bookings th_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_bookings
    ADD CONSTRAINT th_bookings_pkey PRIMARY KEY (id);


--
-- Name: th_customers th_customers_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_customers
    ADD CONSTRAINT th_customers_phone_key UNIQUE (phone);


--
-- Name: th_customers th_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_customers
    ADD CONSTRAINT th_customers_pkey PRIMARY KEY (id);


--
-- Name: th_freight th_freight_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_freight
    ADD CONSTRAINT th_freight_pkey PRIMARY KEY (id);


--
-- Name: th_timeslots th_timeslots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_timeslots
    ADD CONSTRAINT th_timeslots_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_accounts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accounts_user_id ON public.accounts USING btree (user_id);


--
-- Name: idx_bookings_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_date ON public.bookings USING btree (date);


--
-- Name: idx_bookings_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_route_id ON public.bookings USING btree (route_id);


--
-- Name: idx_bookings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_status ON public.bookings USING btree (status);


--
-- Name: idx_bookings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_user_id ON public.bookings USING btree (user_id);


--
-- Name: idx_nh_products_send_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_send_date ON public.nh_products USING btree (send_date);


--
-- Name: idx_nh_products_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_status ON public.nh_products USING btree (status);


--
-- Name: idx_payments_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_booking_id ON public.payments USING btree (booking_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_productlogs_productid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productlogs_productid ON public."ProductLogs" USING btree ("productId");


--
-- Name: idx_products_senddate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_senddate ON public."Products" USING btree ("sendDate");


--
-- Name: idx_products_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_station ON public."Products" USING btree (station);


--
-- Name: idx_products_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_status ON public."Products" USING btree (status);


--
-- Name: idx_schedules_bus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_bus_id ON public.schedules USING btree (bus_id);


--
-- Name: idx_schedules_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_date ON public.schedules USING btree (date);


--
-- Name: idx_schedules_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_route_id ON public.schedules USING btree (route_id);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: idx_th_bookings_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_th_bookings_phone ON public.th_bookings USING btree (customer_phone);


--
-- Name: idx_th_bookings_timeslot; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_th_bookings_timeslot ON public.th_bookings USING btree (time_slot_id);


--
-- Name: idx_th_timeslots_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_th_timeslots_date ON public.th_timeslots USING btree (date);


--
-- Name: idx_th_timeslots_route; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_th_timeslots_route ON public.th_timeslots USING btree (route);


--
-- Name: accounts accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: bookings bookings_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules(id);


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_bus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_bus_id_fkey FOREIGN KEY (bus_id) REFERENCES public.buses(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: th_bookings th_bookings_time_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_bookings
    ADD CONSTRAINT th_bookings_time_slot_id_fkey FOREIGN KEY (time_slot_id) REFERENCES public.th_timeslots(id);


--
-- Name: th_freight th_freight_time_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.th_freight
    ADD CONSTRAINT th_freight_time_slot_id_fkey FOREIGN KEY (time_slot_id) REFERENCES public.th_timeslots(id);


--
-- PostgreSQL database dump complete
--

\unrestrict CWEQrp8j3hwO1xOPYOSVgqOpVpLe83VyqmFdm289o8KLioHIr6yAjf21FJ39dK9

