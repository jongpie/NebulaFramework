/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class SObjectFieldDescriber {
    // We would love for Schema.SObjectField to have a way to return the SObject Type
    // Sadly, it doesn't, so we have this class to fill the void.
    // If a proper method is ever added to Apex to get the field's SObject Type,
    // then we should consider removing this class.

    private static Map<Integer, Schema.SObjectType> sobjectFieldHashCodeToSObjectTypeMap;

    public Schema.SObjectField SObjectField {get; private set;}
    // TODO switch this to a getSObjectType() method maybe?
    public Schema.SObjectType SObjectType {get; private set;}

    public SObjectFieldDescriber(Schema.SObjectField sobjectField) {
        this.cacheSObjectTypeFieldHashCodes();

        this.SObjectField = sobjectField;
        this.setSObjectType();
    }

    public String getFieldName() {
        return this.SObjectField.getDescribe().getName();
    }

    public String getFullFieldName() {
        return this.SObjectType + '.' + this.getFieldName();
    }

    public Schema.SObjectType getParentSObjectType() {
        Schema.DescribeFieldResult fieldDescribe = this.SObjectField.getDescribe();

        Schema.SObjectType parentSObjectType;
        if(!fieldDescribe.isNamePointing() && !fieldDescribe.getReferenceTo().isEmpty()) parentSObjectType = fieldDescribe.getReferenceTo()[0];

        return parentSObjectType;
    }

    public Boolean validateSObjectType(Schema.SObjectType expectedSObjectType) {
        return this.SObjectType == expectedSObjectType;
    }

    private void setSObjectType() {
        Integer sobjectFieldHashCode = this.getHashCode(this.sobjectField);
        this.SObjectType = sobjectFieldHashCodeToSObjectTypeMap.get(sobjectFieldHashCode);
    }

    private void cacheSObjectTypeFieldHashCodes() {
        // Describe calls are "free" but still add CPU time, so let's cache them
        if(sobjectFieldHashCodeToSObjectTypeMap != null) return;

        sobjectFieldHashCodeToSObjectTypeMap = new Map<Integer,Schema.SObjectType>();

        // Build a map of hash codes for each fieldDescribe taken from Schema Global Describe
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for(String sobjTypeName : globalDescribe.keySet()) {
            SObjectType sobjType = globalDescribe.get(sobjTypeName);

            for(Schema.SObjectField sobjField : sobjType.getDescribe().fields.getMap().values()) {
                Integer sobjFieldHashCode = getHashCode(sobjField);

                sobjectFieldHashCodeToSObjectTypeMap.put(sobjFieldHashCode, sobjType);
            }
        }
    }

    private Integer getHashCode(Schema.SObjectField sobjField) {
        return ((Object)sobjField).hashCode();
    }

}