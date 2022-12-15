/*
******************
Cody Bryan 
Final Project Database Generation 
******************
*/

grant all privileges on database finalproject_dfbrya19 to ehar;

-- this is the helper table that relates all of the yds climbing difficulty grades to numbers useful for math
DROP TABLE IF EXISTS "difficulty_numbers";
CREATE TABLE "difficulty_numbers" (
  "yds_grade" varchar,
  "numeric" serial,
  PRIMARY KEY ("yds_grade")
);

INSERT INTO difficulty_numbers values ('3rd', default);
INSERT INTO difficulty_numbers values ('4th', default);
INSERT INTO difficulty_numbers values ('Easy 5th', default);
INSERT INTO difficulty_numbers values ('5.0', default);
INSERT INTO difficulty_numbers values ('5.1', default);
INSERT INTO difficulty_numbers values ('5.2', default);
INSERT INTO difficulty_numbers values ('5.3', default);
INSERT INTO difficulty_numbers values ('5.4', default);
INSERT INTO difficulty_numbers values ('5.5', default);
INSERT INTO difficulty_numbers values ('5.6', default);
INSERT INTO difficulty_numbers values ('5.7', default);
INSERT INTO difficulty_numbers values ('5.7+', default);
INSERT INTO difficulty_numbers values ('5.8-', default);
INSERT INTO difficulty_numbers values ('5.8', default);
INSERT INTO difficulty_numbers values ('5.8+', default);
INSERT INTO difficulty_numbers values ('5.9-', default);
INSERT INTO difficulty_numbers values ('5.9', default);
INSERT INTO difficulty_numbers values ('5.9+', default);
INSERT INTO difficulty_numbers values ('5.10a', default);
INSERT INTO difficulty_numbers values ('5.10-', default);
INSERT INTO difficulty_numbers values ('5.10a/b', default);
INSERT INTO difficulty_numbers values ('5.10b', default);
INSERT INTO difficulty_numbers values ('5.10', default);
INSERT INTO difficulty_numbers values ('5.10b/c', default);
INSERT INTO difficulty_numbers values ('5.10c', default);
INSERT INTO difficulty_numbers values ('5.10+', default);
INSERT INTO difficulty_numbers values ('5.10c/d', default);
INSERT INTO difficulty_numbers values ('5.10d', default);
INSERT INTO difficulty_numbers values ('5.11a', default);
INSERT INTO difficulty_numbers values ('5.11-', default);
INSERT INTO difficulty_numbers values ('5.11a/b', default);
INSERT INTO difficulty_numbers values ('5.11b', default);
INSERT INTO difficulty_numbers values ('5.11', default);
INSERT INTO difficulty_numbers values ('5.11b/c', default);
INSERT INTO difficulty_numbers values ('5.11c', default);
INSERT INTO difficulty_numbers values ('5.11+', default);
INSERT INTO difficulty_numbers values ('5.11c/d', default);
INSERT INTO difficulty_numbers values ('5.11d', default);
INSERT INTO difficulty_numbers values ('5.12a', default);
INSERT INTO difficulty_numbers values ('5.12-', default);
INSERT INTO difficulty_numbers values ('5.12a/b', default);
INSERT INTO difficulty_numbers values ('5.12b', default);
INSERT INTO difficulty_numbers values ('5.12', default);
INSERT INTO difficulty_numbers values ('5.12b/c', default);
INSERT INTO difficulty_numbers values ('5.12c', default);
INSERT INTO difficulty_numbers values ('5.12+', default);
INSERT INTO difficulty_numbers values ('5.12c/d', default);
INSERT INTO difficulty_numbers values ('5.12d', default);
INSERT INTO difficulty_numbers values ('5.13a', default);
INSERT INTO difficulty_numbers values ('5.13-', default);
INSERT INTO difficulty_numbers values ('5.13a/b', default);
INSERT INTO difficulty_numbers values ('5.13b', default);
INSERT INTO difficulty_numbers values ('5.13', default);
INSERT INTO difficulty_numbers values ('5.13b/c', default);
INSERT INTO difficulty_numbers values ('5.13c', default);
INSERT INTO difficulty_numbers values ('5.13+', default);
INSERT INTO difficulty_numbers values ('5.13c/d', default);
INSERT INTO difficulty_numbers values ('5.13d', default);
INSERT INTO difficulty_numbers values ('5.14a', default);
INSERT INTO difficulty_numbers values ('5.14-', default);
INSERT INTO difficulty_numbers values ('5.14a/b', default);
INSERT INTO difficulty_numbers values ('5.14b', default);
INSERT INTO difficulty_numbers values ('5.14', default);
INSERT INTO difficulty_numbers values ('5.14b/c', default);
INSERT INTO difficulty_numbers values ('5.14c', default);
INSERT INTO difficulty_numbers values ('5.14+', default);
INSERT INTO difficulty_numbers values ('5.14c/d', default);
INSERT INTO difficulty_numbers values ('5.14d', default);
INSERT INTO difficulty_numbers values ('5.15a', default);
INSERT INTO difficulty_numbers values ('5.15-', default);
INSERT INTO difficulty_numbers values ('5.15a/b', default);
INSERT INTO difficulty_numbers values ('5.15b', default);
INSERT INTO difficulty_numbers values ('5.15', default);
INSERT INTO difficulty_numbers values ('5.15c', default);
INSERT INTO difficulty_numbers values ('5.15+', default);
INSERT INTO difficulty_numbers values ('5.15c/d', default);
INSERT INTO difficulty_numbers values ('5.15d', default);


