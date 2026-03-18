@JsonAccess(serializable='always' deserializable='always')
global class AvailableFlight {
    @AuraEnabled
    global List<Flight> flights;
}