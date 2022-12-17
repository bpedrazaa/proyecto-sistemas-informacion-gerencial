use AdventureWorks2019
go

;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
SELECT        
	-- For dim_time
	soh.OrderDate as time_id,
	DATEPART(year,soh.OrderDate) as [year],
	IIF(DATEPART(quarter,soh.OrderDate) > 2, 2, 1) as semester,
	DATEPART(quarter,soh.OrderDate) as [quarter],
	DATEPART(month,soh.OrderDate) as [month],
	DATENAME(dw, soh.OrderDate) as [day],
	case 
		when (DATEPART(hour,soh.OrderDate) < 12) then 'Morning'
		when DATEPART(hour,soh.OrderDate) >=12 and DATEPART(hour,soh.OrderDate) < 19 then 'Afternoon'
		else 'Night'
	end as time_of_day,

	-- For dim_location
	pa.AddressID as location_id, 
	pcr.Name AS country, 
	psp.Name AS province, 
	pa.City AS city,
-
	-- For dim_product
	prp.ProductID AS product_id,
	prp.Name AS [name], 
	ppm.Name AS model, 
	ppsc.Name AS sub_category, 
	ppc.Name AS category,

	-- For dim_customer
	sc.CustomerID AS customer_id,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:Gender[1]', 'varchar') AS genre, 
	DATEDIFF(YEAR, pep.Demographics.value('/ns:IndividualSurvey[1]/ns:BirthDate[1]', 'date'), GETDATE()) AS age, 
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:MaritalStatus[1]', 'char') AS marital_status,
	case
		when pep.Demographics.value('/ns:IndividualSurvey[1]/ns:YearlyIncome[1]', 'varchar(255)') = 'greater than 100000' then 100000
		else (select avg(t.value) from (SELECT cast(value as numeric) as value FROM STRING_SPLIT(pep.Demographics.value('/ns:IndividualSurvey[1]/ns:YearlyIncome[1]', 'varchar(255)'), '-')) as t)
	end as yearly_income,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:TotalChildren[1]', 'int') AS total_children,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:Education[1]', 'varchar(255)') AS education,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:NumberCarsOwned[1]', 'int') AS number_cars_owned,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:HomeOwnerFlag[1]', 'int') AS home_owner_flag,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:Occupation[1]', 'varchar(255)') AS occupation,
	pep.Demographics.value('/ns:IndividualSurvey[1]/ns:NumberChildrenAtHome[1]', 'int') AS number_children_at_home,

	---- For fact_sales
	sod.OrderQty as quantity,
	sod.OrderQty * sod.UnitPrice as total_price
	
FROM            
	Sales.SalesOrderHeader soh
	INNER JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID 
	
	INNER JOIN Person.Address pa
		ON soh.BillToAddressID = pa.AddressID AND soh.ShipToAddressID = pa.AddressID 
	INNER JOIN Person.StateProvince psp
		ON pa.StateProvinceID = psp.StateProvinceID
	INNER JOIN Person.CountryRegion pcr
		ON psp.CountryRegionCode = pcr.CountryRegionCode

	INNER JOIN Production.Product prp
		ON sod.ProductID = prp.ProductID
	INNER JOIN Production.ProductModel ppm
		ON prp.ProductModelID = ppm.ProductModelID
	INNER JOIN Production.ProductSubcategory ppsc
		ON prp.ProductSubcategoryID = ppsc.ProductSubcategoryID
	INNER JOIN Production.ProductCategory ppc
		ON ppsc.ProductCategoryID = ppc.ProductCategoryID
	
	INNER JOIN Sales.Customer sc
		ON soh.CustomerID = sc.CustomerID
	INNER JOIN Person.Person pep
		ON sc.PersonID = pep.BusinessEntityID

	-- Filter customer that only have one purchase
	INNER JOIN (SELECT COUNT(c.CustomerID) customer_count, c.CustomerID as customerID
					FROM Sales.Customer as c
					JOIN Sales.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
					JOIN Person.Person as p ON c.CustomerID = p.BusinessEntityID
					where p.PersonType = 'IN'
					group by c.CustomerID 
					having COUNT(c.CustomerID) = 1) as t
		on t.customerID = sc.CustomerID		
where PersonType = 'IN'