public class sObjectTriggerHandler
{
    public static void beforeInsert(List<sObject> newSobjectList)
    {
        System.debug('Entering sObjectTriggerHandler.beforeInsert().');
        List<sObject> sObjectsWithNewOwner = evaluateChangeInOwner(newSobjectList);
        
        if(sObjectsWithNewOwner.size() > 0)
        {
            assignQueueManager(sObjectsWithNewOwner);
        }
    }
    
    public static void beforeUpdate(List<sObject> newSobjectList, Map<Id,sObject> oldSobjectMap)
    {
        System.debug('Entering sObjectTriggerHandler.beforeUpdate().');
        List<sObject> sObjectsWithNewOwner = evaluateChangeInOwner(newSobjectList, oldSobjectMap);
        
        if(sObjectsWithNewOwner.size() > 0)
        {
            assignQueueManager(sObjectsWithNewOwner);
        }
    }
    
    /* This evaluateChangeInOwner method is polymorphic. This version is used for Insert operations.*/
    public static List<sObject> evaluateChangeInOwner(List<sObject> newSobjectList)
    {
        System.debug('Entering sObjectTriggerHandler.evaluateChangeInOwner().');
        List<sObject> sObjectsWithNewOwner = new List<sObject>();
        
        for (sObject sObj :newSobjectList)
        {
            Id ownerId = (Id)sObj.get('OwnerId');
            if (ownerId != null) 
            {
			    sObjectsWithNewOwner.add(sObj);
		    }
        }
        
        return sObjectsWithNewOwner;
    }
    
    /* This evaluateChangeInOwner method is polymorphic. This version is used for Update operations.*/
    public static List<sObject> evaluateChangeInOwner(List<sObject> newSobjectList, Map<Id,sObject> oldSobjectMap)
    {
        System.debug('Entering sObjectTriggerHandler.evaluateChangeInOwner().');
        List<sObject> sObjectsWithNewOwner = new List<sObject>();
	
    	for (sObject sObj :newSobjectList) 
    	{
    		sObject oldSobject = oldSobjectMap.get(sObj.Id);
			Id ownerId = (Id)sObj.get('OwnerId');
			Id oldOwnerId = (Id)oldSobject.get('OwnerId');
    			
			if (oldSobject != null &&  ownerId != oldOwnerId ) 
			{
					sObjectsWithNewOwner.add(sObj);
			}
    	}
    	
    	return sObjectsWithNewOwner;
    }
    
    public static void assignQueueManager(List<sObject> sObjectsWithNewOwner)
    {
        System.debug('Entering sObjectTriggerHandler.assignQueueManager().');
        Queue_Manager_Assign qma = new Queue_Manager_Assign(sObjectsWithNewOwner);
    }
}