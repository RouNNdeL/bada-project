-- Table companies

CREATE TABLE companies
(
    company_id         SERIAL,
    name               VARCHAR(75)  NOT NULL,
    nip                CHAR(13)     NOT NULL,
    establishment_date TIMESTAMP(0) NOT NULL,
    krs                CHAR(10)     NOT NULL,
    parent_company_id  INTEGER DEFAULT NULL,
    hq_address_id      INTEGER      NOT NULL,
    tax_address_id     INTEGER      NOT NULL
);


CREATE INDEX IX_fk_parent_company ON companies (parent_company_id);


CREATE INDEX IX_fk_has_hq ON companies (hq_address_id);


CREATE INDEX IX_fk_has_tax_address ON companies (tax_address_id);


ALTER TABLE companies
    ADD CONSTRAINT company_id_key PRIMARY KEY (company_id);


ALTER TABLE companies
    ADD CONSTRAINT nip_key UNIQUE (nip);


ALTER TABLE companies
    ADD CONSTRAINT krs_key UNIQUE (krs);

-- Table warehouses

CREATE TABLE warehouses
(
    warehouse_id           SERIAL,
    capacity               DOUBLE PRECISION NOT NULL,
    number_of_loading_bays INTEGER          NOT NULL,
    is_retail              CHAR(1)          NOT NULL,
    company_id             INTEGER          NOT NULL,
    address_id             INTEGER          NOT NULL,
    manager_id             INTEGER DEFAULT NULL
);


CREATE INDEX IX_fk_company_has_warehouse ON warehouses (company_id);


CREATE INDEX IX_warehouse_has_address ON warehouses (address_id);


CREATE INDEX IX_manages ON warehouses (manager_id);


ALTER TABLE warehouses
    ADD CONSTRAINT warehouse_id_key PRIMARY KEY (warehouse_id);

-- Table employees

CREATE TABLE employees
(
    employee_id     SERIAL,
    first_name      VARCHAR(30)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    pesel           CHAR(11)     NOT NULL,
    employment_date TIMESTAMP(0) NOT NULL,
    phone_number    VARCHAR(20)  NOT NULL,
    company_id      INTEGER      NOT NULL,
    warehouse_id    INTEGER DEFAULT NULL,
    user_id         INTEGER      NOT NULL,
    address_id      INTEGER      NOT NULL
);


CREATE INDEX IX_fk_company_employs ON employees (company_id);


CREATE INDEX IX_fk_works_in ON employees (warehouse_id);


CREATE INDEX IX_fk_employee_is_user ON employees (user_id);


CREATE INDEX IX_fk_employee_has_address ON employees (address_id);


ALTER TABLE employees
    ADD CONSTRAINT employee_id_key PRIMARY KEY (employee_id);

-- Table items

CREATE TABLE items
(
    item_id     SERIAL,
    name        VARCHAR(100) NOT NULL,
    description TEXT
);


ALTER TABLE items
    ADD CONSTRAINT item_id_key PRIMARY KEY (item_id);

-- Table price_ranges

CREATE TABLE price_ranges
(
    item_id      SERIAL,
    min_quantity INTEGER        NOT NULL
        CONSTRAINT min_quantity_greater_0 CHECK (min_quantity >= 0),
    max_quantity INTEGER,
    price        DECIMAL(10, 2) NOT NULL
        CONSTRAINT price_geq_0 CHECK (price > 0),
    CONSTRAINT min_leq_max CHECK (min_quantity <= max_quantity)
);


CREATE INDEX IX_fk_has_price_range ON price_ranges (item_id);


ALTER TABLE price_ranges
    ADD CONSTRAINT key1 PRIMARY KEY (item_id,
                                     min_quantity);

-- Table customers

CREATE TABLE customers
(
    customer_id  SERIAL,
    user_id      INTEGER     NOT NULL,
    first_name   VARCHAR(30) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    nip          CHAR(13),
    phone_number VARCHAR(20),
    company_id   INTEGER     NOT NULL,
    address_id   INTEGER DEFAULT NULL
);


CREATE INDEX IX_fk_customer_has_address ON customers (address_id);


CREATE INDEX IX_fk_is_customer_of ON customers (company_id);


ALTER TABLE customers
    ADD CONSTRAINT Unique_Identifier3 PRIMARY KEY (customer_id,
                                                   user_id);

-- Table orders

CREATE TABLE orders
(
    order_id      SERIAL,
    order_date    TIMESTAMP(0) NOT NULL,
    status        VARCHAR(20)  NOT NULL
        CONSTRAINT status_constraint
            CHECK (status in
                   ('RECEIVED',
                    'IN_PROGRESS',
                    'READY_FOR_SHIPMENT',
                    'COMPLETED')),
    shipping_cost DECIMAL(10, 2),
    customer_id   INTEGER      NOT NULL,
    address_id    INTEGER      NOT NULL,
    user_id       INTEGER DEFAULT NULL
);


CREATE INDEX IX_fk_places_order ON orders (customer_id, user_id);


CREATE INDEX IX_is_ordered_to ON orders (address_id);


ALTER TABLE orders
    ADD CONSTRAINT order_id_key PRIMARY KEY (order_id);

-- Table categories

CREATE TABLE categories
(
    category_id SERIAL,
    name        VARCHAR(30) NOT NULL,
    description TEXT
);


ALTER TABLE categories
    ADD CONSTRAINT category_id_key PRIMARY KEY (category_id);


CREATE TABLE items_categories
(
    item_id     SERIAL,
    category_id INTEGER NOT NULL
);


CREATE TABLE orders_employees
(
    order_id    SERIAL,
    employee_id INTEGER NOT NULL,
    ROLE        VARCHAR(30)
);

-- Table orders_items

CREATE TABLE orders_items
(
    order_id              SERIAL,
    item_id               INTEGER NOT NULL,
    ordered_item_quantity INTEGER NOT NULL
);


CREATE TABLE warehouses_items
(
    item_id       SERIAL,
    warehouse_id  INTEGER NOT NULL,
    item_quantity INTEGER NOT NULL
);

-- Table addresses

CREATE TABLE addresses
(
    address_id     SERIAL,
    address_line_1 VARCHAR(100) NOT NULL,
    address_line_2 VARCHAR(50),
    zipcode        VARCHAR(15),
    state          VARCHAR(30),
    country_id     INTEGER      NOT NULL
);


CREATE INDEX IX_fk_address_country ON addresses (country_id);


ALTER TABLE addresses
    ADD CONSTRAINT PK_addresses PRIMARY KEY (address_id);

-- Table countries

CREATE TABLE countries
(
    country_id   SERIAL,
    country_name VARCHAR(56) NOT NULL,
    iso_3166_1   CHAR(2)     NOT NULL,
    phone_prefix VARCHAR(3)  NOT NULL
);


ALTER TABLE countries
    ADD CONSTRAINT PK_countries PRIMARY KEY (country_id);


ALTER TABLE countries
    ADD CONSTRAINT country_name UNIQUE (country_name);


ALTER TABLE countries
    ADD CONSTRAINT iso_3166_1 UNIQUE (iso_3166_1);


ALTER TABLE countries
    ADD CONSTRAINT phone_prefix UNIQUE (phone_prefix);

-- Table salaries

CREATE TABLE salaries
(
    salary_id   SERIAL,
    salary_date TIMESTAMP(0)     NOT NULL,
    salary      DOUBLE PRECISION NOT NULL,
    employee_id INTEGER          NOT NULL
);


CREATE INDEX IX_fk_is_paid ON salaries (employee_id);


ALTER TABLE salaries
    ADD CONSTRAINT PK_salaries PRIMARY KEY (salary_id);

-- Table scores

CREATE TABLE scores
(
    score_id      SERIAL,
    score_year    INTEGER          NOT NULL,
    score_quarter INTEGER          NOT NULL
        CONSTRAINT one_leq_quarter_leq_4 CHECK (score_quarter <= 4
            AND score_quarter >= 1),
    score         DOUBLE PRECISION NOT NULL,
    employee_id   INTEGER          NOT NULL
);


CREATE INDEX IX_fk_is_reviewed ON scores (employee_id);


ALTER TABLE scores
    ADD CONSTRAINT PK_scores PRIMARY KEY (score_id);


CREATE TABLE platform_users
(
    user_id     SERIAL,
    username    VARCHAR(20)             NOT NULL,
    password    CHAR(76)                NOT NULL,
    email       VARCHAR(50)             NOT NULL,
    permissions VARCHAR(256) DEFAULT '' NOT NULL
);


ALTER TABLE platform_users
    ADD CONSTRAINT PK_platform_users PRIMARY KEY (user_id);


ALTER TABLE platform_users
    ADD CONSTRAINT Username UNIQUE (username);


ALTER TABLE companies
    ADD CONSTRAINT fk_parent_company
        FOREIGN KEY (parent_company_id) REFERENCES companies (company_id);


ALTER TABLE warehouses
    ADD CONSTRAINT fk_company_has_warehouse
        FOREIGN KEY (company_id) REFERENCES companies (company_id);


ALTER TABLE orders
    ADD CONSTRAINT fk_places_order
        FOREIGN KEY (customer_id,
                     user_id) REFERENCES customers (customer_id, user_id);


ALTER TABLE employees
    ADD CONSTRAINT fk_company_employs
        FOREIGN KEY (company_id) REFERENCES companies (company_id);


ALTER TABLE price_ranges
    ADD CONSTRAINT fk_has_price_range
        FOREIGN KEY (item_id) REFERENCES items (item_id);


ALTER TABLE items_categories
    ADD CONSTRAINT fk_is_in_category_items
        FOREIGN KEY (item_id) REFERENCES items (item_id);


ALTER TABLE items_categories
    ADD CONSTRAINT fk_is_in_category_categories
        FOREIGN KEY (category_id) REFERENCES categories (category_id);


ALTER TABLE orders_employees
    ADD CONSTRAINT fk_handles_order_orders
        FOREIGN KEY (order_id) REFERENCES orders (order_id);


ALTER TABLE orders_employees
    ADD CONSTRAINT fk_handles_order_employees
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id);


ALTER TABLE employees
    ADD CONSTRAINT fk_works_in
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id);


ALTER TABLE orders_items
    ADD CONSTRAINT fk_is_ordered_orders
        FOREIGN KEY (order_id) REFERENCES orders (order_id);


ALTER TABLE orders_items
    ADD CONSTRAINT fk_is_ordered_items
        FOREIGN KEY (item_id) REFERENCES items (item_id);


ALTER TABLE warehouses_items
    ADD CONSTRAINT fk_is_in_stock_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id);


ALTER TABLE warehouses_items
    ADD CONSTRAINT fk_is_in_stock_items
        FOREIGN KEY (item_id) REFERENCES items (item_id);


ALTER TABLE addresses
    ADD CONSTRAINT fk_is_in_country
        FOREIGN KEY (country_id) REFERENCES countries (country_id);


ALTER TABLE customers
    ADD CONSTRAINT fk_customer_address
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);


ALTER TABLE companies
    ADD CONSTRAINT fk_has_hq
        FOREIGN KEY (hq_address_id) REFERENCES addresses (address_id);


ALTER TABLE companies
    ADD CONSTRAINT fk_has_tax_address
        FOREIGN KEY (tax_address_id) REFERENCES addresses (address_id);


ALTER TABLE warehouses
    ADD CONSTRAINT fk_warehouse_has_address
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);


ALTER TABLE orders
    ADD CONSTRAINT fk_is_ordered_to
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);


ALTER TABLE warehouses
    ADD CONSTRAINT Manages
        FOREIGN KEY (manager_id) REFERENCES employees (employee_id);


ALTER TABLE customers
    ADD CONSTRAINT is_customer_of
        FOREIGN KEY (company_id) REFERENCES companies (company_id);


ALTER TABLE salaries
    ADD CONSTRAINT is_paid
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id);


ALTER TABLE scores
    ADD CONSTRAINT is_reviewed
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id);


ALTER TABLE employees
    ADD CONSTRAINT fk_employee_is_user
        FOREIGN KEY (user_id) REFERENCES platform_users (user_id);


ALTER TABLE customers
    ADD CONSTRAINT fk_customer_is_user
        FOREIGN KEY (user_id) REFERENCES platform_users (user_id);


ALTER TABLE employees
    ADD CONSTRAINT fk_employee_has_address
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);


