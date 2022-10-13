update metadata set changedate = '1970-01-01' where isharvested = 'y' and schemaid = 'iso19139';


-- optionally update XML dateStamp (not required for forcing the harvester)
-- update metadata set data = replace(
--   convert(varchar(MAX), data),
--   substring(data, (charindex('<gmd:dateStamp>', data)), (charindex('</gmd:dateStamp>', data) - charindex('<gmd:dateStamp>', data) + len('<gmd:dateStamp>') + 1)),
--   '<gmd:dateStamp>
--     <gco:Date xmlns:gco="http://www.isotc211.org/2005/gco">1970-01-01</gco:Date>
--   </gmd:dateStamp>'
--   )
-- where isharvested = 'y' and schemaid = 'iso19139';
