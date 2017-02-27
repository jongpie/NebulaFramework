public class Environment {

    public static String BaseUrl {
        get {return URL.getSalesforceBaseUrl().toExternalForm();}
    }

    public static String InstanceName {
        get {return organization.InstanceName;}
    }

    public static Boolean IsSandbox {
        get {return organization.IsSandbox;}
    }

    public static String Name {
        get {return organization.Name;}
    }

    public static String Type {
        get {return organization.OrganizationType;}
    }

    private static Organization organization {
        get {
            if(organization == null) organization = [SELECT Id, InstanceName, IsSandbox, Name, OrganizationType FROM Organization];
            return organization;
        }
    }

}