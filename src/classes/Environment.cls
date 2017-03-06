global class Environment {

    global static String BaseUrl {
        get {return URL.getSalesforceBaseUrl().toExternalForm();}
    }

    global static String InstanceName {
        get {return organization.InstanceName;}
    }

    global static Boolean IsSandbox {
        get {return organization.IsSandbox;}
    }

    global static String Name {
        get {return organization.Name;}
    }

    global static String Type {
        get {return organization.OrganizationType;}
    }

    private static Organization organization {
        get {
            if(organization == null) organization = [SELECT Id, InstanceName, IsSandbox, Name, OrganizationType FROM Organization];
            return organization;
        }
    }

}