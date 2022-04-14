package org.fao.geonet.kernel.metadata;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.utils.Xml;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Stream;

public class RdfCache {
    private final GeonetworkDataDirectory gnDataDir;

    public RdfCache() throws IOException {
        this.gnDataDir = ApplicationContextHolder.get().getBean(GeonetworkDataDirectory.class);
        Files.createDirectories(this.gnDataDir.getRdfCacheDir());
    }

    public void add(String uuid, Element rdf) {
        File file = this.gnDataDir.getRdfCacheDir().resolve(uuid + ".rdf").toFile();
        this.delete(uuid);
        try {
            file.createNewFile();
            OutputStreamWriter writer = new OutputStreamWriter(
                new FileOutputStream(file),
                StandardCharsets.UTF_8
            );
            writer.write(Xml.getString(rdf));
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Optional<Element> get(String uuid) {
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

    public void delete(String uuid) {
        File file = this.gnDataDir.getRdfCacheDir().resolve(uuid + ".rdf").toFile();
        if (file.exists()) {
            file.delete();
        }
        // TODO: Delete related metadata
    }

    public void emptyCache() {
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
}
