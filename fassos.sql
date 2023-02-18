CREATE TABLE driver(driver_id integer,reg_date date);
INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-01-03'),
(3,'2021-01-08'),
(4,'2021-01-15');



CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 
INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');



CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 
INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 
INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');



CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2021-01-08 21:30:45','25km','25mins',null),
(8,2,'2021-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2021-01-11 18:50:20','10km','10minutes',null);



CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date DATETIME);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01 18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');



select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

use faasos

-- How many rolls where orderd--
select count(roll_id) Total_rolls_orderd from customer_orders

-- How many unique customer orders where made--
select distinct(customer_id) as unique_customer from customer_orders

-- How many successful orders where delivered by each driver--
select driver_id, count(order_id) count_order_id from driver_order
where duration is not null
group by driver_id

-- How many each types of rolls where delivered--

select roll_id,count(roll_id) as Total_rolls_orderd  from customer_orders where order_id in (

with a as (select *,
case when cancellation in ('cancellation','Customer Cancellation')
then 'c' else 'nc' end as cancelled_details from driver_order)

select order_id from a where a.cancelled_details = 'nc')

group by roll_id


-- numbers of veg and non-veg rolls where orderd by each of the customers--

with a as (select customer_id,roll_id,count(roll_id) as number_of_oredrs from customer_orders
group by customer_id,roll_id
order by roll_id desc)

select *, case when roll_id = 1 then 'Nonveg_roll' else 'veg_roll' end as roll_catagory from a

-- what was the maximum numbers of rolls delivered in a single order?-- 
select *, dense_rank() over(order by cnt desc) rnk from 

(select order_id, count(roll_id) as cnt from (
select * from customer_orders where order_id in (
with a as (select *,
case when cancellation in ('cancellation','Customer Cancellation')
then 'c' else 'nc' end as cancelled_details from driver_order)

select order_id from a where a.cancelled_details = 'nc')) b

group by order_id) c
limit 1

-- for each customer, how many delivered roll had atleast 1 change and how many has no change--

select * from customer_orders;
select * from driver;
select * from driver_order;

with new_customer_order(order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included) as (select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items = ' ' then 0 else not_include_items end as new_not_include_items,
case when extra_items_included is Null or extra_items_included = 'NaN' or extra_items_included = ' ' then 0 else extra_items_included end as new_extra_items_included
from customer_orders),

new_driver_order (order_id,driver_id,pickup_time,distance,duration,cancellation,new_cancellation) as
(select *,
case when cancellation in ('cancellation','customer cancellation') then 0 else 1 end as new_cancellation
from driver_order)

select customer_id,roll_id,changes,count(order_id) cnt from (
select *,
case when new_not_include_items = 0 and new_extra_items_included= 0 then 'No_change' else 'change' end as changes
 from new_customer_order where order_id In (select order_id from new_driver_order where new_cancellation !=0))a
group by customer_id,changes
order by cnt desc


-- How many rolls where delivered that had both exclusion and extras?--

select * from customer_orders;
select * from driver;
select * from driver_order;

select * from (

select *,
case when not_include_items is NULL or not_include_items = ' ' then '0' else '1' end as exclusion_items,
case when extra_items_included is NULL or extra_items_included = ' ' then '0' else '1' end as extra_items
from customer_orders) b 
where exclusion_items and extra_items = 1

-- Which hour is most number of rolls where orderd? --

select * from customer_orders;
select * from driver;
select * from driver_order;


select hour_bucket,count(hour_bucket) as cnt from(
select *, concat(hour(order_date),'-', hour(order_date)+1) as hour_bucket from customer_orders) a
group by hour_bucket
order by cnt desc


-- what was the number of orders for each day of the week? --

select weekday,count(distinct order_id) no_of_orders from(
select *, {fn DAYNAME(order_date)} AS weekday from customer_orders) a
group by weekday

A. Roll Matrics
B. Driver and Customer Experience
C. Ingredient optimization
D. Pricings and Ratings

-- what was the avg time in min, it took for each driver to reach the faasos HQ to pic the orders? --
select * from customer_orders;
select * from driver;
select * from driver_order;
select * from ingredients;
select * from rolls;
select * from rolls_recipes;


select round(avg(abs(timestampdiff(minute,c.order_date,d.pickup_time))),2) as avg_time_diff from customer_orders as c
join 
driver_order as d
on c.order_id = d.order_id
where d.pickup_time is not null


-- Is there any relationship between the numbers of rolls and how long the order takes to prepare --

select order_id,count(roll_id) as no_of_orders, round(sum(Time_diff)/count(roll_id),0) as time_taking_in_minutes from (
select c.order_id, c.roll_id, c.customer_id,c.order_date, d.driver_id, d.pickup_time, timestampdiff(minute,c.order_date,d.pickup_time) as Time_diff from customer_orders as c
join 
driver_order as d
on c.order_id = d.order_id
where d.pickup_time is not null) a
group by order_id


-- What was the avg distance travelled for each of the customer --
select * from customer_orders;
select * from driver_order;


select avg(new_distance) as avg_distance_km from (
select c.customer_id,c.roll_id, c.order_date, d.driver_id, d.pickup_time,d.distance, d.duration, d.cancellation, d.new_distance from customer_orders c
join
(select * , replace(distance,'km','') as new_distance from driver_order
where distance is not null and cancellation is not null) d
on c.order_id = d.order_id
group by c.order_id) a

-- What was the difference between longest and shortest distance delivery time for each of the customers order --

select * from customer_orders;
select * from driver_order;

select * from (
select max(new_duration) as max_and_min_duration from (
select c.order_id,c.customer_id, c.roll_id,c.order_date,d.driver_id, d.pickup_time,d.new_duration from customer_orders c
join
(select *, replace(y,'mins','') as new_duration from (
select *, replace(x,'minute','') as y from (
select *, replace(duration,'minutes','') as x from driver_order
where duration is not null) new) new_duration) d
on c.order_id = d.order_id
group by order_id) a) max

union

select * from (
select min(new_duration) as min_duration from (
select c.order_id,c.customer_id, c.roll_id,c.order_date,d.driver_id, d.pickup_time,d.new_duration from customer_orders c
join
(select *, replace(y,'mins','') as new_duration from (
select *, replace(x,'minute','') as y from (
select *, replace(duration,'minutes','') as x from driver_order
where duration is not null) new) new_duration) d
on c.order_id = d.order_id
group by order_id) b) min


-- What is the successfull delivery percentage for each driver --

 select * from driver_order;

select driver_id, (sum*1.0 / count)*100 cancell_per from (
select driver_id, sum(new_cancellation) as sum, count(driver_id) as count from (
select driver_id, case when cancellation like '%Cancell%' then '0' else '1' end as new_cancellation from  driver_order) a
group by driver_id) b


