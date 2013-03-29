CREATE TABLE chef(
  id INTEGER PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  mentor VARCHAR(255)
);


INSERT INTO chef (id, fname, lname, mentor)
VALUES (NULL, 'Julia', 'Child', NULL),
       (NULL, 'Gordon', 'Ramsey', 1),
       (NULL, 'Homaru', 'Cantu', 2),
       (NULL 'Cookie', 'McFancypants', 2)
       (NULL, 'Adam', 'Zeisler', 3);


CREATE TABLE cheftenure(
  id INTEGER PRIMARY KEY,
  chef_id INTEGER,
  restaurant_id INTEGER NOT NULL,
  start_date TEXT,
  end_date TEXT,
  is_head_chef INTEGER
);

CREATE TABLE restaurant(
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL,,
  chef_id INTEGER,
  neighborhood VARCHAR(255),
  cuisine VARCHAR(255)
);

CREATE TABLE critic(
  id INTEGER PRIMARY KEY,
  screen_name VARCHAR(50) NOT NULL
);

CREATE TABLE restaurantreview(
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  critic_id INTEGER,
  score INTEGER,
  review_date TEXT,
  review TEXT 
);
