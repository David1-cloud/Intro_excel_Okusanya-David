SELECT CUSTOMERNAME AS 'CUSTOMER NAME',Notes
FROM dbo.Customers
SELECT DISTINCT CUSTOMERNAME AS 'CUSTOMER NAME',Notes
FROM dbo.Customers
SELECT TOP(3) *
FROM dbo.Customers
SELECT  *
FROM dbo.Customers
WHERE State='WA'
--this returns all people in washington state 
SELECT  *
FROM dbo.Customers
WHERE State<>'WA'
--this returns all people that are not in washington state 
SELECT  *
FROM dbo.Customers
WHERE State='WA' or State='NY'
--this returns all people in washington state or new york
SELECT  *
FROM dbo.Customers
WHERE State IN('WA','NY','UT')
--this returns all people in washington state or new york

SELECT  *
FROM dbo.Customers
WHERE CustomerName NOT Like'A%'
/* Customer name begins with */

SELECT OrderID, OrderDate,OrderTotal,CustomerName,Phone 
FROM KCC.dbo.Orders
join  KCC.dbo.Customers 
on dbo.Orders.CustomerID = dbo.Customers.CustomerID
order by OrderTotal
/* The use of joins */

Select *
from dbo.Orders
where OrderDate >= DATEADD(month,-1,'2/18/2022')


Select COUNT(*)
from dbo.Orders
where OrderDate >= DATEADD(month,-1,'2/18/2022')

Select SUM(ordertotal)
from dbo.Orders
where OrderDate >= DATEADD(month,-1,'2/18/2022')
group by CustomerID

