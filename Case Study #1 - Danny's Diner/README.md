# 🍜 Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)

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
```
 
## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
