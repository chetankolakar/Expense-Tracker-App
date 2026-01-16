public without sharing class Expense_summary_controller {
    @AuraEnabled(cacheable=false)
    public static Map<String,List<Expense__c>> getExpensesByDate(Date dateFrom, Date dateTo)
    {
        List<Expense__c> expenses=new List<Expense__c>();
        Map<String,List<Expense__c>> finalmap=new Map<String,List<Expense__c>>();
        expenses= [Select Id, Name,Expense_Amount__c,Category__c,Date__c
                   From Expense__c
                   Where Date__c >= :dateFrom
                   And Date__c <= :dateTo
                   And Category__c!='N/A'
                   order by Expense_Amount__c desc];
        for(Expense__c exp:expenses){
            if(!finalmap.containsKey(exp.Category__c)){
                List<Expense__c> tempexpenses=new List<Expense__c>();
                tempexpenses.add(exp);
                finalmap.put(exp.Category__c,tempexpenses);
            }
            else{
                finalmap.get(exp.Category__c).add(exp);
            }
        }
        return finalmap;
    } 
    @AuraEnabled(cacheable=false)
    public static summaryWrappers expensesSummary()
    {
        List<summaryWrappers> summaries=new List<summaryWrappers>();
        summaryWrappers summary=new summaryWrappers();
        List<Expense__c> expenses=new List<Expense__c>();
        List<Retun__c> returns=[Select Id,Date__c,Profit__c,Return_type__c from Retun__c where Return_type__c='Mutual fund'];
        Map<String,Integer> sumMap=new Map<String,Integer>();
        Integer numberofMonths=0;
        Integer netexpenditure=0;
        expenses= [Select Id, Name,Expense_Amount__c,Category__c,Date__c,Return_Status__c
                   From Expense__c
                   ORDER BY Date__c
                   Limit 9999];
        for(Expense__c exp:expenses){
            if(exp.Category__c=='Savings'){
                summary.totalSaving=summary.totalSaving+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Category__c=='N/A' && exp.Return_Status__c=='Not yet'){
                summary.outStandingamt=summary.outStandingamt+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' && (exp.Category__c=='Mummy' || exp.Category__c=='Home' || 
                                                exp.Category__c=='Akshay education')){
                                                    summary.familyContribution=summary.familyContribution+(Integer)exp.Expense_Amount__c; 
                                                }
            if(exp.Return_Status__c=='Self' && exp.Category__c=='Akshay education'){
                summary.akshayTotal=summary.akshayTotal+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' && (exp.Category__c=='Personel use' || exp.Category__c=='Enjoyment')){
                summary.ownExpenditure=summary.ownExpenditure+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' && exp.Category__c!='N/A'){
                summary.totalEarning=summary.totalEarning+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Date__c>=System.today().toStartOfMonth()){
                if(exp.Return_Status__c=='Self' && exp.Category__c!='Savings' && exp.Category__c!='Loan' && exp.Category__c!='Home Loan EMI'){
                    summary.thisMonthTotal=summary.thisMonthTotal+(Integer)exp.Expense_Amount__c;
                }
                if(exp.Return_Status__c=='Self' && exp.Category__c!='Savings' && exp.Category__c=='Home Loan EMI'){
                    summary.presentMonthLoanPaid=summary.presentMonthLoanPaid+(Integer)exp.Expense_Amount__c;
                }
                if(exp.Return_Status__c=='Self' && exp.Category__c=='Savings'){
                    summary.presentMonthSavings=summary.presentMonthSavings+(Integer)exp.Expense_Amount__c;
                }
            }
            if(exp.Return_Status__c=='Self' &&  exp.Category__c=='Loan'){
                summary.totalLoan=summary.totalLoan+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' && exp.Category__c=='Other'){
                summary.otherExpenditure=summary.otherExpenditure+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' && exp.Category__c=='Shopping'){
                summary.totalShopping=summary.totalShopping+(Integer)exp.Expense_Amount__c;
            }
            if(exp.Return_Status__c=='Self' &&  exp.Category__c=='Home Loan EMI'){
                summary.newHomeLoanEMI = summary.newHomeLoanEMI + (Integer)exp.Expense_Amount__c;
                summary.totalHomeLoanEmis = summary.totalHomeLoanEmis + 1;
            }
            if(exp.Return_Status__c=='Self' &&  exp.Category__c=='New Home'){
                summary.newHomeExpenditure = summary.newHomeExpenditure + (Integer)exp.Expense_Amount__c;
            }
        }
        netexpenditure=summary.totalEarning-summary.totalSaving;
        summary.familycontributionpercent=(Integer)((((Double)summary.familyContribution/(Double)summary.totalEarning)*100));
        summary.ownExpenditurepercent=(Integer)((((Double)summary.ownExpenditure/(Double)summary.totalEarning)*100));
        summary.savingspercent=(Integer)((((Double)summary.totalSaving/(Double)summary.totalEarning)*100));
        summary.loanpercent =(Integer)((((Double)summary.totalLoan/(Double)summary.totalEarning)*100));
        summary.totalShoppingPercent=(Integer)((((Double)summary.totalShopping/(Double)summary.totalEarning)*100));
        summary.otherPercent=(Integer)((((Double)summary.otherExpenditure/(Double)summary.totalEarning)*100));
        summary.akshayPercent=(Integer)((((Double)summary.akshayTotal/(Double)summary.totalEarning)*100));
        numberofMonths=noOfMonths();
        summary.monthlyAverageFamily=(Integer)((((Double)summary.familyContribution/numberofMonths)));
        summary.monthlyAveragePersonel=(Integer)((((Double)summary.ownExpenditure/numberofMonths)));
		summary.monthlyEarning=(Integer)((((Double)summary.totalEarning/numberofMonths)));
        summary.newHomeTotalExpenditure = summary.newHomeLoanEMI + summary.newHomeExpenditure;
        //summaries.add(summary);
        summary.newHomePercent = (Integer)((((Double)summary.newHomeExpenditure/(Double)summary.totalEarning)*100));
        summary.newHomeEmiPercent = (Integer)((((Double)summary.newHomeLoanEMI/(Double)summary.totalEarning)*100));
        summary.newHomeTotalPercent = (Integer)((((Double)summary.newHomeTotalExpenditure/(Double)summary.totalEarning)*100));
        summary.mutualFundReturn = (Integer)returns[0].Profit__c;
        summary.overAllSavings = summary.totalSaving + summary.mutualFundReturn;
        summary.returnUpdatedDate = returns[0].Date__c;
        summary.presentMonthTotal = summary.thisMonthTotal + summary.presentMonthLoanPaid+summary.presentMonthSavings;
        System.debug('hhh summary '+summary);
        System.debug('hhh summary 2 '+summary.mutualFundReturn);
        System.debug('hhh summary 3 '+summary.overAllSavings);
        System.debug('hhh summary4  '+summary.returnUpdatedDate);
        System.debug('hhh present month loan  '+summary.presentMonthLoanPaid);
        System.debug('hhh presentMonthTotal '+summary.presentMonthTotal);
        return summary;
    } 
     @AuraEnabled(cacheable=false)
    public static List<catogoryWrapper> analyzeExpenditure()
    {   
        List<catogoryWrapper> summaries =  new List<catogoryWrapper>();
        Date today = Date.today();
        Date firstOfLastMonth = today.toStartOfMonth().addMonths(-1);
        String SELF = 'Self';
        String query = 'Select Id, Name,Expense_Amount__c,Category__c,Date__c,Return_Status__c From Expense__c WHERE Date__c >= :firstOfLastMonth AND Date__c <= :today AND Return_Status__c= :SELF ORDER BY Date__c';
        List<String> catogories = getPicklistValues('Expense__c', 'Category__c') ;
        List<Expense__c> expenses = Database.query(query);
        Map<String,Map<String,Integer>> catogoryValues = new  Map<String,Map<String,Integer>>();
        for(String catogory: catogories){
           Map<String,Integer> catogorySumValues = new Map<String,Integer>();
            for(Expense__c exp:expenses){
                System.debug('hhh exp '+exp);
                if(exp.Category__c != null && exp.Category__c == catogory && exp.Date__c>=today.toStartOfMonth()){
                    if(catogorySumValues!=null && !catogorySumValues.isEmpty()  &&  catogorySumValues.containsKey('thisMonthTotal')){
                        Integer sum = catogorySumValues.get('thisMonthTotal')+(Integer)exp.Expense_Amount__c;
                        catogorySumValues.put('thisMonthTotal',sum);
                    }
                    else{
                        catogorySumValues.put('thisMonthTotal',(Integer)exp.Expense_Amount__c);
                    }
                }
                else if(exp.Category__c != null && exp.Category__c == catogory && exp.Date__c<=today.toStartOfMonth()){
                    if(catogorySumValues!=null && !catogorySumValues.isEmpty()  &&  catogorySumValues.containsKey('lastMonthTotal')){
                        Integer sum = catogorySumValues.get('lastMonthTotal')+(Integer)exp.Expense_Amount__c;
                        catogorySumValues.put('lastMonthTotal',sum);
                    }
                    else{
                        catogorySumValues.put('lastMonthTotal',(Integer)exp.Expense_Amount__c);
                    }
                }
            }
            if(catogorySumValues != null && !catogorySumValues.isEmpty()){
                System.debug('hhh catogorySumValues '+catogorySumValues);
                catogoryValues.put(catogory,catogorySumValues);
                catogoryWrapper summary = new catogoryWrapper();
                summary.catogory = catogory;
                summary.lastMonthTotal = (Integer)catogoryValues.get(catogory).get('lastMonthTotal');
                summary.thisMonthTotal = (Integer)catogoryValues.get(catogory).get('thisMonthTotal');
                summary.diffAmount = (summary.lastMonthTotal != null && summary.thisMonthTotal != null ) ? summary.thisMonthTotal- summary.lastMonthTotal : 0;
                summary.percentChange =  (summary.diffAmount != null && summary.lastMonthTotal != null ) ? (Double)((((Double)summary.diffAmount/(Double)summary.lastMonthTotal)*100)) : 0;
                summary.result = (summary.diffAmount < 0)? true: false;
                summaries.add(summary);

            }
        }
        System.debug('hhh summaries '+summaries);
        return summaries;
    } 

    public class summaryWrappers {
        @AuraEnabled public Integer familyContribution=0;
        @AuraEnabled public Integer ownExpenditure=0;
        @AuraEnabled public Integer outStandingamt=0;
        @AuraEnabled public Integer thisMonthTotal=0;
        @AuraEnabled public Integer totalSaving=0;
        @AuraEnabled public Integer akshayTotal=0;
        @AuraEnabled public Integer totalEarning=0;
        @AuraEnabled public Integer familycontributionpercent;
        @AuraEnabled public Integer ownExpenditurepercent;
        @AuraEnabled public Integer savingspercent;
        @AuraEnabled public Integer totalLoan=0;
        @AuraEnabled public Integer loanpercent ;
        @AuraEnabled public Integer otherExpenditure=0;
        @AuraEnabled public Integer monthlyAverageFamily=0;
        @AuraEnabled public Integer monthlyAveragePersonel=0;
        @AuraEnabled public Integer monthlyEarning=0;
        @AuraEnabled public Integer totalShopping=0;
        @AuraEnabled public Integer totalShoppingPercent=0;
        @AuraEnabled public Integer otherPercent=0;
        @AuraEnabled public Integer akshayPercent=0;
        @AuraEnabled public Integer newHomeExpenditure=0;
        @AuraEnabled public Integer newHomeLoanEMI=0;
        @AuraEnabled public Integer newHomeTotalExpenditure=0;
        @AuraEnabled public Integer totalHomeLoanEmis=0;
        @AuraEnabled public Integer newHomePercent=0;
        @AuraEnabled public Integer newHomeEmiPercent=0;
        @AuraEnabled public Integer newHomeTotalPercent=0;
        @AuraEnabled public Integer mutualFundReturn=0;
        @AuraEnabled public Integer overAllSavings=0;
        @AuraEnabled public Date returnUpdatedDate;
        @AuraEnabled public Integer presentMonthLoanPaid=0;
        @AuraEnabled public Integer presentMonthTotal=0;
        @AuraEnabled public Integer presentMonthSavings=0;
   }
    public class catogoryWrapper {
        @AuraEnabled public String  catogory;
        @AuraEnabled public Integer lastMonthTotal=0;
        @AuraEnabled public Integer thisMonthTotal=0;
        @AuraEnabled public Integer diffAmount=0;
        @AuraEnabled public Double  percentChange=0;
        @AuraEnabled public Boolean result ;
    }
   public static Integer noOfMonths(){
        Date startDate = Date.newInstance(2021, 5, 27);
        Date today = System.today();
        return (startDate.monthsBetween(today));
   }
   public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();

        // Describe the SObject
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        if (sObjectType == null) {
            throw new IllegalArgumentException('Invalid object name');
        }

        // Describe the fields of the SObject
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = Expense__c.Category__c.getDescribe();
        if (fieldResult == null) {
            throw new IllegalArgumentException('Invalid field name');
        }
        if (fieldResult.getType() == Schema.DisplayType.Picklist) {
            // Retrieve picklist values
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        } else {
            throw new IllegalArgumentException('Field is not a picklist');
        }
        return picklistValues;
    }
}