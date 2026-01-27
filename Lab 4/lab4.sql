
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

CREATE TABLE course (
    course_id     VARCHAR(8),
    title         VARCHAR(50),
    dept_name     VARCHAR(20),
    credits       NUMERIC(2,0) CHECK (credits > 0),
    PRIMARY KEY (course_id),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

CREATE TABLE instructor (
    ID            VARCHAR(5),
    name          VARCHAR(20) NOT NULL,
    dept_name     VARCHAR(20),
    salary        NUMERIC(8,2) CHECK (salary > 29000),
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

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

CREATE TABLE student (
    ID            VARCHAR(5),
    name          VARCHAR(20) NOT NULL,
    dept_name     VARCHAR(20),
    tot_cred      NUMERIC(3,0) CHECK (tot_cred >= 0),
    PRIMARY KEY (ID),
    FOREIGN KEY (dept_name) REFERENCES department ON DELETE SET NULL
);

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

CREATE TABLE advisor (
    s_ID          VARCHAR(5),
    i_ID          VARCHAR(5),
    PRIMARY KEY (s_ID),
    FOREIGN KEY (i_ID) REFERENCES instructor (ID) ON DELETE SET NULL,
    FOREIGN KEY (s_ID) REFERENCES student (ID) ON DELETE CASCADE
);

CREATE TABLE time_slot (
    time_slot_id  VARCHAR(4),
    day           VARCHAR(1),
    start_hr      NUMERIC(2) CHECK (start_hr >= 0 AND start_hr < 24),
    start_min     NUMERIC(2) CHECK (start_min >= 0 AND start_min < 60),
    end_hr        NUMERIC(2) CHECK (end_hr >= 0 AND end_hr < 24),
    end_min       NUMERIC(2) CHECK (end_min >= 0 AND end_min < 60),
    PRIMARY KEY (time_slot_id, day, start_hr, start_min)
);

CREATE TABLE prereq (
    course_id     VARCHAR(8),
    prereq_id     VARCHAR(8),
    PRIMARY KEY (course_id, prereq_id),
    FOREIGN KEY (course_id) REFERENCES course ON DELETE CASCADE,
    FOREIGN KEY (prereq_id) REFERENCES course
);

--Now u run smallrelations.sql file to get the database
--Qn 1
SELECT course_id, COUNT(ID) AS student_count
FROM takes
GROUP BY course_id;

--Qn 2
SELECT dept_name, COUNT(ID)
FROM student
GROUP BY dept_name
HAVING COUNT(ID) > 10;

--Qn 3
SELECT dept_name, COUNT(course_id) AS total_courses
FROM course
GROUP BY dept_name;

--Qn 4
SELECT dept_name, AVG(salary)
FROM instructor
GROUP BY dept_name
HAVING AVG(salary) > 42000;

--Qn 5
SELECT course_id, sec_id, COUNT(ID) AS enrollment
FROM takes
WHERE semester = 'Spring' AND year = 2009
GROUP BY course_id, sec_id;

--Qn 6
SELECT course.course_id, title, prereq_id
FROM course, prereq
WHERE course.course_id = prereq.course_id
ORDER BY course.course_id ASC;

--Qn 7
SELECT * FROM instructor
ORDER BY salary DESC;

--Qn 8
SELECT MAX(total_salary)
FROM (SELECT dept_name, SUM(salary) AS total_salary
      FROM instructor
      GROUP BY dept_name);

--Qn 9
SELECT dept_name, avg_sal
FROM (SELECT dept_name, AVG(salary) AS avg_sal
      FROM instructor
      GROUP BY dept_name)
WHERE avg_sal > 42000;

--Qn 10
SELECT course_id, sec_id
FROM (SELECT course_id, sec_id, COUNT(ID) AS enrl
      FROM takes
      WHERE semester = 'Spring' AND year = 2010
      GROUP BY course_id, sec_id)
WHERE enrl = (SELECT MAX(enrl) 
              FROM (SELECT COUNT(ID) AS enrl 
                    FROM takes 
                    WHERE semester = 'Spring' AND year = 2010 
                    GROUP BY course_id, sec_id));

-Qn 11
SELECT name 
FROM instructor i
WHERE NOT EXISTS (
    (SELECT ID FROM student WHERE dept_name = 'Comp. Sci.')
    MINUS
    (SELECT t.ID FROM takes t, teaches te 
     WHERE t.course_id = te.course_id AND t.sec_id = te.sec_id 
     AND t.semester = te.semester AND t.year = te.year 
     AND te.ID = i.ID)
);

--Qn 12
SELECT dept_name, avg_salary
FROM (SELECT dept_name, AVG(salary) AS avg_salary, COUNT(ID) AS inst_count
      FROM instructor
      GROUP BY dept_name)
WHERE avg_salary > 50000 AND inst_count > 5;

--Qn 13
WITH max_budget(value) AS 
    (SELECT MAX(budget) FROM department)
SELECT dept_name
FROM department, max_budget
WHERE department.budget = max_budget.value;

--Qn 14
WITH dept_total(dept_name, total_sal) AS
    (SELECT dept_name, SUM(salary) FROM instructor GROUP BY dept_name),
dept_total_avg(avg_sal) AS
    (SELECT AVG(total_sal) FROM dept_total)
SELECT dept_name
FROM dept_total, dept_total_avg
WHERE dept_total.total_sal > dept_total_avg.avg_sal;

--Qn 15
SAVEPOINT student_transfer;

UPDATE student
SET dept_name = 'IT'
WHERE dept_name = 'Comp. Sci.';

-- To undo: ROLLBACK TO student_transfer;
-- To save: COMMIT;

--Qn 16
SAVEPOINT salary_update;

UPDATE instructor
SET salary = CASE 
                WHEN salary > 100000 THEN salary * 1.03
                ELSE salary * 1.05
             END;

COMMIT;

--Qn 17

