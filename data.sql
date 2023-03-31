CREATE TABLE client (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  age INTEGER NOT NULL,
  gender VARCHAR(6) NOT NULL,
  occupation VARCHAR(25) NOT NULL,
  nationality VARCHAR(25) NOT NULL
);

CREATE TABLE restaurant(
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  category VARCHAR(50) NOT NULL,
  city VARCHAR(50) NOT NULL,
  address VARCHAR(50) NOT NULL
);

CREATE TABLE dish (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  restaurant_id INTEGER NOT NULL REFERENCES restaurant,
  price INTEGER NOT NULL
);

CREATE TABLE visit(
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  client_id INTEGER NOT NULL REFERENCES client,
  restaurant_id INTEGER NOT NULL REFERENCES restaurant,
  dish_id INTEGER NOT NULL REFERENCES dish
);

-- DROP TABLE visit;
-- DROP TABLE dish;
-- DROP TABLE restaurant;
-- DROP TABLE client;