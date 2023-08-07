public class FileUploadController {

    @AuraEnabled
    public static list<Id> saveFiles(Id recordId, list<Object> filesToInsert){
        
        list<Id> lstCntVerIds = new list<Id>();
        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        
        try {
            
            if (recordId == null) {
                system.debug('Record id is null');
                throw new AuraHandledException('No record id for ContentVersion record insertion');
            }
            
            for (Object file : filesToInsert) {
                FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                ContentVersion objCntVersion = new ContentVersion();
                objCntVersion.Title = fileData.Title;
                objCntVersion.PathOnClient = '/' + fileData.Title;
                objCntVersion.FirstPublishLocationId = recordId;
                objCntVersion.VersionData = fileData.VersionData;
                objCntVersion.IsMajorVersion = true;
                lstVersionsToInsert.add(objCntVersion);
            }
            if(!lstVersionsToInsert.isempty()){
                insert lstVersionsToInsert;
            }
            
            
            
        } catch(Exception e) {
            
            system.debug('ContentVersion insert error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return lstCntVerIds;
    }
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }



    public static void createContentDeliveryFile(String fileBody, String recordId){
        //Creating Salesforce File
        ContentVersion contentObj =new ContentVersion(); 
        contentObj.Title = 'Password Protected';  //File Name
        contentObj.VersionData=EncodingUtil.base64Decode(fileBody); //File body
        contentObj.PathOnClient= 'Password Protected.png'; //File extension
        insert contentObj; 
        
        //Content document for linking the file to a parent entity
        ContentDocumentLink docLinkObj = new ContentDocumentLink();
        //Fetch ContentdocumentId from Content Version 
        docLinkObj.ContentDocumentId = [select Id,ContentDocumentId from ContentVersion WHERE Id =:contentObj.Id].ContentDocumentId;
        docLinkObj.LinkedEntityId = recordId; //Id of the parent record
        docLinkObj.ShareType = 'I'; //Inferred Permission. Determined by the user's access to parent record.
        insert docLinkObj;
        
        //Create Content Distribution to make the file publicly available as well as password protected
        ContentDistribution cdistObj = new ContentDistribution();
        cdistObj.name = contentObj.Title;
        cdistObj.ContentVersionId = contentObj.Id; //Id of the content version record
        cdistObj.PreferencesAllowPDFDownload = true; //Allow to download the file as PDF
        cdistObj.PreferencesAllowViewInBrowser = true; // Allow to view the file in browser
        cdistObj.ExpiryDate = Datetime.now().addMinutes(120); // set an expiry date/time for the file (2 hours from current time in this case)
        cdistObj.PreferencesExpires = true; //If setting the expiry date, setting this field to true is required
        insert cdistObj;

        //Fetch the Public URL and Password to store in some into the parent record and use it for further processing
        List<ContentDistribution> cdistObjList = [SELECT DistributionPublicUrl,Password,ExpiryDate FROM ContentDistribution WHERE Id=:cdistObj.Id];

        System.debug('cdistObjList ======> ' + cdistObjList);
        System.debug('cdistObjList Password ======> ' + cdistObjList[0].Password);

        //Further processing .........
        //The above list will have all the details which can be used to store on any object and can be sent out to external users.
    }


    // ================================== References Salesforce Doc =======================

    /*  ContentDocumentlink  :    https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocumentlink.htm
        ContentVersion       :    https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentversion.htm
        ContentDocument      :    https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdocument.htm
        ContentDistribution  :    https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_contentdistribution.htm
        
    */
}