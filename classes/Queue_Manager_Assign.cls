public class Queue_Manager_Assign 
{
	static final string QUEUE_MANAGER_API_NAME = 'Queue_Manager__c';
	static final string SEND_EMAIL_ALERTS_TO_QUEUE_API_NAME = 'Send_Email_Alerts_to_Queue__c';
	
	/* This constructor expects a list of sObject records, builds a set of Queues based on the record owner, 
	 * builds a map of Queues and Managers (Users), and sets the Queue Manager field based on the Owner of the sObject.
	 * Assumption: The following setting is enabled in Remedyforce Administration > Application Settings > Record Assignment
	 *	-Enable Queue and User Assignment
	 */
	public Queue_Manager_Assign(List<sObject> sObjectList) 
	{
		System.debug('Entering Queue_Manager_Assign().');
		
		Set<Id> ownerSet = buildOwnerSet(sObjectList);
		Map<Id,Id> queueManagerMap = buildQueueManagerMap(ownerSet);
		Map<Id, boolean> emailAlertMap = buildEmailAlertMap(ownerSet);
		
		for (sObject sObj :sObjectList)
		{
			
			String ownerId = String.valueOf(sObj.get('OwnerId'));
			Id queueManagerId = queueManagerMap.get( ownerId );
			boolean sendEmailAlert = emailAlertMap.get(ownerId);
			
			//system.debug('hasSObjectField(QUEUE_MANAGER_API_NAME, sObj) = ' + hasSObjectField(QUEUE_MANAGER_API_NAME, sObj));
			
			if (queueManagerId != null && hasSObjectField(QUEUE_MANAGER_API_NAME, sObj)) 
			{
				sObj.put(QUEUE_MANAGER_API_NAME, queueManagerId);
			}
			
			system.debug('hasSObjectField(SEND_EMAIL_ALERTS_TO_QUEUE_API_NAME, sObj) = ' + hasSObjectField(SEND_EMAIL_ALERTS_TO_QUEUE_API_NAME, sObj));
			system.debug('sendEmailAlert) = ' + sendEmailAlert);
			if (sendEmailAlert && hasSObjectField(SEND_EMAIL_ALERTS_TO_QUEUE_API_NAME, sObj))
			{
				sObj.put(SEND_EMAIL_ALERTS_TO_QUEUE_API_NAME, sendEmailAlert);
			}
		}
	}
	
	/* This method returns a set of Owner Ids given a List of sObject records.*/
	private static Set<Id> buildOwnerSet(List<sObject> sObjectList)
	{
		System.debug('Entering Queue_Manager_Assign.buildOwnerSet().');
		Set<Id> ownerSet = new Set<Id>();
	
		for (sObject sObj : sObjectList) 
		{
			Id ownerId = (Id)sObj.get('OwnerId');
			ownerSet.add(ownerId);
		}
		
		return ownerSet;
	}
	
	/* This method returns a map of Queue Manager (User) Ids for a given set of Queues Ids.*/
	private static Map<Id,Id> buildQueueManagerMap(Set<Id> ownerSet)
	{
		System.debug('Entering Queue_Manager_Assign.buildQueueManagerMap().');
		Map<Id,Id> queueManagerMap = new Map<Id,Id>();
		
		List<Queue_Manager_Mapping__c> queueManagerMappingList = 
			[select Id, OwnerId, Queue_Id__c, User__c from Queue_Manager_Mapping__c where OwnerId IN :ownerSet];
			
		if(queueManagerMappingList.size() > 0)
		{	
			for (Queue_Manager_Mapping__c queueManagerMapping :queueManagerMappingList) 
			{
				queueManagerMap.put(queueManagerMapping.OwnerId, queueManagerMapping.User__c);
			}
		}
		return queueManagerMap;
	}
	
	/* This method returns a map of boolean values used identify email preferences for a given set of Queues Ids.*/
	private static Map<Id,boolean> buildEmailAlertMap(Set<Id> ownerSet)
	{
		System.debug('Entering Queue_Manager_Assign.buildQueueManagerMap().');
		Map<Id,boolean> emailAlertMap = new Map<Id,boolean>();
		
		List<Queue_Manager_Mapping__c> queueManagerMappingList = 
			[select Id, OwnerId, Send_Email_Alerts_to_Queue__c from Queue_Manager_Mapping__c where OwnerId IN :ownerSet];
			
		for (Queue_Manager_Mapping__c queueManagerMapping :queueManagerMappingList) 
		{
			emailAlertMap.put(queueManagerMapping.OwnerId, queueManagerMapping.Send_Email_Alerts_to_Queue__c);
		}
		
		return emailAlertMap;
	}
	
	/*check if an Sobject has a field*/
	public static boolean hasSObjectField(String fieldName, SObject sObj)
	{
	  return sObj.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
	}
}