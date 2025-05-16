# Salesforce Lightning Web Components Cheat Sheet

## Table of Contents
1. [Basic LWC Structure](#basic-lwc-structure)
2. [Component Communication](#component-communication)
3. [Data Binding](#data-binding)
4. [Lifecycle Hooks](#lifecycle-hooks)
5. [Event Handling](#event-handling)
6. [Navigation](#navigation)
7. [Conditional Rendering & Looping](#conditional-rendering--looping)
8. [JavaScript Essentials](#javascript-essentials)
9. [Async, Await & Promises](#async-await--promises)
10. [Lightning Data Service (LDS)](#lightning-data-service-lds)
11. [Wire Service](#wire-service)
12. [Base Components](#base-components)
13. [Best Practices](#best-practices)

---

## Basic LWC Structure

### Component Bundle Structure
A typical LWC component bundle includes:
```
myComponent/
  ├── myComponent.html    // Template
  ├── myComponent.js      // JavaScript controller
  ├── myComponent.css     // Styles (optional)
  ├── myComponent.svg     // Icon (optional)
  └── myComponent.js-meta.xml // Configuration metadata
```

### HTML Template
```html
<template>
    <div class="container">
        <h1>Hello, {name}!</h1>
        <lightning-button label="Click Me" onclick={handleClick}></lightning-button>
    </div>
</template>
```
**When to use:** All LWC components must have an HTML template file with a root `<template>` tag that contains all markup.

### JavaScript Controller
```javascript
import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    name = 'World';
    
    handleClick() {
        this.name = 'Lightning Web Components';
    }
}
```
**When to use:** Every component needs a JavaScript controller to define properties and methods.

### CSS Styles (Component-scoped)
```css
.container {
    padding: 10px;
    background-color: #f8f8f8;
    border-radius: 4px;
}

h1 {
    color: #1589ee;
    font-size: 1.5rem;
}
```
**When to use:** Add component-specific styling that's automatically scoped only to this component.

### Configuration Metadata
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>57.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>
```
**When to use:** Control where your component can be used and define properties.

---

## Component Communication

### @api - Public Properties/Methods
```javascript
import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    @api title;
    @api description;
    
    @api
    reset() {
        // Method accessible by parent
        this.title = '';
        this.description = '';
    }
}
```
**When to use:** Make properties and methods available to parent components. Creates a public API for your component.

### Parent-to-Child Communication
Parent component:
```html
<template>
    <c-child-component 
        title="My Title" 
        description="My Description"
        onchildaction={handleChildAction}>
    </c-child-component>
    <lightning-button label="Reset Child" onclick={resetChild}></lightning-button>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    handleChildAction(event) {
        console.log('Child action:', event.detail);
    }
    
    resetChild() {
        this.template.querySelector('c-child-component').reset();
    }
}
```
**When to use:** When a parent component needs to pass data down to a child component or call methods on it.

### Child-to-Parent Communication
Child component:
```javascript
import { LightningElement } from 'lwc';

export default class ChildComponent extends LightningElement {
    fireAction() {
        // Create a custom event
        const event = new CustomEvent('childaction', {
            detail: { message: 'Action from child component' }
        });
        this.dispatchEvent(event);
    }
}
```
**When to use:** When a child component needs to notify a parent component of changes or actions.

---

## Data Binding

### One-Way Data Binding
```html
<template>
    <div>Hello, {name}!</div>
    <div>Expression: {capitalizedName}</div>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class OneWayBinding extends LightningElement {
    name = 'Salesforce';
    
    get capitalizedName() {
        return this.name.toUpperCase();
    }
}
```
**When to use:** For displaying data in the template that updates automatically when JavaScript properties change.

### Two-Way Data Binding
```html
<template>
    <lightning-input 
        label="Enter your name" 
        value={name} 
        onchange={handleChange}>
    </lightning-input>
    <div>Hello, {name}!</div>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class TwoWayBinding extends LightningElement {
    name = '';
    
    handleChange(event) {
        this.name = event.target.value;
    }
}
```
**When to use:** When you need to both display data and update it based on user input.

---

## Lifecycle Hooks

### constructor()
```javascript
import { LightningElement } from 'lwc';

export default class LifecycleDemo extends LightningElement {
    constructor() {
        super(); // Must call super() first
        
        // Initialize properties
        this.privateProperty = 'initialized';
        
        // Don't access DOM elements here - they don't exist yet
        // Don't add event listeners here
    }
}
```
**When to use:** For basic property initialization and setting up initial state. Cannot access the DOM.

### connectedCallback()
```javascript
import { LightningElement } from 'lwc';

export default class LifecycleDemo extends LightningElement {
    connectedCallback() {
        // Called when component is inserted into the DOM
        console.log('Component connected to DOM');
        
        // Subscribe to events
        window.addEventListener('resize', this.handleResize.bind(this));
    }
    
    handleResize() {
        // Handle window resize
    }
}
```
**When to use:** For setup that requires the component to be in the DOM, like adding global event listeners or initializing third-party libraries.

### renderedCallback()
```javascript
import { LightningElement } from 'lwc';

export default class LifecycleDemo extends LightningElement {
    renderedCallback() {
        // Called after every render of the component
        // Access DOM elements safely here
        const divElement = this.template.querySelector('div');
        if (divElement) {
            // DOM manipulation goes here
        }
    }
}
```
**When to use:** When you need to access or manipulate the DOM after render, or use third-party libraries that need rendered elements.

### disconnectedCallback()
```javascript
import { LightningElement } from 'lwc';

export default class LifecycleDemo extends LightningElement {
    disconnectedCallback() {
        // Called when component is removed from the DOM
        console.log('Component disconnected from DOM');
        
        // Clean up resources and event listeners
        window.removeEventListener('resize', this.handleResize);
    }
}
```
**When to use:** For cleanup when a component is removed, such as removing event listeners or unsubscribing from channels.

### errorCallback(error, stack)
```javascript
import { LightningElement } from 'lwc';

export default class ErrorHandlingDemo extends LightningElement {
    errorCallback(error, stack) {
        // Handle errors in child components
        console.error('Error in child component:', error);
        console.error('Stack trace:', stack);
        
        // Log error to custom service or display fallback UI
    }
}
```
**When to use:** To catch and handle errors that occur in a child component during render.

---

## Event Handling

### Standard DOM Events
```html
<template>
    <lightning-button 
        label="Click Me"
        onclick={handleClick}>
    </lightning-button>
    
    <input 
        type="text"
        onkeyup={handleKeyUp}
        onblur={handleBlur} />
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class EventsDemo extends LightningElement {
    handleClick(event) {
        console.log('Button clicked!');
        // event.target contains the element that triggered the event
    }
    
    handleKeyUp(event) {
        if (event.key === 'Enter') {
            console.log('Enter key pressed');
        }
    }
    
    handleBlur(event) {
        console.log('Input lost focus');
    }
}
```
**When to use:** For handling standard HTML element events like clicks, focus changes, or key presses.

### Custom Events
```javascript
// Child component that fires a custom event
import { LightningElement } from 'lwc';

export default class CustomEventDemo extends LightningElement {
    handleButtonClick() {
        // Create and dispatch a basic custom event
        this.dispatchEvent(new CustomEvent('simple'));
        
        // Create and dispatch a custom event with data
        this.dispatchEvent(new CustomEvent('withdata', {
            detail: {
                id: 123,
                name: 'Sample Record',
                status: 'Active'
            },
            bubbles: false,
            composed: false
        }));
    }
}
```

Parent component handling the custom event:
```html
<template>
    <c-custom-event-demo
        onsimple={handleSimpleEvent}
        onwithdata={handleDataEvent}>
    </c-custom-event-demo>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    handleSimpleEvent() {
        console.log('Simple event received');
    }
    
    handleDataEvent(event) {
        const data = event.detail;
        console.log('Data received:', data);
        console.log('Record ID:', data.id);
    }
}
```
**When to use:** When components need to communicate events or data changes upward through the component hierarchy.

---

## Navigation

### Navigate to Record Page
```javascript
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigationDemo extends NavigationMixin(LightningElement) {
    navigateToRecord() {
        // Navigate to a record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '001xxxxxxxxxxxxxxx',  // Record ID
                objectApiName: 'Account',        // Object API name
                actionName: 'view'               // 'view', 'edit', or 'clone'
            }
        });
    }
}
```
**When to use:** To navigate to a specific record in view or edit mode.

### Navigate to Object Home
```javascript
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigationDemo extends NavigationMixin(LightningElement) {
    navigateToObjectHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'home'
            }
        });
    }
}
```
**When to use:** To navigate to an object's list view or home page.

### Navigate to Named Page
```javascript
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigationDemo extends NavigationMixin(LightningElement) {
    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
    
    navigateToChatter() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'chatter'
            }
        });
    }
}
```
**When to use:** To navigate to standard Salesforce pages like Home, Chatter, Reports, etc.

### Navigate to Web Page
```javascript
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NavigationDemo extends NavigationMixin(LightningElement) {
    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.salesforce.com'
            }
        });
    }
}
```
**When to use:** To navigate to an external website.

### Generate Page Reference and Navigate
```javascript
import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class NavigationDemo extends NavigationMixin(LightningElement) {
    // Get current page reference
    @wire(CurrentPageReference)
    pageRef;
    
    navigateToNewRecord() {
        // Generate a URL for a page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            }
        }).then(url => {
            // Use the URL for a link or redirect
            window.open(url, '_blank');
        });
    }
}
```
**When to use:** To get URLs for navigation without immediately navigating, such as for creating links.

---

## Conditional Rendering & Looping

### Conditional Rendering with if:true|false
```html
<template>
    <div>
        <template if:true={isVisible}>
            <p>This content is visible</p>
        </template>
        
        <template if:false={isVisible}>
            <p>This content shows when isVisible is false</p>
        </template>
        
        <lightning-button 
            label="Toggle Visibility"
            onclick={toggleVisibility}>
        </lightning-button>
    </div>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class ConditionalDemo extends LightningElement {
    isVisible = true;
    
    toggleVisibility() {
        this.isVisible = !this.isVisible;
    }
}
```
**When to use:** For simple show/hide operations based on a boolean condition.

### Looping with for:each and iterator
Using for:each:
```html
<template>
    <ul class="list">
        <template for:each={contacts} for:item="contact">
            <li key={contact.Id}>
                {contact.Name} - {contact.Email}
            </li>
        </template>
    </ul>
