
-- BASIC SELECT QUERIES


-- Find all employees
SELECT * FROM employee;

-- Find all clients
SELECT * FROM client;

-- Find all employees ordered by salary (highest first)
SELECT * 
FROM employee
ORDER BY salary DESC;

-- Find all employees ordered by sex then name
SELECT *
FROM employee
ORDER BY sex, first_name DESC;

-- Find the first 5 employees
SELECT *
FROM employee
LIMIT 5;

-- Find first and last names
SELECT first_name, last_name
FROM employee;

-- Rename columns
SELECT first_name AS forename, last_name AS surname
FROM employee;

-- Find distinct genders
SELECT DISTINCT sex
FROM employee;


-- FILTERING QUERIES

-- Male employees
SELECT *
FROM employee
WHERE sex = 'M';

-- Employees in branch 2
SELECT *
FROM employee
WHERE branch_id = 2;

-- Employees born after 1969
SELECT emp_id, first_name, last_name
FROM employee
WHERE birth_day >= '1970-01-01';

-- Female employees in branch 2
SELECT *
FROM employee
WHERE branch_id = 2 AND sex = 'F';

-- Female & born after 1969 OR salary > 80000
SELECT *
FROM employee
WHERE (birth_day >= '1970-01-01' AND sex = 'F') 
   OR salary > 80000;

-- Employees born between 1970 and 1975
SELECT *
FROM employee
WHERE birth_day BETWEEN '1970-01-01' AND '1975-01-01';

-- Employees with specific names
SELECT *
FROM employee
WHERE first_name IN ('Jim', 'Michael', 'Johnny', 'David');


-- AGGREGATION QUERIES

-- Count employees (with supervisors)
SELECT COUNT(super_id)
FROM employee;

-- Average salary
SELECT AVG(salary)
FROM employee;

-- Total salary
SELECT SUM(salary)
FROM employee;

-- Count by gender
SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;

-- Total sales per employee
SELECT SUM(total_sales), emp_id
FROM works_with
GROUP BY emp_id;

-- Total spending per client
SELECT SUM(total_sales), client_id
FROM works_with
GROUP BY client_id;


-- PATTERN MATCHING

-- Clients that are LLCs
SELECT *
FROM client
WHERE client_name LIKE '%LLC';

-- Suppliers in label business
SELECT *
FROM branch_supplier
WHERE supplier_name LIKE '% Label%';

-- Employees born on 10th
SELECT *
FROM employee
WHERE birth_day LIKE '_____10%';

-- Clients that are schools
SELECT *
FROM client
WHERE client_name LIKE '%Highschool%';


-- UNION QUERIES

-- Employee and branch names
SELECT first_name AS name
FROM employee
UNION
SELECT branch_name
FROM branch;

-- Clients and suppliers
SELECT client_name AS name, branch_id
FROM client
UNION
SELECT supplier_name, branch_id
FROM branch_supplier;


-- JOIN QUERIES

-- Employees who are branch managers
SELECT e.emp_id, e.first_name, b.branch_name
FROM employee e
JOIN branch b 
ON e.emp_id = b.mgr_id;


-- SUBQUERIES

-- Employees who sold over 50,000
SELECT first_name, last_name
FROM employee
WHERE emp_id IN (
   SELECT emp_id
   FROM works_with
   WHERE total_sales > 50000
);

-- Clients handled by branch managed by employee 102
SELECT client_id, client_name
FROM client
WHERE branch_id = (
   SELECT branch_id
   FROM branch
   WHERE mgr_id = 102
);

-- Same query without knowing manager ID
SELECT client_id, client_name
FROM client
WHERE branch_id = (
   SELECT branch_id
   FROM branch
   WHERE mgr_id = (
       SELECT emp_id
       FROM employee
       WHERE first_name = 'Michael' 
         AND last_name = 'Scott'
       LIMIT 1
   )
);

-- Employees working with clients in branch 2
SELECT first_name, last_name
FROM employee
WHERE emp_id IN (
   SELECT emp_id FROM works_with
)
AND branch_id = 2;

-- Clients who spent over 100,000
SELECT client_name
FROM client
WHERE client_id IN (
    SELECT client_id
    FROM (
        SELECT SUM(total_sales) AS totals, client_id
        FROM works_with
        GROUP BY client_id
    ) AS total_client_sales
    WHERE totals > 100000
);