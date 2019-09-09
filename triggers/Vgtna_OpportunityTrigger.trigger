trigger Vgtna_OpportunityTrigger on Opportunity (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_OpportunityTriggerHandler().run();
}