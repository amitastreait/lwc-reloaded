public with sharing class ProductController {
   
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        return [SELECT Id, Name, Description FROM Product2 LIMIT 10];
    }
}