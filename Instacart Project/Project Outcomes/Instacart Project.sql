use instamart;
-- Total number of orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM instacart_orders;

-- Total number of users
SELECT COUNT(DISTINCT user_id) AS total_users
FROM instacart_orders;

-- Total number of products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM products;

-- Orders per user
SELECT user_id, COUNT(order_id) AS orders_count
FROM instacart_orders
GROUP BY user_id;

-- Average orders per user
SELECT AVG(order_count) AS avg_orders_per_user
FROM (
    SELECT user_id, COUNT(order_id) AS order_count
    FROM instacart_orders
    GROUP BY user_id
) t;

-- PHASE 2: CUSTOMER BEHAVIOR
-- Average days between orders
SELECT AVG(days_since_prior_order) AS avg_days_between_orders
FROM instacart_orders
WHERE days_since_prior_order IS NOT NULL;

-- Users with longest gap between orders
SELECT user_id, MAX(days_since_prior_order) AS max_gap
FROM instacart_orders
GROUP BY user_id
ORDER BY max_gap DESC;

-- New vs returning users
SELECT
    CASE 
        WHEN order_number = 1 THEN 'New User'
        ELSE 'Returning User'
    END AS user_type,
    COUNT(*) AS total_orders
FROM instacart_orders
GROUP BY user_type;

-- PHASE 3: ORDER ANALYSIS
-- Orders by day of week
SELECT order_dow, COUNT(order_id) AS total_orders
FROM instacart_orders
GROUP BY order_dow
ORDER BY total_orders DESC;

-- Orders by hour of day
SELECT order_hour_of_day, COUNT(order_id) AS total_orders
FROM instacart_orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;

-- Peak ordering hour
SELECT order_hour_of_day, COUNT(*) AS orders
FROM instacart_orders
GROUP BY order_hour_of_day
ORDER BY orders DESC
LIMIT 1;

-- Average products per order
SELECT AVG(product_count) AS avg_products_per_order
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products
    GROUP BY order_id
) t;

-- Largest orders (by product count)
SELECT order_id, COUNT(product_id) AS product_count
FROM order_products
GROUP BY order_id
ORDER BY product_count DESC;

-- PHASE 4: PRODUCT ANALYSIS
-- Top 10 most ordered products
SELECT p.product_name, COUNT(*) AS total_orders
FROM order_products op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC
LIMIT 10;

-- Products rarely reordered
SELECT p.product_name, AVG(op.reordered) AS reorder_rate
FROM order_products op
JOIN products p ON op.product_id = p.product_id
GROUP BY p.product_name
HAVING reorder_rate < 0.1
ORDER BY reorder_rate;

-- First product ordered by each user
SELECT o.user_id, p.product_name
FROM instacart_orders o
JOIN order_products op ON o.order_id = op.order_id
JOIN products p ON op.product_id = p.product_id
WHERE o.order_number = 1;

-- Products frequently bought together
SELECT
    op1.product_id AS product_1,
    op2.product_id AS product_2,
    COUNT(*) AS frequency
FROM order_products op1
JOIN order_products op2
    ON op1.order_id = op2.order_id
   AND op1.product_id < op2.product_id
GROUP BY product_1, product_2
ORDER BY frequency DESC;

-- PHASE 5: DEPARTMENT & AISLE ANALYSIS
-- Aisles with highest reorder rate
SELECT a.aisle, AVG(op.reordered) AS reorder_rate
FROM order_products op
JOIN products p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY reorder_rate DESC;

-- Department-wise avg products per order
SELECT d.department, AVG(product_count) AS avg_products
FROM (
    SELECT order_id, p.department_id, COUNT(*) AS product_count
    FROM order_products op
    JOIN products p ON op.product_id = p.product_id
    GROUP BY order_id, p.department_id
) t
JOIN departments d ON t.department_id = d.department_id
GROUP BY d.department;

-- PHASE 6: ADVANCED CUSTOMER INSIGHTS
-- Top 10 power users
SELECT user_id, COUNT(order_id) AS total_orders
FROM instacart_orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;

-- Customers at churn risk (no recent orders)
SELECT user_id, MAX(days_since_prior_order) AS last_gap
FROM instacart_orders
GROUP BY user_id
HAVING last_gap > 30
ORDER BY last_gap DESC;

 