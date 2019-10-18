use Normalization1;

DROP TABLE IF EXISTS status;
CREATE TABLE status (
  status_ID int(11) NOT NULL auto_increment,
  status VARCHAR(25) NOT NULL,
  PRIMARY KEY  (status_ID)
) AS
	SELECT DISTINCT mc.status
	FROM my_contacts AS mc
	WHERE mc.status IS NOT NULL
	ORDER BY mc.status;
	
ALTER TABLE my_contacts
ADD COLUMN status_FID INT(11) REFERENCES status (status_ID);

ALTER TABLE my_contacts
	ADD CONSTRAINT status_my_contacts_fk
	FOREIGN KEY (status_FID)
	REFERENCES status (status_ID);

UPDATE my_contacts
	INNER JOIN
status
	ON status.status = my_contacts.status
		SET my_contacts.status_FID = status.status_ID
	WHERE status.status IS NOT NULL;

SELECT mc.first_name, mc.last_name, mc.status, mc.status_FID, st.status
	FROM status AS st
	INNER JOIN my_contacts AS mc
	ON st.status_ID = mc.status_FID;

ALTER TABLE my_contacts
DROP COLUMN status;
	

