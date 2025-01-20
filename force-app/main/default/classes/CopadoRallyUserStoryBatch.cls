/**
 * A batch class to process Copado Rally User Story and upsert.
 * 
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public class CopadoRallyUserStoryBatch implements Database.Batchable<Object>, Database.AllowsCallouts {
    
    // List to hold the user story to upsert
    private List<copado__User_Story__c> userStoriesToUpsert;
    // List to hold the user story to process
    private List<Map<String, String>> userStoryList; 
    // Hold the Ids of Sprint and Release with User Story external Id.
    Map<String,Id> sprtRelExtIdMap;
    CopadoRallyApi conn;
    // List to hold the releases to upsert
    private Copado_Rally_Integration__c rallyIntegration;
    private copado__Project__c gProject;
    // Should include iteration. 
    private Boolean includeSprint = false;
    
    // Constructor for the class
    public CopadoRallyUserStoryBatch(copado__Project__c project) {
        
        // Initialize the rallyIntegration and gProject
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
    }
    
    // Constructor for the class
    public CopadoRallyUserStoryBatch(copado__Project__c project, Boolean includeSprint) {
        
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
        if(includeSprint){
            this.includeSprint = includeSprint;
        }
    }
     
    // Start method for the batch job
    public Iterable<Object> start(Database.BatchableContext bc) {
        System.debug('CopadoRallyUserStoryBatch Batch start');
		Map<String,Id> sprtRelExtIds = new Map<String,Id>();
        System.debug('this.includeSprint : '+ this.includeSprint);
        if(this.includeSprint){
            
            List<copado__Sprint__c> sprints = [
                SELECT Id, Name, External_Id__c
                FROM copado__Sprint__c
                WHERE copado__Project__c = :gProject.Id AND External_Id__c != NULL
                ORDER BY copado__Start_Date__c ASC
            ]; 
        
            List<copado__Release__c> releases = [
                SELECT Id, Name, External_Id__c
                FROM copado__Release__c
                WHERE copado__Project__c = :gProject.Id AND External_Id__c != NULL
            ];
            
            for(copado__Sprint__c spr : sprints ){
                sprtRelExtIds.put(spr.External_Id__c, spr.Id);
            }
            
            for(copado__Release__c rel : releases ){
                sprtRelExtIds.put(rel.External_Id__c, rel.Id);
            }
           
        }
       
        if (null != userStoryList && !userStoryList.isEmpty()) {
            System.debug('CopadoRallyUserStoryBatch Batch start end');
            return new RallyCallIterable(userStoryList);
        } else {
            if(conn == null){
                conn = new CopadoRallyApi();
            }
            if(sprtRelExtIds.keySet().size() > 0){
                this.sprtRelExtIdMap = sprtRelExtIds;
                //System.debug('sprtRelExtIds: '+ sprtRelExtIds.keyset());
                //System.debug('this.sprtRelExtIdMap: '+ this.sprtRelExtIdMap.keyset());
            }
            
            return new RallyCallIterable(
                conn.fetchRallyUserStories(rallyIntegration, gProject, this.sprtRelExtIdMap)
            );
        }
        
    }
 
    // Execute method for the batch job
    public void execute(Database.BatchableContext bc, List<Object> scope) {
        System.debug('CopadoRallyUserStoryBatch Batch execute start ');
        System.debug('CopadoRallyUserStoryBatch Number of object in scope ' + scope.size());
        this.userStoriesToUpsert = new List<copado__User_Story__c>();
        for (Object usItem : scope) {
            
            copado__User_Story__c sobj = (copado__User_Story__c) usItem;
            userStoriesToUpsert.add(sobj);
        }
        
        try {
             if(Test.isRunningTest()){
    			upsert userStoriesToUpsert External_Id__c;
			} else {
            //performs upsert based on External Id
            	Database.upsert(userStoriesToUpsert, copado__User_Story__c.Fields.External_Id__c, AccessLevel.USER_MODE);
            }               
        } catch (DmlException ex) {
            System.debug('CopadoRallyUserStoryBatch dml exception==> ' + ex.getMessage());
        }
		        
    }
    
    // Finish method for the batch job
    public void finish(Database.BatchableContext bc) {
        System.debug('CopadoRallyUserStoryBatch Batch Execution Finished');
        if(this.rallyIntegration != null){
            //this.rallyIntegration.Is_Rally_Sync_Running__c = false;
            

            Copado_Rally_Integration__c intUpd = this.rallyIntegration;
            intUpd.Is_Rally_Sync_Running__c = false;
            intUpd.Last_Sync_Time__c = DateTime.now();
            update intUpd;
        }
    }
}