package be.vlaanderen.metadata.util;

/**
 * Perform a dummy test to see whether the XsltControlTest class behaves correctly.
 */
public class XsltControlTest extends AbstractXsltControlTest {
    public XsltControlTest() {
        super("util/XsltControlTest/dummy/xsl.xsl",
                "util/XsltControlTest/dummy/input.xml",
                "util/XsltControlTest/dummy/control.xml");
    }
}