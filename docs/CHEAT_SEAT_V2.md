# Detailed Lightning Web Components (LWC) Cheat Sheet

This cheat sheet is a comprehensive guide to Salesforce Lightning Web Components (LWC) development, covering essential concepts, patterns, and best practices with detailed examples, advanced use cases, and Salesforce-specific considerations.

---

## 1. Basic LWC Structure and Component Composition

### Overview
LWC components are modular, reusable building blocks for Salesforce Lightning applications, adhering to modern web standards. A component bundle includes:
- **HTML**: Defines the template.
- **JavaScript**: Contains logic and state.
- **CSS**: Scoped styles for the component.
- **Metadata (js-meta.xml)**: Configures visibility and deployment targets.

### Example: Basic Component
```html
<!-- myComponent.html -->
<template>
  <div class="slds-p-around_medium">
    <h1 class="slds-text-heading_large">{greeting}</h1>
    <c-child-component message={childMessage}></c-child-component>
  </div>
</template>
```

```javascript
// myComponent.js
import { LightningElement, api } from 'lwc';
export default class MyComponent extends LightningElement {
    @api greeting = 'Welcome to LWC!';
    childMessage = 'Hello from Parent';

    get capitalizedGreeting() {
        return this.greeting.toUpperCase();
    }
}
```

```css
/* myComponent.css */
:host {
    display: block;
    background-color: #f4f6f9;
}
h1 {
    color: #16325c;
}
```

```xml
<!-- myComponent.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>
```

### Usage Guidance
- **Purpose**: Create reusable UI components that integrate with Salesforce Lightning.
- **When to Use**: Use for custom UI elements in Lightning Apps, Experience Cloud, or record pages.
- **Advanced Use Cases**:
  - Compose complex UIs by nesting components (e.g., a form with multiple child input components).
  - Use slots for flexible content injection in child components.
- **Pitfalls**:
  - Avoid large, monolithic components; break them into smaller, reusable ones.
  - Don’t omit the `js-meta.xml` file or misconfigure targets, as this prevents deployment.
  - Avoid inline styles; use CSS files for maintainability.
- **Best Practices**:
  - Follow Salesforce Lightning Design System (SLDS) for consistent styling.
  - Use kebab-case for component names (e.g., `c-my-component`).
  - Leverage getters for computed properties to reduce state complexity.
  - Ensure components are self-contained to promote reusability.

---

## 2. Component Communication Patterns

### Parent-to-Child Communication
Pass data to child components using `@api`-decorated properties or methods.

#### Example: Passing Data and Calling Methods
```html
<!-- parentComponent.html -->
<template>
  <c-child-component
    message={parentMessage}
    record-id={recordId}
    onupdate={handleChildUpdate}>
  </c-child-component>
</template>
```

```javascript
// parentComponent.js
import { LightningElement, api } from 'lwc';
export default class ParentComponent extends LightningElement {
    @api recordId;
    parentMessage = 'Message from Parent';

    handleChildUpdate(event) {
        console.log('Child update:', event.detail);
    }
}
```

```html
<!-- childComponent.html -->
<template>
  <p>{message}</p>
  <button onclick={handleClick}>Update Parent</button>
</template>
```

```javascript
// childComponent.js
import { LightningElement, api } from 'lwc';
export default class ChildComponent extends LightningElement {
    @api message;
    @api recordId;

    @api
    resetMessage() {
        this.message = 'Reset';
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('update', { detail: this.recordId }));
    }
}
```

### Child-to-Parent Communication
Use custom events to send data or trigger actions in parent components.

#### Example: Custom Event with Complex Data
```html
<!-- childComponent.html -->
<template>
  <lightning-button label="Send Data" onclick={handleSend}></lightning-button>
</template>
```

```javascript
// childComponent.js
import { LightningElement } from 'lwc';
export default class ChildComponent extends LightningElement {
    handleSend() {
        const payload = { id: '001', status: 'Active' };
        const event = new CustomEvent('dataupdate', {
            detail: payload,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }
}
```

```html
<!-- parentComponent.html -->
<template>
  <c-child-component ondataupdate={handleDataUpdate}></c-child-component>
</template>
```

