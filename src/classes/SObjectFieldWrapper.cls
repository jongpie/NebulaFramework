public class SObjectFieldWrapper {
    private final List<SObjectField> fields;

    public SObjectFieldWrapper(SObjectField field) {
        this(new List<SObjectField>{ field });
    }

    public SObjectFieldWrapper(List<SObjectField> fields) {
        this.fields = fields;
    }

    public String VALUE {
        get {
            if(this.Fields.size() == 1 ) {
                return String.valueOf(this.Fields[0]);
            }

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
}