<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Dealer_Code_Credited_To</fullName>
        <field>Dealer_Code_Credited_To__c</field>
        <formula>Partner_Account__r.Dealer_Code__c</formula>
        <name>Populate Dealer Code Credited To</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Brand_to_Mack</fullName>
        <field>Brand__c</field>
        <literalValue>Mack</literalValue>
        <name>Update Opportunity Brand to Mack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Brand_to_Other</fullName>
        <field>Brand__c</field>
        <literalValue>Other</literalValue>
        <name>Update Opportunity Brand to Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Brand_to_Volvo</fullName>
        <field>Brand__c</field>
        <literalValue>Volvo</literalValue>
        <name>Update Opportunity Brand to Volvo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Record_Type_To_Mack</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Mack</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Opportunity Record Type To Mack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Record_Type_To_Other</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Other</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Opportunity Record Type To Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_Record_Type_To_Volvo</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Volvo</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Opportunity Record Type To Volvo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Opportunity Record Type To Mack</fullName>
        <actions>
            <name>Update_Opportunity_Brand_to_Mack</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Opportunity_Record_Type_To_Mack</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Opportunity Record type to match Lead Record type. This will happen when a dual branded user creates a Lead that doesn&apos;t match the default opportunity record type for the profile.</description>
        <formula>AND(  NOT(ISBLANK(TEXT(Lead_Record_Type__c))), OR (RecordType.DeveloperName = &apos;Volvo&apos;, RecordType.DeveloperName = &apos;Other&apos; ), TEXT(Lead_Record_Type__c) = &apos;Mack&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Record Type To Other</fullName>
        <actions>
            <name>Update_Opportunity_Brand_to_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Opportunity_Record_Type_To_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Opportunity Record type to match Lead Record type. This will happen when a dual branded user creates a Lead that doesn&apos;t match the default opportunity record type for the profile.</description>
        <formula>AND(  NOT(ISBLANK(TEXT(Lead_Record_Type__c))), OR (RecordType.DeveloperName = &apos;Volvo&apos;, RecordType.DeveloperName = &apos;Mack&apos;), TEXT(Lead_Record_Type__c) = &apos;Other&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Record Type To Volvo</fullName>
        <actions>
            <name>Update_Opportunity_Brand_to_Volvo</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Opportunity_Record_Type_To_Volvo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Opportunity Record type to match Lead Record type. This will happen when a dual branded user creates a Lead that doesn&apos;t match the default opportunity record type for the profile.</description>
        <formula>AND(  NOT(ISBLANK(TEXT(Lead_Record_Type__c))), OR (RecordType.DeveloperName = &apos;Mack&apos;, RecordType.DeveloperName = &apos;Other&apos;), TEXT(Lead_Record_Type__c) = &apos;Volvo&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Vgtna WF Oppty Dealer Code Credited Population</fullName>
        <actions>
            <name>Populate_Dealer_Code_Credited_To</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>There is a field called partner account on Oppty 
If the field is not null and Dealer Code Credited To is NULL 
Update the Dealer Code Credited To field with the dealer code for partner account</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
