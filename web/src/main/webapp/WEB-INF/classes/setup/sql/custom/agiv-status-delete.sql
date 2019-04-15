-- Remove translation for the status specific to AGIV (must be executed before update-workflow-status.sql)
delete from StatusValuesDes where iddes in (7,8,9,10,11,12,13,14);

-- Remove status specific to AGIV
delete from StatusValues where id in (7,8,9,10,11,12,13,14);

