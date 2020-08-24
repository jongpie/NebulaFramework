/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public abstract class Soql implements Comparable {

    public enum Aggregate { AVG, COUNT, COUNT_DISTINCT, MAX, MIN, SUM }
    public enum GroupingDimension { CUBE, ROLLUP }
    public enum FieldCategory { ACCESSIBLE, UPDATEABLE, STANDARD, CUSTOM, IGNORE_FLS }
    public enum Operator {
        EQUALS, NOT_EQUAL_TO,
        GREATER_THAN, GREATER_THAN_OR_EQUAL_TO,
        LESS_THAN, LESS_THAN_OR_EQUAL_TO,
        IS_IN, IS_NOT_IN,
        INCLUDES, EXCLUDES,
        IS_LIKE, IS_NOT_LIKE
    }
    public enum Scope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }
    public enum SortOrder { ASCENDING, DESCENDING }
    public enum DateFunction {
        HOUR_IN_DAY,
        DAY_ONLY, DAY_IN_MONTH, DAY_IN_WEEK, DAY_IN_YEAR,
        WEEK_IN_MONTH, WEEK_IN_YEAR,
        FISCAL_MONTH, FISCAL_QUARTER, FISCAL_YEAR,
        CALENDAR_MONTH, CALENDAR_QUARTER, CALENDAR_YEAR
    }
    public enum FixedDateLiteral {
        YESTERDAY, TODAY, TOMORROW,
        LAST_WEEK, THIS_WEEK, NEXT_WEEK,
        LAST_MONTH, THIS_MONTH, NEXT_MONTH,
        LAST_90_DAYS, NEXT_90_DAYS,
        LAST_QUARTER, THIS_QUARTER, NEXT_QUARTER,
        LAST_FISCAL_QUARTER, THIS_FISCAL_QUARTER, NEXT_FISCAL_QUARTER,
        LAST_YEAR, THIS_YEAR, NEXT_YEAR,
        LAST_FISCAL_YEAR, THIS_FISCAL_YEAR, NEXT_FISCAL_YEAR
    }
    public enum RelativeDateLiteral {
        N_DAYS_AGO, LAST_N_DAYS, NEXT_N_DAYS,
        LAST_N_WEEKS, NEXT_N_WEEKS,
        LAST_N_MONTHS, NEXT_N_MONTHS,
        LAST_N_QUARTERS, NEXT_N_QUARTERS,
        LAST_N_FISCAL_QUARTERS, NEXT_N_FISCAL_QUARTERS,
        LAST_N_YEARS, NEXT_N_YEARS,
        LAST_N_FISCAL_YEARS, NEXT_N_FISCAL_YEARS
    }

    private static final Soql.FieldCategory DEFAULT_FIELD_CATEGORY = Soql.FieldCategory.ACCESSIBLE;
    private static final Soql.SortOrder DEFAULT_SORT_ORDER         = Soql.SortOrder.ASCENDING;
    private static final Boolean DEFAULT_NULLS_SORT_ORDER_FIRST    = true;

    private static Map<Integer, List<SObject>> cachedResultsByHashCode = new Map<Integer, List<SObject>>();

    public static String getOperatorValue(Soql.Operator operator) {
        switch on operator {
            when EQUALS                   { return '='; }
            when NOT_EQUAL_TO             { return '!='; }
            when GREATER_THAN             { return '>'; }
            when GREATER_THAN_OR_EQUAL_TO { return '>='; }
            when LESS_THAN                { return '<'; }
            when LESS_THAN_OR_EQUAL_TO    { return '<='; }
            when IS_IN                    { return 'IN'; }
            when IS_NOT_IN                { return 'NOT IN'; }
            when INCLUDES                 { return 'INCLUDES'; }
            when EXCLUDES                 { return 'EXCLUDES'; }
            when IS_LIKE                  { return 'LIKE'; }
            when IS_NOT_LIKE              { return 'NOT LIKE'; }
            when else                     { return null; }
        }
    }

    protected String query;
    protected Schema.SObjectType sobjectType;
    protected Schema.DescribeSObjectResult sobjectDescribe;
    protected Map<Soql.QueryField, Soql.FieldCategory> includedQueryFieldsAndCategory;
    protected Set<Soql.QueryField> excludedQueryFields;
    protected Scope scope;
    protected List<String> whereFilters, orderByFieldApiNames;
    protected Integer limitCount;
    protected Integer offset;
    protected Boolean hasChanged, sortQueryFields;

    protected Boolean cacheResults;

    protected Soql(Schema.SObjectType sobjectType, Boolean sortQueryFields) {
        this.sobjectType     = sobjectType;
        this.sortQueryFields = sortQueryFields;

        this.sobjectDescribe                = this.sobjectType.getDescribe();
        this.includedQueryFieldsAndCategory = new Map<Soql.QueryField, Soql.FieldCategory>();
        this.excludedQueryFields            = new Set<Soql.QueryField>();
        this.whereFilters                   = new List<String>();
        this.orderByFieldApiNames           = new List<String>();
        this.cacheResults                   = false;
        this.hasChanged                     = false;
    }

    public Schema.SObjectType getSObjectType() {
        return this.sobjectType;
    }

    public abstract String getQuery();

    public Integer compareTo(Object compareTo) {
        String currentSObjectApiName   = String.valueOf(this.getSObjectType());
        Soql soqlToCompareTo           = (Soql)compareTo;
        String compareToSObjectApiName = String.valueOf(soqlToCompareTo.getSObjectType());

        if(currentSObjectApiName == compareToSObjectApiName) return 0;
        else if(currentSObjectApiName > compareToSObjectApiName) return 1;
        else return -1;
    }

    protected void doCacheResults() {
        this.cacheResults = true;
    }

    protected void doAddFields(List<Soql.QueryField> queryFields, Soql.FieldCategory fieldCategory) {
        if(fieldCategory == null) fieldCategory = DEFAULT_FIELD_CATEGORY;
        for(Soql.QueryField queryField : queryFields) {
            this.includedQueryFieldsAndCategory.put(queryField, fieldCategory);
        }
        this.doSetHasChanged();
    }

    protected void doRemoveFields(List<Soql.QueryField> queryFields) {
        this.excludedQueryFields.addAll(queryFields);
    }

    protected void doUsingScope(Scope scope) {
        this.scope = scope;
    }

    protected void doFilterWhere(List<Soql.QueryFilter> filters) {
        if(filters == null || filters.isEmpty()) return;

        for(Soql.QueryFilter filter : filters) this.whereFilters.add(filter.toString());
        this.doSetHasChanged();
    }

    protected void doOrFilterWhere(List<Soql.QueryFilter> filters) {
        if(filters == null || filters.isEmpty()) return;

        filters.sort();

        List<String> orFilterPieces = new List<String>();
        for(Soql.QueryFilter filter : filters) orFilterPieces.add(filter.toString());
        this.whereFilters.add('(' + String.join(orFilterPieces, ' OR ') + ')');
        this.doSetHasChanged();
    }

    protected void doOrderBy(Soql.QueryField queryField, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        this.doOrderBy(queryField.toString(), sortOrder, sortNullsFirst);
    }

    protected void doOrderBy(String fieldPath, Soql.SortOrder sortOrder, Boolean sortNullsFirst) {
        if(sortOrder == null) sortOrder = DEFAULT_SORT_ORDER;
        if(sortNullsFirst == null) sortNullsFirst = DEFAULT_NULLS_SORT_ORDER_FIRST;

        String sortOrderString = sortOrder == Soql.SortOrder.ASCENDING ? 'ASC' : 'DESC';
        String nullsSortOrder = sortNullsFirst ? 'FIRST' : 'LAST';
        this.orderByFieldApiNames.add(fieldPath + ' ' + sortOrderString + ' NULLS ' + nullsSortOrder);
    }

    protected void doLimitTo(Integer numberOfRecords) {
        this.limitCount = numberOfRecords;
    }

    protected void doOffsetBy(Integer offset) {
        this.offset = offset;
    }

    protected SObject doGetFirstResult() {
        List<SObject> results = this.doGetResults();
        return results == null || results.isEmpty() ? null : results[0];
    }

    protected List<SObject> doGetResults() {
        if(this.cacheResults) return this.getCachedResults();
        else return Database.query(this.getQuery());
    }

    protected List<String> doGetFieldsToQuery(Soql.QueryField queryField, Soql.FieldCategory fieldCat) {
        List<String> fieldsToReturn = new List<String>();

        if(fieldCat == null) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.ACCESSIBLE && !queryField.getDescribe().isAccessible()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.UPDATEABLE && !queryField.getDescribe().isUpdateable()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.STANDARD && queryField.getDescribe().isCustom()) return fieldsToReturn;
        else if(fieldCat == Soql.FieldCategory.CUSTOM && !queryField.getDescribe().isCustom()) return fieldsToReturn;

        fieldsToReturn.add(queryField.toString());

        return fieldsToReturn;
    }

    protected String doGetQueryFieldString() {
        Set<String> distinctFieldApiNamesToQuery = new Set<String>();
        for(Soql.QueryField queryField : this.includedQueryFieldsAndCategory.keySet()) {
            Soql.FieldCategory fieldCategory = this.includedQueryFieldsAndCategory.get(queryField);

            List<String> fieldsToQuery = this.doGetFieldsToQuery(queryField, fieldCategory);
            if(!fieldsToQuery.isEmpty()) distinctFieldApiNamesToQuery.addAll(fieldsToQuery);
        }


        // Remove an excluded field paths
        for(Soql.QueryField excludedQueryField : this.excludedQueryFields) {
            distinctFieldApiNamesToQuery.remove(excludedQueryField.toString());
        }

        List<String> fieldApiNamesToQuery = new List<String>(distinctFieldApiNamesToQuery);
        if(this.sortQueryFields) fieldApiNamesToQuery.sort();
        return String.join(fieldApiNamesToQuery, ', ');
    }

    protected String doGetUsingScopeString() {
        return this.scope == null ? '' : ' USING SCOPE ' + this.scope.name();
    }

    protected String doGetWhereClauseString() {
        this.whereFilters.sort();
        return this.whereFilters.isEmpty() ? '' : ' WHERE ' + String.join(this.whereFilters, ' AND ');
    }

    protected String doGetOrderByString() {
        return this.orderByFieldApiNames.isEmpty() ? '' : ' ORDER BY ' + String.join(this.orderByFieldApiNames, ', ');
    }

    protected String doGetLimitCountString() {
        return this.limitCount == null ? '' : ' LIMIT ' + this.limitCount;
    }

    protected String doGetOffetString() {
        return this.offset == null ? '' : ' OFFSET ' + this.offset;
    }

    private void doSetHasChanged() {
        this.hasChanged = true;
    }

    private List<SObject> getCachedResults() {
        String query     = this.getQuery();
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedResultsByHashCode.put(hashCode, Database.query(query));

        // Always return a deep clone so the original cached version is never modified
        return cachedResultsByHashCode.get(hashCode).deepClone(true, true, true);
    }

    public class DateLiteral {

        private String dateLiteral;

        public DateLiteral(Soql.FixedDateLiteral fixedDateLiteral) {
            this.dateLiteral = fixedDateLiteral.name();
        }

        public DateLiteral(Soql.RelativeDateLiteral relativeDateLiteral, Integer n) {
            this.dateLiteral = relativeDateLiteral.name() + ':' + n;
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

    public class QueryField {

        private final String queryFieldPath;
        private final Schema.DescribeFieldResult fieldDescribe;

        public QueryField(Schema.SObjectType sobjectType, String queryFieldPath) {
            this.fieldDescribe  = this.getLastFieldDescribe(sobjectType, queryFieldPath);
            this.queryFieldPath = queryFieldPath;
        }

        public QueryField(Schema.SObjectField field) {
            this(new List<Schema.SObjectField>{field});
        }

        public QueryField(List<Schema.SObjectField> fieldChain) {
            this.fieldDescribe  = this.getLastFieldDescribe(fieldChain);
            this.queryFieldPath = this.getQueryField(fieldChain);
        }

        public QueryField(Soql.DateFunction dateFunction, Schema.SObjectField field) {
            this(dateFunction, field, false);
        }

        public QueryField(Soql.DateFunction dateFunction, Schema.SObjectField field, Boolean convertTimeZone) {
            this(dateFunction, new List<Schema.SObjectField>{field}, convertTimeZone);
        }

        public QueryField(Soql.DateFunction dateFunction, List<Schema.SObjectField> fieldChain) {
            this(dateFunction, fieldChain, false);
        }

        public QueryField(Soql.DateFunction dateFunction, List<Schema.SObjectField> fieldChain, Boolean convertTimeZone) {
            this.fieldDescribe  = this.getLastFieldDescribe(fieldChain);
            this.queryFieldPath = this.getDateFunctionFieldPath(dateFunction, fieldChain, convertTimeZone);
        }
//https://help.salesforce.com/articleView?id=custom_field_geolocate_overview.htm&type=5
        public QueryField(List<Schema.SObjectField> fieldChain, Decimal latitude, Decimal longitude) {
            this.fieldDescribe  = this.getLastFieldDescribe(fieldChain);
            //this.queryFieldPath = 'DISTANCE(' + this.getQueryField(fieldChain), GEOLOCATION(10,10), :units)
        }

        public override String toString() {
            return this.queryFieldPath;
        }

        public Schema.DescribeFieldResult getDescribe() {
            return this.fieldDescribe;
        }

        public String getFieldPath() {
            return this.queryFieldPath;
        }

        private String getDateFunctionFieldPath(Soql.DateFunction dateFunction, List<Schema.SObjectField> fieldChain, Boolean convertTimeZone) {
            String fieldPath = !convertTimeZone ? this.getQueryField(fieldChain) : 'convertTimeZone(' + this.getQueryField(fieldChain) + ')';

            return dateFunction.name() + '(' + fieldPath + ')';
        }

        private Schema.DescribeFieldResult getLastFieldDescribe(Schema.SObjectType sobjectType, String queryField) {
            Schema.SObjectType currentSObjectType = sobjectType;

            List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
            List<String> queryFieldPieces = queryField.split('\\.');
            Integer lastFieldIndex = queryFieldPieces.size() <= 1 ? 0 : queryFieldPieces.size() - 1;

            for(Integer i = 0; i < queryFieldPieces.size(); i++) {
                String queryFieldPiece = queryFieldPieces[i];

                String fieldApiName;
                if(i == lastFieldIndex) fieldApiName = queryFieldPiece;
                else if(queryFieldPiece.endsWith('__r')) fieldApiName = queryFieldPiece.replace('__r', '__c');
                else fieldApiName = queryFieldPiece + 'Id';

                Schema.SObjectField field = currentSObjectType.getDescribe().fields.getMap().get(fieldApiName);

                if(i < lastFieldIndex) currentSObjectType = field.getDescribe().getReferenceTo()[0]; // TODO add support for polymorphic fields

                fields.add(field);
            }
            return this.getLastFieldDescribe(fields);
        }

        private Schema.DescribeFieldResult getLastFieldDescribe(List<Schema.SObjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            return fields[lastFieldIndex].getDescribe();
        }

        private String getQueryField(List<Schema.SObjectField> fields) {
            Integer lastFieldIndex = fields.size() - 1;
            List<String> queryFieldPieces = new List<String>();
            for(Integer i = 0; i < fields.size(); i++) {
                SObjectField field = fields[i];
                // If any field in the chain is not accessible, then the user cant access the data, so return an empty list
                if(!field.getDescribe().isAccessible()) return null;
                else if(i == lastFieldIndex) queryFieldPieces.add(field.getDescribe().getName());
                else queryFieldPieces.add(field.getDescribe().getRelationshipName());
            }
            return String.join(queryFieldPieces, '.');
        }

    }

    public class QueryFilter implements Comparable {

        private Soql.QueryField queryField;
        private Soql.Operator operator;
        private Object value;
        private String formattedValue;
        private String filterString;

        public QueryFilter(Schema.SObjectField field, Soql.Operator operator, Object value) {
            this(new QueryField(field), operator, value);
        }

        public QueryFilter(QueryField queryField, Soql.Operator operator, Object value) {
            this.queryField     = queryField;
            this.operator       = operator;
            this.value          = value;
            this.formattedValue = new QueryArgument(value).toString();

            this.filterString = queryField + ' ' + Soql.getOperatorValue(operator) + ' ' + formattedValue;
        }

        public QueryFilter(Schema.SObjectType childSObjectType, Boolean inOrNotIn, Schema.SObjectField lookupFieldOnChildSObject) {
            this.operator     = inOrNotIn ? Soql.Operator.IS_IN : Soql.Operator.IS_NOT_IN;
            this.filterString = 'Id ' + Soql.getOperatorValue(this.operator) + ' (SELECT ' + lookupFieldOnChildSObject + ' FROM ' + childSObjectType + ')';
        }

        public QueryFilter(Query childQuery, Boolean inOrNotIn, Schema.SObjectField lookupFieldOnChildSObject) {
            this.operator     = inOrNotIn ? Soql.Operator.IS_IN : Soql.Operator.IS_NOT_IN;
            this.filterString = 'Id ' + Soql.getOperatorValue(this.operator) + ' ' + childQuery.getSubquery(lookupFieldOnChildSObject);
        }

        public Integer compareTo(Object compareTo) {
            QueryFilter compareToQueryFilter = (QueryFilter)compareTo;

            if(this.toString() == compareToQueryFilter.toString()) return 0;
            else if(this.toString() > compareToQueryFilter.toString()) return 1;
            else return -1;
        }

        public Soql.QueryField getQueryField() {
            return this.queryField;
        }

        public Soql.Operator getOperator() {
            return this.operator;
        }

        public Object getValue() {
            return this.value;
        }

        public Object getFormattedValue() {
            return this.formattedValue;
        }

        public override String toString() {
            return this.filterString;
        }

    }

    public class SoqlException extends Exception {}

    private class QueryArgument {

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
            else if(valueToFormat instanceOf SObject) {
                SObject record = (SObject)valueToFormat;
                return this.wrapInSingleQuotes(((SObject)valueToFormat).Id);
            }
            else if(valueToFormat instanceOf String) {
                // Escape single quotes to prevent SOQL/SOSL injection
                String unformattedString = (String)valueToFormat;
                String stringArgument = String.escapeSingleQuotes(unformattedString.trim());
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
            Map<String, Object> untypedMap = (Map<String, Object>)Json.deserializeUntyped(Json.serialize(valueMap));
            return this.convertSetToQueryString(untypedMap.keySet());
        }

    }

}