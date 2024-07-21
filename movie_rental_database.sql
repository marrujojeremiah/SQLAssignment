CODE:
B: Transformation Code from A4


CREATE OR REPLACE FUNCTION calc_avg_per_rental(total_amount NUMERIC, total_rentals INT)  
RETURNS NUMERIC AS $$ 
BEGIN
IF total_rentals > 0 THEN
	RETURN total_amount / total_rentals;
ELSE
	RETURN 0;
END IF;
		END;
		$$ LANGUAGE plpgsql;


C: Create Detailed and Summary Tables
		
		DROP TABLE IF EXISTS detailed; -- Detailed table
		CREATE TABLE detailed (
			store_id INT,
			total_amount NUMERIC,
			total_rentals INT,
			average_rentals NUMERIC,
			store_city VARCHAR
		);

		DROP TABLE IF EXISTS summary; -- Summary table
		CREATE TABLE summary (
			store_id INT,
			total_amount NUMERIC
		);

		--Show both tables--
		SELECT * FROM detailed;
		SELECT * FROM summary;

		





D: Extract the raw data for the detailed table from source database

INSERT INTO detailed
SELECT
s.store_id,
SUM(p.amount) AS total_amount,
COUNT(DISTINCT r.rental_id) AS total_rentals,

ROUND(CASE
	WHEN COUNT(DISTINCT r.rental_id) > 0 THEN CAST(SUM(p.amount) AS NUMERIC) / COUNT(DISTINCT r.rental_id)
ELSE 0
END, 2) AS average_rentals,
	CAST(c.city AS VARCHAR) AS store_city
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY
	s.store_id, c.city;
--Check to see if detailed table has data entered—

SELECT * FROM detailed;

E: sql code in a text format that creates a trigger on the detailed table that will continue to update report.

--Trigger Function—

CREATE OR REPLACE FUNCTION update_summary_table()
RETURNS TRIGGER
AS $$
BEGIN
	IF NEW.store_id IN (1,  2) THEN
		UPDATE summary
		SET total_amount = (
			SELECT SUM(total_amount)
			FROM detailed
			WHERE store_id = NEW.store_id
		)
		WHERE store_id = NEW.store_id;

		IF NOT FOUND THEN
			INSERT INTO summary (store_id, total_amount)
			VALUES (NEW.store_id,(
				SELECT SUM(total_amount)
				FROM detailed
				WHERE store_id = NEW.store_id
		));
              END IF;
                    ELSE
	INSERT INTO summary (store_id, total_amount)
	VALUES (NEW.store_id, NEW.total_amount);
       END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;

--Trigger Statement—

CREATE TRIGGER trigger_update_summary
AFTER INSERT ON detailed
FOR EACH ROW
EXECUTE PROCEDURE update_summary_table();


F: Stored procedure in a text format that will refresh both tables. Clear data and perform raw data extraction from part D.

CREATE OR REPLACE PROCEDURE refresh_data()
AS
$$
BEGIN

DELETE FROM detailed; 
DELETE FROM summary;

INSERT INTO detailed(store_id, total_amount, total_rentals, average_rentals, store_city)
SELECT
s.store_id,
SUM(p.amount) AS total_amount,
COUNT(DISTINCT r.rental_id) AS total_rentals,
ROUND(CASE
	WHEN COUNT(DISTINCT r.rental_id) > 0 THEN
	        CAST(SUM(p.amount) AS NUMERIC)  /  COUNT(DISTINCT r.rental_id)
	ELSE 0
	END, 2) AS average_rentals,
	CAST(c.city AS VARCHAR) AS store_city
	FROM payment p
	JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id
	JOIN store s ON i.store_id = s.store_id
	JOIN address a ON s.address_id = a.address_id
	JOIN city c ON a.city_id = c.city_id
	GROUP BY s.store_id, c.city;

	
INSERT INTO summary(store_id, total_amount)
SELECT 
store_id,
SUM(total_amount) AS total_amount
FROM detailed 
GROUP BY store_id;

END;
$$
LANGUAGE plpgsql; 

--Verify by adding a value—

INSERT INTO detailed(store_id, total_amount, total_rentals, average_rentals, store_city)
VALUES
	(3, 1250.00, 250, 5.00, ‘San Diego’);

--Verify the added values—

SELECT * FROM detailed;

--Verify trigger in summary table—
SELECT * FROM summary;

--Refreshing—
CALL refresh_data();

--Verify both tables are refreshed—
SELECT * FROM detailed
WHERE store_id = 3;

SELECT * FROM detailed;
SELECT * FROM summary;
"Added SQL code for movie rental database project."
