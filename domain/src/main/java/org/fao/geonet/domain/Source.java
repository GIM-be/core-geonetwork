package org.fao.geonet.domain;

import javax.persistence.Access;
import javax.persistence.AccessType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;

/**
 * Entity representing a metadata source.
 * 
 * @author Jesse
 */
@Entity
@Access(AccessType.PROPERTY)
@Table(name = "sources")
public class Source {
    private String uuid;
    private String name;
    private char _local = Constants.YN_TRUE;

    /**
     * Get the uuid of the source.
     * 
     * @return the uuid of the source.
     */
    @Id
    public String getUuid() {
        return uuid;
    }

    /**
     * Set the uuid of the source.
     * 
     * @param uuid the uuid of the source.
     */
    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    /**
     * Get the name of the source.
     * 
     * @return the name of the source.
     */
    public String getName() {
        return name;
    }

    /**
     * Set the name of the source.
     * 
     * @param name the name of the source.
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * For backwards compatibility we need the islocal column to be either 'n' or 'y'. This is a workaround to allow this until future
     * versions of JPA that allow different ways of controlling how types are mapped to the database.
     */
    @Column(name = "islocal", nullable = false, length = 1)
    protected char getIsLocal_JpaWorkaround() {
        return _local;
    }

    /**
     * Set the column values.
     * @param local Constants.YN_ENABLED or Constants.YN_DISABLED
     */
    protected void setIsLocal_JpaWorkaround(char local) {
        _local = local;
    }

    /**
     * Return true is the source refers to the local geonetwork.
     *
     * @return true is the source refers to the local geonetwork.
     */
    @Transient
    public boolean isLocal() {
        return Constants.toBoolean_fromYNChar(getIsLocal_JpaWorkaround());
    }

    /**
     * Set true is the source refers to the local geonetwork.
     * @param local true is the source refers to the local geonetwork.
     */
    public void setLocal(boolean local) {
        setIsLocal_JpaWorkaround(Constants.toYN_EnabledChar(local));
    }
}
