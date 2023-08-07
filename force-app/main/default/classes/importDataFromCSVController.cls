public class importDataFromCSVController {
    
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<account> accountlist{get;set;}
    
    public importDataFromCSVController(){
        csvFileLines = new String[]{};
            accountlist= New List<Account>();
    }
    
    public static void FetchCsvData(){
        try{
            // ====================================== Query CSV file from static resource =================================
            StaticResource accSR = [SELECT Id, Body FROM StaticResource WHERE Name = 'CaseToBeUpdated' LIMIT 1];
            system.debug('accSR =====> ' + accSR);
            
            // Convert body to String
            
            String bodyAccSR = accSR.Body.toString();
            system.debug('bodyAccSR =====> ' + bodyAccSR);
            
            
            List<String> strCSVLines = new List<String>();
            strCSVLines = bodyAccSR.split('\n');
            
            //system.debug('strCSVLines =====> ' + strCSVLines);
            set<String> CaseNumbers = new Set<String>();
            String QueryString = 'Select id,';
            for(integer i=0; i<strCSVLines.size(); i++){
                system.debug('strCSVLines ith index =====> ' + strCSVLines[i]);
                System.debug('num isNumericSpace: ' + strCSVLines[i].isNumericSpace()); // Will show as TRUE in the debug log
                System.debug('num isNumeric: ' + strCSVLines[i].isNumeric()); // Will show as TRUE in the debug log
                System.debug('num isAlpha: ' + strCSVLines[i].isAlpha()); // Will show as FALSE in the debug log
                System.debug('num isAlphanumeric: ' + strCSVLines[i].isAlphanumeric()); // Will show as TRUE in the debug log
                if(i> 0){
                    CaseNumbers.add(strCSVLines[i]);
                }
                if(strCSVLines[i].isAlpha()){
                    //CaseNumbers.add(integer.valueof(strCSVLines[i]));
                }
            }
            system.debug('CaseNumbers =====> ' + CaseNumbers);
        }
        catch(Exception e){
            system.debug('The error has occurred due to =====> ' + e.getMessage());
            system.debug('The error has occurred at =====> ' + e.getLineNumber());
        }
        
    }
    
    public static void FetchCsvData2D(){
        
        List<List<String>> allFields = new List<List<String>>();
        
        //This is Base 64 version of the CSV File
        String strCSVFileBase64 = 'RmlsZSxOYW1lLEV4dGVybmFsSUQsQW1vdW50LFRyYW5zYWN0aW9uVHlwZSxSZXR1cm5Db2RlLFJldHVybkNvZGVEZXNjcmlwdGlvbixEYXRlLEJhbGFuY2UKUmV0dXJuLC0sQ2hlY2sxLHRvLEUwMTExMTExMSwkNC4wMCxEZWJpdCwxMTEsQWNjb3VudC9VbmFibGUKUmV0dXJuLC0sQ2hlY2syLGFkdmlzZXMsRTAyMjIyMjIyLCQ0LjAwLERlYml0LDIyMixjdXN0b21lcgosLCwsLCwsLAp0ZXh0Ym94MzAsdGV4dGJveDU5LHRleHRib3g2MSwsLCwsLAo0LzE5LzIwMjIsJDAuMDAsMiwsLCwsLAosLCwsLCwsLA==';
        
        String strCSVFile = EncodingUtil.base64Decode(strCSVFileBase64).toString();
        system.debug('strCSVFile =====> ' + strCSVFile);
        strCSVFile = strCSVFile.replaceAll(',"""', ',"DBLQT');
        system.debug('strCSVFile =====> ' + strCSVFile);
        strCSVFile = strCSVFile.replaceall('""",', 'DBLQT",');
        system.debug('strCSVFile =====> ' + strCSVFile);
        strCSVFile = strCSVFile.replaceAll('""', 'DBLQT');
        system.debug('strCSVFile =====> ' + strCSVFile);
        List<String> strCSVLines = new List<String>();
        strCSVLines = strCSVFile.split('\n');
        
        // Calling Parser Logic from the parseCSV Helper Class
        allFields = getAllFields(strCSVLines);
        
        // Removed the first row at it contains the column name
        if (allFields.size() > 0) {
            allFields.remove(0);
        }        
        
        for (Integer i = 0; i < allFields.size(); i++) 
        {           
            String[] csvRecordData = allFields[i];
            if (String.isNotEmpty(csvRecordData[0]) && csvRecordData.size() > 0) 
            {
                String strFileName = csvRecordData[0];//Gets the First element or row 1 which is FileName
                String strFieldName = csvRecordData[1];
                String strExternalId = csvRecordData[2];//Gets the Third element or row 1 which is External ID
            }
        }
        
    }
    
    
    public static List<List<String>> getAllFields(List<String> strCSVLines) {
        List<List<String>> allFields = new List<List<String>>();
        for (String line : strCSVLines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',', '').trim().length() == 0) {
                break;
            }
            
            List<String> fields = line.split(',');
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            
            for (String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT', '"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField += ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                }
            }
            allFields.add(cleanFields);
        }
        return allFields;
    }
    
    
    public static void CreateStaticResource(){
        try{
            
           MetadataService.MetadataPort service = createService();
            
            MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
            staticResource.fullName = 'MyResource';
            staticResource.contentType = 'csv';
            staticResource.cacheControl = 'public';
            staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static, stuff'));
            MetadataService.SaveResult[] results = service.createMetadata(new List<MetadataService.Metadata> { staticResource });
        }
        catch(Exception e){
            system.debug('The error has occurred due to =====> ' + e.getMessage());
            system.debug('The error has occurred at =====> ' + e.getLineNumber());
        }
    }public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
    
    
}
/*
* File,Name,ExternalID,Amount,TransactionType,Code,Description,Date,Balance
* Return,-,Check1,to,E01111111,$4.00,Debit,111,Account/Unable
* Return,-,Check2,advises,E02222222,$4.00,Debit,222,customer
* ,,,,,,,,
* textbox30,textbox59,textbox61,,,,,,
* 4/19/2022,$0.00,2,,,,,,
* ,,,,,,,,
*/