public interface ISObjectComparison {

    // Methods that rely on sobject.getPopulatedFieldsAsMap();
    Set<Schema.SObjectField> getChangedFields();
    Boolean hasAnyFieldChanged();

    // Methods that rely on parameters
    Boolean hasFieldChanged(Schema.SObjectField field);
    Boolean hasAnyFieldChanged(Set<Schema.SObjectField> fields);
    Boolean hasAnyFieldChanged(List<Schema.SObjectField> fields);

}