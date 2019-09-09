public without sharing class Vgtna_SharingModel {

    public static void setObjectShare(Map<Id,Id> groupid2ObjIdMap, String obj)
    {
        if(obj == 'Lead')
        {
             List<LeadShare> leadShareList = new List<LeadShare>();
            // sort out Lead share
            for(Id i: groupid2ObjIdMap.keyset())
            {
                LeadShare lShare = new LeadShare (LeadId =groupid2ObjIdMap.get(i),
                                                  LeadAccessLevel = 'Edit',                                                  
                                                  UserOrGroupId = i,
                                                  RowCause = 'Manual');
                leadShareList.add(lShare);
            }
            
             if(!leadShareList.isEmpty())
                {
                    insert leadShareList;
                    system.debug('leadShareList-->'+leadShareList);
                    
                }
                
        }
        
        if(obj == 'Opportunity')
        {
              List<OpportunityShare> oppShareList = new List<OpportunityShare>();
            // sort out Opportunity share
            for(Id i: groupid2ObjIdMap.keyset())
            {
                OpportunityShare oShare = new OpportunityShare (OpportunityId =groupid2ObjIdMap.get(i),
                                                  OpportunityAccessLevel = 'Edit',                                                  
                                                  UserOrGroupId = i,
                                                  RowCause = 'Manual');
                oppShareList.add(oShare);
            }
            
             if(!oppShareList.isEmpty())
                {
                    insert oppShareList;
                    system.debug('oppShareList-->'+oppShareList);
                    
                }
        }
    }
    
    public static void reomoveObjectShare(Map<Id,Id> objId2GroupIdMap, String obj)
    {
        if(obj == 'Opportunity')
        {
            List<OpportunityShare> oppShareToBeDeleted = new List<OpportunityShare>();
            
            List<OpportunityShare> oppShareScope = [select id,OpportunityId,UserOrGroupId,RowCause
                                                          from OpportunityShare 
                                                          where OpportunityId =: objId2GroupIdMap.keyset()];
            
            if(!oppShareScope.isEmpty())
            {
                for(OpportunityShare os: oppShareScope)
                {
                    for(Id key: objId2GroupIdMap.keyset())
                    {
                        if(os.RowCause == 'Manual' && os.UserOrGroupId == objId2GroupIdMap.get(key) && os.OpportunityId == key)
                        {
                            oppShareToBeDeleted.add(os);
                        }
                    }
                    
                }
            }
            
            if(!oppShareToBeDeleted.isEmpty())
            {
                delete oppShareToBeDeleted;
            }
            
        }
    }
}