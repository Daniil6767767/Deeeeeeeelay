--
-- PostgreSQL database dump
--

\restrict BT9RPFqAfJ31TIREm5VFfky7tSiweWeXBmK5eCiGCxWPY3aZzBjwXztZUfEtDgU

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.4

-- Started on 2026-10-28 14:57:18

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
-- TOC entry 876 (class 1247 OID 17658)
-- Name: d_full_name; Type: DOMAIN; Schema: public; Owner: user1
--

CREATE DOMAIN public.d_full_name AS character varying(100)
	CONSTRAINT d_full_name_check CHECK ((char_length(TRIM(BOTH FROM VALUE)) > 0));


ALTER DOMAIN public.d_full_name OWNER TO user1;

--
-- TOC entry 868 (class 1247 OID 17652)
-- Name: d_login; Type: DOMAIN; Schema: public; Owner: user1
--

CREATE DOMAIN public.d_login AS character varying(50)
	CONSTRAINT d_login_check CHECK ((char_length(TRIM(BOTH FROM VALUE)) >= 3));


ALTER DOMAIN public.d_login OWNER TO user1;

--
-- TOC entry 880 (class 1247 OID 17661)
-- Name: d_name; Type: DOMAIN; Schema: public; Owner: user1
--

CREATE DOMAIN public.d_name AS character varying(50)
	CONSTRAINT d_name_check CHECK ((char_length(TRIM(BOTH FROM VALUE)) > 0));


ALTER DOMAIN public.d_name OWNER TO user1;

--
-- TOC entry 872 (class 1247 OID 17655)
-- Name: d_password_hash; Type: DOMAIN; Schema: public; Owner: user1
--

CREATE DOMAIN public.d_password_hash AS character varying(255)
	CONSTRAINT d_password_hash_check CHECK ((char_length((VALUE)::text) >= 32));


ALTER DOMAIN public.d_password_hash OWNER TO user1;

--
-- TOC entry 884 (class 1247 OID 17664)
-- Name: d_phone; Type: DOMAIN; Schema: public; Owner: user1
--

CREATE DOMAIN public.d_phone AS character varying(16)
	CONSTRAINT d_phone_check CHECK (((VALUE)::text ~ '^\+?[0-9]{10,15}$'::text));


ALTER DOMAIN public.d_phone OWNER TO user1;

--
-- TOC entry 235 (class 1255 OID 17824)
-- Name: prevent_id_change(); Type: FUNCTION; Schema: public; Owner: user1
--

CREATE FUNCTION public.prevent_id_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.id <> OLD.id THEN
        RAISE EXCEPTION 'Изменять id запрещено (таблица %)', TG_TABLE_NAME;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.prevent_id_change() OWNER TO user1;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 17678)
-- Name: contact_groups; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.contact_groups (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.contact_groups OWNER TO user1;

--
-- TOC entry 221 (class 1259 OID 17677)
-- Name: contact_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.contact_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contact_groups_id_seq OWNER TO user1;

--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 221
-- Name: contact_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.contact_groups_id_seq OWNED BY public.contact_groups.id;


--
-- TOC entry 234 (class 1259 OID 17781)
-- Name: contact_requests; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.contact_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    manager_id integer,
    admin_id integer,
    status_id integer DEFAULT 1 NOT NULL,
    last_name public.d_name NOT NULL,
    first_name public.d_name NOT NULL,
    phone public.d_phone NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.contact_requests OWNER TO user1;

--
-- TOC entry 233 (class 1259 OID 17780)
-- Name: contact_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.contact_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contact_requests_id_seq OWNER TO user1;

--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 233
-- Name: contact_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.contact_requests_id_seq OWNED BY public.contact_requests.id;


--
-- TOC entry 230 (class 1259 OID 17732)
-- Name: contacts; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    last_name public.d_name NOT NULL,
    first_name public.d_name NOT NULL,
    group_id integer NOT NULL,
    created_by integer NOT NULL
);


ALTER TABLE public.contacts OWNER TO user1;

--
-- TOC entry 229 (class 1259 OID 17731)
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO user1;

