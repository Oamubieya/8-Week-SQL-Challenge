# Case Study #1: Danny's Diner 
[![logo](https://user-images.githubusercontent.com/105673465/218287230-c629e5dc-068e-40b0-af63-f1d31948c770.png)](https://8weeksqlchallenge.com/case-study-1/)


## Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Datasets](#datasets)
- [Process](#process)
- [Case Study Questions](#case-study-questions)
- [Solutions](#solutions)

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

## Datasets
There are 3 datasets given by Danny. Those tables are sales, members and menu.
### Sales
The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

![Sales Table](https://user-images.githubusercontent.com/105673465/218285672-136d63e7-278d-40b8-b08a-76f34ff62c2f.png)

### Menu
The menu table maps the product_id to the actual product_name and price of each menu item.

![Menu Table](https://user-images.githubusercontent.com/105673465/218285675-cc1d2516-0a61-4582-9980-dad0d11f7cc7.png)

### Members
The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

![Members Table](https://user-images.githubusercontent.com/105673465/218285678-7cc762cd-75bf-4978-8306-1c37a98535e9.png)

## Process
In order to analyze the data I first had to create the tables in SQL (Bigquery). Instead of uploading the 3 tables I created 3 blank tables and manually inserted the data. The schema for the tables were

![sales schema](https://user-images.githubusercontent.com/105673465/218286239-8b46978e-75d3-4c81-9ed7-3e8a93588af7.png)
![menu schema](https://user-images.githubusercontent.com/105673465/218286244-0aa2154b-8295-4e6e-883d-cb9abdbd3408.png)
![members schema](https://user-images.githubusercontent.com/105673465/218286245-2d9d68d0-036a-4e5f-8384-3a915ef5a5c4.png)

```TSQL
--Inserting data into the sales table--
INSERT INTO `dannys_diner.sales`;
  (`customer_id`, `order_date`, `product_id`)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
--Inserting data into the menu table--
INSERT INTO `dannys_diner.menu`
  (`product_id`, `product_name`, `price`)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
--Inserting data into the members table--
INSERT INTO `dannys_diner.members`
  (`customer_id`, `join_date`)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
```
 
## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## Bonus Questions
11. Join all the things - Recreate the following table output using the available data.
![join all things table](https://user-images.githubusercontent.com/105673465/218837465-e3a95862-9179-4c2d-8310-f8aad036bba5.png)

12. Rank all the things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
![rank all things table](https://user-images.githubusercontent.com/105673465/218837516-18a5d859-4323-4358-9fb5-fcfa1f9f7da2.png)


## Solutions

<details>
<summary>
View Answers Here
</summary>
  
### 1. What is the total amount each customer spent at the restaurant?
Customer A spent $76, Customer B spent $74 and Customer C spent $36
```TSQL
SELECT customer_id, SUM(price) AS total_sales
FROM `dannys_diner.sales` as s
JOIN `dannys_diner.menu` as m
  on s.product_id = m.product_id
GROUP by customer_id
```
### 2. How many days has each customer visited the restaurant?
Customer A visted the diner 4 times, Customer B visted 6 times and Customer C visited 2 times.
```TSQL
SELECT customer_id, COUNT(distinct(order_date)) AS days_visted
FROM `dannys_diner.sales`
GROUP BY customer_id
```
### 3. What was the first item from the menu purchased by each customer?
Customer A's first orders were curry and sushi, Customer B's first order was curry and Customer C's first order was ramen.
```TSQL
WITH ordered_sales AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY order_date) AS rank
   FROM `dannys_diner.sales` AS s
   FULL JOIN `dannys_diner.menu` AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name, order_date;
```
### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
The most purchased item on the menu was ramen and it was ordered 8 times.
```TSQL
SELECT (COUNT(s.product_id)) AS most_purchased, product_name
FROM `dannys_diner.sales` AS s
JOIN `dannys_diner.menu` AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1
```
### 5. Which item was the most popular for each customer?
Customer A and C's favorite item is ramen while Customer B enjoys all items.
```TSQL
WITH fav_product AS
(
   SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY COUNT(s.customer_id) DESC) AS rank
   FROM `dannys_diner.menu` AS m
   JOIN `dannys_diner.sales` AS s
      ON m.product_id = s.product_id
   GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM fav_product
WHERE rank = 1;
```
### 6. Which item was purchased first by the customer after they became a member?
Customer A's first order as a member was curry and Customer B's first order as a member was sushi.
```TSQL
WITH member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rank
   FROM `dannys_diner.sales` AS s
   JOIN `dannys_diner.members` AS m
      ON m.customer_id = s.customer_id
   WHERE s.order_date >= m.join_date
)

SELECT s.customer_id, s.order_date, m2.product_name 
FROM member_sales AS s
JOIN `dannys_diner.menu` AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
```
### 7. Which item was purchased just before the customer became a member?
Customer A's last order before becoming a member was sushi and curry while Customer B's last order before becoming a member was Sushi.
```TSQL
WITH prior_member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date DESC) AS rank
   FROM `dannys_diner.sales` AS s
   JOIN `dannys_diner.members` AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT s.customer_id, s.order_date, m2.product_name 
FROM prior_member_sales AS s
JOIN `dannys_diner.menu` AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
```
### 8. What is the total items and amount spent for each member before they became a member?
Before becoming members Customer A spent $25 on 2 items and Customer B spent $40 on 2 items.
```TSQL
SELECT s.customer_id, COUNT(DISTINCT s.product_id) AS unique_menu_item, 
   SUM(m2.price) AS total_sales
FROM `dannys_diner.sales` AS s
JOIN `dannys_diner.members` AS m
   ON s.customer_id = m.customer_id
JOIN `dannys_diner.menu` AS m2
   ON s.product_id = m2.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
```
### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Customer A has 860 points, Customer B has 940 points and Customer C has 360 points.
```TSQL
WITH points AS
(
   SELECT *, 
      CASE
         WHEN product_id = 1 THEN price * 20
         ELSE price * 10
      END AS p_points
   FROM `dannys_diner.menu`
)

SELECT s.customer_id, SUM(p_points) AS total_points
FROM points AS p
JOIN `dannys_diner.sales` AS s
   ON p.product_id = s.product_id
GROUP BY s.customer_id
```
### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
The total points for Customer A is 1370 and the Total points for Customer B is 820.
```TSQL
WITH jan_date AS
(
  SELECT *,
    DATE_ADD(join_date, INTERVAl +6 day) AS valid_date,
    LAST_DAY('2021-01-31') AS last_date
  FROM `dannys_diner.members` AS m
)

SELECT s.customer_id,
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
    ELSE m.price * 10
    END
    ) AS points
FROM jan_date d
JOIN `dannys_diner.sales` AS s
  ON d.customer_id = s.customer_id
JOIN `dannys_diner.menu` AS m
  ON m.product_id = s.product_id
WHERE s.order_date < d.last_date
GROUP BY s.customer_id
```
### 11. Join all the things
```TSQL
SELECT s.customer_id, s.order_date, m.product_name, m.price,
   CASE
      WHEN m2.join_date > s.order_date THEN 'N'
      WHEN m2.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
      END AS member
FROM `dannys_diner.sales` AS s
LEFT JOIN `dannys_diner.menu` AS m
   ON s.product_id = m.product_id
LEFT JOIN `dannys_diner.members` AS m2
   ON s.customer_id = m2.customer_id
```
### 12. Rank all the things
```TSQL
WITH rankings AS 
(
   SELECT s.customer_id, s.order_date, m.product_name, m.price,
      CASE
      WHEN m2.join_date > s.order_date THEN 'N'
      WHEN m2.join_date <= s.order_date THEN 'Y'
      ELSE 'N' END AS member
   FROM `dannys_diner.sales` AS s
   LEFT JOIN `dannys_diner.menu` AS m
      ON s.product_id = m.product_id
   LEFT JOIN `dannys_diner.members` AS m2
      ON s.customer_id = m2.customer_id
)

SELECT *, CASE
   WHEN member = 'N' then NULL
   ELSE
      RANK () OVER(PARTITION BY customer_id, member
      ORDER BY order_date) END AS ranking
FROM rankings;
```
</details>
