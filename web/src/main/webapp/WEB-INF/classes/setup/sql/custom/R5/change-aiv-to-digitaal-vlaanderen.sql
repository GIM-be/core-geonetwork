UPDATE dbo.StatusValuesDes SET label = 'Goedgekeurd door Digitaal Vlaanderen en gepubliceerd' WHERE langid = 'dut' and idDes = 2;
UPDATE dbo.StatusValuesDes SET label = 'Intern goedgekeurd en ingediend bij Digitaal Vlaanderen' WHERE langid = 'dut' and idDes = 7;
UPDATE dbo.StatusValuesDes SET label = 'Klaar voor publicatie door Digitaal Vlaanderen' WHERE langid = 'dut' and idDes = 8;
UPDATE dbo.StatusValuesDes SET label = 'Afgekeurd door validator Digitaal Vlaanderen' WHERE langid = 'dut' and idDes = 9;
UPDATE dbo.StatusValuesDes SET label = 'Afgekeurd door validator Digitaal Vlaanderen en niet gedepubliceerd' WHERE langid = 'dut' and idDes = 13;
UPDATE dbo.StatusValuesDes SET label = 'Afgekeurd door validator Digitaal Vlaanderen en niet verwijderd' WHERE langid = 'dut' and idDes = 14;

UPDATE dbo.StatusValuesDes SET label = 'Internally approved and submitted to Digitaal Vlaanderen' WHERE langid = 'eng' and idDes = 7;
UPDATE dbo.StatusValuesDes SET label = 'Ready for publication by Digitaal Vlaanderen' WHERE langid = 'eng' and idDes = 8;
UPDATE dbo.StatusValuesDes SET label = 'Rejected by Digitaal Vlaanderen validator' WHERE langid = 'eng' and idDes = 9;
UPDATE dbo.StatusValuesDes SET label = 'Rejected by Digitaal Vlaanderen validator and not unpublished' WHERE langid = 'eng' and idDes = 13;
UPDATE dbo.StatusValuesDes SET label = 'Rejected by Digitaal Vlaanderen validator and not deleted' WHERE langid = 'eng' and idDes = 14;

UPDATE dbo.StatusValuesDes SET label = 'Approuvé en interne et soumis à Digitaal Vlaanderen' WHERE langid = 'fre' and idDes = 7;
UPDATE dbo.StatusValuesDes SET label = 'Prêt pour publication par Digitaal Vlaanderen' WHERE langid = 'fre' and idDes = 8;
UPDATE dbo.StatusValuesDes SET label = 'Rejeté par le validateur de Digitaal Vlaanderen' WHERE langid = 'fre' and idDes = 9;
UPDATE dbo.StatusValuesDes SET label = 'Rejeté par le validateur de Digitaal Vlaanderen et non publié' WHERE langid = 'fre' and idDes = 13;
UPDATE dbo.StatusValuesDes SET label = 'Rejeté par le validateur de Digitaal Vlaanderen et non supprimé' WHERE langid = 'fre' and idDes = 14;