```javascript
// parentComponent.js
import { LightningElement } from 'lwc';
export default class ParentComponent extends LightningElement {
    handleDataUpdate(event) {
        console.log('Received:', event.detail.id, event.detail.status);
    }
}
```

### Usage Guidance
- **Parent-to-Child**: Ideal for passing configuration, record IDs, or static data to child components.
- **Child-to-Parent**: Use for user interactions or state changes that require parent handling (e.g., form submissions).
- **Advanced Use Cases**:
  - Use `bubbles: true` and `composed: true` for events that need to traverse shadow DOM boundaries.
  - Pass complex objects in event `detail` for richer communication.
- **Pitfalls**:
  - Avoid mutating `@api` properties directly in child components; use events to notify parents.
  - Overusing events can lead to complex event chains; consider pub-sub for cross-component communication.
  - Forgetting `bubbles: true` prevents events from reaching parent components in shadow DOM.
- **Best Practices**:
  - Use camelCase for event names (e.g., `ondataupdate`).
  - Validate event data in the parent to prevent errors.
  - Document event contracts (e.g., expected `detail` properties) for maintainability.
  - Consider the `pubsub` module for loosely coupled communication in large apps.

---

## 3. Data Binding Approaches

### One-Way Data Binding
LWC uses one-way data binding by default, where changes to JavaScript properties update the UI.

#### Example: One-Way Binding
```html
<!-- myComponent.html -->
<template>
  <p>Current Value: {displayValue}</p>
  <lightning-input label="Enter Value" value={inputValue} onchange={handleInputChange}></lightning-input>
</template>
```

```javascript
// myComponent.js
import { LightningElement } from 'lwc';
export default class MyComponent extends LightningElement {
    inputValue = 'Initial Value';

    get displayValue() {
        return this.inputValue.toUpperCase();
    }

    handleInputChange(event) {
        this.inputValue = event.target.value;
    }
}
```

### Two-Way Data Binding (Simulated)
LWC does not support true two-way binding; simulate it with event handlers.

#### Example: Simulated Two-Way Binding
```html
<!-- myComponent.html -->
<template>
  <lightning-input label="Name" value={name} onchange={handleNameChange}></lightning-input>
  <p>Name: {name}</p>
</template>
```

```javascript
// myComponent.js
import { LightningElement, track } from 'lwc';
export default class MyComponent extends LightningElement {
    @track name = 'Jane Doe';

    handleNameChange(event) {
        this.name = event.target.value;
    }
}
```

### Usage Guidance
- **One-Way**: Use for displaying data or computed values (e.g., via getters).
- **Two-Way (Simulated)**: Use for form inputs where user changes need to update component state.
- **Advanced Use Cases**:
  - Use getters for complex transformations (e.g., formatting dates or currencies).
  - Combine with `@track` for reactive updates to nested objects or arrays.
- **Pitfalls**:
  - Avoid direct DOM manipulation to update values; rely on reactive properties.
  - Overusing `@track` on simple properties increases memory usage.
  - Forgetting to handle `onchange` events can break two-way binding simulation.
- **Best Practices**:
  - Use getters for computed properties to keep templates clean.
  - Validate user input in event handlers to ensure data integrity.
  - Minimize state changes to avoid unnecessary re-renders.

---

## 4. Lifecycle Hooks

### Available Hooks
- **constructor()**: Initializes the component; avoid DOM access.
- **connectedCallback()**: Runs when the component is inserted into the DOM.
- **renderedCallback()**: Runs after every render; use for DOM manipulation.
- **disconnectedCallback()**: Runs when the component is removed from the DOM.
- **errorCallback(error, stack)**: Catches errors in child components.

