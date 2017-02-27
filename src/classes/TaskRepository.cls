public without sharing class TaskRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Task.FieldSets.MyFieldSet;

    public TaskRepository() {
        super(TaskRepository.DEFAULT_FIELD_SET);
    }

    public Task getRecord(Id taskId) {
        return (Task)this
            .whereIdEquals(taskId)
            .setAsUpdate()
            .getFirstQueryResult();
    }

     public List<Task> getList(List<Id> taskIdList) {
        return (List<Task>)this
            .whereIdIn(taskIdList)
            .setAsUpdate()
            .getQueryResults();
    }

    public List<Task> getListOfOpenForWhoId(Id whoId) {
        return getListOfOpenForWhoId(new List<Id>{whoId});
    }

    public List<Task> getListOfCreatedSinceLastWeek() {
        return (List<Task>)this
            .whereFieldGreaterThanOrEqualTo(Schema.Lead.CreatedDate, 'LAST_WEEK')
            .setAsUpdate()
            .getQueryResults();
    }

    public List<Task> getListOfOpenForWhoId(List<Id> whoIdList) {
        return (List<Task>)this
            .whereWhoIdIn(whoIdList)
            .whereIsClosed(false)
            .orderBy(Schema.Task.WhoId)
            .orderBy(Schema.Task.CreatedDate, SObjectRepository.SortOrder.DESCENDING)
            .getQueryResults();
    }

    public List<Task> searchInAllFields(String searchTerm) {
        return (List<Task>)this
            .whereIsClosed(false)
            .orderBy(Schema.Task.WhoId)
            .limitCount(10)
            .getSearchResults(searchTerm, SObjectRepository.SearchGroup.ALL_FIELDS);
    }

    private TaskRepository whereIsClosed(Boolean bool) {
        return (TaskRepository)this.whereFieldEquals(Schema.Task.IsClosed, bool);
    }

    private TaskRepository whereWhoIdIn(List<Id> whoIdList) {
        return (TaskRepository)this.whereFieldIn(Schema.Task.WhoId, whoIdList);
    }

}