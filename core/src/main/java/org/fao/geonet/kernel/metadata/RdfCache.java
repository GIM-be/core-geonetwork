package org.fao.geonet.kernel.metadata;

import jeeves.constants.Jeeves;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.SystemInfo;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.kernel.schema.SchemaPlugin;
import org.fao.geonet.kernel.search.MetaSearcher;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.SearcherType;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class RdfCache {

    private ServiceContext context;
    private GeonetworkDataDirectory gnDataDir;
    private IMetadataUtils metadataUtils;
    private SearchManager searchMan;
    private SystemInfo systemInfo;


    public void init(ServiceContext context) throws IOException {
        this.context = context;
        this.gnDataDir = context.getBean(GeonetworkDataDirectory.class);
        this.metadataUtils = context.getBean(IMetadataUtils.class);
        this.searchMan = context.getBean(SearchManager.class);
        this.systemInfo = context.getBean(SystemInfo.class);
        Files.createDirectories(this.gnDataDir.getRdfCacheDir());
    }

    public synchronized void add(String uuid, Element rdf) {
        if (isCacheDisabled()) {
            return;
        }
        File file = this.gnDataDir.getRdfCacheDir().resolve(uuid + ".rdf").toFile();
        this.delete(uuid, false);
        try {
            file.createNewFile();
            OutputStreamWriter writer = new OutputStreamWriter(
                Files.newOutputStream(file.toPath()),
                StandardCharsets.UTF_8
            );
            writer.write(Xml.getString(rdf));
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public synchronized Optional<Element> get(String uuid) {
        if (isCacheDisabled()) {
            return  Optional.empty();
        }
        File file = this.gnDataDir.getRdfCacheDir().resolve(uuid + ".rdf").toFile();
        if (file.exists()) {
            try {
                SAXBuilder builder = new SAXBuilder();
                Document doc = builder.build(file);
                return Optional.of(doc.getRootElement());
            } catch (IOException | JDOMException e) {
                e.printStackTrace();
                return Optional.empty();
            }
        } else {
            return Optional.empty();
        }
    }

    public synchronized void delete(String uuid, boolean lookup) {
        if (isCacheDisabled()) {
            return;
        }
        File file = this.gnDataDir.getRdfCacheDir().resolve(uuid + ".rdf").toFile();
        if (file.exists()) {
            file.delete();
        }
        if (lookup) {
            for (String related : getRelated(uuid)) {
                delete(related, false);
            }
        }
    }

    public synchronized void emptyCache() {
        File[] files = this.gnDataDir
            .getRdfCacheDir()
            .toFile()
            .listFiles(pathname -> pathname.getPath().endsWith(".rdf"));
        if (!Objects.isNull(files)) {
            Stream.of(files)
                .filter(File::exists)
                .forEach(File::delete);
        }
    }

    private List<String> getRelated(String uuid) {
        AbstractMetadata metadata = metadataUtils.findOneByUuid(uuid);
        List<String> related = new ArrayList<>(Collections.emptyList());

        try {
            // related dataset
            if (!Objects.isNull(metadata)) {
                SchemaPlugin schemaPlugin = SchemaManager.getSchemaPlugin(metadata.getDataInfo().getSchemaId());
                if (schemaPlugin instanceof AssociatedResourcesSchemaPlugin) {
                    Element mdXml = metadata.getXmlData(false);
                    Set<String> uuids = ((AssociatedResourcesSchemaPlugin) schemaPlugin).getAssociatedDatasetUUIDs(mdXml);
                    related.addAll(uuids);
                }
            }

            // related services
            MetaSearcher searcher = searchMan.newSearcher(SearcherType.LUCENE, Geonet.File.SEARCH_LUCENE);
            Element parameters = new Element(Jeeves.Elem.REQUEST);
            parameters.addContent(new Element("operatesOn").setText(uuid));
            parameters.addContent(new Element("fast").addContent("index"));
            parameters.addContent(new Element("sortBy").addContent("title"));
            parameters.addContent(new Element("buildSummary").addContent("false"));
            parameters.addContent(new Element("from").addContent("1"));
            parameters.addContent(new Element("to").addContent("20"));
            ServiceConfig config = new ServiceConfig();
            searcher.search(context, parameters, config);
            Element response = searcher.present(context, parameters, config);
            List<String> relatedServices = ((List<Element>) (response.getChildren())).stream()
                .map(indexedMd -> indexedMd.getChild("info", Edit.NAMESPACE).getChild("uuid").getText())
                .collect(Collectors.toList());
            related.addAll(relatedServices);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return related;
    }

    private boolean isCacheDisabled() {
        return !SystemInfo.STAGE_PRODUCTION.equals(this.systemInfo.getStagingProfile());
    }
}
