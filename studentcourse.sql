-- ------------------------------
-- Data Definition Language (DDL)
-- ------------------------------

DROP DATABASE IF EXISTS studentcourse; -- Note the addition of IF EXISTS (see Additional SQL Topics)

CREATE DATABASE studentcourse;

USE studentcourse;

CREATE TABLE major (
	major VARCHAR(255),
	school VARCHAR(255),
	CONSTRAINT PK_major PRIMARY KEY (major)
	);

CREATE TABLE student (
	studentid INT,
	name VARCHAR(255),
	major VARCHAR(255),
	year INT,
	CONSTRAINT PK_student PRIMARY KEY (studentid),
	CONSTRAINT FK_student_to_major FOREIGN KEY (major) 			
		REFERENCES major(major)
	);

CREATE TABLE course (
	courseid INT,
	topic VARCHAR(255),
	title VARCHAR(255),
	CONSTRAINT PK_course PRIMARY KEY (courseid)
	);

CREATE TABLE takes (
	studentid INT,
	courseid INT,
	date date,
	CONSTRAINT PK_takes PRIMARY KEY (studentid, courseid),
	CONSTRAINT FK_takes_to_student FOREIGN KEY (studentid) 			
		REFERENCES student(studentid),
	CONSTRAINT FK_takes_to_course FOREIGN KEY (courseid) 			
		REFERENCES course(courseid)
	);

-- Note. The following commands are commented out and thus not run:

/*
ALTER TABLE course MODIFY COLUMN courseid VARCHAR(255); -- Note this will not run due to foreign key constraints
ALTER TABLE student MODIFY COLUMN year VARCHAR(255); -- This would work however

ALTER TABLE course ADD COLUMN credits INT;
ALTER TABLE course DROP COLUMN title;

TRUNCATE TABLE course;

DROP TABLE course;
DROP DATABASE studentcourse;
*/

-- -------------------------------------------------------------
-- Data Manipulation Language (DML) - INSERT, UPDATE, and DELETE
-- -------------------------------------------------------------
    
INSERT INTO major (major, school) VALUES ('COMM', 'Commerce');
INSERT INTO major (major, school) VALUES ('CS', 'Engineering');
INSERT INTO major (major, school) VALUES ('SE', 'Engineering');

INSERT INTO student VALUES (100, 'Lucy', 'COMM', 4);
INSERT INTO student VALUES (140, 'Brian', 'CS', 2);
INSERT INTO student VALUES (130, 'Lindsey', 'SE', 4);

INSERT INTO course VALUES (3200, 'RDBMS', 'Intro...');
INSERT INTO course VALUES (7450, 'Stats', 'Adv...');
INSERT INTO course VALUES (3600, 'Big Data', 'Intro...');
INSERT INTO course VALUES (3460, 'Finance', 'Intro...');
INSERT INTO course VALUES (4200, 'Global', 'Adv...');
INSERT INTO course VALUES (3100, 'Global', 'Intro...');

INSERT INTO takes VALUES (100, 3200, '2016-11-01');
INSERT INTO takes VALUES (100, 7450, '2016-11-01');
INSERT INTO takes VALUES (100, 4200, '2016-12-01');
INSERT INTO takes VALUES (140, 3600, '2016-12-01');
INSERT INTO takes VALUES (140, 3460, '2016-12-01');
INSERT INTO takes VALUES (140, 4200, '2016-01-01');
INSERT INTO takes VALUES (130, 3100, '2016-12-01');
INSERT INTO takes VALUES (130, 3600, '2016-12-01');
INSERT INTO takes VALUES (130, 3200, '2016-12-01');

-- Note. The following commands are commented out and thus not run:

-- UPDATE takes SET date = '2017-01-01' WHERE studentid = 140 AND courseid = 4200;
-- DELETE FROM takes WHERE studentid = 140 AND courseid = 3600;

-- ------------------------------------------------
-- Data Manipulation Language (DML) - SELECT Basics
-- ------------------------------------------------

SELECT * FROM student;

SELECT studentid, year FROM student;

SELECT year FROM student;

SELECT DISTINCT year FROM student;

SELECT studentid AS studentident, year FROM student;

SELECT studentid, name, year FROM student WHERE major = 'COMM' AND year > 2;

SELECT courseid, topic FROM course WHERE topic IN ('Global', 'RDBMS');

SELECT courseid, topic FROM course WHERE topic IN ('GLOBAL', 'RDBMS'); -- Note MySQL's IN is not case sensitive by default

