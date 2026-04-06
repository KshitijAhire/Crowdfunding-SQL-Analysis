create database Crowdfunding_Projects1;
describe projects;
select * from projects;
-- Alter Table
ALTER TABLE projects
ADD COLUMN created_at_dt DATETIME;
ALTER TABLE project
ADD COLUMN deadline_dt DATETIME,
ADD COLUMN updated_at_dt DATETIME,
ADD COLUMN state_changed_at_dt DATETIME,
ADD COLUMN successful_at_dt DATETIME,
ADD COLUMN launched_at_dt DATETIME;
-- Update Table 
UPDATE projects
SET created_at_dt = FROM_UNIXTIME(created_at);
UPDATE projects
SET
    deadline_dt         = FROM_UNIXTIME(NULLIF(deadline, '')),
    updated_at_dt       = FROM_UNIXTIME(NULLIF(updated_at, '')),
    state_changed_at_dt = FROM_UNIXTIME(NULLIF(state_changed_at, '')),
    successful_at_dt    = FROM_UNIXTIME(NULLIF(successful_at, '')),
    launched_at_dt      = FROM_UNIXTIME(NULLIF(launched_at, ''));

-- Q.2.  create table Calendar Table 
CREATE TABLE calendar (
    cal_date DATE PRIMARY KEY,
    cal_year INT,
    month_no INT,
    month_fullname VARCHAR(20),
    cal_quarter VARCHAR(2),
    cal_year_month VARCHAR(10),
    weekday_no INT,
    weekday_name VARCHAR(10),
    financial_month VARCHAR(5)
);
drop table calendar;
select * from calendar;
-- Update calendar Table 
SET SESSION cte_max_recursion_depth = 10000;
CREATE TABLE calendar AS
WITH RECURSIVE date_range AS (
    SELECT DATE(MIN(created_at_dt)) AS cal_date
    FROM projects
    UNION ALL
    SELECT DATE_ADD(cal_date, INTERVAL 1 DAY)
    FROM date_range
    WHERE cal_date < (
        SELECT DATE(MAX(created_at_dt)) FROM projects
    )
)
SELECT
    cal_date,
    YEAR(cal_date) AS cal_year,
    MONTH(cal_date) AS month_no,
    MONTHNAME(cal_date) AS month_fullname,
    CONCAT('Q', QUARTER(cal_date)) AS cal_quarter,
    DATE_FORMAT(cal_date, '%Y-%b') AS cal_year_month,
    WEEKDAY(cal_date) + 1 AS weekday_no,
    DAYNAME(cal_date) AS weekday_name,
    CASE
        WHEN MONTH(cal_date) >= 4 THEN CONCAT('FM', MONTH(cal_date) - 3)
        ELSE CONCAT('FM', MONTH(cal_date) + 9)
    END AS financial_month
FROM date_range;

ALTER TABLE calendar
ADD COLUMN financial_quarter VARCHAR(5);
UPDATE calendar
SET financial_quarter =
    CASE
        WHEN MONTH(cal_date) BETWEEN 4 AND 6 THEN 'FQ-1'
        WHEN MONTH(cal_date) BETWEEN 7 AND 9 THEN 'FQ-2'
        WHEN MONTH(cal_date) BETWEEN 10 AND 12 THEN 'FQ-3'
        ELSE 'FQ-4'
    END;


   
-- Q 7 Top Successful Projects
-- based on Number of Backers

SELECT
    name AS project_name,
    backers_count
FROM projects
WHERE state = 'successful'
ORDER BY backers_count DESC
LIMIT 5;
   
-- Q.7 Top Successful Projects 
-- based on Amount Raised

SELECT
    name AS project_name,
    usd_pledged AS amount_raised_usd
FROM projects
WHERE state = 'successful'
ORDER BY usd_pledged DESC
LIMIT 5;


