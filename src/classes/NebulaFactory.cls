/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Configuration
*
* @description TODO
*
*/
public without sharing class NebulaFactory {

    private static final System.Type DEFAULT_AGGREGATE_RESULT_QUERY_BUILDER_IMPLEMENTATION = AggregateResultQueryBuilder.class;
    private static final System.Type DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION       = QueryArgumentFormatter.class;
    private static final System.Type DEFAULT_SOBJECT_QUERY_BUILDER_IMPLEMENTATION          = SObjectQueryBuilder.class;
    private static final System.Type DEFAULT_QUERY_FILTER_IMPLEMENTATION                   = QueryFilter.class;

    private static Map<String, NebulaInterfaceImplementation__mdt> interfaceConfigs;
    private static String invalidClassForInterfaceError = 'The configured class "{0}" does not implement the Nebula interface "{1}". Actual type: {2}';

    static {
        getInterfaceConfigs();
    }

    public static IAggregateResultQueryBuilder getAggregateQueryBuilder() {
        return (IAggregateResultQueryBuilder)createInterfaceImplementation(IAggregateResultQueryBuilder.class, DEFAULT_AGGREGATE_RESULT_QUERY_BUILDER_IMPLEMENTATION);
    }

    public static IQueryArgumentFormatter getQueryArgumentFormatter() {
        return (IQueryArgumentFormatter)createInterfaceImplementation(IQueryArgumentFormatter.class, DEFAULT_QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION);
    }

    public static IQueryFilter getQueryFilter() {
        return (IQueryFilter)createInterfaceImplementation(IQueryFilter.class, DEFAULT_QUERY_FILTER_IMPLEMENTATION);
    }

    public static ISObjectQueryBuilder getSObjectQueryBuilder() {
        return (ISObjectQueryBuilder)createInterfaceImplementation(ISObjectQueryBuilder.class, DEFAULT_SOBJECT_QUERY_BUILDER_IMPLEMENTATION);
    }

    private static Object createInterfaceImplementation(System.Type interfaceType, System.Type defaultImplementation) {
        String interfaceName = interfaceType.getName();

        NebulaInterfaceImplementation__mdt config = interfaceConfigs.get(interfaceName);
        String configuredClassName;
        if(config == null || config.ApexClass__c == null) configuredClassName = defaultImplementation.getName();
        else configuredClassName = config.ApexClass__c;

        System.type t = Type.forName(configuredClassName);

        if(t == null) {
            List<String> fillers = new List<String>{configuredClassName, interfaceName, String.valueOf(t)};
            String formattedError = String.format(invalidClassForInterfaceError, fillers);

            throw new ImplementationException(formattedError);
        }

        return t.newInstance();
    }

    private static void getInterfaceConfigs() {
        if(interfaceConfigs != null) return;

        interfaceConfigs = new Map<String, NebulaInterfaceImplementation__mdt>();

        for(NebulaInterfaceImplementation__mdt interfaceConfig : [SELECT Id, Label, DeveloperName, ApexClass__c FROM NebulaInterfaceImplementation__mdt]) {
            interfaceConfigs.put(interfaceConfig.DeveloperName, interfaceConfig);
        }
    }

    private class ImplementationException extends Exception {}

}