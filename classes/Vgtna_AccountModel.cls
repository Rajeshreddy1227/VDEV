public with sharing class Vgtna_AccountModel {
    public static void setAorRegionCounty(List<Account> newAccount, Boolean isInsert)
    {
        System.debug('Called setAorRegionCounty');
        Set<String> newAccountZips = new Set<String>();
        Map<Id,String> accZipMap = new Map<Id,String>();
            
        if(isInsert)
        {
            for(Account acct : newAccount)
            {
                System.debug('inside isInsert'+acct.BillingPostalCode+'--'+acct.BillingCountry);   
                if(String.isNotBlank(acct.BillingPostalCode) && acct.BillingCountry!=null)
                {
                    newAccountZips.add(acct.BillingCountry=='United States' ? acct.BillingPostalCode.Left(5) : acct.BillingPostalCode.Left(3));
                }
            }       
            system.debug('newAccountZips: '+newAccountZips);            
            if(newAccountZips.isEmpty())
            {
                // Nothing to do
                System.debug('newAccountZips.isEmpty()');   
                return;
            }
            
            Map<String, Map<String, AOR__c>> zipAORMap = new Map<String, Map<String, AOR__c>>();
            Map<String, AOR__c> aorMap = new Map<String, AOR__c>();
            // Create a Map for US and CA Matching key with AOR object
            System.debug('Starting AOR loop' );
            for(AOR__c aor : [Select Id, Postal_Code__c, Brand__c, Dealer_Code__c, Region__c, County__c, Country__c 
                                from AOR__c
                                where Postal_Code__c IN:newAccountZips
                                Limit 50000])
            {
                if(!zipAORMap.containsKey(aor.Postal_Code__c))
                    zipAORMap.put(aor.Postal_Code__c, new Map<String, AOR__c>());
                
                aorMap.put(aor.Brand__c, aor);                
                zipAORMap.put(aor.Postal_Code__c, aorMap);
            }
            System.debug(zipAORMap);
            
            for(Account acct : newAccount)
            {
                if(acct.BillingPostalCode!=null )
                {
                    /*String mackDealerCode = '';
                    String volvoDealerCode = '';
                    String region = '';
                    String county = '';*/
                    
                    for(String postalCode : zipAORMap.keyset())
                    {
                        for(String brand : zipAORMap.get(postalCode).keyset())
                        {
                            if(brand == 'Mack')
                            {
                                System.debug('inside mack');
                                acct.Mack_Dealer_Code__c = zipAORMap.get(postalCode).get(brand).Dealer_Code__c;
                                acct.Region__c  = zipAORMap.get(postalCode).get(brand).Region__c;
                                acct.Primary_County__c = zipAORMap.get(postalCode).get(brand).County__c;
                            }
                            if(brand == 'Volvo')
                            {
                                System.debug('inside volvo');
                                acct.Volvo_Dealer_Code__c = zipAORMap.get(postalCode).get(brand).Dealer_Code__c;
                                acct.Region__c  = zipAORMap.get(postalCode).get(brand).Region__c;
                                acct.Primary_County__c = zipAORMap.get(postalCode).get(brand).County__c;
                            }
                        }
                    }
                }
            }                   
        }
    }
    public static void setTerritoryAOR(List<Account> newAccount, Map<Id,Account> oldAccount, Boolean isInsert)
    {
        Set<String> newAccountZips = new Set<String>();
        //Set<Id> accountsToRemove = new Set<Id>();
        Map<Id, String> accountsToRemoveForZip = new Map<Id, String>();
        
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND Name=:vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE];
        
        // Load set of Postal Codes to use for Selective Query against AOR 
        for(Account acct : newAccount)
        {
            if(acct.RecordTypeId==rt.Id) // only Processing Customer Accounts
            {
                if(acct.BillingPostalCode!=null && acct.BillingCountryCode!=null)
                {
                    String billZip = acct.BillingCountryCode=='US' ? acct.BillingPostalCode.Left(5) : acct.BillingPostalCode.Left(3);
                    
                   
                    if(!isInsert)
                    {
                        String oldZipCode = acct.BillingCountryCode=='US' ? oldAccount.get(acct.Id).BillingPostalCode.Left(5) : oldAccount.get(acct.Id).BillingPostalCode.Left(3);
                        if(acct.BillingPostalCode.trim()<>oldAccount.get(acct.Id).BillingPostalCode.trim())
                        {
                            // only adding changed postal code accounts for Territory Removal
                            newAccountZips.add(billZip);
                            accountsToRemoveForZip.put(acct.Id, oldZipCode);
                        } 
                        
                    }
                    else
                    {
                        newAccountZips.add(billZip);
                    }
                }
            }        
        }

        if(newAccountZips.isEmpty())
        {
            // Nothing to do
            return;
        }

        Map<String, AOR__c> CustomSettingsMapAOR_US = new Map<String,AOR__c>();
        Map<String, AOR__c> CustomSettingsMapAOR_CA = new Map<String,AOR__c>();
        Set<String> dealerCodes = new Set<String>();
        Set<String> delAccZips = new Set<String>();
        Map<String, String> delZipDealerCodeMap = new Map<String, String>();
        if(!accountsToRemoveForZip.isEmpty()) {
            delAccZips.addAll(accountsToRemoveForZip.values());
        }
        
        // Create a Map for US and CA Matching key with AOR object
        for(AOR__c aor : [Select Id, Region__c,Brand__c, Dealer_Code__c ,City__c,Country__c,Postal_Code__c, State_Province__c
                          from AOR__c
                          where Postal_Code__c IN:newAccountZips OR Postal_Code__c IN:delAccZips
                          Limit 50000])
        {
            if(!accountsToRemoveForZip.isEmpty() && delAccZips.contains(aor.Postal_Code__c)) {
                delZipDealerCodeMap.put(aor.Brand__c+'-'+aor.Postal_Code__c, aor.Dealer_Code__c);
                dealerCodes.add(aor.Dealer_Code__c);
            }
            String zipAOR;
            if(aor.Country__c=='CA')
            {
                zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.left(3);
                CustomSettingsMapAOR_CA.put(aor.Brand__c+'-'+aor.State_Province__c+'-'+zipAOR+'-'+aor.City__c, aor);
                if(aor.Dealer_Code__c!=null)
                {
                    dealerCodes.add(aor.Dealer_Code__c);
                }
            } else if (aor.Country__c=='US')
            {
                zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.left(5);
                CustomSettingsMapAOR_US.put(aor.Brand__c+'-'+zipAOR, aor);
                if(aor.Dealer_Code__c!=null)
                {
                    dealerCodes.add(aor.Dealer_Code__c);
                }
            }
        }
        
        // Create a Map of Territory2 sObjects with Dealer Code as the Key
        Map<String, Territory2> dealerCodeToTerritory = new Map<String, Territory2>();
        Map<String, Set<Id>> existingAccounts = new Map<String, Set<Id>>();
        List<String> delTerList = new List<String>();
        Map<String, ObjectTerritory2Association> otaMap = new Map<String,  ObjectTerritory2Association>();
        List<ObjectTerritory2Association> delOt2a = new List<ObjectTerritory2Association>();
        if(!dealerCodes.isEmpty())
        {
            dealerCodeToTerritory = vgtna_TerritoryModel.findTerritoryID(dealerCodes);
            existingAccounts = vgtna_TerritoryModel.getAccountsWithDealerCode(dealerCodes);
        }
        if(!delZipDealerCodeMap.isEmpty()) {
            for(String dCode : delZipDealerCodeMap.values()) {
                delTerList.add(dealerCodeToTerritory.get(dCode).Id);
            }
            for(ObjectTerritory2Association ota : [SELECT Id, Territory2Id, ObjectId FROM ObjectTerritory2Association WHERE Territory2Id IN :delTerList AND ObjectId IN :accountsToRemoveForZip.keySet()]) {
                otaMap.put(ota.ObjectId+'-'+ota.Territory2Id, ota);
            }
            system.debug('otaMap: '+otaMap);
            for(String accId : accountsToRemoveForZip.keySet()) {
                
                if(delZipDealerCodeMap.containsKey('Volvo-'+accountsToRemoveForZip.get(accId)) && otaMap.containsKey(accId+'-'+dealerCodeToTerritory.get(delZipDealerCodeMap.get('Volvo-'+accountsToRemoveForZip.get(accId))).Id)) {
                    delOt2a.add(otaMap.get(accId+'-'+dealerCodeToTerritory.get(delZipDealerCodeMap.get('Volvo-'+accountsToRemoveForZip.get(accId))).Id));
                } 
                if (delZipDealerCodeMap.containsKey('Mack-'+accountsToRemoveForZip.get(accId)) && otaMap.containsKey(accId+'-'+dealerCodeToTerritory.get(delZipDealerCodeMap.get('Mack-'+accountsToRemoveForZip.get(accId))).Id)) {
                    delOt2a.add(otaMap.get(accId+'-'+dealerCodeToTerritory.get(delZipDealerCodeMap.get('Mack-'+accountsToRemoveForZip.get(accId))).Id));
                }
            }
        }
        if(!delOt2a.isEmpty()) {
            delete delOt2a;
        } 
        List<ObjectTerritory2Association> ot2a = new List<ObjectTerritory2Association>();
        
        
        System.debug('existingAccounts: '+existingAccounts);
        // Loop through Accounts, find AOR.Dealer_Code__c by match key, use Dealer Code to find Territory2 node, send to setAccount with 
        // Territory2.Id and Account.Id 
        String searchString='';
        String dealerCd='';
        for(Account acct : newAccount)
        {
            if(acct.RecordTypeId==rt.Id) // only Processing Customer Accounts
            {
                if(acct.BillingCountryCode=='US')
                {
                    if(acct.BillingPostalCode!=null )
                    {
                        searchString= 'Volvo-'+acct.BillingPostalCode.left(5);
                        if(CustomSettingsMapAOR_US.containsKey(searchString))
                        {
                            
                            dealerCd = CustomSettingsMapAOR_US.get(searchString).Dealer_Code__c;
                            
                            if(existingAccounts.containsKey(dealerCd))
                            {
                                // Some Accounts existed in Territory, make sure this one is not already added
                                if(existingAccounts.get(dealerCd).add(acct.Id))
                                {
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                                }
                            } else
                            {
                                // No Accounts existed in Territory
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                            }
                        } 
                        searchString= 'Mack-'+acct.BillingPostalCode.left(5);
                        if(CustomSettingsMapAOR_US.containsKey(searchString))
                        {
                            
                            dealerCd = CustomSettingsMapAOR_US.get(searchString).Dealer_Code__c;
                            
                            if(existingAccounts.containsKey(dealerCd))
                            {
                                // Some Accounts existed in Territory, make sure this one is not already added
                                if(existingAccounts.get(dealerCd).add(acct.Id))
                                {
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                                }
                            } else
                            {
                                // No Accounts existed in Territory
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                            }
                        } 
                    }                    
                }
                else if(acct.BillingCountryCode=='CA')
                {
                    if(acct.BillingPostalCode!=null && acct.BillingCity!=null && acct.BillingStateCode!=null) // Cannot match without these populated
                    {   
                        searchString= 'Volvo-'+acct.BillingStateCode+'-'+acct.BillingPostalCode.left(3)+'-'+acct.BillingCity;
                        if(CustomSettingsMapAOR_CA.containsKey(searchString))    
                        {
                            
                            dealerCd = CustomSettingsMapAOR_CA.get(searchString).Dealer_Code__c;
                            
                            if(existingAccounts.containsKey(dealerCd))
                            {
                                // Some Accounts existed in Territory, make sure this one is not already added
                                if(existingAccounts.get(dealerCd).add(acct.Id))
                                {
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                                }
                            } else
                            {
                                // No Accounts existed in Territory
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                            }

                        }        
                        searchString= 'Mack-'+acct.BillingStateCode+'-'+acct.BillingPostalCode.left(3)+'-'+acct.BillingCity;
                        if(CustomSettingsMapAOR_CA.containsKey(searchString))    
                        {
                            
                            dealerCd = CustomSettingsMapAOR_CA.get(searchString).Dealer_Code__c;
                            if(existingAccounts.containsKey(dealerCd))
                            {
                                // Some Accounts existed in Territory, make sure this one is not already added
                                if(existingAccounts.get(dealerCd).add(acct.Id))
                                {
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                                }
                            } else
                            {
                                // No Accounts exsited in Territory
                                    ot2a.add(new ObjectTerritory2Association(
                                            AssociationCause='Territory2Manual',
                                            ObjectId=acct.Id,
                                            Territory2Id=dealerCodeToTerritory.get(dealerCd).Id));
                            }
                        }        
                    }
                }
            }
        }

    insert ot2a;
    }    
    public class TerritoryException extends Exception {}

}