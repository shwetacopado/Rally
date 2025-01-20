public with sharing class CopadoMockHttpResponseGenerator {
    
    // Create a mock response with the provided JSON body and status code for release. 
    private static String responseBodyRelease = '{' +
    '"QueryResult": {' +
        '"Errors": [],' +
        '"Warnings": [],' +
        '"TotalResultCount": 1,' +
        '"StartIndex": 1,' +
        '"PageSize": 1,' +
        '"Results": [' +
            '{' +
                '"CreationDate": "2021-09-08T18:02:53.831Z",' +
                '"ObjectID": 608775943679,' +
                '"Name": "Release 05",' +
                '"PlannedVelocity": 3.5,' +
                '"State": "Accepted",' +
                '"ReleaseDate": "2018-10-01T03:59:59.000Z",'+
                '"ReleaseStartDate": "2018-07-01T04:00:00.000Z",'+
                '"_type": "Release"' +
            '}' +
        ']' +
    '}' +
    '}';

    // Create a mock response with the provided JSON body and status code for release. 
    private static String responseBodyReleaseError = '{' +
    '"QueryResult": {' +
        '"Errors": ["This is Test Error"],' +
        '"Warnings": ["This is Test Warninhg"],' +
    '}';

    // Create a mock response with the provided JSON body and status code for Iteration. 
    private static String responseBodyIteration = '{' +
    '"QueryResult": {' +
        '"Errors": [],' +
        '"Warnings": [],' +
        '"TotalResultCount": 1,' +
        '"StartIndex": 1,' +
        '"PageSize": 1,' +
        '"Results": [' +
            '{' +
                '"CreationDate": "2021-09-08T18:02:53.831Z",' +
                '"ObjectID": 608775943680,' +
                '"Name": "Iteration 108",' +
                '"Notes": "",' +
                '"PlanEstimate": null,' +
                '"State": "Planning",' +
                '"_type": "Iteration"' +
            '}' +
        ']' +
    '}' +
    '}';

    // Create a mock response with the provided JSON body and status code for Iteration. 
    private static String responseBodyIterationError = '{' +
    '"QueryResult": {' +
        '"Errors": ["This is Test Error"],' +
        '"Warnings": ["This is Test Warninhg"],' +
    '}';

    // Create a mock response with the provided JSON body and status code for User Story. 
    private static String responseBodyUserStory = '{'+
        '"QueryResult": {'+
            '"Errors": [],'+
            '"Warnings": [],'+
            '"TotalResultCount": 1,'+
            '"StartIndex": 1,'+
            '"PageSize": 1,'+
            '"Results": ['+
                '{'+
                    '"CreationDate": "2023-08-28T13:49:35.668Z",'+
                    '"_CreatedAt": "Aug 28",'+
                    '"ObjectID": 720653152997,'+
                    '"Description": "",'+
                    '"FormattedID": "US5213832",'+
                    '"DirectChildrenCount": 0,'+
                    '"LastUpdateDate": "2023-08-30T15:09:14.640Z",'+
                    '"Name": "Access Management: Security Template for New Projects",'+
                    '"Notes": "",'+
                    '"Owner": {'+
                        '"ObjectID": 720672541929,'+
                        '"EmailAddress": "demouser90903289232783438@test.com",'+
                        '"_type": "User"'+
                    '},'+
                    '"ScheduleState": "In-Progress",'+
                    '"Blocked": false,'+
                    '"Defects": {'+
                        '"_type": "Defect",'+
                        '"Count": 0'+
                    '},'+
                    '"Iteration": {'+
                        '"CreationDate": "2023-06-12T16:11:43.510Z",'+
                        '"_CreatedAt": "Jun 12",'+
                        '"ObjectID": 608775943680,'+
                        '"Name": "Iteration 196",'+
                        '"Notes": "",'+
                        '"PlanEstimate": 8.0,'+
                        '"State": "Planning",'+
                        '"_type": "Iteration"'+
                    '},'+
                    '"PlanEstimate": 5.0,'+
                    '"Release": {'+
                        '"ObjectID": 608775943679,'+
                        '"Name": "2023 Q3",'+
                        '"Notes": "",'+
                        '"PlanEstimate": 9.0,'+
                        '"State": "Planning",'+
                        '"_type": "Release"'+
                    '},'+
                    '"Project": {'+
                        '"_refObjectName": "CRM DevOps",'+
                        '"_type": "Project"'+
                    '},'+
                    '"_type": "HierarchicalRequirement"'+
                '}'+
            ']'+
        '}'+
    '}';

     // Create a mock response with the provided JSON body and status code for User Story. 
     private static String responseBodyUserStoryError = '{' +
     '"QueryResult": {' +
         '"Errors": ["This is Test Error"],' +
         '"Warnings": ["This is Test Warninhg"],' +
     '}';

    Integer statusCode = 200;
    String status = 'OK';
    Map<String, String> headers = new Map<String, String>{
    'Content-Type' => 'application/json'
    };
    
    public static HttpResponse generateReleaseMockHttpResponse(Integer statusCode, String status, String responseBody, Map<String, String> headers) {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(statusCode);
        mockResponse.setStatus(status);

        if(String.isEmpty(responseBody)){
            mockResponse.setBody(responseBodyRelease);
        }else{
            mockResponse.setBody(responseBody);
        }

        if (headers != null) {
            for (String key : headers.keySet()) {
                mockResponse.setHeader(key, headers.get(key));
            }
        }

        return mockResponse;
    }

    public static HttpResponse generateSprintMockHttpResponse(Integer statusCode, String status, String responseBody, Map<String, String> headers) {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(statusCode);
        mockResponse.setStatus(status);
        if(String.isEmpty(responseBody)){
            mockResponse.setBody(responseBodyIteration);
        }else{
            mockResponse.setBody(responseBody);
        }

        if (headers != null) {
            for (String key : headers.keySet()) {
                mockResponse.setHeader(key, headers.get(key));
            }
        }

        return mockResponse;
    }

    public static HttpResponse generateUserStoryMockHttpResponse(Integer statusCode, String status, String responseBody, Map<String, String> headers) {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(statusCode);
        mockResponse.setStatus(status);
        if(String.isEmpty(responseBody)){
            mockResponse.setBody(responseBodyUserStory);
        }else{
            mockResponse.setBody(responseBody);
        }
        

        if (headers != null) {
            for (String key : headers.keySet()) {
                mockResponse.setHeader(key, headers.get(key));
            }
        }

        return mockResponse;
    }

}