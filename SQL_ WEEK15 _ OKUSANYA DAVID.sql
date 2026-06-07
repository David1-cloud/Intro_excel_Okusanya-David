-- Week 15 Assignment - Advanced SQL Queries
-- Okusanya David


-- =====================
-- SUBQUERIES
-- =====================

-- getting employees who earn more than the average salary
SELECT emp.FirstName, emp.LastName, emp.Gender, sal.JobTitle, sal.Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
WHERE sal.Salary > (SELECT AVG(Salary) FROM [SQL Tutorial].dbo.EmployeeSalary)
ORDER BY sal.Salary DESC


-- comparing each employee salary to the average for their job title
SELECT emp.FirstName, emp.LastName, sal.JobTitle, sal.Salary,
	(SELECT AVG(s2.Salary) FROM [SQL Tutorial].dbo.EmployeeSalary s2
	 WHERE s2.JobTitle = sal.JobTitle) AS AvgForJobTitle,
	sal.Salary - (SELECT AVG(s2.Salary) FROM [SQL Tutorial].dbo.EmployeeSalary s2
	 WHERE s2.JobTitle = sal.JobTitle) AS Difference
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
ORDER BY sal.JobTitle


-- using a subquery in FROM to find the top earner per job title
SELECT JobTitle, FirstName, LastName, Salary
FROM (
	SELECT emp.FirstName, emp.LastName, sal.JobTitle, sal.Salary,
		RANK() OVER (PARTITION BY sal.JobTitle ORDER BY sal.Salary DESC) AS rnk
	FROM [SQL Tutorial].dbo.EmployeeDemographics emp
	JOIN [SQL Tutorial].dbo.EmployeeSalary sal
		ON emp.EmployeeID = sal.EmployeeID
) ranked
WHERE rnk = 1


-- =====================
-- WINDOW FUNCTIONS
-- =====================

-- ranking all employees by salary
SELECT emp.FirstName, emp.LastName, sal.JobTitle, sal.Salary,
	ROW_NUMBER() OVER (ORDER BY sal.Salary DESC) AS RowNum,
	RANK() OVER (ORDER BY sal.Salary DESC) AS SalaryRank,
	DENSE_RANK() OVER (ORDER BY sal.Salary DESC) AS DenseRank
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID


-- ranking within gender groups to see who earns most per gender
SELECT emp.FirstName, emp.LastName, emp.Gender, sal.Salary,
	RANK() OVER (PARTITION BY emp.Gender ORDER BY sal.Salary DESC) AS RankByGender
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
ORDER BY emp.Gender, sal.Salary DESC


-- running total and average salary by job title
SELECT emp.FirstName, emp.LastName, sal.JobTitle, sal.Salary,
	SUM(sal.Salary) OVER (PARTITION BY sal.JobTitle ORDER BY sal.Salary) AS RunningTotal,
	AVG(sal.Salary) OVER (PARTITION BY sal.JobTitle) AS AvgByTitle
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
ORDER BY sal.JobTitle


-- splitting employees into 4 salary groups using NTILE
SELECT emp.FirstName, emp.LastName, sal.Salary,
	NTILE(4) OVER (ORDER BY sal.Salary DESC) AS SalaryGroup
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID


-- =====================
-- INDEXES
-- =====================

-- checking existing indexes first
EXEC sp_helpindex 'EmployeeDemographics'
EXEC sp_helpindex 'EmployeeSalary'

-- adding index on EmployeeID for faster joins
CREATE NONCLUSTERED INDEX IX_EmpDemo_EmployeeID
ON [SQL Tutorial].dbo.EmployeeDemographics (EmployeeID)

CREATE NONCLUSTERED INDEX IX_EmpSal_EmployeeID
ON [SQL Tutorial].dbo.EmployeeSalary (EmployeeID)

-- index on Gender since we filter by it a lot
CREATE NONCLUSTERED INDEX IX_EmpDemo_Gender
ON [SQL Tutorial].dbo.EmployeeDemographics (Gender)

-- index on JobTitle and Salary for the queries above
CREATE NONCLUSTERED INDEX IX_EmpSal_JobTitle
ON [SQL Tutorial].dbo.EmployeeSalary (JobTitle)

CREATE NONCLUSTERED INDEX IX_EmpSal_Salary
ON [SQL Tutorial].dbo.EmployeeSalary (Salary DESC)

-- testing that the index actually helps - run with execution plan on (Ctrl+M)
SELECT emp.FirstName, emp.LastName, sal.JobTitle, sal.Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics emp
JOIN [SQL Tutorial].dbo.EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
WHERE sal.JobTitle = 'Salesman'
ORDER BY sal.Salary DESC

