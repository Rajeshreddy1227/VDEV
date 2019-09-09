trigger Vgtna_AssetTrigger on Asset (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_AssetTriggerHandler().run();
}