--
-- PostgreSQL database dump
--

\restrict eccRPF2wMRh3mlfaxCriY2jYKCIA8PwRG5QQ7SqKFxGHE1aqs7fCUdzXpnLYjZI

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

--
-- Name: update_nh_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_nh_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
          NEW."updatedAt" = NOW();
          RETURN NEW;
      END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Counters" (
    id integer NOT NULL,
    "counterKey" character varying(100) NOT NULL,
    station character varying(10) NOT NULL,
    "dateKey" character varying(10) NOT NULL,
    value integer DEFAULT 0,
    "lastUpdated" timestamp without time zone DEFAULT now()
);


--
-- Name: NH_Counters; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NH_Counters" AS
 SELECT id,
    "counterKey",
    station,
    "dateKey",
    value,
    "lastUpdated"
   FROM public."Counters";


--
-- Name: NH_Counters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NH_Counters_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NH_Counters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NH_Counters_id_seq" OWNED BY public."Counters".id;


--
-- Name: ProductLogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ProductLogs" (
    "logId" integer NOT NULL,
    "productId" character varying(50) NOT NULL,
    action character varying(20) NOT NULL,
    field character varying(50),
    "oldValue" text,
    "newValue" text,
    "changedBy" character varying(100),
    "changedAt" timestamp without time zone DEFAULT now(),
    "ipAddress" character varying(50)
);


--
-- Name: NH_ProductLogs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NH_ProductLogs" AS
 SELECT "logId",
    "productId",
    action,
    field,
    "oldValue",
    "newValue",
    "changedBy",
    "changedAt",
    "ipAddress"
   FROM public."ProductLogs";


--
-- Name: NH_ProductLogs_logId_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NH_ProductLogs_logId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NH_ProductLogs_logId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NH_ProductLogs_logId_seq" OWNED BY public."ProductLogs"."logId";


--
-- Name: Products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Products" (
    id character varying(50) NOT NULL,
    "senderName" character varying(100),
    "senderPhone" character varying(20),
    "senderStation" character varying(150) NOT NULL,
    "receiverName" character varying(100),
    "receiverPhone" character varying(20),
    station character varying(150) NOT NULL,
    "productType" character varying(200),
    quantity character varying(500),
    vehicle character varying(100),
    insurance numeric(18,2) DEFAULT 0,
    "totalAmount" numeric(18,2) DEFAULT 0,
    "paymentStatus" character varying(20) DEFAULT 'unpaid'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    "deliveryStatus" character varying(50) DEFAULT 'pending'::character varying,
    employee character varying(100),
    "createdBy" character varying(100),
    notes text,
    "sendDate" timestamp without time zone NOT NULL,
    "deliveredAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now(),
    "tongHopBookingId" integer,
    "syncedToTongHop" boolean DEFAULT false
);


--
-- Name: NH_Products; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NH_Products" AS
 SELECT id,
    "senderName",
    "senderPhone",
    "senderStation",
    "receiverName",
    "receiverPhone",
    station,
    "productType",
    quantity,
    vehicle,
    insurance,
    "totalAmount",
    "paymentStatus",
    status,
    "deliveryStatus",
    employee,
    "createdBy",
    notes,
    "sendDate",
    "deliveredAt",
    "createdAt",
    "updatedAt",
    "tongHopBookingId",
    "syncedToTongHop"
   FROM public."Products";


--
-- Name: Stations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Stations" (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    "fullName" character varying(150) NOT NULL,
    address character varying(255),
    phone character varying(20),
    region character varying(50),
    "isActive" boolean DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: NH_Stations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NH_Stations" AS
 SELECT id,
    code,
    name,
    "fullName",
    address,
    phone,
    region,
    "isActive",
    "createdAt",
    "updatedAt"
   FROM public."Stations";


--
-- Name: NH_Stations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NH_Stations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NH_Stations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NH_Stations_id_seq" OWNED BY public."Stations".id;


--
-- Name: Users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Users" (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    "fullName" character varying(100) NOT NULL,
    phone character varying(20),
    role character varying(20) DEFAULT 'employee'::character varying,
    station character varying(150),
    active boolean DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT now(),
    "updatedAt" timestamp without time zone DEFAULT now()
);


--
-- Name: NH_Users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NH_Users" AS
 SELECT id,
    username,
    password,
    "fullName",
    phone,
    role,
    station,
    active,
    "createdAt",
    "updatedAt"
   FROM public."Users";


--
-- Name: NH_Users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NH_Users_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NH_Users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NH_Users_id_seq" OWNED BY public."Users".id;


--
-- Name: NhapHangUsers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."NhapHangUsers" AS
 SELECT id,
    username,
    password,
    "fullName",
    phone,
    role,
    station,
    active,
    "createdAt",
    "updatedAt"
   FROM public."Users";


--
-- Name: Counters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Counters" ALTER COLUMN id SET DEFAULT nextval('public."NH_Counters_id_seq"'::regclass);


--
-- Name: ProductLogs logId; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductLogs" ALTER COLUMN "logId" SET DEFAULT nextval('public."NH_ProductLogs_logId_seq"'::regclass);


--
-- Name: Stations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations" ALTER COLUMN id SET DEFAULT nextval('public."NH_Stations_id_seq"'::regclass);


--
-- Name: Users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Users" ALTER COLUMN id SET DEFAULT nextval('public."NH_Users_id_seq"'::regclass);


--
-- Data for Name: Counters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Counters" (id, "counterKey", station, "dateKey", value, "lastUpdated") FROM stdin;
1	counter_01_180126	01	180126	1	2026-01-18 05:22:22.116955
2	counter_01_190126	01	190126	1	2026-01-18 22:42:15.549856
3	counter_01_220126	01	220126	1	2026-01-22 13:58:51.459478
100	counter_11_290326	11	290326	1	2026-03-28 22:47:29.40657
151	counter_03_090426	03	090426	9	2026-04-09 03:34:54.755535
170	counter_06_100426	06	100426	1	2026-04-09 22:51:25.069201
92	counter_03_290326	03	290326	8	2026-03-29 00:53:36.970453
171	counter_13_100426	13	100426	1	2026-04-09 22:51:33.756429
99	counter_00_290326	00	290326	5	2026-03-29 03:06:25.800912
109	counter_07_010426	07	010426	1	2026-04-01 09:14:52.680077
16	counter_03_240126	03	240126	1	2026-01-24 09:31:01.36264
108	counter_03_010426	03	010426	2	2026-04-01 09:38:38.933587
111	counter_01_010426	01	010426	1	2026-04-01 09:47:27.55874
112	counter_10_030426	10	030426	2	2026-04-02 21:59:50.177677
114	counter_03_030426	03	030426	2	2026-04-02 22:00:06.793754
4	counter_01_240126	01	240126	19	2026-01-24 14:04:41.987813
116	counter_00_030426	00	030426	1	2026-04-02 22:01:00.299404
24	counter_01_250126	01	250126	9	2026-01-25 11:06:24.991591
33	counter_03_260126	03	260126	1	2026-01-25 22:30:55.183614
34	counter_01_260126	01	260126	2	2026-01-26 00:59:53.595713
36	counter_01_310126	01	310126	5	2026-01-31 11:03:56.933266
41	counter_01_130226	01	130226	1	2026-02-13 08:38:03.127016
42	counter_01_170226	01	170226	1	2026-02-17 11:48:00.445965
178	counter_08_100426	08	100426	1	2026-04-09 23:05:30.893294
119	counter_09_060426	09	060426	4	2026-04-06 01:07:17.944915
122	counter_10_060426	10	060426	2	2026-04-06 01:07:27.005925
44	counter_01_190226	01	190226	8	2026-02-19 05:19:12.415309
52	counter_03_190226	03	190226	1	2026-02-19 05:41:43.566808
53	counter_01_220326	01	220326	2	2026-03-22 07:42:32.615263
55	counter_01_230326	01	230326	2	2026-03-22 23:29:24.408786
134	counter_13_060426	13	060426	1	2026-04-06 01:13:30.994933
57	counter_01_240326	01	240326	5	2026-03-24 06:45:33.888111
62	counter_03_240326	03	240326	1	2026-03-24 06:53:24.644344
63	counter_05_240326	05	240326	1	2026-03-24 06:53:39.425395
64	counter_06_240326	06	240326	1	2026-03-24 06:54:18.078846
65	counter_10_280326	10	280326	2	2026-03-28 00:28:34.872936
67	counter_11_280326	11	280326	3	2026-03-28 08:36:13.012362
72	counter_09_280326	09	280326	1	2026-03-28 08:36:36.127528
73	counter_00_280326	00	280326	1	2026-03-28 08:37:11.420085
117	counter_00_060426	00	060426	6	2026-04-06 01:15:00.835476
186	counter_11_100426	11	100426	1	2026-04-09 23:06:54.292217
180	counter_00_100426	00	100426	3	2026-04-10 05:26:15.056423
120	counter_03_060426	03	060426	17	2026-04-06 01:17:51.960696
126	counter_04_060426	04	060426	2	2026-04-06 01:18:06.315231
149	counter_11_060426	11	060426	2	2026-04-06 01:18:28.480061
169	counter_10_100426	10	100426	4	2026-04-10 05:30:26.032322
69	counter_03_280326	03	280326	19	2026-03-28 09:48:42.526169
91	counter_10_290326	10	290326	1	2026-03-28 22:45:42.089958
154	counter_04_090426	04	090426	1	2026-04-09 03:30:54.995261
172	counter_03_100426	03	100426	16	2026-04-10 06:56:30.127011
97	counter_08_290326	08	290326	1	2026-03-28 22:46:40.92956
98	counter_09_290326	09	290326	1	2026-03-28 22:46:57.554319
157	counter_10_090426	10	090426	3	2026-04-09 03:32:31.506033
155	counter_00_090426	00	090426	4	2026-04-09 03:34:02.073533
166	counter_08_090426	08	090426	1	2026-04-09 03:34:25.489738
\.


