/* 
	Angelica Froio, Amaan Gadatia, Vicky Weng
	CSC 315-02: build_db.sql for Phase V(a)
	Professor DeGood
	4/8/24

*/

-- drops tables of the following names, if they existed beforehand
DROP VIEW time_til_vax;
DROP VIEW ages;
DROP VIEW vaccines;
DROP VIEW weights;
DROP VIEW weight_ages;
DROP TABLE ACTIVITY;
DROP TABLE TRAIT;
DROP TABLE NOTE;
DROP TABLE EVENTS;
DROP TABLE ANIMAL;

CREATE TABLE ANIMAL (
	-- Animal_id INT PRIMARY KEY,
	-- Dob_date TIMESTAMP,
	-- animal_group text,
	-- Status_current VARCHAR(50),
	-- Tag VARCHAR(50),
	-- Sex VARCHAR(10),
	-- Color VARCHAR(50),
	-- Breed VARCHAR(50),
	-- Type VARCHAR(50),

	animal_id INTEGER PRIMARY KEY,
	sex VARCHAR(20) NOT NULL DEFAULT '',
	dob TIMESTAMP,
	breed VARCHAR(20) NOT NULL DEFAULT '',
	colour VARCHAR(20) NOT NULL DEFAULT '',
	status_current VARCHAR(20) NOT NULL DEFAULT '',
	status_date TIMESTAMP,
	overall_adg VARCHAR(20) NOT NULL DEFAULT '',
	current_adg VARCHAR(20) NOT NULL DEFAULT '',
	animal_group VARCHAR(20) NOT NULL DEFAULT '',  
	sex_date TIMESTAMP, 
	breed_date TIMESTAMP,
	dob_date TIMESTAMP
);

CREATE TABLE EVENTS (
	picklistvalue_id INTEGER PRIMARY KEY,
	picklist_id INTEGER,
	value_txt VARCHAR(30)
);

CREATE TABLE NOTE (
	animal_id INTEGER NOT NULL, 
	created TIMESTAMP, 
	note VARCHAR(30) NOT NULL,
	session_id INTEGER NOT NULL, 
	PRIMARY KEY (animal_id, created),
	FOREIGN KEY (animal_id) REFERENCES ANIMAL(animal_id)
);

CREATE TABLE TRAIT (
	Session_id INT NOT NULL,
	animal_id INTEGER NOT NULL,
	trait_code INTEGER NOT NULL, --CHANGED FROM VARCHAR
	Alpha_value VARCHAR(20) NOT NULL DEFAULT '', -- CHANGED FROM INT
	Alpha_units VARCHAR(10) NOT NULL DEFAULT '', --from int
	When_measured TIMESTAMP NOT NULL,
	PRIMARY KEY (session_id, animal_id, trait_code, when_measured),
	FOREIGN KEY (animal_id) REFERENCES ANIMAL(animal_id),
	FOREIGN KEY (trait_code) REFERENCES EVENTS(picklistvalue_id)
);

CREATE TABLE ACTIVITY (
	Session_id INT NOT NULL,
	Animal_id INT NOT NULL,
	activity_code INT NOT NULL, -- CHANGED FROM VARCHAR
	When_measured TIMESTAMP NOT NULL,
	PRIMARY KEY (session_id, animal_id, activity_code, when_measured),
	FOREIGN KEY (activity_code) REFERENCES EVENTS(picklistvalue_id)
);

-- Changed a few attribute names in csv files because they seemed to be reserved
-- words in SQL and I wanted to be safe. eg. 'status' in Animal to 'status_current'


-- creating temporary tables for which to extract certain columns from per base table
CREATE TEMPORARY TABLE T (
	animal_id integer,
	lrid integer NOT NULL default 0,
	tag varchar(16) NOT NULL default '',
	rfid varchar(15) NOT NULL default '',
	nlis varchar(16) NOT NULL default '',
	is_new integer NOT NULL default 1,
	draft varchar(20) NOT NULL default '',
	sex varchar(20) NOT NULL default '',
	dob timestamp,
	sire varchar(16) NOT NULL default '',
	dam varchar(16) NOT NULL default '',
	breed varchar(20) NOT NULL default '',
	colour varchar(20) NOT NULL default '',
	weaned integer NOT NULL default 0 ,
	prev_tag varchar(10) NOT NULL default '',
	prev_pic varchar(20) NOT NULL default '',
	note varchar(30) NOT NULL default '',
	note_date timestamp,
	is_exported integer NOT NULL default 0,
	is_history integer NOT NULL default 0,
	is_deleted integer NOT NULL default 0,
	tag_sorter varchar(48) NOT NULL default '',
	donordam varchar(16) NOT NULL default '',
	whp timestamp,
	esi timestamp,
	status_current varchar(20) NOT NULL default '',
	status_date timestamp,
	overall_adg varchar(20) NOT NULL default '',
	current_adg varchar(20) NOT NULL default '',
	last_weight varchar(20) NOT NULL default '',
	last_weight_date timestamp,
	selected integer default 0,
	animal_group varchar(20) NOT NULL default '',
	current_farm varchar(20) NOT NULL default '',
	current_property varchar(20) NOT NULL default '',
	current_area varchar(20) NOT NULL default '',
	current_farm_date timestamp,
	current_property_date timestamp,
	current_area_date timestamp,
	animal_group_date timestamp,
	sex_date timestamp,
	breed_date timestamp,
	dob_date timestamp,
	colour_date timestamp,
	prev_pic_date timestamp,
	sire_date timestamp,
	dam_date timestamp,
	donordam_date timestamp,
	prev_tag_date timestamp,
	tag_date timestamp,
	rfid_date timestamp,
	nlis_date timestamp,
	modified timestamp,
	full_rfid varchar(16) default '',
	full_rfid_date timestamp);

