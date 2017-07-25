/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
//TODO @isTest
public abstract class TestSObjectBuilder implements ITestSObjectBuilder {

    private Map<Schema.SObjectField, Object> fieldValueMap;

    public TestSObjectBuilder() {
        this.fieldValueMap = new Map<Schema.SObjectField, Object>();
    }

    public abstract Schema.SObjectType getSObjectType();

    public ITestSObjectBuilder set(Schema.SObjectField field, Object value) {
        this.fieldValueMap.put(field, value);
        return this;
    }

    public ITestSObjectBuilder set(Map<Schema.SObjectField, Object> fieldsAndValues) {
        this.fieldValueMap.putAll(fieldsAndValues);
        return this;
    }

    public SObject build() {
        return this.build(false);
    }

    public SObject build(Boolean insertRecord) {
        return this.build(1, insertRecord)[0];
    }

    public List<SObject> build(Integer numberOfRecordsToCreate) {
        return this.build(numberOfRecordsToCreate, false);
    }

    public List<SObject> build(Integer numberOfRecordsToCreate, Boolean insertRecords) {
        List<SObject> sobjects = new List<SObject>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++) {
            SObject sobj = this.getSObjectType().newSObject();
            for(Schema.SObjectField field : this.fieldValueMap.keySet()) {
                Object value = this.fieldValueMap.get(field);
                sobj.put(field.getDescribe().getName(), value);
            }

            sobjects.add(sobj);
        }

        if(insertRecords) insert sobjects;

        return sobjects;
    }

}