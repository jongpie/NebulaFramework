/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class SobjectComparator {

    private Sobject recordVersion1, recordVersion2;
    private Schema.SobjectType sobjectType;
    private Map<String, Schema.SobjectField> sobjectTypeFieldMap;

    public SobjectComparator(Sobject recordVersion1, Sobject recordVersion2) {
        this.recordVersion1 = recordVersion1;
        this.recordVersion2 = recordVersion2;

        this.sobjectType = recordVersion1.getSobjectType();
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();

        this.validate();
    }

    public Set<Schema.SobjectField> getChangedFields() {
        Set<String> populatedFieldNames = new Set<String>();
        populatedFieldNames.addAll(this.recordVersion1.getPopulatedFieldsAsMap().keySet());
        populatedFieldNames.addAll(this.recordVersion2.getPopulatedFieldsAsMap().keySet());

        Set<Schema.SobjectField> changedFields = new Set<Schema.SobjectField>();
        for(String fieldName : populatedFieldNames) {
            Schema.SobjectField field = this.sobjectTypeFieldMap.get(fieldName);
            if(this.hasFieldChanged(field)) changedFields.add(field);
        }

        return changedFields;
    }

    public Boolean hasAnyFieldChanged() {
        return this.getChangedFields().isEmpty() == false;
    }

    public Boolean hasFieldChanged(Schema.SobjectField field) {
        if(field == null) return false;

        String fieldName = field.getDescribe().getName();
        return this.recordVersion1.get(fieldName) != this.recordVersion2.get(fieldName);
    }

    public Boolean hasAnyFieldChanged(Set<Schema.SobjectField> fields) {
        return this.hasAnyFieldChanged(new List<Schema.SobjectField>(fields));
    }

    public Boolean hasAnyFieldChanged(List<Schema.SobjectField> fields) {
        if(fields.isEmpty()) return false;

        for(Schema.SobjectField field : fields) {
            if(this.hasFieldChanged(field)) return true;
        }

        return false;
    }

    private void validate() {
        if(this.recordVersion1.getSobjectType() != this.recordVersion2.getSobjectType()) {
            throw new SobjectComparatorException('Records must be the same type of Sobject');
        }

        if(this.recordVersion1.Id != null && this.recordVersion2.Id != null && this.recordVersion1.Id != this.recordVersion2.Id) {
            throw new SobjectComparatorException('Records must have the same ID');
        }
    }

    public class SobjectComparatorException extends Exception {}

}