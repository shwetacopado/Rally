/**
 * Utilitiy class for Copado Rally Integration.
 *
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class CopadoRallyUtilities {
    
    //casts value based on the current sObject field 
    public static Object returnCastedValue(Object param, String fieldName, String objectType) {
        if (null != param) {
            Schema.SObjectField field;
            if(objectType == CopadoRallyConstants.OBJECT_TYPE_RELEASE){
                field = releaseFieldsMap.get(fieldName);
            } 
            if(objectType == CopadoRallyConstants.OBJECT_TYPE_SPRINT){
                field = sprintFieldsMap.get(fieldName); 
            }
            if(objectType == CopadoRallyConstants.OBJECT_TYPE_USERSTORY){
                field = userStoryFieldsMap.get(fieldName);
            }
            if(field == null){
                System.debug(LoggingLevel.WARN,'The field ' + fieldName + ' does not exist in the ' + objectType + ' object.');
                return null;
            }
            String FldType = String.valueOf(field.getDescribe().getType()).toLowerCase();
            if (FldType == 'textarea' || FldType == 'picklist' || fldType == 'reference' || FldType == 'multipicklist') {
                FldType = 'string';
            }
            if (FldType == 'boolean') { 
                return Boolean.valueOf(param);
            } else if (FldType == 'string') {
                return String.valueOf(param);
            } else if (FldType == 'blob') {
                return (Blob) param;
            } else if (FldType == 'date') {
                return Date.valueOf(applySalesforceDateFormatString(param));
            } else if (FldType == 'datetime') {
                return Datetime.valueOf(applySalesforceDateTimeFormatString(param));
            } else if (FldType == 'time') {
                return (Time) param;
            } else if (FldType == 'integer') {
                return Integer.valueOf(param);
            } else if (FldType == 'long') {
                return (Long) param;
            } else if (FldType == 'decimal') {
                return (Decimal) param;
            } else if (FldType == 'double') {
                return Double.valueOf(param);
            }
        }
        return null;
    }

    //Map to use on dynamic cast logic
    private static Map<String, Schema.SObjectField> userStoryFieldsMap;
    static {
        userStoryFieldsMap = Schema.SObjectType.copado__User_Story__c.fields.getMap();
    }

    //Map to use on dynamic cast logic
    private static Map<String, Schema.SObjectField> releaseFieldsMap;
    static {
        releaseFieldsMap = Schema.SObjectType.copado__Release__c.fields.getMap();
    }

    //Map to use on dynamic cast logic
    private static Map<String, Schema.SObjectField> sprintFieldsMap;
    static {
        sprintFieldsMap = Schema.SObjectType.copado__Sprint__c.fields.getMap();
    }

    public static DateTime DateTimeStringValid(String input) {
        DateTime parsedDateTime;
        
        try {
            String[] dateTimeComponents = input.split('T');
            
            if (dateTimeComponents.size() == 2) {
                String dateString = dateTimeComponents[0];
                String timeString = dateTimeComponents[1].replace('Z', '');
                
                List<String> dateComponents = dateString.split('-');
                List<String> timeComponents = timeString.split(':');
                
                if (dateComponents.size() == 3 && timeComponents.size() >= 2) {
                    Integer year = Integer.valueOf(dateComponents[0]);
                    Integer month = Integer.valueOf(dateComponents[1]); 
                    Integer day = Integer.valueOf(dateComponents[2]);
                    Integer hours = Integer.valueOf(timeComponents[0]);
                    Integer minutes = Integer.valueOf(timeComponents[1]);
                    
                    parsedDateTime = DateTime.newInstanceGmt(year, month, day, hours, minutes, 0);
                    
                }
            }
        } catch (Exception e) {
            // DateTime parsing failed, so input is not a valid DateTime
        }
        
        return parsedDateTime;
    }
	
    public static User findActiveUserByEmail(String email) {
        List<User> activeUsers = [SELECT Id, FirstName, LastName, Email 
                                  FROM User 
                                  WHERE Email = :email AND IsActive = true LIMIT 1];
        
        if (activeUsers.size() > 0) {
            return activeUsers[0];
        } else {
            return null; // No active user found with the provided email
        }
    }

    private static String applySalesforceDateFormatString(Object param) {
        return String.valueOf(param).replace('Z', '+0000');
    }
    private static String applySalesforceDateTimeFormatString(Object param) {
        return String.valueOf(param).replace('T', ' ');
    }

    public static String replaceFromCurly(String strwcurly) {
        return strwcurly.replace('lcurly', '{').replace('rcurly', '}');
    }
    public static String escapeDoubleQuotes(String value) {
        return value.replace('"', '\\"');
    }

}