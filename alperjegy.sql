
CREATE TABLE users (
    user_id int PRIMARY KEY AUTO_INCREMENT,
    username varchar(15) UNIQUE,
    password binary(32),
    email varchar(40) UNIQUE,
    first_name varchar(25),
    last_name varchar(25),
    gender varchar(25),
    birthDate date,	
    country_code smallint,
    phone_number int,
    country varchar(25),
    state varchar(25),
    city varchar(25),
    zip_code varchar(10),
    address1 varchar(40),
    address2 varchar(40),
    registerDate timestamp DEFAULT CURRENT_TIMESTAMP,
    params varchar(100)
);


CREATE TABLE cities (
  city_name VARCHAR(30) PRIMARY KEY
);

CREATE TABLE line_types (
    line_type varchar(30) PRIMARY KEY
);


CREATE TABLE companies (
    line_company varchar(30) PRIMARY KEY
);


CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    amount INT DEFAULT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE ticket_types (
  ticketType_id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_type VARCHAR(30),
  city VARCHAR(30),
  price INT,
  expiration_time TIME,
  FOREIGN KEY (city) REFERENCES cities(city_name)
);

CREATE TABLE tickets (
    ticket_id BINARY(16) PRIMARY KEY,
    transaction_id INT, 
    ticketType_id INT,
    valid_date TIMESTAMP NULL,
    expiry_date TIMESTAMP NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (ticketType_id) REFERENCES ticket_types(ticketType_id)
);

CREATE TABLE transport_lines (
    line_id int,
    ticketType_id INT,
    line_type varchar(30),
    line_company varchar(30), 
    departure_time TIMESTAMP NULL,
    arrival_time TIMESTAMP NULL,
    CONSTRAINT line_identity PRIMARY KEY (line_id, ticketType_id),
    FOREIGN KEY (ticketType_id) REFERENCES ticket_types(ticketType_id),
    FOREIGN KEY (line_type) REFERENCES line_types(line_type),
    FOREIGN KEY (line_company) REFERENCES companies(line_company)
);
