public without sharing class NebulaFactory {

    private static final System.Type DEFAULT_DML_IMPLEMENTATION                      = DML.class;
    private static final System.Type DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION = QueryArgumentFormatter.class;
    private static final System.Type DEFAULT_QUERY_BUILDER_IMPLEMENTATION            = QueryBuilder.class;
    private static final System.Type DEFAULT_QUERY_FILTER_IMPLEMENTATION             = QueryFilter.class;
    private static final System.Type DEFAULT_SOBJECT_RECORD_TYPES_IMPLEMENTATION     = SObjectRecordTypes.class;
    private static final System.Type DEFAULT_SOBJECT_REPOSITORY_IMPLEMENTATION       = SObjectRepository.class;
    private static final System.Type DEFAULT_SOBJECT_TRIGGER_HANDLER_IMPLEMENTATION  = SObjectTriggerHandler.class;

    private static Map<String, NebulaInterfaceImplementation__mdt> interfaceConfigs;
    private static String invalidClassForInterfaceError = 'The configured class "{0}" does not implement the Nebula interface "{1}". Actual type: {2}';

    public static IDML getDML() {
        return (IDML)createInterfaceImplementation(IDML.class, DEFAULT_DML_IMPLEMENTATION);
    }

    public static IQueryArgumentFormatter getQueryArgumentFormatter() {
        return (IQueryArgumentFormatter)createInterfaceImplementation(IQueryArgumentFormatter.class, DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION);
    }

    public static IQueryBuilder getQueryBuilder() {
        return (IQueryBuilder)createInterfaceImplementation(IQueryBuilder.class, DEFAULT_QUERY_BUILDER_IMPLEMENTATION);
    }

    public static IQueryFilter getQueryFilter() {
        return (IQueryFilter)createInterfaceImplementation(IQueryFilter.class, DEFAULT_QUERY_FILTER_IMPLEMENTATION);
    }

    public static ISObjectRecordTypes getSObjectRecordTypes() {
        return (ISObjectRecordTypes)createInterfaceImplementation(ISObjectRecordTypes.class, DEFAULT_SOBJECT_RECORD_TYPES_IMPLEMENTATION);
    }

    public static ISObjectRepository getSObjectRepository() {
        return (ISObjectRepository)createInterfaceImplementation(ISObjectRepository.class, DEFAULT_SOBJECT_REPOSITORY_IMPLEMENTATION);
    }

    public static ISObjectTriggerHandler getSObjectTriggerHandler() {
        return (ISObjectTriggerHandler)createInterfaceImplementation(ISObjectTriggerHandler.class, DEFAULT_SOBJECT_TRIGGER_HANDLER_IMPLEMENTATION);
    }
    
    private static Object createInterfaceImplementation(System.Type interfaceType, System.Type defaultImplementation) {
        getInterfaceConfigs();

        String interfaceName       = interfaceType.getName().replace('Nebula.', ''); //TODO figure out a better solution than replace()
        String configuredClassName = interfaceConfigs.get(interfaceName).ApexClass__c;
        configuredClassName = configuredClassName == null ? defaultImplementation.getName() : configuredClassName;

        //System.type t = Type.forName(configuredClassName) == null ? defaultImplementation : Type.forName(configuredClassName);
        System.type t = Type.forName(configuredClassName);

        if(t == null) {
            List<String> fillers = new List<String>{configuredClassName, interfaceName, String.valueOf(t)};
            String formattedError = String.format(invalidClassForInterfaceError, fillers);

            throw new ImplementationException(formattedError);
        }

        //TODO fix this
        // if(!t.equals(interfaceType)) {
        //     List<String> fillers = new List<String>{configuredClassName, interfaceName, String.valueOf(t)};
        //     String formattedError = String.format(invalidClassForInterfaceError, fillers);
        //
        //     throw new ImplementationException(formattedError);
        // }
        // another option to try to validate the implementation (not working though)
        // try {
        //     String str = JSON.serialize(t.newInstance());
        //     JSON.deserialize(str, interfaceType);
        // }
        // catch (System.JSONException je) {
        //     return false;
        // }

        Object impl = t.newInstance();
        impl = activateNebulaSharingSettings(impl);
        return impl;
    }

    private static void getInterfaceConfigs() {
        if(interfaceConfigs != null) return;

        interfaceConfigs = new Map<String, NebulaInterfaceImplementation__mdt>();

        for(NebulaInterfaceImplementation__mdt interfaceConfig : [SELECT Id, Label, DeveloperName, ApexClass__c FROM NebulaInterfaceImplementation__mdt]) {
            interfaceConfigs.put(interfaceConfig.DeveloperName, interfaceConfig);
        }
    }
    
    private static Object activateNebulaSharingSettings(Object impl) {
        Boolean isInstanceOfNebulaCore = impl instanceof NebulaCore;
        if(!isInstanceOfNebulaCore) return impl;
        
        //If the implementation also extends NebulaCore, then run additional steps
        String toDo = 'Inherit'; //TODO move to custom metadata or custom setting (picklist: inherit, with, without)
        
        INebulaCore core = (INebulaCore)impl;
        if(toDo == 'Inherit') return core;
        else if(toDo == 'With') return core.withSharing();
        else if(toDo == 'Without') return core.withoutSharing();
        else return core;
    }

    private class ImplementationException extends Exception {}

}