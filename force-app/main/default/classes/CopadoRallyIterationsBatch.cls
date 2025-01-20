/** 
 * This is a batch class to process Copado Rally Iterations and upsert.
 * 
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 * 
*/
public class CopadoRallyIterationsBatch implements Database.Batchable<Object>, Database.AllowsCallouts{
    
    // List to hold the iterations to upsert
    private List<copado__Sprint__c> iterationListToUpsert;
    // List to hold the iterations
    private List<copado__Sprint__c> iterationList;
    // Instance of CopadoRallyApi
    CopadoRallyApi conn; 
    // Instance of Copado_Rally_Integration__c
    private Copado_Rally_Integration__c rallyIntegration;
    // Instance of copado__Project__c
    private copado__Project__c gProject;

    private Boolean includeSprint = false;
    
    // Constructor for the class
    public CopadoRallyIterationsBatch(copado__Project__c project) {
        // Initialize the rallyIntegration and gProject
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
    }  
    
    // Constructor for the class
    public CopadoRallyIterationsBatch(copado__Project__c project, Boolean includeSprint ) {
        
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
        
        if(this.includeSprint){
           this.includeSprint = includeSprint;
        }
    }

    // Start method for the batch job
    public Iterable<Object> start(Database.BatchableContext context) {
        System.debug('Copado Rally Sync CopadoRallyIterationsBatch Started');        
        if (null != iterationList && !iterationList.isEmpty()) {
            return new RallyCallIterable(iterationList);
        } else {
            if(conn == null){ 
                conn = new CopadoRallyApi();
            }
            // Fetch Rally Iterations
            return new RallyCallIterable(
                conn.fetchRallyIterations(rallyIntegration, gProject)
            );
        }
    }

    // Execute method for the batch job
    public void execute(Database.BatchableContext context, List<Object> scope) {
        System.debug('CopadoRallyIterationsBatch Batch execute start ');
        System.debug('CopadoRallyIterationsBatch Number of object in scope ' + scope.size());
        // Iterate through iterations and perform processing/synchronization
        this.iterationListToUpsert = new List<copado__Sprint__c>();
        for (Object reItem : scope) {
            copado__Sprint__c sobj = (copado__Sprint__c) reItem;
            this.iterationListToUpsert.add(sobj);
        }
        
        try {
            if(Test.isRunningTest()){
    			upsert iterationListToUpsert External_Id__c;
			} else {
            	// Performs upsert based on External Id
            	Database.upsert(iterationListToUpsert, copado__Sprint__c.Fields.External_Id__c, AccessLevel.USER_MODE);
            }
        } catch (DmlException ex) {
            System.debug('CopadoRallyIterationsBatch dml exception==> ' + ex.getMessage());
        }
    }

    // Finish method for the batch job
    public void finish(Database.BatchableContext context) {
        System.debug('CopadoRallyIterationsBatch Batch finish ');
        // Execute the CopadoRallyUserStoryBatch
        CopadoRallyUserStoryBatch userStoryBatch = new CopadoRallyUserStoryBatch(this.gProject, true);
        Database.executeBatch(userStoryBatch);
    }
}