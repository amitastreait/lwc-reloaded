import { LightningElement, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fullCalendar from '@salesforce/resourceUrl/fullcalendar';

// Import Apex method to fetch events (optional)
// import getEvents from '@salesforce/apex/EventController.getEvents';

export default class EventCalendar extends LightningElement {
    calendar;
    fullCalendarInitialized = false;

    renderedCallback() {
        if (this.fullCalendarInitialized) {
            return;
        }
        this.fullCalendarInitialized = true;

        console.log('Static Resource URL:', fullCalendar);
        // Use non-minified version for better error messages during debugging
        const scriptPath = fullCalendar + '/fullcalendar_6_1/dist/index.global.js';
        console.log('Loading script from:', scriptPath);

        // Load FullCalendar library (only the global build, not both)
        loadScript(this, scriptPath)
        .then(() => {
            console.log('Script loaded successfully');
            console.log('Checking what is available in window object...');
            console.log('window.FullCalendar:', window.FullCalendar);
            console.log('All window keys related to calendar:', Object.keys(window).filter(key => key.toLowerCase().includes('calendar')));
            console.log('All window keys related to full:', Object.keys(window).filter(key => key.toLowerCase().includes('full')));

            this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Libraries Loaded',
                    variant: 'success'
                })
            );
            // Small delay to ensure FullCalendar is fully initialized
            setTimeout(() => {
                this.initializeCalendar();
            }, 200);
        })
        .catch(error => {
            console.error('Error loading FullCalendar:', error);
            console.error('Error details:', JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading FullCalendar',
                    message: 'Check console for details: ' + error.message,
                    variant: 'error'
                })
            );
        });
    }

    initializeCalendar() {
        const calendarEl = this.template.querySelector('.calendar-container');

        console.log('Calendar element:', calendarEl);

        if (!calendarEl) {
            console.error('Calendar container not found');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Calendar container not found',
                    variant: 'error'
                })
            );
            return;
        }

        // Check if FullCalendar is available - try different possible names
        let CalendarClass = null;

        // Try to access FullCalendar from global scope (not window)
        try {
            // eslint-disable-next-line no-undef
            if (typeof FullCalendar !== 'undefined') {
                console.log('Found global FullCalendar object');
                // eslint-disable-next-line no-undef
                CalendarClass = FullCalendar.Calendar;
                console.log('CalendarClass from FullCalendar.Calendar:', CalendarClass);
            }
        } catch (e) {
            console.log('FullCalendar not in global scope:', e.message);
        }

        // Fallback: try window.FullCalendar
        if (!CalendarClass && typeof window.FullCalendar !== 'undefined') {
            console.log('Found window.FullCalendar');
            CalendarClass = window.FullCalendar.Calendar;
        }

        // Fallback: try window.Calendar directly
        if (!CalendarClass && typeof window.Calendar !== 'undefined') {
            console.log('Found window.Calendar');
            CalendarClass = window.Calendar;
        }

        if (!CalendarClass) {
            console.error('FullCalendar is not loaded');
            console.log('Checking all window properties containing "cal":',
                Object.keys(window).filter(k => k.toLowerCase().includes('cal')));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'FullCalendar library not loaded properly. Check console.',
                    variant: 'error'
                })
            );
            return;
        }

        console.log('Initializing FullCalendar with CalendarClass:', CalendarClass);

        // Sample events data
        const events = this.getSampleEvents();

        // Initialize FullCalendar
        this.calendar = new CalendarClass(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
            },
            events: events,
            eventClick: this.handleEventClick.bind(this),
            dateClick: this.handleDateClick.bind(this),
            editable: true,
            selectable: true,
            selectMirror: true,
            dayMaxEvents: true,
            weekends: true,
            height: 'auto',
            eventTimeFormat: {
                hour: '2-digit',
                minute: '2-digit',
                meridiem: 'short'
            }
        });

        console.log('Calendar instance created:', this.calendar);

        try {
            this.calendar.render();
            console.log('Calendar rendered successfully');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Calendar loaded successfully',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error('Error rendering calendar:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error rendering calendar: ' + error.message,
                    variant: 'error'
                })
            );
        }
    }

    getSampleEvents() {
        // Sample events - replace with actual Salesforce Event data
        return [
            {
                id: '1',
                title: 'Team Meeting',
                start: new Date().toISOString(),
                end: new Date(Date.now() + 3600000).toISOString(),
                backgroundColor: '#1589EE',
                borderColor: '#1589EE'
            },
            {
                id: '2',
                title: 'Client Presentation',
                start: new Date(Date.now() + 86400000).toISOString(),
                end: new Date(Date.now() + 90000000).toISOString(),
                backgroundColor: '#E74C3C',
                borderColor: '#E74C3C'
            },
            {
                id: '3',
                title: 'Sprint Planning',
                start: new Date(Date.now() + 172800000).toISOString(),
                end: new Date(Date.now() + 176400000).toISOString(),
                backgroundColor: '#16A34A',
                borderColor: '#16A34A'
            },
            {
                id: '4',
                title: 'Code Review',
                start: new Date(Date.now() + 259200000).toISOString(),
                backgroundColor: '#F59E0B',
                borderColor: '#F59E0B',
                allDay: true
            }
        ];
    }

    // Uncomment this method to fetch events from Salesforce
    /*
    @wire(getEvents)
    wiredEvents({ error, data }) {
        if (data) {
            // Transform Salesforce events to FullCalendar format
            const events = data.map(event => ({
                id: event.Id,
                title: event.Subject,
                start: event.StartDateTime,
                end: event.EndDateTime,
                description: event.Description,
                location: event.Location
            }));

            if (this.calendar) {
                this.calendar.removeAllEvents();
                this.calendar.addEventSource(events);
            }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading events',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
    */

    handleEventClick(info) {
        // Handle event click
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Event Details',
                message: `Event: ${info.event.title}`,
                variant: 'info'
            })
        );

        // You can add more logic here, like opening a modal with event details
        console.log('Event clicked:', info.event);
    }

    handleDateClick(info) {
        // Handle date click
        console.log('Date clicked:', info.dateStr);

        // You can add logic to create a new event on date click
        // For example, open a modal to create a new event
    }

    // Method to refresh calendar events
    refreshCalendar() {
        if (this.calendar) {
            this.calendar.refetchEvents();
        }
    }

    disconnectedCallback() {
        // Cleanup
        if (this.calendar) {
            this.calendar.destroy();
        }
    }
}
