-- Script to be executed on existing database to update the workflow status

-- Add new status
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (6,'justcreated','y', 5, 'workflow', null);

-- Add translation for the new status
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (6,'dut','Pas gecreëerd');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (6,'eng','Just created');
INSERT INTO StatusValuesDes  (iddes, langid, label) VALUES (6,'fre','Juste créé');

-- Update workflow status label for dutch
UPDATE StatusValuesDes SET label = 'Ontwerp' WHERE langid = 'dut' and label = 'Draft';
UPDATE StatusValuesDes SET label = 'Intern goedgekeurd en gepubliceerd' WHERE langid = 'dut' and label = 'Approved';
UPDATE StatusValuesDes SET label = 'Gedepubliceerd' WHERE langid = 'dut' and label = 'Retired';
UPDATE StatusValuesDes SET label = 'Intern ingediend' WHERE langid = 'dut' and label = 'Submitted'; 
UPDATE StatusValuesDes SET label = 'Afgekeurd door Hoofdeditor' WHERE langid = 'dut' and label = 'Rejected';