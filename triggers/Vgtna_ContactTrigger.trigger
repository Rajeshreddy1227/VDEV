trigger Vgtna_ContactTrigger on Contact (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
            new Vgtna_ContactTriggerHandler().run();
}