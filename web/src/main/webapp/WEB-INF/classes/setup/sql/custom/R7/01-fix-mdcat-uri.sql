update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'http://data.vlaanderen.be/ns/',
                        'https://data.vlaanderen.be/ns/') as text)
where data like '%http://data.vlaanderen.be/ns/%';
