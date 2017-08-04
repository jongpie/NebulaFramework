
/**
*
* @group Configuration
*
* @description TODO
*/
public without sharing class NebulaFactory {

    private static final System.Type DEFAULT_AGGREGATE_RESULT_QUERY_BUILDER_IMPLEMENTATION = AggregateResultQueryBuilder.class;
    private static final System.Type DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION       = QueryArgumentFormatter.class;
    private static final System.Type DEFAULT_SOBJECT_QUERY_BUILDER_IMPLEMENTATION          = SObjectQueryBuilder.class;
    private static final System.Type DEFAULT_QUERY_FILTER_IMPLEMENTATION                   = QueryFilter.class;
    private static final System.Type DEFAULT_SOBJECT_REPOSITORY_IMPLEMENTATION             = SObjectRepository.class;

    private static Map<String, NebulaInterfaceImplementation__mdt> interfaceConfigs;
    private static String invalidClassForInterfaceError = 'The configured class "{0}" does not implement the Nebula interface "{1}". Actual type: {2}';

    public static IQueryArgumentFormatter getQueryArgumentFormatter() {
        return (IQueryArgumentFormatter)createInterfaceImplementation(IQueryArgumentFormatter.class, DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION);
    }

    public static ISObjectQueryBuilder getSObjectQueryBuilder() {
        return (ISObjectQueryBuilder)createInterfaceImplementation(ISObjectQueryBuilder.class, DEFAULT_SOBJECT_QUERY_BUILDER_IMPLEMENTATION);
    }

    public static IAggregateResultQueryBuilder getAggregateQueryBuilder() {
        return (IAggregateResultQueryBuilder)createInterfaceImplementation(IAggregateResultQueryBuilder.class, DEFAULT_AGGREGATE_RESULT_QUERY_BUILDER_IMPLEMENTATION);
    }

    public static IQueryFilter getQueryFilter() {
        return (IQueryFilter)createInterfaceImplementation(IQueryFilter.class, DEFAULT_QUERY_FILTER_IMPLEMENTATION);
    }

    public static ISObjectRepository getSObjectRepository() {
        return (ISObjectRepository)createInterfaceImplementation(ISObjectRepository.class, DEFAULT_SOBJECT_REPOSITORY_IMPLEMENTATION);
    }

    private static Object createInterfaceImplementation(System.Type interfaceType, System.Type defaultImplementation) {
        getInterfaceConfigs();

        String interfaceName       = interfaceType.getName().replace('Nebula.', ''); //TODO figure out a better solution than replace()
        String configuredClassName = interfaceConfigs.get(interfaceName).ApexClass__c;
        configuredClassName = configuredClassName == null ? defaultImplementation.getName() : configuredClassName;

        System.type t = Type.forName(configuredClassName);

        if(t == null) {
            List<String> fillers = new List<String>{configuredClassName, interfaceName, String.valueOf(t)};
            String formattedError = String.format(invalidClassForInterfaceError, fillers);

            throw new ImplementationException(formattedError);
        }

        Object instance = t.newInstance();
        instance = activateNebulaSharingSettings(instance);
        return instance;
    }

    private static void getInterfaceConfigs() {
        if(interfaceConfigs != null) return;

        interfaceConfigs = new Map<String, NebulaInterfaceImplementation__mdt>();

        for(NebulaInterfaceImplementation__mdt interfaceConfig : [SELECT Id, Label, DeveloperName, ApexClass__c FROM NebulaInterfaceImplementation__mdt]) {
            interfaceConfigs.put(interfaceConfig.DeveloperName, interfaceConfig);
        }
    }

    private static Object activateNebulaSharingSettings(Object instance) {
        Boolean isInstanceOfNebulaCore = instance instanceof NebulaCore;
        if(!isInstanceOfNebulaCore) return instance;

        //If the implementation also extends NebulaCore, then run additional steps
        String toDo = 'Inherit'; //TODO move to custom metadata or custom setting (picklist: inherit, with, without)

        INebulaCore nebulaClassInstance = (INebulaCore)instance;
        if(toDo == 'Inherit') return nebulaClassInstance;
        // TODO: finish implementing
        //else if(toDo == 'With') return nebulaClassInstance.withSharing();
        //else if(toDo == 'Without') return nebulaClassInstance.withoutSharing();
        else return nebulaClassInstance;
    }

    private class ImplementationException extends Exception {}

}