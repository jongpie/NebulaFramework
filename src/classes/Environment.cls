public class Environment {

    public static String BaseUrl {
        get {return URL.getSalesforceBaseUrl().toExternalForm();}
        private set;
    }

    public static String InstanceName {
        get {return organization.InstanceName;}
        private set;
    }

    public static Boolean IsSandbox {
        get {return organization.IsSandbox;}
        private set;
    }

    public static String Name {
        get {return organization.Name;}
        private set;
    }

    public static String Type {
        get {return organization.OrganizationType;}
        private set;
    }

    private static Organization organization {
        get {
            if(organization == null) organization = [SELECT Id, InstanceName, IsSandbox, Name, OrganizationType FROM Organization];
            return organization;
        }
        private set;
    }

}