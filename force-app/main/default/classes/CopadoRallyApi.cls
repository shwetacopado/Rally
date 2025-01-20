/**
 * This class use Rally REST API to retreive and update mapped objects and fields.
 * 
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class CopadoRallyApi {
    
    public String namedCredential; 
    public Copado_Rally_Integration__c rallyIntgr;
    public copado__Project__c project; 
    
    private Map<String, Id> userIdsByUserEmails = new Map<String, Id>();
    
	
    /**
     * fetch Releases from Rally and parce the response JSON.
     * */
	public List<copado__Release__c> fetchRallyReleases(Copado_Rally_Integration__c rallyIntegration, copado__Project__c prj ){
        System.debug('CopadoRallyApi :: fetchRallyReleases ' + rallyIntegration);
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();

        if(mode == ApplicationReadWriteMode.READ_ONLY){
            
            System.debug(LoggingLevel.WARN, 'Read Only Mode Skipping Fetch Rally Release!');
            return null;
        }

        rallyIntgr = rallyIntegration;
        project = prj;
        namedCredential = rallyIntgr.Named_Credential__c;
        

        //Set the required parameters for requestCalloutToRally method
        String serviceUrl = CopadoRallyConstants.RELEASE_ENDPOINT;
        String projectId = project.External_Id__c;
        String workspaceId = project.Workspace_Id__c;
        
        String pagesize = String.valueOf(CopadoRallyConstants.PAGE_SIZE);
        Map<String, String> queryParams = new Map<String, String>();//new Map<String, String>{'fetch'=> RELEASE_FETCH};
        Map<String, String> additionalHeaders = null;
        
        List<copado__Release__c> releases = new List<copado__Release__c>();
        
        Boolean continueCall = true;
        Integer startIndex = 1;
        Integer totalNumRelease; 
        
        while(continueCall){
        
            String responseBody;
            // Call the requestCalloutToRally method with required parameters
            System.debug('Test.isRunningTest(): ' + Test.isRunningTest());
            
            responseBody = requestCalloutToRally(CopadoRallyConstants.OBJECT_TYPE_RELEASE, namedCredential, serviceUrl, projectId, workspaceId, startIndex, pagesize, queryParams, additionalHeaders, '');
            
            // Parse the response and update the userStoryList
            CopadoRallyReleaseJParser parser = CopadoRallyReleaseJParser.parse(responseBody);
            System.debug('All Parsed Results: ' + parser.QueryResult.Results.size());
            
            if (parser.QueryResult.Errors.size() > 0) {
                List<String> errorMsgs = (List<String>) parser.QueryResult.Errors;
                if(errorMsgs.size() > 0){
                    System.debug('errorMsgs' + errorMsgs);
                }
            }
                      
            totalNumRelease = Integer.valueOf(parser.QueryResult.TotalResultCount);
            startIndex = Integer.valueOf(parser.QueryResult.StartIndex);
                       
            List<copado__Release__c> parcedRelease = createReleases(parser.QueryResult.Results);
            
            releases.addAll(parcedRelease);
            System.debug('Number of Parsed User Stories: ' + parcedRelease.size()); 
            System.debug('totalNumRelease: ' + totalNumRelease); 
            System.debug('startIndex: ' + startIndex); 
            continueCall = false;
            if (totalNumRelease - startIndex < CopadoRallyConstants.PAGE_SIZE) {
                    continueCall = false;
            } else {
                startIndex = startIndex + CopadoRallyConstants.PAGE_SIZE;
            }   
        }
        
        return releases;
    }
    
    /**
     * fetch Releases from Rally and parce the response JSON.
     * */
	public List<copado__Sprint__c> fetchRallyIterations(Copado_Rally_Integration__c rallyIntegration, copado__Project__c prj ){
        System.debug('CopadoRallyApi :: fetchRallyIterations ' + rallyIntegration);
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();

        if(mode == ApplicationReadWriteMode.READ_ONLY){
            
            System.debug(LoggingLevel.WARN, 'Read Only Mode Skipping Fetch Rally Release!');
            return null;
        }
        rallyIntgr = rallyIntegration;
        project = prj;
        namedCredential = rallyIntgr.Named_Credential__c;
        
        //Set the required parameters for requestCalloutToRally method
        String serviceUrl = CopadoRallyConstants.SPRINT_ENDPOINT;
        String projectId = project.External_Id__c;
        String workspaceId = project.Workspace_Id__c;
        
        String pagesize = String.valueOf(CopadoRallyConstants.PAGE_SIZE);
        Map<String, String> queryParams = new Map<String, String>();//new Map<String, String>{'fetch'=> RELEASE_FETCH};
        Map<String, String> additionalHeaders = null;
        
        List<copado__Sprint__c> iterations = new List<copado__Sprint__c>();
        
        Boolean continueCall = true;
        Integer startIndex = 1;
        Integer totalNumItn;
        
        while(continueCall){
        	
            System.debug('startIndex : ' + startIndex);
            List<copado__Sprint__c> parcedIterations = new List<copado__Sprint__c>();

            // Call the requestCalloutToRally method with required parameters
            String responseBody;

            System.debug('Test.isRunningTest(): ' + Test.isRunningTest());
            
            responseBody = requestCalloutToRally(CopadoRallyConstants.OBJECT_TYPE_SPRINT, namedCredential, serviceUrl, projectId, workspaceId, startIndex, pagesize, queryParams, additionalHeaders, '');
                                                        
            CopadoRallySprintJParser parser = CopadoRallySprintJParser.parse(responseBody);
            System.debug('All Parsed Results: ' + parser.QueryResult.Results.size());
                                   
            if (parser.QueryResult.Errors.size() > 0) {
                List<String> errorMsgs = (List<String>) parser.QueryResult.Errors;
                if(errorMsgs.size() > 0){
                    System.debug('Release Errors : ' + errorMsgs);
                }
            }
                      
            totalNumItn = Integer.valueOf(parser.QueryResult.TotalResultCount);
            startIndex = Integer.valueOf(parser.QueryResult.StartIndex);
                       
            parcedIterations = createIterations(parser.QueryResult.Results);
            iterations.addAll(parcedIterations);
            System.debug('Number of Parsed Iterations: ' + parcedIterations.size()); 
            System.debug('totalNumItn: ' + totalNumItn); 
            System.debug('startIndex: ' + startIndex);
            
            if (totalNumItn - startIndex < CopadoRallyConstants.PAGE_SIZE) {
                    continueCall = false;
                
            } else {
                startIndex = startIndex + CopadoRallyConstants.PAGE_SIZE;
            }
        }
        
        return iterations;
    }
    
    public List<copado__User_Story__c> fetchRallyUserStories(Copado_Rally_Integration__c rallyIntegration, copado__Project__c prj, Map<String,Id> sprintIdMap ){
        System.debug('CopadoRallyApi :: fetchRallyUserStories ' + rallyIntegration);
        ApplicationReadWriteMode mode = System.getApplicationReadWriteMode();

        if(mode == ApplicationReadWriteMode.READ_ONLY){
            
            System.debug(LoggingLevel.WARN, 'Read Only Mode Skipping Fetch Rally Release!');
            return null;
        }
        rallyIntgr = rallyIntegration;
        project = prj;
        namedCredential = rallyIntgr.Named_Credential__c;
        
        // Set the required parameters for requestCalloutToRally method
        String serviceUrl = CopadoRallyConstants.USERSTORY_ENDPOINT;
        String projectId = project.External_Id__c;
        String workspaceId = project.Workspace_Id__c;
        
        String pagesize = String.valueOf(CopadoRallyConstants.PAGE_SIZE);
        
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> additionalHeaders = null;
        System.debug('Project External Id: ' + projectId + ' Project Workspace Id: ' + workspaceId);
        
        List<copado__User_Story__c> userStories = new List<copado__User_Story__c>();
        
        Boolean continueCall = true;
        Integer startIndex = 1;
        Integer totalNumStories;
        
        while(continueCall){
        //for(Integer i=0; i< 3; i++){
            System.debug('startIndex at start: '+ startIndex); 
            // Call the requestCalloutToRally method with required parameters
            String responseBody;
            System.debug('Test.isRunningTest(): ' + Test.isRunningTest());
            
            responseBody = requestCalloutToRally(CopadoRallyConstants.OBJECT_TYPE_USERSTORY,namedCredential, serviceUrl, projectId, workspaceId, startIndex, pagesize, queryParams, additionalHeaders, '');
            
            // Parse the response and update the userStoryList
            CopadoRallyUserStoryJParser parser = CopadoRallyUserStoryJParser.parse(responseBody);
            
            System.debug('All Parsed Results: ' + parser.QueryResult.Results.size());
            
            if (parser.QueryResult.Errors.size() > 0) {
                List<String> errorMsgs = (List<String>) parser.QueryResult.Errors;
                if(errorMsgs.size() > 0){
                    System.debug('errorMsgs' + errorMsgs);
                }
            }
            
            totalNumStories = Integer.valueOf(parser.QueryResult.TotalResultCount);
            startIndex = Integer.valueOf(parser.QueryResult.StartIndex);
            
            List<copado__User_Story__c> parcedUserStories = createCopadoUserStories(parser.QueryResult.Results, sprintIdMap);
            
            userStories.addAll(parcedUserStories);
            System.debug('Number of Parsed User Stories: '+userStories.size()); 
            System.debug('totalNumStories: '+totalNumStories); 
            System.debug('startIndex: '+ startIndex); 
            
            if (totalNumStories - startIndex < CopadoRallyConstants.PAGE_SIZE) {
                continueCall = false;
            } else {
                startIndex = startIndex + CopadoRallyConstants.PAGE_SIZE;
            }
        }
        
        return userStories;
    }
            
    private String requestCalloutToRally(String callType, String namedCredential,
                                        String serviceUrl,
                                        String projectId,
                                        String workspaceId,
                                        Integer startIndex,
                                        String pagesize,
                                        Map<String, String> queryParams,
                                        Map<String, String> additionalHeaders, String bodyParam) {
            
            // Set default values for queryParams, workspace, project, and additional params
            if (workspaceId == null) {
                System.debug('WorkspaceId is not defined.');
            }
            if (projectId == null) {
                System.debug('ProjectId is not defined.');
            }
            // Set default values for queryParams, workspace, project, and additional params
            if (queryParams == null) {
                queryParams = new Map<String, String>();
            }
            // Add workspace and project to queryParams
            if(projectId != null){
                queryParams.put(CopadoRallyConstants.PROJECT_STR, '/project/' + projectId);
            }
            if(workspaceId != null){
                queryParams.put(CopadoRallyConstants.WORKSPACE_STR, '/workspace/' + workspaceId);
            }
           
            if(callType == CopadoRallyConstants.OBJECT_TYPE_USERSTORY){
                //FormattedID,ObjectID,Name,State,Description,ScheduleState,PlanEstimate,Notes,Owner,Release,LastUpdateDate,CreationDate,Defects
                if (!queryParams.containsKey(CopadoRallyConstants.FETCH_STR)) {
                	queryParams.put(CopadoRallyConstants.FETCH_STR, CopadoRallyConstants.USERTSTORY_FETCH);
            	}                                
            }else if(callType == CopadoRallyConstants.OBJECT_TYPE_RELEASE){
                //ObjectID,Name,State,ReleaseDate,ReleaseStartDate,PlannedVelocity,Description,LastUpdateDate,CreationDate
                if (!queryParams.containsKey(CopadoRallyConstants.FETCH_STR)) {
                	queryParams.put(CopadoRallyConstants.FETCH_STR, CopadoRallyConstants.RELEASE_FETCH);
            	} 
                
            }else if(callType == CopadoRallyConstants.OBJECT_TYPE_SPRINT){
                //ObjectID,Name,State,PlanEstimate,Notes,StartDate,LastUpdateDate,CreationDate,EndDate
                if (!queryParams.containsKey(CopadoRallyConstants.FETCH_STR)) {
                	queryParams.put(CopadoRallyConstants.FETCH_STR, CopadoRallyConstants.ITERATION_FETCH);
            	}                                
            }
                                            
           
			queryParams.put('order', CopadoRallyConstants.ORDER_QUERY);                                            
            queryParams.put('start', String.valueOf(startIndex));
             
            if (!queryParams.containsKey(CopadoRallyConstants.PROJECT_SCOPE_UP)) {
                queryParams.put(CopadoRallyConstants.PROJECT_SCOPE_UP, 'false');
            }
            if (!queryParams.containsKey(CopadoRallyConstants.PROJECT_SCOPE_DOWN)) {
                queryParams.put(CopadoRallyConstants.PROJECT_SCOPE_DOWN, 'false');
            }
            if (!queryParams.containsKey(CopadoRallyConstants.PAGESIZE)) {
                queryParams.put(CopadoRallyConstants.PAGESIZE, pagesize);
            }
                                                
            String externalSystemEndpoint = 'callout:' + namedCredential;
                                                              
            String url = createGetURL(serviceUrl, queryParams);
            
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            request.setEndpoint(externalSystemEndpoint + url);
            request.setMethod(CopadoRallyConstants.METHOD_GET);
            
            // Add additional headers
            if(additionalHeaders != null){
                for (String key : additionalHeaders.keySet()) {
                    request.setHeader(key, additionalHeaders.get(key));
                }
            }
            
            if(!Test.isRunningTest()){
                Http http = new Http();
                HttpResponse response = http.send(request);
                System.debug('Response Status: '+response.getStatusCode());
                
                return response.getBody();
            }else{
                String body;
                Map <String, String> header = new Map<String, String>();
                header.put('Content-Type','application/json');
                if(callType == CopadoRallyConstants.OBJECT_TYPE_USERSTORY){
                    
                    HttpResponse response = CopadoMockHttpResponseGenerator.generateUserStoryMockHttpResponse(200, 'Ok', null, header);
                    body = response.getBody();
                }else if(callType == CopadoRallyConstants.OBJECT_TYPE_RELEASE){
                    HttpResponse response = CopadoMockHttpResponseGenerator.generateReleaseMockHttpResponse(200, 'Ok', null, header);
                    body = response.getBody();                                                    
                }else if(callType == CopadoRallyConstants.OBJECT_TYPE_SPRINT){
                    HttpResponse response = CopadoMockHttpResponseGenerator.generateSprintMockHttpResponse(200, 'Ok', null, header);
                    body = response.getBody();
                }
                
                return body;
            }
            
        }
        
    	private static void updateCalloutToRally(String namedCredential,
                                        String serviceUrl,
                                        String projectId,
                                        String workspaceId,
                                        String bodyParam,
                                        Map<String, String> queryParams,
                                        Map<String, String> additionalHeaders) {
            
            // Set default values for queryParams, workspace, project, and additional params
            if (workspaceId == null) {
                System.debug('WorkspaceId is not defined.');
            }
            if (projectId == null) {
                System.debug('ProjectId is not defined.');
            }
            // Set default values for queryParams, workspace, project, and additional params
            if (queryParams == null) {
                queryParams = new Map<String, String>();
            }
            // Add workspace and project to queryParams
            if(projectId != null){
                queryParams.put(CopadoRallyConstants.PROJECT_STR, '/project/' + projectId);
            }
            if(workspaceId != null){
                queryParams.put(CopadoRallyConstants.WORKSPACE_STR, '/workspace/' + workspaceId);
            }
           
			queryParams.put('order', CopadoRallyConstants.ORDER_QUERY);                                            
             
            if (!queryParams.containsKey(CopadoRallyConstants.PROJECT_SCOPE_UP)) {
                queryParams.put(CopadoRallyConstants.PROJECT_SCOPE_UP, 'false');
            }
            if (!queryParams.containsKey(CopadoRallyConstants.PROJECT_SCOPE_DOWN)) {
                queryParams.put(CopadoRallyConstants.PROJECT_SCOPE_DOWN, 'false');
            }
                        
            String externalSystemEndpoint = 'callout:' + namedCredential;
            System.debug('externalSystemEndpoint: '+externalSystemEndpoint);
            String url = serviceUrl;
            
            //Create HTTP Request.
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            request.setEndpoint(externalSystemEndpoint + url);
            request.setMethod(CopadoRallyConstants.METHOD_POST);
                                            
            if(String.isNotBlank(bodyParam)){
            	request.setBody(bodyParam);
                System.debug('request.setBody(bodyParam): '+ bodyParam);
            }
            System.debug('serviceUrl: '+ serviceUrl);
                                          
            // Add additional headers
            if(additionalHeaders != null){
                for (String key : additionalHeaders.keySet()) {
                    request.setHeader(key, additionalHeaders.get(key));
                }
            }
            
            if(!Test.isRunningTest()){
            	Http http = new Http();
                HttpResponse response = http.send(request);
                System.debug('Response Status: '+response.getStatusCode());
                                
                //return response.getBody();
                System.debug('Response Body: '+ response.getBody());
            }else{
                HttpResponse mockResponse = CopadoMockHttpResponseGenerator.generateUserStoryMockHttpResponse(200, 'Ok', null, null);
                String responseBody = mockResponse.getBody(); // Test Mock Response
            }
            
        }
    
    	/** Create REST API Service URL */
        public String createGetURL(String baseUrl, Map<String, String> queryParams) {
            String url = baseUrl;
            if (queryParams != null && !queryParams.isEmpty()) {
                List<String> paramList = new List<String>();
                for (String key : queryParams.keySet()) {
                    if(!key.equalsIgnoreCase(CopadoRallyConstants.PROJECT_STR) || !key.equalsIgnoreCase(CopadoRallyConstants.WORKSPACE_STR)){
                        paramList.add(key + '=' + EncodingUtil.urlEncode(queryParams.get(key), CopadoRallyConstants.ENCODING_TYPE));
                    }else{
                        paramList.add(key + '=' + queryParams.get(key));
                    }
                    
                }
                String paramString = String.join(paramList, '&');
                url += '?' + paramString;
            }
            System.debug('Calculated URl: '+ url);
            return url;
        }
    	    	
    	/*
    	 * all Result == hierarchicalrequirement
    	 */
    	public List<copado__User_Story__c> createCopadoUserStories(List<CopadoRallyUserStoryJParser.Results> allResults, Map<String,Id> sprintRelIdMap) {
            List<copado__User_Story__c> userStories = new List<copado__User_Story__c>();
            
            Map<String, String> fieldMap = CopadoRallyFieldMappings.returnUserStoryFieldMap(); 
            
            for (CopadoRallyUserStoryJParser.Results req : allResults) {
                
                Map<String,Object> reqMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(req));
                
                copado__User_Story__c userStory = new copado__User_Story__c();
                
                userStory.RecordTypeId = getUserStoryRecordTypeId();
                for (String sfieldName : fieldMap.keySet()) {
                    
                    String rallyField = (String) fieldMap.get(sfieldName);
                    
                    if (rallyField == 'Project') {
                        // For the Project field,
                        userStory.copado__Project__c = project.Id;
                    }else if (rallyField == CopadoRallyConstants.OBJECTID) {
                        // For the External_Id__c field, get the value from the JSON response
                        String externalId = req.ObjectID; 
                        userStory.External_Id__c = externalId;
                    }else if (rallyField == CopadoRallyConstants.OBJECT_TYPE_SPRINT) {
                        Object itnObj = reqMap.get(rallyField);
                        Map<String, Object> itnmap = (Map<String, Object>) reqMap.get(rallyField);
                                               
                        if(itnmap != null){
                            
                            Id sprntId = sprintRelIdMap.get((String)itnmap.get(CopadoRallyConstants.OBJECTID));
                            if(sprntId != null){
                                userStory.put(sfieldName, sprntId);
                            }
                        }
                        
                    }else if (rallyField == CopadoRallyConstants.OBJECT_TYPE_RELEASE) {
                        Object itnObj = reqMap.get(rallyField);
                        Map<String, Object> relmap = (Map<String, Object>) reqMap.get(rallyField);
                        
                        if(relmap != null){
                            
                            Id relId = sprintRelIdMap.get((String)relmap.get(CopadoRallyConstants.OBJECTID));
                            if(relId != null){
                                userStory.put(sfieldName, relId);
                            }
                        }
                        
                    }else if (rallyField == CopadoRallyConstants.OBJECT_TYPE_OWNER) {
                        Object itnObj = reqMap.get(rallyField);
                        Map<String, Object> relmap = (Map<String, Object>) reqMap.get(rallyField);
                        System.debug('relmap '+ relmap); 
                        if(relmap != null){
                            String emailAdd = (String) relmap.get(CopadoRallyConstants.EMAIL_ADDRESS);
                            if(emailAdd != null){
                                //system.debug('createCopadoUserStories Owner :: ' + relmap.get(CopadoRallyConstants.EMAIL_ADDRESS) + ' >> ');
                                //Id relId = sprintRelIdMap.get((String)relmap.get(CopadoRallyConstants.OBJECTID));
                                User dev = CopadoRallyUtilities.findActiveUserByEmail(emailAdd);
                                if(dev != null){
                                    userStory.put(sfieldName, dev.Id);
                                }
                            }
                        }
                        
                    } else {
                        // For other fields, get the value from the JSON response
                        Object value = reqMap.get(rallyField);
                        
                        Object typeCastedValue = CopadoRallyUtilities.returnCastedValue(value, sfieldName, CopadoRallyConstants.OBJECT_TYPE_USERSTORY);
                        
                        if (sfieldName == 'copado__User_Story_Title__c') {
                            
                            Object formatedID = reqMap.get('FormattedID');
                            userStory.put(sfieldName, typeCastedValue);
                            
                        }else if (sfieldName == 'copado__Status__c') {
                            // You may need to map the status value from Rally to Salesforce values
                            
                            if(typeCastedValue != null){
                                userStory.put(sfieldName, typeCastedValue);
                            }
                        } else{
                            
                            if(typeCastedValue != null){
                                userStory.put(sfieldName, typeCastedValue);
                            }
                        }
                         
                    }
                }
                
                userStories.add(userStory);
            }
            return userStories;
        }
    	            	
    	public List<copado__Release__c> createReleases(List<CopadoRallyReleaseJParser.Release> allResults) {
            List<copado__Release__c> releasesToUpsert = new List<copado__Release__c>();
            
            Map<String, String> fieldMap = CopadoRallyFieldMappings.returnReleaseFieldMap(); 
            
            for (CopadoRallyReleaseJParser.Release req : allResults) {
                //System.debug('RallyReleaseJSONParser.Release req :  '+ req );
                Map<String,Object> reqMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(req));
                copado__Release__c release = new copado__Release__c();
                
                for (String fieldName : fieldMap.keySet()) {
                    //System.debug('Field Name:  '+ fieldName );
                    String rallyField = (String) fieldMap.get(fieldName);
                    //System.debug('rallyField :  '+ rallyField );
                    if (rallyField == CopadoRallyConstants.PROJECT_STR) {
                        // For the Project field,
                        release.copado__Project__c = project.Id;
                    }else if (rallyField == CopadoRallyConstants.OBJECTID) {
                        // For the External_Id__c field, get the value from the JSON response
                        String externalId = String.valueOf(req.ObjectID); 
                        release.External_Id__c = externalId;  
                    } else {
                        // For other fields, get the value from the JSON response
                        Object value = reqMap.get(rallyField);
                        Object typeCastedValue = CopadoRallyUtilities.returnCastedValue(value, fieldName, CopadoRallyConstants.OBJECT_TYPE_RELEASE);
                        
                        if (fieldName == 'copado__Status__c') {
                            // You may need to map the status value from Rally to Salesforce values
                            
                            if(typeCastedValue != null){
                                release.put(fieldName, typeCastedValue);
                            }
                        } else {
                            if(typeCastedValue != null){
                                release.put(fieldName, typeCastedValue);
                            }
                        }
                        
                        
                    }
                    
                }
                
                releasesToUpsert.add(release);
            }
            return releasesToUpsert;
        }
    	
    	
    	/*
    	 * all Results == Iterations 
    	 */
    	public List<copado__Sprint__c> createIterations(List<CopadoRallySprintJParser.Results> allResults) {
            List<copado__Sprint__c> itnsToUpsert = new List<copado__Sprint__c>();
            
            Map<String, String> fieldMap = CopadoRallyFieldMappings.returnIterationFieldMap(); 
            
            Integer count = 0;
            for (CopadoRallySprintJParser.Results req : allResults) {
                
                Map<String,Object> reqMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(req));
                copado__Sprint__c itn = new copado__Sprint__c();
                
                for (String fieldName : fieldMap.keySet()) {
                    //System.debug('Field Name:  '+ fieldName );
                    String rallyField = (String) fieldMap.get(fieldName);
                    //System.debug('rallyField :  '+ rallyField );
                    if (rallyField == CopadoRallyConstants.PROJECT_STR) {
                        // For the Project field,
                        itn.copado__Project__c = project.Id;
                    } else {
                        // For other fields, get the value from the JSON response
                        Object value = reqMap.get(rallyField);
                        Object typeCastedValue = CopadoRallyUtilities.returnCastedValue(value, fieldName, CopadoRallyConstants.OBJECT_TYPE_SPRINT);
                        if (fieldName == 'copado__Status__c') {
                            
                            // You may need to map the status value from Rally to Salesforce values
                            if(typeCastedValue != null){
                                itn.put(fieldName, typeCastedValue);
                            }
                        } else {
                            if(typeCastedValue != null){
                                itn.put(fieldName, typeCastedValue);
                            }
                        } 
                        //System.debug('createIterations>> fieldName '+ fieldName + ' : ' + typeCastedValue);
                    }
                }
                
                itnsToUpsert.add(itn);
                System.debug('createIterations >> itneration to update ' + itn);
            }
            
            return itnsToUpsert;
        }
    	
    	
    	/*
    	 * Update User Story in Rally. 
    	 */
    	@invocableMethod(label='Update Rally Hierarchicalrequirement')
    	public static void updateUserStory(List<List<copado__User_Story__c>> usToUpdate) {

            Map<String, Map<String, String>> projectToUserStoriesMap = new Map<String, Map<String, String>>();
            Map<String, UserStoryUpdRequestObj> usMapByExternalId = new Map<String, UserStoryUpdRequestObj>();
            Map<String, String> usBodyMapByExternalId = new Map<String, String>();
            
            List<String> prjIsList = new List<String>();
            
            for(List<copado__User_Story__c> usUtemLst : usToUpdate){
                
                for(copado__User_Story__c usItem: usUtemLst){
					
                    if(usItem.copado__Project__c != null){
                        UserStoryUpdRequestObj usObj = new UserStoryUpdRequestObj();
                        usObj.ExternalId = usItem.External_Id__c;
                        usObj.Name = usItem.copado__User_Story_Title__c;
                        usObj.Project = usItem.copado__Project__c;
                        usObj.Status = usItem.copado__Status__c;
                        usObj.Notes = usItem.Notes__c;
                        
                        usMapByExternalId.put(usObj.ExternalId, usObj);
                    	
                        prjIsList.add(usObj.Project);
                        
                        String usBodyToUpdate = getUserStoryRequestBody(usObj.Status, usObj.Notes);
                        if(String.isNotBlank(usBodyToUpdate)){
                            usBodyMapByExternalId.put(usObj.ExternalId, usBodyToUpdate);
                        }
                        
                        if (!projectToUserStoriesMap.containsKey(usItem.copado__Project__c)) {
                            projectToUserStoriesMap.put(usItem.copado__Project__c, new Map<String, String>());
                        }
                        projectToUserStoriesMap.get(usItem.copado__Project__c).put(usObj.ExternalId, usBodyToUpdate);
                        
                    }

                }
                               
            }
            
            Map<String, String> fieldsToUpdate = CopadoRallyFieldMappings.returnUpdateUserStoryFieldMap();
            List<String> fieldList = new List<String>(fieldsToUpdate.keySet());
            
            String fieldListStr = String.valueOf(fieldList).replace('(', '').replace(')', '');
            
            List<copado__Project__c> projectLst = [SELECT Id, Name, Copado_Rally_Integration_Setting__r.Name, Copado_Rally_Integration_Setting__r.Named_Credential__c, Copado_Rally_Integration_Setting__r.Is_Rally_Sync_Running__c, Copado_Rally_Integration_Setting__r.Last_Sync_Time__c  FROM copado__Project__c WHERE Id  IN: prjIsList WITH SECURITY_ENFORCED];

             
            //for(copado__Project__c projectItem : projectLst){
            for(copado__Project__c projectItem : projectLst){

                //Check if this call  is due to rally sync job.
                if(!Test.isRunningTest()){
                    DateTime lastSynTm = projectItem.Copado_Rally_Integration_Setting__r.Last_Sync_Time__c;
                    Boolean isSynRunning = projectItem.Copado_Rally_Integration_Setting__r.Is_Rally_Sync_Running__c;
                
                    if((isSynRunning != null && isSynRunning) || (lastSynTm != null && DateTime.now().getTime() - lastSynTm.getTime() <= 10000)){
                        System.debug('The Job is either running or recently completed. Skipping updating Rally User Story!');
                        return;
                    }
                }
                
                String serviceUrl = CopadoRallyConstants.USERSTORY_ENDPOINT + '/' ; 
            	String namedCredential = projectItem.Copado_Rally_Integration_Setting__r.Named_Credential__c;
                Map<String, String> usBdMapByExternalId = projectToUserStoriesMap.get(projectItem.Id);
				for(String fName : usBdMapByExternalId.keySet()){
                    serviceUrl += fName;
                    String bodyStr = usBdMapByExternalId.get(fName);
                    updateCalloutToRally(namedCredential, serviceUrl, null, null, bodyStr, null, null);
                }                
                
            }
            
            
        }
    	
        private static String getUserStoryRequestBody(String scheduleState, String notes) {
            
            Map<String, Object> userStoryFieldBody = new Map<String, Object>{
                    'ScheduleState' => scheduleState,
                    'Notes' => notes
             };
            
            Map<String, Object> requestBody = new Map<String, Object>{
                'hierarchicalrequirement' => userStoryFieldBody
            };
            
            return JSON.serialize(requestBody);
            
        }
    
        private static Id getUserStoryRecordTypeId() {
            String userStoryRecordTypeName = 'User Story';
            Id userStoryRecordTypeId;
        
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByName();
            if (recordTypes.containsKey(userStoryRecordTypeName)) {    
                userStoryRecordTypeId = recordTypes.get(userStoryRecordTypeName).getRecordTypeId();
            }
        
            return userStoryRecordTypeId;
        }
    
    	private static Id getDefectRecordTypeId() {
            String userStoryRecordTypeName = 'Bug';
            Id userStoryRecordTypeId;
        
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByName();
            if (recordTypes.containsKey(userStoryRecordTypeName)) {
                userStoryRecordTypeId = recordTypes.get(userStoryRecordTypeName).getRecordTypeId();
            }
        
            return userStoryRecordTypeId;
        }
        
    
    public class UserStoryUpdRequestObj {
        public String ExternalId {get;set;} 
        public String Name {get;set;} 
        public String Project {get;set;}
        public String Status {get;set;} 
        public String Notes {get;set;} 
    }
    
}