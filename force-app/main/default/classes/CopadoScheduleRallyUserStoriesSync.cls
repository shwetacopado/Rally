/**
 * Class to schedule User Story fetch jobs.
 *
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class CopadoScheduleRallyUserStoriesSync implements Schedulable {
    //private Id prjId; 
    
    //private Id rallyIntegrationId;
    
    // Default cron expression for scheduling
    private final String defaultCronExp = '0 0 12 * * ?';
    
    private copado__Project__c project;
    
    // Copado Rally integration record
    private Copado_Rally_Integration__c rallyIntegration;
    
    // Should include iteration.
    private Boolean includeIteration;
    
    
    public CopadoScheduleRallyUserStoriesSync(copado__Project__c projectObj, Boolean includeIteration) {
        
        this.includeIteration = includeIteration;
        
        // Get the related project record
        if(projectObj != null){
            this.project = projectObj;
            this.rallyIntegration = projectObj.Copado_Rally_Integration_Setting__r;
        }else{
            System.debug('Project is not defined.');
        }

        // Check that a valid integration record was retrieved
        if (this.rallyIntegration == null) {
            System.debug('Could not find Copado Rally Integration Settings associated with project ' + this.project.Name);
            return;
        }
                                        
       // Perform your scheduled processing logic here
       System.debug('Scheduling job for project ' + project.Name);
        
    }

    public CopadoScheduleRallyUserStoriesSync(Id projectId, Boolean includeIteration) {
        
        this.includeIteration = includeIteration;
        // Get the related project record
        // Initialize the rallyIntegration variable by querying for the integration record
        copado__Project__c proj = [SELECT Id, Name, External_Id__c, Workspace_Id__c, Copado_Rally_Integration_Setting__r.Name, Copado_Rally_Integration_Setting__r.Named_Credential__c, Copado_Rally_Integration_Setting__r.Is_Rally_Sync_Running__c, Copado_Rally_Integration_Setting__r.Last_Sync_Time__c
                    FROM copado__Project__c 
                    WHERE Id = :projectId WITH USER_MODE LIMIT 1];
        
        if (proj == null) {
            System.debug('Could not find project.');
            return;
        }else{
            this.project = proj;
            // Check that a valid integration record was retrieved
            if (this.project.Copado_Rally_Integration_Setting__r == null) {
                System.debug('Could not find Copado Rally Integration Settings ' + this.project.Name);
                return;
            }else{
                this.rallyIntegration = proj.Copado_Rally_Integration_Setting__r;
                
            }
            
        } 

        // Perform your scheduled processing logic here
        System.debug('Scheduling job for project ' + this.project.Name);
        
    }
    
    public String scheduleRallyUserStoriesSync(CopadoScheduleRallyUserStoriesSync scheduledClass, String cronExp, Boolean includeIteration) {
        
        String scheduleJobId;
        if(String.isBlank(cronExp)){
            // if no value is provided for cronExp then the sync will happen everyday at 12pm
            cronExp = defaultCronExp;
        }
        this.includeIteration = includeIteration;
        try{
            scheduleJobId = system.schedule('Scheduled User Story and Iteration sync..', cronExp, scheduledClass);

            return scheduleJobId;
        }
        catch(Exception ex){
            //throw new Exception('ERROR Processing integration' + ex);
            System.debug('ERROR Processing integration' + ex);
        }
        
        System.debug('Scheduling job for project ' + this.project.Name);
        return scheduleJobId;
    }
    
    public void execute(SchedulableContext sc) {
        if(this.rallyIntegration != null){
            Boolean isRunning = this.rallyIntegration.Is_Rally_Sync_Running__c;
            if(isRunning){
                throw new ScheduleUserStoriesException('The job is already running!');
            }else{
                //this.rallyIntegration.Is_Rally_Sync_Running__c = true;
                Copado_Rally_Integration__c intUpd = this.rallyIntegration;
                intUpd.Is_Rally_Sync_Running__c = true;
                update intUpd;
            }
           
        }
        
        if(includeIteration){
            Database.executeBatch(new CopadoRallyReleasesBatch(this.project, true));
        }else{
            Database.executeBatch(new CopadoRallyUserStoryBatch(this.project));
        }
        
        
    }
    public class ScheduleUserStoriesException extends Exception {}
}