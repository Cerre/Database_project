
-- Delete the tables if they exist.
-- Disable foreign key checks, so the tables can
-- be dropped in arbitrary order.
PRAGMA foreign_keys=OFF;
DROP TABLE IF EXISTS cookies;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS ingredient_transtitions;
DROP TABLE IF EXISTS pallets;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS order_specification;

PRAGMA foreign_keys=ON;

CREATE TABLE cookies(
	cookie_name		TEXT,
	PRIMARY KEY (cookie_name)
);

CREATE TABLE recipes(
	amount				INT,
	cookie_name 		TEXT,
	ingredient_name 	TEXT,
	PRIMARY KEY (cookie_name, ingredient_name),
	FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name),
	FOREIGN KEY (ingredient_name) REFERENCES ingredients(ingredient_name)
);

CREATE TABLE ingredients(
	ingredient_name 	TEXT,
	unit 				TEXT,
	PRIMARY KEY (ingredient_name)
);

CREATE TABLE ingredient_transtitions(
	quantity 			INT,
	transfer_date		DATE,
	ingredient_name 	TEXT # Ska den ha en key? i så fall kanske det blir alla tre? f
);


CREATE TABLE pallets(
	bar_code		TEXT DEFAULT (lower(hex(randomblob(16)))),
	prod_date 		DATE DEFAULT GETDATE(), # Crax är det en befintilig funktion? finns det gettime också?
	prod_time 		TIME DEFAULT GETTIME(),
	state 			TEXT DEFAULT "freezer",		
	blocked			BIT DEFAULT 0,
	delivery_date	DATE,
	delivery_time 	TIME,
	cookie_name		TEXT,
	order_id 		INT DEFAULT NULL, 
	PRIMARY KEY (bar_code),
	FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name),
	FOREIGN KEY (orders) REFERENCES cookies(order_id)
);


CREATE TABLE orders(
	order_date		DATE,
	order_id		INT,
	wanted_date		DATE,
	customer_name 	TEXT,
	PRIMARY KEY (order_id),
	FOREIGN KEY (customer_name) REFERENCES customers(customer_name)
);

CREATE TABLE customers(
	customer_name 	TEXT,
	address 		TEXT,
	PRIMARY KEY (customer_name)
);

CREATE TABLE order_specification(
	cookie_name 		TEXT,
	order_id 			INT,
	quantity			INT, 
	PRIMARY KEY (cookie_name, order_id)
	FOREIGN KEY (cookie_name) REFERENCES cookies(cookie_name),
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);




#LÅTER DESSAA VA HÄR SÅLÄNGE
/*CREATE TRIGGER update_seats BEFORE INSERT ON tickets
BEGIN
	 if performances.remainingSeats < 1
	 	 -->"Can't buy ticket"
	 else
	 	--"buy the ticket"
	

CREATE TRIGGER default_seats AFTER INSERT ON performances
BEGIN
	UPDATE performances
	SET remainingSeats = (SELECT capacity FROM theaters WHERE theaters.name = performances.theater);
END;*/



INSERT
INTO   customers(customer_name, address)
VALUES ('Finkakor AB', 'Helsingborg'),
	   ('Småbröd AB', 'Malmö'),
	   ('Kaffebröd AB', 'Landskrona'),
	   ('Bjudkakor AB', 'Ystad'),
	   ('Kalaskakor AB', 'Trelleborg'),
	   ('Partykakor AB', 'Kristianstad'),
	   ('Gästkakor AB', 'Hässleholm'),
	   ('Skånekakor AB', 'Perstorp');

INSERT
INTO   cookies(cookie_name)
VALUES ('Nut ring'),
	   ('Nut cookie'),
	   ('Amneris'),
	   ('Tango'),
	   ('Almond delight'),
	   ('Berliner');


INSERT
INTO 	ingredients(ingredient_name, quantity, unit)
VALUES 	('Flour', 100 000, 'g'),
		('Butter', 100 000, 'g'),
		('Icing sugar', 100 000, 'g'),
		('Roasted chopped nuts', 100 000, 'g'),
		('Fine-ground nuts', 100 000, 'g'),
		('Ground, roasted nuts', 100 000, 'g'),
		('Bread crumbs', 100 000, 'g'),
		('Sugar', 100 000, 'g'),
		('Egg whites', 100 000, 'ml'),
		('Chocolate', 100 000, 'g'),
		('Marzipan', 100 000, 'g'),
		('Eggs', 100 000, 'g'),
		('Potato starch', 100 000, 'g'),
		('Wheat flour', 100 000, 'g'),
		('Sodium bicarbonat', 100 000, 'g'),
		('Vanilla', 100 000, 'g'),
		('Chopped almonds', 100 000, 'g'),
		('Cinnamon', 100 000, 'g'),
		('Vanilla sugar', 100 000, 'g'),

INSERT
INTO	recipes(cookie_name, ingredient_name, quantity)
VALUES 	('Nut ring', 'Flour', 450),
		('Nut ring', 'Butter', 450),
		('Nut ring', 'Icing sugar', 190),
		('Nut ring', 'Roasted, chopped nuts', 225),
		('Nut cookie', 'Fine-ground nuts', 750),
		('Nut cookie', 'Ground, roasted nuts', 625),
		('Nut cookie', 'Bread crumbs', 125),
		('Nut cookie', 'Sugar', 375),
		('Nut cookie', 'Egg whites', 350),
		('Nut cookie', 'Chocolate', 50),
		('Amneris', 'Marzipan', 750),
		('Amneris', 'Butter', 250),
		('Amneris', 'Eggs', 250),
		('Amneris', 'Potato starch', 25),
		('Amneris', 'Wheat flour', 25),
		('Tango', 'Butter', 200),
		('Tango', 'Sugar', 250),
		('Tango', 'Flour', 300),
		('Tango', 'Sodium bicarbonat', 4),
		('Tango', 'Vanilla', 2),
		('Almond delight', 'Butter', 400),
		('Almond delight', 'Sugar', 270),
		('Almond delight', 'Chopped almonds', 279),
		('Almond delight', 'Flour', 400),
		('Almond delight', 'Cinnamon', 10),
		('Berliner', 'Flour', 350),
		('Berliner', 'Butter', 250),
		('Berliner', 'Icing sugar', 100),
		('Berliner', 'Eggs', 50),
		('Berliner', 'Vanilla sugar', 5),
		('Berliner', 'Chocolate', 60),














