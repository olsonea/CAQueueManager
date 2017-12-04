trigger Queue_Manager_Problem_Trigger on BMCServiceDesk__Problem__c bulk (before insert,before update) 
{
	if(trigger.isBefore)
	{
		if(trigger.isInsert)
		{
			sObjectTriggerHandler.beforeInsert(trigger.new);
		}
		
		if(trigger.isUpdate)
		{
			sObjectTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
		}
	}
}