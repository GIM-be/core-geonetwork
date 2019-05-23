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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.FedizUser;
import org.fao.geonet.domain.Group;
import org.fao.geonet.domain.Language;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.User;
import org.fao.geonet.domain.UserGroup;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.LanguageRepository;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.repository.specification.GroupSpecs;
import org.fao.geonet.repository.specification.UserGroupSpecs;
import org.fao.geonet.utils.Log;
import org.springframework.transaction.annotation.Transactional;

public class FedizUtils {

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * Save or update an FEDIZ user to the local GeoNetwork database.
     */

    @Transactional
    public synchronized void saveUser(FedizUser user, boolean createNonExistingFedizGroup)
        throws Exception {
        String userName = user.getUsername();
        if (Log.isDebugEnabled(Geonet.FEDIZ)) {
            Log.debug(Geonet.FEDIZ, "FEDIZ user sync for " + userName + " ...");
        }
        User toSave = getUser(user, userName);

        if (user.getOrganisations().size() > 0) {
            entityManager.flush();
            entityManager.clear();
            List<UserGroup> ug = getOrgansiationsAndCreateGroups(user,
                createNonExistingFedizGroup, toSave);
            entityManager.flush();
            setUserGroups(toSave, ug);
        }
    }

    @Transactional
    protected User getUser(FedizUser user, String userName) {
        UserRepository userRepo = ApplicationContextHolder.get().getBean(UserRepository.class);

        User loadedUser = userRepo.findOneByUsername(userName);
        User toSave;
        if (loadedUser != null) {
            loadedUser.mergeUser(user.getUser(), false);
            if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                Log.debug(Geonet.FEDIZ,
                    "  - Update FEDIZ user " + user.getUsername() + " ("
                        + loadedUser.getId() + ") in local database.");
            }
            toSave = loadedUser;

        } else {
            if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                Log.debug(Geonet.FEDIZ,
                    "  - Saving new FEDIZ user " + user.getUsername()
                        + " to database.");
            }
            toSave = user.getUser();
        }
        toSave.getSecurity().setAuthType(FedizConstants.FEDIZ_FLAG);
        toSave = userRepo.save(toSave);
        user.setUser(toSave);
        return toSave;
    }

    @Transactional
    protected List<UserGroup> getOrgansiationsAndCreateGroups(FedizUser user,
                                                         boolean createNonExistingFedizGroup, User toSave) {
        GroupRepository groupRepo = ApplicationContextHolder.get().getBean(GroupRepository.class);

        List<UserGroup> ug = new LinkedList<UserGroup>();
        for (String organisationKey : user.getOrganisations().keySet()) {
            // Add group privileges for each groups

            // Retrieve group id
        	Group group = null;
            Map<String,String> organisation = user.getOrganisations().get(organisationKey);
        	String groupName = organisation.get("organisationDisplayname");
            try {
            	Integer groupId = Integer.parseInt(organisation.get("organisationId"));
	            group = groupRepo.findOne(GroupSpecs.referrerEquals(groupId));
	
	            if (group == null && createNonExistingFedizGroup) {
	                group = new Group().setName(groupName);
	                group = group.setDescription(groupName);
	                group.setReferrer(groupId);
                    LanguageRepository langRepository = ApplicationContextHolder.get().getBean(LanguageRepository.class);
                    java.util.List<Language> allLanguages = langRepository.findAll();
                    for (Language l : allLanguages) {
                        group.getLabelTranslations().put(l.getId(), groupName);
                    }
	                group = groupRepo.save(group);
	
	                if (Log.isDebugEnabled(Geonet.FEDIZ)) {
	                    Log.debug(Geonet.FEDIZ, "  - Create FEDIZ group " + groupName
	                        + " for user.");
	                }
	            }
            } catch (NumberFormatException e) {
                if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                    Log.debug(
                        Geonet.FEDIZ,
                        "  - Can't create FEDIZ group "
                            + groupName
                            + " for user. "
                            + "The id from the organisation is not an integer value.");
                }
            }
            if (group != null) {
                if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                    Log.debug(Geonet.FEDIZ, "  - Link FEDIZ group " + groupName
                        + " for user.");
                }
                UserGroup usergroup = new UserGroup();
                usergroup.setGroup(group);
                usergroup.setUser(toSave);
                usergroup.setProfile(user.getUser().getProfile());
                ug.add(usergroup);
            } else {
                if (Log.isDebugEnabled(Geonet.FEDIZ)) {
                    Log.debug(
                        Geonet.FEDIZ,
                        "  - Can't create FEDIZ group "
                            + groupName
                            + " for user. "
                            + "Group does not exist in local database or createNonExistingFedizGroup is set to false.");
                }
            }
        }
        return ug;
    }

    @Transactional
    protected void setUserGroups(final User user, List<UserGroup> userGroups)
        throws Exception {
        UserGroupRepository userGroupRepo = ApplicationContextHolder.get().getBean(UserGroupRepository.class);

        Collection<UserGroup> all = userGroupRepo.findAll(UserGroupSpecs
            .hasUserId(user.getId()));

        if (Log.isTraceEnabled(Log.JEEVES)) {
            Log.trace(
                Log.JEEVES,
                "Current usergroups:"
                    + UserGroupSpecs.hasUserId(user.getId()));
            Log.trace(Log.JEEVES, all.size());

            for (UserGroup g : all) {
                Log.trace(Log.JEEVES, g);
            }
        }
        // Have a quick reference of existing groups and profiles for this user
        Set<String> listOfAddedProfiles = new HashSet<String>();
        for (UserGroup ug : all) {
            String key = ug.getProfile().name() + ug.getGroup().getId();
            if (!listOfAddedProfiles.contains(key)) {
                listOfAddedProfiles.add(key);
            }
        }

        // We start removing all old usergroup objects. We will remove the
        // explicitly defined for this call
        Collection<UserGroup> toRemove = new ArrayList<UserGroup>();
        toRemove.addAll(all);

        // New pairs of group-profile we need to add
        Collection<UserGroup> toAdd = new ArrayList<UserGroup>();

        // For each of the parameters on the request, make sure the group is
        // updated.
        for (UserGroup element : userGroups) {
            Group group = element.getGroup();
            String profile = element.getProfile().name();
            // The user has a new group and profile

            // Combine all groups editor and reviewer groups
            if (profile.equals(Profile.Reviewer.name())) {
                final UserGroup userGroup = new UserGroup().setGroup(group)
                    .setProfile(Profile.Editor).setUser(user);
                String key = Profile.Editor.toString() + group.getId();
                if (!listOfAddedProfiles.contains(key)) {
                    toAdd.add(userGroup);
                    listOfAddedProfiles.add(key);
                }

                // If the user is already part of this group with this profile,
                // leave it alone:
                for (UserGroup g : all) {
                    if (g.getGroup().getId() == group.getId()
                        && g.getProfile().equals(Profile.Editor)) {
                        toRemove.remove(g);
                    }
                }
            }

            final UserGroup userGroup = new UserGroup().setGroup(group)
                .setProfile(Profile.findProfileIgnoreCase(profile))
                .setUser(user);
            String key = profile + group.getId();
            if (!listOfAddedProfiles.contains(key)) {
                toAdd.add(userGroup);
                listOfAddedProfiles.add(key);

            }

            // If the user is already part of this group with this profile,
            // leave it alone:
            for (UserGroup g : all) {
                if (g.getGroup().getId() == group.getId()
                    && g.getProfile().name().equalsIgnoreCase(profile)) {
                    toRemove.remove(g);
                }
            }
        }

        // Remove deprecated usergroups (if any)
        userGroupRepo.delete(toRemove);
        entityManager.flush();
        entityManager.clear();

        // Add only new usergroups (if any)
        userGroupRepo.save(toAdd);
        entityManager.flush();

    }
}
