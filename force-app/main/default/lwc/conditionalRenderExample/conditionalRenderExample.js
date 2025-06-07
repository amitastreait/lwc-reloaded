import { LightningElement } from 'lwc';
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';
import loadingTemplate from './loadingTemplate.html';
import defaultTemplate from './conditionalRenderExample.html';

export default class ConditionalRenderExample extends LightningElement {
    currentView = 'default';
    userRole = 'guest';
    isLoading = false;

    // The render method determines which template to use
    render() {
        // Loading state
        if (this.isLoading) {
            return loadingTemplate;
        }

        // Conditional rendering based on user role
        if (this.userRole === 'admin') {
            return templateOne; // Admin dashboard
        } else if (this.userRole === 'manager') {
            return templateTwo; // Manager view
        }

        // Switch-case style rendering
        switch (this.currentView) {
            case 'dashboard':
                return templateOne;
            case 'reports':
                return templateTwo;
            default:
                return defaultTemplate; // Default guest view
        }
    }

    // Template for loading state (inline template)
    get loadingTemplate() {
        const template = document.createElement('template');
        template.innerHTML = `
            <div class="slds-spinner_container">
                <div class="slds-spinner slds-spinner_medium" role="status">
                    <span class="slds-assistive-text">Loading...</span>
                    <div class="slds-spinner__dot-a"></div>
                    <div class="slds-spinner__dot-b"></div>
                </div>
            </div>
        `;
        return template;
    }

    // Getters for dynamic styling - LWC way to handle conditional classes/variants
    get defaultButtonVariant() {
        return this.currentView === 'default' ? 'brand' : 'neutral';
    }

    get dashboardButtonVariant() {
        return this.currentView === 'dashboard' ? 'brand' : 'neutral';
    }

    get reportsButtonVariant() {
        return this.currentView === 'reports' ? 'brand' : 'neutral';
    }

    // Event handlers to change the view
    handleViewChange(event) {
        this.currentView = event.target.dataset.view;
    }

    handleRoleChange(event) {
        this.userRole = event.target.value;
    }

    handleLoadingToggle() {
        this.isLoading = !this.isLoading;
        
        // Simulate async operation
        if (this.isLoading) {
            setTimeout(() => {
                this.isLoading = false;
            }, 2000);
        }
    }

    // Lifecycle hook - render is called after this
    connectedCallback() {
        console.log('Component connected, render method will be called');
    }

    // This runs after render method
    renderedCallback() {
        console.log('Component rendered with template:', this.currentView);
    }
    get roleOptions() {
        return [
            { label: 'Guest', value: 'guest' },
            { label: 'Manager', value: 'manager' },
            { label: 'Admin', value: 'admin' }
        ];
    }
}