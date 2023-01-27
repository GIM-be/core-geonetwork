update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'dct:subject>',
                        'mdcat:statuut>') as text)
where schemaid = 'dcat2'
  and isharvested = 'n'
  and data like '%<dct:title>Dcat-ap-vl</dct:title>%'
  and data like '%<dct:subject>%';
