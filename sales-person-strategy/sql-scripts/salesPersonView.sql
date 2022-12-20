CREATE VIEW sales_person_profile AS
SELECT DISTINCT
	 , HASHBYTES('MD5',CONCAT(eph.BusinessEntityID, eph.RateChangeDate)) AS pay_history_id
	, eph.Rate AS rate
	, eph.RateChangeDate AS rate_change_date 
	--dim_time
	, MONTH(soh.OrderDate) AS [month]
	, soh.OrderDate AS time_id
	--dim_quota_history
	,  HASHBYTES('MD5',CONCAT(sqh.BusinessEntityID, sqh.QuotaDate)) AS quota_history_id
	, sqh.SalesQuota AS amount
	, sqh.QuotaDate AS quota_date
	--dim_sales_person
	, emp.BusinessEntityID AS sales_person_id
	, DATEDIFF(year,emp.BirthDate,GETDATE()) AS age
	, DATEDIFF(year,emp.HireDate,GETDATE()) AS time_employed
	, emp.MaritalStatus AS marital_status
	, emp.Gender AS gender
	, emp.OrganizationLevel AS organization_level
	, sp.Bonus AS bonus
	, sp.CommissionPct AS commission_pct
FROM HumanResources.Employee emp