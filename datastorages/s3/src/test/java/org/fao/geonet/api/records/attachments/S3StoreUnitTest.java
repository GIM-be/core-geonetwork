/*
 * =============================================================================
 * ===	Copyright (C) 2026 Food and Agriculture Organization of the
 * ===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * ===	and United Nations Environment Programme (UNEP)
 * ===
 * ===	This program is free software; you can redistribute it and/or modify
 * ===	it under the terms of the GNU General Public License as published by
 * ===	the Free Software Foundation; either version 2 of the License, or (at
 * ===	your option) any later version.
 * ===
 * ===	This program is distributed in the hope that it will be useful, but
 * ===	WITHOUT ANY WARRANTY; without even the implied warranty of
 * ===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * ===	General Public License for more details.
 * ===
 * ===	You should have received a copy of the GNU General Public License
 * ===	along with this program; if not, write to the Free Software
 * ===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 * ===
 * ===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * ===	Rome - Italy. email: geonetwork@osgeo.org
 * ==============================================================================
 */
package org.fao.geonet.api.records.attachments;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.domain.MetadataResource;
import org.fao.geonet.domain.MetadataResourceVisibility;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.resources.S3Credentials;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.Date;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

public class S3StoreUnitTest {

    @Test
    public void testGetPublicResourcesDoesNotRequireEditPrivileges() throws Exception {
        String metadataUuid = "record-uuid";
        int metadataId = 123;
        ServiceContext context = null;
        S3Store store = new S3Store() {
            @Override
            protected int canEdit(ServiceContext context, String metadataUuid, Boolean approved) {
                throw new AssertionError("Public resources must not require edit privileges.");
            }

            @Override
            protected int canDownload(ServiceContext context, String metadataUuid, MetadataResourceVisibility visibility,
                                      Boolean approved) {
                assertEquals(MetadataResourceVisibility.PUBLIC, visibility);
                return metadataId;
            }
        };

        AmazonS3 client = Mockito.mock(AmazonS3.class);
        S3Credentials credentials = Mockito.mock(S3Credentials.class);
        SettingManager settingManager = Mockito.mock(SettingManager.class);
        ListObjectsV2Result result = new ListObjectsV2Result();
        S3ObjectSummary summary = new S3ObjectSummary();
        summary.setKey("resources/" + metadataId + "/public/export.zip");
        summary.setSize(42);
        summary.setLastModified(new Date());
        result.getObjectSummaries().add(summary);

        Mockito.when(credentials.getClient()).thenReturn(client);
        Mockito.when(credentials.getBucket()).thenReturn("bucket");
        Mockito.when(credentials.getKeyPrefix()).thenReturn("resources/");
        Mockito.when(client.listObjectsV2("bucket", "resources/" + metadataId + "/public")).thenReturn(result);
        Mockito.when(settingManager.getNodeURL()).thenReturn("http://localhost:8080/srv/");

        store.s3 = credentials;
        store.settingManager = settingManager;

        List<MetadataResource> resources = store.getResources(
            context, metadataUuid, MetadataResourceVisibility.PUBLIC, null, true);

        assertEquals(1, resources.size());
        assertEquals("export.zip", resources.get(0).getFilename());
        assertEquals(MetadataResourceVisibility.PUBLIC, resources.get(0).getVisibility());
    }

    @Test
    public void testGetPrivateResourcesRequiresDownloadPrivileges() throws Exception {
        ServiceContext context = null;
        S3Store store = new S3Store() {
            @Override
            protected int canEdit(ServiceContext context, String metadataUuid, Boolean approved) {
                throw new AssertionError("Private resource listing should be guarded by download privileges.");
            }

            @Override
            protected int canDownload(ServiceContext context, String metadataUuid, MetadataResourceVisibility visibility,
                                      Boolean approved) {
                assertEquals(MetadataResourceVisibility.PRIVATE, visibility);
                throw new SecurityException("download required");
            }
        };

        try {
            store.getResources(context, "record-uuid", MetadataResourceVisibility.PRIVATE, null, true);
            fail("Expected private resource listing to require download privileges.");
        } catch (SecurityException e) {
            assertEquals("download required", e.getMessage());
        }
    }
}
