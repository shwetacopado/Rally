/**
 * Contacts class for Copado Rally Integration.
 *
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public class CopadoRallyConstants {
    
    public static final String ESCAPED_SINGLE_QUOTE = '\'';
    public static final String STATUS = 'status';
    public static final String ASSIGNEE = 'assignee';
    public static final String KEY_STRING = 'key';
    public static final String TOTAL_STRING = 'total';
    public static final String SPRINTS_STRING = 'sprints';
    public static final String EMAIL_ADDRESS = 'emailAddress';
    public static final String VALUE_KEYWORD = 'value';
    public static final String ENCODING_TYPE = 'UTF-8'; 

    //integer
    public static final Integer PAGE_SIZE = 200;

    //field apis
    public static final String COPADO_STATUS = 'copado__Status__c';
    public static final String ENABLE_LOGS = 'Enable_Logs__c';
    
    public static final String SPRINT_ENDPOINT = '/slm/webservice/v2.0/iteration';
    public static final String RELEASE_ENDPOINT = '/slm/webservice/v2.0/release';
    public static final String USERSTORY_ENDPOINT = '/slm/webservice/v2.0/hierarchicalrequirement';
    public static final String DEFECTS_ENDPOINT = 'slm/webservice/v2.0/defect';
    
    public static final String PROJECT_STR = 'project';
    public static final String WORKSPACE_STR = 'workspace';
    public static final String FETCH_STR = 'fetch';
    public static final String PROJECT_SCOPE_UP = 'projectScopeUp';
    public static final String PROJECT_SCOPE_DOWN = 'projectScopeDown';
    public static final String PAGESIZE = 'pagesize';

    
    public static final String OBJECTID = 'ObjectID';
    public static final String ORDER_QUERY ='ObjectID Desc';
    public static final String USERTSTORY_FETCH ='FormattedID,ObjectID,Name,State,Description,ScheduleState,PlanEstimate,Notes,CreationDate,LastUpdateDate,Defects,Release,Iteration,Owner,EmailAddress';
    public static final String RELEASE_FETCH ='ObjectID,Name,State,ReleaseDate,ReleaseStartDate,PlannedVelocity,Description,LastUpdateDate,CreationDate';
    public static final String ITERATION_FETCH ='ObjectID,Name,State,PlanEstimate,EndDate,StartDate,Notes,LastUpdateDate,CreationDate';
    
    public static final String OBJECT_TYPE_USERSTORY ='UserSory';
    public static final String OBJECT_TYPE_RELEASE ='Release';
    public static final String OBJECT_TYPE_SPRINT ='Iteration';
    public static final String OBJECT_TYPE_OWNER ='Owner';
    
    public static final String METHOD_GET ='GET';
    public static final String METHOD_POST ='POST';

   
}