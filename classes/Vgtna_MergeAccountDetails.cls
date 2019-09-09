public class Vgtna_MergeAccountDetails {
    public static void mergeAccDet(){
       set<id> surIds = new set<id>();
       set<id> vicIds = new set<id>();
        map<id,id> SurVic = new map<id,id>();
       for(Merge__c mer:[select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c
                                                        from Merge__c 
                                                       where Status__c = 'To Be Processed' AND SurvivorAccountId__c <> null and VictimAccountId__c <> null])
        {
            surIds.add(mer.SurvivorAccountId__c);
            vicIds.add(mer.VictimAccountId__c);
            SurVic.put(mer.VictimAccountId__c,mer.SurvivorAccountId__c);
        }
//        List<id> listids = new List<id>(surIds);
      //  system.debug('surIds-->'+surIds);
      //  system.debug('vicIds-->'+vicIds);
        map<id,Account> surAccDet = new map<id,Account>();
        map<id,Account> vicAccDet = new map<id,Account>();
        
        list<Account> surUpd = new list<Account>();
        list<Account> vicUpd = new list<Account>();
        for(Account acc:[select id,name,party_id__c,Industry,Strategic_Account__c,Mack_National_Account__c,Volvo_National_Account__c,Mack_Sales_Target_Account__c,Volvo_Sales_Target_Account__c,FE_Current__c,FE_Current_Volvo__c,Daycab__c,Daycab_Volvo__c,Sleeper__c,Sleeper_Volvo__c,FE_Goal__c,FE_Goal_Volvo__c,Trades__c,Trades_Volvo__c,Application__c,Application_Volvo__c,Trade_Cycle__c,Trade_Cycle_Volvo__c,Primary_Make__c,Primary_Make_Volvo__c,Secondary_Make__c,Secondary_Make_Volvo__c,Warranty_Coverage__c,Warranty_Coverage_Volvo__c,Miles_Driven__c,Miles_Driven_Volvo__c,Trailer_Types__c,Trailer_Types_Volvo__c,Repair_Shop_Owned__c,Repair_Shop_Owned_Volvo__c from Account where id in :surIds]){
            surAccDet.put(acc.id,Acc);
        }
        
        //system.debug('surAccDet-->'+surAccDet);
        for(Account acc:[select id,name,party_id__c,Industry,Strategic_Account__c,Mack_National_Account__c,Volvo_National_Account__c,Mack_Sales_Target_Account__c,Volvo_Sales_Target_Account__c,FE_Current__c,FE_Current_Volvo__c,Daycab__c,Daycab_Volvo__c,Sleeper__c,Sleeper_Volvo__c,FE_Goal__c,FE_Goal_Volvo__c,Trades__c,Trades_Volvo__c,Application__c,Application_Volvo__c,Trade_Cycle__c,Trade_Cycle_Volvo__c,Primary_Make__c,Primary_Make_Volvo__c,Secondary_Make__c,Secondary_Make_Volvo__c,Warranty_Coverage__c,Warranty_Coverage_Volvo__c,Miles_Driven__c,Miles_Driven_Volvo__c,Trailer_Types__c,Trailer_Types_Volvo__c,Repair_Shop_Owned__c,Repair_Shop_Owned_Volvo__c from Account where id in :vicIds]){
            vicAccDet.put(acc.id,Acc);
        }
        //system.debug('vicAccDet-->'+vicAccDet);
        
        for(id v:vicAccDet.keySet())
        {
            Account aSur = surAccDet.get(SurVic.get(v));
            Account aVic = vicAccDet.get(v);
            if(aSur.Industry == null){
                if(aVic.Industry!=null){
                    system.debug('aSur.Industry'+aSur.Industry);
                    system.debug('aVic.Industry'+aVic.Industry);
                    aSur.Industry = aVic.Industry;}
            }
            if(aSur.Strategic_Account__c == null){
                if(aVic.Strategic_Account__c!=null){
                aSur.Strategic_Account__c = aVic.Strategic_Account__c;}
            }
            if(aSur.Mack_National_Account__c==null){
                if(aVic.Mack_National_Account__c!=null){
                    aSur.Mack_National_Account__c = aVic.Mack_National_Account__c;}
            }
            if(aSur.Volvo_National_Account__c==null){
                if(aVic.Volvo_National_Account__c!=null){
                    aSur.Volvo_National_Account__c = aVic.Volvo_National_Account__c;}
            }
            if(aSur.Mack_Sales_Target_Account__c == null){
                if(aVic.Mack_Sales_Target_Account__c!=null){
                    aSur.Mack_Sales_Target_Account__c = aVic.Mack_Sales_Target_Account__c;}
            }
            if(aSur.Volvo_Sales_Target_Account__c == null){
                if(aVic.Volvo_Sales_Target_Account__c!=null){
                    aSur.Volvo_Sales_Target_Account__c = aVic.Volvo_Sales_Target_Account__c;}
            }
            if(aSur.FE_Current__c == null){
                if(aVic.FE_Current__c!=null){
                    aSur.FE_Current__c = aVic.FE_Current__c;}
            }
            if(aSur.FE_Current_Volvo__c == null){
                if(aVic.FE_Current_Volvo__c!=null){
                    aSur.FE_Current_Volvo__c = aVic.FE_Current_Volvo__c;}
            }
            if(aSur.Daycab__c == null){
                if(aVic.Daycab__c!=null){
                    aSur.Daycab__c = aVic.Daycab__c;}
            }
            if(aSur.Daycab_Volvo__c == null){
                if(aVic.Daycab_Volvo__c!=null){
                    aSur.Daycab_Volvo__c = aVic.Daycab_Volvo__c;}
            }
            if(aSur.Sleeper__c == null){
                if(aVic.Sleeper__c!=null){
                    aSur.Sleeper__c = aVic.Sleeper__c;}
            }
            if(aSur.Sleeper_Volvo__c == null){
                if(aVic.Sleeper_Volvo__c!=null){
                    aSur.Sleeper_Volvo__c = aVic.Sleeper_Volvo__c;}
            }
            if(aSur.FE_Goal__c == null){
                if(aVic.FE_Goal_Volvo__c!=null){
                    aSur.FE_Goal__c = aVic.FE_Goal_Volvo__c;}
            }
            if(aSur.FE_Goal_Volvo__c == null){
                if(aVic.FE_Goal_Volvo__c!=null){
                    aSur.FE_Goal_Volvo__c = aVic.FE_Goal_Volvo__c;}
            }
            if(aSur.Trades__c == null){
                if(aVic.Trades__c!=null){
                    aSur.Trades__c = aVic.Trades__c;}
            }
            if(aSur.Trades_Volvo__c == null){
                if(aVic.Trades_Volvo__c!=null){
                    aSur.Trades_Volvo__c = aVic.Trades_Volvo__c;}
            }
            if(aSur.Application__c == null){
                if(aVic.Application__c!=null){
                    aSur.Application__c = aVic.Application__c;}
            }
            if(aSur.Application_Volvo__c == null){
                if(aVic.Application_Volvo__c!=null){
                    aSur.Application_Volvo__c = aVic.Application_Volvo__c;}
            }
            if(aSur.Trade_Cycle__c == null){
                if(aVic.Trade_Cycle__c!=null){
                    aSur.Trade_Cycle__c = aVic.Trade_Cycle__c;}
            }
            if(aSur.Trade_Cycle_Volvo__c == null){
                if(aVic.Trade_Cycle_Volvo__c!=null){
                    aSur.Trade_Cycle_Volvo__c = aVic.Trade_Cycle_Volvo__c;}
            }
            if(aSur.Primary_Make__c == null){
                if(aVic.Primary_Make__c!=null){
                    aSur.Primary_Make__c = aVic.Primary_Make__c;}
            }
            if(aSur.Primary_Make_Volvo__c == null){
                if(aVic.Primary_Make_Volvo__c!=null){
                    aSur.Primary_Make_Volvo__c = aVic.Primary_Make_Volvo__c;}
            }
            if(aSur.Secondary_Make__c == null){
                if(aVic.Secondary_Make__c!=null){
                    aSur.Secondary_Make__c = aVic.Secondary_Make__c;}
            }
            if(aSur.Secondary_Make_Volvo__c == null){
                aSur.Secondary_Make_Volvo__c = aVic.Secondary_Make_Volvo__c;
            }
            if(aSur.Warranty_Coverage__c == null){
                if(aVic.Secondary_Make_Volvo__c!=null){
                    aSur.Warranty_Coverage__c = aVic.Warranty_Coverage__c;}
            }
            if(aSur.Warranty_Coverage_Volvo__c == null){
                if(aVic.Warranty_Coverage_Volvo__c!=null){
                    aSur.Warranty_Coverage_Volvo__c = aVic.Warranty_Coverage_Volvo__c;}
            }
            if(aSur.Miles_Driven__c == null){
                if(aVic.Miles_Driven__c!=null){
                    aSur.Miles_Driven__c = aVic.Miles_Driven__c;}
            }
            if(aSur.Miles_Driven_Volvo__c == null){
                if(aVic.Miles_Driven_Volvo__c!=null){
                    aSur.Miles_Driven_Volvo__c = aVic.Miles_Driven_Volvo__c;}
            }
            if(aSur.Trailer_Types__c == null){
                if(aVic.Trailer_Types__c!=null){
                    aSur.Trailer_Types__c = aVic.Trailer_Types__c;}
            }
            if(aSur.Trailer_Types_Volvo__c == null){
                if(aVic.Trailer_Types_Volvo__c!=null){
                    aSur.Trailer_Types_Volvo__c = aVic.Trailer_Types_Volvo__c;}
            }
            if(aSur.Repair_Shop_Owned__c == null){
                if(aVic.Repair_Shop_Owned__c!=null){
                    aSur.Repair_Shop_Owned__c = aVic.Repair_Shop_Owned__c;}
            }
            if(aSur.Repair_Shop_Owned_Volvo__c == null){
                if(aVic.Repair_Shop_Owned_Volvo__c!=null){
                    aSur.Repair_Shop_Owned_Volvo__c = aVic.Repair_Shop_Owned_Volvo__c;}
            }

            aVic.SurvivingPartyId__c = aSur.Party_ID__c;
            aVic.SurvivingAccountId__c = aSur.Id;
            aVic.MergeStatus__c = 'Merged';
            vicUpd.Add(aVic);
            //system.debug(aVic.name+'==>'+aSur.Name);
            surUpd.Add(aSur);
            //System.debug('vicUpd==>'+vicUpd);
        }
        map<id,Account> mapsurUpd = new map<id,Account>();
        map<id,Account> mapvicUpd = new map<id,Account>();
        for(Account acc:surUpd){
            mapsurUpd.put(acc.Id,acc);
        }
        for(Account accvic:vicUpd){
            mapvicUpd.put(accvic.Id,accvic);
        }
        //system.debug('surUpd'+surUpd);
        if(!mapsurUpd.values().isEmpty()){
		database.update (mapsurUpd.values(),false);
		}
        if(!mapvicUpd.values().isEmpty()){
		database.update (mapvicUpd.values(),false);
		}
   /*     system.debug('surUpd'+surUpd);
        if(surUpd.size()>0){
            database.update(surUpd);
        }
        if(vicUpd.size()>0){
            database.update(vicUpd);
        }*/
    }
}