-- helper table to relate danger grades to numbers
DROP TABLE IF EXISTS danger_numbers;
CREATE TABLE "danger_numbers" (
  "danger_grade" varchar,
  "numeric" serial,
  PRIMARY KEY ("danger_grade")
);
-- danger grades are below. 
-- G/PG is safe (easy to protect on lead)
-- PG13 is you could break an ankle or something if you fell becuase there are not many places to protection or alredly-there protection
-- R you could break a leg if you fell in a bad spot
-- X is would die if you fell at a bad spot 
INSERT INTO danger_numbers values ('G/PG', default);
INSERT INTO danger_numbers values ('PG13', default);
INSERT INTO danger_numbers values ('R', default);
INSERT INTO danger_numbers values ('X', default);

-- helper table to relate commitment grades to numbers
-- commitment grades can be though about how long a climb is grade I is few hours max, II is more like a half day, and goes up from there
DROP TABLE IF EXISTS commitment_numbers;
CREATE TABLE "commitment_numbers" (
  "commitment_grade" varchar,
  "numeric" serial,
  PRIMARY KEY ("commitment_grade")
);

INSERT INTO commitment_numbers values ('I', default);
INSERT INTO commitment_numbers values ('II', default);
INSERT INTO commitment_numbers values ('III', default);
INSERT INTO commitment_numbers values ('IV', default);
INSERT INTO commitment_numbers values ('V', default);
INSERT INTO commitment_numbers values ('VI', default);
INSERT INTO commitment_numbers values ('VII', default);


-- how to do drop tables that we are adding to - correct order
DROP TABLE IF EXISTS classics;
DROP TABLE IF EXISTS admins_areas;
DROP TABLE IF EXISTS ticks;
DROP TABLE IF EXISTS todos;
DROP TABLE IF EXISTS route_types;
DROP TABLE IF EXISTS difficulty_ratings; 
DROP TABLE IF EXISTS star_ratings;  
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS areas;  
DROP TABLE IF EXISTS users; 

-- users table
DROP TABLE IF EXISTS users; 
CREATE TABLE "users" (
  "id" varchar NOT NULL,
  "display_name" varchar NOT NULL,
  "start_date" date, --- https://www.mountainproject.com/user/7002067/orphaned-user - only case where null
  -- make sure age is above zero
  "age" int CHECK ("age" > 0),
  "other_interests" varchar,
  -- points must be above or equal zero 
  "points" int NOT NULL CHECK ("points" >= 0),
  PRIMARY KEY ("id")
);


-- areas table
DROP TABLE IF EXISTS areas; 
CREATE TABLE "areas" (
  "id" varchar NOT NULL,
  "name" varchar NOT NULL,
  "description" varchar,
  "getting_there" varchar,
  "parent_area_id" varchar,
  "elevation" int,
  "corodinates" varchar,
  "shared_by_id" varchar NOT NULL,
  "shared_on" date NOT NULL,
  "views" int NOT NULL CHECK ("views" >= 0),
  PRIMARY KEY ("id"),
  -- foreign keys are parent id which referecnes this table, and shared by id which referecnes users
  FOREIGN KEY ("parent_area_id") references "areas"("id"),
  FOREIGN KEY ("shared_by_id") references "users"("id")
);

-- drop nulls becuaes turns out this stuff can be null in like 1 out of 5000 areas
alter table areas alter shared_by_id drop not null;
alter table areas alter shared_on drop not null;


