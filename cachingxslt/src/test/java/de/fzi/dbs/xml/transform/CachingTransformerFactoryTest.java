package de.fzi.dbs.xml.transform;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.attribute.FileTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

public class CachingTransformerFactoryTest {
    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    @Before
    public void clearCache() {
        new CachingTransformerFactory().clearCache();
    }

    @Test
    public void sharesCompiledStylesheetsButCreatesSeparateTransformers() throws Exception {
        File stylesheet = stylesheet("shared.xsl", "shared");
        CountingFactory first = new CountingFactory();
        CountingFactory second = new CountingFactory();

        Transformer firstTransformer = first.newTransformer(new StreamSource(stylesheet));
        Transformer secondTransformer = second.newTransformer(new StreamSource(stylesheet));

        assertNotSame(firstTransformer, secondTransformer);
        assertEquals("shared", transform(firstTransformer));
        assertEquals("shared", transform(secondTransformer));
        assertEquals(1, first.compilations.get());
        assertEquals(0, second.compilations.get());
    }

    @Test
    public void clearingThroughAnotherFactoryRecompilesStylesheets() throws Exception {
        File stylesheet = stylesheet("clear.xsl", "clear");
        CountingFactory factory = new CountingFactory();
        assertEquals("clear", transform(factory.newTransformer(new StreamSource(stylesheet))));

        new CachingTransformerFactory().clearCache();

        assertEquals("clear", transform(factory.newTransformer(new StreamSource(stylesheet))));
        assertEquals(2, factory.compilations.get());
    }

    @Test
    public void reloadsModifiedStylesheets() throws Exception {
        File stylesheet = stylesheet("modified.xsl", "before");
        CountingFactory factory = new CountingFactory();
        assertEquals("before", transform(factory.newTransformer(new StreamSource(stylesheet))));
        long originalModifiedTime = stylesheet.lastModified();

        writeStylesheet(stylesheet, "after");
        Files.setLastModifiedTime(stylesheet.toPath(), FileTime.fromMillis(originalModifiedTime + 2000));

        assertEquals("after", transform(factory.newTransformer(new StreamSource(stylesheet))));
        assertEquals(2, factory.compilations.get());
    }

    @Test
    public void missingStylesheetDoesNotPreventLaterCompilation() throws Exception {
        File stylesheet = new File(temporaryFolder.getRoot(), "missing.xsl");
        CachingTransformerFactory factory = new CachingTransformerFactory();
        assertCompilationFails(factory, stylesheet);

        writeStylesheet(stylesheet, "recovered");

        assertEquals("recovered", transform(factory.newTransformer(new StreamSource(stylesheet))));
    }

    @Test
    public void invalidStylesheetDoesNotPreventLaterCompilation() throws Exception {
        File stylesheet = temporaryFolder.newFile("invalid.xsl");
        Files.write(stylesheet.toPath(), "<invalid/>".getBytes(StandardCharsets.UTF_8));
        CachingTransformerFactory factory = new CachingTransformerFactory();
        assertCompilationFails(factory, stylesheet);

        writeStylesheet(stylesheet, "recovered");

        assertEquals("recovered", transform(factory.newTransformer(new StreamSource(stylesheet))));
    }

    @Test
    public void concurrentFactoriesAndCacheClearingComplete() throws Exception {
        int workerCount = 8;
        File shared = stylesheet("concurrent-shared.xsl", "shared");
        List<File> individual = new ArrayList<>();
        for (int i = 0; i < workerCount; i++) {
            individual.add(stylesheet("concurrent-" + i + ".xsl", "worker"));
        }
        CountDownLatch ready = new CountDownLatch(workerCount + 1);
        CountDownLatch start = new CountDownLatch(1);
        CountDownLatch finished = new CountDownLatch(workerCount);
        // The old cache ignores interrupts while waiting. Daemon workers ensure a
        // failed regression test cannot keep the test JVM alive indefinitely.
        ExecutorService executor = Executors.newFixedThreadPool(workerCount + 1, task -> {
            Thread thread = new Thread(task, "xslt-cache-regression");
            thread.setDaemon(true);
            return thread;
        });
        List<Future<?>> futures = new ArrayList<>();
        try {
            for (File ownStylesheet : individual) {
                futures.add(executor.submit(() -> {
                    CachingTransformerFactory factory = new CachingTransformerFactory();
                    ready.countDown();
                    try {
                        start.await();
                        for (int i = 0; i < 200; i++) {
                            assertEquals("shared", transform(factory.newTransformer(new StreamSource(shared))));
                            assertEquals("worker", transform(factory.newTransformer(new StreamSource(ownStylesheet))));
                        }
                        return null;
                    } finally {
                        finished.countDown();
                    }
                }));
            }
            futures.add(executor.submit(() -> {
                CachingTransformerFactory factory = new CachingTransformerFactory();
                ready.countDown();
                start.await();
                do {
                    factory.clearCache();
                    Thread.yield();
                } while (finished.getCount() > 0 && !Thread.currentThread().isInterrupted());
                return null;
            }));
            assertTrue("Workers did not start", ready.await(10, TimeUnit.SECONDS));
            long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(20);
            start.countDown();
            for (Future<?> future : futures) {
                future.get(Math.max(1, deadline - System.nanoTime()), TimeUnit.NANOSECONDS);
            }
        } finally {
            start.countDown();
            executor.shutdownNow();
        }
    }

    private File stylesheet(String name, String output) throws Exception {
        File file = temporaryFolder.newFile(name);
        writeStylesheet(file, output);
        return file;
    }

    private void writeStylesheet(File file, String output) throws Exception {
        String stylesheet = "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">"
            + "<xsl:output method=\"text\"/><xsl:template match=\"/\">" + output
            + "</xsl:template></xsl:stylesheet>";
        Files.write(file.toPath(), stylesheet.getBytes(StandardCharsets.UTF_8));
    }

    private static String transform(Transformer transformer) throws Exception {
        StringWriter output = new StringWriter();
        transformer.transform(new StreamSource(new StringReader("<record/>")), new StreamResult(output));
        return output.toString();
    }

    private static void assertCompilationFails(CachingTransformerFactory factory, File stylesheet) throws Exception {
        try {
            factory.newTransformer(new StreamSource(stylesheet));
            fail("Expected stylesheet compilation to fail");
        } catch (TransformerConfigurationException expected) {
            // The failure must leave other cache operations usable.
        }
    }

    private static class CountingFactory extends CachingTransformerFactory {
        private final AtomicInteger compilations = new AtomicInteger();

        @Override
        public Templates newTemplates(Source source) throws TransformerConfigurationException {
            compilations.incrementAndGet();
            return super.newTemplates(source);
        }
    }
}
