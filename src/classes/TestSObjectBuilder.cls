/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class TestSObjectBuilder  {

    public static ITestSObjectBuilder getTestAccountBuilder() {
        return getTestSObjectBuilderInstance('TestAccountBuilder', TestSObjectBuilder.TestAccountBuilder.class);
    }

    public static ITestSObjectBuilder getTestContactBuilder() {
        return getTestSObjectBuilderInstance('TestContactBuilder', TestSObjectBuilder.TestContactBuilder.class);
    }

    public static ITestSObjectBuilder getTestLeadBuilder() {
        return getTestSObjectBuilderInstance('TestLeadBuilder', TestSObjectBuilder.TestLeadBuilder.class);
    }

    private static ITestSObjectBuilder getTestSObjectBuilderInstance(String builderName, System.Type fallbackBuilder) {
        System.Type t = Type.forName(builderName) != null ? Type.forName(builderName) : fallbackBuilder;
        return (ITestSObjectBuilder)t.newInstance();
    }

    public abstract class Base implements ITestSObjectBuilder {

        private Map<Schema.SObjectField, Object> fieldValueMap;

        public Base() {
            this.fieldValueMap = this.getDefaultFieldsAndValues();
        }

        public abstract Schema.SObjectType getSObjectType();
        // The minimum fields needed to insert a test record
        public abstract Map<SObjectField, Object> getDefaultFieldsAndValues();

        public ITestSObjectBuilder set(Schema.SObjectField field, Object value) {
            return this.set(new Map<Schema.SObjectField, Object>{field => value});
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
            List<SObject> records = new List<SObject>();
            for(Integer i = 0; i < numberOfRecordsToCreate; i++) {
                SObject record = this.getSObjectType().newSObject();

                for(Schema.SObjectField field : this.fieldValueMap.keySet()) {
                    Object value = this.fieldValueMap.get(field);
                    record.put(field.getDescribe().getName(), value);
                }

                records.add(record);
            }

            if(insertRecords) insert records;

            return records;
        }

        private void validateFields() {
            for(Schema.SObjectField field : this.fieldValueMap.keySet()) {
                // If the current field is a field for the SObject Type, then everythign is great!
                Schema.SObjectType fieldSObjectType = new SObjectFieldDescriber(field).getSObjectType();
                if(this.getSObjectType() == fieldSObjectType) continue;

                // If a field is provided but it's for a different SObject Type, throw an exception
                throw new TestSObjectBuilderException(field + ' belongs to SObject Type ' + fieldSObjectType + ', current SObject Type is ' + this.getSObjectType());
            }
        }
    }

    private class TestAccountBuilder extends TestSObjectBuilder.Base {

        public override Schema.SObjectType getSObjectType() {
            return Schema.Account.SObjectType;
        }

        public override Map<SObjectField, Object> getDefaultFieldsAndValues() {
            return new Map<SObjectField, Object>{
                Schema.Account.Name  => 'My Test Company'
            };
        }

    }

    private class TestContactBuilder extends TestSObjectBuilder.Base {

        public override Schema.SObjectType getSObjectType() {
            return Schema.Contact.SObjectType;
        }

        public override Map<SObjectField, Object> getDefaultFieldsAndValues() {
            return new Map<SObjectField, Object>{
                Schema.Contact.LastName  => 'Gillespie'
            };
        }

    }

    private class TestLeadBuilder extends TestSObjectBuilder.Base {

        public override Schema.SObjectType getSObjectType() {
            return Schema.Lead.SObjectType;
        }

        public override Map<SObjectField, Object> getDefaultFieldsAndValues() {
            return new Map<SObjectField, Object>{
                Schema.Lead.Company  => 'My Test Company',
                Schema.Lead.LastName => 'Gillespie'
            };
        }

    }

    private class TestSObjectBuilderException extends Exception {}

}