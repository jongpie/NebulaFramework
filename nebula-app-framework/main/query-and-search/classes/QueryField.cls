/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description Used to dynamically generate field string for SObject fields, including parent fields.
*
*/
public without sharing class QueryField extends NebulaCore implements IQueryField, Comparable {

    private final List<SObjectField> fields;
    private final String value;

    public QueryField(SObjectField field) {
        this(new List<SObjectField>{field});
    }

    public QueryField(List<SObjectField> fields) {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;

        this.fields = fields;
        this.value  = this.parseFields();
    }

    public String getValue() {
        return this.value;
    }

    private String parseFields() {
        if(this.fields.size() == 1) return String.valueOf(this.fields[0]);

        //Remove the last field from the list to iterate through so only the parent relationships are hopped
        List<SObjectField> fieldsToIterate = this.fields.clone();
        SObjectField lastField = (SObjectField) CollectionUtils.pop(fieldsToIterate);
        List<String> fieldChain = new List<String>();
        for(SObjectField parentField : fieldsToIterate) {
            fieldChain.add(parentField.getDescribe().getRelationshipName());
        }
        // Return the fully qualified field name
        return String.join(fieldChain, '.') + '.' + lastField.getDescribe().getName();
    }


    public Integer compareTo(Object compareTo) {
        QueryField compareToQueryField = (QueryField)compareTo;
        if(this.getValue() == compareToQueryField.getValue()) return 0;
        if(this.getValue() > compareToQueryField.getValue()) return 1;
        return -1;
    }

}