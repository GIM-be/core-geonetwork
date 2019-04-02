-- Add status specific to AGIV (must be executed after update-workflow-status.sql)

INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (7, 'submittedforagiv', 'y', 6,  'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (8, 'approvedbyagiv',   'y', 7,  'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (9, 'rejectedbyagiv',   'y', 8,  'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (10,'retiredforagiv',   'y', 9,  'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (11,'removedforagiv',   'y', 10, 'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (12,'removed',          'y', 11, 'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (13,'rejectedforretire','y', 12, 'workflow', null);
INSERT INTO StatusValues (id, name, reserved, displayorder, type, notificationLevel) VALUES  (14,'rejectedforremove','y', 13, 'workflow', null);


-- Change the displayed order

UPDATE statusvalues SET displayorder = 1  WHERE id = 6;   -- justcreated
UPDATE statusvalues SET displayorder = 2  WHERE id = 1;   -- draft
UPDATE statusvalues SET displayorder = 3  WHERE id = 4;   -- submitted
UPDATE statusvalues SET displayorder = 4  WHERE id = 7;   -- submittedforagiv
UPDATE statusvalues SET displayorder = 5  WHERE id = 5;   -- rejected
UPDATE statusvalues SET displayorder = 6  WHERE id = 8;   -- approvedbyagiv
UPDATE statusvalues SET displayorder = 7  WHERE id = 9;   -- rejectedbyagiv
UPDATE statusvalues SET displayorder = 8  WHERE id = 2;   -- approved
UPDATE statusvalues SET displayorder = 9  WHERE id = 3;   -- retired
UPDATE statusvalues SET displayorder = 10 WHERE id = 10;  -- retiredforagiv
UPDATE statusvalues SET displayorder = 11 WHERE id = 13;  -- rejectedforretire
UPDATE statusvalues SET displayorder = 12 WHERE id = 11;  -- removedforagiv
UPDATE statusvalues SET displayorder = 13 WHERE id = 12;  -- removed
UPDATE statusvalues SET displayorder = 14 WHERE id = 14;  -- rejectedforremove


-- Add translation for the new status

INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (7, 'dut','Intern goedgekeurd en ingediend bij Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (8, 'dut','Klaar voor publicatie door Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (9, 'dut','Afgekeurd door validator Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (10,'dut','Ingediend voor depubliceren');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (11,'dut','Ingediend voor verwijderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (12,'dut','Verwijderd');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (13,'dut','Afgekeurd door validator Informatie Vlaanderen en niet gedepubliceerd');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (14,'dut','Afgekeurd door validator Informatie Vlaanderen en niet verwijderd');

INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (7, 'eng','Internally approved and submitted to Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (8, 'eng','Ready for publication by Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (9, 'eng','Rejected by Informatie Vlaanderen validator');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (10,'eng','Submitted for un-publishing');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (11,'eng','Submitted for removal');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (12,'eng','Deleted');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (13,'eng','Rejected by Informatie Vlaanderen validator and not unpublished');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (14,'eng','Rejected by Informatie Vlaanderen validator and not deleted');

INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (7, 'fre','Approuvé en interne et soumis à Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (8, 'fre','Prêt pour publication par Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (9, 'fre','Rejeté par le validateur d''Informatie Vlaanderen');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (10,'fre','Soumis pour dépublication');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (11,'fre','Soumis à l''enlèvement');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (12,'fre','Enlevé');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (13,'fre','Rejeté par le validateur d''Informatie Vlaanderen et non publié');
INSERT INTO StatusValuesDes (iddes, langid, label) VALUES (14,'fre','Rejeté par le validateur d''Informatie Vlaanderen et non supprimé');