\copy T FROM 'Animal.csv' WITH DELIMITER ',' CSV HEADER;

CREATE TEMPORARY TABLE U (
	picklistvalue_id INTEGER, 
	picklist_id INTEGER, 
	value_txt VARCHAR(30));

\copy U FROM 'PicklistValue.csv' WITH DELIMITER ',' CSV HEADER;

CREATE TEMPORARY TABLE V (
	animal_id integer NOT NULL,
	created timestamp,
	note varchar(30) NOT NULL,
	session_id integer NOT NULL,
	is_deleted integer default 0,
	is_alert integer default 0);

\copy V FROM 'Note.csv' WITH DELIMITER ',' CSV HEADER;

CREATE TEMPORARY TABLE W (
	session_id integer NOT NULL,
	animal_id integer NOT NULL,
	trait_code integer NOT NULL,
	alpha_value varchar(20) NOT NULL default '',
	alpha_units varchar(10) NOT NULL default '',
	when_measured timestamp NOT NULL,
	latestForSessionAnimal integer default 1,
	latestForAnimal integer default 1,
	is_history integer NOT NULL default 0,
	is_exported integer NOT NULL default 0,
	is_deleted integer default 0);

\copy W FROM 'SessionAnimalTrait.csv' WITH DELIMITER ',' CSV HEADER;

CREATE TEMPORARY TABLE X (
	session_id integer NOT NULL,
	animal_id integer NOT NULL,
	activity_code integer NOT NULL,
	when_measured timestamp NOT NULL,
	latestForSessionAnimal integer default 1,
	latestForAnimal integer default 1,
	is_history integer NOT NULL default 0,
	is_exported integer NOT NULL default 0,
	is_deleted integer default 0);

\copy X FROM 'SessionAnimalActivity.csv' WITH DELIMITER ',' CSV HEADER;

-- insert selected columns for each temporary table into their respective base tables
INSERT INTO ANIMAL (animal_id, sex, dob, breed, colour, status_current, status_date, overall_adg, current_adg, animal_group, sex_date, breed_date, dob_date)
SELECT animal_id, sex, dob, breed, colour, status_current, status_date, overall_adg, current_adg, animal_group, sex_date, breed_date, dob_date
FROM T;

INSERT INTO EVENTS (picklistvalue_id, picklist_id, value_txt)
SELECT picklistvalue_id, picklist_id, value_txt
FROM U;

INSERT INTO NOTE (animal_id, created, note, session_id)
SELECT animal_id, created, note, session_id
FROM V;

INSERT INTO TRAIT (session_id, animal_id, trait_code, alpha_value, alpha_units, when_measured)
SELECT session_id, animal_id, trait_code, alpha_value, alpha_units, when_measured
FROM W;

INSERT INTO ACTIVITY (session_id, animal_id, activity_code, when_measured) 
SELECT session_id, animal_id, activity_code, when_measured 
FROM X;

-- drop the temporary tables
DROP TABLE T;
DROP TABLE U;
DROP TABLE V;
DROP TABLE W;
DROP TABLE X; 

--create views
CREATE OR REPLACE VIEW weights
AS SELECT T.animal_id, T.Trait_code, T.Alpha_value, T.when_measured, T.session_id
	FROM Trait T, Animal A
	WHERE T.Trait_code IN (53, 381, 357, 952, 369, 393, 405, 436, 448, 963, 970, 1018)
		AND T.animal_id = A.animal_id;


CREATE VIEW vaccines
AS SELECT E.picklistvalue_id, E.value_txt
	FROM Events E
	WHERE E.picklistvalue_id IN (49, 708, 737, 791, 754, 796, 1111, 1104, 1203, 1215, 2144, 2147);

-- CREATE VIEW active_goats
-- AS SELECT A.animal_id, A.status_current
-- 	FROM Animal A 
-- 	WHERE 


CREATE VIEW ages
AS SELECT CAST(EXTRACT(DAYS FROM (NOW()::timestamp - A.dob))/365 AS INT) AS goat_age, A.animal_id
	FROM Animal A
	WHERE A.status_current = 'Current';

CREATE VIEW weight_ages
AS SELECT A.animal_id, A.dob, W.alpha_value, CAST(EXTRACT(DAYS FROM (W.when_measured - A.dob)) AS INT) AS age_at_measure, W.when_measured
	FROM weights W, Animal A
	WHERE A.animal_id = W.animal_id;

-- SELECT A.animal_id, W.alpha_value, W.when_measured, C.age_at_measure 
-- 	FROM Animal A, weights W, weight_ages C 
-- 	WHERE A.animal_group = '1st BRD GRP'
-- 		AND A.animal_id = W.animal_id 
-- 		AND W.animal_id = C.animal_id 
-- 		AND W.when_measured = C.when_measured;

-- was trying to alter view so that if goat was dead or sold, age would be -1.
-- CREATE OR REPLACE VIEW ages 
-- AS SELECT (case when A.goat_age = 0.0 then A.goat_age = -1.0 end) as goat_age
-- 	FROM ages A; 


CREATE OR REPLACE VIEW time_til_vax
AS SELECT A.animal_id, EXTRACT(DAYS FROM((B.when_measured - A.dob))) AS vax_time, 
                B.when_measured, V.picklistvalue_id
    FROM Animal A, Activity B, vaccines V
    WHERE B.activity_code = V.picklistvalue_id
        AND B.animal_id = A.animal_id;
