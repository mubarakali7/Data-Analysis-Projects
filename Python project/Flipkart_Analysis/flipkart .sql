select * from flipkart ;

-- 1. Sales Performance

-- What is the total revenue generated by each laptop brand?
select brand,sum(price)total_revenue from flipkart
group by brand
order by total_revenue desc;

-- Which product has the highest sales revenue?
select product_name, (price * ratings) AS Sales_Revenue
from flipkart
order by Sales_Revenue desc
limit 1;

-- What is the average price of laptops for each brand?
select Brand, avg(price) AS Average_Price
from flipkart
group by Brand;
-- 2. Customer Behavior

-- Which laptop brands have the highest average customer ratings?
select Brand, avg(Stars) AS Avg_Star_Rating
from flipkart
group by Brand
order by Avg_Star_Rating desc;

-- What is the correlation between ratings and reviews for each brand?
select product_name, ratings, reviews, 
       round((reviews / NULLIF(ratings, 0)),3) AS Reviews_Per_Rating
from flipkart;

-- How do customer reviews vary across different laptop brands?

-- What is the average number of ratings and reviews for top-selling laptops?
select brand, product_name,ratings,reviews
from 
    flipkart
where 
    ratings >= 200
group by 
    brand, 
    product_name;

-- 3. Pricing and Discounts

-- How often do customers purchase laptops with significant discounts (e.g., above 20%)?
select brand, product_name,MRP,Discount,price from flipkart
where discount > 20
order by discount desc ;

-- Which price range has the highest number of sales?
select 
    CASE 
        WHEN price < 20000 THEN 'Under 20000'
        WHEN price BETWEEN 20000 AND 30000 THEN '20000-30000'
        WHEN price BETWEEN 30000 AND 45000 THEN '30000-45000'
        WHEN price BETWEEN 45000 AND 60000 THEN '45000-60000'
        ELSE 'Above 80000'
    END as price_range,
    SUM(ratings) as total_sales
from 
    flipkart
group by 
    price_range
order by
    total_sales desc;

-- What is the distribution of discounts across different brands?
select brand, avg(discount) as avg_discount
from flipkart
group by brand
order by avg_discount desc;

-- Are higher MRP laptops selling more frequently than mid-range or budget laptops?
select 
    CASE 
        WHEN price BETWEEN 20000 AND 30000 THEN 'Budget-laptops'
        WHEN price BETWEEN 30000 AND 45000 THEN 'Mid-range-laptop'
        WHEN price BETWEEN 45000 AND 60000 THEN 'Higer -range-laptop'
        ELSE 'Expensive-laptop'
    END as price_range,
    SUM(ratings) as total_sales
from flipkart
group by price_range
order by total_sales desc;

-- 4. Product Performance

-- Which laptops have received the highest star ratings, and what makes them popular?
select brand,product_name,stars,price,ratings,reviews
from flipkart
where stars = (select max(stars) from flipkart);

-- What are the characteristics of poorly rated laptops?
select brand,product_name,stars,price,ratings,reviews
from flipkart
where stars = (select min(stars) from flipkart);

-- 5. Brand Analysis
-- Which brand offers the highest average discount on its laptops?
SELECT product_name, Brand, 
       ROUND((dicount / NULLIF(MRP, 0)) * 100, 2) AS Discount_Percentage
FROM flipkart
ORDER BY Discount_Percentage DESC
LIMIT 10;