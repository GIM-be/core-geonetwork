/*
 * Copyright (C) 2001-2023 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.repository;

import org.fao.geonet.domain.InspireAtomFeed;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;


/**
 * Repository class for InspireAtomFeed. Repository class for InspireAtomFeed.
 *
 * @author Jose García
 */
public interface InspireAtomFeedRepository extends GeonetRepository<InspireAtomFeed, Integer>,
    InspireAtomFeedRepositoryCustom, JpaSpecificationExecutor<InspireAtomFeed> {
    /**
     * Find an inspire atom feed related to a metadata. If several feeds are stored for the metadata
     * (eg. after concurrent harvests), the most recently stored one is returned.
     *
     * @param metadataId metadata identifier
     * @return the metadata related to the inspire atom feed
     */
    default InspireAtomFeed findByMetadataId(final int metadataId) {
        return findFirstByMetadataIdOrderByIdDesc(metadataId);
    }

    /**
     * Find the most recently stored inspire atom feed related to a metadata.
     *
     * @param metadataId metadata identifier
     * @return the most recent inspire atom feed related to the metadata
     */
    InspireAtomFeed findFirstByMetadataIdOrderByIdDesc(final int metadataId);

    /**
     * Find the list of all {@link InspireAtomFeed} with the provided {@code atomDatasetid}.
     *
     * @param atomDatasetid the atomDatasetid.
     * @return a list of all the inspire atom feed elements with atomDatasetId.
     */
    List<InspireAtomFeed> findAllByAtomDatasetid(final String atomDatasetid);
}