</template>
```

Using iterator for first/last identification:
```html
<template>
    <ul class="list">
        <template iterator:it={contacts}>
            <li key={it.value.Id} class={it.customClass}>
                <!-- it.value contains the current item -->
                <!-- it.index contains the index -->
                <!-- it.first is true for the first item -->
                <!-- it.last is true for the last item -->
                
                {it.value.Name}
                <template if:true={it.first}>
                    (First Contact)
                </template>
                <template if:true={it.last}>
                    (Last Contact)
                </template>
            </li>
        </template>
    </ul>
</template>
```

```javascript
import { LightningElement } from 'lwc';

export default class LoopingDemo extends LightningElement {
    contacts = [
        { Id: '001', Name: 'Amy Taylor', Email: 'amy@example.com' },
        { Id: '002', Name: 'Michael Jones', Email: 'michael@example.com' },
        { Id: '003', Name: 'Jennifer Wu', Email: 'jennifer@example.com' }
    ];
}
```
**When to use:** `for:each` for simple list rendering and `iterator` when you need index or first/last item information.

---

## JavaScript Essentials

### Importing Static Resources
```javascript
import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/companyLogo';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class ResourceDemo extends LightningElement {
    logoUrl;
    
    connectedCallback() {
        // Set the URL for an image
        this.logoUrl = LOGO;
        
        // Load a JavaScript file from a static resource
        loadScript(this, LOGO + '/js/library.js')
            .then(() => {
                console.log('Script loaded successfully');
            })
            .catch(error => {
                console.error('Error loading script', error);
            });
            
        // Load a CSS file from a static resource
        loadStyle(this, LOGO + '/css/styles.css')
            .then(() => {
                console.log('Styles loaded successfully');
            })
            .catch(error => {
                console.error('Error loading styles', error);
            });
    }
}
```
**When to use:** To include external JavaScript libraries, CSS files, or images from Salesforce static resources.

### Working with @track Property
```javascript
import { LightningElement, track } from 'lwc';