INSERT INTO platform_users (username, password, email, permissions)
VALUES ('cburchill0', '012345678912cac15da37073ec5849d6a14edb69cad68423b9e66af466d22bac56f737a5f93f',
        'rblackaller0@soup.io', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bhavercroft1', '012345678912f4e55b9659df06a7de7b594d30bd9110bc78d83a1177eb025734e1f469042470',
        'ycourtliff1@omniture.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jchalcroft2', '012345678912f11a5b9e2d3d8926097ed4786dabe8ed4dc24157cba61d02a5e195a94eebc3d3',
        'ekindleside2@nih.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('agillings3', '0123456789123ce17c4c0a9b68a353d114183a42ea3786cdfed81de11162978ea4f2379e7194',
        'aeglaise3@photobucket.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rtrippack4', '0123456789123ecaf430674c9f86c15c44b0ef209ab59b72c74aa5c9a1e1310a040ebf6c5c5f',
        'cionnidis4@xinhuanet.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rscones5', '01234567891299cc731f38a949f69f45323ba654010ebfd25a192b686e96077dc3d8bee621de',
        'eduferie5@t-online.de', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('vratcliffe6', '01234567891238f7045670deaf9913b9c1ac8a5696ee770a0b5d97a3a9db93a183568b6e74fa',
        'cspyby6@senate.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('blux7', '012345678912335ab27157fbe76947ba5bf3f407b763cfa8976a34f5c14d2665ce962159ea94',
        'kchamney7@skyrock.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lsoff8', '01234567891274a8f2bfaf3c10c8d6f73f2e672f23e3df1e4ee16c4d82d307611ea449d50c87', 'ipusey8@msn.com',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('fgaley9', '012345678912ce1b408aef990f1f20301eb6e3db26912ef337d0104886dbdc455def7cc89543',
        'mucchino9@constantcontact.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('smaletratta', '01234567891265607b08ed10e2753fcba35515d856ba0cad7a58d585b3c24f0fcb8927aa28b8',
        'kmillsona@unblog.fr', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('fcutbushb', '012345678912a3d67756be3be98fede10babf3f4a20a4827baf29f35380cafde39deebf68f3a',
        'kkinchingtonb@forbes.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('kbutterickc', '012345678912e58a6b60f5c732709a8f226eb8a55d6f8ad90e9ca64e917a9a7fab82e762e3fa',
        'ssmullinc@google.cn', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mdotterilld', '012345678912da7a4e6ef79749a551b27b44eea85395f28a682d3abff8ad46c6ad8204a9bb34',
        'dcauldwelld@friendfeed.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rbewshawe', '0123456789122b110bb969cdff61c7e67ea56d20178d095de3086f9da8be7ac098626b157e1a', 'eraddane@i2i.jp',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('iniessenf', '0123456789121d22c263d9789dc4427be7892fa9869c9b1d8a7afd6310b27b0f4b9b32d0b9b4',
        'wpacquetf@buzzfeed.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tgrammerg', '01234567891293272972ad98a08be61e3c5eb0eb15f0d75fbac89bb6a92099ce0f9afd2f91e3',
        'dleverittg@cbslocal.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bburrash', '012345678912a0f76bebea342dc9f8ac0670b28e4176dadb3417a2f83fa2254025f3f15a3487',
        'jknowlingh@oracle.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('aoloinni', '012345678912fbc39242d02512fc1bd441931d41e40a2f318b9dc2a3f9e82055df4aee9da56f',
        'khandleyi@weebly.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dfeenanj', '0123456789123422082f0d63e29b6a992a1aec735ef7a6a72f420069068bbc825544eccde210',
        'livankovicj@dedecms.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('kdorkink', '012345678912170dccf93fd5fe1eeef523c5840fab50a2462f4f37effa049c53ba9daf51edb6',
        'bthackrayk@chronoengine.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('avynehalll', '0123456789129c59e3a7384d6a86aae9d8b8988e859be3440be6fd07fd90e2ffbc0115c52f1b',
        'graynhaml@umn.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hirdalem', '0123456789125279391ba1978a3d14a9ebeb9c1ec9dabc08d1a30edcd29c217156e85385f23d',
        'ggrinstonm@typepad.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('kphilipetn', '0123456789124ab506ec27b092b757a1715333242b86c2b6fe8c5b1888be19a28023329541d4',
        'drubinekn@amazon.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('efeldbaumo', '0123456789128709bb426bd5ad15d86469ec4bf5441a02396ea34487e0c381598b8a05f341b6',
        'jmacelroyo@virginia.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hhorsewoodp', '012345678912bdf6d0c26bc098287a9dbb267e2eac765ae837862f6def936174d6ec328e6251',
        'rglaisterp@theatlantic.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('phulleq', '0123456789123a11e6f33d5f76f3edf187cf671db1868d7dc77240df52db2d8dfb4d824c8679',
        'rbensteadq@google.com.hk', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tbrownscomber', '012345678912d516d85638b4cda577b89079d0502057c32a612451152962bd8972a6b6c839dc',
        'fdenslowr@cam.ac.uk', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('wmarkes', '01234567891264d65479463e1e3cd5852efa44ddc30d586147722dc41a9f1a87758b12449634', 'plomiss@blogs.com',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jjakuszewskit', '0123456789121959b03612ed49ddd4891113593a263854900da0bb1f3e6d6f5008b53dcdc178',
        'kpackingtont@etsy.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('apickeringu', '012345678912272578c8c5e4001b0b55d886c9739fa302de5daf81f533e71bef6d9097c11279',
        'garelesu@webs.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bstenhousev', '012345678912a5dae4d8b3632bb9fddc4e2cfe4e410482c07d1f2571874c9ec36871f92ffd33',
        'cpiggotv@mapquest.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bbellw', '01234567891271a3a92b997400c327f0d05d89a07ade77d06b94ca55501d4c79dc834d1c0652',
        'dfloresw@prnewswire.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bkalinowskyx', '0123456789128f8d12d8088950a8f00b721e787c292bca785bc7cfebf29d7a226b9fd0a66cb9',
        'cwaumsleyx@ucsd.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jcockshuty', '012345678912c6e720e73fd7f6172c7704739f63431bda487a061ec512f0a2a8c26869f5d517',
        'kcamposy@edublogs.org', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hrodnightz', '012345678912a0c31ceae813628f75b5f692d6bf5cb4341d620e98fe1e44eb5dab5c69c5e653',
        'cklimczakz@sciencedaily.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hwinterbourne10', '012345678912d60b0ff925411093ee48b1451a6a14fcd8b331c80ee9c90932a099f6a09ab832',
        'mbarron10@bing.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ghaydn11', '01234567891231447ba7242e27cd05fae4ae6310f1f6579892b89c7f595c1eb7731734c87279',
        'lolifaunt11@woothemes.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tbaguley12', '01234567891244caa14487309a5a9452246f21006f53412e80cac856dc09f03e4ded87288e4e',
        'pblue12@china.com.cn', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rigounet13', '012345678912e9a210bb92cfcb62b39e13b6454350f9784b324fa931f25fe66ed18fad2aea36',
        'atuft13@webmd.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('noshevlin14', '01234567891248cf893d5c004907dcce4bc6e50dfb56e8267ba471bfbc147c6b220c3c50a407',
        'braiston14@pbs.org', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ojelleman15', '012345678912199717f9176888c5690d5b868c1a2d74893dd3155898ee0e41a38553f8a70b0f',
        'lblundan15@bluehost.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('yhobell16', '0123456789122d9f36464e697a6b6e547530ed06021bf5391bea0643b05e618f63c3ee7be295',
        'otollerfield16@mayoclinic.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jfarquar17', '0123456789127e39540dc4beb93e3d41037025e21e45ba58e24b4dafad0bf2672ff77991f94a',
        'bagott17@hibu.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mpetrelli18', '0123456789128a63f3cec27403ea0b3fd07355a7c6a8dcabcd5c6d79b54322b00f7cf4b9b82c',
        'askentelbury18@ow.ly', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('sochterlony19', '01234567891203148480468cf95446f5696c88c17a42cfdb9ed2854e5a77322fff1c797e71e8',
        'kschruyers19@ted.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('vwarstall1a', '012345678912a77a831d808b9efc39b4f43d1ed7e9612bacb899c8e4f8de4661f3b99e2e8c9f',
        'cwarters1a@oracle.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bmark1b', '01234567891252a432483abf00b25dcc14c34fb76664675faa7ffd0f04f56150033c949976cd',
        'cmarlon1b@chron.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ctagg1c', '012345678912515e52aa8b414b5cde54fec803cecad4b06d52740eb2832ad09b50dde1a9975f',
        'mmcmylor1c@netvibes.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('shay1d', '012345678912133c9f1d78be26f7014416a148116cd9e5914ec92e883a65ee0c3a1b8c74bce6', 'bcoysh1d@nifty.com',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dchidzoy1e', '01234567891286801de344ec76e4f59d14ef0dda7c0dc64b48d36bb2055e34fe9089fca111fc',
        'frolfe1e@virginia.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mwindaybank1f', '01234567891213af1d3798acefa68a8b358d8bb6f15ccfe9931f04e41f8592707d04999198cd',
        'dstairmand1f@furl.net', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jdrinan1g', '012345678912dad75a6ad8084defd5304a8e8ffd8f686354b7e0497dedc2b6966948c1a8db9f',
        'tbogays1g@telegraph.co.uk', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('prooksby1h', '01234567891280d45424908bb14128b8747b778ebcf8e1321b4dfb46af69f39346f904176b13',
        'sbertl1h@blinklist.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mtanzer1i', '012345678912ad81dfb937f2d6501c6453d694f6c228f82551e66406bc67ac3d9ffd087d91fd',
        'jrudolph1i@engadget.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mmohan1j', '01234567891221ba69aa6dfd388482f245c356cf213e57ba97d2dd1f7ca8363a61333e21ecba',
        'khambleton1j@slashdot.org', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mmccalum1k', '012345678912917e8ad5185dc8151da2a08239dd286df5fc0edc0e5a24c732d846ed69e1f3fd',
        'eescofier1k@wp.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('spatley1l', '012345678912994f5f9a39e270742052a95be9067c457bc923678499b452a90338d06b1522f7',
        'kleipoldt1l@fema.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lbendix1m', '0123456789128ca5b5c1c2c577d2731ede43ea65732b1145a1777e106ed1b5ce636d2e2fdd20',
        'kjayume1m@vkontakte.ru', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bfolger1n', '0123456789125e3f5e12cc9f640565d8622160aa206fd05ab3616c79e21584de8b9db8d38b5d',
        'mdoddridge1n@va.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('gthews1o', '0123456789129ef7392779647ca22861619ad2f31b8afe65064899cef6d52f1363da46c1529e',
        'emarcoolyn1o@last.fm', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('keyre1p', '012345678912d365f134f36bd7e956d1d1911902ff1ee3ef67b1f3f9946e6ddf6147b6e34147',
        'svockings1p@cdbaby.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mvlasenko1q', '01234567891231cd5344800b70203d7f7ded81d854e6ae06cacc3cb71f159a652b4fdbf40c67',
        'lwiffen1q@linkedin.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('acroster1r', '0123456789121d26f61b8cf309a09798e06f0bcfa2e3f7bf8f0f1591372460708864819288b8',
        'njouen1r@163.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jhume1s', '012345678912a3c337178b6fce8f0e9e454c1449db4ecfa5870ebf916bd395abe6d4192ccc84',
        'sjendas1s@usnews.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mcrawshay1t', '0123456789120cc88d92393818a09902918c2f45a99f26c0dbee0a7531741e06c07708a8cd91',
        'zarias1t@histats.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('sjopke1u', '01234567891256b6559837acf731728acecfbd493657a8ab98e7d7ded0578b70d7109ec1caee',
        'xsperry1u@dailymotion.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('bwoodard1v', '012345678912a13f1a00d1f54f9a5b427d512bec745e8292570268bdbb4badbf972a8dafa739',
        'gcoslett1v@microsoft.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('csquire1w', '012345678912c9a632d0af97cfdcad4033d018797d0c975d7ec56692d639828b83a54e1f285c',
        'heles1w@engadget.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('frizzetti1x', '012345678912e49103145abe7cfeed8d4b86bda62004c1d14a6f5d300f26ea1a6c2c890dcea4',
        'mfairhurst1x@infoseek.co.jp', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('iransom1y', '0123456789127db8445b2e42e640fe8be5e461be5e86e67f92d462548625c4405720bee5330d',
        'sdodsley1y@ustream.tv', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ctapsell1z', '012345678912acd63779b24df6d3964ec005518df98303dac5000a70e5b5a80469999c88d35f',
        'gmotte1z@cbsnews.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('kmalden20', '0123456789120f6ed3e074f5fc752071791d0a22a1516157eccadf97c41d55593a8648235027',
        'aattew20@utexas.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lsorby21', '012345678912cf777aef9ec560c3a63165d1a05f8d9853eb6e8e47e020fcf25cadbd98fdbb5d', 'zmckew21@who.int',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('eteffrey22', '012345678912a46daa8987922eef2ce19b9b8f59b7af0d96cf99f0599126f5b7b1f2398e5813',
        'hlammie22@sphinn.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dwiz23', '0123456789125fe07f9920633a1ada223255fbf8927e274e04e53dfbaaa48fc79f72260883e9',
        'daudley23@abc.net.au', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lkamen24', '012345678912003a5b5b25f505a7be0fe9b20fb5cd3b67ce75c6445490b3f6435730e97b0488', 'mbennoe24@gov.uk',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dserjeantson25', '01234567891252e61a13ca0b88a79d74658a8f8952d66a664f9174b7f00bb3ce5d35421662f7',
        'caviss25@toplist.cz', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mduetsche26', '0123456789127566e47da549e886f0a29bb77564ed6b4aadabfd9c105bbd74bd9c111cec4ae4',
        'nmulberry26@va.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ttomaszkiewicz27', '012345678912f55678227c5e282c7be50a02bbeeb7485e529eba682981ef160101102bfabd9b',
        'qkarle27@imgur.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tepinay28', '012345678912f7b1d306327188b1f08e8ce6af7d6f2c688b91587965e5fafae9a03739b237bb',
        'abeincken28@hao123.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('nbazeley29', '012345678912f7d78242b60d5defc34864b3db6730d65f22d841067836e8c7a1e1f1e7170f40',
        'dbrasener29@seesaa.net', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hgoburn2a', '012345678912ac06559d2b3294e54f14309798d6dfde1e9063f1f75b9e6f7809399e8b7ae9fb',
        'sdinisco2a@blogtalkradio.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jkarim2b', '01234567891285bc878cc2522a1e3bf0ff7075b68f9abda1c732200999fe55c61ab2ec22839b',
        'ldepke2b@cisco.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('aroles2c', '012345678912e57a4aeec3f644a4eb974b0a898130ae249b33391246c94d840832881fc8eda1',
        'dlavarack2c@blinklist.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('aantonijevic2d', '01234567891205b856dae8397d18038c77f1f60b228a231e0e340789b62d5e66be9f58934699',
        'aissacson2d@clickbank.net', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('crisen2e', '0123456789124ac359261fad7c6dbf7070b9babb3a2611f54f35d590126ce63d4cf3ea505e99',
        'bagirre2e@nsw.gov.au', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lgreeveson2f', '012345678912db2439d3fbbe14af019040ff596bd4d81837515d2449a569564789616bcc666b',
        'cmillgate2f@webnode.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('pbeechcraft2g', '012345678912de2f2dca65aeaee9d5deab6ef20dea4182df86ca09e41ee9c22bd50c6e961c10',
        'wfrend2g@amazonaws.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('krowcastle2h', '012345678912e882f3e7aea84c39f252e6f50d503c4f61c72a25f8b00f4e4890042b3d1da3f2',
        'bromney2h@aboutads.info', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hizkovitch2i', '012345678912187fc0bbe667202cc1edfbc2137ea7f45f6a50ae08ef79ff10088e26607a93d4',
        'ahanbidge2i@lulu.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ntompkiss2j', '0123456789127a55d2985928f31827ecd2190e6147c11640886fcd7253011ad5bbbc082959dd',
        'vrosengren2j@nationalgeographic.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mkiddell2k', '012345678912556cc9e4865a6ebbb3eccbe0bb8eef646d37024080e34d3b734549d53df43d1c',
        'lbruckenthal2k@chicagotribune.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('blougheid2l', '01234567891202df44e42f699d3da344c92df12c101da89bf5a5440bb307dafc839c6b5a1f81',
        'abanasik2l@umich.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('vmatyukon2m', '0123456789120723b71ecac094273010fa980e15104fd6e8f102f9c4961b94856e4233b90086',
        'gbowcher2m@time.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('sbenediktovich2n', '01234567891235c9f9b6789218611f25aeb096aebaf08d129355108decfdd5803e42760e6b23',
        'bkynan2n@biglobe.ne.jp', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lmacon2o', '0123456789129477ac260b65f583cbf7d1162b1ff18375050cf0d813008adca4c60b84c451cc',
        'snaisbit2o@phpbb.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('gclapston2p', '01234567891273ff2a3078d71171a2ba797644d20e647c279eb5e87be0f317c7492b9100148c',
        'dmckinstry2p@wikispaces.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('scrozier2q', '0123456789125c173b5e5daa41ecfff421ee5793905f1b55428e5ff0b72c4589c8c24ea20598',
        'gmatignon2q@homestead.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tthorouggood2r', '012345678912e061a840c79bee8bc81400ca83300858934ff3a3c57542f752db111819cf0383',
        'acleeton2r@wiley.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dschulke2s', '012345678912559bf3740b9f0ac69b9897be3ea03ef7d3ca231056ccd31a7ad32326802e7729',
        'schape2s@yandex.ru', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ntuffin2t', '012345678912853708f0d807c93a2df3a062d1bfceb54b3d28d593b2cf785db763791b776abb',
        'erosi2t@goodreads.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tikringill2u', '012345678912c6db2bb7843690c7f4c378fb2e0088039821c1b7af34f091c1b89d717568d410',
        'kbufton2u@rediff.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mjacob2v', '012345678912e22c5f4f011d7bbca5933d22b66e4ccfbc71e58e017d8a04b6bf3a27d2e18290',
        'mimpey2v@google.com.br', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ifeechum2w', '01234567891219ff4f62701c09c9120bd8f1905ee1adc7954566b8b8e4724172f5d36716831e',
        'erysom2w@fda.gov', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('crydzynski2x', '0123456789129992e04b006e278164b3b51de3cc0eff03b5dbbcea006e7175f897e482c44bd4',
        'sedgeller2x@ucla.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mmcatamney2y', '012345678912d9d810f6b7a68b73569f31458139655b45036f22de221037080c8605d916f43f',
        'ybrunsen2y@jalbum.net', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rclemits2z', '01234567891270b728e1a90f190c89a00194e9c2f0cf2e68966112619c816169cfee04c2e860',
        'jklulisek2z@myspace.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('gmckay30', '012345678912a69c4baad68cce23750a06ebc5d8f802e293cb31f122f36cd621e434d3a8369c', 'dcharge30@nba.com',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('akindleysides31', '0123456789124c8740c5f0767cae5611d0f9bf62b024eab8d0b556f6418604693050cff925f2',
        'hmeeks31@gov.uk', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('skidder32', '012345678912fa55f7622327a5cd31f89d36c69bf2c296650318e2a4ca88ace9654548af76dd',
        'awaistell32@baidu.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rarch33', '012345678912d114b6168f68be054819450790a06ddb4109519d1a158f46c283564dee131512',
        'cdoone33@friendfeed.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ablackburne34', '01234567891296eaa6fe671ed898ac48e757a6a9ec4a7e2b0174a27440982e097dc63238351e',
        'theffer34@amazon.co.jp', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rcranstone35', '01234567891217dc8a1b6bd25338023d13fe6ee9b38f022bc5397d6b7d30678534f11c3c6bdb',
        'jpadilla35@networksolutions.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jtirone36', '012345678912ab45ecaaeebabfdd48a6025200c099b2f9a5d6920fd97f5aeea0bae47849e202', 'ocourt36@npr.org',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('amagill37', '012345678912c2825a3d43b28640e4af6de72725b5725e64bffd574c2abae1c1f0180b8f27b4',
        'tfosberry37@wisc.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('ajanny38', '0123456789127ccc5d1bad34698860f377fbef26aa86b923ecc50bf4506ff5db2f04b10e9e7f',
        'mbeddoe38@tinypic.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('myggo39', '0123456789126e04ad4d7e2c7e010ede40a173b259dc279adc0fcd6bff4691ef48cb702a59e8',
        'omulford39@foxnews.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('afried3a', '0123456789120cfb053997690ba036841f1af6ede08b560a7be392efad0aa15dca5a39c78c58',
        'fpedlingham3a@aol.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('hslade3b', '012345678912b016c963a6620810c3e63a964521481c448964e9542508dee478413bb8fb7f1d',
        'zgilmour3b@privacy.gov.au', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('daurelius3c', '0123456789121cf26c6bc76dbb72505bd137af7022e844b3d863f0a808a29fd6f77e1b6f1d04',
        'mdallender3c@mlb.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rsemarke3d', '0123456789126b935686031fd7355dc746f5c921ba14fa55ba6cf431e1124b97b8c8200ebe26',
        'gmathon3d@umich.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('belis3e', '012345678912749a542e643b099798b5710609b00a5df952a2c69ffa2842da17687350a62808',
        'kbukowski3e@cargocollective.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('wleggis3f', '0123456789125ce808da69511d44c9be9476bb69607444abbb851295b628dde126f005760357',
        'ssheardown3f@go.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mmulderrig3g', '012345678912165b8cc354f709e6b3c1afeaf084e855f6b9f10c43ee75008f5c9d42dc3a8068',
        'kdunbobbin3g@gnu.org', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('gragborne3h', '0123456789127382d48463d57a9f369e2ff6bab308598e60a7059d301b7ec0d5011271044227',
        'dpotticary3h@disqus.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dchantler3i', '0123456789123b21c918e85ef47832d6ed7fc5e9b1f1c8b0c0427d6efb54173b32a0a8e02761',
        'rjewess3i@opensource.org', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('mtedorenko3j', '012345678912ed358cfcdbe73523b5f7a5bd4259754402ef35e46b960c1b98401f5fef575855',
        'lsommerly3j@ucoz.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('salexsandrov3k', '0123456789123becffe2b2a73b78593796338ec41cfb6117abcca26282f04c1a6f32a9f16688',
        'cscrammage3k@netscape.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rhefforde3l', '012345678912ea6fe6e7261875585a019936081ab0bd6ab726be4f772bf6e8cb8660ab8e7f6f',
        'rgeorger3l@multiply.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lasken3m', '0123456789129b2e59d82f1864e13b07dc2d16feac606bec42b80f44c0da4ebf47cd2a809ceb',
        'ahariot3m@webmd.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('cgeldeford3n', '012345678912626c67f12e47bbb3f8ebace258c455463ae6c10b8f6f071958479224ce337dd9',
        'hanthona3n@oaic.gov.au', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lwestgarth3o', '012345678912615a0e2a3dc1b8b09e36cd7f9c151f1f27e15c2599c7f89dc5e7186b443b584d',
        'kpinkerton3o@nba.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('cadame3p', '0123456789127ba683ca0368e86b24d02beab63f6b451f4a52129c2cae0aa3ac5c451192b544',
        'rtottem3p@sina.com.cn', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('aburgin3q', '012345678912a118e75ab1e9fcb406decbae64c78bf43315ec74f871e5cc25268915d640eee4',
        'fwhyteman3q@vk.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('erosser3r', '012345678912036cda6ffa44308a7656924f9c22028797b5eac3da59da1f7cab86aa87f9d71e', 'nruck3r@usda.gov',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('pcalvey3s', '0123456789120b44fc7a68116c95aca620d989866d5a10406f4de32996e1a7d8740aef33b88b',
        'dlenton3s@pagesperso-orange.fr', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('asantostefano3t', '0123456789125a9a419797657b59c583fc3a4bd1e142c7d77013435537e1f0e46037fd16e78a',
        'rscholes3t@usnews.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('fbohey3u', '012345678912a9f9bf4d3b84c36ab4bd2ce45ef7d2df9c2fb1dc5f2e41462796c5c8f365531a',
        'bhedgeley3u@jigsy.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('aivanin3v', '0123456789125ff8dc3df54eeb3d527314579d379f8e298f95cab1ff96349ceda5deb5db86e5',
        'rwitchell3v@nyu.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('kjeannet3w', '012345678912726237f4a8116d5d17f3987e32b62e1d74121aede543f0215acc245a45793d6b',
        'hstannislawski3w@bluehost.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('rpierrepont3x', '012345678912b6c51178e78e2b834683e01fdd9346f593e71dc2bbc3134987da27358be09829',
        'rmacelane3x@columbia.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tbolsteridge3y', '0123456789123e4d9d217cb4aff580f452eb1648d8787ab6530410d7c30199e7c99a654d67ac',
        'tboldra3y@berkeley.edu', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('jpuckrin3z', '0123456789121cf132550e866439f3e2e78e0b4598b754dfc74ef7074c1caa67dfc5f52e52b5',
        'asherborne3z@list-manage.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('lwann40', '012345678912f5c997bdcdedfb4eb296235e927d838a58bea5f175cc76fa4d4af887ed9effc7',
        'chulburd40@tmall.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('tdone41', '012345678912c9ea09e61e8d711ebd58c0ce7b735d25ca23b8eae2f6ac9767833ea6875431b3', 'tshire41@chron.com',
        ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('dtalbot42', '01234567891290a59a85fe4a7753919d9c350d3fec61008b6df25b8a73baccaf9ef65268b0d3',
        'smacdonough42@hubpages.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('pmatuszyk43', '01234567891205fb0053679fe192b9fc0ed55b7f9b9aea5a50e8f263ba5e69ff0f3016b52c3d',
        'qcattenach43@mediafire.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('nplumm44', '01234567891215ab711494fa2679f31ae14a0584447a8ffb8695d797f9f1aae03b3ca95a633d',
        'wzimmermeister44@chicagotribune.com', ' ');
INSERT INTO platform_users (username, password, email, permissions)
VALUES ('liron45', '012345678912822979201ec599ca6cf3088422391ebcc723d43539eb394ba8032ae374aa5cfc',
        'elovemore45@ucoz.com', ' ');

INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Japan', 'JP', 100);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Poland', 'PL', 103);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Philippines', 'PH', 106);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Democratic Republic of the Congo', 'CD', 109);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Russia', 'RU', 112);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Argentina', 'AR', 115);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Indonesia', 'ID', 118);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Sweden', 'SE', 121);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('China', 'CN', 124);
INSERT INTO countries (country_name, iso_3166_1, phone_prefix)
VALUES ('Thailand', 'TH', 127);

INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '96 Butterfield Parkway', 'Injīl', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '84 Bunting Terrace', 'Fandriana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Nancy Junction', 'Pedinó', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '45709 Veith Plaza', 'Chaloem Phra Kiat', '40250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '0298 Boyd Way', 'Zamora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '39899 Morrow Plaza', 'Kamiennik', '48-388', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '50 Shasta Place', 'Krajan Jabungcandi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '3348 7th Park', 'Kokofata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '016 Maple Wood Way', 'Valbo', '818 92', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '15854 Towne Parkway', 'Alquerubim', '3850-312', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '80 Division Road', 'Kahabe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '2 Mendota Circle', 'Sambongpari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '77 Gateway Trail', 'Jīwani', '28360', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '9 Moland Center', 'Lokorae', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '28847 Sunnyside Terrace', 'Malilipot', '4510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '76 Old Gate Trail', 'Huanggu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9473 Dennis Circle', 'Xinjiang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '50 Sycamore Terrace', 'Konstantinovskoye', '356500', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '8115 Talisman Parkway', 'General José de San Martín', '3155', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5 Dorton Center', 'Dhī as Sufāl', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '38842 Crescent Oaks Plaza', 'Mirny', '678179', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '29 Memorial Park', 'Horní Jiřetín', '435 43', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '29 Westridge Point', 'Mpanda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '8 Ludington Terrace', 'Cícero Dantas', '48410-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '07 Ridgeview Hill', 'Dori', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '29 Sunbrook Drive', 'Newmarket on Fergus', 'P17', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '5082 Luster Avenue', 'Ketanggi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '04453 Iowa Crossing', 'Mnichovo Hradiště', '295 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '1265 Northview Point', 'Bafia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '3887 Upham Way', 'Pankrushikha', '658760', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '18652 Sheridan Terrace', 'Maldonado', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '06 Onsgard Alley', 'Cambita Garabitos', '11204', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '9 Charing Cross Crossing', 'Kyenjojo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '001 Starling Terrace', 'Binucayan', '7017', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '498 Bultman Trail', 'Ḩammām Wāşil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '20 Holy Cross Point', 'Pelabuhanratu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6 8th Avenue', 'Askersund', '696 30', 'Örebro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '0 Russell Road', 'Shreveport', '71161', 'Louisiana');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1 Oriole Terrace', 'Thawat Buri', '40160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '571 Lake View Court', 'Orlando', '32835', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1 Gerald Avenue', 'Soledar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '759 Scott Road', 'Lalupon', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '52 Beilfuss Alley', 'Yangba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Arapahoe Plaza', 'Stryszawa', '34-205', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '87 Troy Pass', 'Lusigang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '05798 Tennyson Plaza', 'Shīrvān', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '49765 Thackeray Point', 'Bakuriani', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '81 Washington Point', 'Qinggang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '79 Farragut Park', 'Beška', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7916 Northfield Street', 'San Jorge', '5117', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '82130 Westerfield Point', 'Pretoria', '0204', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '46376 Talmadge Pass', 'Brasília', '70000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '7008 Chive Avenue', 'Loučeň', '289 37', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '8 Scofield Court', 'Şirrīn ash Shamālīyah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '90326 Trailsway Pass', 'Colorado Springs', '80905', 'Colorado');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '991 Hovde Place', 'Lupo', '5616', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '515 Crowley Way', 'Hamburg Bramfeld', '22179', 'Hamburg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '992 Utah Pass', 'Kalandagan', '9802', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '3 West Crossing', 'Yantan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '4166 Northfield Parkway', 'Enschede', '7514', 'Provincie Overijssel');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '71 Raven Drive', 'Singasari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '89 Pearson Crossing', 'Pīshvā', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '201 Reindahl Plaza', 'Berbek', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '4 Bonner Trail', 'Ulapes', '5473', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '59 Burrows Street', 'Żarki-Letnisko', '42-311', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '2 Browning Avenue', 'Cuauhtemoc', '40068', 'Guerrero');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Morning Pass', 'Pegongan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '90 Basil Drive', 'Palermo', '90141', 'Sicilia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '71 Moose Trail', 'Cagayan', '7508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3731 Starling Alley', 'Biaokou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '992 Westport Alley', 'Rio Grande da Serra', '09450-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '611 Toban Hill', 'Valence', '26009 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '7577 Village Green Park', 'Pizhanka', '613380', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '96 Moose Circle', 'Pho Thong', '14120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '8987 Ilene Terrace', 'Lijia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '733 Ridgeway Pass', 'Gabaldon', '3131', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '5439 Coleman Crossing', 'Krasnotur’insk', '624449', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '63366 Schurz Avenue', 'Kesabpur', '8130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '4110 Warner Lane', 'Wotan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '59179 Susan Avenue', 'Kalemie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '19 Waxwing Place', 'Fengyi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '5 Golf View Place', 'Oliveirinha', '3810-856', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '47920 Kinsman Hill', 'Sīnah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '36110 Becker Circle', 'Komprachcice', '46-070', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '4961 Hovde Hill', 'Duishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '80 Ridgeview Street', 'Jezerce', '53231', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '492 Nova Drive', 'Golem', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0 Scofield Trail', 'Novyye Kuz’minki', '301333', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7 Oakridge Parkway', 'Sandata', '347612', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '00425 Waubesa Drive', 'Itacurubí del Rosario', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '54 Sundown Way', 'Teongtoda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '7798 Armistice Crossing', 'Gręboszów', '33-260', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '153 Raven Parkway', 'Fengzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '226 Sundown Pass', 'Yingzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '60 Darwin Road', 'Castlebellingham', 'Y34', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '6 Forest Center', 'Ol’ginka', '352840', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '15543 Tennessee Pass', 'Tirtopuro', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '30390 Bonner Trail', 'Mawlamyine', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8 Northview Alley', 'Castelli', '7114', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '57 Leroy Park', 'Phitsanulok', '65000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '16 Hansons Point', 'Krajan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '8 Glacier Hill Trail', 'Megati Kelod', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '67 Canary Street', 'Yangzi Jianglu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '53328 Hooker Street', 'Petrovo-Dal’neye', '143422', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '69 Tennyson Street', 'Liuxia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9256 Almo Street', 'Al Qārah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '2361 Riverside Avenue', 'Ribas do Rio Pardo', '79180-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '859 Banding Crossing', 'Pensacola', '32505', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '6 Raven Place', 'Ruzayevka', '431469', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '4269 Randy Place', 'Lomboy', '1126', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5268 Raven Road', 'Bassila', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8 Atwood Trail', 'Ban Phan Don', '41220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '3 2nd Junction', 'Palenggihan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '25 Thierer Terrace', 'Anle', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '905 Larry Alley', 'Lyubinskiy', '646160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Garrison Plaza', 'Falköping', '521 96', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8 Colorado Way', 'Mougins', '06254 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '42 Emmet Lane', 'Goba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '547 Emmet Circle', 'Castanheiro do Sul', '5130-025', 'Viseu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '576 Sloan Avenue', 'Skołyszyn', '38-242', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '6 Debs Court', 'Torre', '5050-345', 'Vila Real');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7 Sage Plaza', 'Sinanju', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '1417 Hovde Terrace', 'Bieto', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '3 Pleasure Circle', 'Arvika', '671 41', 'Värmland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '37852 Portage Road', 'Komyshnya', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9396 Melrose Point', 'Bayshint', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '76 Elka Terrace', 'Brikama Nding', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '46 Valley Edge Drive', 'Widorokandang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '591 Elka Street', 'Tol’yatti', '456922', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '4 Surrey Pass', 'Shangshuai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '1 Crowley Alley', 'Golema Rečica', '1219', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '4 Division Terrace', 'Gushui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '11 Sachtjen Pass', 'Kari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '1 Barnett Center', 'Limulunga', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '34700 Oxford Way', 'Jardín América', '3332', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '92796 American Point', 'Kombandaru', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '02153 Mockingbird Street', 'Shebunino', '694761', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '417 Anthes Plaza', 'G‘azalkent', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7493 Goodland Place', 'Bagé', '96400-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '450 Harper Center', 'Áno Kopanákion', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '21 Morrow Avenue', 'Zaplavnoye', '404609', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2 Mesta Point', 'Tsagaanchuluut', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '347 Fair Oaks Place', 'Nyakhachava', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '62 Elka Point', 'Mengeš', '1234', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '8 Michigan Parkway', 'Mao’er', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1474 Bartillon Alley', 'Koryukivka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '77 Rigney Plaza', 'Suhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '740 Morningstar Street', 'Bang Mun Nak', '66120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8684 Crescent Oaks Plaza', 'Krrabë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '01319 6th Court', 'Komletinci', '32253', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Hollow Ridge Circle', 'Fenshui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '731 Morningstar Plaza', 'Farkhah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0 Tomscot Crossing', 'Kavadarci', '1430', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '854 Morning Crossing', 'Sumberngerjat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '43780 Marquette Drive', 'Shimokizukuri', '802-0015', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '017 Mayfield Point', 'Baota', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Schmedeman Terrace', 'Ashikaga', '374-0079', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '69207 Daystar Park', 'Las Mesas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '98316 Bunting Hill', 'Anabar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '685 Gale Circle', 'Vagonoremont', '452155', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '15 Forest Dale Court', 'Lille', '59007 CEDEX', 'Nord-Pas-de-Calais');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '70430 Algoma Park', 'Danané', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '48164 Browning Hill', 'Oštarije', '47302', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '023 Quincy Drive', 'Zacatecoluca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '99323 Calypso Way', 'Nancy', '54046 CEDEX', 'Lorraine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '2604 Corben Pass', 'Gryfów Śląski', '59-620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '79306 Ludington Center', 'Idrinskoye', '662680', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '4848 Elgar Lane', 'Daugavgrīva', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6546 Ramsey Lane', 'Galimuyod', '2709', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '6 Pepper Wood Way', 'Sacsamarca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '4957 Delaware Trail', 'Makui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '713 West Place', 'Pakuranga', '2140', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7692 Loeprich Lane', 'El’brus', '361603', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '232 Dorton Park', 'San Pablo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '54719 Annamark Park', 'Kokofata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '20346 Fieldstone Street', 'Belo Horizonte', '30000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '79 Dapin Place', 'Jicomé', '11201', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '498 Melby Alley', 'Pepayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '381 Namekagon Road', 'Emmen', '7804', 'Provincie Drenthe');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '81 Pierstorff Center', 'Pamiers', '09104 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '8 Carey Trail', 'Fleury-les-Aubrais', '45404 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '417 Debs Terrace', 'Pétionville', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0564 Cardinal Circle', 'Hats’avan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '71 Waywood Junction', 'Topeka', '66611', 'Kansas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '82379 Shelley Way', 'Tumaco', '528539', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '3329 Jenna Parkway', 'San Cristóbal', '11511', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '8177 Melody Court', 'Zhangye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '0958 Sherman Junction', 'Cisitu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '416 Crownhardt Pass', 'Pasco', '5925', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '85 Pond Center', 'Chongxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7268 Farragut Way', 'Darkūsh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '6 Northview Crossing', 'Västra Frölunda', '421 10', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9808 Trailsway Place', 'Pontang Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2 Moland Hill', 'Châteauroux', '36009 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '6 Hollow Ridge Road', 'Xiaohe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5979 Lawn Hill', 'Damaying', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '56679 Summerview Hill', 'Nantes', '44324 CEDEX 3', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '9 Bashford Drive', 'Chengqu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '633 Division Center', 'Kondinskoye', '628210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '90153 Scott Plaza', 'Inriville', '2587', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8 Bartillon Road', 'Queniquea', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '895 Village Street', 'Darłowo', '76-153', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '29 Mendota Street', 'Cumaná', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '26 Northview Road', 'Talacogon', '8510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '2687 Spohn Pass', 'Jaguaruana', '62823-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '2444 Victoria Circle', 'Jönköping', '554 52', 'Jönköping');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '98501 Butternut Junction', 'Kostyantynivka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '3191 Florence Park', 'Novyye Gorki', '155101', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '998 Merry Crossing', 'Meishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1 Corscot Center', 'Nazyvayevsk', '646100', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '636 Helena Drive', 'Diên Khánh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '39 Red Cloud Plaza', 'Troitsk', '142191', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '935 Golden Leaf Road', 'Yangxiang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0 Onsgard Circle', 'Şafwá', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '240 Spenser Drive', 'Heyu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '19394 Ryan Circle', 'Bolian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '25 Magdeline Terrace', 'Liaobu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '21 Transport Parkway', 'Higashimurayama-shi', '359-1144', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '1 Leroy Crossing', 'Kilafors', '823 80', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1 Golf View Court', 'Perches', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '10950 Upham Pass', 'Coris', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2179 Almo Trail', 'Wielka Wieś', '32-089', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '05490 Morningstar Road', 'Rio Negrinho', '89295-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7 Golden Leaf Road', 'Kalpin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '39833 Stone Corner Way', 'Messina', '98168', 'Sicilia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7 Sundown Terrace', 'Cergy-Pontoise', '95809 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '91 Nelson Street', 'Puerto Nariño', '911018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '43977 Gina Road', 'Chengnan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '08813 Westerfield Terrace', 'Waihibar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '443 Vahlen Parkway', 'Rabat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '0922 Independence Circle', 'Pueblo Nuevo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '21104 Ruskin Street', 'Sangongqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '9755 Rutledge Plaza', 'El Paso', '79934', 'Texas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '760 Dapin Lane', 'Cabreúva', '13315-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '011 Dovetail Hill', 'Liushun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '923 Transport Way', 'Bestovje', '10437', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1498 Lotheville Drive', 'Kyzylzhar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '886 Rigney Drive', 'Fuhai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1 Menomonie Drive', 'Oenpeotnai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '044 Roth Pass', 'Tongjing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '61518 Forster Street', 'Canelas', '3865-004', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '030 Victoria Court', 'Zalishchyky', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '178 Blackbird Terrace', 'Markaz Mudhaykirah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Messerschmidt Road', 'Čelopek', '1227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '22 Kings Point', 'Hujia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7 Monterey Circle', 'Lýkeio', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Arapahoe Avenue', 'Frakulla e Madhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Kensington Drive', 'Lolayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1 Jenifer Avenue', 'Quichuay', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '97 Prairie Rose Alley', 'Tres Unidos', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '14 Transport Court', 'Biñan', '4116', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '86467 Beilfuss Circle', 'Jambuwerkrajan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '81249 Oak Plaza', 'Ashley', 'SN13', 'England');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '775 Darwin Lane', 'Vohibinany', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '223 Briar Crest Place', 'Baolong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '4591 Washington Parkway', 'Jishigang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '3 Weeping Birch Terrace', 'Monte de Fralães', '4775-174', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '66 Di Loreto Lane', 'Čáslav', '407 25', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '27740 Packers Parkway', 'Vélo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '49 Maple Park', 'Tiebukenwusan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '284 Ridge Oak Junction', 'Stanovoye', '399734', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '0538 Morrow Point', 'Łąck', '09-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '59 3rd Plaza', 'Jēkabpils', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '3786 Swallow Park', 'Coronda', '2240', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '396 Mallard Hill', 'Albertville', '73209 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '6764 Blackbird Place', 'Budta', '1774', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '5 Dottie Street', 'Gafanha de Aquém', '3830-017', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1 Moland Road', 'San Nicolas', '4207', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0 Southridge Pass', 'Sosnovka', '442064', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '0614 Tony Alley', 'Kant', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '117 Duke Plaza', 'Lamalera', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1 Evergreen Terrace', 'Jinpanling', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '3750 Corben Parkway', 'Béziers', '34545 CEDEX', 'Languedoc-Roussillon');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Evergreen Lane', 'Rabaul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '52166 Hansons Parkway', 'Sempu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0 Maryland Crossing', 'Potlot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '29 Helena Street', 'Ziyang Chengguanzhen', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '40 Hansons Junction', 'Golema Rečica', '1219', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '39 Sutherland Point', 'Takeo', '950-0862', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '405 Lakewood Gardens Avenue', 'Dipayal', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '40975 Norway Maple Junction', 'Kyzyl-Oktyabr’skiy', '457162', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '47098 Prairieview Parkway', 'Donggaocun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9198 Oneill Alley', 'Manga', '4506', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '73 Jana Way', 'Podu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '867 John Wall Road', 'Anjie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '60430 Hanover Hill', 'Luoxiong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '84 Sunbrook Plaza', 'Povorino', '397355', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '4505 International Alley', 'Wenping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '2581 Shelley Point', 'Bakıxanov', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '2 Crescent Oaks Point', 'Tobatí', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '71 Sachtjen Circle', 'Iwaki', '999-3503', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '685 International Point', 'Nāḩiyat Hīrān', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '508 Springs Crossing', 'Černý Most', '198 00', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '7 Rigney Plaza', 'Bearna', 'F93', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '33 Towne Way', 'Ribeiro', '4755-578', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '1953 Valley Edge Plaza', 'Doroslovo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '2 Sachs Parkway', 'Rybnoye', '393917', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '7129 Talisman Circle', 'Lalapanzi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '20 Burrows Junction', 'Sunduk', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '76695 Dahle Parkway', 'Zhireken', '673498', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '43 Park Meadow Plaza', 'Bilajer', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '05051 Dwight Pass', 'San Diego', '4032', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '0649 Barby Plaza', 'Araguaína', '77800-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '9 Quincy Parkway', 'Indianapolis', '46202', 'Indiana');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '23 Del Sol Circle', 'Gupakan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '26 Farwell Court', 'Bcharré', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5 Mccormick Point', 'Ban Takhun', '34260', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '42 Kenwood Hill', 'Ciechanowiec', '18-230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '421 Main Crossing', 'Meylan', '38244 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Delladonna Lane', 'Bratsk', '665709', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '7 Bashford Center', 'Na Khu', '70170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '3 Glendale Drive', 'Enniskerry', 'D18', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6274 Nova Avenue', 'Żabbar', 'ZBR', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2 Rieder Junction', 'Sambongmulyo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '35 Sachtjen Way', 'Fangshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '8473 Oak Valley Park', 'Buarcos', '3080-222', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2415 Park Meadow Lane', 'Lovrenc na Pohorju', '2344', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '4 Farwell Pass', 'Ransang', '1080', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '45 Park Meadow Trail', 'Alvaro Obregon', '74060', 'Puebla');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '8 Service Drive', 'Casilda', '2170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6 Atwood Parkway', 'Huangtian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '6 Novick Alley', 'Thepharak', '85130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '21533 Texas Point', 'Saint-Priest-en-Jarez', '42275 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '630 Esch Park', 'Frýdek-Místek', '733 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '18 Katie Point', 'Mukayrās', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '293 Onsgard Street', 'La Esperanza', '95590', 'Veracruz Llave');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '34871 Green Place', 'Carrefour', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '91791 Russell Pass', 'Asheville', '28815', 'North Carolina');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Kensington Place', 'Suita', '956-0123', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '71 Wayridge Trail', 'Nassarawa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '2 Montana Circle', 'Zhangfeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '0780 Florence Pass', 'Changgai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '100 Iowa Center', 'Passal', '4960-130', 'Viana do Castelo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '6 South Crossing', 'Villeurbanne', '69624 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '86618 Commercial Center', 'Onguday', '649446', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2282 Hazelcrest Hill', 'Guapi', '196009', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '9 Bunker Hill Street', 'Alfenas', '37130-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '21661 Arizona Circle', 'Mirimire', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '794 Scott Place', 'Kongkeshu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0 Del Sol Junction', 'Wachira Barami', '45250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '59 Superior Circle', 'Järfälla', '176 71', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '0 Fairview Way', 'Imtarfa', 'ZBG', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '61504 Union Pass', 'Santo Domingo', '4508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '03324 Quincy Court', 'Yangjian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '038 Moulton Point', 'Tai’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Golden Leaf Trail', 'Aksarka', '629620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1 Schiller Place', 'Cikandang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '439 Melody Way', 'Kotakan Selatan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '235 Roth Avenue', 'Cristalina', '73850-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7877 Golden Leaf Court', 'Žďár nad Sázavou', '592 11', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '5 Old Shore Plaza', 'Atipuluhan', '6124', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '42212 Maple Terrace', 'Marietta', '30061', 'Georgia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '73 Mccormick Avenue', 'Áyioi Apóstoloi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '34 Riverside Street', 'San Agustin', '8305', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '266 Morning Court', 'Martakert', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '28684 Katie Crossing', 'Taganskiy', '662327', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '43749 Upham Circle', 'Campo Mourão', '87300-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '6675 Anderson Terrace', 'Uhniv', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '94 Vahlen Court', 'Liangting', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7 Chive Way', 'Kosum Phisai', '44140', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '54281 Waubesa Alley', 'Le Mans', '72100', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5572 Stang Point', 'Tullich', 'AB55', 'Scotland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '94 Browning Circle', 'Ulster Spring', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '65084 Gina Center', 'Barra do Garças', '78600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '24 Bay Drive', 'Cotabato', '9708', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '64854 Main Circle', 'Na Klang', '39170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '170 Commercial Hill', 'Palaiseau', '91129 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '88 Carpenter Alley', 'Muli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3 Grasskamp Avenue', 'Rybatskoye', '196851', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '63 La Follette Center', 'Lgota Wielka', '97-565', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9670 International Court', 'Danxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '60017 1st Hill', 'Shibukawa', '979-1451', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7866 Bowman Pass', 'Cerme Kidul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '16797 Farragut Point', 'Marapat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '17753 Schurz Way', 'Ilyich', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5413 Cottonwood Place', 'Chiri-Yurt', '366303', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '8 Barby Circle', 'Saltsjö-Boo', '132 30', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '51 Namekagon Drive', 'Hoeryŏng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '50081 Thompson Point', 'Longjumeau', '91821 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '35647 Gulseth Junction', 'Bairros', '4785-512', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '06 Eagle Crest Point', 'Coromandel', '38550-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '897 Russell Place', 'Novosin’kovo', '141896', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '84379 Fair Oaks Trail', 'Villa del Carmen', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '774 Oxford Crossing', 'Ban Haet', '10700', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '860 Armistice Trail', 'Gelang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7236 Marcy Road', 'Cawayan', '5409', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '23 Clemons Drive', 'Ruihong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '56 Straubel Parkway', 'Melchor de Mencos', '17011', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '42 Westend Hill', 'Alfeizerão', '2460-105', 'Leiria');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '624 Park Meadow Plaza', 'Las Palmas', '40054', 'Guerrero');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '4 Hintze Park', 'Xingren', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '99 Schurz Center', 'Perechyn', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1757 Monument Hill', 'Xin’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '4378 Orin Pass', 'Soufrière', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '27499 Sloan Trail', 'Ambatolaona', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '79 Ronald Regan Park', 'Pontes e Lacerda', '78250-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '682 Lerdahl Way', 'Simo', '95201', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '86694 Clyde Gallagher Road', 'Franco da Rocha', '07800-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '4 Judy Plaza', 'Oxelösund', '613 22', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '883 Everett Avenue', 'La Virgen', '50695', 'Mexico');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '813 Atwood Park', 'Lyon', '69281 CEDEX 01', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5704 Sunfield Alley', 'La Celia', '662037', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '954 Grover Road', 'Wendo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '6214 Mosinee Court', 'San José', '40602', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '55548 Golf Center', 'Remedios', '052828', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '8 Melvin Avenue', 'Longyearbyen', '9171', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '9 Crescent Oaks Center', 'Kerek', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '909 Sutherland Street', 'Akouda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '63746 Johnson Center', 'Cential', '3070-085', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8014 Fieldstone Center', 'Pitumarca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '00 Doe Crossing Junction', 'Solnechnoye', '197738', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '84 Elmside Plaza', 'Sudzha', '307831', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '03174 Tennyson Terrace', 'Gävle', '806 31', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '28833 Red Cloud Road', 'Pasirjengkol', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '49585 Weeping Birch Lane', 'Jojoima', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '44540 Nobel Plaza', 'Maqia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '36 Kim Center', 'Changfeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '13 Debs Plaza', 'Fujiayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '8768 Nancy Pass', 'Tairua', '3544', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '74109 Westport Lane', 'Vallehermoso', '2439', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '52843 Prairie Rose Junction', 'Galamares', '2710-210', 'Lisboa');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2 Lillian Center', 'Uddiawan', '3605', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '7564 Logan Lane', 'Rybinsk', '694440', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '3 Hoffman Circle', 'Los Angeles', '90189', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '423 Buell Avenue', 'Paris 15', '75737 CEDEX 15', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '51826 Lighthouse Bay Pass', 'Yanji', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '23779 Victoria Crossing', 'Śniadowo', '18-411', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '898 Bartillon Point', 'Fengjia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '489 Onsgard Circle', 'Valongo', '5400-339', 'Vila Real');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '75585 Mesta Circle', 'Margasana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '59 Clarendon Alley', 'Saraktash', '462159', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '5 Kennedy Junction', 'Stockholm', '121 29', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '6928 Daystar Point', 'Cradock', '5884', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '50 Knutson Lane', 'Jiubao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '3 Bultman Parkway', 'Quintã', '3720-546', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '15 Burning Wood Lane', 'Salaya', '13230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '9345 Lukken Parkway', 'Varberg', '432 51', 'Halland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '0558 Mcbride Parkway', 'Orsay', '91851 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '70 Kropf Way', 'Tanghu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '4849 Myrtle Drive', 'Jinshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '73169 Erie Avenue', 'Majie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '818 Hansons Point', 'Aleksandrovac', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9433 Welch Plaza', 'Darma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '785 Nobel Parkway', 'Leicheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '406 Menomonie Drive', 'Huata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '477 Superior Plaza', 'Yeniköy', '61300', 'Trabzon');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '14097 Nancy Crossing', 'Goodlands', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9 Lake View Park', 'Marcq-en-Barœul', '59704 CEDEX', 'Nord-Pas-de-Calais');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0 Towne Lane', 'Rakitnoye', '182105', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '485 Hagan Junction', 'Comandante Fontana', '3620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '79585 Milwaukee Lane', 'Karanganyar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1 Evergreen Trail', 'Častolovice', '517 50', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '683 Pond Point', 'Skolkovo', '249028', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7 Memorial Crossing', 'Pombal', '58840-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '00 Declaration Terrace', 'Kertosari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '04184 Riverside Center', 'Tarusa', '249111', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '37701 Jana Street', 'Dobryanka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '81 Barnett Plaza', 'Lianyun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '69 Mallory Park', 'Bāniyās', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '202 Muir Park', 'Takai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '586 Melby Alley', 'Tešanj', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '8 Farragut Court', 'Mopti', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9 Sycamore Junction', 'Slovenski Javornik', '4274', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1515 Village Green Lane', 'Dahua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1738 Fremont Road', 'Halmstad', '300 10', 'Halland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '187 Prentice Avenue', 'Tongyang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '891 Ruskin Circle', 'Mengeš', '1234', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '435 Waubesa Hill', 'Bayangol', '671945', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Oakridge Crossing', 'Jiaocha', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3 Havey Drive', 'Si Narong', '34000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '51851 Old Gate Place', 'Saint Paul', '55188', 'Minnesota');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '17 Blackbird Street', 'Housuo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '642 Scofield Terrace', 'Liješnica', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '737 Marquette Alley', 'Velké Losiny', '788 15', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '204 Schurz Place', 'Casais de Revelhos', '2200-463', 'Santarém');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3970 Killdeer Trail', 'Tsimlyansk', '347320', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '284 Emmet Hill', 'Korsun’-Shevchenkivs’kyy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7647 Loomis Hill', 'Kalmar', '391 21', 'Kalmar');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1075 Sundown Crossing', 'Borovany', '348 02', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '041 Summer Ridge Court', 'Bontang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '93 Burrows Circle', 'Budapest', '1136', 'Budapest');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '33 Service Lane', 'Sa''dah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '864 Glendale Circle', 'Barr', '67144 CEDEX', 'Alsace');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7993 Fairview Pass', 'Banjarjo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '048 Homewood Park', 'Qamdo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2 Ilene Crossing', 'Yongshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1469 Almo Lane', 'Kobarid', '5222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3 Birchwood Drive', 'Cluny', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0 Briar Crest Drive', 'Sobang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '08388 Pepper Wood Circle', 'Yongxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '9 Dahle Junction', 'Cinyumput', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '0849 Hansons Plaza', 'Las Breñas', '3722', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '1 Saint Paul Junction', 'Takayama', '999-0141', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '84357 Superior Alley', 'Verbilki', '141930', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '43901 Sloan Circle', 'Maythalūn', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '9473 Evergreen Center', 'Phoenix', '85067', 'Arizona');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '844 Lukken Circle', 'Głogówek', '48-250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '467 Columbus Center', 'Alajuelita', '11001', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '761 Moulton Terrace', 'Erdenet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '452 Little Fleur Court', 'Loo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '99930 Brickson Park Crossing', 'Namora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '4 Forest Dale Terrace', 'Al Karmil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '2 Waubesa Pass', 'Zvole', '789 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '671 Bluejay Trail', 'Sydney', '1130', 'New South Wales');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '53683 Cascade Court', 'Mataquescuintla', '06005', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '84437 Paget Alley', 'Dammarie-les-Lys', '77193 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '84 Delaware Park', 'Tōkamachi', '949-8612', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '869 Sheridan Avenue', 'Niort', '79004 CEDEX', 'Poitou-Charentes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '836 Anniversary Lane', 'Dijon', '21040 CEDEX', 'Bourgogne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '824 Express Parkway', 'Vyborg', '188919', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '949 Morningstar Trail', 'Blachownia', '42-293', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '1964 Northridge Alley', 'Courtaboeuf', '91965 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '2527 Delaware Court', 'Fuchang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '23 Elmside Alley', 'Tygda', '676150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6214 Longview Parkway', 'Hoktember', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '470 Merchant Park', 'Tála', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '83 Buhler Street', 'Skidal’', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '944 Walton Road', 'Yuqunweng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '36 Green Street', 'Ampara', '32000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '3020 Hovde Avenue', 'Dzhayrakh', '309273', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '2686 Hansons Junction', 'Mizunami', '957-0048', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '67867 Emmet Park', 'Pivovarikha', '664511', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '3 Weeping Birch Parkway', 'Valle de Guanape', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '230 Center Parkway', 'Nantes', '44966 CEDEX 9', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '41064 Hoffman Lane', 'Ishkhoy-Yurt', '368164', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '159 Iowa Trail', 'Trnovska Vas', '2254', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '33 Bartillon Alley', 'Malbork', '82-210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '94 Paget Parkway', 'El Matama', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '4 Moulton Plaza', 'Laimuda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '26000 Talmadge Terrace', 'Balahovit', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '2388 Dahle Pass', 'Kanggye-si', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '129 Fairview Road', 'Miringa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '02 Chinook Street', 'Marseille', '13907 CEDEX 20', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7580 Duke Crossing', 'Pontivy', '56309 CEDEX', 'Bretagne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '81807 Buena Vista Place', 'Uticyacu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '216 Thompson Terrace', 'Saint-Priest', '69794 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '62350 Ronald Regan Avenue', 'Dodu Dua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '13 Scott Park', 'Vagos', '3840-386', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '61 Del Mar Street', 'Yong’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2987 Coleman Center', 'Mehtar Lām', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '08100 Trailsway Parkway', 'Hongmiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '35 Havey Road', 'Antas', '4760-018', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '59815 Green Crossing', 'San Juan', '6227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '91039 Tennyson Crossing', 'Le Bourget-du-Lac', '73379 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '96400 Vidon Center', 'Minuyan', '1409', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '36580 Meadow Ridge Way', 'Brusyliv', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0213 Pearson Park', 'Koz’modem’yansk', '425359', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '0928 Anniversary Place', 'Héroumbili', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '38 Hollow Ridge Park', 'Mosopa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '27 Butterfield Center', 'Morteros', '2421', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '62 Helena Court', 'Mengla', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '9 Wayridge Terrace', 'Bethlehem', '18018', 'Pennsylvania');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '6 Duke Terrace', 'Atocha', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '74917 Burrows Street', 'Condoroma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '75313 Clyde Gallagher Pass', 'Неготино', '1236', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '30840 Portage Hill', 'Issoudun', '36104 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '9887 Bayside Park', 'Krajan Tegalombo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '264 Jana Alley', 'Trélissac', '24758 CEDEX', 'Aquitaine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '98059 Northland Street', 'Coaticook', 'J1A', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '64 Union Crossing', 'Datuan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '4 4th Drive', 'Chenfang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '831 Division Road', 'Olavarría', '7400', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5 Cascade Parkway', 'Klampis', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '97331 Jana Trail', 'Perstorp', '284 32', 'Skåne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9444 Center Pass', 'Uglovoye', '694222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '089 Northfield Terrace', 'Kirovsk', '187349', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '245 Dryden Street', 'Nyagan', '628189', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '48 Bonner Way', 'Guanmiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '25906 Hayes Drive', 'Yeysk', '404172', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5 Shelley Parkway', 'Plereyan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7514 Oxford Crossing', 'Cikendi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9391 Union Trail', 'Wakefield', '7052', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '72689 Mifflin Park', 'Petukhovo', '641642', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8830 Leroy Drive', 'Wujiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '36603 Roxbury Drive', 'Mutengene', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '36 Russell Circle', 'Meiyuan Xincun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '9 Susan Junction', 'Baroy', '9210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '0906 Hayes Circle', 'Mambago', '8118', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5668 Sullivan Circle', 'Popielów', '46-090', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '00 Huxley Parkway', 'Valerianovsk', '624365', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '638 Crescent Oaks Hill', 'Sanski Most', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '2 Thierer Pass', 'Dongping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0374 Mendota Hill', 'Ping’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8416 Red Cloud Way', 'Huangjiakou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2192 Kensington Center', 'Anthoúsa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5601 Northridge Avenue', 'Turan', '668510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1723 Weeping Birch Point', 'Nasavrky', '565 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '65805 Victoria Way', 'Talaibon', '4230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '07663 Brentwood Hill', 'Lanjaghbyur', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '05 Spaight Park', 'Dongbian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7731 Grayhawk Drive', 'Orléans', '45933 CEDEX 9', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '2 Susan Center', 'Luts’k', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '32580 Di Loreto Drive', 'Pieniężno', '14-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9 Brickson Park Center', 'Mertani', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '5280 Fulton Alley', 'Gornorechenskiy', '692425', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '14625 Holmberg Road', 'Khantaghy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '349 Pleasure Way', 'Casilda', '2170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '374 Melvin Plaza', 'Ariquemes', '78930-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '972 Ridgeview Point', 'Renfengzhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '57599 Gateway Place', 'Qitao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '9046 Kings Terrace', 'Zaki Biam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '517 Lighthouse Bay Hill', 'Magitang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '3547 Nobel Alley', 'Huaquirca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '8357 Northfield Parkway', 'Kansas City', '64125', 'Missouri');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '4 Fairfield Plaza', 'Volta Redonda', '27200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '54 Corben Lane', 'Łopuszno', '26-070', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '09461 Beilfuss Parkway', 'Zalesnoye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '9 Calypso Pass', 'Legok', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '517 Hazelcrest Park', 'Xiongzhang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '347 Dakota Alley', 'Malummaduri', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3779 Mariners Cove Street', 'Horní Čermná', '561 56', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2214 American Ash Parkway', 'Setúbal', '2900-005', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6002 Westport Junction', 'Tiassalé', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '0656 Straubel Point', 'Tsagaannuur', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '50 Meadow Valley Terrace', 'Buurhakaba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '6 Spohn Place', 'Basa', '2316', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '537 Anthes Circle', 'Soly', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '750 Atwood Street', 'Podu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9452 Sauthoff Center', 'Skópelos', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '02094 Merchant Trail', 'Baligród', '38-606', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '37 Heath Avenue', 'Kalāt-e Nāderī', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '6439 Lakeland Plaza', 'Xike', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '2 Ryan Circle', 'Polzela', '3313', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '6 Dexter Circle', 'Danghara', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '75687 Rusk Junction', 'Sanchang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '61955 Blue Bill Park Pass', 'Neob', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1820 Marquette Place', 'Pasar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '915 Anthes Street', 'Kanlagay', '8712', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '724 Stang Place', 'Los Angeles', '90005', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '37 Linden Crossing', 'Dakingari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1 Melody Park', 'Repki', '08-307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '2 Ramsey Alley', 'Tanashichō', '203-0044', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '19482 Heath Street', 'La Sarrosa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Manley Point', 'Huozhuangzi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '27544 Columbus Lane', 'Capalonga', '4607', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '69 Monica Center', 'Xuebu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '34087 Bartelt Court', 'Krzeszów', '58-405', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0726 Dakota Hill', 'Xujiafang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '86 Corry Alley', 'Sivaki', '403467', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '166 American Ash Park', 'Pitai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '77080 Petterle Crossing', 'Glugur Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2 Grasskamp Point', 'Bidyā', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '76332 Kinsman Park', 'Córdoba', '632027', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '5 Del Sol Center', 'Vaitape', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '405 Tennyson Lane', 'Nihaona', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '84639 Talmadge Point', 'Oslo', '0371', 'Oslo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '37249 Melby Park', 'Americana', '13465-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '45967 John Wall Point', 'Mbinga', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '0 Anniversary Road', 'Três Passos', '98600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '6 Toban Lane', 'Longquan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '00 4th Trail', 'Talok', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '542 Dapin Point', 'Konkwesso', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1190 Scofield Lane', 'Moñitos', '231008', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '1 Dayton Plaza', 'Luzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '28826 Mandrake Way', 'Yuanqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '2 Shoshone Junction', 'Volta Redonda', '27200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '2 Rutledge Junction', 'Dingzhai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '85379 Thierer Center', 'Invermere', 'J1K', 'British Columbia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '8543 Eagan Center', 'Nowe Warpno', '72-022', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '580 Ronald Regan Road', 'Heilongkou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '070 Warner Circle', 'Qingxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '40 Pankratz Terrace', 'Guayabo Dulce', '11904', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2 Maywood Junction', 'São Marcos da Serra', '8375-254', 'Faro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '14 Oneill Lane', 'Esplanada', '48370-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7 Rieder Circle', 'Šimanovci', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '8 Shoshone Point', 'Sumbergayam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '35 Hanover Drive', 'Trakan Phut Phon', '90120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '6904 Carberry Lane', 'Lijia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '009 Graceland Trail', 'Koba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6253 Hooker Circle', 'Stara Kiszewa', '83-430', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '805 Riverside Circle', 'Kasamatsuchō', '504-0968', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '5280 Westerfield Road', 'Tres Isletas', '4000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '0905 Melody Junction', 'Senglea', 'ZTN', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '274 Huxley Terrace', 'Berlin', '10587', 'Berlin');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '221 Brown Pass', 'Mamasa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '69 Twin Pines Place', 'Riangbaring', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '13 Golden Leaf Pass', 'Pasargunung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '0037 Forest Run Crossing', 'Baturinggit Kaja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '12 Crowley Center', 'Driefontein', '4142', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Southridge Alley', 'Zicheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '477 Ruskin Terrace', 'Xinhua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '8274 Barnett Crossing', 'Bouabout', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '199 Kinsman Way', 'Dayr Abū Ḑa‘īf', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '44274 Old Gate Avenue', 'Magepanda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '0726 Tennessee Road', 'Diré', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '6471 Hoard Crossing', 'Drammen', '3037', 'Buskerud');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Susan Lane', 'Kańczuga', '37-220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '66189 Coleman Center', 'Miami Beach', '33141', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '9 Fieldstone Road', 'Krujë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '47 Ruskin Street', 'Lugar Novo', '4820-013', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '0230 Anzinger Circle', 'Carmen', '9408', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '037 Mitchell Trail', 'Zelenodolsk', '422549', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '319 Myrtle Crossing', 'Ochla', '65-980', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '874 Jay Circle', 'Smolenskaya', '353254', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '61825 Ryan Crossing', 'Jintang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '84 Gateway Crossing', 'Jejkowice', '44-290', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '024 Havey Crossing', 'Riung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '09 Burning Wood Place', 'Outjo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '361 Johnson Crossing', 'Aimorés', '35200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '5 Larry Street', 'Mamonit', '2304', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '577 Debs Drive', 'Kisarazu', '299-0271', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '5497 Killdeer Pass', 'Beaconsfield', 'H9W', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0897 Maywood Junction', 'Turus', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7486 Dennis Plaza', 'Zhelin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7 Monument Place', 'Muñoz East', '5407', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '10 Bultman Place', 'Nyköping', '611 35', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '77815 Dryden Street', 'Gorshechnoye', '307425', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '5 Muir Pass', 'Birni N Konni', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '638 Towne Crossing', 'Hamburg', '22559', 'Hamburg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '17 Jackson Hill', 'Huabu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '1 Moland Parkway', 'Cigedang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '076 Rieder Pass', 'Apodi', '59700-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '087 Maryland Terrace', 'Bologna', '40128', 'Emilia-Romagna');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '9538 Schlimgen Terrace', 'Vardane', '678030', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '33 2nd Crossing', 'Radzanów', '26-807', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '54959 Lien Court', 'Tomigusuku', '901-0241', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '6045 Armistice Trail', 'Guacarí', '763508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '83332 Merchant Way', 'Hengshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '779 Dahle Court', 'Az Zubaydāt', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '6860 Morrow Circle', 'Puma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '488 Monterey Point', 'Yiliu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '45 Homewood Street', 'Jiedu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '657 Commercial Point', 'Loreto', '8507', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5110 Eggendart Drive', 'La Peña', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '2 Shoshone Crossing', 'Macedo de Cavaleiros', '5340-197', 'Bragança');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '21572 Thierer Trail', 'Матејче', '1315', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '9 Canary Parkway', 'Patenongan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '98 Jenifer Plaza', 'Santa Luzia', '58600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '90022 Lakewood Gardens Hill', 'Breia', '4830-433', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '7 Maple Wood Lane', 'Cipanggung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '91 Schmedeman Point', 'Shixi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '967 Bunting Terrace', 'Kněžpole', '793 51', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '2 Marcy Park', 'Paris 17', '75817 CEDEX 17', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '36 Schlimgen Circle', 'Thawat Buri', '40160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '35 Nova Lane', 'Leones', '2594', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '193 Burning Wood Terrace', 'Jagabaya Dua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1899 Lien Junction', 'Saño', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '12 Montana Way', 'Quinta da Courela', '2840-547', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '98063 Mariners Cove Junction', 'Maskinongé', 'T7A', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Lerdahl Way', 'Guanxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '968 Eggendart Park', 'Roissy Charles-de-Gaulle', '95761 CEDEX 1', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '45754 Caliangt Place', 'Quilo-quilo', '4224', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '267 Northridge Alley', 'Bocana de Paiwas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '06 Spenser Place', 'Yantak', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '47607 Clarendon Park', 'Xiaojia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '7591 Holmberg Drive', 'Ol’ginskaya', '663914', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '32 Beilfuss Lane', 'Calvão', '3840-045', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '884 Sauthoff Junction', 'Gjilan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Welch Avenue', 'Youhua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '53424 Browning Circle', 'Tagoloan', '9222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Victoria Circle', 'Kasakh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '2507 Sauthoff Way', 'Cinyawar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6014 Bowman Trail', 'Passal', '4960-130', 'Viana do Castelo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '6 Superior Pass', 'Tuamese', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '66 Delladonna Alley', 'Lidong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '326 Fieldstone Park', 'Corinto', '191569', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '759 Buell Crossing', 'Xunqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '019 Sundown Court', 'Uppsala', '751 41', 'Uppsala');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '28 Express Court', 'Ajaccio', '20311 CEDEX 1', 'Corse');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '70253 Rusk Crossing', 'Taen Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '864 Farwell Court', 'Tytuvėnėliai', '86061', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '2 Orin Hill', 'Ndofane', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1254 Kedzie Terrace', 'Marília', '17500-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '9 Johnson Center', 'Río Hondo', '19003', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '19054 Mcguire Trail', 'Dongxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1 Briar Crest Lane', 'Oakland', '94611', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '483 Old Shore Alley', 'Jitan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '20 Fremont Terrace', 'Kuala Terengganu', '21009', 'Terengganu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '72765 Stephen Parkway', 'Kole', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '336 Starling Drive', 'Nova Venécia', '29830-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '3 Melody Center', 'Registro', '11900-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '78 Hoard Trail', 'Kaduseeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '6 Iowa Terrace', 'Rayong', '21000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '76 Monica Lane', 'Bordeaux', '33911 CEDEX 9', 'Aquitaine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '19004 Hanson Terrace', 'Willowdale', 'M3H', 'Ontario');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6 Leroy Circle', 'Yaozhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7 Heath Alley', 'Los Angeles', '90045', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '42816 Dovetail Hill', 'Åmål', '662 24', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '7579 Swallow Pass', 'Feitoria', '4650-291', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8291 Dapin Center', 'Luoxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '29794 Aberg Trail', 'Presidencia Roque Sáenz Peña', '5444', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '1 Monument Avenue', 'Guihuaquan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8 Eggendart Court', 'Freetown', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '25361 Tomscot Terrace', 'Meliau', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '34625 Quincy Crossing', 'Starokorsunskaya', '385274', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '316 Forest Way', 'Xankandi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '044 Harbort Court', 'Hoi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '17464 Old Gate Plaza', 'Duas Igrejas', '4580-373', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '4 Paget Park', 'Wādī as Sīr', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '60 Village Green Junction', 'Gaozhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '20 Northwestern Trail', 'Szlachta', '83-243', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7986 Reindahl Hill', 'Labège', '31678 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '8 Welch Alley', 'Koltubanovskiy', '446521', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '7969 Hazelcrest Park', 'Munjul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '0 Eastlawn Pass', 'Calaba', '3109', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8 Morningstar Park', 'Oehaunu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '54 Morningstar Drive', 'Kachia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '56263 Meadow Valley Park', 'Yangjia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '5 Pawling Avenue', 'Ongjin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '04 Anthes Plaza', 'Ilebo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '78159 Shopko Drive', 'Tembilahan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '812 Scoville Hill', 'Caen', '14085 CEDEX 9', 'Basse-Normandie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '918 Mandrake Plaza', 'Quivilla', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '247 Judy Circle', 'Dadap', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1265 Vermont Hill', 'Pittsburgh', '15266', 'Pennsylvania');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '58 Shopko Hill', 'Steinsel', 'L-7346', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '1 Burning Wood Street', 'Energeticheskiy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '6653 David Lane', 'Bretaña', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '4785 Nevada Lane', 'Wichian Buri', '67130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '8850 Union Road', 'Tanjungagung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '6685 Hauk Lane', 'Aíyira', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '57769 Harper Terrace', 'Banjar Asahduren', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2 Division Court', 'Bromma', '167 74', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '97282 Miller Point', 'Forninho', '2965-223', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '20053 Sundown Road', 'Horodne', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '804 Chinook Avenue', 'Sillamäe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '18 Myrtle Road', 'Sussex', 'E4E', 'New Brunswick');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5 Loomis Avenue', 'Elassóna', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '093 Welch Trail', 'Xinpu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '7 Drewry Place', 'Manaulanan', '2622', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '92293 Bellgrove Court', 'Pinagsibaan', '0801', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '74494 Scott Hill', 'Manfalūţ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '695 Homewood Road', 'Okaya', '520-2541', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '8 Sage Circle', 'Risālpur', '24081', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Bultman Center', 'Labrang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '34 Thierer Trail', 'Jinbi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '9 Lindbergh Terrace', 'Laon', '02004 CEDEX', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '623 Mitchell Alley', 'Mojoroto', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6 Waywood Road', 'Shuyuan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '63855 Butternut Lane', 'Ayia Napa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '9 Oxford Junction', 'Birmingham', '35236', 'Alabama');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '0 Crescent Oaks Parkway', 'Houston', '77240', 'Texas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '87687 Claremont Road', 'Phichai', '53120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '002 Rusk Avenue', 'Bhalil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '03742 Maywood Circle', 'Mrongi Daja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '0384 Packers Plaza', 'Kurungannyawa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '64 Eliot Hill', 'Juncalito Abajo', '10801', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6955 Reindahl Alley', 'Ribeirão Preto', '14000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9 North Street', 'Yoshida-kasugachō', '959-1287', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '004 West Point', 'Florida', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '017 Rusk Pass', 'Yên Mỹ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '03714 Hooker Point', 'São Sebastião do Caí', '95760-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '819 Eliot Court', 'Tripoli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '4064 Buena Vista Hill', 'Jarash', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '759 Independence Plaza', 'Elías', '417018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '6393 Sommers Court', 'Alençon', '61004 CEDEX', 'Basse-Normandie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '37 Buhler Circle', 'Amiens', '80020 CEDEX 9', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '0 Jana Alley', 'Lavaltrie', 'J5T', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '2591 Saint Paul Terrace', 'Xincheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '55 Blue Bill Park Center', 'Tawangrejo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '770 Lake View Plaza', 'Tigarunggu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '48 Fair Oaks Point', 'Jiangnan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '870 Hintze Junction', 'Zishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '6753 Lighthouse Bay Alley', 'Jampang Kulon', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '9 Eliot Court', 'Färjestaden', '386 94', 'Kalmar');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '685 Chive Road', 'Përmet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '85124 Service Way', 'Aquia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2080 Talisman Avenue', 'Martakert', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '24 Clemons Avenue', 'Shuibian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '5130 Springview Avenue', 'Lukovo', '6337', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '17 High Crossing Hill', 'Bouillon', '6834', 'Wallonie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '8 Crest Line Drive', 'Delft', '2624', 'Provincie Zuid-Holland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '0480 Thompson Park', 'Temryuk', '353508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '85568 Novick Point', 'Wassu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '7593 Cascade Park', 'Winduraja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '1 Elgar Center', 'Catriel', '8307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '3557 Oxford Street', 'Qiankou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '029 Clarendon Parkway', 'Milán', '185038', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '1009 Manufacturers Terrace', 'Yangxu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '8 Steensland Court', 'Qusar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '632 Beilfuss Court', 'Napalitan', '9006', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '32 Fulton Trail', 'Náousa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '28031 Spenser Way', 'Buldon', '9615', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '02 Sherman Park', 'Melissochóri', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '1 Anhalt Street', 'Lela', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '19 Drewry Pass', 'Cerro Blanco', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '8 Mockingbird Terrace', 'Bebandem', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '861 Southridge Junction', 'Guanchi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '93024 Monica Terrace', 'Bogorejo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '983 Logan Crossing', 'Cedynia', '74-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '49921 Manitowish Drive', 'Nanxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '5811 Mcguire Pass', 'Nakhon Phanom', '48000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '0 Maple Plaza', 'Carahue', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '4 Loeprich Junction', 'Oslo', '0309', 'Oslo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '750 Raven Street', 'Kuštilj', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '355 1st Street', 'Springfield', '62711', 'Illinois');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '59 Porter Alley', 'Kampot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '750 Kedzie Circle', 'Tutup', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '51460 Tomscot Junction', 'Hājīganj', '3832', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9470 Pierstorff Court', 'Mueang Suang', '45220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '45 Kedzie Park', 'Xinglong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '98 Aberg Place', 'Vacenovice', '675 51', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '81436 Milwaukee Drive', 'København', '1131', 'Region Hovedstaden');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '30341 South Parkway', 'Houmt Souk', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '80 Mccormick Alley', 'Xinshancun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '54930 Red Cloud Trail', 'Xinbu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '0476 Dwight Pass', 'Lapi', '5307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '1 Miller Trail', 'Ribeira', '4690-480', 'Viseu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '68658 Sage Terrace', 'Tajimi', '507-0901', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '413 Memorial Circle', 'Indramayu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '7 Transport Point', 'Katrineholm', '641 91', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '7680 Schiller Plaza', 'Shupenzë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '43 New Castle Place', 'Can-Avid', '6806', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '12511 2nd Crossing', 'Karangora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9 Sauthoff Terrace', 'Rāiwind', '55150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '3 Longview Plaza', 'Macroom', 'P12', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '05 Oneill Drive', 'San Calixto', '547018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '284 Red Cloud Court', 'Cilegi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '3 Lerdahl Crossing', 'Cibatuireng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '26 Glacier Hill Alley', 'Felgueiras', '4610-104', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '59 Merrick Way', 'Cuihuangkou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '3168 Village Green Hill', 'Kairouan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '47616 Scoville Road', 'Changping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '92396 Buell Place', 'Providence', '02912', 'Rhode Island');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '211 Erie Terrace', 'Elele', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '9 Russell Lane', 'Nunsena', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '63797 Maryland Road', 'Santa Lucia', '2712', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '3 Washington Avenue', 'Węgierska Górka', '34-350', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '43754 John Wall Avenue', 'Miringa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '18 Corscot Circle', 'Magallon Cadre', '6132', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '8106 Dovetail Court', 'Bapska', '32235', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '3337 Glendale Drive', 'Soutinho', '4650-530', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '93 Comanche Park', 'Altunemil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '5692 Golf Course Point', 'Ursk', '242467', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '80611 Saint Paul Plaza', 'Suru', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '28188 Hoepker Alley', 'Montes Claros', '39400-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '05 Melody Point', 'Serednye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '639 Mandrake Point', 'Annecy', '74999 CEDEX 9', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '0930 Judy Circle', 'Banjar Taro Kelod', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '2084 Mayer Parkway', 'Pigí', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '60310 Sutherland Lane', 'Sanshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '54118 Sundown Terrace', 'Monte da Boavista', '7100-150', 'Évora');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '028 Forest Plaza', 'Taihu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '5 Knutson Trail', 'Västra Frölunda', '421 10', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '12079 Holmberg Circle', 'Pamiers', '09104 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '04459 Shoshone Terrace', 'Karlskoga', '691 41', 'Örebro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '6769 Dexter Drive', 'Sartana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '95118 Westport Place', 'Laban', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '40 Beilfuss Pass', 'Changchun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '3 Village Place', 'Ariana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '879 Bunker Hill Hill', 'Zhuozishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '58 Dottie Alley', 'Tân Kỳ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '12 Hollow Ridge Trail', 'Camiling', '2306', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '17081 Grasskamp Drive', 'Qulai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '752 Dennis Way', 'Porangaba', '18260-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '4670 Arkansas Way', 'Emin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '52 Pepper Wood Avenue', 'Salon-de-Provence', '13654 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '0 Pennsylvania Terrace', 'Xiaomei', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '2871 Ridgeway Junction', 'Shitong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '134 Bunker Hill Circle', 'Kauniainen', '02701', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '5 High Crossing Park', 'Benito Juarez', '62214', 'Morelos');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '83 Graedel Plaza', 'Ipala', '20011', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '94 Atwood Point', 'Skuhrov nad Bělou', '517 03', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '22282 Graceland Street', 'Tatebal', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '9 Buena Vista Point', 'Manturovo', '307000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '498 Reinke Lane', 'Zouila', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '4 Northwestern Way', 'Kobilje', '9227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '66979 Sunnyside Center', 'Tunggar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '60479 Glacier Hill Junction', 'Carayaó', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '2609 Michigan Crossing', 'Seydi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '6237 Bultman Point', 'Amberd', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '43 Clemons Alley', 'Bhamo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '1603 Dayton Avenue', 'Bonsari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '28 Arapahoe Junction', 'Aubagne', '13681 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '52 Artisan Road', 'Tekeli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '40041 Oneill Parkway', 'Si Somdet', '95130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '1 Ridgeway Circle', 'Neochórion', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '21330 Chive Alley', 'Malibago', '6213', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '03 Jenna Way', 'Lichengdao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '862 Monument Parkway', 'Kumanis', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '00736 Cottonwood Junction', 'Independence', '64054', 'Missouri');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '12584 Hintze Way', 'Puerto Ayacucho', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '82076 Lakewood Gardens Trail', 'Denton', 'M34', 'England');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '87 Spohn Terrace', 'Buyun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '23 Lakewood Gardens Way', 'Hohhot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '26278 Golf View Hill', 'Chantilly', '60637 CEDEX', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (6, '7465 Schmedeman Terrace', 'New York City', '10009', 'New York');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '56490 Larry Park', 'Cimaragas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '6 Arapahoe Point', 'Banjar Dauhpura', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '3 Katie Drive', 'Purranque', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (2, '760 Magdeline Point', 'Ryazan’', '390507', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (10, '73 Twin Pines Pass', 'Ḩawsh ‘Īsá', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '71 Pond Plaza', 'Kabarnet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '2999 Hoffman Crossing', 'Yungay', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '585 Rieder Park', 'Pereiros', '3040-723', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '46638 Knutson Way', 'Paradela', '4785-231', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (3, '8780 Spenser Avenue', 'Oświęcim', '32-610', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '0261 Westend Place', 'Thuận Nam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '9 Morningstar Way', 'Raoyang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (4, '845 Independence Plaza', 'Ridder', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '26456 Garrison Circle', 'Xinzhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '46814 Thierer Crossing', 'Aguas Corrientes', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '08 Pawling Terrace', 'Shigony', '446729', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (5, '438 Grim Way', 'Jinhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '70636 Longview Center', 'Shiyaogou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (7, '29768 Eggendart Lane', 'Donghe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '74837 Ridgeway Circle', 'Daqian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (9, '9 Ronald Regan Center', 'Essen', '45356', 'Nordrhein-Westfalen');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (1, '5 Schlimgen Court', 'Komsomol’sk', '155150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, state)
VALUES (8, '2 Farmco Avenue', 'Ichihara', '920-2327', null);

INSERT INTO companies (name, nip, establishment_date, krs, parent_company_id, hq_address_id, tax_address_id)
VALUES ('TME', '9871234371231', '20-FEB-19', '4911232761', null, 537, 393);
INSERT INTO companies (name, nip, establishment_date, krs, parent_company_id, hq_address_id, tax_address_id)
VALUES ('Kazu', '205vxh3421236', '21-JAN-18', '4301236521', 1, 962, 953);

INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (19241.94, 9, 'F', 1, 84, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (93212.31, 5, 'T', 1, 503, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (45470.25, 5, 'F', 1, 903, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (15385.35, 5, 'F', 2, 49, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (94854.54, 9, 'F', 1, 580, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (68836.09, 5, 'F', 2, 86, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (78462.36, 7, 'T', 2, 89, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (31545.55, 3, 'F', 1, 508, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (10170.43, 7, 'F', 1, 367, null);
INSERT INTO warehouses (capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES (91237.97, 10, 'T', 2, 957, null);

INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Magdaia', 'Bruyns', '40145930722', '29-Nov-2019', '+355 450 512 1419', 2, 6, 1, 256);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Kelila', 'Murrhaupt', '61950313894', '30-Sep-2020', '+86 197 491 5383', 2, 4, 2, 409);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Bobbie', 'Girod', '29207347476', '21-Oct-2020', '+86 985 907 0196', 1, 3, 3, 146);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Joyous', 'Garvin', '57495835686', '26-Jan-2020', '+380 934 304 6102', 1, 1, 4, 136);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Peterus', 'MacWhirter', '11837105846', '07-Jul-2020', '+670 166 585 9881', 2, 4, 5, 721);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Elfreda', 'Luca', '53150165964', '23-Apr-2020', '+86 811 453 5714', 2, 5, 6, 671);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Thaxter', 'Grzes', '34940883794', '29-Aug-2020', '+62 967 472 6287', 2, 3, 7, 958);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Modesty', 'O''Tuohy', '38353664824', '03-Oct-2020', '+55 729 388 2504', 2, 7, 8, 468);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Emelina', 'Rown', '59182297906', '26-Jun-2020', '+420 168 119 9848', 1, 2, 9, 19);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Terrie', 'Corneliussen', '32439527213', '11-Jul-2020', '+63 794 818 6868', 1, 5, 10, 172);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ermanno', 'Gocher', '11560583654', '26-Jul-2020', '+420 556 235 4445', 2, 3, 11, 646);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Rudolf', 'Coxhell', '35481297105', '21-Jun-2020', '+234 306 210 0191', 1, 10, 12, 260);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ronald', 'Braidon', '98980734335', '01-Jan-2020', '+62 952 314 0703', 1, 9, 13, 326);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Theresina', 'Iceton', '12268529622', '06-Jun-2020', '+86 813 257 6187', 1, 10, 14, 556);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Rachel', 'Maddaford', '27025704059', '02-Dec-2019', '+232 991 643 4729', 1, 1, 15, 431);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Marielle', 'Hatherleigh', '41560789494', '05-Dec-2019', '+994 931 508 7601', 1, 6, 16, 857);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Hanna', 'Brideaux', '51669706687', '30-Jan-2020', '+55 657 730 5169', 1, 6, 17, 558);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ab', 'Izhaky', '18285312700', '17-Feb-2020', '+57 536 750 4161', 1, 1, 18, 213);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Eli', 'Bucklan', '62258456031', '09-Mar-2020', '+49 297 624 9330', 2, 5, 19, 222);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Georgy', 'Grishechkin', '31046538871', '04-Jun-2020', '+66 690 590 5317', 2, 5, 20, 144);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Beverlie', 'O'' Dornan', '01948444162', '12-Oct-2020', '+420 888 148 4983', 1, 5, 21, 514);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Harrison', 'Reagan', '92665618785', '29-Mar-2020', '+84 954 929 1141', 1, 2, 22, 796);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Marjorie', 'Skillett', '68997281667', '08-Jun-2020', '+30 819 824 6589', 1, 6, 23, 378);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Tobin', 'Whitham', '25516463716', '31-May-2020', '+86 780 184 4811', 2, 8, 24, 948);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Doloritas', 'Branigan', '11130278590', '09-Feb-2020', '+20 930 602 8729', 1, 5, 25, 894);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Kingsley', 'Ayce', '26414540351', '26-Sep-2020', '+54 877 118 0406', 2, 5, 26, 317);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Analise', 'Grumell', '69819070501', '17-May-2020', '+86 781 757 8918', 2, 2, 27, 331);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Raf', 'Beagin', '83260501512', '07-Apr-2020', '+63 555 801 3852', 2, 7, 28, 479);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Stephie', 'Bydaway', '08124914995', '14-Mar-2020', '+359 683 118 1331', 1, 4, 29, 988);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Gina', 'Mahaffey', '19609263756', '07-Sep-2020', '+63 409 900 7199', 1, 10, 30, 674);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Genovera', 'Dwyer', '78472455295', '23-Oct-2020', '+82 306 637 0638', 1, 8, 31, 901);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ashby', 'Corr', '91781149869', '16-Sep-2020', '+94 727 782 9298', 1, 6, 32, 903);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Micheal', 'Bovaird', '83999746408', '30-Nov-2019', '+94 569 558 4108', 1, 1, 33, 342);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Kean', 'Letteresse', '13898846790', '12-Apr-2020', '+51 259 458 9099', 1, 4, 34, 680);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ronald', 'Henningham', '93147508724', '30-Dec-2019', '+351 487 932 8524', 1, 8, 35, 74);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Collin', 'Craigheid', '01905522171', '27-Dec-2019', '+84 796 466 8717', 1, 10, 36, 192);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('David', 'Urvoy', '15454566077', '01-Jun-2020', '+1 407 708 7241', 2, 5, 37, 442);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Ave', 'Clarage', '12900264618', '08-Jan-2020', '+63 151 403 7331', 2, 7, 38, 347);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Keen', 'Sproul', '04388454135', '30-Aug-2020', '+27 716 818 0389', 2, 10, 39, 306);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Jule', 'Fanti', '38135093316', '09-Apr-2020', '+86 814 449 0937', 1, 5, 40, 871);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Diego', 'Tattersill', '02869842535', '08-Dec-2019', '+62 315 543 6910', 1, 9, 41, 845);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Deeanne', 'Rabjohns', '83534764273', '09-Mar-2020', '+55 475 915 6862', 2, 7, 42, 625);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Sibby', 'Girardez', '35818266187', '24-Mar-2020', '+66 425 412 9781', 1, 8, 43, 174);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Hillary', 'Sousa', '21105256456', '04-Sep-2020', '+33 953 523 5869', 1, 2, 44, 277);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Nikoletta', 'Fever', '60074432039', '22-Apr-2020', '+62 414 644 9641', 1, 2, 45, 950);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Sofia', 'Czapla', '87797452249', '19-Feb-2020', '+63 147 451 1608', 2, 5, 46, 313);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Rickey', 'Pacher', '55484423989', '29-Mar-2020', '+420 874 698 7182', 1, 4, 47, 836);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Clemens', 'Hymus', '06255328775', '01-Nov-2020', '+31 801 929 7420', 2, 10, 48, 269);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Pedro', 'Lyst', '47532765943', '07-Nov-2020', '+62 257 850 7115', 1, 4, 49, 210);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Lana', 'Stowgill', '86069130736', '28-Aug-2020', '+62 240 942 8752', 1, 4, 50, 953);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Monique', 'Capponeer', '59730017351', '02-May-2020', '+86 130 138 2995', 2, 9, 51, 624);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Dew', 'Scading', '67922000180', '24-Jul-2020', '+62 644 111 4035', 1, 10, 52, 871);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Wells', 'Doust', '43452927417', '16-Mar-2020', '+351 198 319 3726', 1, 9, 53, 55);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Valentin', 'Walesa', '38646221656', '25-Jan-2020', '+39 945 491 6377', 2, 6, 54, 960);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Morgan', 'Lobb', '36200449602', '04-Feb-2020', '+30 664 638 4080', 2, 1, 55, 275);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Monroe', 'Mucklow', '89920062781', '29-Apr-2020', '+39 228 810 6159', 1, 9, 56, 691);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Shanon', 'Douberday', '50815422205', '06-Dec-2019', '+81 676 561 3414', 1, 5, 57, 586);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Celle', 'Ciccottini', '58851561427', '30-Jan-2020', '+33 220 446 1727', 1, 9, 58, 684);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Von', 'Riccardini', '96468040370', '28-Jun-2020', '+7 133 371 1295', 1, 6, 59, 131);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Sloane', 'Van Dalen', '97423045486', '05-Oct-2020', '+386 829 804 7137', 2, 5, 60, 457);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Florrie', 'Moscon', '82324713382', '12-Dec-2019', '+380 223 103 6283', 1, 4, 61, 919);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Mellie', 'Dayborne', '24535670151', '11-Sep-2020', '+358 189 821 7388', 2, 3, 62, 849);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Kelila', 'Duck', '32328621133', '11-Dec-2019', '+66 775 884 0970', 2, 10, 63, 126);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Zed', 'Flanigan', '89345715807', '06-Sep-2020', '+62 447 417 7899', 2, 10, 64, 934);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Christiane', 'Aleshkov', '02314792053', '27-Jun-2020', '+62 352 642 5665', 1, 8, 65, 704);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Sherm', 'Simms', '44379382815', '26-Aug-2020', '+62 713 408 7967', 1, 3, 66, 104);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Anna-diana', 'Kitchenman', '87244916667', '18-Feb-2020', '+256 233 666 0321', 1, 5, 67, 402);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Yance', 'Clift', '17687261914', '27-Sep-2020', '+86 875 634 1975', 1, 10, 68, 258);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Emmanuel', 'Coxhell', '78573780439', '13-Jan-2020', '+63 254 175 3936', 1, 3, 69, 367);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Hilliard', 'Nutting', '48239271539', '11-Mar-2020', '+86 458 381 4616', 2, 8, 70, 292);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Kenton', 'Dellar', '00757896111', '03-Sep-2020', '+351 985 105 8354', 1, 10, 71, 440);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Gabriel', 'Goodbourn', '35585035439', '17-Jan-2020', '+51 886 155 9347', 1, 1, 72, 272);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Bailie', 'Mainstone', '81425999039', '07-Sep-2020', '+86 863 682 2840', 1, 9, 73, 269);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Conrado', 'Burrell', '87732270649', '31-Mar-2020', '+48 142 895 6388', 1, 3, 74, 751);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Brendan', 'Purkins', '17161033717', '16-Mar-2020', '+60 172 260 7042', 2, 5, 75, 912);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Chevy', 'Ridgewell', '50454600492', '14-Mar-2020', '+62 148 388 6533', 2, 9, 76, 156);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Shawn', 'Starrs', '97270517865', '23-Jan-2020', '+998 950 890 4568', 2, 7, 77, 575);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Antonius', 'Bakster', '16699955387', '10-Feb-2020', '+253 256 556 8139', 1, 6, 78, 523);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Gale', 'Wanderschek', '13166814533', '31-Dec-2019', '+62 933 202 5072', 1, 10, 79, 652);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Dari', 'Duckett', '62082509790', '26-Dec-2019', '+33 338 898 5700', 2, 3, 80, 465);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Helen', 'Gostling', '17080085465', '28-Aug-2020', '+62 974 716 7872', 1, 9, 81, 285);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Jacquie', 'Van Waadenburg', '45484721904', '14-Sep-2020', '+66 178 423 2499', 1, 2, 82, 693);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Guglielmo', 'Barnshaw', '01341842981', '06-May-2020', '+60 469 100 2002', 1, 3, 83, 892);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Giacobo', 'MacVay', '68056356444', '20-Feb-2020', '+45 302 876 6049', 1, 4, 84, 302);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Obadias', 'Necolds', '87282867780', '12-Mar-2020', '+7 664 486 0600', 1, 7, 85, 150);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Cassy', 'Aleksashin', '83583710820', '08-May-2020', '+62 884 443 8698', 1, 1, 86, 337);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Sydel', 'Voden', '50322901024', '26-Feb-2020', '+504 155 920 4173', 1, 3, 87, 606);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Marion', 'Trump', '93723922663', '11-Aug-2020', '+255 333 138 0787', 2, 2, 88, 763);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Emile', 'Braunstein', '23887893412', '24-Aug-2020', '+33 414 795 9752', 2, 10, 89, 964);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Anne-marie', 'Draayer', '92760398591', '03-Sep-2020', '+86 412 184 9161', 2, 9, 90, 102);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Leonhard', 'Dreghorn', '37626826834', '14-Aug-2020', '+62 760 222 9596', 1, 10, 91, 775);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Em', 'Founds', '36193398593', '07-Oct-2020', '+236 426 582 4418', 1, 3, 92, 15);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('George', 'Dublin', '31727938056', '28-Aug-2020', '+95 943 556 6068', 2, 10, 93, 603);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Bevin', 'Aicheson', '16472431457', '04-Aug-2020', '+46 501 176 0466', 1, 3, 94, 190);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Darius', 'Corless', '88784272508', '09-Oct-2020', '+354 911 456 2709', 1, 7, 95, 26);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Cyrille', 'Pien', '92237848907', '17-Feb-2020', '+84 460 605 5630', 1, 10, 96, 915);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Annamaria', 'Twelve', '13829167446', '05-Oct-2020', '+62 192 117 8391', 2, 3, 97, 49);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Humberto', 'Gringley', '29107725709', '19-May-2020', '+242 948 256 2240', 2, 1, 98, 707);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Tamarra', 'Bisco', '21056199346', '06-Aug-2020', '+55 541 194 0442', 1, 7, 99, 51);
INSERT INTO employees (first_name, last_name, pesel, employment_date, phone_number, company_id, warehouse_id, user_id,
                       address_id)
