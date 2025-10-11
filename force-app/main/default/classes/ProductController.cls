public with sharing class ProductController {
   
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        return [SELECT Id, Name, Description FROM Product2 LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductsByProductCode(String productCode, String productFamily){
        return [SELECT Id, Name, Description, ProductCode FROM Product2 WHERE ProductCode =:productCode LIMIT 10];
    }
}