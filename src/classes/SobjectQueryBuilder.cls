/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class SobjectQueryBuilder extends Soql {

    private String displayFieldApiName;
    private List<String> polymorphicFieldStatements;
    private List<String> childRelationshipQueries;
    private Boolean forReference, forUpdate, forView, includeLabels, includeFormattedValues;

    public SobjectQueryBuilder(Schema.SobjectType sobjectType) {
        super(sobjectType, true);

        this.displayFieldApiName        = this.getDisplayFieldApiName(this.sobjectType);
        this.polymorphicFieldStatements = new List<String>();
        this.childRelationshipQueries   = new List<String>();
        this.forReference               = false;
        this.forUpdate                  = false;
        this.forView                    = false;
        this.includeLabels              = false;
        this.includeFormattedValues     = false;

        this.addDefaultFields();
    }

    public SobjectQueryBuilder addField(Schema.SobjectField field) {
        return this.addField(field, null);
    }

    public SobjectQueryBuilder addField(Schema.SobjectField field, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Schema.SobjectField>{field}, fieldCategory);
    }

    public SobjectQueryBuilder addField(Soql.QueryField queryField) {
        return this.addField(queryField, null);
    }

    public SobjectQueryBuilder addField(Soql.QueryField queryField, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Soql.QueryField>{queryField}, fieldCategory);
    }

    public SobjectQueryBuilder addFields(List<Schema.SobjectField> fields) {
        return this.addFields(fields, null);
    }

    public SobjectQueryBuilder addFields(List<Schema.SobjectField> fields, Soql.FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : fields) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.addFields(queryFields, fieldCategory);
    }

    public SobjectQueryBuilder addFields(List<Soql.QueryField> queryFields) {
        return this.addFields(queryFields, null);
    }

    public SobjectQueryBuilder addFields(Soql.FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : this.sobjectDescribe.fields.getMap().values()) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.addFields(queryFields, fieldCategory);
    }

    public SobjectQueryBuilder addFields(List<Soql.QueryField> queryFields, Soql.FieldCategory fieldCategory) {
        super.doAddFields(queryFields, fieldCategory);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder addFieldSet(Schema.FieldSet fieldSet) {
        return this.addFieldSet(fieldSet, null);
    }

    public SobjectQueryBuilder addFieldSet(Schema.FieldSet fieldSet, Soql.FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new Soql.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.addFields(queryFields, fieldCategory);
    }

    public SobjectQueryBuilder addPolymorphicFields(Schema.SobjectField relationshipField, Map<Schema.SobjectType, List<Schema.SobjectField>> fieldsBySobjectType) {
        String polymorphicFieldStatement = 'TYPEOF ' + relationshipField.getDescribe().getRelationshipName();
        for(Schema.SobjectType sobjectType : fieldsBySobjectType.keySet()) {
            List<String> fieldNames = new List<String>();
            for(Schema.SobjectField field : fieldsBySobjectType.get(sobjectType)) {
                if(field.getDescribe().isAccessible()) fieldNames.add(String.valueOf(field));
            }
            fieldNames.sort();
            polymorphicFieldStatement += ' WHEN ' + sobjectType + ' THEN ' + String.join(fieldNames, ', ');
        }
        polymorphicFieldStatement += ' END';
        this.polymorphicFieldStatements.add(polymorphicFieldStatement);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder includeLabels() {
        this.includeLabels = true;
        return this.setHasChanged();
    }

    public SobjectQueryBuilder includeFormattedValues() {
        this.includeFormattedValues = true;
        return this.setHasChanged();
    }

    public SobjectQueryBuilder removeField(Schema.SobjectField field) {
        return this.removeFields(new List<Schema.SobjectField>{field});
    }

    public SobjectQueryBuilder removeField(Soql.QueryField queryField) {
        return this.removeFields(new List<Soql.QueryField>{queryField});
    }

    public SobjectQueryBuilder removeFields(Schema.FieldSet fieldSet) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new Soql.QueryField(this.getSobjectType(), fieldSetMember.getFieldPath()));
        }
        return this.removeFields(queryFields);
    }

    public SobjectQueryBuilder removeFields(List<Schema.SobjectField> fields) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : fields) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.removeFields(queryFields);
    }

    public SobjectQueryBuilder removeFields(List<Soql.QueryField> queryFields) {
        super.doRemoveFields(queryFields);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder includeRelatedRecords(Schema.SobjectField childToParentRelationshipField, SobjectQueryBuilder relatedSobjectQuery) {
         this.childRelationshipQueries.add(relatedSobjectQuery.getRelatedRecordsQuery(childToParentRelationshipField));
         return this.setHasChanged();
    }

    public SobjectQueryBuilder usingScope(Scope scope) {
        super.doUsingScope(scope);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder filterWhere(Schema.SobjectField field, Soql.Operator operator, Object value) {
        return this.filterWhere(new Soql.QueryField(field), operator, value);
    }

    public SobjectQueryBuilder filterWhere(Soql.QueryField queryField, Soql.Operator operator, Object value) {
        return this.filterWhere(new Soql.QueryFilter(queryField, operator, value));
    }

    public SobjectQueryBuilder filterWhere(Soql.QueryFilter filter) {
        return this.filterWhere(new List<Soql.QueryFilter>{filter});
    }

    public SobjectQueryBuilder filterWhere(List<Soql.QueryFilter> filters) {
        super.doFilterWhere(filters);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder orFilterWhere(List<Soql.QueryFilter> filters) {
        super.doOrFilterWhere(filters);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder orderByField(Schema.SobjectField field) {
        return this.orderByField(new Soql.QueryField(field));
    }

    public SobjectQueryBuilder orderByField(Soql.QueryField queryField) {
        return this.orderByField(queryField, null);
    }

    public SobjectQueryBuilder orderByField(Schema.SobjectField field, Soql.SortOrder sortOrder) {
        return this.orderByField(field, sortOrder, null);
    }

    public SobjectQueryBuilder orderByField(Soql.QueryField queryField, Soql.SortOrder sortOrder) {
        return this.orderByField(queryField, sortOrder, null);
    }

    public SobjectQueryBuilder orderByField(Schema.SobjectField field, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderByField(new Soql.QueryField(field), sortOrder, sortNullsFirst);
    }

    public SobjectQueryBuilder orderByField(Soql.QueryField queryField, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        super.doOrderBy(queryField, sortOrder, sortNullsFirst);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder limitTo(Integer numberOfRecords) {
        super.doLimitTo(numberOfRecords);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder offsetBy(Integer offset) {
        super.doOffsetBy(offset);
        return this.setHasChanged();
    }

    public SobjectQueryBuilder forReference() {
        this.forReference = true;
        return this.setHasChanged();
    }

    public SobjectQueryBuilder forUpdate() {
        this.forUpdate = true;
        return this.setHasChanged();
    }

    public SobjectQueryBuilder forView() {
        this.forView = true;
        return this.setHasChanged();
    }

    public SobjectQueryBuilder cacheResults() {
        super.doCacheResults();
        return this;
    }

    public override String getQuery() {
        if(this.query != null && !this.hasChanged) return this.query;

        String queryFieldString = this.getQueryFieldString();

        String polymorphicFieldsString    = String.join(this.polymorphicFieldStatements, ', ');
        String polymorphicFieldsDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(polymorphicFieldsString) ? ', ' : '';

        String childRelationshipsQueryFieldString = this.getChildRelationshipsQueryFieldString();
        String childRelationshipDelimiter         = !String.isEmpty(queryFieldString) && !String.isEmpty(childRelationshipsQueryFieldString) ? ', ' : '';

        this.query = 'SELECT ' + queryFieldString
            + polymorphicFieldsDelimiter + polymorphicFieldsString
            + childRelationshipDelimiter + childRelationshipsQueryFieldString
            + ' FROM ' + this.sobjectType
            + super.doGetUsingScopeString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString()
            + super.doGetOffetString()
            + this.getForReferenceString()
            + this.getForUpdateString()
            + this.getForViewString();

        // Change hasChanged to false so that subsequent calls to getQuery() use the cached query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.query);
        return this.query;
    }

    public String getRelatedRecordsQuery(Schema.SobjectField childToParentRelationshipField) {
        Schema.SobjectType parentSobjectType = childToParentRelationshipField.getDescribe().getReferenceTo()[0];

        // Get the relationship name
        String childRelationshipName;
        for(Schema.ChildRelationship childRelationship : parentSobjectType.getDescribe().getChildRelationships()) {
            if(childRelationship.getField() != childToParentRelationshipField) continue;

            childRelationshipName = childRelationship.getRelationshipName();
        }

        String childQuery = '(SELECT ' + super.doGetQueryFieldString()
            + ' FROM ' + childRelationshipName
            + super.doGetUsingScopeString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString()
            + ')';

        System.debug(LoggingLevel.FINEST, childQuery);
        return childQuery;
    }

    public String getSearchQuery() {
        String sobjectTypeOptions = super.doGetQueryFieldString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString();

        // If we have any sobject-specific options, then wrap the options in parentheses
        sobjectTypeOptions = String.isEmpty(sobjectTypeOptions) ? '' : '(' + sobjectTypeOptions + ')';

        String searchQuery = this.getSobjectType() + sobjectTypeOptions;

        System.debug(LoggingLevel.FINEST, searchQuery);
        return searchQuery;
    }

    public Sobject getFirstResult() {
        return super.doGetFirstResult();
    }

    public List<Sobject> getResults() {
        return super.doGetResults();
    }

    private void addDefaultFields() {
        Map<String, Schema.SobjectField> fieldMap = this.getSobjectType().getDescribe().fields.getMap();
        this.addField(fieldMap.get('Id'));
        if(!String.isBlank(this.displayFieldApiName)) this.addField(fieldMap.get(this.displayFieldApiName));
    }

    private SobjectQueryBuilder setHasChanged() {
        this.hasChanged = true;
        return this;
    }

    private String getQueryFieldString() {
        Set<String> distinctFieldApiNamesToQuery = new Set<String>();
        for(Soql.QueryField queryField : this.includedQueryFieldsAndCategory.keySet()) {
            Soql.FieldCategory fieldCategory = this.includedQueryFieldsAndCategory.get(queryField);

            List<String> fieldsToQuery = this.getFieldsToQuery(queryField, fieldCategory);
            if(!fieldsToQuery.isEmpty()) distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
        }


        // Remove an excluded field paths
        for(Soql.QueryField excludedQueryField : this.excludedQueryFields) {
            distinctFieldApiNamesToQuery.remove(excludedQueryField.toString());
        }

        List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
        fieldApiNamesToQuery.sort();
        return String.join(fieldApiNamesToQuery, ', ');
    }

    private String getDisplayFieldApiName(Schema.SobjectType sobjectType) {
        // There are several commonly used names for the display field name - typically, Name
        // The order of the field names has been sorted based on number of objects in a new dev org with that field
        List<String> possibleDisplayFieldApiNames = new List<String>{
            'Name', 'DeveloperName', 'ApiName', 'Title', 'Subject', 'AssetRelationshipNumber',
            'CaseNumber', 'ContractNumber', 'Domain', 'FriendlyName', 'FunctionName', 'Label', 'LocalPart',
            'OrderItemNumber', 'OrderNumber', 'SolutionName', 'TestSuiteName'
        };
        Map<String, Schema.SobjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
        for(String fieldApiName : possibleDisplayFieldApiNames) {
            Schema.SobjectField field = fieldMap.get(fieldApiName);

            if(field == null) continue;

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if(fieldDescribe.isNameField()) return fieldDescribe.getName();
        }

        return null;
    }

    private String getParentObjectNameField(Schema.DescribeFieldResult fieldDescribe) {
        String relationshipName = fieldDescribe.getRelationshipName();
        Schema.SobjectType parentSobjectType = fieldDescribe.getReferenceTo()[0];
        String nameField = this.getDisplayFieldApiName(parentSobjectType);

        if(relationshipName == null) return null;
        else if(nameField == null) return null;
        else return relationshipName + '.' + nameField;
    }

    private List<String> getFieldsToQuery(Soql.QueryField queryField, Soql.FieldCategory fieldCat) {
        //List<String> fieldsToReturn = super.doGetFieldsToQuery(queryField, fieldCat);
        List<String> fieldsToReturn = new List<String>();

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.ACCESSIBLE && !queryField.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.UPDATEABLE && !queryField.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.STANDARD && queryField.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.CUSTOM && !queryField.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(queryField.toString());

        // If the field has picklist options, then it can be translated
        if(this.includeLabels && !queryField.getDescribe().getPickListValues().isEmpty()) {
            fieldsToReturn.add(this.getFieldToLabel(queryField.getDescribe().getName()));
        }

        // If the field is a number, date, time, or currency, it can be formatted
        List<Schema.DisplayType> supportedTypesForFormatting = new List<Schema.DisplayType>{
            Schema.DisplayType.CURRENCY, Schema.DisplayType.DATE, Schema.DisplayType.DATETIME, Schema.DisplayType.DOUBLE,
            Schema.DisplayType.INTEGER, Schema.DisplayType.PERCENT, Schema.DisplayType.TIME
        };
        if(this.includeFormattedValues && supportedTypesForFormatting.contains(queryField.getDescribe().getType())) {
            fieldsToReturn.add(this.getFieldFormattedValue(queryField.getDescribe().getName()));
        }

        // If the field is a lookup, then we need to get the name field from the parent object
        if(queryField.getDescribe().getType().name() == 'Reference') {
            if(queryField.getDescribe().isNamePointing()) {
                String fieldPath = queryField.getFieldPath();
                Integer indx = fieldPath.lastIndexOf(queryField.getDescribe().getName());
                String parentTypeFieldPath = fieldPath.substring(0, indx) + queryField.getDescribe().getRelationshipName() + '.Type';
                fieldsToReturn.add(parentTypeFieldPath);
            }

            String parentNameField = this.getParentObjectNameField(queryField.getDescribe());
            if(parentNameField != null) {
                fieldsToReturn.add(parentNameField);
                // Record type names can be translated, so include the translation
                if(this.includeLabels && queryField.toString() == 'RecordTypeId') fieldsToReturn.add(this.getFieldToLabel(parentNameField));
            }
        }

        return fieldsToReturn;
    }

    private String getChildRelationshipsQueryFieldString() {
        if(this.childRelationshipQueries.isEmpty()) return '';

        this.childRelationshipQueries.sort();
        return String.join(this.childRelationshipQueries, ', ');
    }

    private String getFieldToLabel(String fieldApiName) {
        return 'toLabel(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Label';
    }

    private String getFieldFormattedValue(String fieldApiName) {
        return 'format(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Formatted';
    }

    private String getForReferenceString() {
        return !this.forReference ? '' : ' FOR REFERENCE';
    }

    private String getForUpdateString() {
        return !this.forUpdate ? '' : ' FOR UPDATE';
    }

    private String getForViewString() {
        return !this.forView ? '' : ' FOR VIEW';
    }

}