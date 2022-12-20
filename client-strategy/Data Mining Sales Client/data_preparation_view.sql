CREATE VIEW data_preparation as 
Select CAST(dt.time_id as date) as time_id,
		dt.[day],
		dt.[month],
		dt.[quarter],
		dt.[semester],
		dt.[year],

		dc.customer_id,
		CASE 
			WHEN dc.age < 65 THEN 'adult'
		ELSE 'elder'
		END AS age,
		dc.education,
		dc.genre,
		dc.home_owner_flag,
		dc.marital_status,
		dc.number_children_at_home,
		dc.numbers_cars_owned,
		dc.occupation,
		dc.total_children,
		CASE 
			WHEN dc.yearly_income < 40000 THEN 'Low' 
			WHEN dc.yearly_income > 60000 THEN 'High' 
			ELSE 'Moderate' 
		END AS yearly_income, 

		dl.city,
		dl.country,
		dl.province,

		dp.product_id,
		dp.category,
		dp.model,
		dp.[name],
		dp.sub_category,

		fs.quantity,
		fs.total_price

from fact_sales as fs 
	INNER JOIN dim_customer as dc
		ON fs.customer_id = dc.customer_id
	INNER JOIN dim_location as dl
		ON fs.location_id = dl.location_id
	INNER JOIN dim_product  as dp
		ON dp.product_id = fs.product_id
	INNER JOIN dim_time as dt
		ON dt.time_id = fs.time_id