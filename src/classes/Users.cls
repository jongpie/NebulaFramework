public without sharing class Users {
    // Maps of different users
    public static Map<Id, User> ALL_USERS_MAP {
        get {
            if(ALL_USERS_MAP == null) ALL_USERS_MAP = new Map<Id, User>(getAllUsers());
            return ALL_USERS_MAP;
        }
        private set;
    }

    public static Map<Id, User> ACTIVE_USERS_MAP {
        get {
            if(ACTIVE_USERS_MAP == null) {
                ACTIVE_USERS_MAP = new Map<Id, User>();
                for(User user : ALL_USERS_MAP.values()) if(user.IsActive) ACTIVE_USERS_MAP.put(user.Id, user);
            }
            return ACTIVE_USERS_MAP;
        }
        private set;
    }

    public static Map<Id, User> INACTIVE_USERS_MAP {
        get {
            if(INACTIVE_USERS_MAP == null) {
                INACTIVE_USERS_MAP = new Map<Id, User>();
                for(User user : ALL_USERS_MAP.values()) if(!user.IsActive) INACTIVE_USERS_MAP.put(user.Id, user);
            }
            return INACTIVE_USERS_MAP;
        }
        private set;
    }

    public static User CURRENT_USER {
        get {
            if(CURRENT_USER == null) CURRENT_USER = ALL_USERS_MAP.get(UserInfo.getUserId());
            return CURRENT_USER;
        }
        private set;
    }

    public static List<User> getUsersByProfileId(Id profileId, Boolean includeInactiveUsers) {
        return getUsersByField(Schema.User.ProfileId, profileId, includeInactiveUsers);
    }

    public static List<User> getUsersByUserRoleId(Id roleId, Boolean includeInactiveUsers) {
        return getUsersByField(Schema.User.UserRoleId, roleId, includeInactiveUsers);
    }

    // Get a single user by a field value
    public static User getUserById(Id userId) {
        return getUserByField(Schema.User.Id, userId, true);
    }

    public static User getUserByCommunityNickname(String communityNickname) {
        if(String.isBlank(communityNickname)) return null;
        return getUserByField(Schema.User.CommunityNickname, communityNickname, true);
    }

    public static User getUserByFederationId(String federationId) {
        if(String.isBlank(federationId)) return null;
        return getUserByField(Schema.User.FederationIdentifier, federationId, true);
    }


    private static User getUserByField(Schema.SObjectField field, Object fieldValue, Boolean includeInactiveUsers) {
        List<User> matchingUserList = getUsersByField(field, fieldValue, includeInactiveUsers);
        if(matchingUserList.isEmpty()) throw new DataException('No matching user found');
        else if(matchingUserList.size() > 1) throw new DataException('Multiple matching users found');
        return matchingUserList[0];
    }

    private static List<User> getUsersByField(Schema.SObjectField field, Object fieldValue, Boolean includeInactiveUsers) {
        List<User> usersToCheck = includeInactiveUsers ? ALL_USERS_MAP.values() : ACTIVE_USERS_MAP.values();

        String fieldName = field.getDescribe().getName();
        List<User> matchingUserList = new List<User>();
        for(User user : usersToCheck) if(user.get(fieldName) == fieldValue) matchingUserList.add(user);

        return matchingUserList;
    }

    private static List<User> getAllUsers() {
        return [
            SELECT Id, CommunityNickname, Email, FederationIdentifier, FirstName, IsActive, LastName,
                ManagerId, Manager.Name, Name, Profile.Name, ProfileId, UserRole.Name, UserRoleId
            FROM User
        ];
    }

    private class DataException extends Exception {}

}