#### Example: Lifecycle Hooks in Action
```javascript
// myComponent.js
import { LightningElement } from 'lwc';
export default class MyComponent extends LightningElement {
    constructor() {
        super();
        console.log('Constructor: Component initialized');
    }

    connectedCallback() {
        console.log('Connected: Component added to DOM');
        // Initialize resources, e.g., fetch data or set up event listeners
        window.addEventListener('resize', this.handleResize);
    }

    renderedCallback() {
        console.log('Rendered: Component rendered');
        // Example: Access DOM element after render
        const element = this.template.querySelector('.my-element');
        if (element) {
            element.style.backgroundColor = '#e6f3ff';
        }
    }

    disconnectedCallback() {
        console.log('Disconnected: Component removed from DOM');
        // Clean up resources
        window.removeEventListener('resize', this.handleResize);
    }

    errorCallback(error, stack) {
        console.error('Error in child:', error, stack);
        // Display user-friendly error message
        this.dispatchEvent(new CustomEvent('error', { detail: error.message }));
    }

    handleResize = () => {
        console.log('Window resized');
    };
}
```

### Usage Guidance
- **constructor**: Initialize state or variables; avoid side effects.
- **connectedCallback**: Fetch data, set up listeners, or initialize third-party libraries.
- **renderedCallback**: Manipulate DOM or update third-party libraries after render.
- **disconnectedCallback**: Clean up resources to prevent memory leaks.
- **errorCallback**: Log errors and provide user feedback.
- **Advanced Use Cases**:
  - Use `connectedCallback` for asynchronous data fetching with proper error handling.
  - Track first render in `renderedCallback` to avoid redundant operations.
- **Pitfalls**:
  - Avoid DOM access in `constructor`; the DOM isn’t available yet.
  - Overusing `renderedCallback` can lead to performance issues; use sparingly.
  - Forgetting to clean up in `disconnectedCallback` can cause memory leaks.
- **Best Practices**:
  - Use a boolean flag (e.g., `isRendered`) in `renderedCallback` to handle first render.
  - Log errors in `errorCallback` and notify users via toast messages.
  - Bind event handlers in `connectedCallback` and unbind in `disconnectedCallback`.

---

## 5. Event Handling

### Standard DOM Events
Handle browser events like `click`, `change`, or `keydown`.

#### Example: Handling Multiple Events
```html
<!-- myComponent.html -->
<template>
  <lightning-input label="Search" onkeyup={handleKeyUp}></lightning-input>
  <lightning-button label="Click Me" onclick={handleClick}></lightning-button>
</template>
```

```javascript
// myComponent.js
import { LightningElement } from 'lwc';
export default class MyComponent extends LightningElement {
    handleKeyUp(event) {
        if (event.key === 'Enter') {
            console.log('Search value:', event.target.value);
        }
    }

    handleClick(event) {
        console.log('Button clicked:', event.target.label);
    }
}
```

### Custom Events
Create and dispatch custom events for component communication.

#### Example: Custom Event with Validation
```html
<!-- childComponent.html -->
<template>
  <lightning-button label="Notify" onclick={handleNotify}></lightning-button>
</template>
```

```javascript
// childComponent.js
import { LightningElement } from 'lwc';
export default class ChildComponent extends LightningElement {
    handleNotify() {
        const payload = { status: 'success', message: 'Action completed' };
        const event = new CustomEvent('notify', {
            detail: payload,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);
    }
}
```

```html
<!-- parentComponent.html -->
<template>
  <c-child-component onnotify={handleNotify}></c-child-component>
</template>
```

```javascript
// parentComponent.js
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ParentComponent extends LightningElement {
    handleNotify(event) {
        if (event.detail.status === 'success') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: event.detail.message,
                    variant: 'success'
                })
            );
        }
    }
}
```

### Usage Guidance
- **Standard Events**: Use for user interactions (e.g., button clicks, form inputs).
- **Custom Events**: Use for component-to-component communication, especially across shadow DOM.
- **Advanced Use Cases**:
  - Use `composed: true` for events that need to cross shadow DOM boundaries.
  - Combine with `ShowToastEvent` for user feedback.
- **Pitfalls**:
  - Avoid inline JavaScript in HTML templates; use event handler methods.
  - Forgetting `bubbles: true` limits event propagation.
  - Overloading `detail` with large objects can impact performance.
- **Best Practices**:
  - Use descriptive, camelCase event names.
  - Validate event data to prevent errors.
  - Use `lightning/platformShowToastEvent` for user notifications.

---

## 6. Navigation Techniques

Use the `lightning/navigation` module for programmatic navigation in Salesforce.

