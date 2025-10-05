create database pizzahut;
use pizzahut;
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza
SELECT 
    pizza_id, price
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT 
    p.size, COUNT(od.order_details_id) AS total_order
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_order DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities
SELECT 
    p.pizza_type_id, COUNT(od.quantity) AS total_order
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.pizza_type_id
ORDER BY total_order DESC
LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC; 

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(time), COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Quantity 
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_order_per_day
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time
select date, round(sum(revenue) over(order by date ),2) as cum_revenue from (select o.date, SUM(od.quantity * p.price) AS revenue from orders o join order_details od on o.order_id = od.order_id join pizzas p on od.pizza_id =p.pizza_id group by o.date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, revenue 
from 
(SELECT category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category , pt.name) as a) as b where rn<=3;
 