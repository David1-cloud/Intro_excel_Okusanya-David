--JOINS 
SELECT Employeedemographics.EmployeeID,FirstName, LastName, Salary
FROM [SQL Tutorial ].dbo.EmployeeDemographics
Inner Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
   
   SELECT Employeedemographics.EmployeeID,FirstName, LastName, Salary
FROM [SQL Tutorial ].dbo.EmployeeDemographics
FULL OUTER Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
  
  SELECT Employeedemographics.EmployeeID,FirstName, LastName, Salary
FROM [SQL Tutorial ].dbo.EmployeeDemographics
LEFT OUTER Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
  
  SELECT*
FROM [SQL Tutorial ].dbo.EmployeeDemographics
RIGHT OUTER Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
  

SELECT Employeedemographics.EmployeeID,FirstName, LastName, Salary
FROM [SQL Tutorial ].dbo.EmployeeDemographics
Inner Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
   WHERE FirstName < > 'Michael'
   ORDER BY Salary DESC

   -- JOINS WITH CALULATIONS 
   SELECT JobTitle, AVG(Salary) AS AVERAGESALARY
FROM [SQL Tutorial ].dbo.EmployeeDemographics
Inner Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
   WHERE JobTitle ='Salesman'
   GROUP BY JobTitle

 -- UNION   
SELECT*
FROM [SQL Tutorial ].dbo.EmployeeDemographics
union all
SELECT*
FROM [SQL Tutorial ].dbo.WarehouseEmployeeDemographics
Order by EmployeeID

-- CASE 
 SELECT FirstName, LastName, Age,
 CASE 
 When  Age > 30  THEN 'Old'
 When  Age  between 27 and 30  THEN 'Young'
    Else 'Baby'
    END 
FROM [SQL Tutorial ].dbo.EmployeeDemographics
WHERE Age is not NULL
Order By Age

-- CASE with JOINS 
SELECT FirstName, LastName, JobTitle, Salary,
CASE
WHEN JobTitle = 'Salesman' then Salary +(Salary *10)
WHEN JobTitle = 'Accountant' then Salary +(Salary *.05)
WHEN JobTitle = 'HR' then Salary +(Salary *.000001)
ELSE Salary +(Salary *.03)
END AS SALARYAFTERRAISE 
FROM [SQL Tutorial ].dbo.EmployeeDemographics
Join [SQL Tutorial ].dbo.EmployeeSalary
   ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

   -- UPDATE OF DATA IN A TABLE 
   SELECT*
   FROM [SQL Tutorial ].dbo.EmployeeDemographics

   UPDATE [SQL Tutorial ].dbo.EmployeeDemographics
   SET LastName = 'Ajiga' 
   WHERE EmployeeID = 1012


 UPDATE [SQL Tutorial ].dbo.EmployeeDemographics
   SET Age = 30 
   WHERE EmployeeID = 1012

 UPDATE [SQL Tutorial ].dbo.EmployeeDemographics
   SET Gender= 'MALE'
   WHERE EmployeeID = 1012

   --DELETING A ROW FROM A TABLE 
   DELETE FROM [SQL Tutorial ].dbo.EmployeeDemographics
   WHERE EmployeeID=1004
