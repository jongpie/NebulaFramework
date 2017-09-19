/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectQueryBuilder_Tests {

    static String getFirstLineThatStartsWith(String stringToSearch, String stringToCheckFor) {
        String matchingLine;
        for(String stringPartToSearch : stringToSearch.split('\n')) {
            if(!stringPartToSearch.startsWith(stringToCheckFor)) continue;

            matchingLine = stringPartToSearch;
            break;
        }

        return matchingLine;
    }

    static Set<String> getQueryQueryFieldStringSet(String queryString) {
        String selectString = getFirstLineThatStartsWith(queryString, 'SELECT');
        Set<String> queryFieldStringSet = new Set<String>();
        for(String unparsedString : selectString.remove('SELECT ').split(',')) {
            queryFieldStringSet.add(unparsedString.trim());
        }
        return queryFieldStringSet;
    }

    static String getParentSObjectNameField(Schema.SObjectField field) {
        if(field.getDescribe().getType().name() != 'Reference') return null;

        String relationshipName = field.getDescribe().getRelationshipName();
        Schema.SObjectType parentSObjectType = field.getDescribe().getReferenceTo()[0];
        String nameField;
        for(Schema.SObjectField parentField : parentSObjectType.getDescribe().fields.getMap().values()) {
            if(parentField.getDescribe().isNameField()) {
                nameField = parentField.getDescribe().getName();
                break;
            }
        }
        return relationshipName + '.' + nameField;
    }

    static List<String> buildExpectedQueryFieldStrings(List<Schema.SObjectField> sobjectFields) {
        List<String> expectedQueryFieldStrings = new List<String>();
        for(Schema.SObjectField field : sobjectFields) {
            expectedQueryFieldStrings.add(field.getDescribe().getName().toLowerCase());

            String parentNameField = getParentSObjectNameField(field);
            if(parentNameField != null) expectedQueryFieldStrings.add(parentNameField.toLowerCase());
        }
        expectedQueryFieldStrings.sort();
        return expectedQueryFieldStrings;
    }

    static List<QueryField> convertToQueryFields(List<Schema.SObjectField> fields) {
        List<QueryField> queryFields = new List<QueryField>();
        for(Schema.SObjectField field : fields) queryFields.add(new QueryField(field));
        return queryFields;
    }

    @isTest
    static void it_should_be_usable_after_construction() {
        // Query builders should be usable as soon as it's constructed - it should be able to execute a query with some default values
        ISObjectQueryBuilder opportunityQueryBuilder = new SObjectQueryBuilder(Schema.Opportunity.SObjectType);

        Test.startTest();

        List<Opportunity> results = (List<Opportunity>)opportunityQueryBuilder.getQueryResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_results() {
        ISObjectQueryBuilder opportunityQueryBuilder = new SObjectQueryBuilder(Schema.Opportunity.SObjectType);
        opportunityQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(opportunityQueryBuilder.getQueryResults());
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_add_a_list_of_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.Id, Schema.Contact.AccountId, Schema.Contact.CreatedDate};
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(fields);
        expectedQueryFieldStrings.sort();

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addFields(convertToQueryFields(fields));
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_add_all_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(sobjectType.getDescribe().fields.getMap().values());

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addAllFields();
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_add_all_standard_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<Schema.SObjectField> standardFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            if(field.getDescribe().isCustom()) continue;

            standardFields.add(field);
        }
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(standardFields);

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addAllStandardFields();
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_add_all_custom_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<Schema.SObjectField> customFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            if(!field.getDescribe().isCustom()) continue;

            customFields.add(field);
        }
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(customFields);

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addAllCustomFields();
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_add_all_readable_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<Schema.SObjectField> standardFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            if(!field.getDescribe().isAccessible()) continue;

            standardFields.add(field);
        }
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(standardFields);

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addAllReadableFields();
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_add_all_editable_fields() {
        NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c = false;
        upsert NebulaSettings.SObjectQueryBuilderSettings;

        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<Schema.SObjectField> standardFields = new List<Schema.SObjectField>();
        for(Schema.SObjectField field : sobjectType.getDescribe().fields.getMap().values()) {
            if(!field.getDescribe().isUpdateable()) continue;

            standardFields.add(field);
        }
        List<String> expectedQueryFieldStrings = buildExpectedQueryFieldStrings(standardFields);

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType);
        query.addAllEditableFields();
        Test.stopTest();

        Set<String> queryFieldStringSet = getQueryQueryFieldStringSet(query.getQuery());

        // Verify that only our expected field name strings are included in the query
        System.assertEquals(expectedQueryFieldStrings.size(), queryFieldStringSet.size());
        for(String expectedQueryFieldString : expectedQueryFieldStrings) {
            System.assert(queryFieldStringSet.contains(expectedQueryFieldString), expectedQueryFieldString + queryFieldStringSet);
        }

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.CreatedDate));
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.CreatedDate.getDescribe().getName()), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_ascending() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.CreatedDate), QuerySortOrder.ASCENDING);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.CreatedDate.getDescribe().getName() + ' ASC'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_descending() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.CreatedDate), QuerySortOrder.DESCENDING);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.CreatedDate.getDescribe().getName() + ' DESC'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_ascending_nulls_first() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.FirstName};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.FirstName), QuerySortOrder.ASCENDING, QueryNullSortOrder.FIRST);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.FirstName.getDescribe().getName() + ' ASC NULLS FIRST'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_descending_nulls_first() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.FirstName};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.FirstName), QuerySortOrder.DESCENDING, QueryNullSortOrder.FIRST);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.FirstName.getDescribe().getName() + ' DESC NULLS FIRST'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_ascending_nulls_last() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.FirstName};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.FirstName), QuerySortOrder.ASCENDING, QueryNullSortOrder.LAST);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.FirstName.getDescribe().getName() + ' ASC NULLS LAST'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_order_by_field_descending_nulls_last() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.FirstName};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.orderBy(new QueryField(Schema.Contact.FirstName), QuerySortOrder.DESCENDING, QueryNullSortOrder.LAST);
        Test.stopTest();

        String orderByString = getFirstLineThatStartsWith(query.getQuery(), 'ORDER BY');
        System.assert(orderByString.contains(Contact.FirstName.getDescribe().getName() + ' DESC NULLS LAST'), orderByString);

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_limit_count() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};
        Integer limitCount = 99;

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.limitCount(limitCount);
        Test.stopTest();

        System.assert(query.getQuery().contains('LIMIT ' + limitCount));

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_set_as_update() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.forUpdate();
        Test.stopTest();

        System.assert(query.getQuery().contains('FOR UPDATE'));

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_set_using_scope() {
        Schema.SObjectType sobjectType = Schema.Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Schema.Contact.CreatedDate};
        QueryFilterScope scope = QueryFilterScope.TEAM;

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder(sobjectType).addFields(convertToQueryFields(fields));
        query.usingScope(scope);
        Test.stopTest();

        System.assert(query.getQuery().contains('USING SCOPE ' + scope.name()));

        // Execute the query to make sure it's executable
        query.getQueryResults();
    }

    @isTest
    static void it_should_generate_a_query_with_a_subselect() {
        List<Lead> leads = (List<Lead>)new SObjectQueryBuilder(Schema.Lead.SObjectType)
            .filterBy(new QueryFilter().filterBySubquery(Schema.Lead.OwnerId, QueryOperator.IS_IN, Schema.User.Id))
            .getQueryResults();

        // TODO finish writings tests System.assert(false, 'finish writing tests');
    }

}