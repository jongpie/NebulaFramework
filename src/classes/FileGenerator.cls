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

    public ContentVersion generateFile(Boolean upsertRecord) {
        ContentVersion contentVersion = new ContentVersion();

        //if(contentDocId != null) contentVersion.ContentDocumentId = contentDocId;

        contentVersion.Title        = this.fileTitle;
        contentVersion.PathOnClient = this.filename;
        contentVersion.VersionData  = Blob.valueOf(this.fileContent);
        contentVersion.Origin       = 'H';

        if(upsertRecord) {
            upsert contentVersion;
            contentVersion = (ContentVersion)new SObjectQueryBuilder(Schema.ContentVersion.SObjectType)
                .addAllStandardFields()
                .filterBy(new QueryFilter().filterByField(new QueryField(Schema.ContentVersion.Id), QueryOperator.EQUALS, contentVersion.Id))
                .getFirstQueryResult();

            this.insertContentDocumentLinks(new Map<ContentVersion, Id>{contentVersion => linkedEntityId});
        }

        return contentVersion;
    }

    public void insertContentDocumentLinks(Map<ContentVersion, Id> contentToLinkedEntityIdMap) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentVersion contentVersion : contentToLinkedEntityIdMap.keySet()) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentVersion.ContentDocumentId,
                LinkedEntityId    = contentToLinkedEntityIdMap.get(contentVersion),
                ShareType         = 'V'
            );

            contentDocumentLinks.add(contentDocumentLink);
        }

        insert contentDocumentLinks;
    }

}