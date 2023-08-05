--Inspecting the data
SELECT * FROM [dbo].[sales_data_sample];

Checking unique values from the data
SELECT DISTINCT status FROM [dbo].[sales_data_sample]
SELECT DISTINCT year_id FROM [dbo].[sales_data_sample]
SELECT DISTINCT productline FROM [dbo].[sales_data_sample]
SELECT DISTINCT country FROM [dbo].[sales_data_sample]
SELECT DISTINCT dealsize FROM [dbo].[sales_data_sample]
SELECT DISTINCT territory FROM [dbo].

-- Checking why 2005 revenue was low compared to other year
SELECT DISTINCT month_id FROM [dbo].[sales_data_sample]
WHERE year_id = 2005

---ANALYSIS
---GROUPING SALES BY PRODUCTLINE
SELECT productline, round(sum(sales),2) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY productline
ORDER BY revenue DESC

--GROUPING SALES BY YEAR
SELECT year_id, round(sum(sales),2) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY year_id
ORDER BY revenue DESC

-- GROUPING SALES BY DEALSIZE
SELECT dealsize, round(sum(sales),2) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY dealsize
ORDER BY revenue DESC

--ANALYSING WHAT MONTH IS MAKING THE HIGHEST REVENUE
SELECT month_id, round(sum(sales),2) AS revenue, count(ordernumber) AS frequency
FROM [dbo].[sales_data_sample]
GROUP BY month_id
ORDER BY revenue DESC

-- NOVEMBER LOOKS TO BE WHERE THEY'RE MAKING THE BEST REVENUE
SELECT productline, round(sum(sales),2) AS revenue, count(ordernumber) AS frequency
FROM [dbo].[sales_data_sample]
WHERE month_id = 11
GROUP BY productline
ORDER BY revenue DESC

--  Who is our best customer
SELECT DISTINCT customername, sum(Quantityordered) AS Quantity_ordered, round(sum(sales),2) AS revenue
FROM [dbo].[sales_data_sample]
GROUP BY customername
ORDER BY revenue DESC;

--BEST CUSTOMER USING RFM(Recency, Frequency, Monetary Analysis)

DROP TABLE IF EXISTS #rfm;
WITH RFM AS
(
SELECT
     customername,
	 round(sum(sales),2) AS Monetaryvalue,
	 round(avg(sales),2) AS avgmonetaryvalue,
	 count(ordernumber) AS frequency,
	 max(Orderdate) AS last_order_date,
	 (select max(ORDERDATE) from [dbo].[sales_data_sample]) AS max_order_date,
	 DATEDIFF(DD, max(ORDERDATE),(select max(ORDERDATE) from [dbo].[sales_data_sample])) AS Recency
FROM [dbo].[sales_data_sample]
GROUP BY customername
),

rfm_calc AS (
SELECT r.*,
   NTILE(4) OVER (ORDER BY recency desc) AS rfm_recency,
   NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
   NTILE(4) OVER (ORDER BY monetaryvalue) AS rfm_monetary
FROM RFM AS r
)

SELECT
c.*, (rfm_recency + rfm_frequency + rfm_monetary) AS rfm_cell,
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast( rfm_monetary as varchar) AS rfm_string
into #rfm
FROM rfm_calc AS c

SELECT customername,rfm_recency, rfm_frequency, rfm_monetary,
case 
		when rfm_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_string in (311, 411, 331) then 'new customers'
		when rfm_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_string in (433, 434, 443, 444) then 'loyal'

	end rfm_segment
FROM #rfm


SELECT productline + ','
FROM [dbo].[sales_data_sample]
WHERE ORDERNUMBER IN 

(
select ORDERNUMBER
FROM(
select ORDERNUMBER, count(*) rn
				FROM [dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER) AS m
WHERE rn = 2)

for xml path ('')

