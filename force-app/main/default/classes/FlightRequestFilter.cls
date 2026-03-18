@JsonAccess(serializable='always' deserializable='always')
global class FlightRequestFilter {

    @AuraEnabled
    global Long price;

    @AuraEnabled
    global Double discountPercentage;
}