public class FileGenerator {
// https://salesforce.stackexchange.com/questions/131096/how-to-upload-files-using-apex-code

    private Id contentDocId;
    private Id linkedEntityId;
    private String filename;
    private String fileTitle;
    private String fileContent;

    public FileGenerator(Id linkedEntityId, String filename, String fileTitle, String fileContent) {
        //this.contentDocId   = contentDocId;
        this.linkedEntityId = linkedEntityId;
        this.filename       = filename;
        this.fileTitle      = fileTitle;
        this.fileContent    = fileContent;
    }

    public ContentVersion generateFile(Boolean insertRecord) {
        ContentVersion contentVersion = new ContentVersion();

        //if(contentDocId != null) contentVersion.ContentDocumentId = contentDocId;

        contentVersion.Title        = this.fileTitle;
        contentVersion.PathOnClient = this.filename;
        contentVersion.VersionData  = Blob.valueOf(this.fileContent);
        contentVersion.Origin       = 'H';

        if(insertRecord) {
            insert contentVersion;
            contentVersion = (ContentVersion)new SObjectQueryBuilder(Schema.ContentVersion.SObjectType)
                .addAllStandardFields()
                .filterBy(new QueryFilter().filterByField(new QueryField(Schema.ContentVersion.Id), QueryOperator.EQUALS, contentVersion.Id))
                .getFirstQueryResult();

            this.createContentDocumentLink(linkedEntityId, contentVersion);
        }

        return contentVersion;
    }

    private void createContentDocumentLink(Id linkedEntityId, ContentVersion contentVersion) {
        if(contentVersion.Id == null) return;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ShareType = 'V';
        insert cdl;
    }

    public static FeedItem generatePostWithRelatedDocument(Id parent, Id contentVersionId) {
        FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = parent, RelatedRecordId = contentVersionId, Type = 'ContentPost');
        insert elm;
        return elm;
    }

}