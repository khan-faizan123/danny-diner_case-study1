use dannys_diner;


-- 1.What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as total_amount_spent from menu m
join sales s on s.product_id = m.product_id
group by s.customer_id;

-- 2.How many days has each customer visited the restaurant?

select customer_id, COUNT(DISTINCT order_date) AS days_visited from sales
group by customer_id;

-- 3.What was the first item from the menu purchased by each customer?

with cte as (
select s.customer_id, m.product_name,
row_number() over (partition by s.customer_id order by s.customer_id) as purchase_rank from sales s
join menu m on s.product_id = m.product_id)

select customer_id, product_name as first_purchased from cte
where purchase_rank = 1;


-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name, count(*) as time_purchased from sales s
join menu m on m.product_id = s.product_id
group by m.product_name
order by count(*) desc
limit 1;

-- 5.Which item was the most popular for each customer?


with cte as (
select s.customer_id, m.product_name, count(*) as purchase_cnt,
rank() over (partition by s.customer_id order by count(*) desc, m.product_name) as popularity from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name)

select customer_id, product_name
from cte
where popularity = 1;

-- 6.Which item was purchased first by the customer after they became a member?
﻿
with cte as (
select
s.customer_id,s.order_date,m.product_name,mb.join_date,
row_number() over(partition by s.customer_id order by s.order_date) as purchased_rank from sales s
join menu m on m.product_id = s.product_id
join members mb on mb.customer_id = s.customer_id
where s.order_date >= mb.join_date)

select customer_id, product_name from cte
where purchased_rank = 1;

-- 7.Which item was purchased just before the customer became a member?

with cte as (
select
s.customer_id,s.order_date,m.product_name,
row_number() over (partition by s.customer_id order by s.order_date desc) as first_purchased from sales s
join menu m on m.product_id = s.product_id
join members mb on mb.customer_id = s.customer_id
where s.order_date < mb.join_date)

select customer_id, product_name as product_before_membership from cte
where first_purchased = 1;

-- 8.What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(*) as total_items, sum(price) as amount_spent from sales s
join menu m on m.product_id = s.product_id
join members mb on mb.customer_id = s.customer_id
where s.order_date <mb.join_date
group by s.customer_id
order by s.customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id,
sum(case when m.product_name = 'sushi' then 2* m.price* 10 else m.price* 10 end ) as points from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;
-- order by points desc;

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

select s.customer_id,
sum(case when order_date <= date_add(join_date, interval 1 week)
then 2 * m.price* 10 -- they earn 2x points on all items
else m.price* 10 -- regular price
end) as total_points
from sales s
join menu m on m.product_id = s.product_id
join members mb on mb.customer_id = s.customer_id
group by s.customer_id
order by s.customer_id;
