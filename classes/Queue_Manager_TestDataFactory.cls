@isTest
public class Queue_Manager_TestDataFactory
{
    static final string INCIDENT_OBJECT_API_NAME = 'BMCServiceDesk__Incident__c';
    static final string PROBLEM_OBJECT_API_NAME = 'BMCServiceDesk__Problem__c';
    static final string QUEUE_MANAGER_MAPPING_OBJECT_API_NAME = 'Queue_Manager_Mapping__c';
    
    public static List<Group> createQueues()
    {
        //TODO: Add Assertions
        
        List<Group> newGroupList = new List<Group>();
        
        for(integer i=0; i<5; i++)
        {
            Group newGroup = new Group
            (
                Name = 'TestQueue' + i,
                Type = 'Queue',
                DeveloperName = 'TestQueue' + i
            );
            
            newGroupList.add(newGroup);
        }
        
        try
        {
            insert newGroupList;
        }
        catch(Exception e)
        {/*TODO: implement errorLogging*/}
		
		List<String> objects = new List<String>{INCIDENT_OBJECT_API_NAME, PROBLEM_OBJECT_API_NAME};
		
		List<QueuesObject> newQueueSObjectList = new List<QueuesObject>();
		
		System.runAs (new User(Id=UserInfo.getUserId())) 
		{
		    for(String obj :objects)
		    {
		        for(Group queue :newGroupList)
		        {
		            QueuesObject newQueueSObject = new QueueSObject
		            (
		                queueid = queue.id,
		                sobjectType = obj
		            );
		            
		            newQueueSObjectList.add(newQueueSObject);
		        }
		    }
		    
		    for(integer i=0; i < 2; i++)
		    {
    		    QueuesObject newQueueSObject = new QueueSObject
                (
                    queueid = newGroupList[i].id,
                    sobjectType = QUEUE_MANAGER_MAPPING_OBJECT_API_NAME
                );
                newQueueSObjectList.add(newQueueSObject);
            }
		    
		    try
		    {
		        insert newQueueSObjectList;
	        }
            catch(Exception e)
            {/*TODO: implement errorLogging*/}
		}
		
		return newGroupList;
    }
    
    public static BMCServiceDesk__Category__c createCategory()
    {
        //TODO: Add Assertions
        
        BMCServiceDesk__Category__c testCat = new BMCServiceDesk__Category__c
        (
			BMCServiceDesk__AvailableForIncidents__c=true,
				BMCServiceDesk__UnAvailableForProblems__c=true,
			Name='test category'
		);
		
		try
		{
	    	insert testCat;
    	}
        catch(Exception e)
        {/*TODO: implement errorLogging*/}
        
        return testCat;
    }
    
    public static List<Queue_Manager_Mapping__c> createQueueManagerMappings()
    {
        //TODO: Add Assertions
        
        User testUser = new User(Id=UserInfo.getUserId());
        
        List<Group> queues = createQueues();
        
        List<Queue_Manager_Mapping__c> newQueueManagerMappings = new  List<Queue_Manager_Mapping__c>();
        
        for(integer i =0; i < 2; i++)
        {
            Queue_Manager_Mapping__c testQMM = new Queue_Manager_Mapping__c
            (
    			Queue_Id__c = queues[i].Name,
    			User__c = testUser.Id,
    			OwnerId = queues[i].id,
    			Send_Email_Alerts_to_Queue__c = true
    		);
    		
    		newQueueManagerMappings.add(testQMM);
        }
		
		try
		{
		    insert newQueueManagerMappings;
	    }
	    catch(Exception e)
        {/*TODO: implement errorLogging*/}
        
        return newQueueManagerMappings;
    }
    
    public static Map<Id,Queue_Manager_Mapping__c> getQueueManagerMapByQueueId()
    {
        Map<Id,Queue_Manager_Mapping__c> queueManagerMapByQueueId = new Map<Id,Queue_Manager_Mapping__c>();
        
        List<Queue_Manager_Mapping__c> queueManagerMappings = [select Id, Queue_Id__c, User__c, OwnerId from Queue_Manager_Mapping__c];
        
        for(Queue_Manager_Mapping__c queueManagerMapping :queueManagerMappings)
        {
            queueManagerMapByQueueId.put(queueManagerMapping.OwnerId, queueManagerMapping);
        }
        
        return queueManagerMapByQueueId;
    }
    
    public static BMCServiceDesk__Incident__c createIncident()
    {   
        //TODO: Add Assertions
        
        User testUser = new User(Id=UserInfo.getUserId());
        List<Queue_Manager_Mapping__c> queueManagerMappingList = createQueueManagerMappings();
        BMCServiceDesk__Category__c category = createCategory();
        
        BMCServiceDesk__Incident__c incident = new BMCServiceDesk__Incident__c
        (
			BMCServiceDesk__FKCategory__c = category.id,
			BMCServiceDesk__FKClient__c  = testUser.Id,
			BMCServiceDesk__incidentDescription__c = 'test description',
			OwnerId = queueManagerMappingList[0].OwnerId
		);
		
		try
		{
		    insert incident;
	    }
	    catch(Exception e)
        {/*TODO: implement errorLogging*/}
        system.assertNotEquals(null, incident);
        
        return incident;
    }
}