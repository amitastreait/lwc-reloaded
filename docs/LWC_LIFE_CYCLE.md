# Lightning Web Components (LWC) Lifecycle Methods

## 1. constructor()

### Usage
The constructor is called when a component instance is created. It's the first lifecycle method to execute and is used for initial setup.

```javascript
import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    constructor() {
        super(); // Must call super() first
        // Initialize properties
        this.privateProperty = 'Initial value';
        this.data = [];
    }
}
```

### Do's
- Always call `super()` as the first statement
- Initialize private properties and variables
- Set up initial state that doesn't depend on DOM or external data
- Bind event handlers if needed
- Initialize collections and objects

### Don'ts
- Don't access child elements (DOM not ready yet)
- Don't make API calls or perform async operations
- Don't access `this.template` (not available)
- Don't set reactive properties that trigger re-renders
- Don't perform operations that depend on component being connected to DOM

---

## 2. connectedCallback()

### Usage
Called when the component is inserted into the DOM. This is where you perform setup that requires the component to be connected.

```javascript
import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    connectedCallback() {
        // Component is now connected to DOM
        this.loadData();
        this.setupEventListeners();
        this.initializeThirdPartyLibraries();
    }
    
    loadData() {
        // Safe to make API calls here
    }
}
```

### Do's
- Make API calls and fetch data
- Set up event listeners
- Initialize third-party libraries
- Perform operations that require DOM connection
- Set up subscriptions (message channels, platform events)
- Access component attributes and properties

### Don'ts
- Don't assume child components are rendered yet
- Don't access child element references immediately
- Don't perform heavy computations that block the UI
- Don't forget to clean up resources in disconnectedCallback

---

## 3. renderedCallback()

### Usage
Called after every render of the component. Use this for operations that need to happen after the DOM is updated.

```javascript
import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    isRendered = false;
    
    renderedCallback() {
        // Called after every render
        if (!this.isRendered) {
            // First render
            this.initializeAfterRender();
            this.isRendered = true;
        }
        
        // Operations needed after each render
        this.updateThirdPartyLibrary();
    }
    
    initializeAfterRender() {
        // Access child elements safely
        const childElement = this.template.querySelector('.my-element');
        if (childElement) {
            // Manipulate DOM element
        }
    }
}
```

### Do's
- Access and manipulate child DOM elements
- Initialize libraries that need DOM elements
- Perform calculations based on rendered content
- Use flags to distinguish first render from subsequent renders
- Update third-party components that depend on DOM changes

### Don'ts
- Don't change reactive properties unnecessarily (causes infinite loops)
- Don't perform expensive operations on every render
- Don't make API calls in every renderedCallback
- Don't assume the component is fully rendered in nested scenarios
- Don't modify DOM directly if LWC can handle it reactively

---

## 4. errorCallback(error, stack)

### Usage
Called when an error occurs in any child component. This method provides error boundary functionality for handling errors gracefully.

```javascript
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    errorCallback(error, stack) {
        console.error('Component Error:', error.message);
        console.error('Stack Trace:', stack);
        
        // Log error to external service
        this.logErrorToService(error, stack);
        
        // Show user-friendly message
        this.dispatchEvent(new ShowToastEvent({
            title: 'Something went wrong',
            message: 'Please try again or contact support',
            variant: 'error'
        }));
        
        // Prevent error from bubbling up
        return true;
    }
    
    logErrorToService(error, stack) {
        // Send error details to logging service
    }
}
```

### Do's
- Log errors for debugging and monitoring
- Show user-friendly error messages  
- Send error details to external logging services
- Return `true` to prevent error from bubbling up to parent
- Implement fallback UI or recovery mechanisms
- Handle different types of errors appropriately

### Don'ts
- Don't ignore errors silently
- Don't expose sensitive error details to users
- Don't let errors crash the entire component tree
- Don't perform operations that might throw additional errors
- Don't forget to test error scenarios

---

## 5. disconnectedCallback()

### Usage
Called when the component is removed from the DOM. This is your cleanup opportunity to prevent memory leaks and remove listeners.

```javascript
import { LightningElement } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';

export default class MyComponent extends LightningElement {
    subscription = null;
    intervalId = null;
    
    connectedCallback() {
        // Set up resources
        this.subscription = subscribe('/event/MyEvent__e', this.handleEvent);
        this.intervalId = setInterval(this.updateData, 5000);
    }
    
    disconnectedCallback() {
        // Clean up resources
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
        
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
        
        // Remove event listeners
        this.removeEventListeners();
        
        // Clean up third-party libraries
        this.destroyThirdPartyComponents();
    }
}
```

### Do's
- Unsubscribe from platform events and message channels
- Clear timers and intervals
- Remove event listeners
- Cancel pending API requests
- Clean up third-party library instances
- Release memory references to prevent leaks
- Reset component state if needed

### Don'ts
- Don't forget to clean up resources created in connectedCallback
- Don't leave subscriptions or listeners active
- Don't ignore cleanup of third-party libraries
- Don't assume the component will be reconnected
- Don't perform operations that depend on DOM (component is being removed)

---

## Lifecycle Flow Summary

```
1. constructor() → Component instance created
2. connectedCallback() → Component connected to DOM
3. renderedCallback() → Component rendered (called multiple times)
4. disconnectedCallback() → Component removed from DOM
5. errorCallback() → Called when child component errors occur
```

## Best Practices

- Always clean up in `disconnectedCallback()` what you set up in `connectedCallback()`
- Use `renderedCallback()` sparingly and with performance considerations
- Implement proper error handling with `errorCallback()`
- Follow the principle of creating resources in `connectedCallback()` and destroying them in `disconnectedCallback()`
- Use lifecycle methods appropriately based on when DOM and component state are available