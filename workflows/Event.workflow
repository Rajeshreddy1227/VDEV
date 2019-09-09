<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Account_Type</fullName>
        <field>Account_Type__c</field>
        <formula>&quot;Customer&quot;</formula>
        <name>Update Account Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_Type</fullName>
        <field>Event_Type__c</field>
        <formula>TEXT( Type )</formula>
        <name>Update Event Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Event Type Update</fullName>
        <actions>
            <name>Update_Event_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Event Account Type</fullName>
        <actions>
            <name>Update_Account_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(NOT(ISBLANK(Account__c )), NOT(ISNULL(Account__r.Party_ID__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
