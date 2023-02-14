--Solutions for Danny's Diner SQL Questions tailored for BigQuery--

--1. What is the total amount each customer spent at the restaurant--
SELECT customer_id, SUM(price) AS total_sales
FROM `dannys_diner.sales` as s
JOIN `dannys_diner.menu` as m
  on s.product_id = m.product_id
GROUP by customer_id

--2. How many days has each customer visited the restaurant?--
SELECT customer_id, COUNT(distinct(order_date)) AS days_visted
FROM `dannys_diner.sales`
GROUP BY customer_id

--3. What was the first item from the menu purchased by each customer?--
WITH ordered_sales AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY order_date) AS rank
   FROM `dannys_diner.sales` AS s
   INNER JOIN `dannys_diner.menu` AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name, order_date;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?--
SELECT (COUNT(s.product_id)) AS most_purchased, product_name
FROM `dannys_diner.sales` AS s
JOIN `dannys_diner.menu` AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1

--5. Which item was the most popular for each customer?--
WITH fav_product AS
(
   SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY COUNT(s.customer_id) DESC) AS rank
   FROM `dannys_diner.menu` AS m
   LEFT JOIN `dannys_diner.sales` AS s
      ON s.product_id = m.product_id
   GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, order_count
FROM fav_product
WHERE rank = 1;

--6. Which item was purchased first by the customer after they became a member?--
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

--7. Which item was purchased just before the customer became a member?--
WITH prior_member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date DESC) AS rank
   FROM `dannys_diner.sales` AS s
   INNER JOIN `dannys_diner.members` AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT s.customer_id, s.order_date, m2.product_name 
FROM prior_member_sales AS s
INNER JOIN `dannys_diner.menu` AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;

--8. What is the total items and amount spent for each member before they became a member?--
SELECT s.customer_id, COUNT(DISTINCT s.product_id) AS unique_menu_item, 
   SUM(m2.price) AS total_sales
FROM `dannys_diner.sales` AS s
JOIN `dannys_diner.members` AS m
   ON s.customer_id = m.customer_id
JOIN `dannys_diner.menu` AS m2
   ON s.product_id = m2.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?--
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

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?--
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

--11. Join all the things
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

--Rank all the things
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