VALUES ('Elfrida', 'Vanichkov', '81110154584', '11-Dec-2019', '+51 402 779 9317', 1, 10, 100, 980);

INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (101, 'Sabra', 'Duro', '0145201736363', '+355 200 926 5795', 2, 387);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (102, 'Phillip', 'Rohlfs', '2162573232062', '+86 387 911 7343', 2, 639);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (103, 'Allina', 'Frantz', '1126303923556', '+46 426 583 9478', 1, 435);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (104, 'Morgan', 'Kells', '1441540241760', '+86 653 809 0343', 1, 563);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (105, 'Mona', 'Peele', '4776546221301', '+351 700 915 0171', 2, 70);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (106, 'Othelia', 'Kleinbaum', '2912147927887', '+62 428 978 2221', 1, 933);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (107, 'Gerianna', 'McPeeters', '0924153604516', '+7 310 924 4934', 2, 778);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (108, 'Erika', 'Jealous', '0179014134004', '+351 643 765 2896', 2, 287);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (109, 'Lev', 'Bohman', '4326760771426', '+420 930 503 3089', 2, 233);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (110, 'Isaiah', 'Winstanley', '8036785530699', '+254 176 248 3069', 1, 668);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (111, 'Cathe', 'Balsom', '4197986738022', '+381 175 892 4327', 2, 532);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (112, 'Johnny', 'Dockwra', '5347781825722', '+48 125 371 7965', 1, 993);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (113, 'Margareta', 'Vanes', '9849539448996', '+57 880 146 8710', 1, 354);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (114, 'Ulrick', 'Woodyatt', '7827186875355', '+62 386 846 9355', 2, 61);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (115, 'Andros', 'Peggram', '1179954686968', '+55 592 254 6171', 2, 494);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (116, 'Waylen', 'Yglesia', '2355896314335', '+234 154 425 5929', 1, 406);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (117, 'Gilbertine', 'Delle', '2268546540491', '+86 930 548 8082', 2, 245);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (118, 'Delphine', 'Wahncke', '7387036849623', '+7 435 326 8683', 1, 639);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (119, 'Alidia', 'Vanini', '4430984368459', '+358 990 131 1589', 1, 276);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (120, 'Les', 'Marcinkus', '5218691894311', '+1 926 434 4191', 2, 817);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (121, 'Hercule', 'Titterell', '0816507292861', '+420 219 390 5673', 2, 548);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (122, 'Falito', 'Borris', '0548133059697', '+30 841 719 5155', 1, 372);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (123, 'Farly', 'Reignard', '5630506361263', '+7 507 940 3093', 2, 357);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (124, 'Ruby', 'Rennebach', '5861881418063', '+86 454 626 8698', 2, 968);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (125, 'Pierson', 'Clemmey', '3896604727437', '+30 228 840 1446', 1, 573);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (126, 'Darrin', 'Harryman', '2192872007755', '+251 803 823 7838', 1, 449);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (127, 'Roseanne', 'Jordison', '3330367122657', '+970 179 817 3055', 2, 497);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (128, 'Lindi', 'Streets', '5980203656043', '+687 525 734 5214', 1, 58);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (129, 'Caddric', 'Bernardinelli', '6783089245647', '+234 627 645 7681', 1, 709);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (130, 'Karel', 'Trittam', '6387241289718', '+86 482 454 1088', 1, 937);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (131, 'Brittaney', 'Whitcomb', '3894662539308', '+95 893 178 7817', 1, 32);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (132, 'Alix', 'Rosenfield', '5414706005606', '+57 933 466 2770', 2, 955);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (133, 'Hanny', 'Lyddiatt', '2147118414318', '+55 162 307 0014', 1, 564);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (134, 'Ephraim', 'Wastling', '7859831253483', '+351 316 378 5051', 2, 173);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (135, 'Russell', 'Kidwell', '6271719974154', '+86 916 913 7033', 2, 251);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (136, 'Joeann', 'Fenney', '3405065489957', '+55 895 364 7189', 1, 13);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (137, 'Eilis', 'Ovitz', '3682404693246', '+7 364 330 9743', 2, 304);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (138, 'Dex', 'Perillo', '5258414258972', '+62 201 415 1951', 1, 860);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (139, 'Malinda', 'Legg', '9649250358565', '+507 279 864 9101', 2, 347);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (140, 'Harry', 'Schottli', '2659114385514', '+33 449 586 3456', 2, 973);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (141, 'Emalia', 'Kertess', '0570738406453', '+351 677 831 0002', 2, 835);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (142, 'Ingeberg', 'Lafuente', '0354534294485', '+86 383 855 2362', 1, 641);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (143, 'Nicolina', 'Teresse', '2555833449851', '+1 405 364 1163', 1, 335);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (144, 'Lesly', 'Tschersich', '0546749179377', '+81 461 238 5202', 2, 592);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (145, 'Worthington', 'Swalough', '6669316344628', '+81 330 726 5394', 1, 15);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (146, 'Fielding', 'Hiland', '8655848802202', '+86 432 514 4672', 2, 335);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (147, 'Dare', 'Clubley', '7249882206236', '+58 232 300 2984', 1, 574);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (148, 'Eziechiele', 'McIlherran', '8981095956384', '+597 457 806 0001', 1, 514);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (149, 'Hetty', 'Botwood', '7845143313322', '+7 205 797 3303', 2, 711);
INSERT INTO customers (user_id, first_name, last_name, nip, phone_number, company_id, address_id)
VALUES (150, 'Annnora', 'Fidele', '9896108415660', '+63 622 891 8827', 2, 655);

