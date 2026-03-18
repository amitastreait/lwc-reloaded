global class FlightAgent {

    @InvocableMethod(label='Find Flights' description='Finds available flights')
    global static List<FlightResponse> findFlights(List<FlightRequest> req) {
        List<FlightResponse> flightResponses = new List<FlightResponse>();

        List<Flight> flights = new List<Flight>();
        Flight f1 = new Flight('IX 2814', 1, false, 1000l, 20.20d, 70);
        Flight f2 = new Flight('6E 488', 2, false, 2000l, 15.15d, 120);
        Flight f3 = new Flight('6E 523', 1, false, 3000l, 13.14d, 75);
        Flight f4 = new Flight('6E 6166', 2, false, 4000l, 14.14d, 130);
        flights.add(f1);  flights.add(f2); flights.add(f3); flights.add(f4);
        AvailableFlight availableFlights = new AvailableFlight();
        availableFlights.flights = flights;

        FlightResponse fr = new FlightResponse();
        fr.aFlight = availableFlights;
        flightResponses.add(fr);

        return flightResponses;
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class FlightRequest {

        @InvocableVariable
        global String originCity;

        @InvocableVariable
        global String destinationCity;

        @InvocableVariable
        global Date dateOfTravel;

        @InvocableVariable
        global FlightRequestFilter filters;
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class FlightResponse {

        @InvocableVariable
        global AvailableFlight aFlight;
    }
}