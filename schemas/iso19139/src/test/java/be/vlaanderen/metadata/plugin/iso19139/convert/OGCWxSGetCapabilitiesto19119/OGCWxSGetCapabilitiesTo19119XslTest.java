package be.vlaanderen.metadata.plugin.iso19139.convert.OGCWxSGetCapabilitiesto19119;

import be.vlaanderen.metadata.util.AbstractXsltControlTest;
import com.google.common.collect.ImmutableSet;
import org.fao.geonet.schema.iso19139.ISO19139Namespaces;

public class OGCWxSGetCapabilitiesTo19119XslTest extends AbstractXsltControlTest {
    private static String path = "plugin/iso19139/convert/OGCWxSGetCapabilitiesto19119/OGCWxSGetCapabilitiesto19119/";

    public OGCWxSGetCapabilitiesTo19119XslTest() {
        super("convert/OGCWxSGetCapabilitiesto19119/OGCWxSGetCapabilities-to-19119.xsl",
                path + "input.xml",
                path + "control.xml");
        setNs(ImmutableSet.of(ISO19139Namespaces.GMD, ISO19139Namespaces.GCO));
    }
}