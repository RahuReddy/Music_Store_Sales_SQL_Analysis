/* MUSIC STORE DATA ANALYSIS */

-- DATA CLEANING
/* Checking Each Table for any Data Inconsistancies, Duplicates */

-- 1. ALBUM
SELECT *
FROM album
ORDER BY 1;

SELECT DISTINCT(title) AS title
FROM album;


SELECT title, COUNT(title) AS count_title
FROM album
GROUP BY title
HAVING COUNT(title) > 1;


-- 2. ALBUM2
SELECT *
FROM album2
;

SELECT DISTINCT(title) AS title
FROM album2;


SELECT title, COUNT(title) AS count_title
FROM album2
GROUP BY title
HAVING COUNT(title) > 1;


--3. ARTIST
SELECT *
FROM artist;

 
SELECT name, COUNT(name) AS count_name
FROM artist
GROUP BY name
HAVING COUNT(name) > 1;


-- 4.CUSTOMER
SELECT *
FROM customer;


SELECT first_name, last_name, 
COUNT(first_name) AS count_first,
COUNT(last_name) AS count_last
FROM customer
GROUP BY first_name, last_name
HAVING COUNT(first_name) > 1
AND COUNT(last_name) > 1;


-- 5.EMPLOYEE

SELECT *
FROM employee;


-- 6. GENRE
SELECT *
FROM genre;


SELECT name, COUNT(name) AS count_names
FROM genre
GROUP BY name
HAVING COUNT(name) > 1;



-- 7. INVOICE
SELECT * 
FROM invoice;


SELECT DISTINCT customer_id
FROM invoice;


-- 8. INVOICE LINE

SELECT *
FROM invoice_line;


-- 9. MEDIA TYPE

SELECT *
FROM media_type;


-- 10. PLAYLIST
SELECT *
FROM playlist;

SELECT name, COUNT(name) AS count_names
FROM playlist
GROUP BY name
HAVING COUNT(name) > 1;



-- 11.PLAYLIST TRACK
SELECT *
FROM playlist_track;

SELECT track_id, COUNT(track_id) AS tracks_count
FROM playlist_track
GROUP BY track_id;


-- 12. TRACK
SELECT *
FROM track;



/* Answering Some of these Business Questions with SQL queries */
-- 1.Which top 10 countries are generating the most revenue, 
-- and what are their key sales metrics?

SELECT TOp 10 c.country, 
       ROUND(SUM(i.total),2) AS total_revenue,
       COUNT(i.invoice_id) AS total_sales
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY c.country
ORDER BY 2 DESC, 3 DESC;



-- 2. Find out top 10 best performing cities based on Revenue

SELECT TOP 10 c.country, c.city,
       ROUND(SUM(i.total),2) AS total_revenue
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
GROUP BY c.country, c.city
ORDER BY total_revenue DESC;



-- 3. What are the top 5 most popular genres and artists by sales volume?

SELECT *
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
;


-- 3a. Top 5 Most Popular genres by sales volume

SELECT TOP 5 g.name, ROUND(SUM(il.unit_price),2) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY g.name
ORDER BY total_revenue DESC;


-- 3b. Percentage contribution of each genre to the total revenue
WITH CTE AS (
SELECT TOP 5 g.name AS Genre_name, 
       ROUND(SUM(il.unit_price),2) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY g.name
ORDER BY total_revenue DESC)

SELECT *,
CONCAT(ROUND((total_revenue *100.0 / SUM(total_revenue) OVER()),2),'%') AS percentage0ftotal
FROM CTE
;

-- 3c. Top 5 most popular Artists by total quantity and total revenue

SELECT TOP 5 ar.name, 
       SUM(quantity) AS total_quantity,
       ROUND(SUM(il.unit_price),2) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY total_quantity DESC, total_revenue DESC;




-- 4.Find out which media formats are most popular and profitable.

SELECT mt.name AS Media_Type,
       ROUND(SUM(il.unit_price*il.quantity),2) AS total_revenue,
       COUNT(il.quantity) AS total_quantity_sold
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY mt.name
ORDER BY total_revenue DESC;


-- 4a.Percenatge of contribution of each media type for total revenue
WITH CTE AS(
SELECT mt.name AS Media_Type,
       ROUND(SUM(il.unit_price*il.quantity),2) AS total_revenue,
       COUNT(il.quantity) AS total_quantity_sold
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY mt.name)

SELECT *,
CONCAT(ROUND((total_revenue *100.0 / SUM(total_revenue) OVER()),2),'%') AS percentage0ftotal
FROM CTE
ORDER BY total_revenue DESC;



-- 5. Top 10 most valuable customers.

SELECT TOP 10 first_name, last_name, ROUND(SUM(total),2) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY first_name, last_name
ORDER BY total_revenue DESC;


