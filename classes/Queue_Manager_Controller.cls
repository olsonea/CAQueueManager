public class Queue_Manager_Controller 
{

    public List<Queue_Manager_Mapping__c> queueManagers {get; set;}
	public Queue_Manager_Mapping__c newQM {get; set;}
	public String qmId {get; set;}
	
	public Queue_Manager_Controller()
	{
		this.queueManagers = getQueueManagers();
		newQM = new Queue_Manager_Mapping__c();
	}
	
	public PageReference initializeQueues()
	{
		List <Group> queues = [select Id, Name from group where type = 'Queue'];
		List <Queue_Manager_Mapping__c> queueManagerMappings = new List <Queue_Manager_Mapping__c>();
		List <Queue_Manager_Mapping__c> existingQueueMappings = [select Id, Queue_Id__c from Queue_Manager_Mapping__c];
		Set<String> existingQueueMappingSet = new Set<string>();
		
		for(Queue_Manager_Mapping__c queue :existingQueueMappings)
		{
			existingQueueMappingSet.add(queue.Queue_Id__c);
		}
		
		for(Group queue :queues)
		{
			if(existingQueueMappingSet.contains(queue.Name))
			{}
			else
			{
				Queue_Manager_Mapping__c queueManagerMapping = new Queue_Manager_Mapping__c
					(
						Queue_Id__c = queue.Name,
						OwnerId = queue.Id
					);
				
				queueManagerMappings.add(queueManagerMapping);
			}
		}
		
		try
		{
			upsert queueManagerMappings;
		}
		catch (exception e)
		{
			System.debug('The following exception has occurred: ' + e.getMessage());
		}
		
		return null;
	}
	
	public List<Queue_Manager_Mapping__c> getQueueManagers () 
	{
		List<Queue_Manager_Mapping__c> retList = [select Id, Queue_Id__c, User__c, Send_Email_Alerts_to_Queue__c from Queue_Manager_Mapping__c order by Queue_Id__c asc];
		return retList;
	}
	
	public List<SelectOption> getQueueSelOpts() 
	{
		List<SelectOption> retList = new List<SelectOption>();
		Set<String> existIds = new Set<String>();
		
		for (Queue_Manager_Mapping__c queueManager : queueManagers ) 
		{
			existIds.add(queueManager.Queue_Id__c);
		}
		
		for (Group gr : [select Id, Name from Group where Type = 'Queue']) 
		{
			if (!existIds.contains(gr.Id))
			{
				retList.add(new SelectOption(gr.Id,gr.Name));
			}
		}
		
		return retList;
		
	}
	
	public List<SelectOption> getAllQueueSelOpts() 
	{
		List<SelectOption> retList = new List<SelectOption>();

		for (Group gr : [select Id, Name from Group where Type = 'Queue']) 
		{
			retList.add(new SelectOption(gr.Id,gr.Name));
		}
		
		return retList;
		
	}
	
	public PageReference addNew() 
	{
		upsert newQM;
		newQM = new Queue_Manager_Mapping__c();
		this.queueManagers = getQueueManagers();
		return null;
	}
	
	public PageReference delQM() 
	{
		Queue_Manager_Mapping__c qm = new Queue_Manager_Mapping__c(Id=qmId);
		delete qm;
		this.queueManagers = getQueueManagers();
		return null;
	}
	
	public void save() 
	{
		upsert queueManagers;
		this.queueManagers = getQueueManagers();
	}
}