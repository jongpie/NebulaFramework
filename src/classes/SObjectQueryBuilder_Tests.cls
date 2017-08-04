@isTest
private class SObjectQueryBuilder_Tests {

    @isTest
    static void it_should_generate_a_query_with_a_subselect() {
        List<Lead> leads = (List<Lead>)new SObjectQueryBuilder()
            .setSObjectType(Schema.Lead.SObjectType)
            .inSubquery(Schema.Lead.OwnerId, Schema.User.Id)
            .getQueryResults();

        // TODO finish writings tests System.assert(false, 'finish writing tests');
    }

}