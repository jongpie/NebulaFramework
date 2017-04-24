public class QueryPredicate {
    private final Schema.SObjectField specificField;
    private final QueryOperator specificOperator;
    private final List<Object> specificValues;

    public static QueryPredicate EQUALS(Schema.SObjectField field, Object value) {
        return QueryPredicate.EQUALS(field, new List<Object>{value});
    }

    public static QueryPredicate EQUALS(Schema.SObjectField field, List<Object> values) {
        QueryOperator operator = values.size() > 1 ? QueryOperator.IS_IN : QueryOperator.EQUALS;
        return new QueryPredicate(field, operator, values);
    }

    public static QueryPredicate NOT_EQUALS(Schema.SObjectField field, Object value) {
        return QueryPredicate.NOT_EQUALS(field, new List<Object>{value});
    }

    public static QueryPredicate NOT_EQUALS(Schema.SObjectField field, List<Object> values) {
        QueryOperator operator = values.size() > 1 ? QueryOperator.IS_NOT_IN : QueryOperator.NOT_EQUAL_TO;
        return new QueryPredicate(field, operator, values);
    }

    public static QueryPredicate GREATER_THAN(Schema.SObjectField field, Object value) {
        return new QueryPredicate(field, QueryOperator.GREATER_THAN, new List<Object>{value});
    }

    public static QueryPredicate LESS_THAN_OR_EQUAL(Schema.SObjectField field, Object value) {
        return QueryPredicate.LESS_THAN_OR_EQUAL(field, new List<Object>{value});
    }

    public static QueryPredicate LESS_THAN_OR_EQUAL(Schema.SObjectField field, List<Object> values) {
        QueryOperator operator = values.size() > 1 ? QueryOperator.IS_IN : QueryOperator.LESS_THAN_OR_EQUAL_TO;
        return new QueryPredicate(field, operator, values);
    }

    private QueryPredicate(Schema.SObjectField field, QueryOperator operator, List<Object> values) {
        this.specificField    = field;
        this.specificValues   = values;
        this.specificOperator = operator;
    }

    public Schema.SObjectField Field {
        get { return this.specificField; }
    }

    public QueryOperator Operator {
        get { return this.specificOperator; }
    }

    public List<Object> Values {
        get { return this.specificValues; }
    }
}