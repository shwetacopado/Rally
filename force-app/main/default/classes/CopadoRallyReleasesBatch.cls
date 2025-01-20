/**
 * This is a batch class to process Copado Rally Release and upsert.
 * 
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public class CopadoRallyReleasesBatch implements Database.Batchable<Object>, Database.AllowsCallouts {
    
    // List to hold the releases to upsert
    private List<copado__Release__c> releasesToUpsert;
    // List to hold the releases to process
    private List<copado__Release__c> releasesList; 
    // Instance of CopadoRallyApi
	CopadoRallyApi conn;
    private Copado_Rally_Integration__c rallyIntegration;
    private copado__Project__c gProject;
    
    private Boolean includeSprint = false;

    // Constructor for the class
    public CopadoRallyReleasesBatch(copado__Project__c project) {
        // Initialize the rallyIntegration and gProject
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
    }  
    
    // Constructor for the class
    public CopadoRallyReleasesBatch(copado__Project__c project, Boolean includeSprint ) {
        
        this.rallyIntegration = project.Copado_Rally_Integration_Setting__r;
        this.gProject = project;
        
        if(this.includeSprint){
            this.includeSprint = includeSprint;
        }
    }
    
    // Start method for the batch job
    public Iterable<Object> start(Database.BatchableContext context) {
        
        System.debug('Copado Rally Sync CopadoRallyReleasesBatch Started');        
        if (null != releasesList && !releasesList.isEmpty()) {
            return new RallyCallIterable(releasesList); 
        } else {
            if(conn == null){ 
                conn = new CopadoRallyApi();
            }
            
            return new RallyCallIterable(
                conn.fetchRallyReleases(rallyIntegration, gProject)
            );
        }
    }

    // Execute method for the batch job
    public void execute(Database.BatchableContext context, List<Object> scope) {
        System.debug('CopadoRallyReleasesBatch Batch execute start ');
        System.debug('CopadoRallyReleasesBatch Number of object in scope ' + scope.size());
        // Iterate through Releases and perform processing/synchronization     
        this.releasesToUpsert = new List<copado__Release__c>();
        for (Object reItem : scope) {
            copado__Release__c sobj = (copado__Release__c) reItem;
            releasesToUpsert.add(sobj);
        }
        
        try {
            if(Test.isRunningTest()){
    			upsert releasesToUpsert External_Id__c;
			} else {
            	//performs upsert based on External Id
            	Database.upsert(releasesToUpsert, copado__Release__c.External_Id__c, AccessLevel.USER_MODE);
            }     
        } catch (DmlException ex) {
            System.debug('CopadoRallyReleasesBatch dml exception==> ' + ex.getMessage());
        }
    }

    // Finish method for the batch job
    public void finish(Database.BatchableContext context) {
        // Start the next batch - CopadoRallyIterationsBatch
        System.debug('CopadoRallyReleasesBatch Batch finish ');
        CopadoRallyIterationsBatch sprintsBatch = new CopadoRallyIterationsBatch(this.gProject, this.includeSprint);
        Database.executeBatch(sprintsBatch);
    }
}