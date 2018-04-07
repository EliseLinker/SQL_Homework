
USE sakila;

#1a Display the first and last name of all actors from the actors table 
SELECT first_name, last_name 
FROM actor; 

#1b Display the first and last name of each actorin a simgle column in Upper case Actor Name 
SELECT  CONCAT(UPPER(first_name),' ',  UPPER(last_name)) AS `Actor Name`
from actor; 

# 2a. You need to find the ID number, first name, and last name of an actor, 
#of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
where first_name like '%Joe%';

  	
# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * 
FROM actor 
WHERE last_name like '%GEN%';
  	
# 2c. Find all actors whose last names contain the letters `LI`. 
#This time, order the rows by last name and first name, in that order:
SELECT * 
FROM actor
WHERE last_name like '%LI%';

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
#Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM  country 
WHERE country in ('Afghanistan', 'Bangladesh', 'China');


# 3a. Add a `middle_name` column to the table `actor`. 
#Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
 ALTER TABLE actor 
 ADD COLUMN middle_name varchar(45) AFTER first_name; 
 
 
# 3b. You realize that some of these actors have tremendously long last names. 
#Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor 
DROP INDEX actor.idx_actor_last_name;

ALTER TABLE actor 
MODIFY COLUMN last_name BLOB;

# 3c. Now delete the `middle_name` column.
ALTER TABLE actor 
DROP Column middle_name;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) 
from actor 
group by last_name 
order by last_name; 
  	
# 4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor 
GROUP BY last_name 
HAVING count(*) > 2; 
  	
# 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` 
#table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
#Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;

UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

SELECT * 
FROM actor 
WHERE last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
#It turns out that `GROUCHO` was the correct name after all! In a single query, 
#if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
#Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor 
#will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY 
#ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor 
SET first_Name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' 
					ELSE 'MUCHO GROUCHO'
                    END
WHERE actor_id = 172;

SELECT * 
FROM actor 
WHERE actor_id = 172;

SELECT * 
FROM actor
where first_name = 'Mucho GROUCHO';
 

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 

  # Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
  #(https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

SHOW CREATE TABLE address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, 
#of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address 
FROM STAFF s 
JOIN address a 
ON s.address_id = a.address_id;


# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
#Use tables `staff` and `payment`. 
 
 SELECT payment_date 
 FROM payment 
 order by payment_date;
 
 SELECT first_name, last_name, SUM(amount)
 from staff s 
 join payment p 
 on s.staff_id = p.staff_id 
 where payment_date between '2005-08-01' and '2005-08-30'
 group by first_name, last_name;
 
# 6c. List each film and the number of actors who are listed for that film. 
#Use tables `film_actor` and `film`. Use inner join.
 SELECT title, count(*) 
 from film f 
 join film_actor fa 
 on f.film_id = fa.film_id
 GROUP BY title
 ORDER BY title; 
 
# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(*) 
FROM inventory 
where film_id in 
	(
	SELECT film_id
	FROM film
	WHERE title = 'Hunchback Impossible'
    );


# 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
#list the total paid by each customer. List the customers alphabetically by last name:

#  ```
#  	![Total amount paid](Images/total_payment.png)
#  ```

SELECT first_name, last_name, sum(amount) 
FROM customer c 
JOIN payment p 
ON c.customer_id = p.customer_id 
GROUP BY p.customer_id 
order by last_name ;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters `K` and `Q` have also 
#soared in popularity. Use subqueries to display the titles of movies starting with the 
#letters `K` and `Q` whose language is English. 

SELECT title 
from film 
where title like 'K%' 
or title like 'Q%'
and language_id in 
	(
	SELECT language_id
	FROM language 
	where name = 'ENGLISH'
	);


# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name 
from actor 
where actor_id in 
	(
	select actor_id 
	from film_actor 
	where film_id in 
		(
		SELECT film_id 
		from film 
		where title = 'Alone Trip'
		)
	);

   
# 7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

select first_name, last_name, email 
from customer 
where address_id in 
	(
	select address_id 
	from address 
	where address_id in 
		(
		select city_id 
		from city 
		where country_id in 
			(
			select country_id 
			from country 
			where country = 'Canada'
			)
		)
	)
;



# 7d. Sales have been lagging among young families, 
#and you wish to target all family movies for a promotion. 
#Identify all movies categorized as famiy films.

SELECT title 
from film 
where film_id in 
	(
    select film_id 
	from film_category 
	where category_id in 
		(
		SELECT category_id 
		from category 
		where name = 'Family'
		)
	)
    ;



# 7e. Display the most frequently rented movies in descending order.
#get the max rec count
#get inventory_id that matches the max reccnt 

create view vw_rental_max_rentals as 
SELECT inventory_id, count(*) as reccnt 
from rental 
GROUP BY inventory_id 
order by reccnt desc ;

select max(reccnt) 
from vw_rental_max_rentals;

SELECT title 
from film 
where film_id in 
	(
	select DISTINCT film_id  
	from inventory 
	where inventory_id in 
		(
		select inventory_id
		from vw_rental_max_rentals 
		where reccnt = 5
			)
	)
ORDER BY title desc 
;	
    


  	
# 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) 
from store s 
left join customer c 
on s.store_id = c.store_id 
left join payment p 
on c.customer_id = p.customer_id
group by s.store_id 
; 

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cy.country 
FROM store s 
left join address a 
on s.address_id = a.address_id 
left join city c 
on a.city_id = c.city_id 
left join country cy 
on c.country_id = cy.country_id; 
 	
# 7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)

select c.name, sum(p.amount)
FROM category c 
left join film_category fc 
on c.category_id = fc.category_id 
left join inventory i 
on fc.film_id = i.film_id 
left join rental r 
on i.inventory_id = r.inventory_id 
left join payment p 
on r.rental_id = p.rental_id 
group by c.name 
order by sum(p.amount) desc 
limit 5;


  	



# 8a. In your new role as an executive, you would like to have an easy way of viewing the 
#Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

create view vw_top_five_genres_by_gross_revenue as 
select c.name, sum(p.amount)
FROM category c 
left join film_category fc 
on c.category_id = fc.category_id 
left join inventory i 
on fc.film_id = i.film_id 
left join rental r 
on i.inventory_id = r.inventory_id 
left join payment p 
on r.rental_id = p.rental_id 
group by c.name 
order by sum(p.amount) desc 
limit 5;

  	
# 8b. How would you display the view that you created in 8a?
select * from vw_top_five_genres_by_gross_revenue;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
Drop view vw_top_five_genres_by_gross_revenue;


### Appendix: List of Tables in the Sakila DB

# A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

#```sql
#	'actor'
#	'actor_info'
#	'address'
#	'category'
#	'city'
#	'country'
#	'customer'
#	'customer_list'
#	'film'
#	'film_actor'
#	'film_category'
#	'film_list'
#	'film_text'
#	'inventory'
#	'language'
#	'nicer_but_slower_film_list'
#	'payment'
#	'rental'
#	'sales_by_film_category'
#	'sales_by_store'
#	'staff'
#	'staff_list'
#	'store'
#```

