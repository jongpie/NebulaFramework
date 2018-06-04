public virtual class Soql implements Comparable {

    public enum Aggregate { AVG, COUNT, COUNT_DISTINCT, MAX, MIN, SUM }
    public enum FieldCategory { ACCESSIBLE, UPDATEABLE, STANDARD, CUSTOM }
    public enum Scope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }
    public enum SortOrder { ASCENDING, DESCENDING }

    private static final FieldCategory DEFAULT_FIELD_CATEGORY   = FieldCategory.ACCESSIBLE;
    private static final SortOrder DEFAULT_SORT_ORDER           = SortOrder.ASCENDING;
    private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST = true;

    private static Map<Integer, List<Sobject>> cachedQueryResultsByHashCode = new Map<Integer, List<Sobject>>();

    private Schema.SobjectType sobjectType;
    private Schema.DescribeSobjectResult sobjectDescribe;
    private String displayFieldApiName, query;
    private Map<Soql.QueryField, FieldCategory> includedQueryFieldsAndCategory;
    private List<Soql.AggregateField> aggregatedFields;
    private Set<Soql.QueryField> excludedQueryFields;
    private Scope scope;
    private List<String> whereFilters, orderByFieldApiNames;
    private Integer limitCount;
    private Integer offset;
    private Boolean hasChanged, forReference, forUpdate, forView, cacheResults, includeLabels, includeFormattedValues;

    public Soql(Schema.SobjectType sobjectType) {
        this.sobjectType         = sobjectType;
        this.displayFieldApiName = this.getDisplayFieldApiName(this.sobjectType);

        this.sobjectDescribe                = this.sobjectType.getDescribe();
        this.includedQueryFieldsAndCategory = new Map<Soql.QueryField, FieldCategory>();
        this.aggregatedFields               = new List<Soql.AggregateField>();
        this.excludedQueryFields            = new Set<Soql.QueryField>();
        this.whereFilters                   = new List<String>();
        this.orderByFieldApiNames           = new List<String>();
        this.forReference                   = false;
        this.forUpdate                      = false;
        this.forView                        = false;
        this.cacheResults                   = false;
        this.includeLabels                  = false;
        this.includeFormattedValues         = false;
        this.hasChanged                     = false;
    }

    public Soql addField(Schema.SobjectField field) {
        return this.addField(field, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(Schema.SobjectField field, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Schema.SobjectField>{field}, fieldCategory);
    }

    public Soql addField(Soql.QueryField queryField) {
        return this.addField(queryField, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addField(Soql.QueryField queryField, Soql.FieldCategory fieldCategory) {
        return this.addFields(new List<Soql.QueryField>{queryField}, fieldCategory);
    }

    public Soql addFields(Schema.FieldSet fieldSet) {
        return this.addFields(FieldSet, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(Schema.FieldSet fieldSet, FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new Soql.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.addFields(queryFields, fieldCategory);
    }

    public Soql addFields(List<Schema.SobjectField> fields) {
        return this.addFields(fields, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(List<Schema.SobjectField> fields, Soql.FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : fields) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.addFields(queryFields, fieldCategory);
    }

    public Soql addFields(List<Soql.QueryField> queryFields) {
        return this.addFields(queryFields, DEFAULT_FIELD_CATEGORY);
    }

    public Soql addFields(List<Soql.QueryField> queryFields, Soql.FieldCategory fieldCategory) {
        for(Soql.QueryField queryField : queryFields) {
            this.includedQueryFieldsAndCategory.put(queryField, fieldCategory);
        }
        return this;
    }

    public Soql addFields(Soql.FieldCategory fieldCategory) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : this.sobjectDescribe.fields.getMap().values()) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.addFields(queryFields, DEFAULT_FIELD_CATEGORY);
    }

    public Soql aggregateField(Schema.SobjectField field, Soql.Aggregate aggregateFunction) {
        this.aggregatedFields.add(new Soql.AggregateField(field, aggregateFunction));
        return this.setHasChanged();
    }

    public Soql removeField(Schema.SobjectField field) {
        return this.removeFields(new List<Schema.SobjectField>{field});
    }

    public Soql removeField(Soql.QueryField queryField) {
        return this.removeFields(new List<Soql.QueryField>{queryField});
    }

    public Soql removeFields(Schema.FieldSet fieldSet) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            queryFields.add(new Soql.QueryField(this.sobjectType, fieldSetMember.getFieldPath()));
        }
        return this.removeFields(queryFields);
    }

    public Soql removeFields(List<Schema.SobjectField> fields) {
        List<Soql.QueryField> queryFields = new List<Soql.QueryField>();
        for(Schema.SobjectField field : fields) {
            queryFields.add(new Soql.QueryField(field));
        }
        return this.removeFields(queryFields);
    }

    public Soql removeFields(List<Soql.QueryField> queryFields) {
        this.excludedQueryFields.addAll(queryFields);
        return this.setHasChanged();
    }

    public Soql usingScope(Scope scope) {
        this.scope = scope;
        return this.setHasChanged();
    }

    public Soql filterWhere(Schema.SobjectField field, String operator, Object value) {
        Soql.QueryField queryField = new QueryField(new List<Schema.SobjectField>{field});
        return this.filterWhere(queryField, operator, value);
    }

    public Soql filterWhere(Soql.QueryField queryField, String operator, Object value) {
        return this.filterWhere(new QueryFilter(queryField, operator, value));
    }

    public Soql filterWhere(QueryFilter filter) {
        return this.filterWhere(new List<QueryFilter>{filter});
    }

    public Soql filterWhere(List<QueryFilter> filters) {
        for(QueryFilter filter : filters) this.whereFilters.add(filter.toString());
        return this.setHasChanged();
    }

    public Soql orderBy(Schema.SobjectField field) {
        return this.orderBy(field, DEFAULT_SORT_ORDER, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder) {
        return this.orderBy(field, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Schema.SobjectField field, SortOrder sortOrder, Boolean sortNullsFirst) {
        return this.orderBy(new QueryField(field), sortOrder, sortNullsFirst);
    }

    public Soql orderBy(Soql.QueryField queryField) {
        return this.orderBy(queryField, DEFAULT_SORT_ORDER, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Soql.QueryField queryField, SortOrder sortOrder) {
        return this.orderBy(queryField, sortOrder, DEFAULT_NULLS_SORT_ORDER_FIRST);
    }

    public Soql orderBy(Soql.QueryField queryField, SortOrder sortOrder, Boolean sortNullsFirst) {
        String sortOrderString = sortOrder == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC';
        String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
        this.orderByFieldApiNames.add(queryField + ' ' + sortOrderString + ' NULLS ' + nullsSortOrder);
        return this.setHasChanged();
    }

    public Soql limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this.setHasChanged();
    }

    public Soql offset(Integer offset) {
        this.offset = offset;
        return this.setHasChanged();
    }

    public Soql forReference() {
        this.forReference = true;
        return this.setHasChanged();
    }

    public Soql forUpdate() {
        this.forUpdate = true;
        return this.setHasChanged();
    }

    public Soql forView() {
        this.forView = true;
        return this.setHasChanged();
    }

    public Soql includeLabels() {
        this.includeLabels = true;
        return this.setHasChanged();
    }

    public Soql includeFormattedValues() {
        this.includeFormattedValues = true;
        return this.setHasChanged();
    }

    public Soql cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public virtual String getQuery() {
        if(this.query != null && !this.hasChanged) return this.query;

        String queryFieldString = this.getQueryFieldString();
        String aggregateQueryFieldString = this.getAggregateQueryFieldString();
        String fieldDelimiter = !String.isEmpty(queryFieldString) && !String.isEmpty(aggregateQueryFieldString) ? ', ' : '';

        this.query = 'SELECT ' + queryFieldString + fieldDelimiter + aggregateQueryFieldString
            + ' FROM ' + this.sobjectType
            + this.getUsingScopeString()
            + this.getWhereClauseString()
            + this.getGroupByString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getOffetString()
            + this.getForReferenceString()
            + this.getForUpdateString()
            + this.getForViewString();

        // Change hasChanged to false so that subsequent calls to getQuery() use the cached query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.query);
        return this.query;
    }

    public String getSearchQuery() {
        String sobjectTypeOptions = this.getQueryFieldString()
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString();

        // If we have any sobject-specific options, then wrap the options in parentheses
        sobjectTypeOptions = String.isEmpty(sobjectTypeOptions) ? '' : '(' + sobjectTypeOptions + ')';

        String searchQuery = this.getSobjectType() + sobjectTypeOptions;
        System.debug(LoggingLevel.FINEST, searchQuery);
        return searchQuery;
    }

    public Sobject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<Sobject> getQueryResults() {
        if(this.cacheResults) return this.getCachedQuery();
        else return Database.query(this.getQuery());
    }

    public Schema.SobjectType getSobjectType() {
        return this.sobjectType;
    }

    public Integer compareTo(Object compareTo) {
        String currentSobjectApiName   = String.valueOf(this.getSobjectType());
        Soql soqlToCompareTo           = (Soql)compareTo;
        String compareToSobjectApiName = String.valueOf(soqlToCompareTo.getSobjectType());

        if(currentSobjectApiName == compareToSobjectApiName) return 0;
        else if(currentSobjectApiName > compareToSobjectApiName) return 1;
        else return -1;
    }

    private Soql setHasChanged() {
        this.hasChanged = true;
        return this;
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

    private String getFieldToLabel(String fieldApiName) {
        return 'toLabel(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Label';
    }

    private String getFieldFormattedValue(String fieldApiName) {
        return 'format(' + fieldApiName + ') ' + fieldApiName.replace('.', '_') + '__Formatted';
    }

    private List<String> getFieldsToQuery(QueryField queryField, FieldCategory fieldCat) {
        List<String> fieldsToReturn = new List<String>();
        //Schema.SobjectField field = this.sobjectDescribe.fields.getMap().get(fieldApiName);

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == FieldCategory.ACCESSIBLE && !queryField.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.UPDATEABLE && !queryField.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.STANDARD && queryField.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == FieldCategory.CUSTOM && !queryField.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(queryField.toString());

        // If the field has picklist options, then it can be translated
        if(this.includeLabels && !queryField.getDescribe().getPickListValues().isEmpty()) {
            fieldsToReturn.add(this.getFieldToLabel(queryField.getDescribe().getName()));
        }

        // If the field is a number, date, time, or currency, it can be formatted
        List<Schema.DisplayType> supportedTypesForFormat = new List<Schema.DisplayType>{
            Schema.DisplayType.CURRENCY, Schema.DisplayType.DATE, Schema.DisplayType.DATETIME, Schema.DisplayType.DOUBLE,
            Schema.DisplayType.INTEGER, Schema.DisplayType.PERCENT, Schema.DisplayType.TIME
        };
        if(this.includeFormattedValues && supportedTypesForFormat.contains(queryField.getDescribe().getType())) {
            fieldsToReturn.add(this.getFieldFormattedValue(queryField.getDescribe().getName()));
        }

        // If the field is a lookup, then we need to get the name field from the parent object
        if(queryField.getDescribe().getType().name() == 'Reference') {
            String parentNameField = this.getParentObjectNameField(queryField.getDescribe());
            if(parentNameField != null) {
                fieldsToReturn.add(parentNameField);
                // Record type names can be translated, so include the translation
                if(this.includeLabels && queryField.toString() == 'RecordTypeId') fieldsToReturn.add(this.getFieldToLabel(parentNameField));
            }
        }

        return fieldsToReturn;
    }

    private String getQueryFieldString() {
        Set<String> distinctFieldApiNamesToQuery = new Set<String>();
        for(QueryField queryField : this.includedQueryFieldsAndCategory.keySet()) {
            FieldCategory fieldCategory = this.includedQueryFieldsAndCategory.get(queryField);

            List<String> fieldsToQuery = this.getFieldsToQuery(queryField, fieldCategory);
            if(!fieldsToQuery.isEmpty()) distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
        }

        // If the query is NOT an aggregate query, then add the Id & display name fields automatically
        if(this.aggregatedFields.isEmpty()) {
            distinctFieldApiNamesToQuery.add('Id');
            distinctFieldApiNamesToQuery.add(this.displayFieldApiName);
        }

        // Remove an excluded field paths
        for(Soql.QueryField excludedQueryField : this.excludedQueryFields) {
            distinctFieldApiNamesToQuery.remove(excludedQueryField.toString());
        }

        List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
        if(this.aggregatedFields.isEmpty()) fieldApiNamesToQuery.sort();
        return String.join(fieldApiNamesToQuery, ', ');
    }

    private String getAggregateQueryFieldString() {
        if(this.aggregatedFields.isEmpty()) return '';

        List<String> aggregatedFieldStrings = new List<String>();
        for(Soql.AggregateField aggregatedField : this.aggregatedFields) {
            aggregatedFieldStrings.add(aggregatedField.toString());
        }
        return String.join(aggregatedFieldStrings, ', ');
    }

    private String getUsingScopeString() {
        return this.scope == null ? '' : ' USING SCOPE ' + this.scope.name();
    }

    private String getWhereClauseString() {
        return this.whereFilters.isEmpty() ? '' : ' WHERE ' + String.join(this.whereFilters, ' AND ');
    }

    private String getGroupByString() {
        // TODO might need a better way to track if the query is a standard query or aggregate
        String queryFieldString = this.getQueryFieldString();
        return String.isEmpty(queryFieldString) || this.aggregatedFields.isEmpty() ? '' : ' GROUP BY ' + queryFieldString;
    }

    private String getOrderByString() {
        return this.orderByFieldApiNames.isEmpty() ? '' : ' ORDER BY ' + String.join(this.orderByFieldApiNames, ', ');
    }

    private String getLimitCountString() {
        return this.limitCount == null ? '' : ' LIMIT ' + this.limitCount;
    }

    private String getOffetString() {
        return this.offset == null ? '' : ' OFFSET ' + this.offset;
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

    private List<Sobject> getCachedQuery() {
        String query     = this.getQuery();
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedQueryResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedQueryResultsByHashCode.put(hashCode, Database.query(query));

        // Always return a deep clone so the original cached version is never modified
        return cachedQueryResultsByHashCode.get(hashCode).deepClone(true, true, true);
    }

    private class AggregateField {
        private String aggregateField;
        public AggregateField(Schema.SobjectField field, Soql.Aggregate aggregateFunction) {
            String fieldApiName = field.getDescribe().getName();
            String fieldAlias   = fieldApiName + '__' + aggregateFunction.name();

            // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MyField__c__MIN
            this.aggregateField = aggregateFunction.name() + '(' + fieldApiName + ') ' + fieldAlias;
        }
        public override String toString() {
            return this.aggregateField;
        }
    }

    public class SoqlException extends Exception {}

    public class DateLiteral {

        private String dateLiteral;

        public DateLiteral(String dateLiteral) {
            this.dateLiteral = String.escapeSingleQuotes(dateLiteral);
        }

        public override String toString() {
            return this.dateLiteral;
        }

    }

    public class IsoCurrency {

        private final String isoCurrency;

        public IsoCurrency(String isoCode, Decimal currencyAmount) {
            if(!UserInfo.isMultiCurrencyOrganization()) throw new SoqlException('IsoCurrency is only supported in multi-currency orgs');
            this.isoCurrency = isoCode + currencyAmount;
        }

        public override String toString() {
            return this.isoCurrency;
        }

    }

    public virtual class QueryArgument {

        private String value;

        public QueryArgument(Object valueToFormat) {
            this.value = this.formatObjectForQueryString(valueToFormat);
        }

        public override String toString() {
            return this.value;
        }

        private String formatObjectForQueryString(Object valueToFormat) {
            if(valueToFormat == null) return null;
            else if(valueToFormat instanceOf List<Object>) return this.convertListToQueryString((List<Object>)valueToFormat);
            else if(valueToFormat instanceOf Set<Object>) return this.convertSetToQueryString(valueToFormat);
            else if(valueToFormat instanceOf Map<Object, Object>) return this.convertMapToQueryString(valueToFormat);
            else if(valueToFormat instanceOf Date) return String.valueOf((Date)valueToFormat).left(10);
            else if(valueToFormat instanceOf Datetime) {
                Datetime datetimeValue = (Datetime)valueToFormat;
                return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
            }
            else if(valueToFormat instanceOf Sobject) {
                Sobject record = (Sobject)valueToFormat;
                return this.wrapInSingleQuotes(((Sobject)valueToFormat).Id);
            }
            else if(valueToFormat instanceOf String) {
                // Escape single quotes to prevent SOQL/SOSL injection
                String stringArgument = String.escapeSingleQuotes((String)valueToFormat);
                return this.wrapInSingleQuotes(stringArgument);
            }
            else return String.valueOf(valueToFormat);
        }

        private String wrapInSingleQuotes(String input) {
            input = input.trim();
            if(input.left(1) != '\'') input = '\'' + input;
            if(input.right(1) != '\'') input = input + '\'';
            return input;
        }

        private String convertListToQueryString(List<Object> valueList) {
            List<String> parsedValueList = new List<String>();
            for(Object value : valueList) {
                parsedValueList.add(this.formatObjectForQueryString(value));
            }
            return '(' + String.join(parsedValueList, ', ') + ')';
        }

        private String convertSetToQueryString(Object valueSet) {
            String unformattedString = String.valueOf(valueSet).replace('{', '').replace('}', '');
            List<String> parsedValueList = new List<String>();
            for(String collectionItem : unformattedString.split(',')) {
                parsedValueList.add(this.formatObjectForQueryString(collectionItem));
            }
            return '(' + String.join(parsedValueList, ', ') + ')';
        }

        private String convertMapToQueryString(Object valueMap) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(valueMap));
            return this.convertSetToQueryString(m.keySet());
        }

    }

    public class QueryField {

        private final String queryField;
        private final Schema.DescribeFieldResult fieldDescribe;

        public QueryField(Schema.SobjectType sobjectType, String queryField) {
            this.fieldDescribe = this.getLastFieldDescribe(sobjectType, queryField);
            this.queryField    = queryField;
        }

        public QueryField(Schema.SobjectField field) {
            this(new List<Schema.SobjectField>{field});
        }

        public QueryField(List<Schema.SobjectField> fields) {
            this.fieldDescribe = this.getLastFieldDescribe(fields);
            this.queryField    = this.getQueryField(fields);
        }

        public override String toString() {
            return this.queryField;
        }

        public Schema.DescribeFieldResult getDescribe() {
            return this.fieldDescribe;
        }

        private Schema.DescribeFieldResult getLastFieldDescribe(Schema.SobjectType sobjectType, String queryField) {
            Schema.SobjectType currentSobjectType = sobjectType;
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>();
            List<String> queryFieldPieces = queryField.split('\\.');
            Integer lastFieldIndex = queryFieldPieces.size() - 1;
            for(Integer i = 0; i < queryFieldPieces.size(); i++) {
                String queryFieldPiece = queryFieldPieces[i];

                String fieldApiName;
                if(i == lastFieldIndex) fieldApiName = queryFieldPiece;
                else if(queryFieldPiece.endsWith('__r')) fieldApiName = queryFieldPiece.replace('__r', '__c');
                else fieldApiName = queryFieldPiece + 'Id';

                Schema.SobjectField field = currentSobjectType.getDescribe().fields.getMap().get(fieldApiName);

                if(i < lastFieldIndex) currentSobjectType = field.getDescribe().getReferenceTo()[0]; // TODO add support for polymorphic fields

                fields.add(field);
            }
            return this.getLastFieldDescribe(fields);
        }

        private Schema.DescribeFieldResult getLastFieldDescribe(List<Schema.SobjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            return fields[lastFieldIndex].getDescribe();
        }

        private String getQueryField(List<Schema.SobjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            List<String> queryFieldPieces = new List<String>();
            for(Integer i = 0; i < fields.size(); i++) {
                SobjectField field = fields[i];
                // If any field in the chain is not accessible, then the user cant access the data, so return an empty list
                if(!field.getDescribe().isAccessible()) return null;
                else if(i == lastFieldIndex) queryFieldPieces.add(field.getDescribe().getName());
                else queryFieldPieces.add(field.getDescribe().getRelationshipName());
            }
            return String.join(queryFieldPieces, '.');
        }

    }

    public class QueryFilter implements Comparable {

        private String value;

        public QueryFilter(QueryField queryField, String operator, Object value) {
            this.value = queryField + ' ' + operator + ' ' + new QueryArgument(value);
        }

        public Integer compareTo(Object compareTo) {
            QueryFilter compareToQueryFilter = (QueryFilter)compareTo;
            if(this.toString() == compareToQueryFilter.toString()) return 0;
            else if(this.toString() > compareToQueryFilter.toString()) return 1;
            else return -1;
        }

        public override String toString() {
            return this.value;
        }

    }

    public class Results {

        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer currentPage {get;set;}
        @AuraEnabled public Integer totalPages {get;set;}
        @AuraEnabled public Integer matchCount {get;set;}
        @AuraEnabled public Integer totalMatchCount {get;set;}
        @AuraEnabled public List<Sobject> matches {get;set;}

        public Results(){
            matches = new List<Sobject>();
        }

    }

}