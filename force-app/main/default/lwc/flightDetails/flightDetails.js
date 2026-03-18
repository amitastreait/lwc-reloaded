import { LightningElement, api } from "lwc";

export default class FlightDetails extends LightningElement {
  @api value;
  flightData = [];

  // Method to convert duration from minutes to hours and minutes
  formattedDuration(durationInMin) {
    if (durationInMin) {
      const hours = Math.floor(durationInMin / 60); // Get whole hours
      const minutes = durationInMin % 60; // Get remaining minutes
      return `${hours} hr ${minutes} min`;
    }
    return;
  }

  // Method to calculate arrival time based on departure time and duration
  arrivalTime(durationInMin) {
    const hours = 7,
      minutes = 0;
    const departureDate = new Date(2025, 0, 1, hours, minutes); // Sample date for calculation

    const arrivalDate = new Date(departureDate.getTime() + durationInMin * 60000); // Add duration to departure time

    const arrivalHours = String(arrivalDate.getHours()).padStart(2, "0");
    const arrivalMinutes = String(arrivalDate.getMinutes()).padStart(2, "0");

    return `${arrivalHours}:${arrivalMinutes}`;
  }

  connectedCallback() {
    const flights = this.value?.flights || [];
    this.flightData = flights.map((flight) => ({
      ...flight,
      petAllowedStatus: flight.isPetAllowed ? "Yes" : "No",
      durationInHr: this.formattedDuration(flight.durationInMin),
      departureTime: "07:00",
      arrivalInHr: this.arrivalTime(flight.durationInMin),
    }));
  }
}