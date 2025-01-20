@isTest
public with sharing class CopadoScheduleRallyUserStoriesSyncTest {
    

    @isTest
    static void testSchedulingAndExecution() {
        
        User tu = [SELECT Id FROM User WHERE UserName='demouser90903289232783438@test.com' LIMIT 1];

        
        //Copado_Rally_Integration__c testIntegration = createTestIntegration();
        
        System.runAs(tu){

            copado__Project__c testProject = createTestProject();

            // Enqueue the schedulable class
            Test.startTest();
            String cronExp = '0 0 0 1 1 ?'; // Every year on January 1st at midnight
            CopadoScheduleRallyUserStoriesSync scheduledClass = new CopadoScheduleRallyUserStoriesSync(testProject.Id, true);
            String jobId = scheduledClass.scheduleRallyUserStoriesSync(scheduledClass, cronExp, true);
            //String jobId = System.schedule('Test Job', cronExp, testClassInstance);
            Test.stopTest();
            
            // Verify the scheduled job has been enqueued
            System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE Id = :jobId]);

            List<AsyncApexJob> jobInfoLst = [SELECT Status, NumberOfErrors
                                            FROM AsyncApexJob WHERE ApexClass.Name IN ('CopadoRallyReleasesBatch','CopadoRallyIterationsBatch', 'CopadoRallyUserStoryBatch')];

            System.debug('>> jobInfoLst '+ jobInfoLst);
        }       
        
        

    }

    @isTest
    static void testUpdateUserStoryExecution() {

        User tu = [SELECT Id FROM User WHERE UserName='demouser90903289232783438@test.com' LIMIT 1];
        System.runAs(tu){
            copado__User_Story__c us = createTestUserStory();
        
            //List<copado__Project__c> prjs = [SELECT Id, Name, Copado_Rally_Integration_Setting__r.Name FROM copado__Project__c];
            System.debug('copado__Project__c >> ' + us.copado__Project__c);
            
            List<copado__User_Story__c> uslst = new List<copado__User_Story__c>();
            List<List<copado__User_Story__c>> usToUpdate = new List<List<copado__User_Story__c>>();
            uslst.add(us);
            usToUpdate.add(uslst);
            Test.startTest();
            us.copado__Status__c = 'Completed';
            CopadoRallyApi.updateUserStory(usToUpdate);
            update us;
            Test.stopTest();
        }
    }

    private static copado__User_Story__c createTestUserStory(){
        copado__Project__c testProject = createTestProject();

        copado__User_Story__c tus = new copado__User_Story__c();
        tus.copado__Status__c = 'In Progress';
        tus.copado__User_Story_Title__c = 'US-0001';
        tus.copado__Project__c = testProject.Id;
        insert tus;
        return tus;
    }

    private static User createTestUser() {
        // Create Test User
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User testUser = new User(
            ProfileId = p.Id,
            FirstName = 'Demo',
            LastName = 'User',
            Email = 'demouser90903289232783438@test.com',
            Alias = 'demouser',
            Username = 'demouser90903289232783438@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        
        insert testUser;
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Copado_Rally_Integration_PS'];
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
        
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'Copado_User'];
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps2.Id);
        
        return testUser;
    }

    private static copado__Project__c createTestProject() {

        Copado_Rally_Integration__c intSetting = createTestIntegration();
        System.debug('>> '+ intSetting.Name);
        System.debug('>> '+ intSetting.Named_Credential__c);
        copado__Project__c testProject = new copado__Project__c(Name='Test Project');
        testProject.External_Id__c = '4837482390';
        testProject.Workspace_Id__c = '45348958439';
        testProject.Copado_Rally_Integration_Setting__c = intSetting.Id;
                
        insert testProject;
        return testProject;
    }

    private static Copado_Rally_Integration__c createTestIntegration() {
        Copado_Rally_Integration__c testIntegration = new Copado_Rally_Integration__c(Name='Test Integration', Named_Credential__c = 'Test Named Credential');
        insert testIntegration;
        return testIntegration;
    }

    @testSetup 
    static void createTestRecords() {
        createTestUser();
    }

}