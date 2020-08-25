/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class SObjectComparator {

    private SObject recordVersion1, recordVersion2;
    private Schema.SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    public SObjectComparator(SObject recordVersion1, SObject recordVersion2) {
        this.recordVersion1 = recordVersion1;
        this.recordVersion2 = recordVersion2;

        this.sobjectType = recordVersion1.getSObjectType();
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();

        this.validate();
    }

    public Set<Schema.SObjectField> getChangedFields() {
        Set<String> populatedFieldNames = new Set<String>();
        populatedFieldNames.addAll(this.recordVersion1.getPopulatedFieldsAsMap().keySet());
        populatedFieldNames.addAll(this.recordVersion2.getPopulatedFieldsAsMap().keySet());

        Set<Schema.SObjectField> changedFields = new Set<Schema.SObjectField>();
        for(String fieldName : populatedFieldNames) {
            Schema.SObjectField field = this.sobjectTypeFieldMap.get(fieldName);
            if(this.hasFieldChanged(field)) changedFields.add(field);
        }

        return changedFields;
    }

    public Boolean hasAnyFieldChanged() {
        return this.getChangedFields().isEmpty() == false;
    }

    public Boolean hasFieldChanged(Schema.SObjectField field) {
        if(field == null) return false;

        String fieldName = field.getDescribe().getName();
        return this.recordVersion1.get(fieldName) != this.recordVersion2.get(fieldName);
    }

    public Boolean hasAnyFieldChanged(Set<Schema.SObjectField> fields) {
        return this.hasAnyFieldChanged(new List<Schema.SObjectField>(fields));
    }

    public Boolean hasAnyFieldChanged(List<Schema.SObjectField> fields) {
        if(fields.isEmpty()) return false;

        for(Schema.SObjectField field : fields) {
            if(this.hasFieldChanged(field)) return true;
        }

        return false;
    }

    private void validate() {
        if(this.recordVersion1.getSObjectType() != this.recordVersion2.getSObjectType()) {
            throw new SObjectComparatorException('Records must be the same type of SObject');
        }

        if(this.recordVersion1.Id != null && this.recordVersion2.Id != null && this.recordVersion1.Id != this.recordVersion2.Id) {
            throw new SObjectComparatorException('Records must have the same ID');
        }
    }

    public class SObjectComparatorException extends Exception {}

}