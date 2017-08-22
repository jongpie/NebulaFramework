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
public without sharing class QueryField {

    private final List<SObjectField> fields;

    public QueryField(SObjectField field) {
        this(new List<SObjectField>{field});
    }

    public QueryField(List<SObjectField> fields) {
        this.fields = fields;
    }

    public String getValue() {
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

}