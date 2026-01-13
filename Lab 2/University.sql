CREATE TABLE Department (
    dept_name VARCHAR2(20) PRIMARY KEY,
    building VARCHAR2(20),
    budget NUMBER(12, 2) CHECK (budget > 0)
);

CREATE TABLE Student (
    ID VARCHAR2(5) PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    dept_name VARCHAR2(20),
    tot_cred NUMBER(3, 0) DEFAULT 0,
    CONSTRAINT student_dept_fk FOREIGN KEY (dept_name) REFERENCES Department(dept_name)
);

CREATE TABLE Instructor (
    ID VARCHAR2(5) PRIMARY KEY,
    name VARCHAR2(20) NOT NULL,
    dept_name VARCHAR2(20),
    salary NUMBER(8, 2),
    CONSTRAINT instructor_dept_fk FOREIGN KEY (dept_name) REFERENCES Department(dept_name)
);

CREATE TABLE Course (
    course_id VARCHAR2(8) PRIMARY KEY,
    title VARCHAR2(50),
    dept_name VARCHAR2(20),
    credits NUMBER(2, 0) CHECK (credits > 0),
    CONSTRAINT course_dept_fk FOREIGN KEY (dept_name) REFERENCES Department(dept_name)
);

CREATE TABLE Section (
    course_id VARCHAR2(8),
    sec_id VARCHAR2(8),
    semester VARCHAR2(6),
    year NUMBER(4, 0),
    building VARCHAR2(20),
    room_number VARCHAR2(7),
    time_slot_id VARCHAR2(4),
    PRIMARY KEY (course_id, sec_id, semester, year),
    CONSTRAINT section_course_fk FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE
);

CREATE TABLE Takes (
    ID VARCHAR2(5),
    course_id VARCHAR2(8),
    sec_id VARCHAR2(8),
    semester VARCHAR2(6),
    year NUMBER(4, 0),
    grade VARCHAR2(2),
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    CONSTRAINT takes_student_fk FOREIGN KEY (ID) REFERENCES Student(ID) ON DELETE CASCADE
);

CREATE TABLE Teaches (
    ID VARCHAR2(5),
    course_id VARCHAR2(8),
    sec_id VARCHAR2(8),
    semester VARCHAR2(6),
    year NUMBER(4, 0),
    PRIMARY KEY (ID, course_id, sec_id, semester, year),
    CONSTRAINT teaches_instructor_fk FOREIGN KEY (ID) REFERENCES Instructor(ID)
);

CREATE TABLE Employee (
    emp_id NUMBER PRIMARY KEY,
    name VARCHAR2(20),
    DOB DATE
);

INSERT INTO Department VALUES ('CSE', 'Taylor', 100000);
INSERT INTO Department VALUES ('Physics', 'Watson', 70000);

INSERT INTO Student VALUES ('12345', 'John Doe', 'CSE', 30);
INSERT INTO Student VALUES ('54321', 'Jane Smith', 'Physics', 45);

INSERT INTO Instructor VALUES ('10101', 'Srinivasan', 'CSE', 65000);
INSERT INTO Instructor VALUES ('22222', 'Einstein', 'Physics', 95000);
INSERT INTO Instructor VALUES ('33333', 'Korth', 'CSE', 40000);

INSERT INTO Course VALUES ('CS-101', 'Intro to CS', 'CSE', 3);
INSERT INTO Course VALUES ('PHY-101', 'Gen Physics', 'Physics', 4);

INSERT INTO Section VALUES ('CS-101', '1', 'Fall', 2015, 'Taylor', '303', 'A');

INSERT INTO Takes VALUES ('12345', 'CS-101', '1', 'Fall', 2015, 'A');

INSERT INTO Employee VALUES (1, 'Alice', TO_DATE('12-05-1995', 'DD-MM-YYYY'));

-- 9. List all Students with names and their department names
SELECT name, dept_name FROM Student;

-- 10. List all instructors in CSE department
SELECT * FROM Instructor WHERE dept_name = 'CSE';

-- 11. Find the names of courses in CSE department which have 3 credits
SELECT title FROM Course WHERE dept_name = 'CSE' AND credits = 3;

-- 12. For student ID 12345, show all course-id and title of courses registered for
SELECT c.course_id, c.title 
FROM Course c, Takes t 
WHERE c.course_id = t.course_id AND t.ID = '12345';

-- 13. Instructors whose salary is between 40000 and 90000
SELECT name FROM Instructor WHERE salary BETWEEN 40000 AND 90000;

-- 14. IDs of instructors who have never taught a course
SELECT ID FROM Instructor 
MINUS 
SELECT ID FROM Teaches;

-- 15. Student names, course names, and year for classes in room 303
SELECT s.name, c.title, t.year
FROM Student s, Takes t, Course c, Section sec
WHERE s.ID = t.ID 
  AND t.course_id = c.course_id 
  AND t.course_id = sec.course_id 
  AND t.sec_id = sec.sec_id
  AND sec.room_number = '303';

-- 16. Students in 2015, rename title to c-name
SELECT s.name, t.course_id, c.title AS "c-name"
FROM Student s, Takes t, Course c
WHERE s.ID = t.ID AND t.course_id = c.course_id AND t.year = 2015;

-- 17. Instructors with salary > at least one CSE instructor, rename to inst-salary
SELECT name, salary AS "inst-salary"
FROM Instructor
WHERE salary > ANY (SELECT salary FROM Instructor WHERE dept_name = 'CSE');

-- 18. Dept name includes substring 'ch'
SELECT name FROM Instructor WHERE dept_name LIKE '%ch%';

-- 19. Student names and their lengths
SELECT name, LENGTH(name) AS name_length FROM Student;

-- 20. Dept names and 3 characters from 3rd position
SELECT dept_name, SUBSTR(dept_name, 3, 3) FROM Department;

-- 21. Instructor names in upper case
SELECT UPPER(name) FROM Instructor;

-- 22. Replace NULL with 0 (example: tot_cred in Student)
SELECT name, NVL(tot_cred, 0) FROM Student;

-- 23. Salary and salary/3 rounded to nearest hundred
SELECT salary, ROUND(salary/3, -2) AS rounded_salary FROM Instructor;

-- 24. Display birth date in different formats
SELECT TO_CHAR(DOB, 'DD-MON-YYYY') AS format1 FROM Employee;
SELECT TO_CHAR(DOB, 'DD-MON-YY') AS format2 FROM Employee;
SELECT TO_CHAR(DOB, 'DD-MM-YY') AS format3 FROM Employee;

-- 25. List names and the birth year fully spelled out
SELECT name, TO_CHAR(DOB, 'YEAR') AS UPPER_YEAR FROM Employee;
SELECT name, TO_CHAR(DOB, 'Year') AS Title_Year FROM Employee;
SELECT name, TO_CHAR(DOB, 'year') AS Lower_Year FROM Employee;