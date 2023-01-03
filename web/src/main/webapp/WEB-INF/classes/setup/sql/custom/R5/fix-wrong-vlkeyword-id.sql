update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/SERVICEVLOPENDATA"',
                        'metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE"') as text)
where istemplate = 'n'
  and isharvested = 'n'
  and data like '%metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/SERVICEVLOPENDATA"%';



-- replace(data, 'metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/SERVICEVLOPENDATA"', 'metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE"')
