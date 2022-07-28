package be.vlaanderen.metadata.plugin.iso19139.convert.OGCWxSGetCapabilitiesto19119;

import be.vlaanderen.metadata.util.AbstractXsltControlTest;
import com.google.common.collect.ImmutableSet;
import org.fao.geonet.schema.iso19139.ISO19139Namespaces;

public class IdentificationXslTest extends AbstractXsltControlTest {
    private static String path = "plugin/iso19139/convert/OGCWxSGetCapabilitiesto19119/identificationxsl/";

    public IdentificationXslTest() {
        super("convert/OGCWxSGetCapabilitiesto19119/OGCWxSGetCapabilities-to-19119.xsl",
                path + "input.xml",
                path + "control.xml");
        setNs(ImmutableSet.of(ISO19139Namespaces.GMD, ISO19139Namespaces.GCO));
    }
}