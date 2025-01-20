/**
 * This class parse the Rally Iteration Object JOSN String.
 *
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class CopadoRallySprintJParser {
    	
	public class QueryResult {
		public List<String> Errors {get;set;} 
		public List<String> Warnings {get;set;} 
		public Integer TotalResultCount {get;set;} 
		public Integer StartIndex {get;set;} 
		public Integer PageSize {get;set;} 
		public List<Results> Results {get;set;} 

		public QueryResult(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Errors') {
							Errors = arrayOfString(parser);
						} else if (text == 'Warnings') {
							Warnings = arrayOfString(parser);
						} else if (text == 'TotalResultCount') {
							TotalResultCount = parser.getIntegerValue();
						} else if (text == 'StartIndex') {
							StartIndex = parser.getIntegerValue();
						} else if (text == 'PageSize') {
							PageSize = parser.getIntegerValue();
						} else if (text == 'Results') {
							Results = arrayOfResults(parser);
						} else {
							//System.debug(LoggingLevel.WARN, 'QueryResult consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public QueryResult QueryResult {get;set;} 

	public CopadoRallySprintJParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'QueryResult') {
						QueryResult = new QueryResult(parser);
					} else {
						//System.debug(LoggingLevel.WARN, 'CopadoRallySprintJParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Results {
		public String x_ref {get;set;} // in json: _ref
		public String x_refObjectUUID {get;set;} // in json: _refObjectUUID
		public String x_objectVersion {get;set;} // in json: _objectVersion
		public String x_refObjectName {get;set;} // in json: _refObjectName
		public String CreationDate {get;set;} 
		public String x_CreatedAt {get;set;} // in json: _CreatedAt
		public String ObjectID {get;set;} 
		public String EndDate {get;set;} 
		public String Name {get;set;} 
		public String Notes {get;set;} 
		public String PlanEstimate {get;set;} 
		public String StartDate {get;set;} 
		public String State {get;set;} 
		public String x_type {get;set;} // in json: _type

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '_ref') {
							x_ref = parser.getText();
						} else if (text == '_refObjectUUID') {
							x_refObjectUUID = parser.getText();
						} else if (text == '_objectVersion') {
							x_objectVersion = parser.getText();
						} else if (text == '_refObjectName') {
							x_refObjectName = parser.getText();
						} else if (text == 'CreationDate') {
							CreationDate = parser.getText();
						} else if (text == '_CreatedAt') {
							x_CreatedAt = parser.getText();
						} else if (text == 'ObjectID') {
							ObjectID = parser.getText();
						} else if (text == 'EndDate') {
							EndDate = parser.getText();
						} else if (text == 'Name') {
							Name = parser.getText();
						} else if (text == 'Notes') {
							Notes = parser.getText();
						} else if (text == 'PlanEstimate') {
							PlanEstimate = parser.getText();
						} else if (text == 'StartDate') {
							StartDate = parser.getText();
						} else if (text == 'State') {
							State = parser.getText();
						} else if (text == '_type') {
							x_type = parser.getText();
						} else {
							//System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static CopadoRallySprintJParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CopadoRallySprintJParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    private static List<Results> arrayOfResults(System.JSONParser p) {
        List<Results> res = new List<Results>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Results(p));
        }
        return res;
    }
}