SELECT COUNT(studentid) FROM student;

SELECT ROUND(AVG(year), 2) FROM student;

SELECT COUNT(DISTINCT year) FROM student;

SELECT * FROM takes;

SELECT studentid, COUNT(courseid) FROM takes 
GROUP BY studentid;

SELECT studentid, COUNT(courseid) FROM takes 
WHERE courseid != 3100 
GROUP BY studentid HAVING COUNT(courseid) > 2;

-- ----------------------------------------
-- Data Manipulation Language (DML) - Joins
-- ----------------------------------------

SELECT * FROM student JOIN major ON student.major = major.major;

SELECT * FROM student NATURAL JOIN major;

CREATE TABLE engmajor (
	major VARCHAR(255),
	school VARCHAR(255),
	CONSTRAINT PK_major PRIMARY KEY (major)
	);
    
INSERT INTO engmajor (major, school) VALUES ('CS', 'Engineering');
INSERT INTO engmajor (major, school) VALUES ('SE', 'Engineering');

SELECT * FROM student NATURAL JOIN engmajor;

CREATE TABLE students (
	studentid INT,
	name VARCHAR(255),
	major VARCHAR(255),
	year INT,
	CONSTRAINT PK_students PRIMARY KEY (studentid),
	CONSTRAINT FK_students_to_major FOREIGN KEY (major) 			
		REFERENCES major(major)
	);
    
INSERT INTO students VALUES (100, 'Lucy', 'COMM', 4);
INSERT INTO students VALUES (140, 'Brian', 'CS', 2);
INSERT INTO students VALUES (130, 'Lindsey', 'SE', 4);
INSERT INTO students VALUES (150, 'Tim', 'COMM', 3);

CREATE TABLE studentemp (
	studentident INT,
	hourlysalary INT,
	CONSTRAINT PK_studentemp PRIMARY KEY (studentident)
	);
    
INSERT INTO studentemp VALUES (150, 12);
INSERT INTO studentemp VALUES (130, 15);
INSERT INTO studentemp VALUES (190, 20);

SELECT * FROM students JOIN studentemp ON studentid = studentident;

SELECT * FROM students LEFT JOIN studentemp ON studentid = studentident;

SELECT * FROM students RIGHT JOIN studentemp ON studentid = studentident;

-- Note that the following is not available in MySQL:

-- SELECT * FROM students FULL JOIN studentemp ON studentid = studentident;

-- But it can be simulated using UNION ALL:

SELECT * FROM students LEFT JOIN studentemp ON studentid = studentident
UNION ALL
SELECT * FROM students RIGHT JOIN studentemp ON studentid = studentident
WHERE studentid IS NULL;

SELECT * FROM student NATURAL JOIN major NATURAL JOIN takes NATURAL JOIN course;

-- ------------------------------------------------
-- Data Manipulation Language (DML) - Set Operators
-- ------------------------------------------------

CREATE TABLE morestudent (
	studentid INT,
	name VARCHAR(255),
	major VARCHAR(255),
	year INT,
	CONSTRAINT PK_morestudent PRIMARY KEY (studentid, major),
	CONSTRAINT FK_morestudent_to_major FOREIGN KEY (major) 			
		REFERENCES major(major)
	);
    
INSERT INTO morestudent VALUES (150, 'Tim', 'COMM', 3);
INSERT INTO morestudent VALUES (140, 'Brian', 'CS', 2);
INSERT INTO morestudent VALUES (160, 'Will', 'COMM', 2);

SELECT * FROM student 
UNION 
SELECT * FROM morestudent;

-- Note that the following are not available in MySQL:

/*

SELECT * FROM student
EXCEPT
SELECT * FROM morestudent;

SELECT * FROM morestudent
EXCEPT
SELECT * FROM student;

SELECT * FROM student
INTERSECT
SELECT * FROM morestudent;

*/

-- But they can be simulated in various ways.

-- Simulating EXCEPT using IN:

SELECT * FROM student WHERE studentid NOT IN (SELECT studentid FROM morestudent);

SELECT * FROM morestudent WHERE studentid NOT IN (SELECT studentid FROM student);

-- Simulating INTERSECT using IN:

SELECT * FROM student WHERE studentid IN (SELECT studentid FROM morestudent);

-- ---------------------
-- Additional SQL Topics
-- ---------------------

SELECT * FROM student WHERE studentid IN (SELECT DISTINCT studentid FROM takes);

SELECT * FROM student AS s1, student AS s2;