export default class TrackDemo extends LightningElement {
    // No longer needed for primitive values in recent versions
    // but still useful for complex objects
    @track customer = {
        name: 'John Doe',
        address: {
            street: '123 Main St',
            city: 'San Francisco',
            state: 'CA'
        }
    };
    
    updateAddress() {
        // Changes to nested properties are tracked and trigger re-render
        this.customer.address.city = 'New City';
    }
}
```
**When to use:** For reactive nested objects where you need to track deep property changes. For primitive values, `@track` is no longer required in modern LWC versions.

### Importing Labels, Schema, and User Info
```javascript
import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';

// Import custom labels
import helloLabel from '@salesforce/label/c.Hello_World';
import infoLabel from '@salesforce/label/c.Information_Message';

// Import object fields
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';

// Import user info
import USER_ID from '@salesforce/user/Id';
import IS_GUEST from '@salesforce/user/isGuest';

export default class SchemaDemo extends LightningElement {
    // Label references
    label = {
        hello: helloLabel,
        info: infoLabel
    };
    
    // User info
    userId = USER_ID;
    isGuest = IS_GUEST;
    
    // Wire current page reference
    @wire(CurrentPageReference)
    pageRef;
    
    // Wire object info
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountInfo;
    
    // Wire specific record
    @wire(getRecord, { 
        recordId: '$recordId',
        fields: [NAME_FIELD, REVENUE_FIELD]
    })
    account;
    
