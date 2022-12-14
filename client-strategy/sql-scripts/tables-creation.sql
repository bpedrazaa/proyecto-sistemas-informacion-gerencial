use [Sales-Client]
go

CREATE TABLE dim_time (
    time_id datetime,
	[year] int,
	[semester] int,
	[quarter] int,
    [month] int,
	[day] nvarchar(20)
	PRIMARY KEY (time_id)
);

CREATE TABLE dim_location (
    location_id int,
    country nvarchar(255),
	province nvarchar(255),
	city nvarchar(255)
	PRIMARY KEY (location_id)
);

CREATE TABLE dim_product (
	product_id int,
	[name] nvarchar(255),
	model nvarchar(255),
	category nvarchar(255),
	sub_category nvarchar(255),
	PRIMARY KEY (product_id)
);

CREATE TABLE dim_customer(
	customer_id int,
	genre nvarchar(5),
	age int,
	marital_status nvarchar(5),
	yearly_income numeric,
	total_children int,
	education nvarchar(255),
	numbers_cars_owned int,
	home_owner_flag int,
	occupation nvarchar(255),
	number_children_at_home int,
	PRIMARY KEY (customer_id)
);

CREATE TABLE fact_sales(
	time_id datetime NOT NULL,
	location_id int NOT NULL,
	customer_id int NOT NULL,
	product_id int NOT NULL,
	quantity int,
	total_price numeric,
	FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
	FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
)