--
-- Data for Name: ProductLogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ProductLogs" ("logId", "productId", action, field, "oldValue", "newValue", "changedBy", "changedAt", "ipAddress") FROM stdin;
1	260118.0101	create	product_info	\N	{"receiverName":"Test Receiver","receiverPhone":"0909876543","totalAmount":50000}	system	2026-01-18 05:22:22.266222	::1
2	260119.0101	create	product_info	\N	{"receiverName":"Minh","receiverPhone":"0908724146","totalAmount":0}	system	2026-01-18 22:42:15.724427	::1
3	260122.0101	create	product_info	\N	{"receiverName":"Test Receiver","receiverPhone":"0987654321","totalAmount":50000}	test	2026-01-22 13:58:51.616676	::1
4	260124.0101	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0908724146","totalAmount":500000}	Staff An Đông	2026-01-24 08:16:01.717573	42.116.77.152
5	260124.0102	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0908724146","totalAmount":500000}	Staff An Đông	2026-01-24 08:17:02.39247	42.116.77.152
6	260124.0103	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 08:29:23.214816	42.116.77.152
7	260124.0104	create	product_info	\N	{"receiverName":"Nâu tbom","receiverPhone":"0908724146","totalAmount":100000}	Staff An Đông	2026-01-24 08:36:19.818915	42.113.126.37
8	260124.0105	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 08:41:03.415867	42.116.77.152
9	260124.0106	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 08:42:49.782124	42.116.77.152
10	260124.0107	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 08:43:04.7302	42.116.77.152
11	260124.0108	create	product_info	\N	{"receiverName":"Nâu tbom","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-01-24 08:45:39.609182	42.113.126.37
12	260124.0109	create	product_info	\N	{"receiverName":"Nâu tbom","receiverPhone":"0908724146","totalAmount":100000}	Staff An Đông	2026-01-24 08:46:16.268239	42.113.126.37
13	260124.0110	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0908724146","totalAmount":1000000}	Staff An Đông	2026-01-24 09:26:09.139684	42.113.126.37
14	260124.0111	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 09:27:11.208167	42.116.77.152
15	260124.0112	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0772607305","totalAmount":100000}	Staff An Đông	2026-01-24 09:28:58.221628	42.113.126.37
16	260124.0301	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0908724146","totalAmount":200000}	Staff Long Khánh	2026-01-24 09:31:01.846415	42.113.126.37
17	260124.0113	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 09:35:11.806781	42.116.77.152
18	260124.0114	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 13:30:55.021032	42.116.77.152
19	260124.0115	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 13:46:41.072809	42.116.77.152
20	260124.0116	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 13:55:00.110983	42.116.77.152
21	260124.0117	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 13:58:10.903462	42.116.77.152
22	260124.0118	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 13:58:30.557905	42.116.77.152
23	260124.0119	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":100000}	Staff An Đông	2026-01-24 14:04:42.508571	42.116.77.152
24	260125.0101	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":1000000}	Staff An Đông	2026-01-24 22:20:49.509044	42.116.77.152
25	260125.0102	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":1000000}	Staff An Đông	2026-01-24 22:42:47.937734	42.116.77.152
26	260125.0103	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":1000000}	Staff An Đông	2026-01-24 22:50:32.923489	42.116.77.152
27	260125.0104	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":1000000}	Staff An Đông	2026-01-24 23:17:40.180409	42.116.77.152
28	260125.0105	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-25 06:28:17.026931	42.116.77.152
29	260125.0106	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-25 09:01:50.216936	42.116.77.152
30	260125.0107	create	product_info	\N	{"receiverName":"minh qbien","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-25 09:05:36.577861	42.116.77.152
31	260125.0108	create	product_info	\N	{"receiverName":"Nâu","receiverPhone":"3232","totalAmount":8000000}	Staff An Đông	2026-01-25 11:05:43.452014	42.117.84.204
32	260125.0109	create	product_info	\N	{"receiverName":"Nâu","receiverPhone":"3232","totalAmount":800000}	Staff An Đông	2026-01-25 11:06:25.422526	42.117.84.204
33	260126.0301	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0877414135","totalAmount":200000}	Staff Long Khánh	2026-01-25 22:30:55.635866	42.116.77.152
34	260126.0101	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-25 22:31:25.310705	42.116.77.152
35	260126.0101	update	2 fields	[{"totalAmount":"200000.00"},{"deliveryStatus":"pending"}]	[{"totalAmount":200000},{"deliveryStatus":"delivered"}]	system	2026-01-25 22:31:58.820552	42.116.77.152
36	260126.0102	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-26 00:59:54.044668	42.116.77.152
37	260131.0101	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-31 10:45:55.762363	42.116.77.152
38	260131.0102	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-01-31 10:46:26.147158	42.116.77.152
39	260131.0103	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-01-31 10:47:03.381679	42.116.77.152
40	260131.0104	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"07726073050","totalAmount":200000}	Staff An Đông	2026-01-31 11:01:41.359694	42.116.77.152
41	260131.0105	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-01-31 11:03:57.37249	42.116.77.152
42	260213.0101	create	product_info	\N	{"receiverName":"vu tbom","receiverPhone":"0908724146","totalAmount":10000000000}	Staff An Đông	2026-02-13 08:38:03.659068	113.22.174.63
43	260217.0101	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-17 11:48:00.897168	14.179.45.207
44	260219.0101	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 04:33:40.929515	183.81.19.151
45	260219.0102	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 04:48:42.875139	183.81.19.151
46	260219.0103	create	product_info	\N	{"receiverName":"minh tbom","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 04:49:17.211678	183.81.19.151
47	260219.0104	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 05:07:59.852652	183.81.19.151
48	260219.0105	create	product_info	\N	{"receiverName":"minh sthao","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 05:08:53.204939	183.81.19.151
49	260219.0106	create	product_info	\N	{"receiverName":"minh qbien","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 05:09:46.516271	183.81.19.151
50	260219.0107	create	product_info	\N	{"receiverName":"minh tbomtb","receiverPhone":"0877414135","totalAmount":200000}	Staff An Đông	2026-02-19 05:18:12.096619	183.81.19.151
51	260219.0108	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-02-19 05:19:12.837684	183.81.19.151
52	260219.0301	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff Long Khánh	2026-02-19 05:41:44.106989	183.81.19.151
53	260322.0101	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-03-22 07:37:03.587146	1.53.56.225
54	260322.0101	update	5 fields	[{"senderName":null},{"senderPhone":null},{"quantity":null},{"vehicle":null},{"totalAmount":"200000.00"}]	[{"senderName":""},{"senderPhone":""},{"quantity":""},{"vehicle":"26025"},{"totalAmount":200000}]	system	2026-03-22 07:40:23.92729	1.53.56.225
55	260322.0102	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-03-22 07:42:33.079716	1.53.56.225
56	260322.0102	update	5 fields	[{"senderName":null},{"senderPhone":null},{"quantity":null},{"vehicle":"01057"},{"totalAmount":"200000.00"}]	[{"senderName":""},{"senderPhone":""},{"quantity":""},{"vehicle":"26025"},{"totalAmount":200000}]	system	2026-03-22 07:46:23.309331	1.53.56.225
57	260323.0101	create	product_info	\N	{"receiverName":"cô lưu","receiverPhone":"8878","totalAmount":1}	Staff An Đông	2026-03-22 23:28:25.837867	42.119.79.188
58	260323.0102	create	product_info	\N	{"receiverName":"hiền","receiverPhone":"0073","totalAmount":120000}	Staff An Đông	2026-03-22 23:29:24.845032	42.119.79.188
59	260323.0102	update	6 fields	[{"senderName":null},{"senderPhone":null},{"receiverPhone":"0073"},{"quantity":null},{"vehicle":null},{"totalAmount":"120000.00"}]	[{"senderName":""},{"senderPhone":""},{"receiverPhone":"0074"},{"quantity":""},{"vehicle":" "},{"totalAmount":120000}]	system	2026-03-22 23:30:08.103701	42.119.79.188
60	260323.0102	update	2 fields	[{"receiverPhone":"0074"},{"totalAmount":"120000.00"}]	[{"receiverPhone":"0073"},{"totalAmount":120000}]	system	2026-03-22 23:30:14.301009	42.119.79.188
61	260323.0102	update	2 fields	[{"vehicle":" "},{"totalAmount":"120000.00"}]	[{"vehicle":"26879"},{"totalAmount":120000}]	system	2026-03-22 23:30:35.088893	42.119.79.188
62	260323.0101	update	3 fields	[{"totalAmount":"1.00"},{"paymentStatus":"unpaid"},{"deliveryStatus":"pending"}]	[{"totalAmount":100000},{"paymentStatus":"paid"},{"deliveryStatus":"delivered"}]	system	2026-03-22 23:31:55.249766	42.119.79.188
63	260323.0102	update	2 fields	[{"totalAmount":"120000.00"},{"deliveryStatus":"pending"}]	[{"totalAmount":120000},{"deliveryStatus":"delivered"}]	system	2026-03-22 23:32:04.85382	42.119.79.188
64	260213.0101	delete	product_info	{"receiverName":"vu tbom","receiverPhone":"0908724146","totalAmount":"10000000000.00"}	\N	system	2026-03-24 01:22:44.333777	113.185.73.20
65	260324.0101	create	product_info	\N	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":200000}	Staff An Đông	2026-03-24 01:34:00.541444	113.185.73.20
66	260324.0102	create	product_info	\N	{"receiverName":"Minh bưu điện trảng bom","receiverPhone":"0877414135","totalAmount":160000}	Staff An Đông	2026-03-24 01:34:18.018615	113.185.73.20
67	260324.0103	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0205","totalAmount":100000}	Staff An Đông	2026-03-24 01:55:37.17194	113.185.73.20
68	260324.0101	delete	product_info	{"receiverName":"minh tco","receiverPhone":"0908724146","totalAmount":"200000.00"}	\N	Staff An Đông	2026-03-24 02:04:16.331675	113.185.73.20
69	260324.0104	create	product_info	\N	{"receiverName":"Minh bưu điện trảng bom","receiverPhone":"0908724146","totalAmount":100000}	Staff An Đông	2026-03-24 04:47:26.776825	113.185.85.51
70	260324.0103	update	5 fields	[{"senderName":null},{"senderPhone":null},{"quantity":null},{"vehicle":null},{"totalAmount":"100000.00"}]	[{"senderName":""},{"senderPhone":""},{"quantity":""},{"vehicle":"01057"},{"totalAmount":10000000}]	Staff An Đông	2026-03-24 04:48:32.508166	113.185.85.51
71	260324.0102	update	5 fields	[{"senderName":null},{"senderPhone":null},{"quantity":null},{"vehicle":null},{"totalAmount":"160000.00"}]	[{"senderName":""},{"senderPhone":""},{"quantity":""},{"vehicle":"01785"},{"totalAmount":16000000}]	Staff An Đông	2026-03-24 04:48:40.65743	113.185.85.51
72	260324.0103	update	totalAmount	10000000.00	160000	Staff An Đông	2026-03-24 04:48:53.773512	113.185.85.51
73	260324.0102	update	2 fields	[{"quantity":""},{"totalAmount":"16000000.00"}]	[{"quantity":"10k"},{"totalAmount":1600000}]	Staff An Đông	2026-03-24 04:49:04.19748	113.185.85.51
74	260324.0105	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0205","totalAmount":1}	Staff An Đông	2026-03-24 06:45:34.574731	113.185.78.236
75	260324.0301	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0205","totalAmount":1}	Staff An Đông	2026-03-24 06:53:25.150066	113.185.85.51
76	260324.0501	create	product_info	\N	{"receiverName":"minh","receiverPhone":"2341","totalAmount":100000}	Staff An Đông	2026-03-24 06:53:39.872609	113.185.85.51
77	260324.0601	create	product_info	\N	{"receiverName":"minh","receiverPhone":"0205","totalAmount":1}	Staff An Đông	2026-03-24 06:54:18.540881	113.185.85.51
78	260324.0601	delete	product_info	{"receiverName":"minh","receiverPhone":"0205","totalAmount":"1.00"}	\N	Staff An Đông	2026-03-24 06:54:34.530138	113.185.85.51
79	260324.0301	cancel	status	pending	cancelled	Staff An Đông	2026-03-24 07:00:59.32251	113.185.78.236
80	260324.0501	cancel	status	pending	cancelled - trùng đơn	Staff An Đông	2026-03-24 07:03:09.649229	113.185.78.236
81	260324.0102	cancel	status	pending	cancelled - khách hủy	Staff An Đông	2026-03-24 07:03:23.820033	113.185.78.236
82	260328.1001	create	product_info	\N	{"receiverName":"phượng bảo hòa","receiverPhone":"5717","totalAmount":120000}	Staff An Đông	2026-03-28 00:24:50.089178	1.53.42.52
83	260328.1001	cancel	status	pending	cancelled	Staff An Đông	2026-03-28 00:28:17.405529	42.116.178.183
84	260328.1002	create	product_info	\N	{"receiverName":"phượng bảo hòa","receiverPhone":"5717","totalAmount":120000}	Staff An Đông	2026-03-28 00:28:35.320585	42.116.178.183
85	260328.1101	create	product_info	\N	{"receiverName":"liên hương","receiverPhone":"8635","totalAmount":120000}	Staff An Đông	2026-03-28 00:28:58.500683	42.116.178.183
86	260328.1102	create	product_info	\N	{"receiverName":"huy","receiverPhone":"6703","totalAmount":80000}	Staff An Đông	2026-03-28 00:29:57.897101	42.116.178.183
87	260328.1002	cancel	status	pending	cancelled	Staff An Đông	2026-03-28 00:31:59.613794	1.53.42.52
88	260328.1101	cancel	status	pending	cancelled	Staff An Đông	2026-03-28 00:32:00.901809	1.53.42.52
89	260328.1102	cancel	status	pending	cancelled	Staff An Đông	2026-03-28 00:32:01.35988	1.53.42.52
90	260328.0301	create	product_info	\N	{"receiverName":"phượng bảo hòa","receiverPhone":"5717","totalAmount":100000}	Staff An Đông	2026-03-28 00:32:17.928193	1.53.42.52
91	260328.0301	update	6 fields	[{"senderName":null},{"senderPhone":null},{"station":"03 - LONG KHÁNH"},{"quantity":null},{"vehicle":null},{"totalAmount":"100000.00"}]	[{"senderName":""},{"senderPhone":""},{"station":"10 - ÔNG ĐÔN"},{"quantity":""},{"vehicle":" "},{"totalAmount":10000000}]	Staff An Đông	2026-03-28 00:32:24.543703	1.53.42.52
92	260328.0301	update	totalAmount	10000000.00	1000000	Staff An Đông	2026-03-28 07:23:24.902857	1.53.42.52
93	260328.0301	update	2 fields	[{"quantity":""},{"totalAmount":"1000000.00"}]	[{"quantity":"2t"},{"totalAmount":100000000}]	Staff An Đông	2026-03-28 08:24:02.03528	1.53.42.52
94	260328.0302	create	product_info	\N	{"receiverName":"cô lưu","receiverPhone":"8878","totalAmount":1}	Staff An Đông	2026-03-28 08:34:13.99404	1.53.42.52
95	260328.113	create	product_info	\N	{"receiverName":"huy","receiverPhone":"6703","totalAmount":100000}	Staff An Đông	2026-03-28 08:36:13.461112	1.53.42.52
96	260328.091	create	product_info	\N	{"receiverName":"hiếu","receiverPhone":"1449","totalAmount":120000}	Staff An Đông	2026-03-28 08:36:36.585147	1.53.42.52
97	260328.001	create	product_info	\N	{"receiverName":"thảo trị an","receiverPhone":"0977112382","totalAmount":80000}	Staff An Đông	2026-03-28 08:37:11.862576	1.53.42.52
98	260328.033	create	product_info	\N	{"receiverName":"huy","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 08:38:53.559796	1.53.42.52
99	260328.034	create	product_info	\N	{"receiverName":"bính hạnh","receiverPhone":"9767","totalAmount":1}	Staff An Đông	2026-03-28 08:40:04.029001	42.116.178.183
100	260328.035	create	product_info	\N	{"receiverName":"MINH","receiverPhone":"6060","totalAmount":1}	Staff An Đông	2026-03-28 08:48:18.810542	1.53.42.52
101	260328.036	create	product_info	\N	{"receiverName":"HIẾU","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 08:59:51.627225	1.53.42.52
102	260328.037	create	product_info	\N	{"receiverName":"HIẾU","receiverPhone":"5290","totalAmount":1}	Staff An Đông	2026-03-28 09:00:03.847443	1.53.42.52
103	260328.038	create	product_info	\N	{"receiverName":"HIẾU","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 09:01:13.605894	1.53.42.52
104	260328.039	create	product_info	\N	{"receiverName":"hiếu","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 09:02:27.050177	1.53.42.52
105	260328.0310	create	product_info	\N	{"receiverName":"PHƯƠNG","receiverPhone":"5296","totalAmount":1}	Staff An Đông	2026-03-28 09:02:27.794384	1.53.42.52
106	260328.0311	create	product_info	\N	{"receiverName":"HEHE","receiverPhone":"0834554020","totalAmount":1}	Staff An Đông	2026-03-28 09:17:58.29465	1.53.42.52
107	260328.0312	create	product_info	\N	{"receiverName":"HIẾU","receiverPhone":"1123","totalAmount":1}	Staff An Đông	2026-03-28 09:18:09.271014	1.53.42.52
108	260328.0301	update	totalAmount	100000000.00	100000	Staff An Đông	2026-03-28 09:22:08.709882	1.53.42.52
109	260328.0311	update	vehicle	\N	04671	Staff An Đông	2026-03-28 09:23:21.480744	1.53.42.52
110	260328.0312	update	vehicle	\N	04671	Staff An Đông	2026-03-28 09:23:21.797793	1.53.42.52
111	260328.0313	create	product_info	\N	{"receiverName":"HUNGF","receiverPhone":"6326","totalAmount":1}	Staff An Đông	2026-03-28 09:32:36.134744	1.53.42.52
112	260328.0314	create	product_info	\N	{"receiverName":"HIEU","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 09:32:44.111148	1.53.42.52
113	260328.0315	create	product_info	\N	{"receiverName":"HOANG","receiverPhone":"8433","totalAmount":1}	Staff An Đông	2026-03-28 09:32:53.168249	1.53.42.52
114	260328.0316	create	product_info	\N	{"receiverName":"HOANG","receiverPhone":"8433","totalAmount":1}	Staff An Đông	2026-03-28 09:39:30.619125	1.53.42.52
115	260328.0317	create	product_info	\N	{"receiverName":"HIẾU","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-03-28 09:40:09.0426	42.116.178.183
116	260328.0318	create	product_info	\N	{"receiverName":"NGAAN","receiverPhone":"8468","totalAmount":1}	Staff An Đông	2026-03-28 09:44:47.583151	1.53.42.52
117	260328.0319	create	product_info	\N	{"receiverName":"TUYẾT NGÂN","receiverPhone":"8468","totalAmount":1}	Staff An Đông	2026-03-28 09:48:42.974652	1.53.42.52
118	260329.101	create	product_info	\N	{"receiverName":"PHƯƠNG BẢO HÒA","receiverPhone":"5717","totalAmount":120000}	Staff An Đông	2026-03-28 22:45:42.644668	183.80.152.238
119	260329.031	create	product_info	\N	{"receiverName":"QUỐC","receiverPhone":"9449","totalAmount":1}	Staff An Đông	2026-03-28 22:45:48.963545	183.80.152.238
120	260329.032	create	product_info	\N	{"receiverName":"LƯU AN","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-03-28 22:45:58.277995	183.80.152.238
121	260329.033	create	product_info	\N	{"receiverName":"KIỂNG THÀNH","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-03-28 22:46:13.825393	183.80.152.238
122	260329.034	create	product_info	\N	{"receiverName":"HIẾU MÌ","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-03-28 22:46:22.279622	183.80.152.238
123	260329.035	create	product_info	\N	{"receiverName":"HỒNG","receiverPhone":"5290","totalAmount":1}	Staff An Đông	2026-03-28 22:46:30.592139	183.80.152.238
124	260329.081	create	product_info	\N	{"receiverName":"THÚY","receiverPhone":"5286","totalAmount":80000}	Staff An Đông	2026-03-28 22:46:41.344697	183.80.152.238
125	260329.091	create	product_info	\N	{"receiverName":"THẮNG","receiverPhone":"0940","totalAmount":340000}	Staff An Đông	2026-03-28 22:46:58.001369	183.80.152.238
126	260329.001	create	product_info	\N	{"receiverName":"VÔ DANH KM41","receiverPhone":"1","totalAmount":100000}	Staff An Đông	2026-03-28 22:47:17.116514	183.80.152.238
127	260329.111	create	product_info	\N	{"receiverName":"VINH","receiverPhone":"5993","totalAmount":80000}	Staff An Đông	2026-03-28 22:47:29.869263	183.80.152.238
128	260329.036	create	product_info	\N	{"receiverName":"CÔ BA","receiverPhone":"2744","totalAmount":1}	Staff An Đông	2026-03-28 22:47:39.584185	183.80.152.238
129	260329.037	create	product_info	\N	{"receiverName":"THẢO 60 CĂN","receiverPhone":"1","totalAmount":60000}	Staff An Đông	2026-03-28 22:47:49.251187	183.80.152.238
130	260329.002	create	product_info	\N	{"receiverName":"NGỌC TBOM","receiverPhone":"0967503440","totalAmount":80000}	Staff An Đông	2026-03-28 22:48:29.855624	183.80.152.238
131	260329.037	update	vehicle	\N	04627	Staff An Đông	2026-03-28 23:12:32.439288	183.80.152.238
132	260329.036	update	vehicle	\N	04627	Staff An Đông	2026-03-28 23:12:32.490189	183.80.152.238
133	260329.002	update	vehicle	\N	04627	Staff An Đông	2026-03-28 23:12:32.514093	183.80.152.238
134	260329.003	create	product_info	\N	{"receiverName":"thảo trị an","receiverPhone":"0977112382","totalAmount":80000}	Staff An Đông	2026-03-29 00:49:28.099632	183.80.152.238
135	260329.038	create	product_info	\N	{"receiverName":"trùng dương","receiverPhone":"5056","totalAmount":1}	Staff An Đông	2026-03-29 00:53:37.39161	183.80.152.238
136	260329.004	create	product_info	\N	{"receiverName":"thúy đào 30/4","receiverPhone":"0979189663","totalAmount":100000}	Staff An Đông	2026-03-29 03:05:36.773385	101.99.32.55
137	260329.005	create	product_info	\N	{"receiverName":"thảo trị an","receiverPhone":"0977112382","totalAmount":80000}	Staff An Đông	2026-03-29 03:06:26.251985	101.99.32.55
138	260329.038	update	3 fields	[{"totalAmount":"1.00"},{"paymentStatus":"unpaid"},{"deliveryStatus":"pending"}]	[{"totalAmount":50000},{"paymentStatus":"paid"},{"deliveryStatus":"delivered"}]	Staff Long Khánh	2026-03-29 03:08:53.62875	101.99.32.55
139	260329.038	update	totalAmount	50000.00	50000	Staff Long Khánh	2026-03-29 03:08:54.312442	101.99.32.55
140	260329.036	update	3 fields	[{"totalAmount":"1.00"},{"paymentStatus":"unpaid"},{"deliveryStatus":"pending"}]	[{"totalAmount":70000},{"paymentStatus":"paid"},{"deliveryStatus":"delivered"}]	Staff Long Khánh	2026-03-29 03:09:13.317986	101.99.32.55
141	260401.031	create	product_info	\N	{"receiverName":"đề","receiverPhone":"5579","totalAmount":1}	Staff An Đông	2026-04-01 09:14:32.59622	113.22.81.180
142	260401.071	create	product_info	\N	{"receiverName":"nguyên","receiverPhone":"1173","totalAmount":70000}	Staff An Đông	2026-04-01 09:14:53.122181	113.22.81.180
143	260401.032	create	product_info	\N	{"receiverName":"HÀ DUNG","receiverPhone":"2950","totalAmount":1}	Staff An Đông	2026-04-01 09:38:39.486891	113.22.81.180
144	260401.011	create	product_info	\N	{"receiverName":"trung kim yên","receiverPhone":"6202","totalAmount":100000}	Staff Long Khánh	2026-04-01 09:47:28.026591	113.22.81.180
145	260403.101	create	product_info	\N	{"receiverName":"hường mã vôi","receiverPhone":"1581","totalAmount":360000}	Staff An Đông	2026-04-02 21:55:10.852513	113.23.83.224
146	260403.102	create	product_info	\N	{"receiverName":"phượng bảo hòa","receiverPhone":"5717","totalAmount":240000}	Staff An Đông	2026-04-02 21:59:50.65232	113.23.83.224
147	260403.031	create	product_info	\N	{"receiverName":"quốc","receiverPhone":"9449","totalAmount":1}	Staff An Đông	2026-04-02 21:59:56.839702	113.23.83.224
148	260403.032	create	product_info	\N	{"receiverName":"lưu an","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-02 22:00:07.248997	113.23.83.224
149	260403.001	create	product_info	\N	{"receiverName":"ngọc tbom","receiverPhone":"0967503440","totalAmount":100000}	Staff An Đông	2026-04-02 22:01:00.743513	113.23.83.224
150	260406.001	create	product_info	\N	{"receiverName":"thảo trị an","receiverPhone":"0977112382","totalAmount":80000}	Staff Long Khánh	2026-04-05 23:49:23.678092	42.118.167.44
151	260406.002	create	product_info	\N	{"receiverName":"ngọc tbom","receiverPhone":"0967503440","totalAmount":80000}	Staff Long Khánh	2026-04-05 23:55:00.018086	42.118.167.44
152	260406.091	create	product_info	\N	{"receiverName":"thắng","receiverPhone":"0940","totalAmount":240000}	Staff Long Khánh	2026-04-06 01:01:01.07726	42.118.167.44
153	260406.031	create	product_info	\N	{"receiverName":"bính hạnh","receiverPhone":"9767","totalAmount":1}	Staff Long Khánh	2026-04-06 01:01:23.51279	42.118.167.44
154	260406.092	create	product_info	\N	{"receiverName":"thắng","receiverPhone":"0940","totalAmount":120000}	Staff Long Khánh	2026-04-06 01:01:35.456826	42.118.167.44
155	260406.101	create	product_info	\N	{"receiverName":"nhi bảo hòa","receiverPhone":"5717","totalAmount":120000}	Staff Long Khánh	2026-04-06 01:01:41.134708	42.118.167.44
156	260406.032	create	product_info	\N	{"receiverName":"quốc","receiverPhone":"9449","totalAmount":1}	Staff Long Khánh	2026-04-06 01:01:49.296867	42.118.167.44
157	260406.033	create	product_info	\N	{"receiverName":"hiếu mì","receiverPhone":"1","totalAmount":1}	Staff Long Khánh	2026-04-06 01:01:54.174348	42.118.167.44
158	260406.034	create	product_info	\N	{"receiverName":"như","receiverPhone":"1123","totalAmount":1}	Staff Long Khánh	2026-04-06 01:02:04.045158	42.118.167.44
159	260406.041	create	product_info	\N	{"receiverName":"vdanh km41","receiverPhone":"1","totalAmount":120000}	Staff Long Khánh	2026-04-06 01:02:19.893259	42.118.167.44
160	260406.093	create	product_info	\N	{"receiverName":"thắng","receiverPhone":"0940","totalAmount":240000}	Staff An Đông	2026-04-06 01:03:16.827687	42.118.167.44
161	260406.035	create	product_info	\N	{"receiverName":"quốc","receiverPhone":"9449","totalAmount":1}	Staff An Đông	2026-04-06 01:03:55.326607	42.118.167.44
162	260406.036	create	product_info	\N	{"receiverName":"hiếu mì","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-06 01:06:45.184525	42.118.167.44
163	260406.094	create	product_info	\N	{"receiverName":"thắng","receiverPhone":"0940","totalAmount":120000}	Staff An Đông	2026-04-06 01:07:18.399297	42.118.167.44
164	260406.102	create	product_info	\N	{"receiverName":"nhi bảo hòa","receiverPhone":"5717","totalAmount":120000}	Staff An Đông	2026-04-06 01:07:27.464646	42.118.167.44
165	260406.003	create	product_info	\N	{"receiverName":"vdanh km41","receiverPhone":"0383399204","totalAmount":120000}	Staff An Đông	2026-04-06 01:07:53.508566	42.118.167.44
166	260406.037	create	product_info	\N	{"receiverName":"bính hạnh","receiverPhone":"9767","totalAmount":1}	Staff An Đông	2026-04-06 01:08:17.82584	42.118.167.44
167	260406.038	create	product_info	\N	{"receiverName":"như","receiverPhone":"1123","totalAmount":1}	Staff An Đông	2026-04-06 01:13:42.631277	42.118.167.44
168	260406.039	create	product_info	\N	{"receiverName":"minh ngọc","receiverPhone":"1357","totalAmount":1}	Staff An Đông	2026-04-06 01:13:50.122843	42.118.167.44
169	260406.004	create	product_info	\N	{"receiverName":"công thanh hóa","receiverPhone":"0911854535","totalAmount":80000}	Staff An Đông	2026-04-06 01:14:18.631366	42.118.167.44
170	260406.005	create	product_info	\N	{"receiverName":"ngọc tbom","receiverPhone":"0967503440","totalAmount":240000}	Staff An Đông	2026-04-06 01:14:32.351409	42.118.167.44
171	260406.005	update	4 fields	[{"senderName":null},{"senderPhone":null},{"vehicle":null},{"totalAmount":"240000.00"}]	[{"senderName":""},{"senderPhone":""},{"vehicle":" "},{"totalAmount":160000}]	Staff An Đông	2026-04-06 01:14:39.276636	42.118.167.44
172	260406.006	create	product_info	\N	{"receiverName":"xuân ttam","receiverPhone":"0977687057","totalAmount":80000}	Staff An Đông	2026-04-06 01:15:01.28083	42.118.167.44
173	260406.0310	create	product_info	\N	{"receiverName":"tuấn trân","receiverPhone":"7131","totalAmount":1}	Staff An Đông	2026-04-06 01:15:25.068769	42.118.167.44
174	260406.0311	create	product_info	\N	{"receiverName":"dũng","receiverPhone":"0336","totalAmount":1}	Staff An Đông	2026-04-06 01:15:31.647392	42.118.167.44
175	260406.0312	create	product_info	\N	{"receiverName":"lai","receiverPhone":"2418","totalAmount":1}	Staff An Đông	2026-04-06 01:15:38.430023	42.118.167.44
176	260406.0313	create	product_info	\N	{"receiverName":"hùng","receiverPhone":"5121","totalAmount":1}	Staff An Đông	2026-04-06 01:15:52.426876	42.118.167.44
177	260406.0313	update	6 fields	[{"senderName":null},{"senderPhone":null},{"productType":"03 - Thùng"},{"quantity":null},{"vehicle":null},{"totalAmount":"1.00"}]	[{"senderName":""},{"senderPhone":""},{"productType":"15 - Thùng xốp"},{"quantity":""},{"vehicle":" "},{"totalAmount":100}]	Staff An Đông	2026-04-06 01:15:59.618015	42.118.167.44
178	260406.0314	create	product_info	\N	{"receiverName":"hải","receiverPhone":"6783","totalAmount":1}	Staff An Đông	2026-04-06 01:16:43.762428	42.118.167.44
179	260406.0313	update	totalAmount	100.00	1	Staff An Đông	2026-04-06 01:16:46.85847	42.118.167.44
180	260406.0314	update	7 fields	[{"senderName":null},{"senderPhone":null},{"station":"03 - LONG KHÁNH"},{"quantity":null},{"vehicle":null},{"totalAmount":"1.00"},{"paymentStatus":"unpaid"}]	[{"senderName":""},{"senderPhone":""},{"station":"04 - TRẠM 97"},{"quantity":""},{"vehicle":" "},{"totalAmount":40000},{"paymentStatus":"paid"}]	Staff An Đông	2026-04-06 01:17:11.905964	42.118.167.44
181	260406.0315	create	product_info	\N	{"receiverName":"thi","receiverPhone":"7435","totalAmount":1}	Staff An Đông	2026-04-06 01:17:22.171044	42.118.167.44
182	260406.0316	create	product_info	\N	{"receiverName":"thư","receiverPhone":"1891","totalAmount":40000}	Staff An Đông	2026-04-06 01:17:42.598872	42.118.167.44
183	260406.0317	create	product_info	\N	{"receiverName":"hiến","receiverPhone":"4523","totalAmount":40000}	Staff An Đông	2026-04-06 01:17:52.407552	42.118.167.44
184	260406.042	create	product_info	\N	{"receiverName":"sơn","receiverPhone":"5509","totalAmount":40000}	Staff An Đông	2026-04-06 01:18:06.799748	42.118.167.44
185	260406.111	create	product_info	\N	{"receiverName":"phát","receiverPhone":"3745","totalAmount":80000}	Staff An Đông	2026-04-06 01:18:17.81811	42.118.167.44
186	260406.112	create	product_info	\N	{"receiverName":"khoa","receiverPhone":"6773","totalAmount":160000}	Staff An Đông	2026-04-06 01:18:28.90167	42.118.167.44
187	260406.039	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:16.733986	113.22.160.115
188	260406.035	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:16.757072	113.22.160.115
189	260406.037	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.119591	113.22.160.115
190	260406.003	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.120943	113.22.160.115
191	260406.094	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.152893	113.22.160.115
192	260406.102	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.190245	113.22.160.115
193	260406.093	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.314162	113.22.160.115
194	260406.036	update	vehicle	\N	23033	Staff An Đông	2026-04-06 05:53:17.331352	113.22.160.115
195	260406.038	update	vehicle	\N	01031	Staff An Đông	2026-04-06 05:53:30.97121	113.22.160.115
196	260406.004	update	vehicle	\N	01031	Staff An Đông	2026-04-06 05:53:30.997748	113.22.160.115
197	260406.131	update	vehicle	\N	01031	Staff An Đông	2026-04-06 05:53:31.023175	113.22.160.115
198	260406.005	update	vehicle	 	01031	Staff An Đông	2026-04-06 05:53:31.060449	113.22.160.115
199	260406.006	update	vehicle	\N	31935	Staff An Đông	2026-04-06 05:53:59.476365	113.22.160.115
200	260406.0310	update	vehicle	\N	31935	Staff An Đông	2026-04-06 05:53:59.476711	113.22.160.115
201	260406.0313	update	vehicle	 	31935	Staff An Đông	2026-04-06 05:53:59.486936	113.22.160.115
202	260406.0311	update	vehicle	\N	31935	Staff An Đông	2026-04-06 05:53:59.577639	113.22.160.115
203	260406.0312	update	vehicle	\N	31935	Staff An Đông	2026-04-06 05:53:59.596248	113.22.160.115
204	260409.031	create	product_info	\N	{"receiverName":"quốc","receiverPhone":"9449","totalAmount":1}	Staff An Đông	2026-04-09 01:11:01.891214	113.185.83.114
205	260409.032	create	product_info	\N	{"receiverName":"kiểng thành","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 03:30:17.400811	112.197.18.106
206	260409.033	create	product_info	\N	{"receiverName":"út danh","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 03:30:34.343569	112.197.18.106
207	260409.041	create	product_info	\N	{"receiverName":"linh","receiverPhone":"3186","totalAmount":100000}	Staff An Đông	2026-04-09 03:30:55.427358	112.197.18.106
208	260409.001	create	product_info	\N	{"receiverName":"loan tbac","receiverPhone":"0376670275","totalAmount":240000}	Staff An Đông	2026-04-09 03:31:16.140985	112.197.18.106
209	260409.034	create	product_info	\N	{"receiverName":"linh","receiverPhone":"5956","totalAmount":1}	Staff An Đông	2026-04-09 03:31:27.454389	112.197.18.106
210	260409.101	create	product_info	\N	{"receiverName":"minh võ","receiverPhone":"2904","totalAmount":80000}	Staff An Đông	2026-04-09 03:31:43.959719	112.197.18.106
211	260409.035	create	product_info	\N	{"receiverName":"hương","receiverPhone":"4409","totalAmount":1}	Staff An Đông	2026-04-09 03:32:05.662672	112.197.18.106
212	260409.102	create	product_info	\N	{"receiverName":"hường mã vôi","receiverPhone":"1581","totalAmount":120000}	Staff An Đông	2026-04-09 03:32:22.235694	112.197.18.106
213	260409.103	create	product_info	\N	{"receiverName":"nguồn","receiverPhone":"7606","totalAmount":120000}	Staff An Đông	2026-04-09 03:32:31.964999	112.197.18.106
214	260409.036	create	product_info	\N	{"receiverName":"thảo 60 căn","receiverPhone":"1","totalAmount":50000}	Staff An Đông	2026-04-09 03:32:47.127509	112.197.18.106
215	260409.037	create	product_info	\N	{"receiverName":"châu","receiverPhone":"3218","totalAmount":1}	Staff An Đông	2026-04-09 03:33:01.088038	112.197.18.106
216	260409.002	create	product_info	\N	{"receiverName":"vô danh 30,4","receiverPhone":"0786022791","totalAmount":100000}	Staff An Đông	2026-04-09 03:33:23.157881	112.197.18.106
217	260409.003	create	product_info	\N	{"receiverName":"ngọc tbom","receiverPhone":"0967503440","totalAmount":80000}	Staff An Đông	2026-04-09 03:33:47.365956	112.197.18.106
218	260409.004	create	product_info	\N	{"receiverName":"thu csat","receiverPhone":"0919262113","totalAmount":80000}	Staff An Đông	2026-04-09 03:34:02.523397	112.197.18.106
219	260409.081	create	product_info	\N	{"receiverName":"bình","receiverPhone":"9783","totalAmount":50000}	Staff An Đông	2026-04-09 03:34:25.924491	112.197.18.106
220	260409.038	create	product_info	\N	{"receiverName":"nhi","receiverPhone":"7517","totalAmount":1}	Staff An Đông	2026-04-09 03:34:47.263786	112.197.18.106
221	260409.039	create	product_info	\N	{"receiverName":"nhi","receiverPhone":"7517","totalAmount":1}	Staff An Đông	2026-04-09 03:34:55.218865	112.197.18.106
222	260409.002	update	6 fields	[{"senderName":null},{"senderPhone":null},{"receiverName":"vô danh 30,4"},{"quantity":null},{"vehicle":null},{"totalAmount":"100000.00"}]	[{"senderName":""},{"senderPhone":""},{"receiverName":"vô danh 30/4"},{"quantity":""},{"vehicle":" "},{"totalAmount":10000000}]	Staff An Đông	2026-04-09 03:43:38.484528	112.197.18.106
223	260409.002	update	totalAmount	10000000.00	10000000	Staff An Đông	2026-04-09 03:43:40.03122	112.197.18.106
225	260409.002	update	totalAmount	10000000.00	100000	Staff An Đông	2026-04-09 04:00:39.795538	112.197.57.66
224	260409.002	update	totalAmount	10000000.00	100000	Staff An Đông	2026-04-09 04:00:39.795812	112.197.57.66
226	260409.081	update	2 fields	[{"totalAmount":"50000.00"},{"deliveryStatus":"pending"}]	[{"totalAmount":50000},{"deliveryStatus":"delivered"}]	Quản trị viên	2026-04-09 04:17:21.024329	112.197.18.122
227	260409.081	update	totalAmount	50000.00	50000	Quản trị viên	2026-04-09 04:17:21.79391	112.197.18.122
228	260409.038	update	3 fields	[{"totalAmount":"1.00"},{"paymentStatus":"unpaid"},{"deliveryStatus":"pending"}]	[{"totalAmount":140000},{"paymentStatus":"paid"},{"deliveryStatus":"delivered"}]	Quản trị viên	2026-04-09 04:17:39.130432	112.197.18.122
229	260410.101	create	product_info	\N	{"receiverName":"phượng bảo hòa","receiverPhone":"5717","totalAmount":240000}	Staff An Đông	2026-04-09 22:50:50.273471	115.75.4.122
230	260410.061	create	product_info	\N	{"receiverName":"vô danh","receiverPhone":"8450","totalAmount":120000}	Staff An Đông	2026-04-09 22:51:25.506154	115.75.4.122
231	260410.131	create	product_info	\N	{"receiverName":"phụng tiên","receiverPhone":"0532","totalAmount":120000}	Staff An Đông	2026-04-09 22:51:34.19218	115.75.4.122
232	260410.031	create	product_info	\N	{"receiverName":"quốc","receiverPhone":"9449","totalAmount":1}	Staff An Đông	2026-04-09 22:51:42.680436	115.75.4.122
233	260410.032	create	product_info	\N	{"receiverName":"hiếu mì","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 22:51:47.151846	115.75.4.122
234	260410.033	create	product_info	\N	{"receiverName":"như","receiverPhone":"1123","totalAmount":1}	Staff An Đông	2026-04-09 22:51:54.670721	115.75.4.122
235	260410.034	create	product_info	\N	{"receiverName":"út danh","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 22:52:25.671561	115.75.4.122
236	260410.035	create	product_info	\N	{"receiverName":"lưu an","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 22:52:33.623869	115.75.4.122
237	260410.036	create	product_info	\N	{"receiverName":"nhi","receiverPhone":"7517","totalAmount":1}	Staff An Đông	2026-04-09 22:52:44.508593	115.75.4.122
238	260410.081	create	product_info	\N	{"receiverName":"nguyên","receiverPhone":"4154","totalAmount":80000}	Staff An Đông	2026-04-09 23:05:31.426419	115.75.4.122
239	260410.037	create	product_info	\N	{"receiverName":"hương","receiverPhone":"4409","totalAmount":1}	Staff An Đông	2026-04-09 23:05:44.542934	115.75.4.122
240	260410.001	create	product_info	\N	{"receiverName":"đạt bca","receiverPhone":"0899465931","totalAmount":70000}	Staff An Đông	2026-04-09 23:05:57.350827	115.75.4.122
241	260410.102	create	product_info	\N	{"receiverName":"liễu","receiverPhone":"0213","totalAmount":80000}	Staff An Đông	2026-04-09 23:06:04.961478	115.75.4.122
242	260410.103	create	product_info	\N	{"receiverName":"chi","receiverPhone":"8816","totalAmount":80000}	Staff An Đông	2026-04-09 23:06:11.249164	115.75.4.122
243	260410.038	create	product_info	\N	{"receiverName":"hiếu","receiverPhone":"6773","totalAmount":1}	Staff An Đông	2026-04-09 23:06:23.62491	115.75.4.122
244	260410.039	create	product_info	\N	{"receiverName":"thanh bánh bao","receiverPhone":"1","totalAmount":1}	Staff An Đông	2026-04-09 23:06:32.716669	115.75.4.122
245	260410.0310	create	product_info	\N	{"receiverName":"sơn","receiverPhone":"3773","totalAmount":1}	Staff An Đông	2026-04-09 23:06:39.193228	115.75.4.122
246	260410.111	create	product_info	\N	{"receiverName":"huy","receiverPhone":"6703","totalAmount":70000}	Staff An Đông	2026-04-09 23:06:54.739732	115.75.4.122
247	260410.0311	create	product_info	\N	{"receiverName":"nam","receiverPhone":"2847","totalAmount":1}	Staff An Đông	2026-04-09 23:07:01.109785	115.75.4.122
248	260410.0312	create	product_info	\N	{"receiverName":"chương hằng","receiverPhone":"2472","totalAmount":1}	Staff An Đông	2026-04-09 23:07:14.476333	115.75.4.122
249	260410.0313	create	product_info	\N	{"receiverName":"tuyến chương","receiverPhone":"2539","totalAmount":1}	Staff An Đông	2026-04-09 23:07:21.042634	115.75.4.122
250	260410.0314	create	product_info	\N	{"receiverName":"cô lưu","receiverPhone":"8878","totalAmount":1}	Staff An Đông	2026-04-10 00:21:14.172443	115.75.4.122
251	260410.002	create	product_info	\N	{"receiverName":"trung vtau","receiverPhone":"0937768129","totalAmount":100000}	Staff An Đông	2026-04-10 05:16:35.386413	113.22.92.196
252	260410.003	create	product_info	\N	{"receiverName":"thảo trị an","receiverPhone":"0977112382","totalAmount":80000}	Staff An Đông	2026-04-10 05:26:15.540057	113.22.92.196
253	260410.104	create	product_info	\N	{"receiverName":"hồng thư","receiverPhone":"7279","totalAmount":80000}	Staff An Đông	2026-04-10 05:30:26.484128	113.22.92.196
254	260410.104	update	5 fields	[{"senderName":null},{"senderPhone":null},{"quantity":null},{"vehicle":null},{"totalAmount":"80000.00"}]	[{"senderName":""},{"senderPhone":""},{"quantity":""},{"vehicle":"01031"},{"totalAmount":8000000}]	Staff An Đông	2026-04-10 05:43:23.38084	113.22.92.196
255	260410.104	update	totalAmount	8000000.00	8000000	Staff An Đông	2026-04-10 05:43:24.769194	113.22.92.196
256	260410.104	update	totalAmount	8000000.00	80000	Quản trị viên	2026-04-10 05:51:11.834467	113.22.92.196
257	260410.0315	create	product_info	\N	{"receiverName":"nhi","receiverPhone":"7517","totalAmount":1}	Staff An Đông	2026-04-10 06:54:39.395213	113.22.92.196
258	260410.002	cancel	status	pending	cancelled	Staff An Đông	2026-04-10 06:54:49.909103	113.22.92.196
259	260410.0316	create	product_info	\N	{"receiverName":"bé chương","receiverPhone":"1929","totalAmount":1}	Staff An Đông	2026-04-10 06:56:30.557278	113.22.92.196
\.


--
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Products" (id, "senderName", "senderPhone", "senderStation", "receiverName", "receiverPhone", station, "productType", quantity, vehicle, insurance, "totalAmount", "paymentStatus", status, "deliveryStatus", employee, "createdBy", notes, "sendDate", "deliveredAt", "createdAt", "updatedAt", "tongHopBookingId", "syncedToTongHop") FROM stdin;
260118.0101	Test Sender	0901234567	01 - AN ĐÔNG	Test Receiver	0909876543	00 - DỌC ĐƯỜNG	06 - Kiện	2	\N	0.00	50000.00	paid	pending	pending	\N	\N	\N	2026-01-18 05:22:21.612	\N	2026-01-18 05:22:22.187947	2026-01-18 05:22:22.976133	21	t
260119.0101	Test	0123456789	01 - AN ĐÔNG	Minh	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	1	\N	0.00	0.00	unpaid	pending	pending	\N	\N	\N	2026-01-18 22:42:14.872	\N	2026-01-18 22:42:15.641191	2026-01-18 22:42:16.669129	22	t
260122.0101	Test	0901234567	01 - AN ĐÔNG	Test Receiver	0987654321	00 - DỌC ĐƯỜNG	06 - Kiện	2 thùng	\N	0.00	50000.00	paid	pending	pending	\N	test	\N	2026-01-22 13:58:50.244	\N	2026-01-22 13:58:51.548594	2026-01-22 13:58:52.620916	23	t
260406.038	\N	\N	01 - AN ĐÔNG	như	1123	03 - LONG KHÁNH	03 - Thùng	\N	01031	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:13:00	\N	2026-04-06 01:13:42.37847	2026-04-06 05:53:30.757513	\N	f
260124.0101	\N	\N	01 - AN ĐÔNG	minh tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	500000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:15:00	\N	2026-01-24 08:16:01.490358	2026-01-24 08:16:02.875596	24	t
260124.0102	\N	\N	01 - AN ĐÔNG	minh tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	500000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:17:00	\N	2026-01-24 08:17:02.179348	2026-01-24 08:17:03.463903	25	t
260124.0103	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:29:00	\N	2026-01-24 08:29:22.989418	2026-01-24 08:29:25.628203	26	t
260124.0104	\N	\N	01 - AN ĐÔNG	Nâu tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:36:00	\N	2026-01-24 08:36:19.596254	2026-01-24 08:36:20.872412	27	t
260124.0105	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:41:00	\N	2026-01-24 08:41:02.727875	2026-01-24 08:41:05.764519	28	t
260124.0106	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:42:00	\N	2026-01-24 08:42:49.56554	2026-01-24 08:42:50.861269	29	t
260124.0107	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:43:00	\N	2026-01-24 08:43:04.51387	2026-01-24 08:43:05.805974	30	t
260124.0108	\N	\N	01 - AN ĐÔNG	Nâu tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:45:00	\N	2026-01-24 08:45:39.398608	2026-01-24 08:45:40.658608	31	t
260124.0109	\N	\N	01 - AN ĐÔNG	Nâu tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 15:46:00	\N	2026-01-24 08:46:16.055652	2026-01-24 08:46:17.30661	32	t
260124.0110	\N	\N	01 - AN ĐÔNG	minh tbom	0908724146	00 - DỌC ĐƯỜNG	17 - Hộp	\N	\N	0.00	1000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 16:26:00	\N	2026-01-24 09:26:08.918521	2026-01-24 09:26:10.239073	33	t
260124.0111	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 16:27:00	\N	2026-01-24 09:27:10.995613	2026-01-24 09:27:12.272294	34	t
260124.0112	\N	\N	01 - AN ĐÔNG	minh tbom	0772607305	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 16:28:00	\N	2026-01-24 09:28:58.009123	2026-01-24 09:28:59.265515	35	t
260124.0301	\N	\N	03 - LONG KHÁNH	minh tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-01-24 16:30:00	\N	2026-01-24 09:31:01.631481	2026-01-24 09:31:02.928241	36	t
260124.0113	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	26 - Nhiều loại	1 thùng + 1 bao	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 16:35:00	\N	2026-01-24 09:35:11.589117	2026-01-24 09:35:12.874782	37	t
260124.0114	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 20:30:00	\N	2026-01-24 13:30:54.790124	2026-01-24 13:30:57.860138	38	t
260124.0115	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 20:46:00	\N	2026-01-24 13:46:40.844968	2026-01-24 13:46:43.854337	39	t
260124.0116	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 20:54:00	\N	2026-01-24 13:54:59.887747	2026-01-24 13:55:02.810727	40	t
260124.0117	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 20:58:00	\N	2026-01-24 13:58:10.688993	2026-01-24 13:58:11.987741	41	t
260124.0118	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 20:58:00	\N	2026-01-24 13:58:30.338278	2026-01-24 13:58:31.60957	42	t
260124.0119	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-24 21:04:00	\N	2026-01-24 14:04:42.227471	2026-01-24 14:04:44.861939	43	t
260125.0101	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	1000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 05:20:00	\N	2026-01-24 22:20:49.283383	2026-01-24 22:20:52.455912	44	t
260125.0102	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	05 - Bao	\N	\N	0.00	1000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 05:42:00	\N	2026-01-24 22:42:47.714321	2026-01-24 22:42:50.937789	45	t
260125.0103	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	1000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 05:50:00	\N	2026-01-24 22:50:32.704975	2026-01-24 22:50:35.877613	46	t
260125.0104	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	1000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 06:17:00	\N	2026-01-24 23:17:39.957389	2026-01-24 23:17:42.594582	47	t
260125.0105	\N	\N	01 - AN ĐÔNG	minh tbom	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 13:28:00	\N	2026-01-25 06:28:16.794298	2026-01-25 06:28:18.135	48	t
260125.0106	\N	\N	01 - AN ĐÔNG	minh tco	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 16:01:00	\N	2026-01-25 09:01:49.996368	2026-01-25 09:01:51.387258	49	t
260125.0107	\N	\N	01 - AN ĐÔNG	minh qbien	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 16:05:00	\N	2026-01-25 09:05:36.3653	2026-01-25 09:05:38.969434	50	t
260125.0108	\N	\N	01 - AN ĐÔNG	Nâu	3232	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	8000000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 18:05:00	\N	2026-01-25 11:05:43.225765	2026-01-25 11:05:43.225765	\N	f
260125.0109	\N	\N	01 - AN ĐÔNG	Nâu	3232	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	800000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-25 18:06:00	\N	2026-01-25 11:06:25.206625	2026-01-25 11:06:26.562266	51	t
260126.0301	\N	\N	03 - LONG KHÁNH	minh	0877414135	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-01-26 05:30:00	\N	2026-01-25 22:30:55.413864	2026-01-25 22:30:55.413864	\N	f
260126.0101	\N	\N	01 - AN ĐÔNG	minh	0877414135	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-01-26 05:31:00	\N	2026-01-25 22:31:25.096677	2026-01-25 22:31:58.602601	\N	f
260126.0102	\N	\N	01 - AN ĐÔNG	minh	0877414135	05 - XUÂN TRƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-26 07:59:00	\N	2026-01-26 00:59:53.821682	2026-01-26 00:59:53.821682	\N	f
260131.0101	\N	\N	01 - AN ĐÔNG	minh tco	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-31 17:45:00	\N	2026-01-31 10:45:55.528723	2026-01-31 10:45:56.891754	52	t
260131.0102	\N	\N	01 - AN ĐÔNG	minh tco	0877414135	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-31 17:46:00	\N	2026-01-31 10:46:25.928565	2026-01-31 10:46:27.238929	53	t
260328.1002	\N	\N	01 - AN ĐÔNG	phượng bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 07:28:00	\N	2026-03-28 00:28:35.092826	2026-03-28 00:31:59.835835	\N	f
260131.0103	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-31 17:47:00	\N	2026-01-31 10:47:03.162017	2026-01-31 10:47:04.450834	54	t
260328.1101	\N	\N	01 - AN ĐÔNG	liên hương	8635	11 - XUÂN ĐÀ	03 - Thùng	\N	\N	0.00	120000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 07:28:00	\N	2026-03-28 00:28:58.277993	2026-03-28 00:32:01.124959	\N	f
260131.0104	\N	\N	01 - AN ĐÔNG	minh tco	07726073050	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-31 18:01:00	\N	2026-01-31 11:01:41.125999	2026-01-31 11:01:42.439637	55	t
260328.1102	\N	\N	01 - AN ĐÔNG	huy	6703	11 - XUÂN ĐÀ	03 - Thùng	\N	\N	0.00	80000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 07:29:00	\N	2026-03-28 00:29:57.668205	2026-03-28 00:32:01.582323	\N	f
260131.0105	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-01-31 18:03:00	\N	2026-01-31 11:03:57.152417	2026-01-31 11:03:58.442157	56	t
260328.0302	\N	\N	01 - AN ĐÔNG	cô lưu	8878	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:34:00	\N	2026-03-28 08:34:13.750185	2026-03-28 08:34:13.750185	\N	f
260217.0101	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-17 18:47:00	\N	2026-02-17 11:48:00.676351	2026-02-17 11:48:03.862207	58	t
260328.113	\N	\N	01 - AN ĐÔNG	huy	6703	11 - XUÂN ĐÀ	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:36:00	\N	2026-03-28 08:36:13.235282	2026-03-28 08:36:13.235282	\N	f
260328.091	\N	\N	01 - AN ĐÔNG	hiếu	1449	09 - HAI MÃO	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:36:00	\N	2026-03-28 08:36:36.360456	2026-03-28 08:36:36.360456	\N	f
260219.0101	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 11:33:00	\N	2026-02-19 04:33:40.701116	2026-02-19 04:33:43.279874	59	t
260219.0102	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 11:48:00	\N	2026-02-19 04:48:42.640816	2026-02-19 04:48:45.345899	60	t
260328.001	\N	\N	01 - AN ĐÔNG	thảo trị an	0977112382	00 - DỌC ĐƯỜNG	05 - Bao	\N	 	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:37:00	\N	2026-03-28 08:37:11.639366	2026-03-28 08:37:47.787452	98	t
260219.0103	\N	\N	01 - AN ĐÔNG	minh tbom	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 11:49:00	\N	2026-02-19 04:49:16.986298	2026-02-19 04:49:18.150038	61	t
260328.033	\N	\N	01 - AN ĐÔNG	huy	6773	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:38:00	\N	2026-03-28 08:38:53.336729	2026-03-28 08:38:53.336729	\N	f
260219.0104	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	04 - Gói	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 12:07:00	\N	2026-02-19 05:07:59.607515	2026-02-19 05:08:01.00695	62	t
260328.034	\N	\N	01 - AN ĐÔNG	bính hạnh	9767	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:40:00	\N	2026-03-28 08:40:03.803978	2026-03-28 08:40:03.803978	\N	f
260219.0105	\N	\N	01 - AN ĐÔNG	minh sthao	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 12:08:00	\N	2026-02-19 05:08:52.982781	2026-02-19 05:08:54.264918	63	t
260328.035	\N	\N	01 - AN ĐÔNG	MINH	6060	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:48:00	\N	2026-03-28 08:48:18.580672	2026-03-28 08:48:18.580672	\N	f
260219.0106	\N	\N	01 - AN ĐÔNG	minh qbien	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 12:09:00	\N	2026-02-19 05:09:46.290845	2026-02-19 05:09:47.411171	64	t
260219.0107	\N	\N	01 - AN ĐÔNG	minh tbomtb	0877414135	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 12:18:00	\N	2026-02-19 05:18:11.855096	2026-02-19 05:18:11.855096	\N	f
260328.036	\N	\N	01 - AN ĐÔNG	HIẾU	6773	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:59:00	\N	2026-03-28 08:59:51.388164	2026-03-28 08:59:51.388164	\N	f
260219.0108	\N	\N	01 - AN ĐÔNG	minh tco	0908724146	00 - DỌC ĐƯỜNG	26 - Nhiều loại	1 thùng 3 kiện	\N	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-02-19 12:19:00	\N	2026-02-19 05:19:12.624381	2026-02-19 05:19:15.119918	66	t
260328.037	\N	\N	01 - AN ĐÔNG	HIẾU	5290	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 15:59:00	\N	2026-03-28 09:00:03.612626	2026-03-28 09:00:03.612626	\N	f
260219.0301	\N	\N	03 - LONG KHÁNH	minh tco	0908724146	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	200000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-02-19 12:41:00	\N	2026-02-19 05:41:43.861617	2026-02-19 05:41:54.371091	67	t
260322.0101			01 - AN ĐÔNG	minh tco	0908724146	03 - LONG KHÁNH	03 - Thùng		26025	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-22 14:37:00	\N	2026-03-22 07:37:03.364104	2026-03-22 07:40:23.636533	\N	f
260322.0102			01 - AN ĐÔNG	minh tco	0908724146	03 - LONG KHÁNH	03 - Thùng		26025	0.00	200000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-22 14:42:00	\N	2026-03-22 07:42:32.845869	2026-03-22 07:46:23.078849	\N	f
260323.0101	\N	\N	01 - AN ĐÔNG	cô lưu	8878	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-03-23 06:28:00	\N	2026-03-22 23:28:25.605519	2026-03-22 23:31:55.030632	\N	f
260323.0102			01 - AN ĐÔNG	hiền	0073	05 - XUÂN TRƯỜNG	15 - Thùng xốp		26879	0.00	120000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-03-23 06:29:00	\N	2026-03-22 23:29:24.625904	2026-03-22 23:32:04.635452	\N	f
260324.0104	\N	\N	01 - AN ĐÔNG	Minh bưu điện trảng bom	0908724146	03 - LONG KHÁNH	03 - Thùng	\N	01031	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 11:47:00	\N	2026-03-24 04:47:26.546611	2026-03-24 04:47:26.546611	\N	f
260324.0103			01 - AN ĐÔNG	minh	0205	03 - LONG KHÁNH	03 - Thùng		01057	0.00	160000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 08:55:00	\N	2026-03-24 01:55:36.939902	2026-03-24 04:48:53.552629	\N	f
260324.0105	\N	\N	01 - AN ĐÔNG	minh	0205	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 13:45:00	\N	2026-03-24 06:45:34.23501	2026-03-24 06:45:34.23501	\N	f
260324.0301	\N	\N	01 - AN ĐÔNG	minh	0205	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 13:53:00	\N	2026-03-24 06:53:24.901156	2026-03-24 07:00:59.572559	\N	f
260324.0501	\N	\N	01 - AN ĐÔNG	minh	2341	05 - XUÂN TRƯỜNG	03 - Thùng	\N	\N	0.00	100000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 13:53:00	\N	2026-03-24 06:53:39.648119	2026-03-24 07:03:09.864195	\N	f
260324.0102			01 - AN ĐÔNG	Minh bưu điện trảng bom	0877414135	03 - LONG KHÁNH	03 - Thùng	10k	01785	0.00	1600000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-24 08:34:00	\N	2026-03-24 01:34:17.792519	2026-03-24 07:03:24.045833	\N	f
260328.1001	\N	\N	01 - AN ĐÔNG	phượng bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 07:24:00	\N	2026-03-28 00:24:49.849398	2026-03-28 00:28:17.625711	\N	f
260328.038	\N	\N	01 - AN ĐÔNG	HIẾU	6773	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:01:00	\N	2026-03-28 09:01:13.387365	2026-03-28 09:01:13.387365	\N	f
260328.039	\N	\N	01 - AN ĐÔNG	hiếu	6773	03 - LONG KHÁNH	03 - Thùng	1	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:02:00	\N	2026-03-28 09:02:26.819393	2026-03-28 09:02:26.819393	\N	f
260328.0310	\N	\N	01 - AN ĐÔNG	PHƯƠNG	5296	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:02:00	\N	2026-03-28 09:02:27.563624	2026-03-28 09:02:27.563624	\N	f
260328.0301			01 - AN ĐÔNG	phượng bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	2t	 	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 07:32:00	\N	2026-03-28 00:32:17.693468	2026-03-28 09:22:08.459015	\N	f
260328.0311	\N	\N	01 - AN ĐÔNG	HEHE	0834554020	03 - LONG KHÁNH	03 - Thùng	\N	04671	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:17:00	\N	2026-03-28 09:17:58.070685	2026-03-28 09:23:21.24805	\N	f
260328.0312	\N	\N	01 - AN ĐÔNG	HIẾU	1123	03 - LONG KHÁNH	03 - Thùng	\N	04671	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:18:00	\N	2026-03-28 09:18:09.052742	2026-03-28 09:23:21.57922	\N	f
260328.0313	\N	\N	01 - AN ĐÔNG	HUNGF	6326	03 - LONG KHÁNH	03 - Thùng	\N	 	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:32:00	\N	2026-03-28 09:32:35.904312	2026-03-28 09:32:35.904312	\N	f
260328.0314	\N	\N	01 - AN ĐÔNG	HIEU	6773	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:32:00	\N	2026-03-28 09:32:43.895841	2026-03-28 09:32:43.895841	\N	f
260328.0315	\N	\N	01 - AN ĐÔNG	HOANG	8433	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:32:00	\N	2026-03-28 09:32:52.953356	2026-03-28 09:32:52.953356	\N	f
260328.0316	\N	\N	01 - AN ĐÔNG	HOANG	8433	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:39:00	\N	2026-03-28 09:39:30.380665	2026-03-28 09:39:30.380665	\N	f
260328.0317	\N	\N	01 - AN ĐÔNG	HIẾU	6773	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:40:00	\N	2026-03-28 09:40:08.831623	2026-03-28 09:40:08.831623	\N	f
260328.0318	\N	\N	01 - AN ĐÔNG	NGAAN	8468	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:44:00	\N	2026-03-28 09:44:47.361114	2026-03-28 09:44:47.361114	\N	f
260328.0319	\N	\N	01 - AN ĐÔNG	TUYẾT NGÂN	8468	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-28 16:48:00	\N	2026-03-28 09:48:42.747297	2026-03-28 09:48:42.747297	\N	f
260329.101	\N	\N	01 - AN ĐÔNG	PHƯƠNG BẢO HÒA	5717	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:45:00	\N	2026-03-28 22:45:42.378179	2026-03-28 22:45:42.378179	\N	f
260329.031	\N	\N	01 - AN ĐÔNG	QUỐC	9449	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:45:00	\N	2026-03-28 22:45:48.741823	2026-03-28 22:45:48.741823	\N	f
260329.032	\N	\N	01 - AN ĐÔNG	LƯU AN	1	03 - LONG KHÁNH	03 - Thùng	6 THÙNG	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:45:00	\N	2026-03-28 22:45:58.055172	2026-03-28 22:45:58.055172	\N	f
260329.033	\N	\N	01 - AN ĐÔNG	KIỂNG THÀNH	1	03 - LONG KHÁNH	03 - Thùng	2 THÙNG	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:46:00	\N	2026-03-28 22:46:13.614966	2026-03-28 22:46:13.614966	\N	f
260329.034	\N	\N	01 - AN ĐÔNG	HIẾU MÌ	1	03 - LONG KHÁNH	05 - Bao	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:46:00	\N	2026-03-28 22:46:22.071079	2026-03-28 22:46:22.071079	\N	f
260329.035	\N	\N	01 - AN ĐÔNG	HỒNG	5290	03 - LONG KHÁNH	15 - Thùng xốp	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:46:00	\N	2026-03-28 22:46:30.383501	2026-03-28 22:46:30.383501	\N	f
260329.081	\N	\N	01 - AN ĐÔNG	THÚY	5286	08 - BẢO BÌNH	06 - Kiện	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:46:00	\N	2026-03-28 22:46:41.136739	2026-03-28 22:46:41.136739	\N	f
260329.091	\N	\N	01 - AN ĐÔNG	THẮNG	0940	09 - HAI MÃO	03 - Thùng	3 THÙNG	\N	0.00	340000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:46:00	\N	2026-03-28 22:46:57.778101	2026-03-28 22:46:57.778101	\N	f
260329.111	\N	\N	01 - AN ĐÔNG	VINH	5993	11 - XUÂN ĐÀ	15 - Thùng xốp	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:47:00	\N	2026-03-28 22:47:29.637231	2026-03-28 22:47:29.637231	\N	f
260329.001	\N	\N	01 - AN ĐÔNG	VÔ DANH KM41	1	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:47:00	\N	2026-03-28 22:47:16.892977	2026-03-28 22:47:49.225057	99	t
260329.037	\N	\N	01 - AN ĐÔNG	THẢO 60 CĂN	1	03 - LONG KHÁNH	05 - Bao	\N	04627	0.00	60000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:47:00	\N	2026-03-28 22:47:49.018738	2026-03-28 23:12:32.202158	\N	f
260329.002	\N	\N	01 - AN ĐÔNG	NGỌC TBOM	0967503440	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	04627	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 05:48:00	\N	2026-03-28 22:48:29.625864	2026-03-28 23:12:32.284474	\N	f
260329.003	\N	\N	01 - AN ĐÔNG	thảo trị an	0977112382	00 - DỌC ĐƯỜNG	05 - Bao	1	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 07:49:00	\N	2026-03-29 00:49:27.838565	2026-03-29 00:49:46.64	102	t
260329.004	\N	\N	01 - AN ĐÔNG	thúy đào 30/4	0979189663	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 10:05:00	\N	2026-03-29 03:05:36.520285	2026-03-29 03:05:57.489123	107	t
260329.005	\N	\N	01 - AN ĐÔNG	thảo trị an	0977112382	00 - DỌC ĐƯỜNG	05 - Bao	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-03-29 10:06:00	\N	2026-03-29 03:06:26.025664	2026-03-29 03:06:40.402351	108	t
260329.038	\N	\N	01 - AN ĐÔNG	trùng dương	5056	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	50000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-03-29 07:53:00	\N	2026-03-29 00:53:37.180279	2026-03-29 03:08:54.1	\N	f
260329.036	\N	\N	01 - AN ĐÔNG	CÔ BA	2744	03 - LONG KHÁNH	03 - Thùng	\N	04627	0.00	70000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-03-29 05:47:00	\N	2026-03-28 22:47:39.352193	2026-03-29 03:09:13.087636	\N	f
260401.031	\N	\N	01 - AN ĐÔNG	đề	5579	03 - LONG KHÁNH	05 - Bao	2 bao	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-01 16:14:00	\N	2026-04-01 09:14:32.348698	2026-04-01 09:14:32.348698	\N	f
260401.071	\N	\N	01 - AN ĐÔNG	nguyên	1173	07 - XUÂN LỮ	04 - Gói	\N	\N	0.00	70000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-01 16:14:00	\N	2026-04-01 09:14:52.900125	2026-04-01 09:14:52.900125	\N	f
260401.032	\N	\N	01 - AN ĐÔNG	HÀ DUNG	2950	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-01 16:38:00	\N	2026-04-01 09:38:39.212379	2026-04-01 09:38:39.212379	\N	f
260401.011	\N	\N	03 - LONG KHÁNH	trung kim yên	6202	01 - AN ĐÔNG	03 - Thùng	1	\N	0.00	100000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-01 16:47:00	\N	2026-04-01 09:47:27.796404	2026-04-01 09:47:27.796404	\N	f
260403.101	\N	\N	01 - AN ĐÔNG	hường mã vôi	1581	10 - ÔNG ĐÔN	03 - Thùng	3t	\N	0.00	360000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-03 04:55:00	\N	2026-04-02 21:55:10.606748	2026-04-02 21:55:10.606748	\N	f
260403.102	\N	\N	01 - AN ĐÔNG	phượng bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	2t	\N	0.00	240000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-03 04:59:00	\N	2026-04-02 21:59:50.405372	2026-04-02 21:59:50.405372	\N	f
260403.031	\N	\N	01 - AN ĐÔNG	quốc	9449	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-03 04:59:00	\N	2026-04-02 21:59:56.611062	2026-04-02 21:59:56.611062	\N	f
260403.032	\N	\N	01 - AN ĐÔNG	lưu an	1	03 - LONG KHÁNH	03 - Thùng	6t	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-03 05:00:00	\N	2026-04-02 22:00:07.020697	2026-04-02 22:00:07.020697	\N	f
260403.001	\N	\N	01 - AN ĐÔNG	ngọc tbom	0967503440	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-03 05:00:00	\N	2026-04-02 22:01:00.519835	2026-04-02 22:01:27.216714	110	t
260406.001	\N	\N	03 - LONG KHÁNH	thảo trị an	0977112382	00 - DỌC ĐƯỜNG	05 - Bao	\N	\N	0.00	80000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 06:49:00	\N	2026-04-05 23:49:23.436907	2026-04-05 23:49:27.807087	111	t
260406.002	\N	\N	03 - LONG KHÁNH	ngọc tbom	0967503440	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	80000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 06:54:00	\N	2026-04-05 23:54:59.768357	2026-04-05 23:55:04.144588	112	t
260406.091	\N	\N	03 - LONG KHÁNH	thắng	0940	09 - HAI MÃO	03 - Thùng	2 thùng	\N	0.00	240000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:00:00	\N	2026-04-06 01:01:00.527987	2026-04-06 01:01:00.527987	\N	f
260406.031	\N	\N	03 - LONG KHÁNH	bính hạnh	9767	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:01:00	\N	2026-04-06 01:01:17.669207	2026-04-06 01:01:17.669207	\N	f
260406.092	\N	\N	03 - LONG KHÁNH	thắng	0940	09 - HAI MÃO	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:01:00	\N	2026-04-06 01:01:33.306315	2026-04-06 01:01:33.306315	\N	f
260406.101	\N	\N	03 - LONG KHÁNH	nhi bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:01:00	\N	2026-04-06 01:01:40.905422	2026-04-06 01:01:40.905422	\N	f
260406.032	\N	\N	03 - LONG KHÁNH	quốc	9449	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:01:00	\N	2026-04-06 01:01:49.066423	2026-04-06 01:01:49.066423	\N	f
260406.033	\N	\N	03 - LONG KHÁNH	hiếu mì	1	03 - LONG KHÁNH	05 - Bao	\N	\N	0.00	1.00	unpaid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:01:00	\N	2026-04-06 01:01:53.945121	2026-04-06 01:01:53.945121	\N	f
260406.034	\N	\N	03 - LONG KHÁNH	như	1123	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:02:00	\N	2026-04-06 01:02:03.816017	2026-04-06 01:02:03.816017	\N	f
260406.041	\N	\N	03 - LONG KHÁNH	vdanh km41	1	04 - TRẠM 97	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff Long Khánh	Staff Long Khánh	\N	2026-04-06 08:02:00	\N	2026-04-06 01:02:19.668989	2026-04-06 01:02:19.668989	\N	f
260406.035	\N	\N	01 - AN ĐÔNG	quốc	9449	03 - LONG KHÁNH	03 - Thùng	\N	23033	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:03:00	\N	2026-04-06 01:03:55.097783	2026-04-06 05:53:16.530293	\N	f
260406.037	\N	\N	01 - AN ĐÔNG	bính hạnh	9767	03 - LONG KHÁNH	03 - Thùng	\N	23033	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:08:00	\N	2026-04-06 01:08:17.608418	2026-04-06 05:53:16.90171	\N	f
260406.003	\N	\N	01 - AN ĐÔNG	vdanh km41	0383399204	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	23033	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:07:00	\N	2026-04-06 01:07:53.27719	2026-04-06 05:53:16.903109	\N	f
260406.094	\N	\N	01 - AN ĐÔNG	thắng	0940	09 - HAI MÃO	03 - Thùng	\N	23033	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:07:00	\N	2026-04-06 01:07:18.171393	2026-04-06 05:53:16.939554	\N	f
260406.102	\N	\N	01 - AN ĐÔNG	nhi bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	\N	23033	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:07:00	\N	2026-04-06 01:07:27.233897	2026-04-06 05:53:16.975739	\N	f
260406.093	\N	\N	01 - AN ĐÔNG	thắng	0940	09 - HAI MÃO	03 - Thùng	2 thùng	23033	0.00	240000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:03:00	\N	2026-04-06 01:03:16.598905	2026-04-06 05:53:17.088647	\N	f
260406.036	\N	\N	01 - AN ĐÔNG	hiếu mì	1	03 - LONG KHÁNH	05 - Bao	\N	23033	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:06:00	\N	2026-04-06 01:06:44.953597	2026-04-06 05:53:17.099841	\N	f
260406.131	\N	\N	01 - AN ĐÔNG	phụng tiên	0532	13 - XUÂN HƯNG	03 - Thùng	\N	01031	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:13:00	\N	2026-04-06 01:13:31.212207	2026-04-06 05:53:30.803114	\N	f
260406.0314			01 - AN ĐÔNG	hải	6783	04 - TRẠM 97	03 - Thùng		 	0.00	40000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:16:00	\N	2026-04-06 01:16:43.530915	2026-04-06 01:17:11.677737	\N	f
260406.0315	\N	\N	01 - AN ĐÔNG	thi	7435	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:17:00	\N	2026-04-06 01:17:21.949111	2026-04-06 01:17:21.949111	\N	f
260406.0316	\N	\N	01 - AN ĐÔNG	thư	1891	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	40000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:17:00	\N	2026-04-06 01:17:42.384426	2026-04-06 01:17:42.384426	\N	f
260406.0317	\N	\N	01 - AN ĐÔNG	hiến	4523	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	40000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:17:00	\N	2026-04-06 01:17:52.174674	2026-04-06 01:17:52.174674	\N	f
260406.042	\N	\N	01 - AN ĐÔNG	sơn	5509	04 - TRẠM 97	03 - Thùng	\N	\N	0.00	40000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:18:00	\N	2026-04-06 01:18:06.54339	2026-04-06 01:18:06.54339	\N	f
260406.111	\N	\N	01 - AN ĐÔNG	phát	3745	11 - XUÂN ĐÀ	05 - Bao	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:18:00	\N	2026-04-06 01:18:17.600961	2026-04-06 01:18:17.600961	\N	f
260406.112	\N	\N	01 - AN ĐÔNG	khoa	6773	11 - XUÂN ĐÀ	03 - Thùng	2 thùng	\N	0.00	160000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:18:00	\N	2026-04-06 01:18:28.689866	2026-04-06 01:18:28.689866	\N	f
260406.039	\N	\N	01 - AN ĐÔNG	minh ngọc	1357	03 - LONG KHÁNH	03 - Thùng	\N	23033	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:13:00	\N	2026-04-06 01:13:49.899356	2026-04-06 05:53:16.393452	\N	f
260406.004	\N	\N	01 - AN ĐÔNG	công thanh hóa	0911854535	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	01031	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:14:00	\N	2026-04-06 01:14:18.406627	2026-04-06 05:53:30.783292	113	t
260406.005			01 - AN ĐÔNG	ngọc tbom	0967503440	00 - DỌC ĐƯỜNG	15 - Thùng xốp	2 thùng xốp	01031	0.00	160000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:14:00	\N	2026-04-06 01:14:32.119402	2026-04-06 05:53:30.836068	\N	f
260406.0310	\N	\N	01 - AN ĐÔNG	tuấn trân	7131	03 - LONG KHÁNH	03 - Thùng	\N	31935	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:15:00	\N	2026-04-06 01:15:24.842357	2026-04-06 05:53:59.255199	\N	f
260406.006	\N	\N	01 - AN ĐÔNG	xuân ttam	0977687057	00 - DỌC ĐƯỜNG	03 - Thùng	\N	31935	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:15:00	\N	2026-04-06 01:15:01.058228	2026-04-06 05:53:59.255014	115	t
260406.0313			01 - AN ĐÔNG	hùng	5121	03 - LONG KHÁNH	15 - Thùng xốp		31935	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:15:00	\N	2026-04-06 01:15:52.208911	2026-04-06 05:53:59.266203	\N	f
260406.0311	\N	\N	01 - AN ĐÔNG	dũng	0336	03 - LONG KHÁNH	05 - Bao	\N	31935	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:15:00	\N	2026-04-06 01:15:31.42668	2026-04-06 05:53:59.348364	\N	f
260406.0312	\N	\N	01 - AN ĐÔNG	lai	2418	03 - LONG KHÁNH	03 - Thùng	\N	31935	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-06 08:15:00	\N	2026-04-06 01:15:38.211633	2026-04-06 05:53:59.362466	\N	f
260409.031	\N	\N	01 - AN ĐÔNG	quốc	9449	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 08:10:00	\N	2026-04-09 01:11:01.656552	2026-04-09 01:11:01.656552	\N	f
260409.032	\N	\N	01 - AN ĐÔNG	kiểng thành	1	03 - LONG KHÁNH	03 - Thùng	2	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:30:00	\N	2026-04-09 03:30:17.163742	2026-04-09 03:30:17.163742	\N	f
260409.033	\N	\N	01 - AN ĐÔNG	út danh	1	03 - LONG KHÁNH	03 - Thùng	5 thùng	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:30:00	\N	2026-04-09 03:30:34.112288	2026-04-09 03:30:34.112288	\N	f
260409.041	\N	\N	01 - AN ĐÔNG	linh	3186	04 - TRẠM 97	03 - Thùng	\N	\N	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:30:00	\N	2026-04-09 03:30:55.21345	2026-04-09 03:30:55.21345	\N	f
260409.001	\N	\N	01 - AN ĐÔNG	loan tbac	0376670275	00 - DỌC ĐƯỜNG	03 - Thùng	2 thùng	\N	0.00	240000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:31:00	\N	2026-04-09 03:31:15.908822	2026-04-09 03:31:15.908822	\N	f
260409.034	\N	\N	01 - AN ĐÔNG	linh	5956	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:31:00	\N	2026-04-09 03:31:27.238642	2026-04-09 03:31:27.238642	\N	f
260409.101	\N	\N	01 - AN ĐÔNG	minh võ	2904	10 - ÔNG ĐÔN	15 - Thùng xốp	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:31:00	\N	2026-04-09 03:31:43.745575	2026-04-09 03:31:43.745575	\N	f
260409.035	\N	\N	01 - AN ĐÔNG	hương	4409	03 - LONG KHÁNH	06 - Kiện	2 kiện	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:32:00	\N	2026-04-09 03:32:05.426916	2026-04-09 03:32:05.426916	\N	f
260409.102	\N	\N	01 - AN ĐÔNG	hường mã vôi	1581	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:32:00	\N	2026-04-09 03:32:22.005539	2026-04-09 03:32:22.005539	\N	f
260409.103	\N	\N	01 - AN ĐÔNG	nguồn	7606	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:32:00	\N	2026-04-09 03:32:31.73482	2026-04-09 03:32:31.73482	\N	f
260409.036	\N	\N	01 - AN ĐÔNG	thảo 60 căn	1	03 - LONG KHÁNH	05 - Bao	\N	\N	0.00	50000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:32:00	\N	2026-04-09 03:32:46.896494	2026-04-09 03:32:46.896494	\N	f
260409.037	\N	\N	01 - AN ĐÔNG	châu	3218	03 - LONG KHÁNH	15 - Thùng xốp	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:32:00	\N	2026-04-09 03:33:00.857903	2026-04-09 03:33:00.857903	\N	f
260409.003	\N	\N	01 - AN ĐÔNG	ngọc tbom	0967503440	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:33:00	\N	2026-04-09 03:33:47.153438	2026-04-09 03:34:02.583807	118	t
260409.004	\N	\N	01 - AN ĐÔNG	thu csat	0919262113	00 - DỌC ĐƯỜNG	03 - Thùng	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:34:00	\N	2026-04-09 03:34:02.28445	2026-04-09 03:34:26.477169	119	t
260409.039	\N	\N	01 - AN ĐÔNG	nhi	7517	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:34:00	\N	2026-04-09 03:34:54.986461	2026-04-09 03:34:54.986461	\N	f
260409.002			01 - AN ĐÔNG	vô danh 30/4	0786022791	00 - DỌC ĐƯỜNG	03 - Thùng		 	0.00	100000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-09 10:33:00	\N	2026-04-09 03:33:22.936138	2026-04-09 04:00:39.401751	117	t
260409.081	\N	\N	01 - AN ĐÔNG	bình	9783	08 - BẢO BÌNH	17 - Hộp	\N	\N	0.00	50000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-04-09 10:34:00	\N	2026-04-09 03:34:25.706237	2026-04-09 04:17:21.57655	\N	f
260409.038	\N	\N	01 - AN ĐÔNG	nhi	7517	03 - LONG KHÁNH	26 - Nhiều loại	2 thùng + 1 kiện	\N	0.00	140000.00	paid	pending	delivered	Staff An Đông	Staff An Đông	\N	2026-04-09 10:34:00	\N	2026-04-09 03:34:47.031332	2026-04-09 04:17:38.912371	\N	f
260410.101	\N	\N	01 - AN ĐÔNG	phượng bảo hòa	5717	10 - ÔNG ĐÔN	03 - Thùng	2 thùng	\N	0.00	240000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:50:00	\N	2026-04-09 22:50:50.044655	2026-04-09 22:50:50.044655	\N	f
260410.061	\N	\N	01 - AN ĐÔNG	vô danh	8450	06 - SÔNG RAY	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:51:00	\N	2026-04-09 22:51:25.286615	2026-04-09 22:51:25.286615	\N	f
260410.131	\N	\N	01 - AN ĐÔNG	phụng tiên	0532	13 - XUÂN HƯNG	03 - Thùng	\N	\N	0.00	120000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:51:00	\N	2026-04-09 22:51:33.973262	2026-04-09 22:51:33.973262	\N	f
260410.031	\N	\N	01 - AN ĐÔNG	quốc	9449	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:51:00	\N	2026-04-09 22:51:42.462356	2026-04-09 22:51:42.462356	\N	f
260410.032	\N	\N	01 - AN ĐÔNG	hiếu mì	1	03 - LONG KHÁNH	05 - Bao	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:51:00	\N	2026-04-09 22:51:46.933426	2026-04-09 22:51:46.933426	\N	f
260410.033	\N	\N	01 - AN ĐÔNG	như	1123	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:51:00	\N	2026-04-09 22:51:54.456752	2026-04-09 22:51:54.456752	\N	f
260410.034	\N	\N	01 - AN ĐÔNG	út danh	1	03 - LONG KHÁNH	03 - Thùng	4 thùng	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:52:00	\N	2026-04-09 22:52:25.453129	2026-04-09 22:52:25.453129	\N	f
260410.035	\N	\N	01 - AN ĐÔNG	lưu an	1	03 - LONG KHÁNH	03 - Thùng	4 thùng	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:52:00	\N	2026-04-09 22:52:33.405538	2026-04-09 22:52:33.405538	\N	f
260410.036	\N	\N	01 - AN ĐÔNG	nhi	7517	03 - LONG KHÁNH	03 - Thùng	2 thùng	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 05:52:00	\N	2026-04-09 22:52:44.289849	2026-04-09 22:52:44.289849	\N	f
260410.081	\N	\N	01 - AN ĐÔNG	nguyên	4154	08 - BẢO BÌNH	15 - Thùng xốp	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:05:00	\N	2026-04-09 23:05:31.202646	2026-04-09 23:05:31.202646	\N	f
260410.037	\N	\N	01 - AN ĐÔNG	hương	4409	03 - LONG KHÁNH	06 - Kiện	2 kiện	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:05:00	\N	2026-04-09 23:05:44.31261	2026-04-09 23:05:44.31261	\N	f
260410.001	\N	\N	01 - AN ĐÔNG	đạt bca	0899465931	00 - DỌC ĐƯỜNG	05 - Bao	\N	\N	0.00	70000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:05:00	\N	2026-04-09 23:05:57.119966	2026-04-09 23:05:59.731288	120	t
260410.102	\N	\N	01 - AN ĐÔNG	liễu	0213	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:04.737288	2026-04-09 23:06:04.737288	\N	f
260410.103	\N	\N	01 - AN ĐÔNG	chi	8816	10 - ÔNG ĐÔN	03 - Thùng	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:11.022251	2026-04-09 23:06:11.022251	\N	f
260410.038	\N	\N	01 - AN ĐÔNG	hiếu	6773	03 - LONG KHÁNH	26 - Nhiều loại	1 thùng + 1 kiện	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:23.397287	2026-04-09 23:06:23.397287	\N	f
260410.039	\N	\N	01 - AN ĐÔNG	thanh bánh bao	1	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:32.488632	2026-04-09 23:06:32.488632	\N	f
260410.0310	\N	\N	01 - AN ĐÔNG	sơn	3773	03 - LONG KHÁNH	06 - Kiện	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:38.96569	2026-04-09 23:06:38.96569	\N	f
260410.111	\N	\N	01 - AN ĐÔNG	huy	6703	11 - XUÂN ĐÀ	04 - Gói	\N	\N	0.00	70000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:06:54.51537	2026-04-09 23:06:54.51537	\N	f
260410.0311	\N	\N	01 - AN ĐÔNG	nam	2847	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:06:00	\N	2026-04-09 23:07:00.885998	2026-04-09 23:07:00.885998	\N	f
260410.0312	\N	\N	01 - AN ĐÔNG	chương hằng	2472	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:07:00	\N	2026-04-09 23:07:14.25166	2026-04-09 23:07:14.25166	\N	f
260410.0313	\N	\N	01 - AN ĐÔNG	tuyến chương	2539	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 06:07:00	\N	2026-04-09 23:07:20.817057	2026-04-09 23:07:20.817057	\N	f
260410.0314	\N	\N	01 - AN ĐÔNG	cô lưu	8878	03 - LONG KHÁNH	03 - Thùng	5thung+2kien+1goi	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 07:21:00	\N	2026-04-10 00:21:13.925533	2026-04-10 00:21:13.925533	\N	f
260410.003	\N	\N	01 - AN ĐÔNG	thảo trị an	0977112382	00 - DỌC ĐƯỜNG	05 - Bao	\N	\N	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 12:26:00	\N	2026-04-10 05:26:15.286188	2026-04-10 05:26:15.286188	\N	f
260410.104			01 - AN ĐÔNG	hồng thư	7279	10 - ÔNG ĐÔN	06 - Kiện		01031	0.00	80000.00	paid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 12:30:00	\N	2026-04-10 05:30:26.257366	2026-04-10 05:51:11.611385	\N	f
260410.0315	\N	\N	01 - AN ĐÔNG	nhi	7517	03 - LONG KHÁNH	03 - Thùng	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 13:54:00	\N	2026-04-10 06:54:37.160928	2026-04-10 06:54:37.160928	\N	f
260410.002	\N	\N	01 - AN ĐÔNG	trung vtau	0937768129	00 - DỌC ĐƯỜNG	15 - Thùng xốp	\N	\N	0.00	100000.00	paid	cancelled	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 12:16:00	\N	2026-04-10 05:16:35.140107	2026-04-10 06:54:50.13057	121	t
260410.0316	\N	\N	01 - AN ĐÔNG	bé chương	1929	03 - LONG KHÁNH	04 - Gói	\N	\N	0.00	1.00	unpaid	pending	pending	Staff An Đông	Staff An Đông	\N	2026-04-10 13:56:00	\N	2026-04-10 06:56:30.341279	2026-04-10 06:56:30.341279	\N	f
\.


--
-- Data for Name: Stations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Stations" (id, code, name, "fullName", address, phone, region, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Users" (id, username, password, "fullName", phone, role, station, active, "createdAt", "updatedAt") FROM stdin;
5	staffad	$2a$10$h.JvzkDKG4pl7FbykLy8QOb2GsxM8O3vBOc6q/pttV.GW3EC2mRf6	Staff An Đông	\N	employee	01 - AN ĐÔNG	t	2026-02-17 12:03:37.646235	2026-02-17 12:03:37.646235
6	stafflk	$2a$10$9bcol.vHGnGy4jrPAIyn2eBoH8OaLOc4s1Xcp.6erRNy6AfG5E652	Staff Long Khánh	\N	employee	03 - LONG KHÁNH	t	2026-02-17 12:03:37.771514	2026-02-17 12:03:37.771514
1	admin	$2a$10$2EvJzqh73dVrq0VHCI26t.MtdO9O2ILFrCYqpErz2gvwszlqA.a6S	Quản trị viên	\N	admin	\N	t	2026-01-18 05:22:00.73978	2026-02-17 12:03:38.004746
7	staffhx	staffhx	Staff Hàng Xanh	\N	employee	02 - HÀNG XANH	t	2026-04-20 23:14:04.185457	2026-04-20 23:14:04.185457
\.


--
-- Name: NH_Counters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."NH_Counters_id_seq"', 195, true);


--
-- Name: NH_ProductLogs_logId_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."NH_ProductLogs_logId_seq"', 259, true);


--
-- Name: NH_Stations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."NH_Stations_id_seq"', 20, true);


--
-- Name: NH_Users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."NH_Users_id_seq"', 7, true);


--
-- Name: Counters NH_Counters_counterKey_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Counters"
    ADD CONSTRAINT "NH_Counters_counterKey_key" UNIQUE ("counterKey");


--
-- Name: Counters NH_Counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Counters"
    ADD CONSTRAINT "NH_Counters_pkey" PRIMARY KEY (id);


--
-- Name: ProductLogs NH_ProductLogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProductLogs"
    ADD CONSTRAINT "NH_ProductLogs_pkey" PRIMARY KEY ("logId");


--
-- Name: Products NH_Products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "NH_Products_pkey" PRIMARY KEY (id);


--
-- Name: Stations NH_Stations_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations"
    ADD CONSTRAINT "NH_Stations_code_key" UNIQUE (code);


--
-- Name: Stations NH_Stations_fullName_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations"
    ADD CONSTRAINT "NH_Stations_fullName_key" UNIQUE ("fullName");


--
-- Name: Stations NH_Stations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Stations"
    ADD CONSTRAINT "NH_Stations_pkey" PRIMARY KEY (id);


--
-- Name: Users NH_Users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "NH_Users_pkey" PRIMARY KEY (id);


--
-- Name: Users NH_Users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "NH_Users_username_key" UNIQUE (username);


--
-- Name: idx_nh_counters_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_counters_key ON public."Counters" USING btree ("counterKey");


--
-- Name: idx_nh_counters_station_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_counters_station_date ON public."Counters" USING btree (station, "dateKey");


--
-- Name: idx_nh_productlogs_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_productlogs_action ON public."ProductLogs" USING btree (action);


--
-- Name: idx_nh_productlogs_changed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_productlogs_changed_at ON public."ProductLogs" USING btree ("changedAt");


--
-- Name: idx_nh_productlogs_product; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_productlogs_product ON public."ProductLogs" USING btree ("productId");


--
-- Name: idx_nh_products_delivery; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_delivery ON public."Products" USING btree ("deliveryStatus");


--
-- Name: idx_nh_products_payment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_payment ON public."Products" USING btree ("paymentStatus");


--
-- Name: idx_nh_products_receiver_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_receiver_phone ON public."Products" USING btree ("receiverPhone");


--
-- Name: idx_nh_products_senddate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_senddate ON public."Products" USING btree ("sendDate");


--
-- Name: idx_nh_products_sender_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_sender_phone ON public."Products" USING btree ("senderPhone");


--
-- Name: idx_nh_products_sender_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_sender_station ON public."Products" USING btree ("senderStation");


--
-- Name: idx_nh_products_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_station ON public."Products" USING btree (station);


--
-- Name: idx_nh_products_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_status ON public."Products" USING btree (status);


--
-- Name: idx_nh_products_synced; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_synced ON public."Products" USING btree ("syncedToTongHop");


--
-- Name: idx_nh_products_vehicle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_products_vehicle ON public."Products" USING btree (vehicle);


--
-- Name: idx_nh_stations_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_stations_active ON public."Stations" USING btree ("isActive");


--
-- Name: idx_nh_stations_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_stations_code ON public."Stations" USING btree (code);


--
-- Name: idx_nh_stations_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_stations_name ON public."Stations" USING btree (name);


--
-- Name: idx_nh_users_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_users_active ON public."Users" USING btree (active);


--
-- Name: idx_nh_users_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_users_station ON public."Users" USING btree (station);


--
-- Name: idx_nh_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nh_users_username ON public."Users" USING btree (username);


--
-- Name: Products trg_nh_products_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_nh_products_updated BEFORE UPDATE ON public."Products" FOR EACH ROW EXECUTE FUNCTION public.update_nh_updated_at();


--
-- Name: Stations trg_nh_stations_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_nh_stations_updated BEFORE UPDATE ON public."Stations" FOR EACH ROW EXECUTE FUNCTION public.update_nh_updated_at();


--
-- Name: Users trg_nh_users_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_nh_users_updated BEFORE UPDATE ON public."Users" FOR EACH ROW EXECUTE FUNCTION public.update_nh_updated_at();


--
-- PostgreSQL database dump complete
--

\unrestrict eccRPF2wMRh3mlfaxCriY2jYKCIA8PwRG5QQ7SqKFxGHE1aqs7fCUdzXpnLYjZI

