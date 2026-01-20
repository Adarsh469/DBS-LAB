
DROP TABLE prereq CASCADE CONSTRAINTS;
DROP TABLE time_slot CASCADE CONSTRAINTS;
DROP TABLE advisor CASCADE CONSTRAINTS;
DROP TABLE takes CASCADE CONSTRAINTS;
DROP TABLE student CASCADE CONSTRAINTS;
DROP TABLE teaches CASCADE CONSTRAINTS;
DROP TABLE section CASCADE CONSTRAINTS;
DROP TABLE instructor CASCADE CONSTRAINTS;
DROP TABLE course CASCADE CONSTRAINTS;
DROP TABLE department CASCADE CONSTRAINTS;
DROP TABLE classroom CASCADE CONSTRAINTS;

CREATE TABLE classroom (
    building      VARCHAR(15),
    room_number   VARCHAR(7),
    capacity      NUMERIC(4,0),
    PRIMARY KEY (building, room_number)
);

CREATE TABLE department (
    dept_name     VARCHAR(20),
    building      VARCHAR(15),
    budget        NUMERIC(12,2) CHECK (budget > 0),
    PRIMARY KEY (dept_name)
);

-- 3. Academic Catalog
CREATE TABLE course (
    course_id     VARCHAR(8),
    title         VARCHAR(50),
    dept_name     VARCHAR(20),
    credits       NUMERIC(2,0) CHECK (credits > 0),
    PRIMARY KEY (course_id),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

-- 4. Human Resources
CREATE TABLE instructor (
    ID            VARCHAR(5),
    name          VARCHAR(20) NOT NULL,
    dept_name     VARCHAR(20),
    salary        NUMERIC(8,2) CHECK (salary > 29000),
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

-- 5. Course Offerings (Sections)
CREATE TABLE section (
    course_id     VARCHAR(8),
    sec_id        VARCHAR(8),
    semester      VARCHAR(6) CHECK (semester IN ('Fall', 'Winter', 'Spring', 'Summer')),
    year          NUMERIC(4,0) CHECK (year > 1701 AND year < 2100),
    building      VARCHAR(15),
    room_number   VARCHAR(7),
    time_slot_id  VARCHAR(4),
    PRIMARY KEY (course_id, sec_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course ON DELETE CASCADE,
    FOREIGN KEY (building, room_number) REFERENCES classroom ON DELETE SET NULL
);

-- 6. Instructor Assignments
CREATE TABLE teaches (
    ID            VARCHAR(5),
    course_id     VARCHAR(8),
    sec_id        VARCHAR(8),
    semester      VARCHAR(6),
    year          NUMERIC(4,0),
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section ON DELETE CASCADE,
    FOREIGN KEY (ID) REFERENCES instructor ON DELETE CASCADE
);

-- 7. Students
CREATE TABLE student (
    ID            VARCHAR(5),
    name          VARCHAR(20) NOT NULL,
    dept_name     VARCHAR(20),
    tot_cred      NUMERIC(3,0) CHECK (tot_cred >= 0),
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

-- 8. Student Enrollment
CREATE TABLE takes (
    ID            VARCHAR(5),
    course_id     VARCHAR(8),
    sec_id        VARCHAR(8),
    semester      VARCHAR(6),
    year          NUMERIC(4,0),
    grade         VARCHAR(2),
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section ON DELETE CASCADE,
    FOREIGN KEY (ID) REFERENCES student ON DELETE CASCADE
);

-- 9. Mentorship
CREATE TABLE advisor (
    s_ID          VARCHAR(5),
    i_ID          VARCHAR(5),
    PRIMARY KEY (s_ID),
    FOREIGN KEY (i_ID) REFERENCES instructor (ID) ON DELETE SET NULL,
    FOREIGN KEY (s_ID) REFERENCES student (ID) ON DELETE CASCADE
);

-- 10. Scheduling
CREATE TABLE time_slot (
    time_slot_id  VARCHAR(4),
    day           VARCHAR(1),
    start_hr      NUMERIC(2) CHECK (start_hr >= 0 AND start_hr < 24),
    start_min     NUMERIC(2) CHECK (start_min >= 0 AND start_min < 60),
    end_hr        NUMERIC(2) CHECK (end_hr >= 0 AND end_hr < 24),
    end_min       NUMERIC(2) CHECK (end_min >= 0 AND end_min < 60),
    PRIMARY KEY (time_slot_id, day, start_hr, start_min)
);

-- 11. Course Requirements
CREATE TABLE prereq (
    course_id     VARCHAR(8),
    prereq_id     VARCHAR(8),
    PRIMARY KEY (course_id, prereq_id),
    FOREIGN KEY (course_id) REFERENCES course ON DELETE CASCADE,
    FOREIGN KEY (prereq_id) REFERENCES course
);

--Now u run smallrelations.sql file to get the database
--Qn1
SELECT course_id FROM section WHERE semester = 'Fall' AND year = 2009
UNION
SELECT course_id FROM section WHERE semester = 'Spring' AND year = 2010;

--Qn2
SELECT course_id FROM section WHERE semester = 'Fall' AND year = 2009
INTERSECT
SELECT course_id FROM section WHERE semester = 'Spring' AND year = 2010;

--Qn3
SELECT course_id FROM section WHERE semester = 'Fall' AND year = 2009
MINUS
SELECT course_id FROM section WHERE semester = 'Spring' AND year = 2010;

--Qn4
SELECT title FROM course 
WHERE course_id NOT IN (SELECT course_id FROM takes);

--Qn5
SELECT DISTINCT course_id FROM section 
WHERE semester = 'Fall' AND year = 2009 
AND course_id IN (SELECT course_id FROM section WHERE semester = 'Spring' AND year = 2010);

--Qn6
SELECT COUNT(DISTINCT ID) FROM takes 
WHERE (course_id, sec_id, semester, year) IN 
      (SELECT course_id, sec_id, semester, year FROM teaches WHERE ID = '10101');

--Qn7
SELECT DISTINCT course_id FROM section 
WHERE semester = 'Fall' AND year = 2009 
AND course_id NOT IN (SELECT course_id FROM section WHERE semester = 'Spring' AND year = 2010);

--Qn8
SELECT name FROM student 
WHERE name IN (SELECT name FROM instructor);

--Qn9
SELECT name FROM instructor 
WHERE salary > SOME (SELECT salary FROM instructor WHERE dept_name = 'Biology');

--Qn10
SELECT name FROM instructor 
WHERE salary > ALL (SELECT salary FROM instructor WHERE dept_name = 'Biology');

--Qn11
SELECT dept_name FROM instructor GROUP BY dept_name
HAVING AVG(salary) >= ALL (SELECT AVG(salary) FROM instructor GROUP BY dept_name);

--Qn12
SELECT dept_name FROM department 
WHERE budget < (SELECT AVG(salary) FROM instructor);

--Qn13
SELECT S.course_id FROM section S 
WHERE S.semester = 'Fall' AND S.year = 2009 
AND EXISTS (SELECT * FROM section T WHERE T.semester = 'Spring' AND T.year = 2010 AND S.course_id = T.course_id);

--Qn14
SELECT S.name FROM student S 
WHERE NOT EXISTS (
    (SELECT course_id FROM course WHERE dept_name = 'Biology')
    MINUS
    (SELECT T.course_id FROM takes T WHERE S.ID = T.ID)
);

--Qn15
SELECT title FROM course 
WHERE course_id IN (
    SELECT course_id FROM section WHERE year = 2009 
    GROUP BY course_id HAVING COUNT(*) <= 1
);

--Qn16
SELECT S.name FROM student S 
JOIN takes T ON S.ID = T.ID 
JOIN course C ON T.course_id = C.course_id 
WHERE C.dept_name = 'Comp. Sci.' 
GROUP BY S.ID, S.name HAVING COUNT(*) >= 2;

--Qn17
SELECT dept_name, avg_salary 
FROM (SELECT dept_name, AVG(salary) as avg_salary FROM instructor GROUP BY dept_name) 
WHERE avg_salary > 42000;

--Qn18
CREATE VIEW all_courses AS
SELECT s.course_id, s.sec_id, s.building, s.room_number 
FROM section s 
JOIN course c ON s.course_id = c.course_id 
WHERE c.dept_name = 'Physics' AND s.semester = 'Fall' AND s.year = 2009;

--Qn19
SELECT * FROM all_courses;

--Qn20
CREATE VIEW department_total_salary AS
SELECT dept_name, SUM(salary) as total_salary 
FROM instructor 
GROUP BY dept_name;