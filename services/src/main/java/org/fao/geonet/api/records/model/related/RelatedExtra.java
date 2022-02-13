package org.fao.geonet.api.records.model.related;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "relatedExtra", propOrder = {
    "linkage",
    "format",
    "accessRights"
})
public class RelatedExtra {
    private String[] linkage;
    private String[] format;
    private String accessRights;

    public RelatedExtra() {
    }

    public String[] getlinkage() {
        return linkage;
    }

    public void setlinkage(String[] linkage) {
        this.linkage = linkage;
    }

    public String[] getformat() {
        return format;
    }

    public void setformat(String[] format) {
        this.format = format;
    }

    public String getAccessRights() {
        return accessRights;
    }

    public void setAccessRights(String accessRights) {
        this.accessRights = accessRights;
    }
}
