update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'https://standards.iso.org/iso/',
                        'http://standards.iso.org/iso/') as text)
where isharvested = 'n'
  and data like '%https://standards.iso.org/iso/%';


update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'https://inspire.ec.europa.eu/',
                        'http://inspire.ec.europa.eu/') as text)
where isharvested = 'n'
  and data like '%https://inspire.ec.europa.eu/%';
