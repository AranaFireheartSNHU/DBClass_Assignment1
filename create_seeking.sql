# modify my_contacts to normalize seeking field
# ------------------------------------------------------------
use Normalization1;

ALTER TABLE my_contacts
    ADD COLUMN seekingCopy VARCHAR(100),
    ADD COLUMN seeking1 VARCHAR(100),
    ADD COLUMN seeking2 VARCHAR(100);

UPDATE my_contacts
SET seekingCopy = seeking;


UPDATE my_contacts
    SET seeking1 = SUBSTRING_INDEX(seekingCopy, ',', 1);

UPDATE my_contacts SET seekingCopy = TRIM(RIGHT(seekingCopy,
    (LENGTH(seekingCopy) - LENGTH(seeking1) - 1)));

UPDATE my_contacts SET seeking2 = seekingCopy;

DROP TABLE IF EXISTS temp_seeking;

CREATE TABLE temp_seeking
AS
	SELECT seeking1 AS seeking FROM my_contacts
	GROUP BY seeking1
	ORDER BY seeking1;

SELECT * from temp_seeking;

INSERT INTO temp_seeking (seeking)
	SELECT seeking2 FROM my_contacts
	GROUP BY seeking2;

DELETE FROM temp_seeking
WHERE
seeking = ' ';

DELETE FROM temp_seeking
WHERE
seeking IS NULL;

SELECT * from temp_seeking;

DROP TABLE IF EXISTS seeking;

CREATE TABLE seeking
(
seeking_ID INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
seeking VARCHAR(100)
) AS
	SELECT seeking FROM temp_seeking
	GROUP BY seeking
	ORDER BY seeking;

SELECT * from seeking;

DROP TABLE IF EXISTS contacts_seeking;

CREATE TABLE contacts_seeking (
    seeking_ID INT(11) NOT NULL,
    CONSTRAINT seeking_seeking_my_contact_fk
    FOREIGN KEY (seeking_ID)
    REFERENCES seeking (seeking_ID),

    contacts_ID INT(11) NOT NULL,
    CONSTRAINT my_contacts_contact_seeking_fk
    FOREIGN KEY (contacts_ID)
    REFERENCES my_contacts (contacts_ID)
);

INSERT INTO contacts_seeking (contacts_ID, seeking_ID)
    SELECT mc.contacts_ID, sk.seeking_ID FROM my_contacts AS mc
    JOIN seeking AS sk
    ON mc.seeking1 = sk.seeking
    WHERE TRIM(seeking1) != ""
    AND seeking1 IS NOT NULL;


INSERT INTO contacts_seeking (contacts_ID, seeking_ID)
    SELECT mc.contacts_ID, sk.seeking_ID FROM my_contacts AS mc
    JOIN seeking AS sk
    ON mc.seeking2 = sk.seeking
    WHERE TRIM(seeking2) != ""
    AND seeking2 IS NOT NULL;


SELECT * FROM seeking;

SELECT first_name, last_name, contacts_ID, seeking1, seeking2
    FROM my_contacts;

SELECT mc.first_name, mc.last_name, mc.contacts_ID, s.seeking
    FROM my_contacts AS mc
    INNER JOIN
    seeking AS s
    ON contacts_ID = seeking_ID;

# Cleanup all tempory structures
#
# DROP TABLE IF EXISTS temp_seeking;

# ALTER TABLE my_contacts
#     DROP COLUMN seeking,
#     DROP COLUMN seekingCopy,
#     DROP COLUMN seeking1,
#     DROP COLUMN seeking2;

SELECT cs.contacts_ID, cs.seeking_ID, mc.first_name, mc.last_name, sk.seeking
    FROM contacts_seeking AS cs
    JOIN my_contacts AS mc
    ON cs.contacts_ID = mc.contacts_ID
    JOIN seeking AS sk
    ON cs.seeking_ID = sk.seeking_ID
    ORDER BY mc.last_name;
