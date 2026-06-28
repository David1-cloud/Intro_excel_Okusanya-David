/*
 HR ANALYTICS PROJECT
 Author: Okusanya David Fiyinfoluwa
 Date: June 2026
Dataset: HR Data 

*/

-- SECTION 1: DATA CLEANING & QUALITY CHECKS


-- 1. Preview the raw data
SELECT TOP 10 * 
FROM [dbo].[HR Data];

-- 2. Total employee count
SELECT COUNT(id) AS TotalEmployees
FROM [dbo].[HR Data];

-- 3. Check for NULLs in key columns
SELECT 
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NullIDs,
    SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS NullDepartments,
    SUM(CASE WHEN hire_date IS NULL THEN 1 ELSE 0 END) AS NullHireDates,
    SUM(CASE WHEN termdate IS NULL OR termdate = '' THEN 1 ELSE 0 END) AS NullTermDates_ActiveEmployees
FROM [dbo].[HR Data];

-- 4. Check all unique gender values
SELECT DISTINCT gender
FROM [dbo].[HR Data];

-- 5. Check all unique race values
SELECT DISTINCT race
FROM [dbo].[HR Data];

-- SECTION 2: CORE ANALYSIS

-- Attrition rate by department
SELECT
    department,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) AS Terminated,
    SUM(CASE WHEN termdate IS NULL OR termdate = '' THEN 1 ELSE 0 END) AS ActiveEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) / COUNT(*),
    2) AS AttritionRate_Pct
FROM [dbo].[HR Data]
GROUP BY department
ORDER BY AttritionRate_Pct DESC;


-- Average employee tenure by department
SELECT
    department,
    COUNT(*) AS TotalEmployees,
    ROUND(AVG(DATEDIFF(YEAR, hire_date, 
        CASE 
            WHEN termdate IS NULL OR termdate = '' THEN GETDATE()
            WHEN ISDATE(termdate) = 1 THEN CONVERT(DATE, termdate)
            ELSE GETDATE()
        END
    )), 1) AS AvgTenureYears
FROM [dbo].[HR Data]
GROUP BY department
ORDER BY AvgTenureYears DESC;


-- Headcount by department and job title with gender breakdown
SELECT 
    department,
    jobtitle,
    COUNT(*) AS Headcount,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    SUM(CASE WHEN gender = 'Not Conforming' THEN 1 ELSE 0 END) AS NotConforming
FROM [dbo].[HR Data]
GROUP BY department, jobtitle
ORDER BY department, Headcount DESC;


-- Race and diversity breakdown with attrition rate 
SELECT distinct 
    [race],
    [jobtitle],
    COUNT(*) AS TotalEmployees,

    -- Attrition breakdown
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) AS Terminated,
    SUM(CASE WHEN termdate IS NULL OR termdate = '' THEN 1 ELSE 0 END) AS ActiveEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) / COUNT(*),
    2) AS AttritionRate_Pct,  

    -- Gender breakdown
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    SUM(CASE WHEN gender = 'Not Conforming' THEN 1 ELSE 0 END) AS NotConforming

FROM [dbo].[HR Data]
GROUP BY [race], [jobtitle]  
ORDER BY AttritionRate_Pct DESC;

-- Average Age people left by department 
SELECT
    department,
    COUNT(*) AS TotalEmployees,
    SUM( CASE WHEN termdate is NOT NULL AND termdate != '' 
     AND ISDATE(LEFT(termdate, 10)) = 1 
     THEN 1 ELSE 0 END) AS PeopleWhoLeft,
    ROUND(AVG(DATEDIFF(YEAR, [birthdate], 
        CASE 
            WHEN termdate IS NULL OR termdate = '' THEN GETDATE()
            WHEN ISDATE(termdate) = 1 THEN CONVERT(DATE, termdate)
            ELSE GETDATE()
        END
    )), 1) AS AvgAgePeopleleft 
FROM [dbo].[HR Data]
GROUP BY department
ORDER BY AvgAgePeopleleft DESC;

/*SECTION 3: FINAL REPORT — CTEs + JOINs + WINDOW FUNCTIONS*/n


WITH DepartmentSummary AS (
    -- CTE 1: Department-level headcount and attrition
    SELECT
        department,
        COUNT(*) AS TotalEmployees,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) AS Terminated,
        SUM(CASE WHEN termdate IS NULL OR termdate = '' THEN 1 ELSE 0 END) AS ActiveEmployees,
        ROUND(
            100.0 * SUM(CASE WHEN termdate IS NOT NULL AND termdate <> '' THEN 1 ELSE 0 END) / COUNT(*),
        2) AS AttritionRate_Pct
    FROM [dbo].[HR Data]
    GROUP BY department
),

TenureSummary AS (
    -- CTE 2: Average tenure per department
    SELECT
        department,
        ROUND(AVG(DATEDIFF(YEAR, hire_date,
            CASE 
                WHEN termdate IS NULL OR termdate = '' THEN GETDATE()
                WHEN ISDATE(termdate) = 1 THEN CONVERT(DATE, termdate)
                ELSE GETDATE()
            END
        )), 1) AS AvgTenureYears
    FROM [dbo].[HR Data]
    GROUP BY department
)

-- Main query: JOIN both CTEs to employee records + apply Window Functions
SELECT
    e.id,
    e.first_name,
    e.last_name,
    e.gender,
    e.race,
    e.department,
    e.jobtitle,
    e.location,
    e.location_city,
    e.location_state,
    e.hire_date,
    e.termdate,

    -- Window Function 1: Rank employees by how long they've worked in their department
    RANK() OVER (
        PARTITION BY e.department 
        ORDER BY DATEDIFF(YEAR, e.hire_date, 
            CASE 
                WHEN e.termdate IS NULL OR e.termdate = '' THEN GETDATE()
                WHEN ISDATE(e.termdate) = 1 THEN CONVERT(DATE, e.termdate)
                ELSE GETDATE()
            END
        ) DESC
    ) AS TenureRankInDept,

    -- Window Function 2: Count total employees per department (running context)
    COUNT(*) OVER (PARTITION BY e.department) AS DeptTotalEmployees,

    -- Window Function 3: Row number across entire company ordered by hire date
    ROW_NUMBER() OVER (ORDER BY e.hire_date ASC) AS CompanyHireOrder,

    -- From CTEs via JOIN
    ds.AttritionRate_Pct,
    ds.ActiveEmployees,
    ds.Terminated,
    ts.AvgTenureYears

FROM [dbo].[HR Data] e
JOIN DepartmentSummary ds ON e.department = ds.department
JOIN TenureSummary ts ON e.department = ts.department
ORDER BY e.department, TenureRankInDept;