#### Example: Navigating to Record, Tab, and URL
```javascript
// myComponent.js
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MyComponent extends LightningElement {
    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '001xxxxxxxxxxxxxxx',
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    navigateToObjectHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    navigateToExternalUrl() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.salesforce.com'
            }
        });
    }

    async generateRecordUrl() {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '001xxxxxxxxxxxxxxx',
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
        console.log('Generated URL:', url);
    }
}
```

```html
<!-- myComponent.html -->
<template>
  <lightning-button label="Go to Record" onclick={navigateToRecord}></lightning-button>
  <lightning-button label="Go to Account List" onclick={navigateToObjectHome}></lightning-button>
  <lightning-button label="Go to External URL" onclick={navigateToExternalUrl}></lightning-button>
</template>
```

### Usage Guidance
- **Purpose**: Navigate to Salesforce records, object lists, tabs, or external URLs.
- **When to Use**: Use for dynamic navigation based on user actions or logic.
- **Advanced Use Cases**:
  - Generate URLs for sharing or bookmarking with `NavigationMixin.GenerateUrl`.
  - Navigate to custom tabs or Experience Cloud pages.
- **Pitfalls**:
  - Ensure `NavigationMixin` is applied to the class.
  - Verify record IDs and object API names to avoid navigation errors.
  - Test navigation in different contexts (e.g., Lightning App, Experience Cloud).
- **Best Practices**:
  - Use `state` properties for filters or query parameters.
  - Handle navigation errors gracefully with user feedback.
  - Test navigation in both desktop and mobile Salesforce apps.

---

## 7. Conditional Rendering and Iterative Components

### Conditional Rendering
Use `if:true` and `if:false` directives to show or hide content.

#### Example: Conditional Rendering with Toggle
```html
<!-- myComponent.html -->
<template>
  <lightning-button label="Toggle Content" onclick={toggleContent}></lightning-button>
  <template if:true={isVisible}>
    <div class="slds-p-around_medium">
      <p>Visible Content</p>
    </div>
  </template>
  <template if:false={isVisible}>
    <p>Hidden Content</p>
  </template>
</template>
```

```javascript
// myComponent.js
import { LightningElement } from 'lwc';
export default class MyComponent extends LightningElement {
    isVisible = true;

    toggleContent() {
        this.isVisible = !this.isVisible;
    }
}
```

### Iterative Components
Use `for:each` for simple lists and `iterator:it` for advanced iteration with index or first/last flags.

#### Example: Iterative Rendering with Index
```html
<!-- myComponent.html -->
<template>
  <template iterator:it={items}>
    <div key={it.value.id} class={it.first ? 'slds-p-top_medium' : ''}>
      <p>{it.index}: {it.value.name}</p>
    </div>
  </template>
</template>
```

```javascript
// myComponent.js
import { LightningElement } from 'lwc';
export default class MyComponent extends LightningElement {
    items = [
        { id: '1', name: 'Item 1' },
        { id: '2', name: 'Item 2' },
        { id: '3', name: 'Item 3' }
    ];
}
```

### Usage Guidance
- **Conditional**: Control visibility of UI elements based on state or permissions.
- **Iterative**: Render dynamic lists of records or data.
- **Advanced Use Cases**:
  - Use `iterator:it` for custom styling based on index or first/last items.
  - Combine with `lightning-datatable` for complex table rendering.
- **Pitfalls**:
  - Forgetting the `key` directive in `for:each` can cause DOM rendering issues.
  - Complex logic in templates can reduce readability; move to JavaScript.
  - Avoid nested `if` and `for:each` for performance reasons.
- **Best Practices**:
  - Always provide a unique `key` for `for:each` to optimize DOM updates.
  - Use `iterator:it` for advanced list manipulation (e.g., styling first/last items).
  - Keep templates declarative and move logic to JavaScript.

---

## 8. JavaScript Essentials Specific to LWC

### Decorators
- **@api**: Exposes properties or methods to parent components.
- **@track**: Makes complex objects (arrays, objects) reactive.
- **@wire**: Fetches data reactively from Salesforce APIs or Apex.

