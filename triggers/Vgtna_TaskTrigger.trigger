trigger Vgtna_TaskTrigger on Task (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_TaskTriggerHandler().run();
}