    get recordId() {
        // Get recordId from pageRef
        return this.pageRef?.state?.recordId;
    }
}
```
**When to use:** To access custom labels, object schema information, or current user context in your components.

---

## Async, Await & Promises

### Basic Promise Usage
```javascript
import { LightningElement } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';

export default class PromiseDemo extends LightningElement {
    accounts = [];
    error;
    
    connectedCallback() {
        // Call Apex method using Promise syntax
        getAccountList()
            .then(result => {
                this.accounts = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            });
    }
}
```
**When to use:** For basic asynchronous operations where you want to handle success and error cases separately.

### Using Async/Await
```javascript
import { LightningElement } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';
import getContactList from '@salesforce/apex/ContactController.getContactList';

export default class AsyncAwaitDemo extends LightningElement {
    accounts = [];
    contacts = [];
    error;
    
    async connectedCallback() {
        try {
            // Use await to make code more readable
            this.accounts = await getAccountList();
            
            // After accounts are loaded, get related contacts
            this.contacts = await getContactList({
                accountId: this.accounts[0].Id
            });
            
            this.error = undefined;
        } catch (error) {
            this.error = error;
            this.accounts = [];
            this.contacts = [];
        }
    }
    
    async handleRefresh() {
        // Show loading indicator
        this.isLoading = true;
        
        try {
            // Multiple parallel operations with Promise.all
            const [accountsResult, contactsResult] = await Promise.all([
                getAccountList(),
                getContactList({ accountId: this.selectedAccountId })
            ]);
            
            this.accounts = accountsResult;
            this.contacts = contactsResult;
        } catch (error) {
            this.error = error;
        } finally {
            // Always hide loading indicator
            this.isLoading = false;
        }
    }
}
```
**When to use:** For cleaner, more readable asynchronous code especially when dealing with multiple sequential operations or error handling.

### Promise Methods
```javascript
import { LightningElement } from 'lwc';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';
import getContactList from '@salesforce/apex/ContactController.getContactList';
import getOpportunityList from '@salesforce/apex/OpportunityController.getOpportunityList';

export default class PromiseMethodsDemo extends LightningElement {
    dashboardData = {};
    
    connectedCallback() {
        // Parallel execution with Promise.all
        Promise.all([
            getAccountList(),
            getContactList(),
            getOpportunityList()
        ])
        .then(([accounts, contacts, opportunities]) => {
            this.dashboardData = {
                accounts,
                contacts,
                opportunities
            };
        })
        .catch(error => {
            this.error = error;
        });
    }
    
    async loadCriticalData() {
        // Promise.race - use the first response that completes
        try {
            const firstDataSource = await Promise.race([
                this.fetchFromPrimarySource(),
                this.fetchFromBackupSource()
            ]);
            
            this.criticalData = firstDataSource;
        } catch (error) {
            this.error = 'Both data sources failed';
        }
    }
    
    fetchFromPrimarySource() {
        return new Promise((resolve, reject) => {
            // Simulating API call
            setTimeout(() => {
                resolve({ source: 'primary', data: [...] });
            }, 2000);
        });
    }
    
    fetchFromBackupSource() {
        return new Promise((resolve, reject) => {
            // Simulating API call
            setTimeout(() => {
                resolve({ source: 'backup', data: [...] });
            }, 3000);
        });
    }
}
```
**When to use:** `Promise.all` for running multiple async operations in parallel and `Promise.race` when you need the first completed result from multiple sources.

---

## Lightning Data Service (LDS)

### Record Form
```html
<template>
    <lightning-record-form
        object-api-name="Account"
        record-id={recordId}
        fields={fields}
        columns="2"
        mode="view"
        onsubmit={handleSubmit}
        onsuccess={handleSuccess}
        onerror={handleError}>
    </lightning-record-form>
