package org.fao.geonet.api.records.rdf;

import io.swagger.annotations.*;
import jeeves.services.ReadWriteController;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.api.API;
import org.fao.geonet.kernel.metadata.RdfCache;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;

@RequestMapping(value = {
    "/{portal}/api/rdf",
    "/{portal}/api/" + API.VERSION_0_1 +
        "/rdf"
})
@Api(value = "rdf",
    tags = "rdf",
    description = "RDF cache operations")
@Controller("rdf")
@ReadWriteController
public class CacheApi {

    @ApiOperation(
        value = "Clear RDF cache",
        notes = "When a record is converted to RDF a cache is populated for better performance. " +
            "By default, the RDF are stored as files in the filesystem.",
        authorizations = {
            @Authorization(value = "basicAuth")
        },
        nickname = "clearRdfCache")
    @RequestMapping(
        value = "/cache",
        method = RequestMethod.DELETE
    )
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(code = 204, message = "Cache cleared."),
        @ApiResponse(code = 403, message = "Operation not allowed. Only Administrator can access it.")
    })
    public void clearRdfCache() throws Exception {
        RdfCache rdfCache = ApplicationContextHolder.get().getBean(RdfCache.class);
        rdfCache.emptyCache();
    }
}
