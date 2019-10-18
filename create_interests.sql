# modify my_contacts to normalize interests field
# ------------------------------------------------------------
use Normalization1;

ALTER TABLE my_contacts
ADD COLUMN interestsCopy VARCHAR(200),
ADD COLUMN interest1 VARCHAR(50),
ADD COLUMN interest2 VARCHAR(50),
ADD COLUMN interest3 VARCHAR(50),
ADD COLUMN interest4 VARCHAR(50);

UPDATE my_contacts
SET interestsCopy = interests;


UPDATE my_contacts
SET interest1 = SUBSTRING_INDEX(interestsCopy, ',', 1);
UPDATE my_contacts SET interestsCopy = TRIM(RIGHT(interestsCopy,
(LENGTH(interestsCopy) - LENGTH(interest1) - 1)));

UPDATE my_contacts
SET interest2 = SUBSTRING_INDEX(interestsCopy, ',', 1);
UPDATE my_contacts SET interestsCopy = TRIM(RIGHT(interestsCopy,
(LENGTH(interestsCopy) - LENGTH(interest2) - 1)));

UPDATE my_contacts
SET interest3 = SUBSTRING_INDEX(interestsCopy, ',', 1);
UPDATE my_contacts SET interestsCopy = TRIM(RIGHT(interestsCopy,
(LENGTH(interestsCopy) - LENGTH(interest3) - 1)));

UPDATE my_contacts SET interest4 = interestsCopy;

DROP TABLE IF EXISTS temp_interests;

CREATE TABLE temp_interests
AS
	SELECT interest1 AS interest FROM my_contacts
	GROUP BY interest
	ORDER BY interest;

SELECT * from temp_interests;

INSERT INTO temp_interests (interest)
	SELECT interest2 FROM my_contacts
	GROUP BY interest2;

INSERT INTO temp_interests (interest)
	SELECT interest3 FROM my_contacts
	GROUP BY interest3;

INSERT INTO temp_interests (interest)
	SELECT interest4 FROM my_contacts
	GROUP BY interest4;

DELETE FROM temp_interests
    WHERE TRIM(interest) = '';

DELETE FROM temp_interests
    WHERE interest IS NULL;

SELECT * from temp_interests;

DROP TABLE IF EXISTS interests;

CREATE TABLE interests
(
interest_ID INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
interest VARCHAR(20)
) AS
	SELECT interest FROM temp_interests
	GROUP BY interest
	ORDER BY interest;


SELECT * from interests;

DROP TABLE IF EXISTS contacts_interests;

CREATE TABLE contacts_interests (
    interest_ID INT(11) NOT NULL,
    CONSTRAINT interests_contact_interest_fk
    FOREIGN KEY (interest_ID)
    REFERENCES interests (interest_ID),

    contacts_ID INT(11) NOT NULL,
    CONSTRAINT my_contacts_contact_interest_fk
    FOREIGN KEY (contacts_ID)
    REFERENCES my_contacts (contacts_ID)
);

INSERT INTO contacts_interests (contacts_ID, interest_ID)
    SELECT mc.contacts_ID, intr.interest_ID FROM my_contacts AS mc
    JOIN interests AS intr
    ON mc.interest1 = intr.interest
    WHERE interest1 != ""
    AND interest1 IS NOT NULL;


INSERT INTO contacts_interests (contacts_ID, interest_ID)
    SELECT mc.contacts_ID, intr.interest_ID FROM my_contacts AS mc
    JOIN interests AS intr
    ON mc.interest2 = intr.interest
    WHERE interest2 != ""
    AND interest2 IS NOT NULL;


INSERT INTO contacts_interests (contacts_ID, interest_ID)
    SELECT mc.contacts_ID, intr.interest_ID FROM my_contacts AS mc
    JOIN interests AS intr
    ON mc.interest3 = intr.interest
    WHERE interest3 != ""
    AND interest3 IS NOT NULL;


INSERT INTO contacts_interests (contacts_ID, interest_ID)
    SELECT mc.contacts_ID, intr.interest_ID FROM my_contacts AS mc
    JOIN interests AS intr
    ON mc.interest4 = intr.interest
    WHERE interest4 != ""
    AND interest4 IS NOT NULL;

SELECT * FROM interests;

SELECT first_name, last_name, contacts_ID, interest1, interest2, interest3, interest4
    FROM my_contacts;

SELECT mc.first_name, mc.last_name, mc.contacts_ID, i.interest
    FROM my_contacts AS mc
    INNER JOIN
    interests AS i
    ON contacts_ID = interest_ID;

# Cleanup all temporary structures
#
# DROP TABLE IF EXISTS temp_interests;

# ALTER TABLE my_contacts
# DROP COLUMN interests,
# DROP COLUMN interestsCopy,
# DROP COLUMN interest1,
# DROP COLUMN interest2,
# DROP COLUMN interest3,
# DROP COLUMN interest4;

SELECT ci.contacts_ID, ci.interest_ID, mc.first_name, mc.last_name, intr.interest
    FROM contacts_interests AS ci
    JOIN my_contacts AS mc
    ON ci.contacts_ID = mc.contacts_ID
    JOIN interests AS intr
    ON ci.interest_ID = intr.interest_ID
    ORDER BY mc.last_name;
