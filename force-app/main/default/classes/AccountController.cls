public with sharing class AccountController {
    
    @AuraEnabled
    public static List<Account> getAllAccounts(){
        return [SELECT Id, Name, Industry, Rating, Phone, Fax, Description, AnnualRevenue FROM Account ];
    }

    @AuraEnabled
    public static List<Account> getAllAccountsByIndustry(String industry){
        return [SELECT Id, Name, Industry, Rating, Phone, Fax, Description, AnnualRevenue FROM Account WHERE Industry =: industry];
    }
}