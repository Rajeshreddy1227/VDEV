trigger Vgtna_EventTrigger on Event (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_EventTriggerHandler().run();
}