trigger Vgtna_UserTrigger on User (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_UserTriggerHandler().run();
}