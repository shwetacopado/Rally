/*
 * CopadoRallyPromotedUSService is a class designed to update the notes of User Stories in Salesforce that have been promoted.
 * It contains two methods: updatePromotedUserStoryNotes and updateUserStoryNotes.
 * 
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class CopadoRallyPromotedUSService {
    /*
    * This method is invoked from a Process Builder or Flow. It processes a list of promotions.
    * For each promotion, it retrieves all related promoted user stories and updates their notes.
    */
    @invocableMethod(label='Update Promoted User Story Notes Del')
    public static void updatePromotedUserStoryNotes(List<List<copado__Promotion__c>> promotions) {
        System.debug('Promotions to process >>  ' + promotions.size());
        
        List<copado__Promotion__c> allPromotions = new List<copado__Promotion__c>();
        for (List<copado__Promotion__c> relpromotion : promotions) {
            allPromotions.addAll(relpromotion);
        }
        
        List<copado__Promoted_User_Story__c> promotedUSs = [
            SELECT Id, Name, copado__Status__c,copado__User_Story__c, copado__Promotion__r.Name, copado__Promotion__r.Id, copado__User_Story__r.Notes__c, copado__Promotion__r.copado__Status__c, copado__Promotion__r.copado__Source_Environment__r.Name, copado__Promotion__r.copado__Destination_Environment__r.Name
            FROM copado__Promoted_User_Story__c 
            WHERE copado__Promotion__r.Id IN :allPromotions AND copado__Status__c = 'Active' WITH USER_MODE 
        ];
        
        updateUserStoryNotes(promotedUSs);
    }
    
    /*
    * This method updates the notes of a list of promoted user stories.
    * It appends a string containing the promotion name and a link to the promotion record in Salesforce to the existing notes.
    */
    public static void updateUserStoryNotes(List<copado__Promoted_User_Story__c> promotedUSs){
        if(promotedUSs != null){
            List<copado__User_Story__c> userStoriesToUpdate = new List<copado__User_Story__c>();
            for(copado__Promoted_User_Story__c promotedUS : promotedUSs){
                copado__User_Story__c userStory = promotedUS.copado__User_Story__r;
                
                String sourceStr = (String) promotedUS.copado__Promotion__r.copado__Source_Environment__r.Name;
                String destinationStr = (String) promotedUS.copado__Promotion__r.copado__Destination_Environment__r.Name;

                
                String notesStr = '<br></br><p>' + DateTime.now() + '  Promotion ' + promotedUS.copado__Promotion__r.Name + ' ' + promotedUS.copado__Promotion__r.copado__Status__c + ' From Source Environment: ' + sourceStr + ' To Destination Enviroment: '+ destinationStr + '</p>';
                notesStr = notesStr + getPromotionURL(promotedUS.copado__Promotion__r.Id); 
                if(userStory.Notes__c != null){
                    userStory.Notes__c = userStory.Notes__c + notesStr;
                }else{
                    userStory.Notes__c = notesStr;
                }
                

                userStoriesToUpdate.add(userStory);
            }
            
            try {
                List<Database.SaveResult> sr = Database.update( userStoriesToUpdate, false, AccessLevel.USER_MODE);
            } catch (QueryException qe) {
                Map<String, Set<String>> inaccessibleFields = qe.getInaccessibleFields();
                System.debug(LoggingLevel.WARN, 'User Story Fields not Accissible  ' + inaccessibleFields);
                
            }
        }
    }
    
    public static String getPromotionURL(String recordId){
        
        // Get the base URL for your Salesforce instance
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
		String objectApiName = 'copado__Promotion__c';
        // Create the record URL
        String recordUrl = baseUrl + '/' + objectApiName + '/' + recordId;
        
        return generateHyperlinkMarkup(recordUrl, recordUrl);
        
    }
    
    public static String generateHyperlinkMarkup(String url, String linkText) {
        String hyperlinkMarkup = '<a href="' + url + '" target="_blank">' + linkText + '</a>';
        return hyperlinkMarkup;
    }
    
}