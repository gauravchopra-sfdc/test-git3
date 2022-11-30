//Class to test the GIT opsera flow
public class CIOpportunityStageUpdate {
    private ID opportunityId = null;
    private Opportunity opp = new Opportunity();
    private Boolean hasErrors = false;
    
    public CIOpportunityStageUpdate(ApexPages.StandardController stdController) {
        // get the opportunity id
        this.opportunityId = stdController.getId();
        this.opp = (Opportunity)stdController.getRecord();
        // read parameters
        Map<String,String> params = ApexPages.currentPage().getParameters();
    }
    
    public PageReference onLoad() {
        
        Savepoint sp = null;
        PageReference t = null;
        try {
            List<Opportunity> oppty = [SELECT Id, CI_Incomplete_Stage__c , Workday_Services_Changed__c, StageName FROM Opportunity WHERE Id = :opportunityId];
            if(oppty[0].CI_Incomplete_Stage__c != NULL || oppty[0].Workday_Services_Changed__c){
                if(oppty[0].CI_Incomplete_Stage__c != NULL){
                    oppty[0].StageName = oppty[0].CI_Incomplete_Stage__c;
                    oppty[0].CI_Incomplete_Stage__c = NULL;
                }
                if(oppty[0].Workday_Services_Changed__c){
                	oppty[0].Workday_Services_Changed__c = False;
                }
                System.debug('CI_Incomplete_Stage__c: '+ oppty[0].CI_Incomplete_Stage__c);
                System.debug('StageName: '+ oppty[0].StageName);
                System.debug('Workday_Services_Changed__c: '+ oppty[0].Workday_Services_Changed__c);
                OpportunityTriggerHelper.CIStageWiseFlag = True;
                update oppty[0];
        	}
            
            string s = URL.getSalesforceBaseUrl().toExternalForm() +'/'+this.opportunityId; 
            t = new PageReference(s);  
            t.setRedirect(true);       
            return t;
        }
        catch (Exception ex) {
            // report error
            ApexPages.addmessages(ex);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The Opportunity Stage is not updated due to the above validation. Please Update the Stage Value and Save the Record');
            ApexPages.addMessage(myMsg);
            // indicate error
            hasErrors = true;
            List<Opportunity> oppty = [SELECT Id, CI_Incomplete_Stage__c , Workday_Services_Changed__c, StageName FROM Opportunity WHERE Id = :opportunityId];
            this.opp.StageName = oppty[0].CI_Incomplete_Stage__c;
            this.opp.CI_Incomplete_Stage__c = NULL;
            this.opp.Workday_Services_Changed__c = NULL;
            System.debug('EX CI_Incomplete_Stage__c: '+ oppty[0].CI_Incomplete_Stage__c);
            System.debug('EX StageName: '+ oppty[0].StageName);
            System.debug('EX Workday_Services_Changed__c: '+ oppty[0].Workday_Services_Changed__c);
            string s = URL.getSalesforceBaseUrl().toExternalForm() +'/'+this.opp.Id+'/e?retURL='+URL.getSalesforceBaseUrl().toExternalForm() +'/'+this.opp.Id; 
            //string s = URL.getSalesforceBaseUrl().toExternalForm() +'/'+this.opportunityId;
            t = new PageReference(s);  
            t.setRedirect(true); 
            //t= null;
            return t;
        }
        t.setRedirect(true);       
        return t;
    }
}