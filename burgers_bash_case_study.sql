create database Burger_Case_study;

CREATE TABLE burger_names(
   burger_id   INTEGER  NOT NULL PRIMARY KEY 
  ,burger_name VARCHAR(10) NOT NULL
);
INSERT INTO burger_names(burger_id,burger_name) VALUES (1,'Meatlovers');
INSERT INTO burger_names(burger_id,burger_name) VALUES (2,'Vegetarian');

CREATE TABLE burger_runner(
   runner_id   INTEGER  NOT NULL PRIMARY KEY 
  ,registration_date date NOT NULL
);
INSERT INTO burger_runner VALUES (1,'2021-01-01');
INSERT INTO burger_runner VALUES (2,'2021-01-03');
INSERT INTO burger_runner VALUES (3,'2021-01-08');
INSERT INTO burger_runner VALUES (4,'2021-01-15');

CREATE TABLE runner_orders(
   order_id     INTEGER  NOT NULL PRIMARY KEY 
  ,runner_id    INTEGER  NOT NULL
  ,pickup_time  timestamp
  ,distance     VARCHAR(7)
  ,duration     VARCHAR(10)
  ,cancellation VARCHAR(23)
);
INSERT INTO runner_orders VALUES (1,1,'2021-01-01 18:15:34','20km','32 minutes',NULL);
INSERT INTO runner_orders VALUES (2,1,'2021-01-01 19:10:54','20km','27 minutes',NULL);
INSERT INTO runner_orders VALUES (3,1,'2021-01-03 00:12:37','13.4km','20 mins',NULL);
INSERT INTO runner_orders VALUES (4,2,'2021-01-04 13:53:03','23.4','40',NULL);
INSERT INTO runner_orders VALUES (5,3,'2021-01-08 21:10:57','10','15',NULL);
INSERT INTO runner_orders VALUES (6,3,NULL,NULL,NULL,'Restaurant Cancellation');
INSERT INTO runner_orders VALUES (7,2,'2021-01-08 21:30:45','25km','25mins',NULL);
INSERT INTO runner_orders VALUES (8,2,'2021-01-10 00:15:02','23.4 km','15 minute',NULL);
INSERT INTO runner_orders VALUES (9,2,NULL,NULL,NULL,'Customer Cancellation');
INSERT INTO runner_orders VALUES (10,1,'2021-01-11 18:50:20','10km','10minutes',NULL);

CREATE TABLE customer_orders(
   order_id    INTEGER  NOT NULL 
  ,customer_id INTEGER  NOT NULL
  ,burger_id    INTEGER  NOT NULL
  ,exclusions  VARCHAR(4)
  ,extras      VARCHAR(4)
  ,order_time  timestamp NOT NULL
);
INSERT INTO customer_orders VALUES (1,101,1,NULL,NULL,'2021-01-01 18:05:02');
INSERT INTO customer_orders VALUES (2,101,1,NULL,NULL,'2021-01-01 19:00:52');
INSERT INTO customer_orders VALUES (3,102,1,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (3,102,2,NULL,NULL,'2021-01-02 23:51:23');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,1,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (4,103,2,'4',NULL,'2021-01-04 13:23:46');
INSERT INTO customer_orders VALUES (5,104,1,NULL,'1','2021-01-08 21:00:29');
INSERT INTO customer_orders VALUES (6,101,2,NULL,NULL,'2021-01-08 21:03:13');
INSERT INTO customer_orders VALUES (7,105,2,NULL,'1','2021-01-08 21:20:29');
INSERT INTO customer_orders VALUES (8,102,1,NULL,NULL,'2021-01-09 23:54:33');
INSERT INTO customer_orders VALUES (9,103,1,'4','1, 5','2021-01-10 11:22:59');
INSERT INTO customer_orders VALUES (10,104,1,NULL,NULL,'2021-01-11 18:34:49');
INSERT INTO customer_orders VALUES (10,104,1,'2, 6','1, 4','2021-01-11 18:34:49');


      #             CASE STUDY QUESTIONS
select * from burger_names;
select * from burger_runner;
select * from customer_orders;
select * from runner_orders;

#Q1. How many burgers were ordered?
select count(*) as num_of_burgers
 from runner_orders;
 
#Q2. How many unique customer orders were made?
select count(distinct order_id) as unique_cust_order
 from customer_orders;
 
 #Q3. How many successful orders were delivered by each runner?
 select runner_id, count(distinct order_id) as successful_ordered
 from runner_orders
 where cancellation is null
 group by runner_id;
 
 #Q4. How many of each type of burger was delivered?
 select bn.burger_name, count(co.order_id) as delivered_burger_count
       from customer_orders co 
 join runner_orders ro
           on co.order_id= ro.order_id
 join burger_names bn
		   on bn.burger_id = co.burger_id
 where distance != 0
 group by bn.burger_name;
 
 #Q5. How many Vegetarian and Meatlovers were ordered by each customer?
 select co.customer_id, bn.burger_name,  count(bn.burger_name) as num_order
 from customer_orders co
 join burger_names as bn
 on co.burger_id = bn.burger_id
 group by bn.burger_name, co.customer_id
 order by co.customer_id;
 
#Q6. What was the maximum number of burgers delivered in a single order?
with burger_count_cte as
(
 select co.order_id, count(co.burger_id) as burger_per_order
 from customer_orders co
 join
 runner_orders ro on co.order_id = ro.order_id
 where distance != 0 
 group by co.order_id
 )
 select max(burger_per_order) as total_burger_delivered
 from burger_count_cte;
 
#Q7. For each customer, how many delivered burgers had at least 1 change and how many had no changes?
 select co.customer_id,
 sum(case 
         when co.exclusions != ' ' or co.extras != ' ' then 1
         else 0 
     end) as atleast_one_change,
 sum(case
         when co.exclusions = ' ' and co.extras = ' ' then 1
         else 0
	 end) as no_change
	 from customer_orders as co
		join runner_orders ro
			on co.order_id = ro.order_id
		where ro.distance != 0
	group by co.customer_id;
    
#Q8. What was the total volume of burgers ordered for each hour of the day?
 select extract(hour from order_time) as hour_of_day,
        count(order_id) as burger_count
	  from customer_orders
   group by hour_of_day
 order by hour_of_day;
 
#Q9. How many runners signed up for each 1 week period? 
select extract(week from registration_date) as regis_week,
       count(runner_id) as runner_signup
    from burger_runner
group by regis_week;

#Q10. What was the average distance travelled for each customer?
select co.customer_id, avg(ro.distance) as avg_distance
  from customer_orders co
      join runner_orders ro
         on co.order_id = ro.order_id
      where ro.distance != 0
  group by co.customer_id;



