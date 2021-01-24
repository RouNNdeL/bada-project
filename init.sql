-- Table companies

CREATE TABLE companies
(
    id                 SERIAL,
    name               VARCHAR(75)  NOT NULL,
    nip                CHAR(13)     NOT NULL,
    establishment_date TIMESTAMP(0) NOT NULL,
    krs                CHAR(10)     NOT NULL,
    parent_company_id  INTEGER DEFAULT NULL,
    hq_address_id      INTEGER      NOT NULL,
    tax_address_id     INTEGER      NOT NULL
);


CREATE
    INDEX IX_fk_parent_company ON companies (id);


CREATE
    INDEX IX_fk_has_hq ON companies (id);


CREATE
    INDEX IX_fk_has_tax_address ON companies (id);


ALTER TABLE companies
    ADD CONSTRAINT company_id_key PRIMARY KEY (id);


ALTER TABLE companies
    ADD CONSTRAINT nip_key UNIQUE (nip);


ALTER TABLE companies
    ADD CONSTRAINT krs_key UNIQUE (krs);

-- Table warehouses

CREATE TABLE warehouses
(
    id                     SERIAL,
    name                   VARCHAR(100)     NOT NULL,
    capacity               DOUBLE PRECISION NOT NULL,
    number_of_loading_bays INTEGER          NOT NULL,
    is_retail              CHAR(1)          NOT NULL,
    company_id             INTEGER          NOT NULL,
    address_id             INTEGER          NOT NULL,
    manager_id             INTEGER DEFAULT NULL
);


CREATE
    INDEX IX_fk_company_has_warehouse ON warehouses (id);


CREATE
    INDEX IX_warehouse_has_address ON warehouses (id);


CREATE
    INDEX IX_manages ON warehouses (id);


ALTER TABLE warehouses
    ADD CONSTRAINT warehouse_id_key PRIMARY KEY (id);

-- Table employees

CREATE TABLE employees
(
    id              SERIAL,
    username        VARCHAR(20)             NOT NULL,
    password        VARCHAR(100)            NOT NULL,
    email           VARCHAR(50)             NOT NULL,
    role            VARCHAR(256) DEFAULT '' NOT NULL,
    first_name      VARCHAR(30)             NOT NULL,
    last_name       VARCHAR(50)             NOT NULL,
    pesel           CHAR(11)                NOT NULL,
    employment_date TIMESTAMP(0)            NOT NULL,
    phone_number    VARCHAR(20)             NOT NULL,
    company_id      INTEGER                 NOT NULL,
    warehouse_id    INTEGER      DEFAULT NULL,
    address_id      INTEGER                 NOT NULL
);


CREATE
    INDEX IX_fk_company_employs ON employees (id);


CREATE
    INDEX IX_fk_works_in ON employees (id);


CREATE
    INDEX IX_fk_employee_has_address ON employees (id);


ALTER TABLE employees
    ADD CONSTRAINT employee_id_key PRIMARY KEY (id);

-- Table items

CREATE TABLE items
(
    id          SERIAL,
    name        VARCHAR(100) NOT NULL,
    description TEXT
);


ALTER TABLE items
    ADD CONSTRAINT item_id_key PRIMARY KEY (id);

-- Table price_ranges

CREATE TABLE price_ranges
(
    item_id      INTEGER        NOT NULL,
    min_quantity INTEGER        NOT NULL
        CONSTRAINT min_quantity_greater_0 CHECK (min_quantity >= 0),
    price        DECIMAL(10, 2) NOT NULL
        CONSTRAINT price_geq_0 CHECK (price > 0)
);


CREATE
    INDEX IX_fk_has_price_range ON price_ranges (item_id, min_quantity);

ALTER TABLE price_ranges
    ADD CONSTRAINT PK_price_ranges PRIMARY KEY (item_id, min_quantity);

-- Table customers

CREATE TABLE customers
(
    id           SERIAL,
    username     VARCHAR(20)  NOT NULL,
    password     VARCHAR(100) NOT NULL,
    email        VARCHAR(50)  NOT NULL,
    first_name   VARCHAR(30)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    nip          CHAR(13),
    phone_number VARCHAR(20),
    company_id   INTEGER      NOT NULL,
    address_id   INTEGER DEFAULT NULL
);


CREATE
    INDEX IX_fk_customer_has_address ON customers (id);


CREATE
    INDEX IX_fk_is_customer_of ON customers (id);


ALTER TABLE customers
    ADD CONSTRAINT PK_customers PRIMARY KEY (id);

-- Table orders

CREATE TABLE orders
(
    id                   SERIAL,
    date                 TIMESTAMP(0) NOT NULL,
    status               VARCHAR(20)  NOT NULL DEFAULT 'RECEIVED'
        CONSTRAINT status_constraint
            CHECK (status in
                   ('RECEIVED',
                    'IN_PROGRESS',
                    'READY_FOR_SHIPMENT',
                    'COMPLETED')),
    shipping_cost        DECIMAL(10, 2),
    customer_id          INTEGER      NOT NULL,
    assigned_employee_id INTEGER,
    address_id           INTEGER      NOT NULL
);


CREATE
    INDEX IX_fk_places_order ON orders (id);


CREATE
    INDEX IX_is_ordered_to ON orders (id);


ALTER TABLE orders
    ADD CONSTRAINT order_id_key PRIMARY KEY (id);

-- Table categories

CREATE TABLE categories
(
    id          SERIAL,
    name        VARCHAR(30) NOT NULL,
    description TEXT
);


ALTER TABLE categories
    ADD CONSTRAINT category_id_key PRIMARY KEY (id);


CREATE TABLE items_categories
(
    item_id     INTEGER NOT NULL,
    category_id INTEGER NOT NULL
);

-- Table orders_items

CREATE TABLE orders_items
(
    order_id              INTEGER NOT NULL,
    item_id               INTEGER NOT NULL,
    ordered_item_quantity INTEGER NOT NULL
);


CREATE TABLE warehouses_items
(
    item_id       INTEGER NOT NULL,
    warehouse_id  INTEGER NOT NULL,
    item_quantity INTEGER NOT NULL
);

-- Table addresses

CREATE TABLE addresses
(
    id             SERIAL,
    address_line_1 VARCHAR(100) NOT NULL,
    address_line_2 VARCHAR(50),
    zipcode        VARCHAR(15),
    city           VARCHAR(30),
    country_id     INTEGER      NOT NULL
);


CREATE
    INDEX IX_fk_address_country ON addresses (id);


ALTER TABLE addresses
    ADD CONSTRAINT PK_addresses PRIMARY KEY (id);

-- Table countries

CREATE TABLE countries
(
    id           SERIAL,
    country_name VARCHAR(56) NOT NULL,
    iso_3166_1   CHAR(2)     NOT NULL,
    phone_prefix VARCHAR(3)  NOT NULL
);


ALTER TABLE countries
    ADD CONSTRAINT PK_countries PRIMARY KEY (id);


ALTER TABLE countries
    ADD CONSTRAINT country_name UNIQUE (country_name);


ALTER TABLE countries
    ADD CONSTRAINT iso_3166_1 UNIQUE (iso_3166_1);


ALTER TABLE countries
    ADD CONSTRAINT phone_prefix UNIQUE (phone_prefix);

-- Table salaries

CREATE TABLE salaries
(
    id          SERIAL,
    salary_date TIMESTAMP(0)     NOT NULL,
    salary      DOUBLE PRECISION NOT NULL,
    employee_id INTEGER          NOT NULL
);


CREATE
    INDEX IX_fk_is_paid ON salaries (id);


ALTER TABLE salaries
    ADD CONSTRAINT PK_salaries PRIMARY KEY (id);

-- Table scores

CREATE TABLE scores
(
    id            SERIAL,
    score_year    INTEGER          NOT NULL,
    score_quarter INTEGER          NOT NULL
        CONSTRAINT one_leq_quarter_leq_4 CHECK (score_quarter <= 4
            AND score_quarter >= 1),
    score         DOUBLE PRECISION NOT NULL,
    employee_id   INTEGER          NOT NULL
);


CREATE
    INDEX IX_fk_is_reviewed ON scores (id);


ALTER TABLE scores
    ADD CONSTRAINT PK_scores PRIMARY KEY (id);

ALTER TABLE employees
    ADD CONSTRAINT UsernameEmployees UNIQUE (username);

ALTER TABLE customers
    ADD CONSTRAINT UsernameCustomers UNIQUE (username);


ALTER TABLE companies
    ADD CONSTRAINT fk_parent_company
        FOREIGN KEY (parent_company_id) REFERENCES companies (id);


ALTER TABLE warehouses
    ADD CONSTRAINT fk_company_has_warehouse
        FOREIGN KEY (company_id) REFERENCES companies (id);


ALTER TABLE orders
    ADD CONSTRAINT fk_places_order
        FOREIGN KEY (customer_id) REFERENCES customers (id);


ALTER TABLE orders
    ADD CONSTRAINT fk_handles_order
        FOREIGN KEY (assigned_employee_id) REFERENCES employees (id);

ALTER TABLE employees
    ADD CONSTRAINT fk_works_in
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (id);


ALTER TABLE employees
    ADD CONSTRAINT fk_company_employs
        FOREIGN KEY (company_id) REFERENCES companies (id);


ALTER TABLE price_ranges
    ADD CONSTRAINT fk_has_price_range
        FOREIGN KEY (item_id) REFERENCES items (id);


ALTER TABLE items_categories
    ADD CONSTRAINT fk_is_in_category_items
        FOREIGN KEY (item_id) REFERENCES items (id);

ALTER TABLE items_categories
    ADD CONSTRAINT fk_is_in_category_categories
        FOREIGN KEY (category_id) REFERENCES categories (id);


ALTER TABLE orders_items
    ADD CONSTRAINT fk_is_ordered_orders
        FOREIGN KEY (order_id) REFERENCES orders (id);


ALTER TABLE orders_items
    ADD CONSTRAINT fk_is_ordered_items
        FOREIGN KEY (item_id) REFERENCES items (id);


ALTER TABLE warehouses_items
    ADD CONSTRAINT fk_is_in_stock_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (id);


ALTER TABLE warehouses_items
    ADD CONSTRAINT fk_is_in_stock_items
        FOREIGN KEY (item_id) REFERENCES items (id);


ALTER TABLE addresses
    ADD CONSTRAINT fk_is_in_country
        FOREIGN KEY (country_id) REFERENCES countries (id);


ALTER TABLE customers
    ADD CONSTRAINT fk_customer_address
        FOREIGN KEY (address_id) REFERENCES addresses (id);


ALTER TABLE companies
    ADD CONSTRAINT fk_has_hq
        FOREIGN KEY (hq_address_id) REFERENCES addresses (id);


ALTER TABLE companies
    ADD CONSTRAINT fk_has_tax_address
        FOREIGN KEY (tax_address_id) REFERENCES addresses (id);


ALTER TABLE warehouses
    ADD CONSTRAINT fk_warehouse_has_address
        FOREIGN KEY (address_id) REFERENCES addresses (id);


ALTER TABLE orders
    ADD CONSTRAINT fk_is_ordered_to
        FOREIGN KEY (address_id) REFERENCES addresses (id);


ALTER TABLE warehouses
    ADD CONSTRAINT Manages
        FOREIGN KEY (manager_id) REFERENCES employees (id);


ALTER TABLE customers
    ADD CONSTRAINT is_customer_of
        FOREIGN KEY (company_id) REFERENCES companies (id);


ALTER TABLE salaries
    ADD CONSTRAINT is_paid
        FOREIGN KEY (employee_id) REFERENCES employees (id);


ALTER TABLE scores
    ADD CONSTRAINT is_reviewed
        FOREIGN KEY (employee_id) REFERENCES employees (id);


ALTER TABLE employees
    ADD CONSTRAINT fk_employee_has_address
        FOREIGN KEY (address_id) REFERENCES addresses (id);


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

INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '96 Butterfield Parkway', 'Injīl', '01-345', 'Poznań');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '96 Butterfield Parkway', 'Injīl', '34-678', 'Lublin');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '96 Butterfield Parkway', 'Injīl', '02-987', 'Warszawa');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '96 Butterfield Parkway', 'Injīl', '12-789', 'Gdańsk');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '96 Butterfield Parkway', 'Injīl', '01-233', 'Lódź');

INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '96 Butterfield Parkway', 'Injīl', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '84 Bunting Terrace', 'Fandriana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Nancy Junction', 'Pedinó', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '45709 Veith Plaza', 'Chaloem Phra Kiat', '40250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '0298 Boyd Way', 'Zamora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '39899 Morrow Plaza', 'Kamiennik', '48-388', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '50 Shasta Place', 'Krajan Jabungcandi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '3348 7th Park', 'Kokofata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '016 Maple Wood Way', 'Valbo', '818 92', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '15854 Towne Parkway', 'Alquerubim', '3850-312', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '80 Division Road', 'Kahabe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '2 Mendota Circle', 'Sambongpari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '77 Gateway Trail', 'Jīwani', '28360', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '9 Moland Center', 'Lokorae', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '28847 Sunnyside Terrace', 'Malilipot', '4510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '76 Old Gate Trail', 'Huanggu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9473 Dennis Circle', 'Xinjiang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '50 Sycamore Terrace', 'Konstantinovskoye', '356500', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '8115 Talisman Parkway', 'General José de San Martín', '3155', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5 Dorton Center', 'Dhī as Sufāl', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '38842 Crescent Oaks Plaza', 'Mirny', '678179', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '29 Memorial Park', 'Horní Jiřetín', '435 43', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '29 Westridge Point', 'Mpanda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '8 Ludington Terrace', 'Cícero Dantas', '48410-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '07 Ridgeview Hill', 'Dori', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '29 Sunbrook Drive', 'Newmarket on Fergus', 'P17', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '5082 Luster Avenue', 'Ketanggi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '04453 Iowa Crossing', 'Mnichovo Hradiště', '295 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '1265 Northview Point', 'Bafia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '3887 Upham Way', 'Pankrushikha', '658760', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '18652 Sheridan Terrace', 'Maldonado', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '06 Onsgard Alley', 'Cambita Garabitos', '11204', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '9 Charing Cross Crossing', 'Kyenjojo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '001 Starling Terrace', 'Binucayan', '7017', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '498 Bultman Trail', 'Ḩammām Wāşil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '20 Holy Cross Point', 'Pelabuhanratu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6 8th Avenue', 'Askersund', '696 30', 'Örebro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '0 Russell Road', 'Shreveport', '71161', 'Louisiana');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1 Oriole Terrace', 'Thawat Buri', '40160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '571 Lake View Court', 'Orlando', '32835', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1 Gerald Avenue', 'Soledar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '759 Scott Road', 'Lalupon', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '52 Beilfuss Alley', 'Yangba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Arapahoe Plaza', 'Stryszawa', '34-205', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '87 Troy Pass', 'Lusigang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '05798 Tennyson Plaza', 'Shīrvān', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '49765 Thackeray Point', 'Bakuriani', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '81 Washington Point', 'Qinggang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '79 Farragut Park', 'Beška', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7916 Northfield Street', 'San Jorge', '5117', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '82130 Westerfield Point', 'Pretoria', '0204', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '46376 Talmadge Pass', 'Brasília', '70000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '7008 Chive Avenue', 'Loučeň', '289 37', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '8 Scofield Court', 'Şirrīn ash Shamālīyah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '90326 Trailsway Pass', 'Colorado Springs', '80905', 'Colorado');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '991 Hovde Place', 'Lupo', '5616', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '515 Crowley Way', 'Hamburg Bramfeld', '22179', 'Hamburg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '992 Utah Pass', 'Kalandagan', '9802', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '3 West Crossing', 'Yantan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '4166 Northfield Parkway', 'Enschede', '7514', 'Provincie Overijssel');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '71 Raven Drive', 'Singasari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '89 Pearson Crossing', 'Pīshvā', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '201 Reindahl Plaza', 'Berbek', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '4 Bonner Trail', 'Ulapes', '5473', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '59 Burrows Street', 'Żarki-Letnisko', '42-311', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '2 Browning Avenue', 'Cuauhtemoc', '40068', 'Guerrero');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Morning Pass', 'Pegongan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '90 Basil Drive', 'Palermo', '90141', 'Sicilia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '71 Moose Trail', 'Cagayan', '7508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3731 Starling Alley', 'Biaokou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '992 Westport Alley', 'Rio Grande da Serra', '09450-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '611 Toban Hill', 'Valence', '26009 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '7577 Village Green Park', 'Pizhanka', '613380', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '96 Moose Circle', 'Pho Thong', '14120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '8987 Ilene Terrace', 'Lijia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '733 Ridgeway Pass', 'Gabaldon', '3131', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '5439 Coleman Crossing', 'Krasnotur’insk', '624449', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '63366 Schurz Avenue', 'Kesabpur', '8130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '4110 Warner Lane', 'Wotan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '59179 Susan Avenue', 'Kalemie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '19 Waxwing Place', 'Fengyi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '5 Golf View Place', 'Oliveirinha', '3810-856', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '47920 Kinsman Hill', 'Sīnah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '36110 Becker Circle', 'Komprachcice', '46-070', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '4961 Hovde Hill', 'Duishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '80 Ridgeview Street', 'Jezerce', '53231', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '492 Nova Drive', 'Golem', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0 Scofield Trail', 'Novyye Kuz’minki', '301333', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7 Oakridge Parkway', 'Sandata', '347612', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '00425 Waubesa Drive', 'Itacurubí del Rosario', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '54 Sundown Way', 'Teongtoda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '7798 Armistice Crossing', 'Gręboszów', '33-260', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '153 Raven Parkway', 'Fengzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '226 Sundown Pass', 'Yingzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '60 Darwin Road', 'Castlebellingham', 'Y34', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '6 Forest Center', 'Ol’ginka', '352840', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '15543 Tennessee Pass', 'Tirtopuro', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '30390 Bonner Trail', 'Mawlamyine', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8 Northview Alley', 'Castelli', '7114', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '57 Leroy Park', 'Phitsanulok', '65000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '16 Hansons Point', 'Krajan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '8 Glacier Hill Trail', 'Megati Kelod', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '67 Canary Street', 'Yangzi Jianglu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '53328 Hooker Street', 'Petrovo-Dal’neye', '143422', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '69 Tennyson Street', 'Liuxia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9256 Almo Street', 'Al Qārah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '2361 Riverside Avenue', 'Ribas do Rio Pardo', '79180-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '859 Banding Crossing', 'Pensacola', '32505', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '6 Raven Place', 'Ruzayevka', '431469', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '4269 Randy Place', 'Lomboy', '1126', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5268 Raven Road', 'Bassila', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8 Atwood Trail', 'Ban Phan Don', '41220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '3 2nd Junction', 'Palenggihan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '25 Thierer Terrace', 'Anle', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '905 Larry Alley', 'Lyubinskiy', '646160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Garrison Plaza', 'Falköping', '521 96', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8 Colorado Way', 'Mougins', '06254 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '42 Emmet Lane', 'Goba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '547 Emmet Circle', 'Castanheiro do Sul', '5130-025', 'Viseu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '576 Sloan Avenue', 'Skołyszyn', '38-242', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '6 Debs Court', 'Torre', '5050-345', 'Vila Real');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7 Sage Plaza', 'Sinanju', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '1417 Hovde Terrace', 'Bieto', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '3 Pleasure Circle', 'Arvika', '671 41', 'Värmland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '37852 Portage Road', 'Komyshnya', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9396 Melrose Point', 'Bayshint', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '76 Elka Terrace', 'Brikama Nding', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '46 Valley Edge Drive', 'Widorokandang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '591 Elka Street', 'Tol’yatti', '456922', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '4 Surrey Pass', 'Shangshuai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '1 Crowley Alley', 'Golema Rečica', '1219', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '4 Division Terrace', 'Gushui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '11 Sachtjen Pass', 'Kari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '1 Barnett Center', 'Limulunga', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '34700 Oxford Way', 'Jardín América', '3332', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '92796 American Point', 'Kombandaru', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '02153 Mockingbird Street', 'Shebunino', '694761', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '417 Anthes Plaza', 'G‘azalkent', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7493 Goodland Place', 'Bagé', '96400-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '450 Harper Center', 'Áno Kopanákion', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '21 Morrow Avenue', 'Zaplavnoye', '404609', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2 Mesta Point', 'Tsagaanchuluut', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '347 Fair Oaks Place', 'Nyakhachava', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '62 Elka Point', 'Mengeš', '1234', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '8 Michigan Parkway', 'Mao’er', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1474 Bartillon Alley', 'Koryukivka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '77 Rigney Plaza', 'Suhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '740 Morningstar Street', 'Bang Mun Nak', '66120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8684 Crescent Oaks Plaza', 'Krrabë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '01319 6th Court', 'Komletinci', '32253', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Hollow Ridge Circle', 'Fenshui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '731 Morningstar Plaza', 'Farkhah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0 Tomscot Crossing', 'Kavadarci', '1430', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '854 Morning Crossing', 'Sumberngerjat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '43780 Marquette Drive', 'Shimokizukuri', '802-0015', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '017 Mayfield Point', 'Baota', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Schmedeman Terrace', 'Ashikaga', '374-0079', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '69207 Daystar Park', 'Las Mesas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '98316 Bunting Hill', 'Anabar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '685 Gale Circle', 'Vagonoremont', '452155', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '15 Forest Dale Court', 'Lille', '59007 CEDEX', 'Nord-Pas-de-Calais');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '70430 Algoma Park', 'Danané', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '48164 Browning Hill', 'Oštarije', '47302', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '023 Quincy Drive', 'Zacatecoluca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '99323 Calypso Way', 'Nancy', '54046 CEDEX', 'Lorraine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '2604 Corben Pass', 'Gryfów Śląski', '59-620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '79306 Ludington Center', 'Idrinskoye', '662680', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '4848 Elgar Lane', 'Daugavgrīva', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6546 Ramsey Lane', 'Galimuyod', '2709', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '6 Pepper Wood Way', 'Sacsamarca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '4957 Delaware Trail', 'Makui', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '713 West Place', 'Pakuranga', '2140', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7692 Loeprich Lane', 'El’brus', '361603', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '232 Dorton Park', 'San Pablo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '54719 Annamark Park', 'Kokofata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '20346 Fieldstone Street', 'Belo Horizonte', '30000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '79 Dapin Place', 'Jicomé', '11201', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '498 Melby Alley', 'Pepayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '381 Namekagon Road', 'Emmen', '7804', 'Provincie Drenthe');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '81 Pierstorff Center', 'Pamiers', '09104 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '8 Carey Trail', 'Fleury-les-Aubrais', '45404 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '417 Debs Terrace', 'Pétionville', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0564 Cardinal Circle', 'Hats’avan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '71 Waywood Junction', 'Topeka', '66611', 'Kansas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '82379 Shelley Way', 'Tumaco', '528539', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '3329 Jenna Parkway', 'San Cristóbal', '11511', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '8177 Melody Court', 'Zhangye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '0958 Sherman Junction', 'Cisitu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '416 Crownhardt Pass', 'Pasco', '5925', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '85 Pond Center', 'Chongxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7268 Farragut Way', 'Darkūsh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '6 Northview Crossing', 'Västra Frölunda', '421 10', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9808 Trailsway Place', 'Pontang Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2 Moland Hill', 'Châteauroux', '36009 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '6 Hollow Ridge Road', 'Xiaohe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5979 Lawn Hill', 'Damaying', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '56679 Summerview Hill', 'Nantes', '44324 CEDEX 3', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '9 Bashford Drive', 'Chengqu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '633 Division Center', 'Kondinskoye', '628210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '90153 Scott Plaza', 'Inriville', '2587', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8 Bartillon Road', 'Queniquea', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '895 Village Street', 'Darłowo', '76-153', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '29 Mendota Street', 'Cumaná', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '26 Northview Road', 'Talacogon', '8510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '2687 Spohn Pass', 'Jaguaruana', '62823-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '2444 Victoria Circle', 'Jönköping', '554 52', 'Jönköping');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '98501 Butternut Junction', 'Kostyantynivka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '3191 Florence Park', 'Novyye Gorki', '155101', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '998 Merry Crossing', 'Meishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1 Corscot Center', 'Nazyvayevsk', '646100', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '636 Helena Drive', 'Diên Khánh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '39 Red Cloud Plaza', 'Troitsk', '142191', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '935 Golden Leaf Road', 'Yangxiang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0 Onsgard Circle', 'Şafwá', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '240 Spenser Drive', 'Heyu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '19394 Ryan Circle', 'Bolian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '25 Magdeline Terrace', 'Liaobu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '21 Transport Parkway', 'Higashimurayama-shi', '359-1144', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '1 Leroy Crossing', 'Kilafors', '823 80', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1 Golf View Court', 'Perches', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '10950 Upham Pass', 'Coris', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2179 Almo Trail', 'Wielka Wieś', '32-089', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '05490 Morningstar Road', 'Rio Negrinho', '89295-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7 Golden Leaf Road', 'Kalpin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '39833 Stone Corner Way', 'Messina', '98168', 'Sicilia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7 Sundown Terrace', 'Cergy-Pontoise', '95809 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '91 Nelson Street', 'Puerto Nariño', '911018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '43977 Gina Road', 'Chengnan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '08813 Westerfield Terrace', 'Waihibar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '443 Vahlen Parkway', 'Rabat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '0922 Independence Circle', 'Pueblo Nuevo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '21104 Ruskin Street', 'Sangongqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '9755 Rutledge Plaza', 'El Paso', '79934', 'Texas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '760 Dapin Lane', 'Cabreúva', '13315-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '011 Dovetail Hill', 'Liushun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '923 Transport Way', 'Bestovje', '10437', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1498 Lotheville Drive', 'Kyzylzhar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '886 Rigney Drive', 'Fuhai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1 Menomonie Drive', 'Oenpeotnai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '044 Roth Pass', 'Tongjing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '61518 Forster Street', 'Canelas', '3865-004', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '030 Victoria Court', 'Zalishchyky', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '178 Blackbird Terrace', 'Markaz Mudhaykirah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Messerschmidt Road', 'Čelopek', '1227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '22 Kings Point', 'Hujia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7 Monterey Circle', 'Lýkeio', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Arapahoe Avenue', 'Frakulla e Madhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Kensington Drive', 'Lolayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1 Jenifer Avenue', 'Quichuay', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '97 Prairie Rose Alley', 'Tres Unidos', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '14 Transport Court', 'Biñan', '4116', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '86467 Beilfuss Circle', 'Jambuwerkrajan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '81249 Oak Plaza', 'Ashley', 'SN13', 'England');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '775 Darwin Lane', 'Vohibinany', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '223 Briar Crest Place', 'Baolong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '4591 Washington Parkway', 'Jishigang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '3 Weeping Birch Terrace', 'Monte de Fralães', '4775-174', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '66 Di Loreto Lane', 'Čáslav', '407 25', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '27740 Packers Parkway', 'Vélo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '49 Maple Park', 'Tiebukenwusan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '284 Ridge Oak Junction', 'Stanovoye', '399734', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '0538 Morrow Point', 'Łąck', '09-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '59 3rd Plaza', 'Jēkabpils', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '3786 Swallow Park', 'Coronda', '2240', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '396 Mallard Hill', 'Albertville', '73209 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '6764 Blackbird Place', 'Budta', '1774', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '5 Dottie Street', 'Gafanha de Aquém', '3830-017', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1 Moland Road', 'San Nicolas', '4207', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0 Southridge Pass', 'Sosnovka', '442064', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '0614 Tony Alley', 'Kant', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '117 Duke Plaza', 'Lamalera', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1 Evergreen Terrace', 'Jinpanling', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '3750 Corben Parkway', 'Béziers', '34545 CEDEX', 'Languedoc-Roussillon');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Evergreen Lane', 'Rabaul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '52166 Hansons Parkway', 'Sempu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0 Maryland Crossing', 'Potlot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '29 Helena Street', 'Ziyang Chengguanzhen', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '40 Hansons Junction', 'Golema Rečica', '1219', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '39 Sutherland Point', 'Takeo', '950-0862', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '405 Lakewood Gardens Avenue', 'Dipayal', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '40975 Norway Maple Junction', 'Kyzyl-Oktyabr’skiy', '457162', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '47098 Prairieview Parkway', 'Donggaocun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9198 Oneill Alley', 'Manga', '4506', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '73 Jana Way', 'Podu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '867 John Wall Road', 'Anjie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '60430 Hanover Hill', 'Luoxiong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '84 Sunbrook Plaza', 'Povorino', '397355', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '4505 International Alley', 'Wenping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '2581 Shelley Point', 'Bakıxanov', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '2 Crescent Oaks Point', 'Tobatí', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '71 Sachtjen Circle', 'Iwaki', '999-3503', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '685 International Point', 'Nāḩiyat Hīrān', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '508 Springs Crossing', 'Černý Most', '198 00', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '7 Rigney Plaza', 'Bearna', 'F93', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '33 Towne Way', 'Ribeiro', '4755-578', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '1953 Valley Edge Plaza', 'Doroslovo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '2 Sachs Parkway', 'Rybnoye', '393917', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '7129 Talisman Circle', 'Lalapanzi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '20 Burrows Junction', 'Sunduk', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '76695 Dahle Parkway', 'Zhireken', '673498', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '43 Park Meadow Plaza', 'Bilajer', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '05051 Dwight Pass', 'San Diego', '4032', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '0649 Barby Plaza', 'Araguaína', '77800-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '9 Quincy Parkway', 'Indianapolis', '46202', 'Indiana');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '23 Del Sol Circle', 'Gupakan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '26 Farwell Court', 'Bcharré', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5 Mccormick Point', 'Ban Takhun', '34260', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '42 Kenwood Hill', 'Ciechanowiec', '18-230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '421 Main Crossing', 'Meylan', '38244 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Delladonna Lane', 'Bratsk', '665709', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '7 Bashford Center', 'Na Khu', '70170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '3 Glendale Drive', 'Enniskerry', 'D18', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6274 Nova Avenue', 'Żabbar', 'ZBR', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2 Rieder Junction', 'Sambongmulyo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '35 Sachtjen Way', 'Fangshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '8473 Oak Valley Park', 'Buarcos', '3080-222', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2415 Park Meadow Lane', 'Lovrenc na Pohorju', '2344', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '4 Farwell Pass', 'Ransang', '1080', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '45 Park Meadow Trail', 'Alvaro Obregon', '74060', 'Puebla');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '8 Service Drive', 'Casilda', '2170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6 Atwood Parkway', 'Huangtian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '6 Novick Alley', 'Thepharak', '85130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '21533 Texas Point', 'Saint-Priest-en-Jarez', '42275 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '630 Esch Park', 'Frýdek-Místek', '733 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '18 Katie Point', 'Mukayrās', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '293 Onsgard Street', 'La Esperanza', '95590', 'Veracruz Llave');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '34871 Green Place', 'Carrefour', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '91791 Russell Pass', 'Asheville', '28815', 'North Carolina');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Kensington Place', 'Suita', '956-0123', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '71 Wayridge Trail', 'Nassarawa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '2 Montana Circle', 'Zhangfeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '0780 Florence Pass', 'Changgai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '100 Iowa Center', 'Passal', '4960-130', 'Viana do Castelo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '6 South Crossing', 'Villeurbanne', '69624 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '86618 Commercial Center', 'Onguday', '649446', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2282 Hazelcrest Hill', 'Guapi', '196009', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '9 Bunker Hill Street', 'Alfenas', '37130-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '21661 Arizona Circle', 'Mirimire', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '794 Scott Place', 'Kongkeshu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0 Del Sol Junction', 'Wachira Barami', '45250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '59 Superior Circle', 'Järfälla', '176 71', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '0 Fairview Way', 'Imtarfa', 'ZBG', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '61504 Union Pass', 'Santo Domingo', '4508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '03324 Quincy Court', 'Yangjian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '038 Moulton Point', 'Tai’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Golden Leaf Trail', 'Aksarka', '629620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1 Schiller Place', 'Cikandang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '439 Melody Way', 'Kotakan Selatan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '235 Roth Avenue', 'Cristalina', '73850-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7877 Golden Leaf Court', 'Žďár nad Sázavou', '592 11', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '5 Old Shore Plaza', 'Atipuluhan', '6124', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '42212 Maple Terrace', 'Marietta', '30061', 'Georgia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '73 Mccormick Avenue', 'Áyioi Apóstoloi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '34 Riverside Street', 'San Agustin', '8305', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '266 Morning Court', 'Martakert', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '28684 Katie Crossing', 'Taganskiy', '662327', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '43749 Upham Circle', 'Campo Mourão', '87300-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '6675 Anderson Terrace', 'Uhniv', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '94 Vahlen Court', 'Liangting', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7 Chive Way', 'Kosum Phisai', '44140', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '54281 Waubesa Alley', 'Le Mans', '72100', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5572 Stang Point', 'Tullich', 'AB55', 'Scotland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '94 Browning Circle', 'Ulster Spring', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '65084 Gina Center', 'Barra do Garças', '78600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '24 Bay Drive', 'Cotabato', '9708', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '64854 Main Circle', 'Na Klang', '39170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '170 Commercial Hill', 'Palaiseau', '91129 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '88 Carpenter Alley', 'Muli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3 Grasskamp Avenue', 'Rybatskoye', '196851', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '63 La Follette Center', 'Lgota Wielka', '97-565', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9670 International Court', 'Danxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '60017 1st Hill', 'Shibukawa', '979-1451', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7866 Bowman Pass', 'Cerme Kidul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '16797 Farragut Point', 'Marapat', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '17753 Schurz Way', 'Ilyich', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5413 Cottonwood Place', 'Chiri-Yurt', '366303', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '8 Barby Circle', 'Saltsjö-Boo', '132 30', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '51 Namekagon Drive', 'Hoeryŏng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '50081 Thompson Point', 'Longjumeau', '91821 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '35647 Gulseth Junction', 'Bairros', '4785-512', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '06 Eagle Crest Point', 'Coromandel', '38550-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '897 Russell Place', 'Novosin’kovo', '141896', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '84379 Fair Oaks Trail', 'Villa del Carmen', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '774 Oxford Crossing', 'Ban Haet', '10700', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '860 Armistice Trail', 'Gelang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7236 Marcy Road', 'Cawayan', '5409', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '23 Clemons Drive', 'Ruihong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '56 Straubel Parkway', 'Melchor de Mencos', '17011', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '42 Westend Hill', 'Alfeizerão', '2460-105', 'Leiria');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '624 Park Meadow Plaza', 'Las Palmas', '40054', 'Guerrero');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '4 Hintze Park', 'Xingren', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '99 Schurz Center', 'Perechyn', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1757 Monument Hill', 'Xin’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '4378 Orin Pass', 'Soufrière', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '27499 Sloan Trail', 'Ambatolaona', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '79 Ronald Regan Park', 'Pontes e Lacerda', '78250-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '682 Lerdahl Way', 'Simo', '95201', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '86694 Clyde Gallagher Road', 'Franco da Rocha', '07800-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '4 Judy Plaza', 'Oxelösund', '613 22', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '883 Everett Avenue', 'La Virgen', '50695', 'Mexico');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '813 Atwood Park', 'Lyon', '69281 CEDEX 01', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5704 Sunfield Alley', 'La Celia', '662037', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '954 Grover Road', 'Wendo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '6214 Mosinee Court', 'San José', '40602', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '55548 Golf Center', 'Remedios', '052828', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '8 Melvin Avenue', 'Longyearbyen', '9171', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '9 Crescent Oaks Center', 'Kerek', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '909 Sutherland Street', 'Akouda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '63746 Johnson Center', 'Cential', '3070-085', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8014 Fieldstone Center', 'Pitumarca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '00 Doe Crossing Junction', 'Solnechnoye', '197738', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '84 Elmside Plaza', 'Sudzha', '307831', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '03174 Tennyson Terrace', 'Gävle', '806 31', 'Gävleborg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '28833 Red Cloud Road', 'Pasirjengkol', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '49585 Weeping Birch Lane', 'Jojoima', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '44540 Nobel Plaza', 'Maqia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '36 Kim Center', 'Changfeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '13 Debs Plaza', 'Fujiayan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '8768 Nancy Pass', 'Tairua', '3544', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '74109 Westport Lane', 'Vallehermoso', '2439', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '52843 Prairie Rose Junction', 'Galamares', '2710-210', 'Lisboa');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2 Lillian Center', 'Uddiawan', '3605', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '7564 Logan Lane', 'Rybinsk', '694440', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '3 Hoffman Circle', 'Los Angeles', '90189', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '423 Buell Avenue', 'Paris 15', '75737 CEDEX 15', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '51826 Lighthouse Bay Pass', 'Yanji', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '23779 Victoria Crossing', 'Śniadowo', '18-411', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '898 Bartillon Point', 'Fengjia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '489 Onsgard Circle', 'Valongo', '5400-339', 'Vila Real');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '75585 Mesta Circle', 'Margasana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '59 Clarendon Alley', 'Saraktash', '462159', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '5 Kennedy Junction', 'Stockholm', '121 29', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '6928 Daystar Point', 'Cradock', '5884', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '50 Knutson Lane', 'Jiubao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '3 Bultman Parkway', 'Quintã', '3720-546', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '15 Burning Wood Lane', 'Salaya', '13230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '9345 Lukken Parkway', 'Varberg', '432 51', 'Halland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '0558 Mcbride Parkway', 'Orsay', '91851 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '70 Kropf Way', 'Tanghu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '4849 Myrtle Drive', 'Jinshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '73169 Erie Avenue', 'Majie', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '818 Hansons Point', 'Aleksandrovac', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9433 Welch Plaza', 'Darma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '785 Nobel Parkway', 'Leicheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '406 Menomonie Drive', 'Huata', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '477 Superior Plaza', 'Yeniköy', '61300', 'Trabzon');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '14097 Nancy Crossing', 'Goodlands', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9 Lake View Park', 'Marcq-en-Barœul', '59704 CEDEX', 'Nord-Pas-de-Calais');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0 Towne Lane', 'Rakitnoye', '182105', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '485 Hagan Junction', 'Comandante Fontana', '3620', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '79585 Milwaukee Lane', 'Karanganyar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1 Evergreen Trail', 'Častolovice', '517 50', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '683 Pond Point', 'Skolkovo', '249028', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7 Memorial Crossing', 'Pombal', '58840-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '00 Declaration Terrace', 'Kertosari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '04184 Riverside Center', 'Tarusa', '249111', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '37701 Jana Street', 'Dobryanka', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '81 Barnett Plaza', 'Lianyun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '69 Mallory Park', 'Bāniyās', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '202 Muir Park', 'Takai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '586 Melby Alley', 'Tešanj', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '8 Farragut Court', 'Mopti', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9 Sycamore Junction', 'Slovenski Javornik', '4274', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1515 Village Green Lane', 'Dahua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1738 Fremont Road', 'Halmstad', '300 10', 'Halland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '187 Prentice Avenue', 'Tongyang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '891 Ruskin Circle', 'Mengeš', '1234', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '435 Waubesa Hill', 'Bayangol', '671945', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Oakridge Crossing', 'Jiaocha', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3 Havey Drive', 'Si Narong', '34000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '51851 Old Gate Place', 'Saint Paul', '55188', 'Minnesota');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '17 Blackbird Street', 'Housuo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '642 Scofield Terrace', 'Liješnica', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '737 Marquette Alley', 'Velké Losiny', '788 15', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '204 Schurz Place', 'Casais de Revelhos', '2200-463', 'Santarém');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3970 Killdeer Trail', 'Tsimlyansk', '347320', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '284 Emmet Hill', 'Korsun’-Shevchenkivs’kyy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7647 Loomis Hill', 'Kalmar', '391 21', 'Kalmar');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1075 Sundown Crossing', 'Borovany', '348 02', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '041 Summer Ridge Court', 'Bontang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '93 Burrows Circle', 'Budapest', '1136', 'Budapest');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '33 Service Lane', 'Sa''dah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '864 Glendale Circle', 'Barr', '67144 CEDEX', 'Alsace');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7993 Fairview Pass', 'Banjarjo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '048 Homewood Park', 'Qamdo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2 Ilene Crossing', 'Yongshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1469 Almo Lane', 'Kobarid', '5222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3 Birchwood Drive', 'Cluny', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0 Briar Crest Drive', 'Sobang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '08388 Pepper Wood Circle', 'Yongxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '9 Dahle Junction', 'Cinyumput', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '0849 Hansons Plaza', 'Las Breñas', '3722', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '1 Saint Paul Junction', 'Takayama', '999-0141', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '84357 Superior Alley', 'Verbilki', '141930', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '43901 Sloan Circle', 'Maythalūn', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '9473 Evergreen Center', 'Phoenix', '85067', 'Arizona');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '844 Lukken Circle', 'Głogówek', '48-250', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '467 Columbus Center', 'Alajuelita', '11001', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '761 Moulton Terrace', 'Erdenet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '452 Little Fleur Court', 'Loo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '99930 Brickson Park Crossing', 'Namora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '4 Forest Dale Terrace', 'Al Karmil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '2 Waubesa Pass', 'Zvole', '789 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '671 Bluejay Trail', 'Sydney', '1130', 'New South Wales');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '53683 Cascade Court', 'Mataquescuintla', '06005', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '84437 Paget Alley', 'Dammarie-les-Lys', '77193 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '84 Delaware Park', 'Tōkamachi', '949-8612', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '869 Sheridan Avenue', 'Niort', '79004 CEDEX', 'Poitou-Charentes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '836 Anniversary Lane', 'Dijon', '21040 CEDEX', 'Bourgogne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '824 Express Parkway', 'Vyborg', '188919', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '949 Morningstar Trail', 'Blachownia', '42-293', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '1964 Northridge Alley', 'Courtaboeuf', '91965 CEDEX', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '2527 Delaware Court', 'Fuchang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '23 Elmside Alley', 'Tygda', '676150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6214 Longview Parkway', 'Hoktember', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '470 Merchant Park', 'Tála', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '83 Buhler Street', 'Skidal’', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '944 Walton Road', 'Yuqunweng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '36 Green Street', 'Ampara', '32000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '3020 Hovde Avenue', 'Dzhayrakh', '309273', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '2686 Hansons Junction', 'Mizunami', '957-0048', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '67867 Emmet Park', 'Pivovarikha', '664511', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '3 Weeping Birch Parkway', 'Valle de Guanape', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '230 Center Parkway', 'Nantes', '44966 CEDEX 9', 'Pays de la Loire');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '41064 Hoffman Lane', 'Ishkhoy-Yurt', '368164', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '159 Iowa Trail', 'Trnovska Vas', '2254', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '33 Bartillon Alley', 'Malbork', '82-210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '94 Paget Parkway', 'El Matama', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '4 Moulton Plaza', 'Laimuda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '26000 Talmadge Terrace', 'Balahovit', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '2388 Dahle Pass', 'Kanggye-si', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '129 Fairview Road', 'Miringa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '02 Chinook Street', 'Marseille', '13907 CEDEX 20', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7580 Duke Crossing', 'Pontivy', '56309 CEDEX', 'Bretagne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '81807 Buena Vista Place', 'Uticyacu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '216 Thompson Terrace', 'Saint-Priest', '69794 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '62350 Ronald Regan Avenue', 'Dodu Dua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '13 Scott Park', 'Vagos', '3840-386', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '61 Del Mar Street', 'Yong’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2987 Coleman Center', 'Mehtar Lām', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '08100 Trailsway Parkway', 'Hongmiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '35 Havey Road', 'Antas', '4760-018', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '59815 Green Crossing', 'San Juan', '6227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '91039 Tennyson Crossing', 'Le Bourget-du-Lac', '73379 CEDEX', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '96400 Vidon Center', 'Minuyan', '1409', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '36580 Meadow Ridge Way', 'Brusyliv', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0213 Pearson Park', 'Koz’modem’yansk', '425359', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '0928 Anniversary Place', 'Héroumbili', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '38 Hollow Ridge Park', 'Mosopa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '27 Butterfield Center', 'Morteros', '2421', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '62 Helena Court', 'Mengla', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '9 Wayridge Terrace', 'Bethlehem', '18018', 'Pennsylvania');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '6 Duke Terrace', 'Atocha', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '74917 Burrows Street', 'Condoroma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '75313 Clyde Gallagher Pass', 'Неготино', '1236', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '30840 Portage Hill', 'Issoudun', '36104 CEDEX', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '9887 Bayside Park', 'Krajan Tegalombo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '264 Jana Alley', 'Trélissac', '24758 CEDEX', 'Aquitaine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '98059 Northland Street', 'Coaticook', 'J1A', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '64 Union Crossing', 'Datuan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '4 4th Drive', 'Chenfang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '831 Division Road', 'Olavarría', '7400', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5 Cascade Parkway', 'Klampis', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '97331 Jana Trail', 'Perstorp', '284 32', 'Skåne');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9444 Center Pass', 'Uglovoye', '694222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '089 Northfield Terrace', 'Kirovsk', '187349', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '245 Dryden Street', 'Nyagan', '628189', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '48 Bonner Way', 'Guanmiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '25906 Hayes Drive', 'Yeysk', '404172', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5 Shelley Parkway', 'Plereyan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7514 Oxford Crossing', 'Cikendi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9391 Union Trail', 'Wakefield', '7052', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '72689 Mifflin Park', 'Petukhovo', '641642', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8830 Leroy Drive', 'Wujiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '36603 Roxbury Drive', 'Mutengene', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '36 Russell Circle', 'Meiyuan Xincun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '9 Susan Junction', 'Baroy', '9210', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '0906 Hayes Circle', 'Mambago', '8118', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5668 Sullivan Circle', 'Popielów', '46-090', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '00 Huxley Parkway', 'Valerianovsk', '624365', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '638 Crescent Oaks Hill', 'Sanski Most', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '2 Thierer Pass', 'Dongping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0374 Mendota Hill', 'Ping’an', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8416 Red Cloud Way', 'Huangjiakou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2192 Kensington Center', 'Anthoúsa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5601 Northridge Avenue', 'Turan', '668510', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1723 Weeping Birch Point', 'Nasavrky', '565 01', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '65805 Victoria Way', 'Talaibon', '4230', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '07663 Brentwood Hill', 'Lanjaghbyur', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '05 Spaight Park', 'Dongbian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7731 Grayhawk Drive', 'Orléans', '45933 CEDEX 9', 'Centre');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '2 Susan Center', 'Luts’k', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '32580 Di Loreto Drive', 'Pieniężno', '14-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9 Brickson Park Center', 'Mertani', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '5280 Fulton Alley', 'Gornorechenskiy', '692425', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '14625 Holmberg Road', 'Khantaghy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '349 Pleasure Way', 'Casilda', '2170', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '374 Melvin Plaza', 'Ariquemes', '78930-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '972 Ridgeview Point', 'Renfengzhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '57599 Gateway Place', 'Qitao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '9046 Kings Terrace', 'Zaki Biam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '517 Lighthouse Bay Hill', 'Magitang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '3547 Nobel Alley', 'Huaquirca', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '8357 Northfield Parkway', 'Kansas City', '64125', 'Missouri');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '4 Fairfield Plaza', 'Volta Redonda', '27200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '54 Corben Lane', 'Łopuszno', '26-070', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '09461 Beilfuss Parkway', 'Zalesnoye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '9 Calypso Pass', 'Legok', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '517 Hazelcrest Park', 'Xiongzhang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '347 Dakota Alley', 'Malummaduri', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3779 Mariners Cove Street', 'Horní Čermná', '561 56', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2214 American Ash Parkway', 'Setúbal', '2900-005', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6002 Westport Junction', 'Tiassalé', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '0656 Straubel Point', 'Tsagaannuur', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '50 Meadow Valley Terrace', 'Buurhakaba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '6 Spohn Place', 'Basa', '2316', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '537 Anthes Circle', 'Soly', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '750 Atwood Street', 'Podu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9452 Sauthoff Center', 'Skópelos', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '02094 Merchant Trail', 'Baligród', '38-606', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '37 Heath Avenue', 'Kalāt-e Nāderī', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '6439 Lakeland Plaza', 'Xike', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '2 Ryan Circle', 'Polzela', '3313', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '6 Dexter Circle', 'Danghara', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '75687 Rusk Junction', 'Sanchang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '61955 Blue Bill Park Pass', 'Neob', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1820 Marquette Place', 'Pasar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '915 Anthes Street', 'Kanlagay', '8712', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '724 Stang Place', 'Los Angeles', '90005', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '37 Linden Crossing', 'Dakingari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1 Melody Park', 'Repki', '08-307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '2 Ramsey Alley', 'Tanashichō', '203-0044', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '19482 Heath Street', 'La Sarrosa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Manley Point', 'Huozhuangzi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '27544 Columbus Lane', 'Capalonga', '4607', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '69 Monica Center', 'Xuebu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '34087 Bartelt Court', 'Krzeszów', '58-405', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0726 Dakota Hill', 'Xujiafang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '86 Corry Alley', 'Sivaki', '403467', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '166 American Ash Park', 'Pitai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '77080 Petterle Crossing', 'Glugur Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2 Grasskamp Point', 'Bidyā', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '76332 Kinsman Park', 'Córdoba', '632027', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '5 Del Sol Center', 'Vaitape', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '405 Tennyson Lane', 'Nihaona', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '84639 Talmadge Point', 'Oslo', '0371', 'Oslo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '37249 Melby Park', 'Americana', '13465-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '45967 John Wall Point', 'Mbinga', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '0 Anniversary Road', 'Três Passos', '98600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '6 Toban Lane', 'Longquan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '00 4th Trail', 'Talok', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '542 Dapin Point', 'Konkwesso', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1190 Scofield Lane', 'Moñitos', '231008', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '1 Dayton Plaza', 'Luzhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '28826 Mandrake Way', 'Yuanqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '2 Shoshone Junction', 'Volta Redonda', '27200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '2 Rutledge Junction', 'Dingzhai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '85379 Thierer Center', 'Invermere', 'J1K', 'British Columbia');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '8543 Eagan Center', 'Nowe Warpno', '72-022', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '580 Ronald Regan Road', 'Heilongkou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '070 Warner Circle', 'Qingxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '40 Pankratz Terrace', 'Guayabo Dulce', '11904', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2 Maywood Junction', 'São Marcos da Serra', '8375-254', 'Faro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '14 Oneill Lane', 'Esplanada', '48370-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7 Rieder Circle', 'Šimanovci', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '8 Shoshone Point', 'Sumbergayam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '35 Hanover Drive', 'Trakan Phut Phon', '90120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '6904 Carberry Lane', 'Lijia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '009 Graceland Trail', 'Koba', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6253 Hooker Circle', 'Stara Kiszewa', '83-430', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '805 Riverside Circle', 'Kasamatsuchō', '504-0968', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '5280 Westerfield Road', 'Tres Isletas', '4000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '0905 Melody Junction', 'Senglea', 'ZTN', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '274 Huxley Terrace', 'Berlin', '10587', 'Berlin');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '221 Brown Pass', 'Mamasa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '69 Twin Pines Place', 'Riangbaring', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '13 Golden Leaf Pass', 'Pasargunung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '0037 Forest Run Crossing', 'Baturinggit Kaja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '12 Crowley Center', 'Driefontein', '4142', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Southridge Alley', 'Zicheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '477 Ruskin Terrace', 'Xinhua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '8274 Barnett Crossing', 'Bouabout', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '199 Kinsman Way', 'Dayr Abū Ḑa‘īf', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '44274 Old Gate Avenue', 'Magepanda', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '0726 Tennessee Road', 'Diré', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '6471 Hoard Crossing', 'Drammen', '3037', 'Buskerud');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Susan Lane', 'Kańczuga', '37-220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '66189 Coleman Center', 'Miami Beach', '33141', 'Florida');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '9 Fieldstone Road', 'Krujë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '47 Ruskin Street', 'Lugar Novo', '4820-013', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '0230 Anzinger Circle', 'Carmen', '9408', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '037 Mitchell Trail', 'Zelenodolsk', '422549', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '319 Myrtle Crossing', 'Ochla', '65-980', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '874 Jay Circle', 'Smolenskaya', '353254', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '61825 Ryan Crossing', 'Jintang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '84 Gateway Crossing', 'Jejkowice', '44-290', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '024 Havey Crossing', 'Riung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '09 Burning Wood Place', 'Outjo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '361 Johnson Crossing', 'Aimorés', '35200-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '5 Larry Street', 'Mamonit', '2304', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '577 Debs Drive', 'Kisarazu', '299-0271', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '5497 Killdeer Pass', 'Beaconsfield', 'H9W', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0897 Maywood Junction', 'Turus', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7486 Dennis Plaza', 'Zhelin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7 Monument Place', 'Muñoz East', '5407', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '10 Bultman Place', 'Nyköping', '611 35', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '77815 Dryden Street', 'Gorshechnoye', '307425', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '5 Muir Pass', 'Birni N Konni', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '638 Towne Crossing', 'Hamburg', '22559', 'Hamburg');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '17 Jackson Hill', 'Huabu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '1 Moland Parkway', 'Cigedang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '076 Rieder Pass', 'Apodi', '59700-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '087 Maryland Terrace', 'Bologna', '40128', 'Emilia-Romagna');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '9538 Schlimgen Terrace', 'Vardane', '678030', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '33 2nd Crossing', 'Radzanów', '26-807', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '54959 Lien Court', 'Tomigusuku', '901-0241', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '6045 Armistice Trail', 'Guacarí', '763508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '83332 Merchant Way', 'Hengshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '779 Dahle Court', 'Az Zubaydāt', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '6860 Morrow Circle', 'Puma', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '488 Monterey Point', 'Yiliu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '45 Homewood Street', 'Jiedu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '657 Commercial Point', 'Loreto', '8507', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5110 Eggendart Drive', 'La Peña', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '2 Shoshone Crossing', 'Macedo de Cavaleiros', '5340-197', 'Bragança');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '21572 Thierer Trail', 'Матејче', '1315', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '9 Canary Parkway', 'Patenongan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '98 Jenifer Plaza', 'Santa Luzia', '58600-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '90022 Lakewood Gardens Hill', 'Breia', '4830-433', 'Braga');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '7 Maple Wood Lane', 'Cipanggung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '91 Schmedeman Point', 'Shixi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '967 Bunting Terrace', 'Kněžpole', '793 51', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '2 Marcy Park', 'Paris 17', '75817 CEDEX 17', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '36 Schlimgen Circle', 'Thawat Buri', '40160', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '35 Nova Lane', 'Leones', '2594', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '193 Burning Wood Terrace', 'Jagabaya Dua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1899 Lien Junction', 'Saño', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '12 Montana Way', 'Quinta da Courela', '2840-547', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '98063 Mariners Cove Junction', 'Maskinongé', 'T7A', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Lerdahl Way', 'Guanxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '968 Eggendart Park', 'Roissy Charles-de-Gaulle', '95761 CEDEX 1', 'Île-de-France');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '45754 Caliangt Place', 'Quilo-quilo', '4224', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '267 Northridge Alley', 'Bocana de Paiwas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '06 Spenser Place', 'Yantak', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '47607 Clarendon Park', 'Xiaojia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '7591 Holmberg Drive', 'Ol’ginskaya', '663914', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '32 Beilfuss Lane', 'Calvão', '3840-045', 'Aveiro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '884 Sauthoff Junction', 'Gjilan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Welch Avenue', 'Youhua', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '53424 Browning Circle', 'Tagoloan', '9222', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Victoria Circle', 'Kasakh', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '2507 Sauthoff Way', 'Cinyawar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6014 Bowman Trail', 'Passal', '4960-130', 'Viana do Castelo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '6 Superior Pass', 'Tuamese', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '66 Delladonna Alley', 'Lidong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '326 Fieldstone Park', 'Corinto', '191569', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '759 Buell Crossing', 'Xunqiao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '019 Sundown Court', 'Uppsala', '751 41', 'Uppsala');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '28 Express Court', 'Ajaccio', '20311 CEDEX 1', 'Corse');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '70253 Rusk Crossing', 'Taen Tengah', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '864 Farwell Court', 'Tytuvėnėliai', '86061', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '2 Orin Hill', 'Ndofane', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1254 Kedzie Terrace', 'Marília', '17500-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '9 Johnson Center', 'Río Hondo', '19003', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '19054 Mcguire Trail', 'Dongxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1 Briar Crest Lane', 'Oakland', '94611', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '483 Old Shore Alley', 'Jitan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '20 Fremont Terrace', 'Kuala Terengganu', '21009', 'Terengganu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '72765 Stephen Parkway', 'Kole', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '336 Starling Drive', 'Nova Venécia', '29830-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '3 Melody Center', 'Registro', '11900-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '78 Hoard Trail', 'Kaduseeng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '6 Iowa Terrace', 'Rayong', '21000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '76 Monica Lane', 'Bordeaux', '33911 CEDEX 9', 'Aquitaine');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '19004 Hanson Terrace', 'Willowdale', 'M3H', 'Ontario');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6 Leroy Circle', 'Yaozhou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7 Heath Alley', 'Los Angeles', '90045', 'California');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '42816 Dovetail Hill', 'Åmål', '662 24', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '7579 Swallow Pass', 'Feitoria', '4650-291', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8291 Dapin Center', 'Luoxi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '29794 Aberg Trail', 'Presidencia Roque Sáenz Peña', '5444', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '1 Monument Avenue', 'Guihuaquan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8 Eggendart Court', 'Freetown', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '25361 Tomscot Terrace', 'Meliau', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '34625 Quincy Crossing', 'Starokorsunskaya', '385274', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '316 Forest Way', 'Xankandi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '044 Harbort Court', 'Hoi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '17464 Old Gate Plaza', 'Duas Igrejas', '4580-373', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '4 Paget Park', 'Wādī as Sīr', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '60 Village Green Junction', 'Gaozhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '20 Northwestern Trail', 'Szlachta', '83-243', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7986 Reindahl Hill', 'Labège', '31678 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '8 Welch Alley', 'Koltubanovskiy', '446521', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '7969 Hazelcrest Park', 'Munjul', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '0 Eastlawn Pass', 'Calaba', '3109', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8 Morningstar Park', 'Oehaunu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '54 Morningstar Drive', 'Kachia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '56263 Meadow Valley Park', 'Yangjia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '5 Pawling Avenue', 'Ongjin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '04 Anthes Plaza', 'Ilebo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '78159 Shopko Drive', 'Tembilahan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '812 Scoville Hill', 'Caen', '14085 CEDEX 9', 'Basse-Normandie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '918 Mandrake Plaza', 'Quivilla', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '247 Judy Circle', 'Dadap', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1265 Vermont Hill', 'Pittsburgh', '15266', 'Pennsylvania');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '58 Shopko Hill', 'Steinsel', 'L-7346', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '1 Burning Wood Street', 'Energeticheskiy', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '6653 David Lane', 'Bretaña', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '4785 Nevada Lane', 'Wichian Buri', '67130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '8850 Union Road', 'Tanjungagung', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '6685 Hauk Lane', 'Aíyira', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '57769 Harper Terrace', 'Banjar Asahduren', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2 Division Court', 'Bromma', '167 74', 'Stockholm');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '97282 Miller Point', 'Forninho', '2965-223', 'Setúbal');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '20053 Sundown Road', 'Horodne', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '804 Chinook Avenue', 'Sillamäe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '18 Myrtle Road', 'Sussex', 'E4E', 'New Brunswick');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5 Loomis Avenue', 'Elassóna', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '093 Welch Trail', 'Xinpu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '7 Drewry Place', 'Manaulanan', '2622', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '92293 Bellgrove Court', 'Pinagsibaan', '0801', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '74494 Scott Hill', 'Manfalūţ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '695 Homewood Road', 'Okaya', '520-2541', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '8 Sage Circle', 'Risālpur', '24081', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Bultman Center', 'Labrang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '34 Thierer Trail', 'Jinbi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '9 Lindbergh Terrace', 'Laon', '02004 CEDEX', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '623 Mitchell Alley', 'Mojoroto', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6 Waywood Road', 'Shuyuan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '63855 Butternut Lane', 'Ayia Napa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '9 Oxford Junction', 'Birmingham', '35236', 'Alabama');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '0 Crescent Oaks Parkway', 'Houston', '77240', 'Texas');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '87687 Claremont Road', 'Phichai', '53120', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '002 Rusk Avenue', 'Bhalil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '03742 Maywood Circle', 'Mrongi Daja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '0384 Packers Plaza', 'Kurungannyawa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '64 Eliot Hill', 'Juncalito Abajo', '10801', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6955 Reindahl Alley', 'Ribeirão Preto', '14000-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9 North Street', 'Yoshida-kasugachō', '959-1287', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '004 West Point', 'Florida', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '017 Rusk Pass', 'Yên Mỹ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '03714 Hooker Point', 'São Sebastião do Caí', '95760-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '819 Eliot Court', 'Tripoli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '4064 Buena Vista Hill', 'Jarash', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '759 Independence Plaza', 'Elías', '417018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '6393 Sommers Court', 'Alençon', '61004 CEDEX', 'Basse-Normandie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '37 Buhler Circle', 'Amiens', '80020 CEDEX 9', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '0 Jana Alley', 'Lavaltrie', 'J5T', 'Québec');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '2591 Saint Paul Terrace', 'Xincheng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '55 Blue Bill Park Center', 'Tawangrejo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '770 Lake View Plaza', 'Tigarunggu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '48 Fair Oaks Point', 'Jiangnan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '870 Hintze Junction', 'Zishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '6753 Lighthouse Bay Alley', 'Jampang Kulon', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '9 Eliot Court', 'Färjestaden', '386 94', 'Kalmar');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '685 Chive Road', 'Përmet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '85124 Service Way', 'Aquia', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2080 Talisman Avenue', 'Martakert', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '24 Clemons Avenue', 'Shuibian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '5130 Springview Avenue', 'Lukovo', '6337', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '17 High Crossing Hill', 'Bouillon', '6834', 'Wallonie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '8 Crest Line Drive', 'Delft', '2624', 'Provincie Zuid-Holland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '0480 Thompson Park', 'Temryuk', '353508', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '85568 Novick Point', 'Wassu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '7593 Cascade Park', 'Winduraja', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '1 Elgar Center', 'Catriel', '8307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '3557 Oxford Street', 'Qiankou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '029 Clarendon Parkway', 'Milán', '185038', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '1009 Manufacturers Terrace', 'Yangxu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '8 Steensland Court', 'Qusar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '632 Beilfuss Court', 'Napalitan', '9006', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '32 Fulton Trail', 'Náousa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '28031 Spenser Way', 'Buldon', '9615', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '02 Sherman Park', 'Melissochóri', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '1 Anhalt Street', 'Lela', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '19 Drewry Pass', 'Cerro Blanco', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '8 Mockingbird Terrace', 'Bebandem', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '861 Southridge Junction', 'Guanchi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '93024 Monica Terrace', 'Bogorejo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '983 Logan Crossing', 'Cedynia', '74-520', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '49921 Manitowish Drive', 'Nanxing', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '5811 Mcguire Pass', 'Nakhon Phanom', '48000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '0 Maple Plaza', 'Carahue', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '4 Loeprich Junction', 'Oslo', '0309', 'Oslo');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '750 Raven Street', 'Kuštilj', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '355 1st Street', 'Springfield', '62711', 'Illinois');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '59 Porter Alley', 'Kampot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '750 Kedzie Circle', 'Tutup', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '51460 Tomscot Junction', 'Hājīganj', '3832', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9470 Pierstorff Court', 'Mueang Suang', '45220', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '45 Kedzie Park', 'Xinglong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '98 Aberg Place', 'Vacenovice', '675 51', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '81436 Milwaukee Drive', 'København', '1131', 'Region Hovedstaden');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '30341 South Parkway', 'Houmt Souk', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '80 Mccormick Alley', 'Xinshancun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '54930 Red Cloud Trail', 'Xinbu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '0476 Dwight Pass', 'Lapi', '5307', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '1 Miller Trail', 'Ribeira', '4690-480', 'Viseu');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '68658 Sage Terrace', 'Tajimi', '507-0901', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '413 Memorial Circle', 'Indramayu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '7 Transport Point', 'Katrineholm', '641 91', 'Södermanland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '7680 Schiller Plaza', 'Shupenzë', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '43 New Castle Place', 'Can-Avid', '6806', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '12511 2nd Crossing', 'Karangora', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9 Sauthoff Terrace', 'Rāiwind', '55150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '3 Longview Plaza', 'Macroom', 'P12', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '05 Oneill Drive', 'San Calixto', '547018', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '284 Red Cloud Court', 'Cilegi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '3 Lerdahl Crossing', 'Cibatuireng', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '26 Glacier Hill Alley', 'Felgueiras', '4610-104', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '59 Merrick Way', 'Cuihuangkou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '3168 Village Green Hill', 'Kairouan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '47616 Scoville Road', 'Changping', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '92396 Buell Place', 'Providence', '02912', 'Rhode Island');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '211 Erie Terrace', 'Elele', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '9 Russell Lane', 'Nunsena', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '63797 Maryland Road', 'Santa Lucia', '2712', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '3 Washington Avenue', 'Węgierska Górka', '34-350', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '43754 John Wall Avenue', 'Miringa', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '18 Corscot Circle', 'Magallon Cadre', '6132', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '8106 Dovetail Court', 'Bapska', '32235', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '3337 Glendale Drive', 'Soutinho', '4650-530', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '93 Comanche Park', 'Altunemil', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '5692 Golf Course Point', 'Ursk', '242467', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '80611 Saint Paul Plaza', 'Suru', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '28188 Hoepker Alley', 'Montes Claros', '39400-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '05 Melody Point', 'Serednye', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '639 Mandrake Point', 'Annecy', '74999 CEDEX 9', 'Rhône-Alpes');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '0930 Judy Circle', 'Banjar Taro Kelod', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '2084 Mayer Parkway', 'Pigí', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '60310 Sutherland Lane', 'Sanshan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '54118 Sundown Terrace', 'Monte da Boavista', '7100-150', 'Évora');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '028 Forest Plaza', 'Taihu', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '5 Knutson Trail', 'Västra Frölunda', '421 10', 'Västra Götaland');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '12079 Holmberg Circle', 'Pamiers', '09104 CEDEX', 'Midi-Pyrénées');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '04459 Shoshone Terrace', 'Karlskoga', '691 41', 'Örebro');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '6769 Dexter Drive', 'Sartana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '95118 Westport Place', 'Laban', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '40 Beilfuss Pass', 'Changchun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '3 Village Place', 'Ariana', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '879 Bunker Hill Hill', 'Zhuozishan', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '58 Dottie Alley', 'Tân Kỳ', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '12 Hollow Ridge Trail', 'Camiling', '2306', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '17081 Grasskamp Drive', 'Qulai', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '752 Dennis Way', 'Porangaba', '18260-000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '4670 Arkansas Way', 'Emin', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '52 Pepper Wood Avenue', 'Salon-de-Provence', '13654 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '0 Pennsylvania Terrace', 'Xiaomei', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '2871 Ridgeway Junction', 'Shitong', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '134 Bunker Hill Circle', 'Kauniainen', '02701', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '5 High Crossing Park', 'Benito Juarez', '62214', 'Morelos');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '83 Graedel Plaza', 'Ipala', '20011', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '94 Atwood Point', 'Skuhrov nad Bělou', '517 03', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '22282 Graceland Street', 'Tatebal', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '9 Buena Vista Point', 'Manturovo', '307000', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '498 Reinke Lane', 'Zouila', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '4 Northwestern Way', 'Kobilje', '9227', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '66979 Sunnyside Center', 'Tunggar', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '60479 Glacier Hill Junction', 'Carayaó', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '2609 Michigan Crossing', 'Seydi', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '6237 Bultman Point', 'Amberd', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '43 Clemons Alley', 'Bhamo', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '1603 Dayton Avenue', 'Bonsari', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '28 Arapahoe Junction', 'Aubagne', '13681 CEDEX', 'Provence-Alpes-Côte d''Azur');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '52 Artisan Road', 'Tekeli', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '40041 Oneill Parkway', 'Si Somdet', '95130', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '1 Ridgeway Circle', 'Neochórion', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '21330 Chive Alley', 'Malibago', '6213', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '03 Jenna Way', 'Lichengdao', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '862 Monument Parkway', 'Kumanis', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '00736 Cottonwood Junction', 'Independence', '64054', 'Missouri');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '12584 Hintze Way', 'Puerto Ayacucho', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '82076 Lakewood Gardens Trail', 'Denton', 'M34', 'England');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '87 Spohn Terrace', 'Buyun', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '23 Lakewood Gardens Way', 'Hohhot', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '26278 Golf View Hill', 'Chantilly', '60637 CEDEX', 'Picardie');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (6, '7465 Schmedeman Terrace', 'New York City', '10009', 'New York');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '56490 Larry Park', 'Cimaragas', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '6 Arapahoe Point', 'Banjar Dauhpura', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '3 Katie Drive', 'Purranque', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (2, '760 Magdeline Point', 'Ryazan’', '390507', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (10, '73 Twin Pines Pass', 'Ḩawsh ‘Īsá', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '71 Pond Plaza', 'Kabarnet', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '2999 Hoffman Crossing', 'Yungay', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '585 Rieder Park', 'Pereiros', '3040-723', 'Coimbra');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '46638 Knutson Way', 'Paradela', '4785-231', 'Porto');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (3, '8780 Spenser Avenue', 'Oświęcim', '32-610', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '0261 Westend Place', 'Thuận Nam', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '9 Morningstar Way', 'Raoyang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (4, '845 Independence Plaza', 'Ridder', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '26456 Garrison Circle', 'Xinzhuang', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '46814 Thierer Crossing', 'Aguas Corrientes', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '08 Pawling Terrace', 'Shigony', '446729', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (5, '438 Grim Way', 'Jinhe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '70636 Longview Center', 'Shiyaogou', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (7, '29768 Eggendart Lane', 'Donghe', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '74837 Ridgeway Circle', 'Daqian', null, null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (9, '9 Ronald Regan Center', 'Essen', '45356', 'Nordrhein-Westfalen');
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (1, '5 Schlimgen Court', 'Komsomol’sk', '155150', null);
INSERT INTO addresses (country_id, address_line_1, address_line_2, zipcode, city)
VALUES (8, '2 Farmco Avenue', 'Ichihara', '920-2327', null);

INSERT INTO companies (name, nip, establishment_date, krs, parent_company_id, hq_address_id, tax_address_id)
VALUES ('TME', '9871234371231', '20-FEB-19', '4911232761', null, 537, 393);
INSERT INTO companies (name, nip, establishment_date, krs, parent_company_id, hq_address_id, tax_address_id)
VALUES ('Kazu', '205vxh3421236', '21-JAN-18', '4301236521', 1, 962, 953);

INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #1', 19241.94, 9, 'F', 1, 1, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #2', 93212.31, 5, 'T', 1, 2, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #3', 45470.25, 5, 'F', 1, 3, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #4', 15385.35, 5, 'F', 2, 4, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #5', 94854.54, 9, 'F', 1, 5, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #6', 68836.09, 5, 'F', 2, 6, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #7', 78462.36, 7, 'T', 2, 7, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #8', 31545.55, 3, 'F', 1, 8, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #9', 10170.43, 7, 'F', 1, 9, null);
INSERT INTO warehouses (name, capacity, number_of_loading_bays, is_retail, company_id, address_id, manager_id)
VALUES ('Warehouse #10', 91237.97, 10, 'T', 2, 10, null);

insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (1, 'user1', '{noop}password1',
        'dsparkwill0@booking.com', 'WAREHOUSE_EMPLOYEE', 'Donnell', 'Sparkwill', '56280983160', '2020-04-09 14:00:14',
        '521-700-4568',
        2, 2, 393);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (2, 'user2', '{noop}password2',
        'npoole1@friendfeed.com', 'WAREHOUSE_MANAGER', 'North', 'Poole', '02152406951', '2020-10-23 00:50:34',
        '118-264-5825', 1,
        7, 891);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (3, 'nmeineking2', 'Ns27DWO8cSZP1Cn1qTHFccpNqipnzB1AVXzpQrE3KGzXFURoEh6TDPUOtpozIpUGBC0rHwgHcOqj',
        'nmeineking2@nymag.com', 'iaculis congue', 'Naoma', 'Meineking', '30084131683', '2020-12-13 01:51:57',
        '866-633-6121', 2, 1, 321);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (4, 'bpaumier3', '0sn3zfWEkZVVnke9g1naFIf3FJmx42rIsp5gXSotvKHrJG4RgZzxxW0cFnHq03f2f1tIyWfh0BQw',
        'bpaumier3@chicagotribune.com', 'orci luctus', 'Bowie', 'Paumier', '26236154024', '2020-01-30 11:09:41',
        '603-209-5643', 1, 4, 714);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (5, 'ubogace4', 'Tbb1EeWlBzqZJdF2K9Tt2fc568C9aYdjrj2lBL94R5GmxxpMEgS8Q2lMfoyFqj5POGUnanM3cMCC',
        'ubogace4@sphinn.com', 'ridiculus mus', 'Umeko', 'Bogace', '80507796576', '2020-04-27 15:55:41', '481-906-0935',
        1, 7, 833);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (6, 'hlowbridge5', '6Z42tueaNMuxFBHuoKdFQXldchVCSm6LX3LJ49bHCdh0oPp11jfhreoPNjbSDUtichoNBJvTnZlb',
        'hlowbridge5@city.gov', 'ac nibh', 'Haslett', 'Lowbridge', '87099767110', '2020-02-20 08:35:49',
        '299-858-7711', 2, 1, 119);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (7, 'ekloster6', 'MgYFty1F0nvxSWcYCO6carYY0WFSuuNObP9KPgONO9KgTqVdQUOUfOIg8ON5IodpOdyh9InjlTu7',
        'ekloster6@marketwatch.com', 'pharetra', 'Eduino', 'Kloster', '87761359475', '2020-08-30 04:37:39',
        '676-840-6828', 2, 2, 729);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (8, 'cguillot7', 'TDGWOWxx7lmL9qk2hHTxixaUS1Nw5nUaahisNs36bal44NJOYBVV6Fd3SmJLiemLp560vrhzvRhU',
        'cguillot7@noaa.gov', 'sapien a', 'Carly', 'Guillot', '57799952527', '2020-04-06 05:05:35', '868-889-5205', 1,
        5, 757);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (9, 'lvoyce8', 'kUqDy0ARHchY9M6pdkhF8q9E3kE4rtG8aFRt9MmuZRhLboyxanoUGlfX98tTz4nU3itv5K7b7rD9', 'lvoyce8@cdc.gov',
        'fusce lacus', 'Lemar', 'Voyce', '94539377878', '2020-10-03 00:17:49', '840-725-8193', 2, 7, 793);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (10, 'kpeck9', 'ODiOHf2rRvJBYdWFAcpWwpPuIIyDFKu0fJJihqZhJFyIQnchx6rVbH7U87so9EokjsP4UGpAdUFk',
        'kpeck9@patch.com', 'dictumst maecenas', 'Kelcie', 'Peck', '10199434327', '2020-04-24 19:48:48', '125-706-5916',
        1, 4, 438);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (11, 'tmordeya', 'u7z2VtxpRNeKYvq7lszMvkTx8yJWrf8wqip6saNpMqe55Y0zM9kIq74aKxszDOOsVDQP9VLSCCJm',
        'tmordeya@nature.com', 'ut nulla', 'Titos', 'Mordey', '74405982722', '2020-06-07 06:29:53', '686-474-1982', 1,
        7, 737);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (12, 'emalinowskib', '73p2ZPb1LOwHs7SClLzFrMbNYstfIdxT90tpeSrrFLgkvxUsy4XTsxK0tOCmE7DmnTxJTvwev3WS',
        'emalinowskib@example.com', 'in hac', 'Eveline', 'Malinowski', '53838822049', '2020-06-10 15:27:58',
        '312-917-0421', 2, 2, 187);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (13, 'shassentc', '8DmznarmNaJU9RVfsz4gCC6AAY7kAPq5o3C108Prxfvjag2ovAVlULGy03BhBZym0JYcdh86Hv6g',
        'shassentc@meetup.com', 'magna', 'Stace', 'Hassent', '20288554549', '2020-05-20 22:02:33', '311-662-4498', 2, 7,
        823);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (14, 'jwitcombed', 'A7eTrYW5AJ1diriNRIBmWTbFW1nSupfeYN4BagiKxOlVjZNiKRb9ZkWM6NOpBEzkAkk1ObOIvkov',
        'jwitcombed@ibm.com', 'phasellus', 'Jarvis', 'Witcombe', '76916976929', '2020-11-28 18:15:00', '163-659-0903',
        2, 6, 160);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (15, 'fitzkovwiche', 'ch1xfuq59N7D1un50NS1ntCz3epuPIqPh1CBwCZLn6aJi49OPnu7tJQFfb4FO3w7jlYYTyG08nsn',
        'fitzkovwiche@godaddy.com', 'cras', 'Frederic', 'Itzkovwich', '13619898560', '2020-03-13 04:31:24',
        '716-560-1970', 2, 9, 615);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (16, 'wenrightf', 'zbRzHcVTKg7vA7y5iAqXaYvWC8NWd5cFIqh5LqTM2YnIe3ScXEzKixQ74omT1SnI34JwPsyxxAsC',
        'wenrightf@ehow.com', 'non mi', 'Wynn', 'Enright', '53255793126', '2020-09-07 08:29:04', '675-444-7289', 2, 9,
        659);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (17, 'pcrockettg', 'SPdZtlhkcb4MViz7ucaohzzQEi9poV7rT3dLOMhjN2Z2rkxSvWa9cNQf7LArMemCiXFzarxJIZWp',
        'pcrockettg@multiply.com', 'in', 'Pavel', 'Crockett', '10343193772', '2020-05-28 00:20:36', '571-457-8498', 2,
        6, 690);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (18, 'wschallh', 'UlbFfRzqC6gMPloHilcyY2IK24Wf1un9fZUyI0lD2gP8TmSDOtLjPWmo9x2V2PXOU9fUCuJh3CA3',
        'wschallh@netvibes.com', 'vestibulum', 'Waite', 'Schall', '53462883031', '2020-02-07 15:25:51', '859-276-2457',
        2, 8, 252);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (19, 'ikumari', 'frlXflXSb0lsO3aXvnoEoARlo6Og45wO7ofNc3UQpQGE3wHDdnpmRnYtpcjcMlh8PfOxF8n97zpu',
        'ikumari@blogspot.com', 'condimentum', 'Ileana', 'Kumar', '49232149609', '2020-11-14 22:57:07', '442-155-0696',
        2, 4, 583);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (20, 'rbreesej', 'iXDDw9OIngpK7ig12ubXdSf3y8bjq35w3uFOhdLH4bQbmNaT63tjX3ngEqaaOGLGfFnD8GUUKZBo',
        'rbreesej@oracle.com', 'quis turpis', 'Rudy', 'Breese', '21743924855', '2020-02-12 09:00:34', '488-820-4771', 2,
        8, 478);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (21, 'rberthk', 'D5FCs4op5IkMbjkfjE8JAflRY4mKsakwdleoJ1NHhQctTu5HltXk2w6MqnQiCgK0QazlZVW8dUET',
        'rberthk@vinaora.com', 'nisl', 'Robbie', 'Berth', '32824087610', '2020-05-10 22:26:31', '869-470-3554', 2, 9,
        13);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (22, 'scrocil', '80SEuGnrZTT1NrD438M4BwoT07SXhtu2jIb7p16oNKvU3NcRgjrR7OrryKWZp0lYZ3KR52Hlq8Pb',
        'scrocil@ibm.com', 'feugiat', 'Shaylynn', 'Croci', '34131013312', '2020-01-05 04:59:09', '217-982-8934', 2, 6,
        751);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (23, 'jkaym', 'OT2r4F0L0HzhNAkNOMWqqqW7jie2wCtUnndTW2l21miWP6c7iQXyJWXkSTDxff7OussE5V6sPtJQ',
        'jkaym@altervista.org', 'donec', 'Jennica', 'Kay', '81094157093', '2020-05-21 13:17:26', '912-701-7702', 1, 4,
        878);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (24, 'cfeasleyn', 'Ke7EvzGNhO1G7T01QYRvTYPwu0SLBzdOSYi4uBJXumpSlDmFjdZiHDVvBAcxEJe60URDeDuYsyQo',
        'cfeasleyn@live.com', 'duis ac', 'Caritta', 'Feasley', '68444317883', '2020-01-30 11:54:10', '777-309-4045', 1,
        9, 919);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (25, 'pdecazeo', 'XSmqPKoHfzA81hNp3I59b2eODlR98eoPy3Sv9rY5fij1dhHbgeTWoKigU9WWPV8vlPXime8go3Pf',
        'pdecazeo@nasa.gov', 'sed', 'Paddie', 'Decaze', '58469489171', '2020-03-12 09:37:01', '670-457-4019', 1, 3,
        570);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (26, 'kjansep', 'jH2JtSkvmv2LfsryGLgtCZaJ1KYQAuhRdmDBBPHVTrpMbJ26hwpfjT7cr0x1cYJOzXzYnZ9Lj0Eq',
        'kjansep@twitpic.com', 'mauris enim', 'Katee', 'Janse', '31250765786', '2020-10-27 08:03:42', '212-107-5294', 2,
        4, 107);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (27, 'tswynq', 'TmhMpwQO6iuwrBVoLfUvehxgLlQ01QNLf8y1AEdLyTF0XItzE9v2rQ6FwJc1650WjEVPKLSEFPRP',
        'tswynq@tripadvisor.com', 'lectus aliquam', 'Tova', 'Swyn', '64837305671', '2020-11-19 19:12:11',
        '940-964-2329', 2, 6, 272);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (28, 'nstoyellr', 'Eh7lKLj4UIUUrIUG2yqXYqmCIiqZueV5htMjInSxCJZNkgXPHBIHFofTioKxmPocZaDUvIPrWCAc',
        'nstoyellr@weibo.com', 'at velit', 'Noble', 'Stoyell', '75203322223', '2020-11-29 22:55:02', '714-410-1921', 1,
        7, 758);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (29, 'cpickfords', 'rA7cz0axlh8Nkg91CmfDM0pyyRNKgJuysliFDN0eipEKRkCscBGqjTXzbB0CYvT5q2IV4u2KAjLd',
        'cpickfords@yellowpages.com', 'in', 'Caresse', 'Pickford', '56768262120', '2020-07-22 08:07:34', '954-893-3950',
        1, 5, 907);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (30, 'mstedellt', 'lQ3VuUkB7vu6VCV6tlhn0FbIRbDsd1ZN0EIH1vyBO1vSDCQRAh8mflPj9b1QDEjp8OSoT3WnomuI',
        'mstedellt@wisc.edu', 'turpis', 'Margalit', 'Stedell', '22572504049', '2020-09-12 14:55:41', '202-736-4542', 1,
        8, 130);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (31, 'dbrendu', 'IRg3AOEslw0Ha5Zuo7iUfkormPGjv54utcdDswgLj29wFxSMbCpZ6xQ0pee9xkkczrgLrqEc6ds6',
        'dbrendu@nsw.gov.au', 'quam', 'Dacy', 'Brend', '33030282504', '2020-01-27 15:52:18', '425-920-5290', 2, 8, 656);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (32, 'jtiev', 'KP5oAcv3ISAPXwpNUH0AbPUcrWyrdH7Kmpl0Gc4WfLQY2y4a80eEHN5PmdqqqMkEJHDdAbvkIJAU',
        'jtiev@shutterfly.com', 'aenean', 'Jakob', 'Tie', '11051888268', '2020-01-28 18:44:23', '909-432-6990', 2, 5,
        329);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (33, 'astollew', 'cKSGh3HkUzg1LgaUpapWC2eKnsdxbXU0INVU82rcHqkeefj7wILMiF2LZxHuP9FXk1D8yFSBqGpi',
        'astollew@unicef.org', 'eget elit', 'Alidia', 'Stolle', '05645218303', '2020-08-13 17:27:21', '982-745-6348', 2,
        4, 848);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (34, 'atattersdillx', 'zsDOrICBEvvayqJBDvXfEJHI9zGh0m4SXLC6nafIAru7BMpoh8go1BoZxV4VHAxdS7UJRj6dsxK3',
        'atattersdillx@hubpages.com', 'cubilia', 'Albert', 'Tattersdill', '01331910768', '2020-12-02 01:58:31',
        '426-913-6757', 1, 2, 994);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (35, 'wscalesy', 'liRnibjZUT77yKECWBrExqaJdp3GeqDSBSHGHxxyTpkQaqYiHwOX5lGsOAuZHP14UO3JU2ZajpPH',
        'wscalesy@yahoo.co.jp', 'velit donec', 'Wallache', 'Scales', '44867087723', '2020-09-16 04:00:34',
        '979-192-8480', 1, 1, 930);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (36, 'dlehrz', 'dicggamw5cVHD7NdQA1O67dfrlsY0fNyfV7p1NeRRKTlBeak6nDNEVTE7AVJR1zZHs2XtkrvS41L', 'dlehrz@ovh.net',
        'etiam justo', 'Deane', 'Lehr', '70234473558', '2020-06-30 05:19:14', '839-977-5479', 1, 10, 810);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (37, 'cfairfull10', 'EYEypf2s8fnRp123s4GJ39rpWP4MgjcAXIsdNrWSozTg7PAuIyAb9HUJuhfOamncsE0GPW1uU48O',
        'cfairfull10@discuz.net', 'magna vestibulum', 'Cairistiona', 'Fairfull', '29441099829', '2020-02-12 17:52:59',
        '961-246-6031', 1, 7, 45);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (38, 'tmamwell11', 'Lccv4eK1CnA9uZAx3pFSsGQSwdXRKJoAE41gBFm70z7cKyLLcZEoe1xnOy7O09RlZP2vml6hXReS',
        'tmamwell11@cloudflare.com', 'amet', 'Talbert', 'Mamwell', '18330441216', '2020-01-03 02:25:15', '693-833-9180',
        2, 2, 607);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (39, 'mkearton12', '5PMaFsOuVkqfEbK0zIVRKpiesDvVB1yZuv2MDQLaFVsXk8nWvI4Ap9MtPzKn6cJPYtFad2UsHHEr',
        'mkearton12@opensource.org', 'cursus', 'Morly', 'Kearton', '20151317071', '2020-04-04 14:49:46', '985-745-2550',
        2, 2, 629);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (40, 'hsummons13', 'CC6Mr9fxCEBBwPk9WwwM0kvvoubTfJsKyZxdjEN36xYHA61S7GGhlzKCyjpzzghcAFoO31kY0CMR',
        'hsummons13@issuu.com', 'odio', 'Herminia', 'Summons', '17512271762', '2020-09-29 15:43:33', '157-334-1831', 2,
        4, 618);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (41, 'jmadelin14', 'LRClcyiuIuor8uzduJNwtXCp3ehNvjtqrIYRTytZqy6YHLmbScppelCGGKef8T8pdgfs9V78cjqH',
        'jmadelin14@imgur.com', 'lectus vestibulum', 'Jeremy', 'Madelin', '19542071146', '2020-01-13 21:18:53',
        '589-414-6842', 2, 4, 219);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (42, 'rcoche15', 'JRrnKIg2Bb6bxMYVBeUmjWQT5KjRSbkWpInM8JIz4QVTv2Y415R1o20uj0hWEiTzpGf6UDC1rRUp',
        'rcoche15@foxnews.com', 'id', 'Roarke', 'Coche', '98042506052', '2020-02-17 19:25:05', '749-499-1999', 1, 9,
        584);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (43, 'cantunes16', '0cKRAwkCYuceLE4Gz8S5nz5A8rKNraf5ZD0Z9s1vgc1C0aiTJTshSMNHszwDMoNx0jZ6ovgtiJzK',
        'cantunes16@etsy.com', 'tortor eu', 'Clemmie', 'Antunes', '45645240622', '2020-09-13 06:51:12', '732-274-3011',
        1, 4, 468);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (44, 'dedwards17', 'i39kh8HuMCFI72SLDb5kZD5OKmoJWRB9AfSyJmcFHtp15rab7akfBU5Lw6uF5LKKDHIPVZHoSxd7',
        'dedwards17@yahoo.com', 'felis sed', 'Daffi', 'Edwards', '25719975170', '2020-04-25 07:56:29', '362-116-5720',
        2, 10, 563);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (45, 'wsanders18', 'Ejg2EDdG9TpncECJ1gUKswTcaXff3ouAn6OaKILGr0ww9VXWq1Gct1B93xc2cEVdtZfqEVhJnXSx',
        'wsanders18@europa.eu', 'sapien', 'Whitney', 'Sanders', '34393999062', '2020-07-12 05:56:05', '480-494-5054', 1,
        1, 75);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (46, 'dcecchi19', 'swcyeBUst9wpUOP7F4BmUbNgf0rXWsfPVMXirJw1QfRZqMXXLzsXALxPkvauJwzzzHAmOKPng3xI',
        'dcecchi19@noaa.gov', 'donec dapibus', 'Dot', 'Cecchi', '78976719612', '2020-12-28 18:50:56', '368-426-8756', 2,
        6, 350);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (47, 'cpurseglove1a', 'yvOJMG2XGPKpN6mi0Glz0s7h7paEMiQSZcTcJ6o6zk6MY5aM5karJsfw1HiSu5cstUv3PZ1j5Lck',
        'cpurseglove1a@illinois.edu', 'etiam', 'Chrissy', 'Purseglove', '28533245865', '2020-01-08 13:20:50',
        '968-662-7606', 1, 2, 360);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (48, 'malchin1b', 'rz5hcmH9q0TAGcSvcZoBXkU0ue37TvIZ9BMOsxTIjGaqXyZ2zQM7j6xd0jmBUiBHVAtIDRj2giyn',
        'malchin1b@ucoz.com', 'in imperdiet', 'Malachi', 'Alchin', '06335783977', '2020-10-05 15:32:41', '622-290-6231',
        2, 4, 701);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (49, 'jmelior1c', 'IsKj4ikkDp1n45Yfi1wqa3no9v21KqYprzetqiSoRTRZjsrMP1pfwiwYvzwOQ2gX55OCPejXUggZ',
        'jmelior1c@people.com.cn', 'donec', 'Johnathan', 'Melior', '75145823461', '2020-12-26 05:56:59', '180-852-7958',
        1, 3, 22);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (50, 'kdodsworth1d', 'DMhfISXzBNmvWe5YnjIB3TO3iN9Ck2YqYsnA3d5Q7thTRkm8TDN8rWaU5q16A9UdfE88lbFjkLvk',
        'kdodsworth1d@dropbox.com', 'dolor', 'Keriann', 'Dodsworth', '96252529505', '2020-02-11 03:17:33',
        '743-198-7476', 1, 2, 844);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (51, 'dbusain1e', 'ZOLjfk6K1Q8fHDdUj9jxGpPxE93a8koJTFTEYcl8QhXwk8FpIDutvmctqZYDns0IDEwTbBCgGa6p',
        'dbusain1e@facebook.com', 'mauris', 'Duke', 'Busain', '65286933534', '2020-02-27 04:22:37', '563-771-8101', 1,
        1, 584);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (52, 'mmulliner1f', 'fDzt0bcRwWiyoDjryB5cATE8AItiOc5UawMZ9NyJAf4GSYk5CEsCFiaud7bUkzb85UqVKbX3xKaR',
        'mmulliner1f@alexa.com', 'vestibulum', 'Modestia', 'Mulliner', '99831098181', '2020-10-08 19:50:01',
        '178-160-1265', 2, 10, 559);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (53, 'aloving1g', 'BeaJp6BSTVzPvP5xlWgCMpWSDj5mtgH4y3LGpAtA737bQUyjrnAdiO0Di53mCdx5WfGndZUYtsAF',
        'aloving1g@liveinternet.ru', 'cursus id', 'Amy', 'Loving', '42481264662', '2020-06-03 14:00:53', '668-832-6001',
        2, 7, 637);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (54, 'lmannie1h', 'wQMB3iVPhhENT7dUWYNbpOPai1c9KfKN1TGudQo7jsOkwxFyxNcjrpCEMmBcfSkEM73Zx9A9DaNk',
        'lmannie1h@sakura.ne.jp', 'vulputate luctus', 'Leda', 'Mannie', '82553739132', '2020-07-18 22:45:25',
        '204-491-7875', 1, 2, 644);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (55, 'lforsbey1i', 'fq1O7kCW9ggbcVECli08ow4uFuK7hBXCMVnu9m1vUmknSGYJiQjW8oe9NG2630nxnuS7pHNgYJbu',
        'lforsbey1i@fotki.com', 'duis', 'Laurence', 'Forsbey', '40926507882', '2020-05-12 01:50:12', '597-579-8721', 1,
        8, 105);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (56, 'edodsworth1j', 'Y427A1YOiQJU9tk3jmxd569BndmAd4co3MdJRIw39rjoYEjdAvoslg41p8Ewow9IGsqne6eNy6ae',
        'edodsworth1j@bandcamp.com', 'interdum', 'Eldon', 'Dodsworth', '07647528678', '2020-02-29 20:11:34',
        '354-551-0544', 1, 7, 431);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (57, 'kworsnup1k', 'hPeTv6gkSfnd3ytsu4JeP50C23KYL2cVQrgkitckCpw4xXXsQRW5nlOIkQ9qNEqEUlgPOBSuqDkg',
        'kworsnup1k@barnesandnoble.com', 'amet eros', 'Kara-lynn', 'Worsnup', '51808699369', '2020-02-07 05:42:53',
        '998-976-8919', 2, 1, 102);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (58, 'akiefer1l', 'Sn6dgrjnDaWzGk8mL4RPfqXA1ca89oDYuhnkJqZ28IHhz8e9BY5QaapjtkUP8K78lIji5rwSkhrj',
        'akiefer1l@bigcartel.com', 'eleifend', 'Abran', 'Kiefer', '27073146920', '2020-09-01 18:07:47', '761-706-6372',
        1, 1, 701);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (59, 'rrozzell1m', 'Sg2nnFyi39l9rNP29K5nQP5VfE9xPQzrZ7T3e9HpjK6qfytR4cSdw7sFGvwGt96Cz5FY6QB5Xobj',
        'rrozzell1m@hexun.com', 'faucibus', 'Rosie', 'Rozzell', '18231602319', '2020-01-21 01:50:54', '944-101-0407', 1,
        8, 662);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (60, 'kdilger1n', 'u7MD7u4hTWydV9KlptlkVxHoDFWjqWkEP0UqOvCnmzcioWcwK5AtCGPBYGdDqBOrDE6PfWT22XE3',
        'kdilger1n@columbia.edu', 'tincidunt', 'Krishna', 'Dilger', '85472076337', '2020-01-13 02:42:58',
        '213-163-4881', 1, 5, 291);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (61, 'amarchelli1o', 'qniDwZyHv5yTmx7Eb7WlUbVOMdD4HF6dNQxQoH6drmq5pJE3VyzAPWCxwjUPZMZoI1TJWwBOk3jA',
        'amarchelli1o@nationalgeographic.com', 'cubilia curae', 'Ava', 'Marchelli', '82003580157',
        '2020-07-05 11:59:17', '813-947-7131', 2, 9, 921);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (62, 'dcoultard1p', '2WE65462fd48d5iLntqTaxYSANo6IA07ZTdBhPD5avVDzzIdYJzTZkkqk47lo8TKi1FmFo0HUogP',
        'dcoultard1p@jugem.jp', 'neque', 'Dorisa', 'Coultard', '84007742478', '2020-07-24 15:12:53', '742-189-9169', 1,
        7, 379);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (63, 'cmariault1q', 'SgmiqLuNTZAl6gJoeEbl5fkg221HH2hmOysZFhqwrcdBrTEQJB6lpuwsbIR7T9V1yarlO9s948jt',
        'cmariault1q@chron.com', 'neque libero', 'Codie', 'Mariault', '40350478328', '2020-01-29 08:58:41',
        '701-803-7463', 2, 7, 581);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (64, 'gbridges1r', 'z1MnVeyC8gzCVqQ1cZaswpOWOVMVFDed9XzmbNFoN8XqfTMG9U66dJHxmdg0gZDRfFqFMxjFkz5t',
        'gbridges1r@csmonitor.com', 'vehicula', 'Gertruda', 'Bridges', '13402013005', '2020-04-13 14:11:29',
        '874-848-7924', 1, 9, 660);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (65, 'tshapera1s', '9aJq5aamZOlG2rTvTwTE2jdJICOJhCS8Ts2NN3vu7cPaCI6aEymFyTh8wYZIMKRXIL9Ct5Z38SeZ',
        'tshapera1s@ucoz.com', 'nulla', 'Tadeas', 'Shapera', '11972392363', '2020-02-13 13:55:36', '576-635-4880', 1, 3,
        816);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (66, 'gshakelady1t', 'RJGASp9dlsvruZqjCVUKemZGvy4Qyyom3QnvzVGBZu6ApuHWOHEQLgH34iFi5agDjbU6k6EZ5Usu',
        'gshakelady1t@prlog.org', 'quisque erat', 'Gallagher', 'Shakelady', '42148724331', '2020-05-09 12:37:38',
        '224-617-6275', 2, 3, 71);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (67, 'lrymill1u', 'ebIezaYOQeUqJ3Jph5vNKFcGkZVij68hbJXkca9jzhzjuRGp4pkJ3KsBdd8eUz4oHkhQcjVZXzfm',
        'lrymill1u@xinhuanet.com', 'sed vestibulum', 'Liza', 'Rymill', '11153735794', '2020-01-12 05:04:35',
        '755-674-6262', 2, 2, 787);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (68, 'imedland1v', 'MUXzJnou9hxWLjMiYK7r94qWA3fYkHQjZQFz0DcL0wMlr3wq9sxQv6vqN8gYXkuipw4lONPBcqYO',
        'imedland1v@unesco.org', 'eget rutrum', 'Ingeberg', 'Medland', '75379521999', '2020-03-27 23:38:05',
        '107-118-4205', 1, 5, 253);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (69, 'abeverley1w', 'UJF5XPlWpWat9qvWOD5nT66et4zgseGLyhNGQdcDKndWgKYjumbnVvhcnHnOjbNbZRB75pTRoq4n',
        'abeverley1w@netvibes.com', 'amet nunc', 'Adriaens', 'Beverley', '73709432103', '2020-01-07 07:20:59',
        '822-703-2427', 1, 10, 106);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (70, 'gsambrook1x', 'v6SBIZHXwfM7AzELO1lH99VCbsMkcZBQ00VzGviBGRhe0SoOLynb7iGqsAa84Bm8CC47cV0NAXfO',
        'gsambrook1x@shinystat.com', 'nulla', 'Glenn', 'Sambrook', '87441294447', '2020-09-18 10:31:24', '464-258-0033',
        1, 2, 349);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (71, 'cscuse1y', 'nVXmTfFLN11XDoXOWTpedHtfaCUWUCyI5mzTdDjY8e0oZiv6IpDdtzuIihAd2vGaetbsiLRmvW02',
        'cscuse1y@pagesperso-orange.fr', 'vitae', 'Crista', 'Scuse', '29350964627', '2020-03-09 04:45:57',
        '501-339-4056', 2, 9, 441);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (72, 'pziem1z', '4RvyfvwZ4BbyBrOSASvoTzUWQ3tOZ5Kh4dXCNofcOBDVI0RUz9abfb9fcUxwxZCwBsW1kQdkF4BK',
        'pziem1z@ycombinator.com', 'non mi', 'Penni', 'Ziem', '66269244469', '2020-08-21 05:34:07', '643-196-1561', 2,
        1, 82);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (73, 'ngarton20', 'kSwDPJJKAjNmbzADGletRejVYuB7PS7thspzzy4tdL3NxqU1nKJzYy38DKsylrDMPwCxd22Cv5fz',
        'ngarton20@illinois.edu', 'eget eros', 'Nanine', 'Garton', '56589801016', '2020-10-25 06:54:53', '204-446-1953',
        2, 10, 359);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (74, 'hblaszkiewicz21', 'zmOA5PJQDgmKc4TCJkUE2aUZEOrXfbuMYqCsyDDFP6BF6abtFdtC6gxlkaZ3I3YE5xK5VCsYtrfc',
        'hblaszkiewicz21@last.fm', 'luctus cum', 'Hurley', 'Blaszkiewicz', '22270595474', '2020-05-11 22:20:13',
        '492-897-0654', 2, 4, 959);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (75, 'cexell22', 'NHhIeiNmQhYwVPgp0gdEImETf05wXIzC2CmvBFZhLRNrQmiRAS9ecuPpd5n7tqPlUPssJD9paPe8',
        'cexell22@cargocollective.com', 'nec nisi', 'Charlton', 'Exell', '83955540321', '2020-06-11 12:54:27',
        '700-150-8257', 2, 8, 447);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (76, 'rseignior23', '9Henz7c1F0PDAopNROwIODIANLo2EVQLgFLpNt3fvijMrgXVbTMbEJoAsUiEAGTgXEIPEClfoygC',
        'rseignior23@dyndns.org', 'turpis enim', 'Rennie', 'Seignior', '79269852941', '2020-11-22 06:40:38',
        '288-828-1028', 2, 10, 960);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (77, 'xromera24', '97yRB6MZOHZDbhHx5v7PIp8pi06ZTHWdXPFjFICIMUdVcqJshIcayYJbu3LH34Z86AQXhGcEPvyD',
        'xromera24@studiopress.com', 'posuere', 'Xerxes', 'Romera', '88541804263', '2020-09-13 17:30:27',
        '174-548-9700', 1, 6, 821);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (78, 'dleupold25', 'snWPTm4RhrzMJTgeWcruecH8Mfqiwd7vVVEfQn1hvAdKOq4Zm6fTlQTTd4NRoYMj4ZPwQu8SqXGd',
        'dleupold25@lycos.com', 'rhoncus', 'Dolores', 'Leupold', '53565064481', '2020-01-05 08:03:59', '758-675-2359',
        1, 10, 918);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (79, 'kropartz26', 'dwiyPVtStRNf6RL7VDCXG5KIIMWFRYSDWFmkl4WMcDdNgNiAsgcFtMYxkNlWSnvlg7KvSE7vJnxe',
        'kropartz26@cbc.ca', 'congue', 'Korella', 'Ropartz', '14978174834', '2020-06-07 05:00:41', '557-363-3102', 2, 4,
        461);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (80, 'pholah27', 'FQYNWoaTrfdbnwCtfgY3gmvKZ58obbhxa4V7VbBnabSIvW5llF4ImD90Wfa6Mtox4bhKDkAOvor6',
        'pholah27@hao123.com', 'sit', 'Phyllis', 'Holah', '27074578622', '2020-08-19 23:34:36', '316-632-0637', 1, 8,
        587);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (81, 'gfulkes28', 'TDLCBUbZGkMGHQztWSG8kZXSupgEXk6SlGDnlCHfuWWs1KBmFs0G8R4Orou0CReMwwyGGku7MZVb',
        'gfulkes28@wikimedia.org', 'suscipit', 'Germayne', 'Fulkes', '52073494542', '2020-11-29 00:24:04',
        '654-123-1544', 1, 5, 77);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (82, 'banyene29', 'dVTch0uFRLihptC7jr5hvXheDE76fpBmFglkxqA4TWRLhzTdPAVWKlaNgWCuNM9bAh59hEYWJBlx',
        'banyene29@bloglovin.com', 'blandit', 'Beilul', 'Anyene', '16388352325', '2020-10-20 02:00:47', '641-568-2306',
        1, 2, 455);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (83, 'nmcroberts2a', 'pHmCU8kJd4nGouNejzpS5YgTdq9CMdmmAm0iEnYVYw4GlJIzpdBvLhnuSJljG8kqDd3FQLYN4htg',
        'nmcroberts2a@ebay.co.uk', 'donec', 'Nicolai', 'McRoberts', '99396377415', '2020-11-24 23:41:28',
        '532-938-7044', 1, 2, 194);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (84, 'glegassick2b', 'sAhDdIT1xPLz9VNKB31rG9H9nHtPSJXZkkvtuL4lCugqJaREbNw7xUxbb5fAjvvT37Ed9QA91toI',
        'glegassick2b@icio.us', 'cum sociis', 'Godfree', 'Le Gassick', '62153810953', '2020-11-01 13:57:47',
        '781-857-7006', 2, 3, 331);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (85, 'msinkin2c', 'B02BJmJPoeqgQlmOoEjWET26jw8qzawPj6rWO9cUbdfPiHKal0fsVrglyqZPXI9tghxGgUqubsQA',
        'msinkin2c@columbia.edu', 'massa donec', 'Marlow', 'Sinkin', '32364601830', '2020-06-16 01:23:16',
        '557-936-1266', 2, 9, 410);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (86, 'mcapehorn2d', 'T0Rm7vo8c8LBJBUSevJ9tysfo5g5E2d07syrLjtZMPO6KqOzgAVT1YIPyxc3Vxtzj43VruZIaJp5',
        'mcapehorn2d@cornell.edu', 'sapien ut', 'Michail', 'Capehorn', '23518087627', '2020-04-08 22:16:40',
        '531-307-6351', 1, 8, 118);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (87, 'rbache2e', 'K3060H9x9ImD2dtqqOeHxDC3bQn98tXpktKYPB97nmONxygxCNH80uLgcjFmMbNyOvAzKaIpOgoK',
        'rbache2e@washingtonpost.com', 'eros elementum', 'Ronalda', 'Bache', '48678435474', '2020-12-06 10:27:21',
        '159-486-6530', 1, 9, 286);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (88, 'vcrystal2f', 'U5hXsU8mkGdJ9kUouTVCnztmbv1zbmczbLHQ5bSx7ehASz8mvV4GQNK3FQgpT4ZDZ9I3DdoZxu1k',
        'vcrystal2f@google.ca', 'in', 'Vlad', 'Crystal', '29096306990', '2020-12-06 04:39:55', '166-829-3242', 2, 5,
        716);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (89, 'tquinby2g', 'WRnN3k8bMlkcy4EN67aCoRNJ2m4MVoptz6rFOGdKGT5huRGHCA5OSn1mGSaJrDtPtMfXTKMSaJqq',
        'tquinby2g@over-blog.com', 'integer pede', 'Thedric', 'Quinby', '47959825437', '2020-10-06 16:10:50',
        '442-780-3807', 2, 3, 303);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (90, 'gcayser2h', 'uQxeZwp7fdwOVBUdUHeSRJirIooGq5XDgD1X9OqatMbNgOPg9cmpIRQmyyPrQcBbqYkgtZYlT6w0',
        'gcayser2h@globo.com', 'sem mauris', 'Gabriel', 'Cayser', '77609829005', '2020-05-11 07:12:24', '459-519-8865',
        2, 3, 307);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (91, 'frevelle2i', 'XGowdexjXRWgm3xoMnWQJYreqqDxOlj1aiZDTe8TA6FwnaT2Wf9D6HzKd0epTLPiXU9IUc5dHuKx',
        'frevelle2i@moonfruit.com', 'condimentum id', 'Fredric', 'Revelle', '47366882307', '2020-12-31 15:45:22',
        '821-905-6919', 1, 2, 594);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (92, 'vprinnett2j', 'rs5vT6JZcYiDyai1s20ifrAe9VAzAV4ALRjd77x9kfBRMegQ8GivSts8cSqhSER60EsK1TS2NalQ',
        'vprinnett2j@tripod.com', 'lectus', 'Viki', 'Prinnett', '00912131799', '2020-12-18 21:43:47', '853-701-2347', 2,
        6, 828);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (93, 'mtonry2k', '6DtOwfM61klMQUlhUKitpoqCjnepQczFvzyi3boT59E21NVMmoHP46PgrglbH1PcX48xomfUEH0Q',
        'mtonry2k@woothemes.com', 'primis in', 'Marcille', 'Tonry', '96263952176', '2020-07-06 23:55:14',
        '432-591-3570', 2, 10, 274);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (94, 'cdevuyst2l', 'nzPApcN6kvniAHAqRZPYRlqebiCQdwEJCvVeEZwBuwsR0dt1qtxsRp9kqiX9swKXATvdGLxiDjGU',
        'cdevuyst2l@liveinternet.ru', 'erat fermentum', 'Caril', 'De Vuyst', '30918135226', '2020-12-15 07:29:26',
        '581-716-9417', 2, 5, 561);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (95, 'mblasdale2m', 'DfWanUTtW1MWGLx5XCQfPJYGIDMNTrmMXcJtVMosM42APxum2LQmVLRTI9erps6prn78erdzfa3J',
        'mblasdale2m@jalbum.net', 'donec', 'Marcelle', 'Blasdale', '54620118928', '2020-09-12 06:52:39', '638-121-6188',
        1, 2, 527);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (96, 'klilley2n', '0XMY3mmFgcPzJnZiTnUGY21Qgnvlj1e3a3rysfn33WP6PS0ZtH623w6E4DJIr8pXrnBpjO7xNmn2',
        'klilley2n@ca.gov', 'risus auctor', 'Kass', 'Lilley', '57358648094', '2020-02-19 21:57:23', '649-567-2334', 1,
        2, 778);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (97, 'lryland2o', 'durKhP3rvsRUpyWXPMa9YTE6ayjGAMwlyEw1TlpNO6QnIa2A0GEjKRV7IHj61KrHBaCXKmyQLXTD',
        'lryland2o@desdev.cn', 'ullamcorper', 'Leslie', 'Ryland', '88942940203', '2020-12-06 23:42:08', '763-352-1493',
        1, 8, 208);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (98, 'fthorburn2p', 'f0VEMG3OsmhLvEKo71SamyTAMWjhgwClaEUEeoyhXoNwkUuqcPKPgxHHAXqQnPWxVAsAFTVQbqQg',
        'fthorburn2p@google.com.hk', 'vitae', 'Faye', 'Thorburn', '68149189596', '2020-07-23 12:42:05', '555-966-2901',
        1, 9, 775);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (99, 'lgodon2q', '2IwHqb0yuQhfo82hlwPXisPBwJug03ZGvI6kOzKmeJS4t7f91TdGIQw0WsOBGKZxTZhADG8qs7Lu',
        'lgodon2q@amazon.co.uk', 'vestibulum', 'Lila', 'Godon', '61722557073', '2020-09-02 08:11:06', '278-964-7838', 1,
        2, 762);
insert into employees (id, username, password, email, role, first_name, last_name, pesel,
                       employment_date, phone_number, company_id, warehouse_id, address_id)
values (100, 'slaste2r', 'G2ZSEYUnNxNsV5RfejzefPPMACOK4WRPumIoMQpu3lGDvTN3VlahvJAO6WOinYbvU6AahBk45Xly',
        'slaste2r@myspace.com', 'turpis', 'Sheff', 'Laste', '37170764606', '2020-04-02 02:49:32', '883-940-1914', 1, 3,
        741);

insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (1, 'user1', '{noop}password1',
        'pdimblebee0@prlog.org', 'Pattin', 'Dimblebee', '4895011041', '889-371-2316', 2, 121);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (2, 'user2', '{noop}password2',
        'wlowndsbrough1@newsvine.com', 'Wald', 'Lowndsbrough', '5798756352', '609-269-3797', 2, 445);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (3, 'agregory2', '9vt5JdO3c2fYT6ecBxRmrrMWRUT7cCGFlGGxuak6Q8CBp01BCSGf9t086odJxjPW4RiDVnqev6jn',
        'agregory2@com.com', 'Adolpho', 'Gregory', '3812388160', '514-674-7963', 1, 93);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (4, 'ggilbride3', 'LoCxAB2MrNL5isTQWdlyIIA9OYaa396rjnmw1wMP26msGYMPwm8dwtZpoIDdgcnPobLHGDQCXEPe',
        'ggilbride3@paypal.com', 'Gideon', 'Gilbride', '0951834365', '467-172-0924', 1, 927);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (5, 'gheaney4', 'lwPsupMRAMBtOHgFNS2RD8adXXeNXtgkG67MvGCOUUJPd3gfUHNKYMnPGhsQVOBZueAnJirkMVbH',
        'gheaney4@bloglines.com', 'Gilberte', 'Heaney', '9091751832', '912-782-2105', 1, 841);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (6, 'blaban5', 'Yzehtnt7JqibFgmik9wXduq8h9G6lh2ECRBFO2DMK6xw3tqBF5fSqdiXN9b6UtAsOKvaSjV63PgR',
        'blaban5@webs.com', 'Bryan', 'Laban', '0535792353', '205-212-3453', 2, 527);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (7, 'dcornish6', '6ouQ5pvWjd6D5LyjOOqRaDdClHeCVrixtELy4S4pVRMcKsWB8z0ikz0ZmMizc1eYc0v6pP4vhDKT',
        'dcornish6@kickstarter.com', 'Darlleen', 'Cornish', '9919536249', '502-597-5673', 1, 473);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (8, 'jpatullo7', 'WqN3PZnB6VYoMEW8rwV0y7I9fHPNAdRbvgKYn1w2a5ghIRdI5maxLtyGmjcp669Hs19maacT1EkY',
        'jpatullo7@auda.org.au', 'Jareb', 'Patullo', '7366411555', '868-474-3398', 1, 945);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (9, 'jgutch8', '593ktESs32jtH7RJHV6BjDWFloNQUsyIPPDila1ZuJoYE2yErc9ASM8n9xsCJZKyYJwpktbWVbkJ', 'jgutch8@ed.gov',
        'Jeniffer', 'Gutch', '3587020801', '552-344-5855', 2, 852);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (10, 'cwingrove9', 'TVgQWq8V38ASanXqWnu6SLyFwgPBc3iwHUjRaUBVqQAJLcw781URlsdmnsQL8FA0x00ghNZkgm7W',
        'cwingrove9@marketwatch.com', 'Curtice', 'Wingrove', '6520415350', '500-465-8601', 2, 104);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (11, 'pbernardinoa', 'E9BDWR5dBvAOGMczTawAmdvpYdGcgFTBysEShwK235vX6R2omcsIFZFdkttEqVPFujo0AmfazUTC',
        'pbernardinoa@globo.com', 'Phaidra', 'Bernardino', '1333311779', '948-243-2125', 2, 668);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (12, 'bwarsopb', 'tQGAuuChuGbUYIELOkBF6pDJt2EKY0J9kYkRocrjrsK8zh7otBjEMB0f3IfE7r46WOmgPp3t4yVt',
        'bwarsopb@godaddy.com', 'Brad', 'Warsop', '7890695389', '443-197-2013', 2, 309);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (13, 'mnilesc', 'qCxvGWHK5SMGOJ534Fqk9ph0gGvwirIidMtLydBQtqW2LqC0Ta0Bakav0QFOy5FmAzI8lbM1HX38',
        'mnilesc@vinaora.com', 'Morris', 'Niles', '5594567213', '801-744-5689', 1, 636);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (14, 'hspoonerd', 'zKCpjQ0XyX2lO7Fvau8RadJnyIwIDruqeWNHSFN1sRaFlbrTL8ueBqapjku8PYv7NNmJiE2nxibJ',
        'hspoonerd@gmpg.org', 'Hunfredo', 'Spooner', '8467612951', '495-594-9320', 1, 41);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (15, 'gbeaue', '4bFbLQo805Ofk4wS5dbKXmjF5qXffVOD2mnrv3I2HdwrY7nqeRztNznQL1K6LXb8haGm3emt0DNr',
        'gbeaue@shareasale.com', 'Gabi', 'Beau', '8393266520', '216-842-9106', 2, 456);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (16, 'nwildgoosef', 'XcFhnmpDH0tAa6PI5uXv2Nv7nBZHN2KU7Z9JFQ2m2Tt2NvpnNjZxtHsVbvjS7bqu5CyvLEEz3PZY',
        'nwildgoosef@princeton.edu', 'Ninetta', 'Wildgoose', '4510019349', '702-995-3146', 1, 954);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (17, 'cteshg', 'bucLSDoniDWDQ56rgZY9dTtSZapjMVRvDp2cSdT1iGmTsOu3joCH7yCZXaSPCuwjHq9zveJkbGns',
        'cteshg@ameblo.jp', 'Cece', 'Tesh', '1492667335', '682-979-4720', 1, 596);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (18, 'doehmh', 'P9n9sJyky7khX7pQwXh5pKhZAAmQ4ltfvqdzxqEMpSWInzEahp4wsCnrFOwkyNCv9UCn8bhZQGQC',
        'doehmh@cisco.com', 'Donnajean', 'Oehm', '2028863234', '345-926-5170', 2, 857);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (19, 'smongaini', 'lTpkfNLGxI6EBEVz85ivK0JA3jRY6HzlsjCjfWNdS308SqTQXsfU6Rn2EmhL27Wauuartdg3XSFI',
        'smongaini@mit.edu', 'Salomi', 'Mongain', '5053057247', '358-289-9713', 1, 391);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (20, 'bpeagrimj', 'WgKyZ8PMxWaEmllZ0eECGOYXCCFQmNOuPhmJktusNumhIMeDc2dATwErQTlwqsVAskJ9Z3ZgvljD',
        'bpeagrimj@city.tx.us', 'Bidget', 'Peagrim', '0209359919', '940-203-7736', 1, 615);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (21, 'bwalentynowiczk', 'BsGDLwVNJs0mT9PuBAiTR3KtWQLAARMzVpq0YezplBNOm7JwSkEbXWxr3lZuhw3HUC9mKXgDdxtZ',
        'bwalentynowiczk@squidoo.com', 'Berry', 'Walentynowicz', '0821964496', '144-318-7268', 2, 168);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (22, 'fmillichipl', 'QYAYIyaQs7PJWJCxZdt59tuLILOfgVi8tvCLFRUGnwk9IRqmVWvALcMePIu0vsMpaxpJRcodQejT',
        'fmillichipl@addtoany.com', 'Filia', 'Millichip', '4898413142', '159-952-0886', 2, 775);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (23, 'aitzhakm', 'xvvMkdGcH86Ui5isHpzRVTe4ialQhCgud14QjIpdj8Q19XQ2S6ZdKQg6szk97gy9QMLZTNrYphwQ',
        'aitzhakm@networkadvertising.org', 'Aleen', 'Itzhak', '5385913036', '912-795-3184', 1, 155);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (24, 'gcasinn', '33LwbLPO3tLpdVQ1wqTLbpftPQ8TxJufuukK960xpkVhsPCv55qDusvnu43DS5Y0ZjTLTlV5yG1g',
        'gcasinn@behance.net', 'Glyn', 'Casin', '1865927556', '763-409-5492', 2, 629);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (25, 'kpendergasto', 'hkPew2repV1hMQryNoH6RRf3ftraokxQiywDiV9hK4EbKRaOfkLxiBvdHsiBMscEfRNigosJAqsS',
        'kpendergasto@goodreads.com', 'Kellsie', 'Pendergast', '8578064608', '729-214-9998', 1, 737);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (26, 'dperonp', 'QWiy9cclhAISg8PWmzBiOqK1XbWIXiceNrvj5e0i2olqb6PYvSerPRekKxtbMUt1IK17JLFZ6yM0',
        'dperonp@yale.edu', 'Dalton', 'Peron', '5597819499', '695-525-3887', 1, 767);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (27, 'mfosdykeq', 'spqLIxbbPrAszO4nXXjM1fUxOjrY8dqGlFuedOk6GFcAAgnNNqWTEwocEFwntgi9rH0FQCWZcDWE',
        'mfosdykeq@cornell.edu', 'Merline', 'Fosdyke', '8956972157', '129-972-3170', 1, 74);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (28, 'mlunar', 'Hm0agEAhUqmqseYDxhFPCyWC0TXq23aYyHsDIv0PZSeLZH3uQ7OW08UH5TrasHx73bn5z7PzRIf4', 'mlunar@cnbc.com',
        'Mickie', 'Luna', '0926692903', '503-518-8481', 2, 640);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (29, 'rlodemanns', '8aytYN6aaaNtisphpzJR3tiK0lulr5MoOFM1AMsAwQE8Ae81PseueWGSMd3RxEGsUQQ65nwOS1Jw',
        'rlodemanns@live.com', 'Rodney', 'Lodemann', '5688082923', '171-927-3887', 1, 715);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (30, 'ogalliet', 'YSFMpYEqXnjUm9J9k5CL2ziAsFY6vy4xN6py4lQOZZURYcjSq55GRGQLEwsasqayH5XI5HKqrO07',
        'ogalliet@imgur.com', 'Oby', 'Gallie', '9459836931', '199-649-3865', 2, 636);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (31, 'iafonsou', 'ZRxtVQVQXrIGgFYrwtbcLshov0AIkz6dp2Bf81dnOUSh8bNQQX1KvLOmn0bSv15jg7FYnsdEp3XG',
        'iafonsou@cbsnews.com', 'Irwin', 'Afonso', '7905575775', '115-674-6808', 1, 744);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (32, 'ajacquemyv', 'XAILc3w1uGgp8neKFa7TznVQhvUQopWncMF1yCepJF8TgjmYsJuWoQr97STyTmKNk6HQlsR7YhEi',
        'ajacquemyv@gizmodo.com', 'Ardella', 'Jacquemy', '9726708524', '456-938-8696', 1, 563);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (33, 'fsidnallw', 'ocokbhkTCKDO8sNSiTmeM0R57Y4RXeBa5UKd3e4U72xLrMXj7kJizDYiCILwTVowrzb4xfvG7PoV',
        'fsidnallw@odnoklassniki.ru', 'Freddy', 'Sidnall', '3412079792', '816-446-7367', 2, 205);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (34, 'kburgenx', '7hoVkE6yda0WmfM2TqGiQd4YnKwEi1F1JdpwnsTjgw3zoGkh5zAulLNrYCjoU6dz3LYoCEDqsyOP',
        'kburgenx@psu.edu', 'Kylen', 'Burgen', '2503686722', '457-972-0388', 1, 135);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (35, 'idownery', 'qXlvBTf6irfz9UBFUteTDvkomljFfUuSGwKC1EQE7BZepOT5QhS1KxsOuTIrap3pKTKPIbxY1ZW3',
        'idownery@hubpages.com', 'Ingaborg', 'Downer', '8497680933', '803-461-7576', 1, 474);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (36, 'khullerz', 'pY1j8S11UqbMrPbz0Bmxd3VkHZdqJwZMXoi7XuPbZnyor1KvZ78hOMNrLlYnedmo5E93fQPAE5Yf',
        'khullerz@edublogs.org', 'Kirbee', 'Huller', '4196168075', '480-940-0079', 1, 622);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (37, 'pgolbourn10', 'CPvFRTM2WmQq72tz47MbF1DF6dP2fYjgrOWihSaPhInAJoVB5tTGSEehGFj7HtA7jCJwFrz9aFmY',
        'pgolbourn10@about.com', 'Petronella', 'Golbourn', '4717425195', '987-668-5314', 2, 75);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (38, 'rrikel11', 'dt2VRIzQCaY00L84Lda6fNo6L7aMKz90pfekedEVIJZoCXuCmPIqbwDCMrTjkjr3eiAsypKHXZxc',
        'rrikel11@live.com', 'Rolland', 'Rikel', '7105852427', '645-760-5010', 2, 567);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (39, 'rquesne12', '90UX3Ics0SGbllYAFlCnb9WMdnrstaai17U5Id1VYQtjuxYsGRxUgOO4QCEEAxXNF6N26OcnP3Yk',
        'rquesne12@canalblog.com', 'Rica', 'Quesne', '7728934032', '489-209-2006', 2, 42);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (40, 'pcooley13', 'ZOwppRu2ofuRaTypGfYv8M5zIxHkbxlCOIGapqvhw6Wu6CFN4icLANnZtZMqn3BVwDGOWoEE9gcl',
        'pcooley13@merriam-webster.com', 'Philippe', 'Cooley', '9573751736', '198-856-2090', 1, 618);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (41, 'tlopez14', 'yFGQPq8jtja4k3f53Nz2kChcNhrrv7W64U6EmjR5NSTExaz4RS6AdhENG8rTRkCzd8Bzo1yf4evH',
        'tlopez14@huffingtonpost.com', 'Tades', 'Lopez', '8523304096', '705-145-9270', 2, 270);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (42, 'lmoizer15', 'fOApBrMSNv2DYFTB2b9jiXn4gGt3Z5R5yaOmESnmWPHtLX0TRo2v8m4Ke7yYtk0rJ0rlj2ii3oQu',
        'lmoizer15@list-manage.com', 'Ludovika', 'Moizer', '9610103814', '300-780-7268', 2, 275);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (43, 'jgarrison16', 'wv1t0Aaem4OnKyzmJcX1uFTMJrgip3QCJgxu7NdluEzstaZScE5XvLJ3P4qAlMtJq0GpfkjhgwsG',
        'jgarrison16@360.cn', 'Jacquelin', 'Garrison', '6076522800', '446-729-3936', 2, 499);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (44, 'emoreton17', 'WunXhRIQAiPmrd8O3EbztbgVMcOf476EbLyEGRUTo8JycS4LLgiLaDxQ3NCsqZDEg5OAzTzQpr7a',
        'emoreton17@cloudflare.com', 'Ezequiel', 'Moreton', '4649940897', '240-538-7545', 1, 844);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (45, 'pstraw18', 'coa4fZkDxCObfnX4kWa6ZwIPHm7eOmPVCjcDjOZaqHGMPIVX7Dv19YYcfXJt67towv3xy31Xb1uF',
        'pstraw18@home.pl', 'Piotr', 'Straw', '9296820988', '472-169-2438', 1, 637);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (46, 'mpalin19', 'YgB68SUvvpXVmB2ITabhwXO7mDbnUK4uYUVRnOOnzU80tADvgsxGpvu0iquoAqM31sgZ4DZwKYgI',
        'mpalin19@simplemachines.org', 'Margit', 'Palin', '3566621567', '386-950-8149', 2, 198);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (47, 'clecky1a', 'HY91prncGidXg8Gen4oRCeUzMPGLD5RpsghMjnSJEsca8AKg3ilI7bakKi4k0cmaPcpKmTZ6yvtV',
        'clecky1a@accuweather.com', 'Catarina', 'Lecky', '5726876311', '944-572-2608', 1, 407);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (48, 'amcphail1b', 'bV8h4UIl2fvFASy1A2il3BZ3RL7I9qx9XevIKL2mdyJIoA00WmMQ5BLMu4yaLo3mTqjvw8MFkzay',
        'amcphail1b@hud.gov', 'Annmaria', 'McPhail', '3303060991', '241-235-5393', 1, 276);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (49, 'kcoupman1c', 'P78AUamJWtGJxex9fnwBrv98jkTEzWW6ppwTnzqon52GgiQknGN6X9tZJEpfOROwkTGqlVH19456',
        'kcoupman1c@1und1.de', 'Killie', 'Coupman', '7765908548', '592-198-9051', 2, 415);
insert into customers (id, username, password, email, first_name, last_name, nip, phone_number, company_id,
                       address_id)
values (50, 'abrammall1d', 'NODV1XWtnfkrhCqUfYzyQ9I6dUCCYHLsl66vW5mGRih49ktMfSD7ORXCqs1raXdKfVssgsIHna2k',
        'abrammall1d@studiopress.com', 'Andromache', 'Brammall', '5172703676', '226-968-8859', 2, 624);

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

INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (1, 1, 91.79);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (2, 1, 71.4);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (3, 1, 12.42);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (4, 1, 3.81);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (5, 1, 62.88);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (6, 1, 82.11);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (7, 1, 96.39);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (8, 1, 15.7);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (9, 1, 42.67);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (10, 1, 4.84);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (11, 1, 59.66);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (12, 1, 76.2);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (13, 1, 16.14);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (14, 1, 75.55);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (15, 1, 48.83);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (16, 1, 18.85);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (17, 1, 35.44);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (18, 1, 73.33);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (19, 1, 43.23);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (20, 1, 67.04);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (21, 1, 60.57);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (22, 1, 57.92);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (23, 1, 65.1);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (24, 1, 88.51);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (25, 1, 1.53);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (26, 1, 65.26);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (27, 1, 28.28);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (28, 1, 24.34);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (29, 1, 23.01);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (30, 1, 21.77);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (31, 1, 93.89);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (32, 1, 87.38);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (33, 1, 3.91);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (34, 1, 26.45);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (35, 1, 74.18);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (36, 1, 0.08);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (37, 1, 21.12);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (38, 1, 14.35);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (39, 1, 97.6);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (40, 1, 44.12);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (41, 1, 66.32);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (42, 1, 50.08);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (43, 1, 46.13);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (44, 1, 80.17);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (45, 1, 7.16);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (46, 1, 45.87);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (47, 1, 55.09);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (48, 1, 49.05);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (49, 1, 42.21);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (50, 1, 82.94);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (51, 1, 99.42);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (52, 1, 43.37);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (53, 1, 2.99);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (54, 1, 98.97);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (55, 1, 26.58);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (56, 1, 5.34);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (57, 1, 16.21);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (58, 1, 89.95);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (59, 1, 70.91);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (60, 1, 2.29);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (61, 1, 55.11);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (62, 1, 47.74);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (63, 1, 61.15);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (64, 1, 58.36);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (65, 1, 7.14);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (66, 1, 7.05);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (67, 1, 1.96);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (68, 1, 70.6);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (69, 1, 32.09);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (70, 1, 92.09);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (71, 1, 34.84);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (72, 1, 93.58);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (73, 1, 20.79);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (74, 1, 56.16);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (75, 1, 56.04);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (76, 1, 22.03);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (77, 1, 56.84);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (78, 1, 42.54);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (79, 1, 6.37);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (80, 1, 2.76);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (81, 1, 81.09);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (82, 1, 43.89);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (83, 1, 22.76);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (84, 1, 60.04);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (85, 1, 6.29);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (86, 1, 86.28);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (87, 1, 99.87);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (88, 1, 5.72);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (89, 1, 96.87);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (90, 1, 70.54);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (91, 1, 3.01);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (92, 1, 35.39);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (93, 1, 26.65);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (94, 1, 41.18);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (95, 1, 17.65);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (96, 1, 39.86);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (97, 1, 74.41);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (98, 1, 52.19);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (99, 1, 53.51);
INSERT INTO price_ranges (item_id, min_quantity, price)
VALUES (100, 1, 29.2);

INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Oct-25', 'RECEIVED', null, 19, 1, 826);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Jul-09', 'RECEIVED', null, 32, 1, 256);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Jan-08', 'RECEIVED', null, 35, 1, 535);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Apr-07', 'RECEIVED', 499.71, 10, 2, 244);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Feb-08', 'RECEIVED', null, 14, 10, 254);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Mar-31', 'RECEIVED', 22.28, 7, 5, 517);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Mar-23', 'RECEIVED', null, 24, 7, 457);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('19-Dec-22', 'RECEIVED', 179.03, 15, 2, 758);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Jul-31', 'RECEIVED', 683.65, 27, 3, 632);
INSERT INTO orders (date, status, shipping_cost, customer_id, assigned_employee_id, address_id)
VALUES ('20-Mar-03', 'RECEIVED', 307.24, 13, 1, 284);

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