INSERT INTO items (name, description)
VALUES ('Descurainia pinnata (Walter) Britton',
        'ac tellus semper interdum mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel');
INSERT INTO items (name, description)
VALUES ('Chelidonium L.',
        'quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit');
INSERT INTO items (name, description)
VALUES ('Arctostaphylos glandulosa Eastw. ssp. zacaensis (Eastw.) P.V. Wells',
        'sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque');
INSERT INTO items (name, description)
VALUES ('Lithospermum ruderale Douglas ex Lehm.',
        'dui vel sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci nullam molestie');
INSERT INTO items (name, description)
VALUES ('Aspicilia caesiocinerea (Nyl. ex Malbr.) Arnold',
        'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis turpis enim blandit mi in');
INSERT INTO items (name, description)
VALUES ('Scabrethia scabra (Hook.) W.A. Weber ssp. attenuata (W.A. Weber) W.A. Weber',
        'congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci eget orci vehicula');
INSERT INTO items (name, description)
VALUES ('Thelypteris cordata (Fée) Proctor var. imitata (C. Chr.) Proctor',
        'integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim sit');
INSERT INTO items (name, description)
VALUES ('Aristida palustris (Chapm.) Vasey',
        'viverra diam vitae quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi');
INSERT INTO items (name, description)
VALUES ('Froelichia interrupta (L.) Moq.',
        'sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras');