-- 6. Identify which sales support agents are driving the most revenue.

SELECT e.first_name, e.last_name, ROUND(SUM(i.total),2) AS total_revenue
FROM customer c
JOIN employee e ON c.support_rep_id = e.employee_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.first_name, e.last_name
ORDER BY total_revenue DESC;


-- 7. Identifying sales performance over time Yearly and Monthly

-- Yearly Revenue
SELECT YEAR(invoice_date) AS Year,

       ROUND(SUM(total),2) AS total_revenue
FROM invoice
GROUP BY YEAR(invoice_date)
ORDER BY total_revenue DESC;

-- Monthly Revenue

SELECT 
       MONTH(invoice_date) AS Month,
       ROUND(SUM(total),2) AS total_revenue
FROM invoice
GROUP BY MONTH(invoice_date)
ORDER BY total_revenue DESC;


-- 7a.Checking YOY sales growth percentage

WITH YearlyMetrics AS (
SELECT YEAR(invoice_date) AS Year,
       SUM(total) AS total_sales,
       COUNT(customer_id) AS total_customers
FROM invoice
GROUP BY YEAR(invoice_date))

SELECT Year,
       total_Sales,
       total_customers,
       LAG(total_sales, 1) OVER(ORDER BY Year) AS prev_year_sales,
       ROUND(((total_sales - LAG(total_sales, 1) OVER(ORDER BY Year))/
       LAG(total_sales, 1) OVER(ORDER BY Year)) * 100,2) AS yoy_growth_percent       
FROM YearlyMetrics;


-- 7b.Checking MOM sales growth percentage

WITH MonthlyMetrics AS (
SELECT MONTH(invoice_date) AS Month,
       COUNT(customer_id) AS total_customers,
       SUM(total) AS current_month_sales
FROM invoice
GROUP BY MONTH(invoice_date))

SELECT Month,
       total_customers,
       current_month_sales,      
       LAG(current_month_sales, 1) OVER(ORDER BY Month) AS prev_month_sales,
       ROUND(((current_month_sales - LAG(current_month_sales, 1) OVER(ORDER BY Month))/
       LAG(current_month_sales, 1) OVER(ORDER BY Month)) * 100,2) AS MOM_growth_percent       
FROM MonthlyMetrics;



-- 8. Which Top 10 albums and tracks are selling well to ensure they are well-stocked and promoted.

SELECT TOP 10 a.title, t.name, 
       COUNT(il.quantity) AS total_quantity
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY a.title, t.name
ORDER BY total_quantity DESC;



-- 9. Identifying purchasing behavior of more repeated customers versus less repeated customers.
-- Most Repeating Customers greater than 10 times

SELECT customer_id, COUNT(*) AS repeat_count
FROM invoice
GROUP BY customer_id
HAVING COUNT(*) > 10
ORDER BY repeat_count DESC;


-- Less Repeating Customers less than 10 times

SELECT customer_id, COUNT(*) AS repeat_count
FROM invoice
GROUP BY customer_id
HAVING COUNT(*) < 10
ORDER BY repeat_count;



-- 10. Find out the total revenue generated by less repeated customers 
-- versus more repeated customers.(>10 and <10)

WITH CustomerPurchaseCount AS (
SELECT customer_id, 
       COUNT(invoice_id) AS total_purchases
FROM invoice
GROUP BY customer_id)


SELECT 
     CASE 
         WHEN cpc.total_purchases < 10 THEN 'less_repeated_customers'
         ELSE 'more_repeated_customers'
     END AS customer_type,
     COUNT(cpc.customer_id) AS total_customers,
     ROUND(SUM(i.total),2) AS total_revenue
FROM invoice i
JOIN CustomerPurchaseCount cpc
    ON i.customer_id = cpc.customer_id
GROUP BY CASE 
         WHEN cpc.total_purchases < 10 THEN 'less_repeated_customers'
         ELSE 'more_repeated_customers'
     END
ORDER BY total_revenue DESC;


-- 11.What is the average customer lifetime value for each sales support agent.

SELECT 
e.first_name,
e.last_name,
ROUND(SUM(i.total),2) AS total_revenue_generated,
ROUND(AVG(i.total),2) AS avg_invoice_value,
COUNT(DISTINCT c.customer_id) AS total_customers_served
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
JOIN employee e ON c.support_rep_id = e.employee_id
GROUP BY e.first_name,e.last_name
ORDER BY total_revenue_generated DESC;


-- Important KPI's
-- Total Sales
SELECT ROUND(SUM(total),2) AS total_sales
FROM invoice;

-- Total Number of Orders
SELECT COUNT(invoice_id) AS total_orders
FROM invoice;

-- AVG order Value (AOV)
SELECT ROUND(AVG(total),2) AS AOV
FROM invoice;