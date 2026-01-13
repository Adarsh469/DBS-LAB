-- 1 & 2. Create Tables
CREATE TABLE Department (
    DeptNo NUMBER PRIMARY KEY,
    DeptName VARCHAR2(50) UNIQUE,
    Location VARCHAR2(50)
);

CREATE TABLE Employee (
    EmpNo NUMBER PRIMARY KEY,
    EmpName VARCHAR2(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Salary NUMBER NOT NULL,
    Address VARCHAR2(100) NOT NULL,
    DNo NUMBER,
    CONSTRAINT fk_dept FOREIGN KEY (DNo) REFERENCES Department(DeptNo)
);

-- 4. Insert Valid Tuples
INSERT INTO Department VALUES (10, 'Accounting', 'New York');
INSERT INTO Department VALUES (20, 'Research', 'Dallas');

INSERT INTO Employee VALUES (101, 'Alice', 'F', 50000, '123 Maple St', 10);
INSERT INTO Employee VALUES (102, 'Bob', 'M', 45000, '456 Oak St', 20);

-- 7. Modify Constraint to ON DELETE CASCADE
ALTER TABLE Employee DROP CONSTRAINT fk_dept;

ALTER TABLE Employee 
ADD CONSTRAINT fk_dept_cascade 
FOREIGN KEY (DNo) REFERENCES Department(DeptNo) ON DELETE CASCADE;

-- Test Cascade Delete (Deleting Dept 10 will remove Alice)
DELETE FROM Department WHERE DeptNo = 10;

-- 8. Fix Default Salary Syntax
ALTER TABLE Employee MODIFY Salary DEFAULT 10000;
INSERT INTO Employee (EmpNo, EmpName, Gender, Address, DNo) 
VALUES (106, 'Dave', 'M', '789 Pine St', 20);

SELECT * FROM Employee;
