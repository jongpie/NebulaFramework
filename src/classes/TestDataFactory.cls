/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class TestDataFactory {

    private final Schema.SobjectType sobjectType;
    private final List<Schema.SobjectField> requiredFields;

    private Sobject record;

    public TestDataFactory(Schema.SobjectType sobjectType) {
        this(sobjectType.newSobject());
    }

    public TestDataFactory(Sobject record) {
        this.record      = record;
        this.sobjectType = record.getSobjectType();

        this.requiredFields = this.getRequiredFields();
    }

    public Sobject populateRequiredFields() {
        this.setRequiredFieldsOnRecord();
        return this.record;
    }

    private List<Schema.SobjectField> getRequiredFields() {
        List<SobjectField> requiredFields = new List<SobjectField>();
        for(Schema.SobjectField field : this.sobjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            // Guard clauses for fields that aren't required
            if(fieldDescribe.isNillable() == true) continue;
            if(fieldDescribe.isCreateable() == false) continue;

            // If a field is not nillable & it is createable, then it's required
            requiredFields.add(field);
        }

        return requiredFields;
    }

    private void setRequiredFieldsOnRecord() {
        Map<String, Object> populatedFields = this.record.getPopulatedFieldsAsMap();
        for(Schema.SobjectField field : this.requiredFields) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            // If a field was already populated by using the constructor 'TestDataFactory(Sobject record)', then don't change it
            if(populatedFields.containsKey(fieldDescribe.getName())) continue;

            Object fieldValue;
            if(fieldDescribe.getDefaultValue() != null) {
                // If there is a default value setup for the field, use it
                fieldValue = fieldDescribe.getDefaultValue();
            } else {
                // Otherwise, we'll generate our own test value to use, based on the field's metadata
                fieldValue = this.getTestValue(fieldDescribe);
            }

            // If we now have a value to use, set it on the record
            if(fieldValue != null) this.record.put(field, fieldValue);
        }
    }

    private Object getTestValue(Schema.DescribeFieldResult fieldDescribe) {
        Schema.DisplayType displayType = fieldDescribe.getType();
        // Since Apex does not support case statements, we use several ugly IF-ELSE statements
        // Some more complex data types, like ID & Reference, require other objects to be created
        // This implementation delegates that responsibility to the test classes since DML is required to get a valid ID,
        // but the logic below could be updated to support creating parent objects if needed

        // Unsupported display types have been commented-out below
        /*
            Schema.DisplayType.Address, Schema.DisplayType.AnyType, Schema.DisplayType.Base64,
            Schema.DisplayType.DataCategoryGroupReference, Schema.DisplayType.Id, Schema.DisplayType.Reference
        */

        if(displayType == Schema.DisplayType.Boolean) return false;
        else if(displayType == Schema.DisplayType.Combobox) return 'Test combobox';
        else if(displayType == Schema.DisplayType.Currency) return 19.85;
        else if(displayType == Schema.DisplayType.Date) return System.today();
        else if(displayType == Schema.DisplayType.DateTime) return System.now();
        else if(displayType == Schema.DisplayType.Double) return 3.14;
        else if(displayType == Schema.DisplayType.Email) return 'test@example.com';
        else if(displayType == Schema.DisplayType.EncryptedString) return this.getStringValue(fieldDescribe);
        else if(displayType == Schema.DisplayType.Integer) return 1;
        else if(displayType == Schema.DisplayType.MultiPicklist) return fieldDescribe.getPicklistValues()[0].getValue();
        else if(displayType == Schema.DisplayType.Percent) return 0.42;
        else if(displayType == Schema.DisplayType.Phone) return '+34 999 11 22 33';
        else if(displayType == Schema.DisplayType.Picklist) return fieldDescribe.getPicklistValues()[0].getValue();
        else if(displayType == Schema.DisplayType.String) return this.getStringValue(fieldDescribe);
        else if(displayType == Schema.DisplayType.TextArea) return this.getStringValue(fieldDescribe);
        else if(displayType == Schema.DisplayType.Time) return Time.newInstance(13, 30, 6, 20);
        else if(displayType == Schema.DisplayType.Url) return 'https://salesforce.com';

        // Any non-supported display types will return null - test classes will need to handle setting the values
        else return null;
    }

    private String getStringValue(Schema.DescribeFieldResult fieldDescribe) {
        String strValue   = 'Test string for ' + fieldDescribe.getType();
        Integer maxLength = fieldDescribe.getLength();

        return strValue.length() <= maxLength ? strValue : strValue.left(maxLength);
    }

}