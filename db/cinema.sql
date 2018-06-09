DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS screenings;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS films;

CREATE TABLE customers(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(255),
  wallet INT2
);

CREATE TABLE films(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(255),
  price INT2
);

CREATE TABLE screenings(
  id SERIAL4 PRIMARY KEY,
  film_id INT4 REFERENCES films(id) NOT NULL,
  show_time TIME(0),
  capacity INT2
);

CREATE TABLE tickets(
  id SERIAL4 PRIMARY KEY,
  customer_id INT4 REFERENCES customers(id) NOT NULL,
  screening_id INT4 REFERENCES screenings(id) NOT NULL
);