</template>
```

```javascript
import { LightningElement, api } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

export default class RecordFormDemo extends LightningElement {
    @api recordId;
    
    fields = [NAME_FIELD, PHONE_FIELD, WEBSITE_FIELD, INDUSTRY_FIELD];
    
    handleSubmit(event) {
        // Modify fields before submit
        const fields = event.detail.fields;
        fields.Name = fields.Name + ' (Modified)';
        
        // Prevent default submit and submit with modified fields
        event.preventDefault();
        this.template.querySelector('lightning-record-form').submit(fields);
    }
    
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'Record updated successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }
    
    handleError(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.message,
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
    }
}
```
**When to use:** For quick implementation of record forms with minimal code. Great for standard create, edit, or view forms.

### Record View Form
```html
<template>
    <lightning-record-view-form
        record-id={recordId}
        object-api-name="Contact">
        
        <div class="slds-grid slds-gutters">
            <div class="slds-col">
                <lightning-output-field field-name="Name"></lightning-output-field>
                <lightning-output-field field-name="Email"></lightning-output-field>
            </div>
            <div class="slds-col">
                <lightning-output-field field-name="Phone"></lightning-output-field>
                <lightning-output-field field-name="Title"></lightning-output-field>
            </div>
        </div>
        
    </lightning-record-view-form>
</template>
```

```javascript
import { LightningElement, api } from 'lwc';

export default class RecordViewFormDemo extends LightningElement {
    @api recordId;
}
```
**When to use:** For read-only display of record data with field labels and formatting already handled.

### Record Edit Form
```html
<template>
    <lightning-record-edit-form
        record-id={recordId}
        object-api-name="Contact"
        onsubmit={handleSubmit}
        onsuccess={handleSuccess}>
        
        <lightning-messages></lightning-messages>
        
        <div class="slds-grid slds-gutters">
            <div class="slds-col">
                <lightning-input-field field-name="FirstName"></lightning-input-field>
                <lightning-input-field field-name="LastName"></lightning-input-field>
            </div>
            <div class="slds-col">
                <lightning-input-field field-name="Email"></lightning-input-field>
                <lightning-input-field field-name="Phone"></lightning-input-field>
            </div>
        </div>
        
        <div class="slds-m-top_medium">
            <lightning-button
                type="submit"
                variant="brand"
                label="Save">
            </lightning-button>
        </div>
        
    </lightning-record-edit-form>
</template>
```

```javascript
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordEditFormDemo extends LightningElement {
    @api recordId;
    
    handleSubmit(event) {
        // Optional: prevent default submit and handle manually
        // event.preventDefault();
        // Add custom logic
    }
    
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success!',
            message: 'Contact updated',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }
}
```
**When to use:** For editable forms with more control over layout while still leveraging Salesforce's field validation and save functionality.

### Using getRecord and updateRecord
```javascript
import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import the fields
import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';

export default class GetUpdateRecordDemo extends LightningElement {
    @api recordId;
    account;
    name = '';
    phone = '';
    website = '';
    
    // Get record data
    @wire(getRecord, { 
        recordId: '$recordId',
        fields: [NAME_FIELD, PHONE_FIELD, WEBSITE_FIELD]
    })
    wiredAccount({ error, data }) {
        if (data) {
            this.account = data;
            this.name = this.account.fields.Name.value;
            this.phone = this.account.fields.Phone.value;
            this.website = this.account.fields.Website.value;
        } else if (error) {
            this.handleError(error);
        }
    }
    
    handleNameChange(event) {
        this.name = event.target.value;
    }
    
    handlePhoneChange(event) {
        this.phone = event.target.value;
    }
    
    handleWebsiteChange(event) {
        this.website = event.target.value;
    }
    
    async saveAccount() {
        // Create the recordInput object
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[PHONE_FIELD.fieldApiName] = this.phone;
        fields[WEBSITE_FIELD.fieldApiName] = this.website;
        
        const recordInput = { fields };
        
        try {
            // Update the record
            await updateRecord(recordInput);
            
            // Show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account updated',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.handleError(error);
        }
    }
    
    handleError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error'
            })
        );
    }
}
```