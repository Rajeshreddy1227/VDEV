<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Notification_to_creator_upon_Task_completion</fullName>
        <description>Email Notification to creator upon Task completion</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Notification_to_creator_upon_Task_completion</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Task_Account_Type</fullName>
        <field>Account_Type__c</field>
        <formula>&quot;Customer&quot;</formula>
        <name>Update Task Account Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Task Account type</fullName>
        <actions>
            <name>Update_Task_Account_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Account__c )), NOT(ISNULL(Account__r.Party_ID__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