INSERT INTO items (name, description)
VALUES ('Thalictrum sparsiflorum Turcz. ex Fisch. & C.A. Mey. var. richardsonii (A. Gray) B. Boivin',
        'nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium');
INSERT INTO items (name, description)
VALUES ('Iris setosa Pall. ex Link',
        'mauris ullamcorper purus sit amet nulla quisque arcu libero rutrum ac lobortis vel');
INSERT INTO items (name, description)
VALUES ('Cornus drummondii C.A. Mey.',
        'velit eu est congue elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium iaculis diam erat fermentum justo nec condimentum neque sapien placerat ante nulla');
INSERT INTO items (name, description)
VALUES ('Carex radfordii Gaddy',
        'nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo');
INSERT INTO items (name, description)
VALUES ('Stereophyllum radiculosum (Hook.) Mitt.',
        'cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis dis');
INSERT INTO items (name, description)
VALUES ('Atriplex spongiosa F. Muell.',
        'at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac');
INSERT INTO items (name, description)
VALUES ('Scutellaria elliptica Muhl. ex Spreng. var. elliptica',
        'hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt');
INSERT INTO items (name, description)
VALUES ('Clematis terniflora DC.',
        'augue a suscipit nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla');
INSERT INTO items (name, description)
VALUES ('Symphyotrichum tenuifolium (L.) G.L. Nesom',
        'nam congue risus semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti');
