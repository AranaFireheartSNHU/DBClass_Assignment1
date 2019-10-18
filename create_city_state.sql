# modify my_contacts to normalize interests field
# ------------------------------------------------------------
use Normalization1;

UPDATE my_contacts
SET location = 'San Francisco, CA'
WHERE location = 'San Fran, CA';

ALTER TABLE my_contacts
ADD COLUMN city VARCHAR(25),
ADD COLUMN state VARCHAR(2),
ADD COLUMN city_ID VARCHAR(25),
ADD COLUMN state_ID VARCHAR(2);

UPDATE my_contacts
    SET city = SUBSTRING_INDEX(location, ',', 1);

UPDATE my_contacts
    SET state = TRIM(RIGHT(location, (LENGTH(location) - LENGTH(city) - 1)));

DROP TABLE IF EXISTS cities;

CREATE TABLE cities (
    city_ID INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(20)
) AS
	SELECT city FROM my_contacts
	GROUP BY city
	ORDER BY city;

DROP TABLE IF EXISTS states;

CREATE TABLE states
(
state_ID INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
state VARCHAR(2)
) AS
	SELECT state FROM my_contacts
	GROUP BY state
	ORDER BY state;

SELECT * from cities;

SELECT * from states;

UPDATE my_contacts
			INNER JOIN
			cities
		ON cities.city = my_contacts.city
		SET my_contacts.city_ID = cities.city_ID
		WHERE my_contacts.city IS NOT NULL;

UPDATE my_contacts
			INNER JOIN
			states
		ON states.state = my_contacts.state
		SET my_contacts.state_ID = states.state_ID
		WHERE my_contacts.state IS NOT NULL;

SELECT mc.first_name, mc.last_name, mc.location, c.city, s.state
FROM my_contacts AS mc
JOIN cities AS c
	ON mc.city_ID = c.city_ID
JOIN states AS s
	ON mc.state_ID = s.state_ID;

# Cleanup all tempory structures
#

# ALTER TABLE my_contacts
# DROP COLUMN location,
# DROP COLUMN city,
# DROP COLUMN state;
