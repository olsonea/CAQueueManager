//Comments

@isTest
private class Queue_Manager_Test 
{
	/*static testMethod void queueAssignTest() 
	{
		Queue_Manager_TestData.createTestData();
		
		BMCServiceDesk__Incident__c createInc = [select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Incident__c LIMIT 1];
		Queue_Manager_Mapping__c createQMM = 
			[select Id, Queue_Id__c, User__c from Queue_Manager_Mapping__c where Queue_Id__c = :createInc.OwnerId LIMIT 1];
		
		System.assertEquals(createInc.Queue_Manager__c,createQMM.User__c);
		
		
		
		Queue_Manager_TestData.updateTestData();
		
		BMCServiceDesk__Incident__c updateInc = [select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Incident__c LIMIT 1];
		Queue_Manager_Mapping__c updateQMM = 
			[select Id, Queue_Id__c, User__c from Queue_Manager_Mapping__c where Queue_Id__c = :updateInc.OwnerId LIMIT 1];
		
		System.assertEquals(updateInc.Queue_Manager__c,updateQMM.User__c);
		
	}*/
	
	static testMethod void queueAssignOnIncidentInsert()
	{
		Test.startTest();
		BMCServiceDesk__Incident__c incident = Queue_Manager_TestDataFactory.createIncident();
		system.assertNotEquals(null, incident.id);
		Test.stopTest();
		
		List<BMCServiceDesk__Incident__c> assertIncident = 
			[select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Incident__c where Id = :incident.id];
		System.assertNotEquals(null,assertIncident);
			
		Map<Id, Queue_Manager_Mapping__c> queueManagerMapByQueueId = Queue_Manager_TestDataFactory.getQueueManagerMapByQueueId();
		System.assertNotEquals(null,queueManagerMapByQueueId);
		
		Queue_Manager_Mapping__c assertQueueManager = queueManagerMapByQueueId.get(assertIncident[0].OwnerId);
			
		System.assertEquals(assertIncident[0].Queue_Manager__c, assertQueueManager.User__c);
	}
	
	static testMethod void queueAssignOnIncidentUpdate()
	{
		BMCServiceDesk__Incident__c incident = Queue_Manager_TestDataFactory.createIncident();
		system.assertNotEquals(null, incident);
		List<Group> queues = [select id from group];
		
		Test.startTest();
		incident.ownerId = queues[1].id;
		try
		{
			update incident;
		}
		catch(Exception e)
        {/*TODO: implement errorLogging*/}
		Test.stopTest();
		
		BMCServiceDesk__Incident__c assertIncident = 
			[select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Incident__c LIMIT 1];
			
		Queue_Manager_Mapping__c assertQueueManager = 
			[select Id, Queue_Id__c, User__c from Queue_Manager_Mapping__c where OwnerId = :assertIncident.OwnerId LIMIT 1];
			
		System.assertEquals(assertIncident.Queue_Manager__c,assertQueueManager.User__c);
	}
	
	static testMethod void adminUITest() 
	{
	
		//Queue_Manager_TestData.createTestData();
		Map<Id,Queue_Manager_Mapping__c> queueManagerMapByQueueId = Queue_Manager_TestDataFactory.getQueueManagerMapByQueueId();
		
		if(queueManagerMapByQueueId.IsEmpty())
		{
			List<Queue_Manager_Mapping__c> queueManagerMappings = Queue_Manager_TestDataFactory.createQueueManagerMappings();	
		}
		
		Queue_Manager_Controller qmc = new Queue_Manager_Controller ();
		
		List<SelectOption> qSelectOptions =  qmc.getQueueSelOpts();
		
		List<SelectOption> qAllSelectOptions =  qmc.getAllQueueSelOpts();
		
		qmc.save();
		
		qmc.qmId = qmc.queueManagers[0].Id;
		qmc.delQM();
		
	}
	
	static testMethod void testInitializeQueues()
	{
		Map<Id,Queue_Manager_Mapping__c> queueManagerMapByQueueId = Queue_Manager_TestDataFactory.getQueueManagerMapByQueueId();
		
		if(queueManagerMapByQueueId.IsEmpty())
		{
			List<Queue_Manager_Mapping__c> queueManagerMappings = Queue_Manager_TestDataFactory.createQueueManagerMappings();	
		}
		
		Queue_Manager_Controller queueManagerController = new Queue_Manager_Controller ();
		
		Test.StartTest();
		queueManagerController.initializeQueues();
		Test.StopTest();
		
		List <QueueSObject> assertQueueSObject = [select queueId, sObjectType from QueueSObject where sObjectType = 'Queue_Manager_Mapping__c'];
		List <Queue_Manager_Mapping__c> assertQueueMappings = [select Id, Queue_Id__c from Queue_Manager_Mapping__c];
		
		system.AssertEquals(assertQueueSObject.size(), assertQueueMappings.size());
	}
	
	static testMethod void queueAssignOnProblemInsert()
	{
		Test.startTest();
		BMCServiceDesk__Problem__c problem = Queue_Manager_TestDataFactory.createProblem();
		system.assertNotEquals(null, problem.id);
		Test.stopTest();
		
		List<BMCServiceDesk__Problem__c> assertProblem = 
			[select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Problem__c where Id = :problem.id];
		System.assertNotEquals(null,assertProblem);
			
		Map<Id, Queue_Manager_Mapping__c> queueManagerMapByQueueId = Queue_Manager_TestDataFactory.getQueueManagerMapByQueueId();
		System.assertNotEquals(null,queueManagerMapByQueueId);
		
		Queue_Manager_Mapping__c assertQueueManager = queueManagerMapByQueueId.get(assertProblem[0].OwnerId);
			
		System.assertEquals(assertProblem[0].Queue_Manager__c, assertQueueManager.User__c);
	}
	
	static testMethod void queueAssignOnProblemUpdate()
	{
		BMCServiceDesk__Problem__c problem = Queue_Manager_TestDataFactory.createProblem();
		List<Group> queues = [select id from group];
		Map<Id,Queue_Manager_Mapping__c> queueManagerMap = Queue_Manager_TestDataFactory.getQueueManagerMapByQueueId();
		
		Id newQueueId;
		
		for(Id queueId :queueManagerMap.keySet())
		{
			if(queueId != problem.ownerId)
			{
				newQueueId = queueId;
				break;
			}
		}
		
		
		Test.startTest();
		//problem.ownerId = queues[1].id;
		problem.ownerId = newQueueId;
		
		update problem;
		
		try
		{
			//update problem;
		}
		catch(Exception e)
        {/*TODO: implement errorLogging*/}
        
		Test.stopTest();
		
		BMCServiceDesk__Problem__c assertProblem = 
			[select Id, OwnerId, Queue_Manager__c from BMCServiceDesk__Problem__c LIMIT 1];
		
		system.assertNotEquals(assertProblem.ownerId, queues[1].id);
			
		Queue_Manager_Mapping__c assertQueueManager = 
			[select Id, Queue_Id__c, User__c from Queue_Manager_Mapping__c where OwnerId = :assertProblem.OwnerId LIMIT 1];
			
		System.assertEquals(assertProblem.Queue_Manager__c,assertQueueManager.User__c);
	}
	
}