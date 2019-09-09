trigger Vgtna_AccountContactRelTrigger on AccountContactRelation(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new AccountContactRelTriggerHandler().run();
}