#### Example: Using Decorators
```javascript
// myComponent.js
import { LightningElement, api, track, wire } from 'lwc';
import getAccount from '@salesforce/apex/AccountController.getAccount';

export default class MyComponent extends LightningElement {
    @api recordId;
    @track complexState = { name: 'Initial', items: [] };

    @api
    updateName(newName) {
        this.complexState.name = newName;
    }

    @wire(getAccount, { accountId: '$recordId' })
    account;

    get accountName() {
        return this.account.data ? this.account.data.Name : 'No Account';
    }
}
```

### ES Modules and Imports
LWC uses ES modules for modular JavaScript.

#### Example: Importing Modules
```javascript
// utils.js
export const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

// myComponent.js
import { LightningElement } from 'lwc';
import { formatCurrency } from 'c/utils';

export default class MyComponent extends LightningElement {
    amount = 1000;
    get formattedAmount() {
        return formatCurrency(this.amount);
    }
}
```

### Usage Guidance
- **@api**: Use for public interfaces; keep private methods undecorated.
- **@track**: Use for nested objects or arrays that need reactivity.
- **@wire**: Use for reactive data fetching.
- **ES Modules**: Use for code reuse across components.
- **Advanced Use Cases**:
  - Create utility modules for common functions (e.g., formatting, validation).
  - Use `@api` methods to expose component functionality to parent components.
- **Pitfalls**:
  - Avoid `@track` on simple properties; they’re reactive by default.
  - Don’t overuse `@api`; expose only necessary properties/methods.
  - Ensure `@wire` dependencies are reactive (e.g., use `$` for dynamic parameters).
- **Best Practices**:
  - Use getters for computed properties to simplify templates.
  - Organize utility functions in separate ES modules.
  - Validate `@api` inputs to prevent invalid data.

---

## 9. Async/Await and Promises

### Example: Fetching Data with Async/Await and Promises
```javascript
// myComponent.js
import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    accounts = [];

    async fetchAccounts() {
        try {
            this.accounts = await getAccounts();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Accounts loaded',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    fetchAccountsWithPromise() {
        getAccounts()
            .then(result => {
                this.accounts = result;
                console.log('Accounts:', result);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
}
```

### Usage Guidance
- **Async/Await**: Use for readable asynchronous code, especially with Apex calls.
- **Promises**: Use for chaining multiple asynchronous operations or when `async/await` isn’t suitable.
- **Advanced Use Cases**:
  - Chain multiple Apex calls with `Promise.all` for parallel execution.
  - Use `async/await` with `lightning/uiRecordApi` for record operations.
- **Pitfalls**:
  - Always include error handling to avoid uncaught exceptions.
  - Avoid nested promises; use `async/await` for clarity.
  - Forgetting to await async calls can lead to race conditions.
- **Best Practices**:
  - Use `ShowToastEvent` for user-friendly error messages.
  - Handle loading states with UI indicators (e.g., spinners).
  - Test asynchronous code with Jest mocks for Apex calls.

---

## 10. Lightning Data Service (LDS) Patterns

Use `lightning/uiRecordApi` for client-side CRUD operations without Apex.

#### Example: Create, Read, Update, Delete with LDS
```javascript
// myComponent.js
import { LightningElement, api, track } from 'lwc';
import { getRecord, updateRecord, createRecord, deleteRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    @api recordId;
    @track accountName;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleUpdate() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.accountName;
        fields.Id = this.recordId;

        updateRecord({ fields })
            .then(() => this.showToast('Success', 'Account updated', 'success'))
            .catch(error => this.showToast('Error', error.body.message, 'error'));
    }

    handleCreate() {
        const fields = { [NAME_FIELD.fieldApiName]: 'New Account' };
        createRecord({ apiName: ACCOUNT_OBJECT.objectApiName, fields })
            .then(record => this.showToast('Success', `Created record ${record.id}`, 'success'))
            .catch(error => this.showToast('Error', error.body.message, 'error'));
    }

    handleDelete() {
        deleteRecord(this.recordId)
            .then(() => this.showToast('Success', 'Account deleted', 'success'))
            .catch(error => this.showToast('Error', error.body.message, 'error'));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
```

