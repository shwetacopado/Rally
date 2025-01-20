/**
 * This class parse the Rally HierarchicalRequirement Object JOSN String.
 * 
 * package CopadoRallyIntegration
 * @author Ajay Sahu
 * @version 1.0
 * 
 */
public with sharing class CopadoRallyUserStoryJParser {
    
	
	public class Project {
		public String x_ref {get;set;} // in json: _ref
		public String x_refObjectUUID {get;set;} // in json: _refObjectUUID
		public String x_refObjectName {get;set;} // in json: _refObjectName
		public String x_type {get;set;} // in json: _type

		public Project(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '_ref') {
							x_ref = parser.getText();
						} else if (text == '_refObjectUUID') {
							x_refObjectUUID = parser.getText();
						} else if (text == '_refObjectName') {
							x_refObjectName = parser.getText();
						} else if (text == '_type') {
							x_type = parser.getText();
						} else {
							//System.debug(LoggingLevel.WARN, 'Project consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class Defect {
		public String x_ref {get;set;} // in json: _ref
		public String Count {get;set;} 
		public String x_type {get;set;} // in json: _type

		public Defect(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '_ref') {
							x_ref = parser.getText();
						} else if (text == 'Count') {
							Count = parser.getText();
						} else if (text == '_type') {
							x_type = parser.getText();
						} else {
							//System.debug(LoggingLevel.WARN, 'Defect consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
    public class Iteration {
		public String x_ref {get;set;} // in json: _ref
		public String x_type {get;set;} // in json: _type
		public String ObjectID {get;set;}
        public String Name {get;set;}
        public String State {get;set;}
        
		public Iteration(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '_ref') {
							x_ref = parser.getText();
						} else if (text == 'ObjectID') {
							ObjectID = parser.getText();
						}else if (text == 'Name') {
							Name = parser.getText();
						}else if (text == 'State') {
							State = parser.getText();
						} else if (text == '_type') {
							x_type = parser.getText();
						} else {
							//System.debug(LoggingLevel.WARN, 'Defect consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class Release {
		public String ObjectID {get;set;}
        public String Name {get;set;}
        public String State {get;set;}
        
		public Release(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'ObjectID') {
							ObjectID = parser.getText();
						}else if (text == 'Name') {
							Name = parser.getText();
						}else if (text == 'State') {
							State = parser.getText();
						}else {
							//System.debug(LoggingLevel.WARN, 'Defect consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
	public class Owner {
		public String x_ref {get;set;} // in json: _ref
		public String x_refObjectUUID {get;set;} // in json: _refObjectUUID
		public String x_refObjectName {get;set;} // in json: _refObjectName
		public String ObjectID {get;set;} 
		public String x_type {get;set;} // in json: _type

		public Owner(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '_ref') {
							x_ref = parser.getText();
						} else if (text == '_refObjectUUID') {
							x_refObjectUUID = parser.getText();
						} else if (text == '_refObjectName') {
							x_refObjectName = parser.getText();
						} else if (text == 'ObjectID') {
							ObjectID = parser.getText();
						} else if (text == '_type') {
							x_type = parser.getText();
						} else {
							//System.debug(LoggingLevel.WARN, 'Owner consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
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
                    System.debug('text'+text);
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
							System.debug(LoggingLevel.WARN, 'QueryResult consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Results {
		public String x_ref {get;set;} // in json: _ref
		public String x_refObjectUUID {get;set;} // in json: _refObjectUUID
		public String x_refObjectName {get;set;} // in json: _refObjectName
		public String CreationDate {get;set;} 
		public String x_CreatedAt {get;set;} // in json: _CreatedAt
		public String ObjectID {get;set;} 
		public String Description {get;set;} 
		public String FormattedID {get;set;} 
		public Integer DirectChildrenCount {get;set;} 
		public String LastUpdateDate {get;set;} 
		public String Name {get;set;} 
		public String Notes {get;set;} 
		public Owner Owner {get;set;} 
		public String ScheduleState {get;set;} 
		public Boolean Blocked {get;set;} 
		public Double PlanEstimate {get;set;} 
		public Release Release {get;set;}
        public Iteration Iteration {get;set;}
		public Project Project {get;set;}
        public Defect Defects {get;set;} 
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
						} else if (text == '_refObjectName') {
							x_refObjectName = parser.getText();
						} else if (text == 'CreationDate') {
							CreationDate = parser.getText();
						} else if (text == '_CreatedAt') {
							x_CreatedAt = parser.getText();
						} else if (text == 'ObjectID') {
							ObjectID = parser.getText();
						} else if (text == 'Description') {
							Description = parser.getText();
						} else if (text == 'FormattedID') {
							FormattedID = parser.getText();
						} else if (text == 'DirectChildrenCount') {
							DirectChildrenCount = parser.getIntegerValue();
						} else if (text == 'LastUpdateDate') {
							LastUpdateDate = parser.getText();
						} else if (text == 'Name') {
							Name = parser.getText();
						} else if (text == 'Notes') {
							Notes = parser.getText();
						} else if (text == 'Owner') {
							Owner = new Owner(parser);
						} else if (text == 'ScheduleState') {
							ScheduleState = parser.getText();
						} else if (text == 'Blocked') {
							Blocked = parser.getBooleanValue();
						} else if (text == 'PlanEstimate') {
							PlanEstimate = parser.getDoubleValue();
						} else if (text == 'Release') {
							Release = new Release(parser);//parser.readValueAs(Object.class);
						}else if (text == 'Iteration') {
							Iteration = new Iteration(parser);//parser.readValueAs(Object.class);
						} else if (text == 'Project') {
							Project = new Project(parser);
						} else if (text == '_type') {
							x_type = parser.getText();
						}else if (text == 'Defects') {
							Defects = new Defect(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public QueryResult QueryResult {get;set;} 

	public CopadoRallyUserStoryJParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'QueryResult') {
						QueryResult = new QueryResult(parser);

					} else {
						//System.debug(LoggingLevel.WARN, 'CopadoRallyUserStoryJParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static CopadoRallyUserStoryJParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CopadoRallyUserStoryJParser(parser);
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