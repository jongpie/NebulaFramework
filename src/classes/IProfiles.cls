public interface IProfiles {

    Map<Id, Profile> getAllById();
    Map<String, Profile> getAllByName();
    Profile getSystemAdministrator();

}