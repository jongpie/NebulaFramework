# Overview
SObjectRepository.cls is one of the core classes of the Nebula framework. This class is intended to handle
* All DML actions for a given SObject type, like insert, update & delete
* All queries for a given SObject type, with several predefined queries, as well as the ability to dynamically generate queries

To accomplish these goals, it implements 2 interfaces: ISObjectRepository.cls and IDML.cls

>**Nebula Best Practice:** Each SObject that you use in your org should havee 1 class to extend SObjectRepository. For example, if you use the lead object, you will create LeadRepository.cls. If you use the cases object, then create CaseRepository.cls, etc. In some more complex systems, having multiple repositories per SObject can also be used.

Using SObject repositories provides several benefits
1. DML actions can be easily altered for your entire codebase
2. Repositories can be easily replaced by mock classes to improve unit tests
3. Queries can be dynamically generated
4. Query fields can be added & removed declaratively when using field sets. This lets you declaratively resolve 'SObject row was retrieved via SOQL without querying the requested field' errors
5. Automatically include all fields to your queries, removing the need to constantly update queries when new fields are added to your SObject. This feature is like having ```select * from <sobject>``` from traditional SQL. It can be a great time saver for smaller objects, but performance issues may occur with larger objects, so use carefully.
6. Filter conditions can be easily added to all queries within a repo class by adding filters to your constructor. For example, this sample class filters out all converted leads for all queries (both inherited queries from Nebula and any custom query methods that you add)
```
public with sharing class CaseRepository extends SObjectRepository {
    
    public LeadRepository() {
        super(Schema.Lead.SObjectType);
        // Filters in the constructor are applied to all methods in the class
        // This filter means that only leads that have not been converted will be included
        this.Query.filterBy(new QueryFilter(Schema.Lead.IsConverted, QueryOperator.EQUALS, false));
    }

}
```

# Implementation
Nebula provides 3 options for implementing a repository. You can decide which option best fits your use case (or you can even use a combination of the 3 options).

## Constructor - Only SObject Type Provided
The most basic implementation can be done by extending SObjectRepository, using just a few lines of code
```
public with sharing class CaseRepository extends SObjectRepository {
    
    public CaseRepository() {
        // When only an SObject type is provided, all fields for the SObject are included in your queries
        super(Schema.Case.SObjectType);
    }

}
```

Your new class, CaseRepository.cls, automatically inherits all of the methods in ISObjectRepository.cls and IDML.cls. It also leverages IQueryBuilder methods to dynamically generate queries. Using the super constructor shown above, the framework will automatically include all case fields in every query. If you want to specify the desired fields, you can use either a field set or list of SObject fields.

## Constructor - SObject Type & Field Set Provided
```
public with sharing class CaseRepository extends SObjectRepository {

    public CaseRepository(Schema.FieldSet myFieldSet) {
         // When a field set is provided, only the fields in the field set are included in your queries
         super(Schema.Case.SObjectType, myFieldSet));
    }

}
```

## Constructor - SObject Type & List of SObject Fields Provided
```
public with sharing class CaseRepository extends SObjectRepository {

    public CaseRepository(List<Schema.FieldSet> mySObjectFields) {
        // When a list of SObject fields is provided, only the fields in the field set are included in your queries
        super(Schema.Case.SObjectType, mySObjectFields));
    }

}
```

## Custom Setting
The custom setting Nebula Repository Settings (NebulaRepositorySettings__c) can be used to further control the behaviour of the class SObjectRepository.cls. 

>**Nebula Best Practice:** Nebula's custom settings can be accessed programmatically through the class NebulaSettings.cls.

1. Include Common Fields (API Name: IncludeCommonFields__c). If enabled, the following fields are auto-added to your queries if they exist on the SObject. You do not need to add these fields to your field set or list of SObject fields when this option is enabled. This feature can be used with all 3 super constructor's for SObjectRepository.cls
    * Id
    * CaseNumber
    * CreatedById
    * CreatedDate
    * IsClosed
    * LastModifiedById
    * LastModifiedDate
    * Name
    * OwnerId
    * Subject
    * RecordTypeId
    * SystemModStamp

## DML Actions: Insert, Update, Upsert, Delete, Undelete and Hard Delete
All repositories automatically inherit several methods from DML.cls. These methods can be used to save, updated and delete your data ('C', 'U' & 'D' from CRUD). Each method can be overridden to implement your own logic as needed.
* public virtual void insertRecords(SObject record)
* public virtual void insertRecords(List<SObject> records)
* public virtual void updateRecords(SObject record)
* public virtual void updateRecords(List<SObject> records)
* public virtual void upsertRecords(SObject record)
* public virtual void upsertRecords(List<SObject> records)
* public virtual void undeleteRecords(SObject record)
* public virtual void undeleteRecords(List<SObject> records)
* public virtual void deleteRecords(SObject record)
* public virtual void deleteRecords(List<SObject> records)
* public virtual void hardDeleteRecords(SObject record)
* public virtual void hardDeleteRecords(List<SObject> records)


## Querying for Data
All repositories automatically inherit several methods from SObjectRepository.cls. These methods can be used to query your data ('R' from CRUD). Each method can be overridden to implement your own logic for each SObject type.
* public virtual SObject getById(Id recordId)
* public virtual List<SObject> getById(List<Id> recordIds)
* public virtual List<SObject> get(IQueryFilter queryFilter)
* public virtual List<SObject> get(List<IQueryFilter> queryFilters)
* public virtual List<SObject> getByIdAndQueryFilters(Set<Id> idSet, List<IQueryFilter> queryFilters)
* public virtual List<SObject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters)
* public virtual List<SObject> getSearchResults(String searchTerm)
* public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup)
* public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup, List<IQueryFilter> queryFilters)
* public virtual IQueryBuilder getQueryBuilder()

### Query Builder: Query for Your Data
All repostories can leverage QueryBuilder.cls to provide predefined queries and to handle dynamically generated queries