INSERT INTO items (name, description)
VALUES ('Orbignya Mart. ex Endl.', 'quis orci eget orci vehicula condimentum curabitur in libero ut');
INSERT INTO items (name, description)
VALUES ('Fimbristylis decipiens Kral',
        'porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse');
INSERT INTO items (name, description)
VALUES ('Tetraneuris scaposa (DC.) Greene var. villosa (Shinners) Shinners',
        'erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis');
INSERT INTO items (name, description)
VALUES ('Penstemon franklinii S.L. Welsh',
        'blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse');
INSERT INTO items (name, description)
VALUES ('Adenophyllum Pers.',
        'ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis');
INSERT INTO items (name, description)
VALUES ('Chorizanthe xanti S. Watson var. xanti',
        'pellentesque eget nunc donec quis orci eget orci vehicula condimentum');
INSERT INTO items (name, description)
VALUES ('Cordylanthus maritimus Nutt. ex Benth.',
        'faucibus orci luctus et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit');
INSERT INTO items (name, description)
VALUES ('Macromitrium Brid.', 'mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor gravida sem praesent');
INSERT INTO items (name, description)
VALUES ('Miconia affinis DC.',
        'integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum');
INSERT INTO items (name, description)
VALUES ('Quercus dumosa Nutt.', 'convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh');
INSERT INTO items (name, description)
VALUES ('Iva hayesiana A. Gray',
        'sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut');
