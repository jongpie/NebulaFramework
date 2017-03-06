global class Environment {

    global static String BaseUrl {
        get {return URL.getSalesforceBaseUrl().toExternalForm();}
        private set;
    }

    global static String InstanceName {
        get {return organization.InstanceName;}
        private set;
    }

    global static Boolean IsSandbox {
        get {return organization.IsSandbox;}
        private set;
    }

    global static String Name {
        get {return organization.Name;}
        private set;
    }

    global static String Type {
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