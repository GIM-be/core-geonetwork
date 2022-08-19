package be.vlaanderen.metadata.plugin.iso19139.convert.OGCWxSGetCapabilitiesto19119;

import be.vlaanderen.metadata.util.AbstractXsltControlTest;
import com.google.common.collect.ImmutableSet;
import org.fao.geonet.schema.iso19139.ISO19139Namespaces;
import org.junit.After;

import java.io.File;
import java.io.IOException;

public class OGCWxSGetCapabilitiesTo19119XslTest2 extends AbstractXsltControlTest {
    private static String path = "plugin/iso19139/convert/OGCWxSGetCapabilitiesto19119/OGCWxSGetCapabilitiesto19119/";

    public OGCWxSGetCapabilitiesTo19119XslTest2() {
        super("convert/OGCWxSGetCapabilitiesto19119/OGCWxSGetCapabilities-to-19119.xsl",
                path + "2-input.xml",
                path + "2-control.xml");
        setNs(ImmutableSet.of(ISO19139Namespaces.GMD, ISO19139Namespaces.GCO));
    }

    // uncomment for easy viewing of the result
    //    @After
    //    public void write() throws IOException {
    //        writeResult(new File("c:/temp/test.xml"));
    //    }
}