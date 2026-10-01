//=============================================================================
//===	Copyright (C) 2001-2026 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.kernel.harvest.harvester;

import static org.junit.Assert.assertEquals;

import org.fao.geonet.domain.ISODate;
import org.fao.geonet.domain.Metadata;
import org.junit.Test;

/**
 * Regression test for the WebDAV/WAF harvester NullPointerException in
 * {@code webdav.Harvester#updateMetadata}: the {@link RecordInfo} built from a local
 * {@link Metadata} record must carry the schema so the schema-change check can compare it.
 */
public class RecordInfoTest {

    @Test
    public void recordInfoFromMetadataCarriesSchema() {
        Metadata metadata = new Metadata();
        metadata.setId(1);
        metadata.setUuid("uuid-1");
        metadata.getDataInfo().setSchemaId("iso19139").setChangeDate(new ISODate("2020-01-01T00:00:00"));

        RecordInfo ri = new RecordInfo(metadata);

        assertEquals("1", ri.id);
        assertEquals("uuid-1", ri.uuid);
        assertEquals("iso19139", ri.schema);
    }
}
