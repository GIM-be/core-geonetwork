UPDATE Settings
SET value = '<p>
  The $$harvesterType$$ harvester ''<b>$$harvesterName$$</b>'' was successful and has imported $$total$$ records. There
  were $$doesNotValidate$$ datasets that are not valid against the validation rules.
</p>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Total number of metadata imported: $$total$$.</li>
  <li>Number of metadata added: $$added$$.</li>
  <li>Number of metadata updated: $$updated$$.</li>
  <li>Number of metadata unchanged: $$unchanged$$.</li>
  <li>Number of metadata unretrievable: $$unretrievable$$.</li>
  <li>Number of metadata removed: $$removed$$.</li>
  <li>Number of invalid metadata records: $$doesNotValidate$$.</li>
</ul>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Harvester Name: $$harvesterName$$.</li>
  <li>Harvester Type: $$harvesterType$$.</li>
  <li>Harvester Validation: $$harvestValidate$$</li>
</ul>
<p>
  Further information is available in the log file at <a href="$$logURL$$">$$logURL$$</a>.
</p>'
WHERE name = 'system/harvesting/mail/template';

UPDATE Settings
SET value = '<p>
  The $$harvesterType$$ harvester ''<b>$$harvesterName$$</b>'' was NOT successful<br>
  Error Message: <i>$$errorMsg$$</i>
</p>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Total number of metadata imported: $$total$$.</li>
  <li>Number of metadata added: $$added$$.</li>
  <li>Number of metadata updated: $$updated$$.</li>
  <li>Number of metadata unchanged: $$unchanged$$.</li>
  <li>Number of metadata unretrievable: $$unretrievable$$.</li>
  <li>Number of metadata removed: $$removed$$.</li>
  <li>Number of invalid metadata records: $$doesNotValidate$$.</li>
</ul>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Harvester Name: $$harvesterName$$.</li>
  <li>Harvester Type: $$harvesterType$$.</li>
  <li>Harvester Validation: $$harvestValidate$$</li>
</ul>
<p>
  Further information is available in the log file at <a href="$$logURL$$">$$logURL$$</a>.
</p>'
WHERE name = 'system/harvesting/mail/templateError';

UPDATE Settings
SET value = '<p>The $$harvesterType$$ harvester ''<b>$$harvesterName$$</b>'' was successful with warnings</p>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Total number of metadata imported: $$total$$.</li>
  <li>Number of metadata added: $$added$$.</li>
  <li>Number of metadata updated: $$updated$$.</li>
  <li>Number of metadata unchanged: $$unchanged$$.</li>
  <li>Number of metadata unretrievable: $$unretrievable$$.</li>
  <li>Number of metadata removed: $$removed$$.</li>
  <li>Number of invalid metadata records: $$doesNotValidate$$.</li>
</ul>
<ul style="list-style-type: none; padding-inline-start: 0;">
  <li>Harvester Name: $$harvesterName$$.</li>
  <li>Harvester Type: $$harvesterType$$.</li>
  <li>Harvester Validation: $$harvestValidate$$</li>
</ul>
<p>
  Further information is available in the log file at <a href="$$logURL$$">$$logURL$$</a>.
</p>'
WHERE name = 'system/harvesting/mail/templateWarning';