```html
<!-- myComponent.html -->
<template>
  <lightning-card title="Account Details">
    <lightning-input label="Account Name" value={accountName} onchange={handleNameChange}></lightning-input>
    <lightning-button label="Update" onclick={handleUpdate}></lightning-button>
    <lightning-button label="Create New" onclick={handleCreate}></lightning-button>
    <lightning-button label="Delete" onclick={handleDelete}></lightning-button>
  </lightning-card>
</template>
```

### Usage Guidance
- **Purpose**: Perform record operations with minimal server calls, leveraging Salesforce’s caching.
- **When to Use**: Use for simple CRUD operations on single records or related records.
- **Advanced Use Cases**:
  - Use `getRecordNotifyChange` to refresh LDS cache after updates.
  - Combine with `@wire` for reactive data updates.
- **Pitfalls**:
  - LDS is limited to single records; use Apex for bulk operations.
  - Forgetting to handle errors can lead to silent failures.
  - Ensure field-level security (FLS) is respected.
- **Best Practices**:
  - Use `@salesforce/schema` imports for type-safe field references.
  - Cache results locally to reduce server calls.
  - Validate user permissions before performing operations.

---

## 11. Wire Service and Its Applications

Use `@wire` to fetch data reactively from Apex or Salesforce APIs.

#### Example: Dynamic Wire with Error Handling
```javascript
// myComponent.js
import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    @track searchTerm = '';

    @wire(getAccounts, { searchTerm: '$searchTerm' })
    accounts;

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    get accountList() {
        if (this.accounts.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.accounts.error.body.message,
                    variant: 'error'
                })
            );
            return [];
        }
        return this.accounts.data || [];
    }
}
```

```html
<!-- myComponent.html -->
<template>
  <lightning-input label="Search Accounts" onchange={handleSearchChange}></lightning-input>
  <lightning-datatable
    key-field="Id"
    data={accountList}
    columns={columns}>
  </lightning-datatable>
</template>
```

```javascript
// myComponent.js (continued)
export default class MyComponent extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' }
    ];
}
```

### Usage Guidance
- **Purpose**: Fetch data reactively and update the UI when data changes.
- **When to Use**: Use for dynamic data retrieval from Apex or Salesforce APIs.
- **Advanced Use Cases**:
  - Use dynamic parameters (e.g., `$searchTerm`) for reactive updates.
  - Combine with `lightning-datatable` for efficient table rendering.
- **Pitfalls**:
  - Avoid `@wire` for static data; use imperative Apex calls.
  - Forgetting to handle `error` and `data` states can break the UI.
  - Overusing `@wire` can lead to performance issues.
- **Best Practices**:
  - Use getters to process wired data for templates.
  - Provide loading spinners and error messages for better UX.
  - Cache results locally when possible to reduce server calls.

---

## 12. Base Lightning Components

Use Salesforce-provided components like `lightning-card`, `lightning-datatable`, and `lightning-input`.

#### Example: Form with Base Components
```html
<!-- myComponent.html -->
<template>
  <lightning-card title="Contact Form" icon-name="standard:contact">
    <div class="slds-p-around_medium">
      <lightning-input label="First Name" value={contact.FirstName} onchange={handleInputChange} name="FirstName"></lightning-input>
      <lightning-input label="Last Name" value={contact.LastName} onchange={handleInputChange} name="LastName"></lightning-input>
      <lightning-button label="Save" variant="brand" onclick={handleSave}></lightning-button>
    </div>
  </lightning-card>
</template>
```

```javascript
// myComponent.js
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    @track contact = {
        FirstName: '',
        LastName: ''
    };

    handleInputChange(event) {
        const field = event.target.name;
        this.contact[field] = event.target.value;
    }

    handleSave() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contact saved',
                variant: 'success'
            })
        );
    }
}
```

### Usage Guidance
- **Purpose**: Build consistent, accessible UIs with pre-built components.
- **When to Use**: Use for forms, tables, buttons, and layouts in Salesforce apps.
- **Advanced Use Cases**:
  - Use `lightning-datatable` for sortable, editable tables.
  - Combine with SLDS classes for responsive layouts.
- **Pitfalls**:
  - Avoid custom CSS that conflicts with SLDS styles.
  - Ensure compatibility with Salesforce mobile apps.
  - Don’t overuse base components for complex custom UIs.
