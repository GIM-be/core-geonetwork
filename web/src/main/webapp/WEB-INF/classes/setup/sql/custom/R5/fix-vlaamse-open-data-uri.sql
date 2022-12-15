-- ONLY on DEV and BETA
update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/TOEGEVOEGDGDIVL"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/TOEGEVOEGDGDIVL"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/TOEGEVOEGDGDIVL"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATA"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATA"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATA"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/HERBRUIKBAAR"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/HERBRUIKBAAR"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/HERBRUIKBAAR"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/KOSTELOOS"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/KOSTELOOS"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/KOSTELOOS"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDINSPIRECONFORM"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDINSPIRECONFORM"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDINSPIRECONFORM"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDGDICONFORM"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDGDICONFORM"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDGDICONFORM"%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA"%';

