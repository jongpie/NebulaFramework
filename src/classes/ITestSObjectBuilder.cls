/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ITestSObjectBuilder {

    // Setup methods
    Schema.SObjectType getSObjectType();

    // Setter methods
    ITestSObjectBuilder set(Schema.SObjectField field, Object value);
    ITestSObjectBuilder set(Map<Schema.SObjectField, Object> fieldsAndValues);

    // Builder methods
    SObject build();
    SObject build(Boolean insertRecord);
    List<SObject> build(Integer numberOfRecordsToCreate);
    List<SObject> build(Integer numberOfRecordsToCreate, Boolean insertRecords);

}