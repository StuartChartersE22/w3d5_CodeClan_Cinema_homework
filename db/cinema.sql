DROP TABLE IF EXISTS tickets;
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

CREATE TABLE tickets(
  id SERIAL4 PRIMARY KEY,
  customer_id INT4 REFERENCES customers(id),
  film_id INT4 REFERENCES films(id)
);
