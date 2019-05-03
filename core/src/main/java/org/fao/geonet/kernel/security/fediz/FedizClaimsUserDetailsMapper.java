//=============================================================================
//===	Copyright (C) 2001-2012 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.kernel.security.fediz;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nonnull;

import org.apache.cxf.fediz.core.Claim;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.FedizUser;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.User;
import org.fao.geonet.util.PasswordUtil;
import org.fao.geonet.utils.Log;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.StringUtils;

/**
 * Map Fediz user information to GeoNetworkUser information.
 *
 * Create the GeoNetworkUser in local database on first login and update all user information on
 * subsequent login.
 *
 * @author gustaaf
 */
public class FedizClaimsUserDetailsMapper {

    Map<String, String> mapping;
    Map<String, String> profileMapping;
    private boolean createNonExistingFedizGroup = true;
    
    public Map<String, String> getUserInfo(List<Claim> claims) {
        Map<String, String> userInfo = new HashMap<String, String>();
        for (Claim claim : claims) {
            Object claimValue = claim.getValue();
            String claimType = claim.getClaimType().toString();
            int lastIndexOfSlash = claimType.lastIndexOf('/');
            if (lastIndexOfSlash>-1) {
                String userAttribute = getMappingValue(claimType.substring(lastIndexOfSlash+1));
                if (claimValue instanceof String && userAttribute!=null) {
                    userInfo.put(userAttribute, (String) claimValue);
                }
            }
        }
        return userInfo;
    }
    
    public UserDetails mapUserFromClaimsAndRoles(List<Claim> claims) {
        Map<String, String> userInfo = getUserInfo(claims);
        String organisationId = userInfo.get("organisationid");
        String organisationDisplayname = userInfo.get("organisationdisplayname");
        if (StringUtils.isEmpty(organisationId)) {
            organisationId = userInfo.get("parentorganisationid");
            organisationDisplayname = userInfo.get("parentorganisationdisplayname");
        }
        FedizUser userDetails = new FedizUser(userInfo.get("username"));
        User user = userDetails.getUser();
        user.getSecurity().setPassword(
            PasswordUtil.encoder(ApplicationContextHolder.get()).encode(User.getRandomPassword())
        );            
        user.setName(userInfo.get("name"))
            .setSurname(userInfo.get("surname"))
            .setOrganisation(organisationDisplayname);
        user.getEmailAddresses().clear();
        user.getEmailAddresses().add(userInfo.get("mail"));
        Map<String,String> organisationInfo =  new HashMap<String, String>();
        organisationInfo.put("organisationId", organisationId);
        organisationInfo.put("organisationDisplayname", organisationDisplayname);
        Map<String,Map<String,String>> organisations =  new HashMap<String, Map<String,String>>();
        organisations.put(organisationId, organisationInfo);
        userDetails.setOrganisations(organisations);
        setProfile(userDetails, userInfo.get("profile"));
        FedizUtils fedizUtils = ApplicationContextHolder.get().getBean(FedizUtils.class);
        try {
            fedizUtils.saveUser(userDetails,createNonExistingFedizGroup);
        } catch (Exception e) {
            throw new AuthenticationServiceException(
                "Unexpected error while saving/updating FEDIZ user in database",
                e);
        }
        
        return userDetails;
    }

    protected void setProfile(@Nonnull FedizUser userDetails,
                              @Nonnull String profileName) {
        String mappedProfileName = getProfileMappingValue(profileName);
        if (mappedProfileName != null) {
            if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                Log.debug(Geonet.FEDIZ, "  Assigning profile " + mappedProfileName);
            }
            try {
                Profile profile = Profile.valueOf(mappedProfileName);
                if (profile != null) {
                    userDetails.getUser().setProfile(profile);
                } else {
                    Log.error(Geonet.FEDIZ, "  Profile " + mappedProfileName
                        + " does not exist.");
                }
            } catch (Exception e) {
                Log.warning(Geonet.FEDIZ, "  Profile " + profileName
                    + " could not be mapped to a valid profile (default profile will be used). " + e.getMessage());
            }
        }
    }

    public String getMappingValue(String key) {
        if (mapping!=null) {
            return mapping.get(key);
        }
        return null;
    }

    public Map<String, String> getMapping() {
        return mapping;
    }

    public void setMapping(Map<String, String> mapping) {
        this.mapping = mapping;
    }

    public String getProfileMappingValue(String key) {
        if (profileMapping!=null) {
            return profileMapping.get(key);
        }
        return null;
    }

    public Map<String, String> getProfileMapping() {
        return profileMapping;
    }

    public void setProfileMapping(Map<String, String> profileMapping) {
        this.profileMapping = profileMapping;
    }

    public boolean isCreateNonExistingFedizGroup() {
        return createNonExistingFedizGroup;
    }

    public void setCreateNonExistingFedizGroup(boolean createNonExistingLdapGroup) {
        this.createNonExistingFedizGroup = createNonExistingLdapGroup;
    }
}