INSERT INTO items (name, description)
VALUES ('Eschscholzia minutiflora S. Watson ssp. minutiflora',
        'ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta');
INSERT INTO items (name, description)
VALUES ('Encalypta affinis R. Hedw. var. affinis', 'nisl ut volutpat sapien arcu sed augue aliquam erat volutpat');
INSERT INTO items (name, description)
VALUES ('Oplopanax horridus (Sm.) Miq.',
        'quam suspendisse potenti nullam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam');
INSERT INTO items (name, description)
VALUES ('Lecanora tristiuscula H. Magn.',
        'aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed');
INSERT INTO items (name, description)
VALUES ('Argentina anserina (L.) Rydb.',
        'erat quisque erat eros viverra eget congue eget semper rutrum nulla nunc purus phasellus in felis donec semper sapien a libero');
INSERT INTO items (name, description)
VALUES ('Lepidium lasiocarpum Nutt. var. wrightii (A. Gray) C.L. Hitchc.',
        'nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a');
INSERT INTO items (name, description)
VALUES ('Thymelaea passerina (L.) Coss. & Germ.',
        'elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus');
INSERT INTO items (name, description)
VALUES ('Arctium lappa L.',
        'ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae');
INSERT INTO items (name, description)
VALUES ('Tetraplasandra waimeae Wawra',
        'sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit amet');
INSERT INTO items (name, description)
VALUES ('Trifolium monanthum A. Gray ssp. tenerum (Eastw.) J.M. Gillett',
        'pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere');
INSERT INTO items (name, description)
VALUES ('Calystegia malacophylla (Greene) Munz ssp. pedicellata (Jeps.) Munz',
        'faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non velit nec nisi vulputate');
INSERT INTO items (name, description)
VALUES ('Stachytarpheta mutabilis (Jacq.) Vahl',
        'felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod');
INSERT INTO items (name, description)
VALUES ('Phacelia congdonii Greene',
        'auctor sed tristique in tempus sit amet sem fusce consequat nulla nisl nunc nisl duis bibendum felis sed interdum venenatis');
INSERT INTO items (name, description)
VALUES ('Odontonema nitidum (Jacq.) Kuntze',
        'aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero');
INSERT INTO items (name, description)
VALUES ('Geranium californicum G.N. Jones & F.F. Jones',
        'velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget');
INSERT INTO items (name, description)
VALUES ('Clappia A. Gray',
        'elementum eu interdum eu tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu');
INSERT INTO items (name, description)
VALUES ('Eriosorus Fée', 'odio odio elementum eu interdum eu tincidunt in leo maecenas pulvinar');
INSERT INTO items (name, description)
VALUES ('Echinocactus polycephalus Engelm. & J.M. Bigelow var. polycephalus',
        'lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in sapien iaculis congue');
INSERT INTO items (name, description)
VALUES ('Arnica acaulis (Walter) Britton, Sterns & Poggenb.',
        'elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis');
INSERT INTO items (name, description)
VALUES ('Packera flettii (Wiegand) W.A. Weber & Á. Löve',
        'sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum');
INSERT INTO items (name, description)
VALUES ('Nyctaginia capitata Choisy',
        'sed interdum venenatis turpis enim blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum in hac habitasse');
INSERT INTO items (name, description)
VALUES ('Aspicilia subradians (Nyl.) Hue',
        'primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti nullam porttitor');
INSERT INTO items (name, description)
VALUES ('Hygroamblystegium noterophilum (Sull. & Lesq.) Warnst.',
        'aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem');
INSERT INTO items (name, description)
VALUES ('Crassula aquatica (L.) Schoenl.',
        'magnis dis parturient montes nascetur ridiculus mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum');
INSERT INTO items (name, description)
VALUES ('Angiopteris Hoffm.',
        'sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam');
INSERT INTO items (name, description)
VALUES ('Caloplaca approximata (Lynge) H. Magn.',
        'aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse');
INSERT INTO items (name, description)
VALUES ('Juncus squarrosus L.',
        'aliquam sit amet diam in magna bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus');
INSERT INTO items (name, description)
VALUES ('Cyperus surinamensis Rottb.', 'risus praesent lectus vestibulum quam sapien varius ut blandit non');
INSERT INTO items (name, description)
VALUES ('Muhlenbergia filiculmis Vasey',
        'justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan');
INSERT INTO items (name, description)
VALUES ('Jasminum sambac (L.) Aiton', 'eget eleifend luctus ultricies eu nibh quisque id justo sit');
INSERT INTO items (name, description)
VALUES ('Ramalina fastigiata (Pers.) Ach.',
        'leo odio porttitor id consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam');
INSERT INTO items (name, description)
VALUES ('Quercus john-tuckeri Nixon & C.H. Mull.',
        'augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea');
INSERT INTO items (name, description)
VALUES ('Camellia L.', 'vel sem sed sagittis nam congue risus semper porta volutpat quam pede');
INSERT INTO items (name, description)
VALUES ('Lilium humboldtii Roezl & Leichtlin ex Duch.',
        'neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac nibh fusce');
INSERT INTO items (name, description)
VALUES ('Adiantum villosum L.',
        'scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut');
INSERT INTO items (name, description)
VALUES ('Carex cyrtostachya Janeway & Zika',
        'volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus');
INSERT INTO items (name, description)
VALUES ('Duchesnea Sm.',
        'curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem integer');
INSERT INTO items (name, description)
VALUES ('Graphina anguina (Mont.) Müll. Arg.',
        'pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae');
INSERT INTO items (name, description)
VALUES ('Arabis lyallii S. Watson var. nubigena (J.F. Macbr. & Payson) Rollins',
        'faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum');
INSERT INTO items (name, description)
VALUES ('Taraxacum carneocoloratum A. Nelson',
        'in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet');
INSERT INTO items (name, description)
VALUES ('Hymenopappus tenuifolius Pursh',
        'sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac');
INSERT INTO items (name, description)
VALUES ('Koellensteinia Rchb. f.', 'sit amet diam in magna bibendum imperdiet nullam orci pede');
INSERT INTO items (name, description)
VALUES ('Lepidium apetalum Willd.',
        'massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante');
INSERT INTO items (name, description)
VALUES ('Pyrrocoma clementis Rydb.',
        'dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices');
INSERT INTO items (name, description)
VALUES ('Placynthium petersii (Nyl.) Burnham',
        'et ultrices posuere cubilia curae nulla dapibus dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia');
INSERT INTO items (name, description)
VALUES ('Hexastylis arifolia (Michx.) Small var. arifolia',
        'nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor');
INSERT INTO items (name, description)
VALUES ('Polystichum imbricans (D.C. Eaton) D.H. Wagner',
        'sit amet erat nulla tempus vivamus in felis eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque');
INSERT INTO items (name, description)
VALUES ('Stroganowia tiehmii Rollins',
        'a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat');
INSERT INTO items (name, description)
VALUES ('Potentilla plattensis Nutt.',
        'nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo');
INSERT INTO items (name, description)
VALUES ('Paraserianthes lophantha (Willd.) I.C. Nielsen ssp. montana (Jungh.) I.C. Nielsen',
        'eleifend pede libero quis orci nullam molestie nibh in lectus pellentesque at nulla suspendisse potenti cras in purus eu magna vulputate luctus cum sociis natoque penatibus et magnis');
INSERT INTO items (name, description)
VALUES ('Ficus macrophylla Desf. ex Pers.',
        'nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis');
INSERT INTO items (name, description)
VALUES ('Carex illota L.H. Bailey',
        'dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst');
INSERT INTO items (name, description)
VALUES ('Anthaenantia P. Beauv.', 'felis donec semper sapien a libero nam dui proin leo odio porttitor');
INSERT INTO items (name, description)
VALUES ('Celosia palmeri S. Watson',
        'primis in faucibus orci luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse');
INSERT INTO items (name, description)
VALUES ('Dichanthelium strigosum (Muhl. ex Elliott) Freckmann var. strigosum',
        'sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis orci');
INSERT INTO items (name, description)
VALUES ('Eleocharis schaffneri Boeckeler',
        'rhoncus aliquet pulvinar sed nisl nunc rhoncus dui vel sem sed sagittis nam congue risus');
INSERT INTO items (name, description)
VALUES ('Agrostemma brachyloba (Fenzl) Hammer',
        'a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare imperdiet sapien urna pretium nisl');
INSERT INTO items (name, description)
VALUES ('Dionaea muscipula Ellis',
        'id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero nullam sit amet turpis elementum ligula vehicula consequat morbi a');
INSERT INTO items (name, description)
VALUES ('Centaurea uniflora Turra',
        'ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui');
INSERT INTO items (name, description)
VALUES ('Cuscuta obtusiflora Kunth var. glandulosa Engelm.',
        'etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus nulla ut erat id mauris vulputate elementum nullam varius nulla facilisi cras non');
INSERT INTO items (name, description)
VALUES ('Ferocactus hamatacanthus (Muehlenpf.) Britton & Rose var. hamatacanthus',
        'vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus vivamus');
INSERT INTO items (name, description)
VALUES ('Salix amygdaloides Andersson',
        'blandit mi in porttitor pede justo eu massa donec dapibus duis at velit eu est congue elementum');
