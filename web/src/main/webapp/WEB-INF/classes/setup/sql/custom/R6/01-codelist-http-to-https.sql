update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml',
                        'https://standards.iso.org/iso/19139/resources/gmxCodelists.xml') as text)
where schemaid = 'iso19139'
  and isharvested = 'n'
  and data like '%http://standards.iso.org/iso/19139/resources/gmxCodelists.xml%';


update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown',
                        'https://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown') as text)
where schemaid = 'iso19139'
  and isharvested = 'n'
  and data like '%http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown%';


update dbo.metadata
set data = cast(replace(cast(data as NVarchar(MAX)),
                        'http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations',
                        'https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations') as text)
where schemaid = 'iso19139'
  and isharvested = 'n'
  and data like '%http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations%';
