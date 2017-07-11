public class Profiles implements IProfiles {

    private static List<Profile> cachedProfiles;

    private Map<Id, Profile> profilesById;
    private Map<String, Profile> profilesByName;
    private Profile systemAdministratorProfile;

    public Profiles() {
        this.populateCache();
        this.setProfilesById();
        this.setProfilesByName();
        this.setSystemAdministratorProfile();
    }

    public Map<Id, Profile> getAllById() {
        return this.profilesById;
    }

    public Map<String, Profile> getAllByName() {
        return this.profilesByName;
    }

    public Profile getSystemAdministrator() {
        return systemAdministratorProfile;
    }


    private void populateCache() {
        if(cachedProfiles != null) return;

        // If we don't have the SObject cached, then we need to query
        cachedProfiles = (List<Profile>)new QueryBuilder(Schema.Profile.SObjectType)
            .orderBy(Schema.Profile.Name)
            .getQueryResults();
    }

    private void setProfilesById() {
        if(this.profilesById != null) return;

        this.profilesById = new Map<Id, Profile>();
        for(Profile profile : cachedProfiles) this.profilesById.put(profile.Id, Profile);
    }

    private void setProfilesByName() {
        if(this.profilesByName != null) return;

        this.profilesByName = new Map<String, Profile>();
        for(Profile profile : cachedProfiles) this.profilesByName.put(profile.Name, Profile);
    }

    private void setSystemAdministratorProfile() {
        // Determining the system admin profile is a bit tricky for 2 reasons
        // 1. There is no DeveloperName field (or equivalent) on the Profile object
        // 2. The name of standard profiles can change based on the user's language, making name unreliable
        // Instead, we check a few attributes on the profile to determine if it's the admin profile
        for(Profile profile : this.getAllById().values()) {
            if(profile.UserType != 'Standard') continue;
            if(!profile.PermissionsCustomizeApplication) continue;

            this.systemAdministratorProfile = profile;
            break;
        }
    }

}