INSERT INTO items (name, description)
VALUES ('Phascum hyalinotrichum Cardot & Thér.', 'platea dictumst maecenas ut massa quis augue luctus tincidunt nulla');
INSERT INTO items (name, description)
VALUES ('Carex baltzellii Chapm. ex Dewey',
        'cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem');
INSERT INTO items (name, description)
VALUES ('Hieracium canadense Michx.',
        'diam id ornare imperdiet sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis');
INSERT INTO items (name, description)
VALUES ('Camassia quamash (Pursh) Greene ssp. azurea (A. Heller) Gould',
        'eu sapien cursus vestibulum proin eu mi nulla ac enim in tempor turpis nec euismod scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem');
INSERT INTO items (name, description)
VALUES ('Triticum vavilovii Jakubz.',
        'neque sapien placerat ante nulla justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet');
INSERT INTO items (name, description)
VALUES ('Amaranthus cannabinus (L.) Sauer',
        'velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit vivamus vel nulla');
INSERT INTO items (name, description)
VALUES ('Catillaria terrena (Willey) Zahlbr.',
        'sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra magna ac consequat');
INSERT INTO items (name, description)
VALUES ('Physaria acutifolia Rydb. var. acutifolia',
        'bibendum imperdiet nullam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed');
INSERT INTO items (name, description)
VALUES ('Lobelia portoricensis (Vatke) Urb.',
        'odio donec vitae nisi nam ultrices libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim');

INSERT INTO categories (name, description)
VALUES ('Honokahua Melicope', 'id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio');
INSERT INTO categories (name, description)
VALUES ('Craterostigma', 'sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam');
INSERT INTO categories (name, description)
VALUES ('Dipteryx', 'ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo etiam pretium');
INSERT INTO categories (name, description)
VALUES ('Rufous Tiger Orchid',
        'parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor');
INSERT INTO categories (name, description)
VALUES ('Itchgrass',
        'aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a odio in hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt nulla mollis');
INSERT INTO categories (name, description)
VALUES ('Nuttall''s Homalothecium Moss',
        'posuere nonummy integer non velit donec diam neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae donec pharetra');
INSERT INTO categories (name, description)
VALUES ('Orpine Stonecrop',
        'phasellus id sapien in sapien iaculis congue vivamus metus arcu adipiscing molestie hendrerit');
INSERT INTO categories (name, description)
VALUES ('Indigoberry',
        'mauris eget massa tempor convallis nulla neque libero convallis eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in');
INSERT INTO categories (name, description)
VALUES ('Rusby''s Blazingstar',
        'posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet');
INSERT INTO categories (name, description)
VALUES ('Mendrina',
        'consequat in consequat ut nulla sed accumsan felis ut at dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero');

INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (1, 1, 620134, 91.79);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (2, 1, null, 71.4);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (3, 1, null, 12.42);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (4, 1, null, 3.81);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (5, 1, 806844, 62.88);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (6, 1, null, 82.11);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (7, 1, null, 96.39);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (8, 1, null, 15.7);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (9, 1, null, 42.67);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (10, 1, null, 4.84);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (11, 1, null, 59.66);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (12, 1, null, 76.2);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (13, 1, null, 16.14);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (14, 1, null, 75.55);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (15, 1, null, 48.83);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (16, 1, null, 18.85);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (17, 1, null, 35.44);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (18, 1, null, 73.33);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (19, 1, null, 43.23);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (20, 1, null, 67.04);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (21, 1, null, 60.57);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (22, 1, null, 57.92);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (23, 1, null, 65.1);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (24, 1, null, 88.51);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (25, 1, 795254, 1.53);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (26, 1, null, 65.26);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (27, 1, null, 28.28);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (28, 1, null, 24.34);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (29, 1, null, 23.01);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (30, 1, null, 21.77);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (31, 1, null, 93.89);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (32, 1, 727786, 87.38);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (33, 1, null, 3.91);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (34, 1, null, 26.45);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (35, 1, null, 74.18);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (36, 1, null, 0.08);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (37, 1, null, 21.12);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (38, 1, null, 14.35);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (39, 1, null, 97.6);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (40, 1, null, 44.12);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (41, 1, null, 66.32);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (42, 1, null, 50.08);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (43, 1, null, 46.13);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (44, 1, 518594, 80.17);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (45, 1, 844033, 7.16);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (46, 1, null, 45.87);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (47, 1, 92357, 55.09);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (48, 1, null, 49.05);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (49, 1, null, 42.21);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (50, 1, null, 82.94);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (51, 1, null, 99.42);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (52, 1, 856213, 43.37);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (53, 1, null, 2.99);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (54, 1, null, 98.97);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (55, 1, 65023, 26.58);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (56, 1, 868024, 5.34);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (57, 1, null, 16.21);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (58, 1, null, 89.95);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (59, 1, 632899, 70.91);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (60, 1, null, 2.29);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (61, 1, null, 55.11);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (62, 1, null, 47.74);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (63, 1, null, 61.15);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (64, 1, null, 58.36);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (65, 1, null, 7.14);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (66, 1, null, 7.05);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (67, 1, null, 1.96);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (68, 1, null, 70.6);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (69, 1, null, 32.09);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (70, 1, null, 92.09);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (71, 1, null, 34.84);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (72, 1, null, 93.58);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (73, 1, null, 20.79);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (74, 1, 738136, 56.16);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (75, 1, null, 56.04);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (76, 1, null, 22.03);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (77, 1, null, 56.84);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (78, 1, null, 42.54);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (79, 1, 938165, 6.37);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (80, 1, null, 2.76);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (81, 1, null, 81.09);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (82, 1, null, 43.89);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (83, 1, null, 22.76);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (84, 1, null, 60.04);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (85, 1, null, 6.29);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (86, 1, null, 86.28);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (87, 1, null, 99.87);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (88, 1, null, 5.72);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (89, 1, null, 96.87);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (90, 1, null, 70.54);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (91, 1, 471020, 3.01);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (92, 1, null, 35.39);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (93, 1, null, 26.65);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (94, 1, null, 41.18);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (95, 1, null, 17.65);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (96, 1, null, 39.86);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (97, 1, null, 74.41);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (98, 1, null, 52.19);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (99, 1, null, 53.51);
INSERT INTO price_ranges (item_id, min_quantity, max_quantity, price)
VALUES (100, 1, null, 29.2);

INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Oct-25', 'RECEIVED', null, 19, 826);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Jul-09', 'RECEIVED', null, 32, 256);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Jan-08', 'RECEIVED', null, 35, 535);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Apr-07', 'RECEIVED', 499.71, 10, 244);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Feb-08', 'RECEIVED', null, 14, 254);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Mar-31', 'RECEIVED', 22.28, 7, 517);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Mar-23', 'RECEIVED', null, 24, 457);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('19-Dec-22', 'RECEIVED', 179.03, 15, 758);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Jul-31', 'RECEIVED', 683.65, 27, 632);
INSERT INTO orders (order_date, status, shipping_cost, customer_id, address_id)
VALUES ('20-Mar-03', 'RECEIVED', 307.24, 13, 284);

INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (10, 29, 33);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (5, 8, 62);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (5, 48, 36);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (1, 47, 12);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (3, 29, 44);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (5, 13, 47);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (6, 75, 91);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (7, 62, 8);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (6, 82, 56);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (7, 37, 3);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (7, 84, 100);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (9, 76, 82);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (5, 25, 79);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (6, 53, 62);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (2, 19, 5);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (8, 2, 46);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (7, 39, 13);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (4, 89, 26);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (7, 24, 97);
INSERT INTO orders_items (order_id, item_id, ordered_item_quantity)
VALUES (5, 44, 76);

INSERT INTO orders_employees (order_id, employee_id, role)
VALUES (7, 44, 'logistical');
INSERT INTO orders_employees (order_id, employee_id, role)
VALUES (2, 53, 'contingency');
INSERT INTO orders_employees (order_id, employee_id, role)
VALUES (5, 23, 'optimal');
INSERT INTO orders_employees (order_id, employee_id, role)
VALUES (9, 58, 'emulation');
INSERT INTO orders_employees (order_id, employee_id, role)
VALUES (1, 56, 'optimal');

INSERT INTO items_categories (item_id, category_id)
VALUES (32, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (52, 9);
INSERT INTO items_categories (item_id, category_id)
VALUES (13, 9);
INSERT INTO items_categories (item_id, category_id)
VALUES (46, 2);
INSERT INTO items_categories (item_id, category_id)
VALUES (60, 7);
INSERT INTO items_categories (item_id, category_id)
VALUES (22, 1);
INSERT INTO items_categories (item_id, category_id)
VALUES (60, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (75, 6);
INSERT INTO items_categories (item_id, category_id)
VALUES (81, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (41, 2);
INSERT INTO items_categories (item_id, category_id)
VALUES (41, 8);
INSERT INTO items_categories (item_id, category_id)
VALUES (76, 8);
INSERT INTO items_categories (item_id, category_id)
VALUES (81, 7);
INSERT INTO items_categories (item_id, category_id)
VALUES (12, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (12, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (69, 10);
INSERT INTO items_categories (item_id, category_id)
VALUES (52, 7);
INSERT INTO items_categories (item_id, category_id)
VALUES (36, 3);
INSERT INTO items_categories (item_id, category_id)
VALUES (37, 4);
INSERT INTO items_categories (item_id, category_id)
VALUES (48, 8);

INSERT INTO warehouses_items (warehouse_id, item_id, item_quantity)
VALUES (1, 83, 276);
INSERT INTO warehouses_items (warehouse_id, item_id, item_quantity)
VALUES (7, 60, 345);
INSERT INTO warehouses_items (warehouse_id, item_id, item_quantity)
VALUES (6, 2, 254);
INSERT INTO warehouses_items (warehouse_id, item_id, item_quantity)
VALUES (6, 46, 250);
INSERT INTO warehouses_items (warehouse_id, item_id, item_quantity)
VALUES (3, 35, 140);

INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('26-Mar-2020', 2730.67, 1);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-Dec-2019', 1324.88, 2);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Sep-2020', 2138.38, 3);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('18-Nov-2019', 1742.37, 4);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('17-Feb-2020', 2010.12, 5);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('17-Apr-2020', 898.82, 6);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-May-2020', 1033.95, 7);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Oct-2020', 1884.56, 8);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('18-Aug-2020', 2518.18, 9);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('30-Dec-2019', 1074.52, 10);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('15-Dec-2019', 1169.16, 11);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-Dec-2019', 750.41, 12);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('04-Nov-2020', 1612.05, 13);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('29-Feb-2020', 2184.24, 14);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Aug-2020', 1130.77, 15);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('01-Aug-2020', 864.33, 16);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('01-Jan-2020', 2097.2, 17);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Feb-2020', 1526.96, 18);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-Oct-2020', 2735.87, 19);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('27-Aug-2020', 1780.09, 20);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('20-Jul-2020', 1018.95, 21);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('09-Oct-2020', 2008.76, 22);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('22-Nov-2019', 764.79, 23);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('05-Sep-2020', 2702.45, 24);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Mar-2020', 1224.36, 25);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('25-Dec-2019', 2068.67, 26);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('05-Apr-2020', 1906.68, 27);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Jun-2020', 2915.19, 28);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('19-Mar-2020', 1882.82, 29);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('24-Jul-2020', 1986.84, 30);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-Feb-2020', 807.37, 31);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('18-Nov-2019', 1999.17, 32);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('20-Jan-2020', 1439.72, 33);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('15-Apr-2020', 1249.21, 34);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('31-Dec-2019', 2883.62, 35);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Oct-2020', 2941.61, 36);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('14-Oct-2020', 1744.12, 37);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('25-Feb-2020', 2961.44, 38);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('12-Sep-2020', 834.0, 39);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('29-Jan-2020', 1077.49, 40);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('19-Oct-2020', 2123.18, 41);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-May-2020', 2313.98, 42);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('29-Apr-2020', 821.31, 43);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Nov-2020', 2763.54, 44);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('14-Nov-2020', 1222.69, 45);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('03-Jan-2020', 1615.65, 46);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('17-Jul-2020', 1145.21, 47);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('01-Apr-2020', 2381.88, 48);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('15-Mar-2020', 1543.14, 49);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Sep-2020', 2269.29, 50);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('06-Aug-2020', 1897.21, 51);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Mar-2020', 1268.52, 52);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-Jan-2020', 1404.04, 53);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('26-Oct-2020', 2061.48, 54);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('26-May-2020', 2079.37, 55);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('16-Jun-2020', 2634.58, 56);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('06-Dec-2019', 1523.48, 57);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('14-Jul-2020', 2478.72, 58);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Jul-2020', 912.3, 59);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('04-Aug-2020', 1528.41, 60);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('02-Dec-2019', 1712.69, 61);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('12-Mar-2020', 1092.38, 62);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('17-Sep-2020', 2315.88, 63);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('22-Mar-2020', 2453.31, 64);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-Dec-2019', 892.59, 65);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('25-Feb-2020', 1557.64, 66);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('09-Apr-2020', 2631.73, 67);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('17-Apr-2020', 2736.1, 68);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('27-Jul-2020', 1193.63, 69);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('23-Oct-2020', 881.72, 70);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('27-Dec-2019', 2239.4, 71);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('05-Sep-2020', 1216.86, 72);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('23-Oct-2020', 937.12, 73);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Apr-2020', 1125.34, 74);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Nov-2019', 2371.57, 75);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('12-May-2020', 1283.97, 76);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Oct-2020', 2660.06, 77);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('28-Jan-2020', 2014.16, 78);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Jun-2020', 1459.8, 79);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('31-Jul-2020', 743.92, 80);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-Aug-2020', 2499.38, 81);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('10-Jul-2020', 2633.99, 82);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-May-2020', 2204.91, 83);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('06-Nov-2020', 1002.06, 84);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('06-Oct-2020', 1444.55, 85);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('12-Nov-2020', 2458.9, 86);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('31-Mar-2020', 2358.03, 87);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('27-Jun-2020', 1668.11, 88);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('15-Mar-2020', 2904.61, 89);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('18-Jul-2020', 773.69, 90);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Mar-2020', 2063.59, 91);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('13-Mar-2020', 1141.61, 92);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('22-Jan-2020', 845.82, 93);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-May-2020', 2433.53, 94);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('21-Apr-2020', 1595.44, 95);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('25-Aug-2020', 2417.02, 96);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('26-Jun-2020', 1740.84, 97);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('04-Jul-2020', 2150.01, 98);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('08-Oct-2020', 1271.73, 99);
INSERT INTO salaries (salary_date, salary, employee_id)
VALUES ('07-Feb-2020', 2824.0, 100);

INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (1, 2019, 1, 2.52);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (2, 2020, 1, 0.25);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (3, 2018, 1, 0.97);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (4, 2019, 4, 0.54);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (5, 2020, 3, 2.23);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (6, 2017, 1, 1.63);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (7, 2018, 4, 1.78);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (8, 2019, 2, 2.45);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (9, 2020, 1, 1.77);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (10, 2018, 2, 2.29);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (11, 2017, 3, 1.07);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (12, 2020, 2, 0.72);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (13, 2017, 1, 2.23);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (14, 2018, 3, 2.84);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (15, 2017, 3, 2.84);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (16, 2020, 1, 0.84);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (17, 2017, 2, 2.35);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (18, 2017, 3, 0.47);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (19, 2020, 4, 1.5);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (20, 2020, 4, 1.93);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (21, 2018, 3, 1.86);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (22, 2019, 2, 0.98);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (23, 2020, 2, 0.7);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (24, 2019, 3, 0.39);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (25, 2019, 2, 0.45);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (26, 2020, 1, 1.15);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (27, 2018, 2, 0.54);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (28, 2017, 4, 1.34);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (29, 2017, 3, 1.32);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (30, 2020, 3, 0.63);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (31, 2017, 1, 2.41);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (32, 2018, 2, 2.45);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (33, 2018, 2, 1.84);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (34, 2017, 1, 0.18);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (35, 2020, 4, 2.49);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (36, 2019, 4, 0.33);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (37, 2020, 4, 2.18);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (38, 2020, 3, 0.16);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (39, 2020, 1, 0.48);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (40, 2018, 2, 1.69);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (41, 2020, 2, 1.15);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (42, 2018, 1, 2.83);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (43, 2017, 3, 0.69);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (44, 2017, 4, 2.54);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (45, 2017, 1, 2.49);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (46, 2019, 2, 0.59);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (47, 2018, 4, 1.61);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (48, 2017, 2, 2.16);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (49, 2018, 4, 2.44);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (50, 2020, 4, 0.08);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (51, 2018, 1, 0.97);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (52, 2018, 2, 1.28);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (53, 2020, 1, 2.0);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (54, 2017, 2, 2.2);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (55, 2020, 4, 2.16);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (56, 2018, 1, 0.74);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (57, 2020, 2, 1.3);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (58, 2019, 2, 1.76);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (59, 2018, 1, 0.72);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (60, 2017, 3, 0.12);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (61, 2018, 4, 2.22);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (62, 2018, 3, 2.92);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (63, 2019, 3, 0.25);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (64, 2018, 3, 1.59);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (65, 2018, 1, 2.86);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (66, 2019, 1, 1.04);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (67, 2019, 2, 0.53);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (68, 2019, 2, 1.66);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (69, 2019, 3, 1.87);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (70, 2019, 3, 2.48);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (71, 2017, 3, 1.41);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (72, 2018, 1, 1.29);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (73, 2020, 3, 0.41);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (74, 2019, 1, 2.56);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (75, 2019, 4, 2.57);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (76, 2018, 2, 2.68);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (77, 2017, 4, 0.34);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (78, 2017, 1, 2.66);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (79, 2019, 1, 0.36);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (80, 2020, 1, 0.57);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (81, 2017, 3, 1.72);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (82, 2020, 1, 2.75);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (83, 2020, 4, 1.02);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (84, 2018, 4, 0.47);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (85, 2020, 1, 1.19);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (86, 2018, 4, 0.09);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (87, 2017, 2, 2.3);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (88, 2019, 3, 2.04);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (89, 2017, 3, 1.22);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (90, 2019, 2, 0.98);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (91, 2020, 4, 2.09);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (92, 2018, 3, 1.06);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (93, 2018, 1, 1.37);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (94, 2020, 4, 2.37);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (95, 2018, 4, 0.06);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (96, 2017, 2, 1.12);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (97, 2019, 3, 2.38);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (98, 2017, 1, 2.21);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (99, 2018, 2, 0.28);
INSERT INTO scores (employee_id, score_year, score_quarter, score)
VALUES (100, 2018, 2, 0.43);

