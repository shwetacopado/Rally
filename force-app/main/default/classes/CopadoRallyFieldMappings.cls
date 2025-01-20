/**
 * Class for Copado Rally Field Mapping.
 * 
 * 
 * @author Ajay Sahu
 * @version 1.0
 */
public class CopadoRallyFieldMappings {

    //Field mapping values between Copado User Story and Rally Hierarchicalrequirement fields
    public static Map<String, String> returnUserStoryFieldMap() {
        Map<String, String> fieldMap;
        if (null == fieldMap) {
            fieldMap = new Map<String, String>();
            fieldMap.put('External_Id__c', 'ObjectID');
            fieldMap.put('copado__User_Story_Title__c', 'Name');
            fieldMap.put('copado__Functional_Specifications__c', 'Description');
            fieldMap.put('copado__Status__c', 'ScheduleState');
            fieldMap.put('copado__Project__c', 'Project');
            fieldMap.put('copado__Story_Points_Other__c', 'PlanEstimate');
            fieldMap.put('copado__Sprint__c', 'Iteration');
            fieldMap.put('copado__Release__c', 'Release');
            fieldMap.put('copado__Developer__c', 'Owner');
            fieldMap.put('Notes__c', 'Notes');
            
        }
        return fieldMap;
    }
    
    public static Map<String, String> returnUpdateUserStoryFieldMap() {
        Map<String, String> fieldMap;
        if (null == fieldMap) {
            fieldMap = new Map<String, String>();
            fieldMap.put('copado__Status__c', 'ScheduleState'); 
            fieldMap.put('Notes__c', 'Notes');
            
        }
        return fieldMap;
    }
    
    //Field mapping values between Copado Release and Rally Release fields
    //ObjectID,Name,State,ReleaseDate,ReleaseStartDate,PlannedVelocity,Description,LastUpdateDate,CreationDate
    public static Map<String, String> returnReleaseFieldMap() {
        Map<String, String> fieldMap;
        if (null == fieldMap) {
            fieldMap = new Map<String, String>();
            fieldMap.put('External_Id__c', 'ObjectID');
            fieldMap.put('Name', 'Name');
            fieldMap.put('copado__Status__c', 'State');
            fieldMap.put('copado__Project__c', 'Project');
            fieldMap.put('copado__Planned_Date__c', 'ReleaseDate');
            
        }
        return fieldMap;
    }
    
    //Field mapping values between Copado Sprint and Rally Iteration fields
    //ObjectID,Name,State,PlanEstimate,Notes,StartDate,Release,LastUpdateDate,CreationDate,EndDate
    public static Map<String, String> returnIterationFieldMap() {
        Map<String, String> fieldMap;
        if (null == fieldMap) {
            fieldMap = new Map<String, String>();
            fieldMap.put('External_Id__c', 'ObjectID');
            fieldMap.put('Name', 'Name');
            fieldMap.put('copado__Status__c', 'State');
            fieldMap.put('copado__Project__c', 'Project');
            fieldMap.put('copado__Start_Date__c', 'StartDate');
            fieldMap.put('copado__End_Date__c', 'EndDate');           
        }
        return fieldMap;
    }
        
}