- **Best Practices**:
  - Follow SLDS guidelines for styling and accessibility.
  - Use `icon-name` for visual consistency.
  - Test components in Lightning Experience and Experience Cloud.

---

## 13. Best Practices for Performance, Security, Testing, and Accessibility

### Performance
- **Minimize Re-renders**: Use immutable data patterns and avoid unnecessary state changes.
- **Lazy Loading**: Fetch data only when needed (e.g., on user action or scroll).
- **Optimize Loops**: Use `key` in `for:each` and avoid complex template logic.
- **Cache Data**: Use LDS or local variables to cache frequently accessed data.

#### Example: Lazy Loading
```javascript
// myComponent.js
import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class MyComponent extends LightningElement {
    accounts = [];
    isLoading = false;

    handleLoadMore() {
        this.isLoading = true;
        getAccounts()
            .then(result => {
                this.accounts = [...this.accounts, ...result];
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.error(error);
            });
    }
}
```

### Security
- **Locker Service**: Adhere to Salesforce’s strict mode for secure DOM access.
- **Sanitize Inputs**: Use `lightning-input` to prevent XSS attacks.
- **Field-Level Security (FLS)**: Check user permissions before CRUD operations.
- **Avoid Hardcoding**: Use dynamic queries and schema imports.

#### Example: Secure Apex Call
```javascript
// myComponent.js
import { LightningElement } from 'lwc';
import getSecureData from '@salesforce/apex/SecureController.getSecureData';

export default class MyComponent extends LightningElement {
    handleFetch() {
        getSecureData()
            .then(result => console.log('Secure data:', result))
            .catch(error => console.error('Error:', error));
    }
}
```

```apex
// SecureController.cls
public with sharing class SecureController {
    @AuraEnabled
    public static List<Account> getSecureData() {
        return [SELECT Id, Name FROM Account WHERE CreatedById = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
    }
}
```

### Testing
Use Jest for unit testing LWC components.

#### Example: Jest Test
```javascript
// myComponent.test.js
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';

describe('c-my-component', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays greeting', () => {
        const element = createElement('c-my-component', { is: MyComponent });
        element.greeting = 'Test Greeting';
        document.body.appendChild(element);
        const h1 = element.shadowRoot.querySelector('h1');
        expect(h1.textContent).toBe('Test Greeting');
    });

    it('updates input value', () => {
        const element = createElement('c-my-component', { is: MyComponent });
        document.body.appendChild(element);
        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = 'New Value';
        input.dispatchEvent(new CustomEvent('change', { detail: { value: 'New Value' } }));
        expect(element.inputValue).toBe('New Value');
    });
});
```

### Accessibility
- **ARIA Attributes**: Add `aria-label`, `aria-describedby`, etc., for screen readers.
- **Keyboard Navigation**: Ensure all interactive elements are focusable.
- **SLDS Components**: Use base components for built-in accessibility.

#### Example: Accessible Component
```html
<!-- myComponent.html -->
<template>
  <lightning-button
    label="Submit"
    variant="brand"
    onclick={handleSubmit}
    aria-label="Submit form"
    accesskey="s">
  </lightning-button>
</template>
```

### Usage Guidance
- **Performance**: Optimize for fast rendering and minimal server calls.
- **Security**: Follow Salesforce security best practices to protect data.
- **Testing**: Achieve high test coverage for reliability.
- **Accessibility**: Ensure components are usable by all users, including those with disabilities.
- **Advanced Use Cases**:
  - Use `lightning-spinner` for loading states.
  - Implement client-side validation for secure inputs.
  - Write integration tests for Apex and LWC interactions.
- **Pitfalls**:
  - Avoid excessive DOM queries in `renderedCallback`.
  - Don’t bypass Locker Service or FLS checks.
  - Ensure test mocks cover all Apex scenarios.
  - Forgetting ARIA attributes can reduce accessibility.
- **Best Practices**:
  - Use Jest for comprehensive unit and integration testing.
  - Follow SLDS accessibility guidelines and test with screen readers.
  - Regularly review Salesforce release notes for updates to APIs and best practices.
  - Use `with sharing` in Apex to enforce record-level security.