-- routes table
DROP TABLE IF EXISTS routes; 
CREATE TABLE "routes" (
  "id" varchar NOT NULL,
  "name" varchar NOT NULL,
  "area_id" varchar NOT NULL,
  "description" varchar,
  "location" varchar,
  "protection" varchar,
  "difficulty_rating" varchar NOT NULL,
  "danger_rating" varchar,
  "aid_rating" varchar,
  "commitmet_rating" varchar NOT NULL,
  "length" int CHECK ("length" >= 0),
  "pitches" int NOT NULL CHECK ("pitches" >= 1),
  "first_accent" varchar NOT NULL,
  "shared_by_id" varchar NOT NULL,
  "shared_on" date NOT NULL,
  "views" int NOT NULL,
  PRIMARY KEY ("id"),
  -- forgein keys are area reference, share_by refences, and danger and dificluty rating tables
  -- which basically makes it so I do need to do a bunch of checks to make sure the grade is correct 
  FOREIGN KEY ("area_id") references "areas"("id"),
  FOREIGN KEY ("shared_by_id") references "users"("id"),
  FOREIGN KEY ("danger_rating") references "danger_numbers"("danger_grade"),
  FOREIGN KEY ("difficulty_rating") references "difficulty_numbers"("yds_grade")
);

-- star ratings table, row is user giving a climb a certain star rating
DROP TABLE IF EXISTS star_ratings;  
CREATE TABLE "star_ratings" (
  "user_id" varchar NOT NULL,
  "route_id" varchar NOT NULL,
  -- needs to be in this range
  "star_rating" int NOT NULL CHECK ("star_rating" >= 0 and "star_rating" <= 4),
  PRIMARY KEY ("user_id", "route_id"),
  FOREIGN KEY("user_id") references "users"("id"),
  FOREIGN KEY("route_id") references "routes"("id")
);

-- diffilucty ratings table
DROP TABLE IF EXISTS difficulty_ratings; 
CREATE TABLE "difficulty_ratings" (
  "user_id" varchar NOT NULL,
  "route_id" varchar NOT NULL,
  "difficulty_rating" varchar NOT NULL,
  "danger_rating" varchar,
  "aid_rating" varchar,
  PRIMARY KEY ("user_id", "route_id"),
  FOREIGN KEY ("user_id") references "users"("id"),
  FOREIGN KEY ("route_id") references "routes"("id"),
  -- to make sure the ratings is valid
  FOREIGN KEY ("danger_rating") references "danger_numbers"("danger_grade"),
  FOREIGN KEY ("difficulty_rating") references "difficulty_numbers"("yds_grade")
);

-- route types for a given route
DROP TABLE IF EXISTS route_types;   
CREATE TABLE "route_types" (
  "route_id" varchar NOT NULL,
  "type" varchar NOT NULL,
  PRIMARY KEY ("route_id", "type"),
  FOREIGN KEY ("route_id") references "routes"("id")
);

-- todos 
DROP TABLE IF EXISTS todos;  
CREATE TABLE "todos" (
  "user_id" varchar NOT NULL,
  "route_id" varchar NOT NULL,
  PRIMARY KEY ("user_id", "route_id"),
  FOREIGN KEY ("user_id") references "users"("id"),
  FOREIGN KEY ("route_id") references "routes"("id")
);

-- ticks - only one I couldn't find a key for becuase could be two private (no user) ticks on a climb in the same day
-- or other combos that would lead to duplicates
DROP TABLE IF EXISTS ticks; 
CREATE TABLE "ticks" (
  "id" serial NOT NULL,
  "user_id" varchar, -- private ticks so can be null
  "route_id" varchar NOT NULL,
  "date" date,
  "pitches" int,
  "style" varchar CONSTRAINT style_check CHECK ("style" in ('Solo', 'TR', 'Follow', 'Lead')),
  "secondary_style" varchar CONSTRAINT secondary_style_check CHECK ("secondary_style" in ('Onsight', 'Flash', 'Redpoint', 'Pinkpoint', 'Fell/Hung')),
  "notes" varchar,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("user_id") references "users"("id"),
  FOREIGN KEY ("route_id") references "routes"("id")
);

-- admins areas table 
DROP TABLE IF EXISTS admins_areas; 
CREATE TABLE "admins_areas" (
  "user_id" varchar,
  "area_id" varchar,
  PRIMARY KEY ("user_id", "area_id"),
  FOREIGN KEY ("user_id") references "users"("id"),
  FOREIGN KEY ("area_id") references "areas"("id")
);

-- classics 
DROP TABLE IF EXISTS classics; 
CREATE TABLE "classics" (
  "route_id" varchar,
  "area_id" varchar,
  PRIMARY KEY ("route_id", "area_id"),
  FOREIGN KEY ("route_id") references "routes"("id"),
  FOREIGN KEY ("area_id") references "areas"("id")
);