--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 229
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- TOC entry 224 (class 1259 OID 17689)
-- Name: phone_types; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.phone_types (
    id integer NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE public.phone_types OWNER TO user1;

--
-- TOC entry 223 (class 1259 OID 17688)
-- Name: phone_types_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.phone_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.phone_types_id_seq OWNER TO user1;

--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 223
-- Name: phone_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.phone_types_id_seq OWNED BY public.phone_types.id;


--
-- TOC entry 232 (class 1259 OID 17756)
-- Name: phones; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.phones (
    id integer NOT NULL,
    contact_id integer NOT NULL,
    phone_type_id integer NOT NULL,
    number public.d_phone NOT NULL
);


ALTER TABLE public.phones OWNER TO user1;

--
-- TOC entry 231 (class 1259 OID 17755)
-- Name: phones_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.phones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.phones_id_seq OWNER TO user1;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 231
-- Name: phones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.phones_id_seq OWNED BY public.phones.id;


--
-- TOC entry 226 (class 1259 OID 17700)
-- Name: request_statuses; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.request_statuses (
    id integer NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE public.request_statuses OWNER TO user1;

--
-- TOC entry 225 (class 1259 OID 17699)
-- Name: request_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.request_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_statuses_id_seq OWNER TO user1;

--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 225
-- Name: request_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.request_statuses_id_seq OWNED BY public.request_statuses.id;


--
-- TOC entry 220 (class 1259 OID 17667)
-- Name: roles; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE public.roles OWNER TO user1;

--
-- TOC entry 219 (class 1259 OID 17666)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO user1;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 228 (class 1259 OID 17711)
-- Name: users; Type: TABLE; Schema: public; Owner: user1
--

CREATE TABLE public.users (
    id integer NOT NULL,
    login public.d_login NOT NULL,
    password_hash public.d_password_hash NOT NULL,
    full_name public.d_full_name NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO user1;

--
-- TOC entry 227 (class 1259 OID 17710)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: user1
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO user1;

--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user1
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3346 (class 2604 OID 17681)
-- Name: contact_groups id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_groups ALTER COLUMN id SET DEFAULT nextval('public.contact_groups_id_seq'::regclass);


--
-- TOC entry 3352 (class 2604 OID 17784)
-- Name: contact_requests id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests ALTER COLUMN id SET DEFAULT nextval('public.contact_requests_id_seq'::regclass);


--
-- TOC entry 3350 (class 2604 OID 17735)
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- TOC entry 3347 (class 2604 OID 17692)
-- Name: phone_types id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phone_types ALTER COLUMN id SET DEFAULT nextval('public.phone_types_id_seq'::regclass);


--
-- TOC entry 3351 (class 2604 OID 17759)
-- Name: phones id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phones ALTER COLUMN id SET DEFAULT nextval('public.phones_id_seq'::regclass);


--
-- TOC entry 3348 (class 2604 OID 17703)
-- Name: request_statuses id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.request_statuses ALTER COLUMN id SET DEFAULT nextval('public.request_statuses_id_seq'::regclass);


--
-- TOC entry 3345 (class 2604 OID 17670)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 3349 (class 2604 OID 17714)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3552 (class 0 OID 17678)
-- Dependencies: 222
-- Data for Name: contact_groups; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.contact_groups (id, name) FROM stdin;
1	Семья
2	Друзья
3	Работа
4	Клиенты
5	Другое
\.


--
-- TOC entry 3564 (class 0 OID 17781)
-- Dependencies: 234
-- Data for Name: contact_requests; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.contact_requests (id, user_id, manager_id, admin_id, status_id, last_name, first_name, phone, group_id) FROM stdin;
1	57	3	1	3	Иванов	Дмитрий	+79484324669	1
2	82	4	\N	5	Волков	Кирилл	+79024709066	5
3	20	3	\N	4	Козлов	Алексей	+79676246095	4
4	47	5	\N	4	Петров	Анна	+79441105138	4
5	93	2	\N	4	Волков	Дмитрий	+79110425894	4
6	39	3	\N	2	Сидоров	Наталья	+79058213664	5
7	97	2	\N	5	Кузнецов	Елена	+79949451009	5
8	94	5	\N	2	Попов	Светлана	+79848097360	3
9	96	3	\N	2	Волков	Елена	+79825417335	2
10	77	\N	\N	1	Кузнецов	Артём	+79844700343	1
11	35	5	\N	2	Васильев	Елена	+79093498337	2
12	66	3	\N	5	Васильев	Артём	+79255665359	1
13	62	4	1	3	Лебедев	Михаил	+79746744729	4
14	35	\N	\N	1	Лебедев	Татьяна	+79753146806	1
15	91	3	\N	2	Васильев	Кирилл	+79637379272	1
16	41	3	\N	4	Лебедев	Илья	+79725800489	3
17	31	\N	\N	1	Семёнов	Екатерина	+79087269300	2
18	98	2	1	3	Степанов	Екатерина	+79722253780	2
19	18	4	\N	5	Алексеев	Ирина	+79998958321	3
20	75	2	1	3	Алексеев	Артём	+79166426063	2
21	75	3	\N	2	Васильев	Елена	+79617366862	3
22	8	\N	\N	1	Козлов	Юлия	+79462482858	2
23	94	4	\N	4	Попов	Мария	+79054175205	1
24	28	5	\N	4	Соколов	Анна	+79471660410	3
25	63	5	1	3	Волков	Алексей	+79221956419	5
26	14	2	\N	4	Степанов	Илья	+79205354013	1
27	69	4	1	3	Семёнов	Екатерина	+79822375746	3
28	45	2	1	3	Васильев	Андрей	+79167747858	2
29	64	2	\N	4	Попов	Александр	+79747535331	5
30	31	2	\N	5	Морозов	Ольга	+79129143248	5
31	72	5	\N	5	Фёдоров	Алексей	+79096444708	4
32	11	5	1	3	Михайлов	Юлия	+79336384233	1
33	22	4	\N	5	Егоров	Дмитрий	+79757710071	5
34	82	\N	\N	1	Соколов	Илья	+79578132774	1
35	16	4	\N	5	Новиков	Кирилл	+79621609979	1
36	28	5	\N	5	Кузнецов	Ирина	+79317261613	1
37	24	3	1	3	Соколов	Юлия	+79731495109	5
38	86	2	\N	5	Семёнов	Елена	+79863130868	4
39	43	3	\N	5	Фёдоров	Александр	+79121772021	2
40	43	2	\N	2	Кузнецов	Татьяна	+79472153095	4
41	21	3	\N	2	Волков	Юлия	+79893477961	4
42	58	\N	\N	1	Попов	Татьяна	+79267870250	2
43	89	4	\N	4	Егоров	Анна	+79187392606	1
44	28	\N	\N	1	Алексеев	Сергей	+79937723675	3
45	22	4	\N	2	Лебедев	Дмитрий	+79059444182	4
46	37	2	\N	2	Семёнов	Андрей	+79738125445	3
47	37	4	\N	5	Михайлов	Ольга	+79480675887	3
48	31	\N	\N	1	Морозов	Светлана	+79457896487	4
49	6	\N	\N	1	Васильев	Михаил	+79552121397	4
50	11	4	1	3	Козлов	Татьяна	+79100681481	1
51	55	4	\N	4	Новиков	Мария	+79926352256	4
52	80	5	\N	4	Павлов	Светлана	+79958438547	5
53	65	3	\N	5	Алексеев	Ирина	+79454679315	4
54	51	3	\N	4	Смирнов	Мария	+79603139650	2
55	26	2	\N	2	Попов	Сергей	+79536703833	4
56	81	2	\N	4	Васильев	Екатерина	+79622104676	3
57	62	4	\N	2	Васильев	Анна	+79201279269	3
58	55	5	\N	5	Степанов	Екатерина	+79240927122	5
59	99	3	1	3	Новиков	Максим	+79962735641	4
60	59	\N	\N	1	Васильев	Андрей	+79203292701	3
61	12	4	\N	4	Морозов	Михаил	+79760773060	3
62	55	3	\N	5	Соколов	Михаил	+79946074208	5
63	6	2	\N	5	Козлов	Ольга	+79819826195	4
64	48	4	1	3	Морозов	Артём	+79349599642	3
65	68	3	\N	4	Алексеев	Алексей	+79729000053	5
66	38	4	1	3	Васильев	Максим	+79564676059	4
67	96	4	\N	2	Соколов	Елена	+79285623189	3
68	48	3	\N	4	Васильев	Татьяна	+79704656494	1
69	63	5	\N	4	Лебедев	Екатерина	+79094007365	4
70	75	5	1	3	Кузнецов	Максим	+79485812897	2
71	76	4	1	3	Соколов	Екатерина	+79865205082	4
72	36	2	1	3	Павлов	Ольга	+79799034405	4
73	20	3	\N	2	Фёдоров	Александр	+79384181539	3
74	50	5	\N	5	Семёнов	Наталья	+79206191229	2
75	35	\N	\N	1	Михайлов	Екатерина	+79714505721	2
76	53	4	\N	4	Морозов	Светлана	+79676643159	5
77	74	2	\N	4	Попов	Сергей	+79902091272	2
78	83	4	\N	5	Волков	Михаил	+79060027668	5
79	100	\N	\N	1	Лебедев	Наталья	+79475490935	2
80	7	5	\N	4	Васильев	Елена	+79831335220	1
81	64	2	\N	4	Степанов	Екатерина	+79682111612	4
82	81	2	\N	4	Степанов	Екатерина	+79162716440	3
83	60	\N	\N	1	Семёнов	Александр	+79496529743	2
84	37	3	1	3	Васильев	Анна	+79809096542	3
85	14	3	\N	4	Смирнов	Екатерина	+79985662943	3
86	31	5	1	3	Иванов	Ирина	+79352641394	1
87	99	4	\N	2	Козлов	Екатерина	+79486481648	2
88	45	4	\N	2	Попов	Артём	+79317299785	3
89	15	3	\N	2	Попов	Илья	+79542553102	5
90	6	4	\N	4	Степанов	Сергей	+79000349689	1
91	49	4	\N	4	Семёнов	Татьяна	+79837631892	2
92	88	4	\N	5	Новиков	Светлана	+79712039484	2
93	51	\N	\N	1	Соколов	Михаил	+79810039819	3
94	60	\N	\N	1	Соколов	Светлана	+79012275931	5
95	77	4	1	3	Петров	Максим	+79946384302	5
96	53	5	1	3	Петров	Михаил	+79332706260	5
97	95	3	\N	2	Васильев	Дмитрий	+79204564556	3
98	89	2	\N	4	Степанов	Анна	+79555002973	3
99	88	2	\N	4	Алексеев	Максим	+79038888625	2
100	91	5	\N	5	Соколов	Дмитрий	+79951640569	1
101	6	2	1	5	Заявкин	Тимур	+79005556677	1
\.


--
-- TOC entry 3560 (class 0 OID 17732)
-- Dependencies: 230
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.contacts (id, last_name, first_name, group_id, created_by) FROM stdin;
1	Сидоров	Елена	2	39
2	Васильев	Екатерина	2	64
3	Семёнов	Илья	3	86
4	Васильев	Юлия	2	63
5	Васильев	Мария	5	79
6	Соколов	Андрей	5	24
7	Павлов	Юлия	1	58
8	Соколов	Дмитрий	2	8
9	Сидоров	Михаил	1	95
10	Попов	Илья	1	77
11	Васильев	Артём	1	18
12	Васильев	Наталья	4	38
13	Семёнов	Анна	3	65
14	Смирнов	Наталья	1	32
15	Семёнов	Михаил	1	9
16	Соколов	Илья	4	15
17	Новиков	Светлана	1	20
18	Морозов	Илья	3	33
19	Сидоров	Татьяна	5	62
20	Волков	Андрей	5	80
21	Петров	Елена	4	39
22	Васильев	Елена	5	36
23	Морозов	Андрей	3	100
24	Семёнов	Светлана	2	67
25	Новиков	Татьяна	2	44
26	Попов	Елена	1	98
27	Алексеев	Алексей	4	28
28	Морозов	Наталья	5	59
29	Павлов	Михаил	5	51
30	Васильев	Наталья	2	12
31	Волков	Кирилл	2	75
32	Попов	Алексей	1	20
33	Семёнов	Дмитрий	2	10
34	Михайлов	Кирилл	1	53
35	Степанов	Дмитрий	5	5
36	Соколов	Артём	1	34
37	Фёдоров	Михаил	2	57
38	Петров	Сергей	1	59
39	Морозов	Максим	2	8
40	Сидоров	Елена	5	96
41	Кузнецов	Мария	4	51
42	Смирнов	Михаил	1	69
43	Соколов	Анна	3	60
44	Козлов	Дмитрий	4	65
45	Морозов	Светлана	1	2
46	Кузнецов	Мария	3	33
47	Лебедев	Анна	2	86
48	Семёнов	Екатерина	2	68
49	Петров	Ирина	2	16
50	Степанов	Ирина	3	79
51	Волков	Андрей	3	98
52	Сидоров	Анна	4	2
53	Кузнецов	Ольга	1	69
54	Соколов	Анна	3	16
55	Фёдоров	Анна	4	87
56	Алексеев	Светлана	3	48
57	Семёнов	Дмитрий	5	57
58	Алексеев	Елена	4	57
59	Степанов	Ирина	5	49
60	Михайлов	Анна	5	18
61	Сидоров	Анна	2	62
62	Смирнов	Татьяна	2	53
63	Морозов	Илья	1	82
64	Семёнов	Ирина	4	100
65	Егоров	Максим	1	22
66	Фёдоров	Екатерина	2	21
67	Лебедев	Александр	4	2
68	Иванов	Артём	4	15
69	Кузнецов	Мария	1	65
70	Волков	Светлана	2	77
71	Иванов	Светлана	2	90
72	Иванов	Юлия	4	78
73	Семёнов	Михаил	3	8
74	Степанов	Светлана	5	54
75	Соколов	Анна	5	3
76	Кузнецов	Мария	3	45
77	Козлов	Светлана	5	31
78	Новиков	Александр	5	85
79	Лебедев	Мария	1	69
80	Соколов	Дмитрий	5	15
81	Кузнецов	Светлана	4	70
82	Волков	Михаил	4	1
83	Васильев	Сергей	1	100
84	Кузнецов	Максим	3	19
85	Соколов	Андрей	3	73
86	Новиков	Татьяна	4	18
87	Смирнов	Дмитрий	1	51
88	Алексеев	Юлия	1	28
89	Иванов	Елена	3	34
90	Лебедев	Илья	3	68
91	Волков	Александр	1	91
92	Морозов	Александр	5	49
93	Новиков	Илья	1	64
94	Кузнецов	Наталья	1	76
95	Семёнов	Татьяна	1	49
96	Семёнов	Дмитрий	3	32
97	Соколов	Михаил	5	73
98	Васильев	Андрей	5	4
99	Лебедев	Илья	4	21
100	Егоров	Анна	1	82
101	Алексеев	Анна	5	25
102	Петров	Анна	4	93
103	Сидоров	Андрей	3	80
104	Новиков	Наталья	2	65
105	Соколов	Михаил	1	8
106	Соколов	Александр	5	97
107	Степанов	Елена	2	48
108	Козлов	Екатерина	4	52
109	Козлов	Дмитрий	3	28
110	Волков	Максим	3	10
111	Михайлов	Светлана	1	16
112	Алексеев	Юлия	4	54
113	Алексеев	Екатерина	2	19
114	Егоров	Татьяна	1	21
115	Семёнов	Юлия	4	33
116	Иванов	Дмитрий	2	100
117	Лебедев	Артём	2	13
118	Петров	Ирина	4	100
119	Михайлов	Михаил	1	24
120	Смирнов	Татьяна	4	74
121	Тестов	Тимофей	3	1
123	Заявкин	Тимур	1	6
125	Тестов	Тест	1	1
\.


--
-- TOC entry 3554 (class 0 OID 17689)
-- Dependencies: 224
-- Data for Name: phone_types; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.phone_types (id, name) FROM stdin;
1	Мобильный
2	Рабочий
3	Домашний
\.


--
-- TOC entry 3562 (class 0 OID 17756)
-- Dependencies: 232
-- Data for Name: phones; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.phones (id, contact_id, phone_type_id, number) FROM stdin;
1	1	1	+79883724916
2	2	1	+79690642336
3	3	1	+79609700061
4	4	1	+79908771914
5	5	1	+79350924122
6	6	1	+79234886823
7	7	1	+79839393640
8	8	1	+79429453283
9	9	1	+79439938467
10	10	1	+79878483846
11	11	1	+79881977087
12	12	1	+79424627078
13	13	1	+79046919466
14	14	1	+79760117029
15	15	1	+79600224291
16	16	1	+79561178821
17	17	1	+79266798110
18	18	1	+79780678627
19	19	1	+79737597697
20	20	1	+79877559247
21	21	1	+79616711015
22	22	1	+79233479898
23	23	1	+79254318505
24	24	1	+79777586854
25	25	1	+79494535177
26	26	1	+79101650274
27	27	1	+79548927242
28	28	1	+79556984847
29	29	1	+79082850266
30	30	1	+79228116077
31	31	1	+79872363527
32	32	1	+79969180758
33	33	1	+79247728604
34	34	1	+79696286543
35	35	1	+79483490630
36	36	1	+79989316152
37	37	1	+79716980463
38	38	1	+79554004349
39	39	1	+79829256410
40	40	1	+79180217432
41	41	1	+79350655039
42	42	1	+79762996410
43	43	1	+79798987684
44	44	1	+79183936733
45	45	1	+79297327114
46	46	1	+79869930466
47	47	1	+79614831472
48	48	1	+79382339497
49	49	1	+79312448319
50	50	1	+79240201182
51	51	1	+79758793943
52	52	1	+79652404210
53	53	1	+79550647016
54	54	1	+79558813696
55	55	1	+79777842313
56	56	1	+79118240700
57	57	1	+79525188690
58	58	1	+79373168300
59	59	1	+79785807331
60	60	1	+79290617430
61	61	1	+79100561400
62	62	1	+79790920543
63	63	1	+79470363974
64	64	1	+79491333351
65	65	1	+79146128112
66	66	1	+79127005306
67	67	1	+79099468404
68	68	1	+79514781751
69	69	1	+79622454652
70	70	1	+79735635700
71	71	1	+79701437034
72	72	1	+79335279274
73	73	1	+79343781804
74	74	1	+79661989434
75	75	1	+79589231592
76	76	1	+79250502933
77	77	1	+79173633165
78	78	1	+79721306297
79	79	1	+79176192562
80	80	1	+79501761667
81	81	1	+79076834945
82	82	1	+79272702742
83	83	1	+79272347822
84	84	1	+79618858640
85	85	1	+79540559143
86	86	1	+79159015293
87	87	1	+79468732290
88	88	1	+79005807337
89	89	1	+79098214109
90	90	1	+79924429939
91	91	1	+79799689608
92	92	1	+79083921400
93	93	1	+79746823192
94	94	1	+79035741954
95	95	1	+79094134519
96	96	1	+79377705471
97	97	1	+79680016627
98	98	1	+79772797730
99	99	1	+79508466551
100	100	1	+79568126945
101	101	1	+79013134763
102	102	1	+79200413389
103	103	1	+79807594671
104	104	1	+79513234121
105	105	1	+79114414952
106	106	1	+79128809556
107	107	1	+79065884466
108	108	1	+79827543899
109	109	1	+79900120886
110	110	1	+79107457941
111	111	1	+79722786393
112	112	1	+79174583972
113	113	1	+79578336381
114	114	1	+79733041672
115	115	1	+79597882946
116	116	1	+79701254593
117	117	1	+79350952077
118	118	1	+79246741683
119	119	1	+79895178579
120	120	1	+79056055500
121	1	2	+79227845633
122	15	2	+79236650028
123	21	3	+79887337861
124	26	3	+79069865903
125	27	3	+79753908852
126	28	2	+79489137503
127	30	2	+79187448446
128	34	3	+79026009841
129	35	3	+79152014236
130	42	2	+79863978176
131	44	3	+79238059289
132	47	2	+79520753058
133	49	2	+79190030628
134	51	2	+79404299044
135	53	2	+79597382780
136	56	3	+79629846258
137	57	3	+79448201027
138	61	3	+79097883725
139	64	2	+79155329500
140	65	3	+79164116352
141	66	2	+79597952507
142	68	2	+79127842873
143	69	3	+79904996451
144	70	3	+79718124071
145	72	3	+79362742167
146	75	3	+79154274428
147	76	2	+79639116122
148	77	3	+79426720693
149	78	3	+79493035844
150	80	3	+79753160212
151	81	2	+79234851739
152	90	2	+79933916879
153	92	3	+79960013590
154	94	3	+79592410927
155	97	3	+79643757815
156	102	3	+79704921706
157	107	3	+79492541974
158	110	2	+79205932459
159	111	3	+79435065051
160	112	3	+79249408281
161	115	3	+79728741976
162	121	1	+79007654321
163	123	1	+79005556677
165	125	1	+79001234567
\.


--
-- TOC entry 3556 (class 0 OID 17700)
-- Dependencies: 226
-- Data for Name: request_statuses; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.request_statuses (id, name) FROM stdin;
1	Новая
2	Принята менеджером
3	Изменена администратором
4	Отклонена
5	Выполнена
\.


--
-- TOC entry 3550 (class 0 OID 17667)
-- Dependencies: 220
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.roles (id, name) FROM stdin;
1	Администратор
2	Менеджер
3	Пользователь
\.


--
-- TOC entry 3558 (class 0 OID 17711)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: user1
--

COPY public.users (id, login, password_hash, full_name, role_id) FROM stdin;
1	admin	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Администратор Системы	1
2	manager1	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Менеджер 1	2
3	manager2	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Менеджер 2	2
4	manager3	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Менеджер 3	2
5	manager4	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Менеджер 4	2
6	user1	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Кирилл	3
7	user2	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Алексей	3
8	user3	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Сидоров Наталья	3
9	user4	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Попов Мария	3
10	user5	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Екатерина	3
11	user6	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Павлов Елена	3
12	user7	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Максим	3
13	user8	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Татьяна	3
14	user9	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Степанов Михаил	3
15	user10	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Андрей	3
16	user11	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Михайлов Кирилл	3
17	user12	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Морозов Кирилл	3
18	user13	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Дмитрий	3
19	user14	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Павлов Артём	3
20	user15	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Степанов Александр	3
21	user16	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Михаил	3
22	user17	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Сергей	3
23	user18	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Наталья	3
24	user19	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Козлов Светлана	3
25	user20	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Юлия	3
26	user21	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новиков Илья	3
27	user22	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Соколов Михаил	3
28	user23	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Анна	3
29	user24	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Павлов Алексей	3
30	user25	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Лебедев Максим	3
31	user26	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Алексей	3
32	user27	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Татьяна	3
33	user28	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Попов Елена	3
34	user29	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Егоров Михаил	3
35	user30	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Мария	3
36	user31	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Петров Артём	3
37	user32	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Егоров Кирилл	3
38	user33	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Смирнов Михаил	3
39	user34	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Дмитрий	3
40	user35	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Иванов Илья	3
41	user36	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Смирнов Сергей	3
42	user37	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Сидоров Мария	3
43	user38	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Светлана	3
44	user39	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Михайлов Мария	3
45	user40	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Ирина	3
46	user41	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Сидоров Михаил	3
47	user42	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Козлов Ирина	3
48	user43	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Артём	3
49	user44	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Светлана	3
50	user45	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Михаил	3
51	user46	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новиков Кирилл	3
52	user47	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Илья	3
53	user48	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Алексеев Илья	3
54	user49	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Ольга	3
55	user50	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Алексеев Мария	3
56	user51	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Морозов Татьяна	3
57	user52	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новиков Татьяна	3
58	user53	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Степанов Артём	3
59	user54	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Лебедев Артём	3
60	user55	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Михайлов Максим	3
61	user56	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Екатерина	3
62	user57	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Павлов Мария	3
63	user58	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Кирилл	3
64	user59	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Михайлов Анна	3
65	user60	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Смирнов Ирина	3
66	user61	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Кузнецов Мария	3
67	user62	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Сидоров Наталья	3
68	user63	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Алексеев Екатерина	3
69	user64	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Козлов Илья	3
70	user65	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Михаил	3
71	user66	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Кузнецов Ольга	3
72	user67	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Сидоров Елена	3
73	user68	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Алексей	3
74	user69	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Петров Максим	3
75	user70	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Кирилл	3
76	user71	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Смирнов Екатерина	3
77	user72	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Егоров Андрей	3
78	user73	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Дмитрий	3
79	user74	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Александр	3
80	user75	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новиков Александр	3
81	user76	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Максим	3
82	user77	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Васильев Алексей	3
83	user78	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Ольга	3
84	user79	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Андрей	3
85	user80	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Лебедев Дмитрий	3
86	user81	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Лебедев Елена	3
87	user82	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Кузнецов Артём	3
88	user83	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Юлия	3
89	user84	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новиков Наталья	3
90	user85	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Алексеев Михаил	3
91	user86	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Егоров Анна	3
92	user87	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Фёдоров Светлана	3
93	user88	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Кузнецов Анна	3
94	user89	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Смирнов Сергей	3
95	user90	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Максим	3
96	user91	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Козлов Илья	3
97	user92	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Волков Татьяна	3
98	user93	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Петров Екатерина	3
99	user94	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Лебедев Андрей	3
100	user95	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Семёнов Сергей	3
101	newuser	8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92	Новый Пользователь	2
\.


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 221
-- Name: contact_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.contact_groups_id_seq', 5, true);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 233
-- Name: contact_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.contact_requests_id_seq', 101, true);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 229
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.contacts_id_seq', 125, true);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 223
-- Name: phone_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.phone_types_id_seq', 3, true);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 231
-- Name: phones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.phones_id_seq', 165, true);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 225
-- Name: request_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.request_statuses_id_seq', 5, true);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 219
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user1
--

SELECT pg_catalog.setval('public.users_id_seq', 101, true);


--
-- TOC entry 3359 (class 2606 OID 17687)
-- Name: contact_groups contact_groups_name_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_groups
    ADD CONSTRAINT contact_groups_name_key UNIQUE (name);


--
-- TOC entry 3361 (class 2606 OID 17685)
-- Name: contact_groups contact_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_groups
    ADD CONSTRAINT contact_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3383 (class 2606 OID 17796)
-- Name: contact_requests contact_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 3375 (class 2606 OID 17744)
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 3363 (class 2606 OID 17698)
-- Name: phone_types phone_types_name_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phone_types
    ADD CONSTRAINT phone_types_name_key UNIQUE (name);


--
-- TOC entry 3365 (class 2606 OID 17696)
-- Name: phone_types phone_types_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phone_types
    ADD CONSTRAINT phone_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3379 (class 2606 OID 17769)
-- Name: phones phones_contact_id_number_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_contact_id_number_key UNIQUE (contact_id, number);


--
-- TOC entry 3381 (class 2606 OID 17767)
-- Name: phones phones_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_pkey PRIMARY KEY (id);


--
-- TOC entry 3367 (class 2606 OID 17709)
-- Name: request_statuses request_statuses_name_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.request_statuses
    ADD CONSTRAINT request_statuses_name_key UNIQUE (name);


--
-- TOC entry 3369 (class 2606 OID 17707)
-- Name: request_statuses request_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.request_statuses
    ADD CONSTRAINT request_statuses_pkey PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 17676)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 3357 (class 2606 OID 17674)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3371 (class 2606 OID 17725)
-- Name: users users_login_key; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_login_key UNIQUE (login);


--
-- TOC entry 3373 (class 2606 OID 17723)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3376 (class 1259 OID 17822)
-- Name: idx_contacts_name; Type: INDEX; Schema: public; Owner: user1
--

CREATE INDEX idx_contacts_name ON public.contacts USING btree (last_name, first_name);


--
-- TOC entry 3377 (class 1259 OID 17823)
-- Name: idx_phones_number; Type: INDEX; Schema: public; Owner: user1
--

CREATE INDEX idx_phones_number ON public.phones USING btree (number);


--
-- TOC entry 3395 (class 2620 OID 17826)
-- Name: contact_groups trg_contact_groups_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_contact_groups_id BEFORE UPDATE OF id ON public.contact_groups FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3401 (class 2620 OID 17832)
-- Name: contact_requests trg_contact_requests_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_contact_requests_id BEFORE UPDATE OF id ON public.contact_requests FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3399 (class 2620 OID 17830)
-- Name: contacts trg_contacts_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_contacts_id BEFORE UPDATE OF id ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3396 (class 2620 OID 17827)
-- Name: phone_types trg_phone_types_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_phone_types_id BEFORE UPDATE OF id ON public.phone_types FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3400 (class 2620 OID 17831)
-- Name: phones trg_phones_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_phones_id BEFORE UPDATE OF id ON public.phones FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3397 (class 2620 OID 17828)
-- Name: request_statuses trg_request_statuses_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_request_statuses_id BEFORE UPDATE OF id ON public.request_statuses FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3394 (class 2620 OID 17825)
-- Name: roles trg_roles_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_roles_id BEFORE UPDATE OF id ON public.roles FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3398 (class 2620 OID 17829)
-- Name: users trg_users_id; Type: TRIGGER; Schema: public; Owner: user1
--

CREATE TRIGGER trg_users_id BEFORE UPDATE OF id ON public.users FOR EACH ROW EXECUTE FUNCTION public.prevent_id_change();


--
-- TOC entry 3389 (class 2606 OID 17807)
-- Name: contact_requests contact_requests_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id);


--
-- TOC entry 3390 (class 2606 OID 17817)
-- Name: contact_requests contact_requests_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.contact_groups(id);


--
-- TOC entry 3391 (class 2606 OID 17802)
-- Name: contact_requests contact_requests_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id);


--
-- TOC entry 3392 (class 2606 OID 17812)
-- Name: contact_requests contact_requests_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.request_statuses(id);


--
-- TOC entry 3393 (class 2606 OID 17797)
-- Name: contact_requests contact_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contact_requests
    ADD CONSTRAINT contact_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3385 (class 2606 OID 17750)
-- Name: contacts contacts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 3386 (class 2606 OID 17745)
-- Name: contacts contacts_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.contact_groups(id);


--
-- TOC entry 3387 (class 2606 OID 17770)
-- Name: phones phones_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- TOC entry 3388 (class 2606 OID 17775)
-- Name: phones phones_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_types(id);


--
-- TOC entry 3384 (class 2606 OID 17726)
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user1
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


-- Completed on 2026-10-28 14:57:18

--
-- PostgreSQL database dump complete
--

\unrestrict BT9RPFqAfJ31TIREm5VFfky7tSiweWeXBmK5eCiGCxWPY3aZzBjwXztZUfEtDgU

