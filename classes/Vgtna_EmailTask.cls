public class Vgtna_EmailTask {
 @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody, String accountId){
    
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
     // Step 1: Create a new Email
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
       List<String> sendTo = new List<String>();
       sendTo.add(mMail);
       mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
       mail.setReplyTo('noreply@gmail.com'); // change it with your mail address.
       mail.setSenderDisplayName('salesforce User'); 
    
    // Step 4. Set email contents - you can use variables!
      mail.setSubject(mSubject);
      mail.setHtmlBody(mbody);
    
    // Step 5. Add your email to the master list
      mails.add(mail);
    
  // Step 6: Send all emails in the master list
     Messaging.sendEmail(mails);
     Task t = new Task();
     t.whatId = accountId;
     t.OwnerId = userInfo.getUserId();
     t.Subject = mSubject;
     t.TaskSubtype = 'Email';
     String description = 'To: '+mMail+'\n'+'Subject: '+mSubject+'\n'+'Body: '+mbody;
     t.Description = description;
     t.ActivityDate = System.today();
     insert t;
        system.debug('task id: '+t.Id);
   }   
}