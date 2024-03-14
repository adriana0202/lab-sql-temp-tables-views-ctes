-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

-- Step 1. create query

select c.customer_id as customer_id, concat(c.first_name,"  ", c.last_name) as name, c.email as email_address, count(r.rental_id) as rental_count
from sakila.rental r
join sakila.customer c
	on r.customer_id = c.customer_id

group by 1, 2, 3;

-- Step 2. create view 

create view rental_info_summary_view as 
select c.customer_id as customer_id, concat(c.first_name,"  ", c.last_name) as name, c.email as email_address, count(r.rental_id) as rental_count
from sakila.rental r
join sakila.customer c
	on r.customer_id = c.customer_id
    group by 1, 2, 3;
    
    
select * from rental_info_summary_view;


-- Step 2: Create a Temporary Table

create temporary table rental_info_temp_table as 
select c.customer_id as customer_id, concat(c.first_name,"  ", c.last_name) as name, c.email as email_address, count(r.rental_id) as rental_count
from sakila.rental r
join sakila.customer c
	on r.customer_id = c.customer_id
    group by 1, 2, 3;
    
    select * from rental_info_temp_table;

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should -- use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

create temporary table total_amount_paid as 
select p.customer_id as customer, sum(p.amount) as total_paid
from rental_info_summary_view sum_view
join payment p
	on sum_view.customer_id = p.customer_id
    group by p.customer_id
    order by customer, total_paid desc;
    
    select * from total_amount_paid; 

-- query to compare reults - (ok)
select *, sum(amount) over (partition by customer_id) as total_amount_paid
from payment;

-- Step 3: Create a CTE and the Customer Summary Report

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
select count(8) from customer;

select * from rental_info_summary_view; 
select * from total_amount_paid;

with cust_summary as (
select re.name, re.email_address, re.rental_count , t.total_paid
from rental_info_summary_view re
join total_amount_paid t
on re.customer_id = t.customer
)
select * from cust_summary; 

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

with cust_summary as (
select re.name, re.email_address, re.rental_count , t.total_paid
from rental_info_summary_view re
join total_amount_paid t
on re.customer_id = t.customer
)
select name, email_address, rental_count, total_paid, round( avg(total_paid)over (partition by rental_count) , 2) as average_payment_per_rental from cust_summary;