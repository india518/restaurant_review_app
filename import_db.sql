CREATE TABLE chef(
  id INTEGER PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  mentor_id INTEGER
);


INSERT INTO chef (id, first_name, last_name, mentor_id)
VALUES (NULL, 'Julia', 'Child', NULL),
       (NULL, 'Gordon', 'Ramsey', 1),
       (NULL, 'Homaru', 'Cantu', 2),
       (NULL, 'Cookie', 'McFancypants', 2),
       (NULL, 'Adam', 'Zeisler', 3);


CREATE TABLE restaurant(
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  chef_id INTEGER,
  neighborhood VARCHAR(255),
  cuisine VARCHAR(255)
);

INSERT INTO restaurant (id, name ,chef_id, neighborhood, cuisine)
VALUES (NULL, 'PBS Studio', 1, 'PBS', 'French'),
       (NULL, 'Naglee Park Garage', 4, 'Naglee Park', 'American'),
       (NULL, 'Moto', 3, 'Downtown', 'Molecular Gastronomy'),
	   (NULL, 'Otom', 5, 'Downtown', 'Molecular Gastronomy'),
       (NULL, 'BurgerJoint', 4, 'Downtown', 'American'),
	   (NULL, 'FoodNetwork', 6, 'TV Land', 'British');

CREATE TABLE cheftenure(
  id INTEGER PRIMARY KEY,
  chef_id INTEGER,
  restaurant_id INTEGER NOT NULL,
  start_date TEXT,
  end_date TEXT,
  is_head_chef INTEGER
);

-- Reminder to self:
-- SELECT start_date FROM cheftenure WHERE start_date <= date('2005-09-11')
-- returns all start_dates before or on that date!

INSERT INTO cheftenure (id, chef_id, restaurant_id, start_date, end_date, is_head_chef)
VALUES (NULL, 1, 1, '1956-12-12', '1990-06-21', 1),
       (NULL, 4, 5, '2001-07-14', '2009-02-28', 0),
       (NULL, 4, 2, '2009-03-21', '2013-03-28', 1),
       (NULL, 2, 6, '2000-01-01', '2012-09-17', 1),
       (NULL, 3, 3, '2004-02-11', '2009-09-11', 1),
	   (NULL, 5, 3, '2007-03-08', '2009-09-11', 0);

CREATE TABLE critic(
  id INTEGER PRIMARY KEY,
  screen_name VARCHAR(50) NOT NULL
);

INSERT INTO critic (id, screen_name)
VALUES (NULL, 'food_judge'),
       (NULL, 'live_to_eat'),
       (NULL, 'feed_mee'),
       (NULL, 'yumm_yumm');

CREATE TABLE restaurantreview(
  id INTEGER PRIMARY KEY,
  restaurant_id INTEGER,
  critic_id INTEGER,
  score INTEGER,
  review_date TEXT,
  review TEXT 
);

INSERT INTO restaurantreview (id, restaurant_id, critic_id, score, review_date, review)
VALUES (NULL, 3, 1, 15, '2005-09-15', 'Slow service, but pretty good overall'),
       (NULL, 3, 4, 19, '2009-07-24', 'Awesome sauce!'),
       (NULL, 5, 1, 3, '2012-10-21', 'This place sucks'),
       (NULL, 6, 3, 13, '2008-08-08', 'Chef here is scary and loud!'),
       (NULL, 2, 2, 17, '2010-04-21', 'Guy Fieri ate here!'),
	   (NULL, 2, 1, 14, '2013-01-16', 'Too expensive');
