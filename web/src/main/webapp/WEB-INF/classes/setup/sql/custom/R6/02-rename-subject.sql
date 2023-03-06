update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'dct:subject>',
                        'mdcat:statuut>') as text)
where schemaid = 'dcat2'
  and isTemplate <> 's'
  and data like '%<dct:Standard rdf:about="https://data.vlaanderen.be/doc/applicatieprofiel/DCAT-AP-VL%'
  and data like '%dct:subject>%';

update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'dct:subject>',
                        'mdcat:MAGDA-categorie>') as text)
where schemaid = 'dcat2'
  and isTemplate <> 's'
  and data like '%<dct:Standard rdf:about="https://data.vlaanderen.be/doc/applicatieprofiel/metadata-dcat%'
  and data like '%dct:subject>%';


update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        '<rdf:RDF',
                        '<rdf:RDF xmlns:mdcat="http://data.vlaanderen.be/ns/metadata-dcat#"') as text)
where schemaid = 'dcat2'
  and isTemplate = 'n'
  and data not like '%<rdf:RDF%xmlns:mdcat="http://data.vlaanderen.be/ns/metadata-dcat#"%<dcat:Catalog %';
