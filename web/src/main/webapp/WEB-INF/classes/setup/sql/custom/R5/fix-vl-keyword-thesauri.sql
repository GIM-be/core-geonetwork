update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden"',
                        '"https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden"') as text)
where schemaid = 'iso19139'
  and istemplate = 'n'
  and isharvested = 'n'
  and data like '%"https://beta.metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden"%';
