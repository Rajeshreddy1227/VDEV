global class Vgtna_batchAssignTerrToOpptySchedule implements Schedulable{
    
    global void execute(SchedulableContext sc) 
    {
          Vgtna_batchAssignTerrToOppty uca = new Vgtna_batchAssignTerrToOppty();
            Id batchId = Database.executeBatch(uca,100);      
    }
        
           

}