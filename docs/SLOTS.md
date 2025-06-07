# LWC Slots - Complete Guide

## What are Slots in LWC?

Slots in Lightning Web Components (LWC) are **placeholders** that allow parent components to inject content into child components. They enable **content projection** and make components more flexible and reusable.

Think of slots as "holes" in your component template where other components can insert their own content.

## Types of Slots

### 1. **Unnamed Slots (Default Slots)**
### 2. **Named Slots**

---

## Unnamed Slots (Default Slots)

An unnamed slot accepts any content passed to the component without specifying a slot name.

### Child Component Example

```javascript
// cardComponent.js
import { LightningElement } from 'lwc';

export default class CardComponent extends LightningElement {}
```

```html
<!-- cardComponent.html -->
<template>
    <div class="slds-card">
        <div class="slds-card__header">
            <h2 class="slds-card__header-title">Card Title</h2>
        </div>
        <div class="slds-card__body slds-card__body_inner">
            <!-- Unnamed/Default Slot -->
            <slot></slot>
        </div>
    </div>
</template>
```

### Parent Component Usage

```javascript
// parentComponent.js
import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {}
```

```html
<!-- parentComponent.html -->
<template>
    <c-card-component>
        <!-- This content goes into the unnamed slot -->
        <p>This content will be projected into the card body!</p>
        <lightning-button label="Click Me"></lightning-button>
        <div>Any HTML content can go here</div>
    </c-card-component>
</template>
```

---

## Named Slots

Named slots allow you to have multiple slots in a component, each identified by a unique name.

### Child Component with Named Slots

```javascript
// modalComponent.js
import { LightningElement, api } from 'lwc';

export default class ModalComponent extends LightningElement {
    @api title = 'Modal Title';
    @api isOpen = false;

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
```

```html
<!-- modalComponent.html -->
<template>
    <template if:true={isOpen}>
        <section class="slds-modal slds-fade-in-open">
            <div class="slds-modal__container">
                <!-- Header Slot -->
                <header class="slds-modal__header">
                    <slot name="header">
                        <!-- Default header content if no header slot provided -->
                        <h2 class="slds-modal__title">{title}</h2>
                    </slot>
                    <button class="slds-button slds-button_icon slds-modal__close" onclick={handleClose}>
                        <lightning-icon icon-name="utility:close" size="small"></lightning-icon>
                    </button>
                </header>

                <!-- Body Slot (Default/Unnamed) -->
                <div class="slds-modal__content slds-p-around_medium">
                    <slot></slot>
                </div>

                <!-- Footer Slot -->
                <footer class="slds-modal__footer">
                    <slot name="footer">
                        <!-- Default footer if no footer slot provided -->
                        <lightning-button label="Close" onclick={handleClose}></lightning-button>
                    </slot>
                </footer>
            </div>
        </section>
        <div class="slds-backdrop slds-backdrop_open"></div>
    </template>
</template>
```

### Parent Component Using Named Slots

```html
<!-- parentComponent.html -->
<template>
    <lightning-button label="Open Modal" onclick={openModal}></lightning-button>

    <c-modal-component is-open={modalOpen} onclose={closeModal}>
        <!-- Content for header named slot -->
        <div slot="header">
            <h2>Custom Header with Icon</h2>
            <lightning-icon icon-name="utility:warning" size="small"></lightning-icon>
        </div>

        <!-- Content for default/unnamed slot (modal body) -->
        <div>
            <p>This is the modal body content.</p>
            <lightning-input label="Enter your name" value={userName}></lightning-input>
            <p>You can put any content here!</p>
        </div>

        <!-- Content for footer named slot -->
        <div slot="footer">
            <lightning-button label="Cancel" onclick={closeModal}></lightning-button>
            <lightning-button label="Save" variant="brand" onclick={saveData}></lightning-button>
        </div>
    </c-modal-component>
</template>
```

---

## Complete Working Example

### 1. Layout Component (Child)

```javascript
// layoutComponent.js
import { LightningElement, api } from 'lwc';

export default class LayoutComponent extends LightningElement {
    @api title = 'Page Title';
    @api showSidebar = true;
}
```

```html
<!-- layoutComponent.html -->
<template>
    <div class="page-container">
        <!-- Header Named Slot -->
        <header class="page-header slds-p-around_medium">
            <slot name="header">
                <h1>{title}</h1>
            </slot>
        </header>

        <div class="page-content slds-grid">
            <!-- Sidebar Named Slot -->
            <aside if:true={showSidebar} class="sidebar slds-col slds-size_1-of-4">
                <slot name="sidebar">
                    <div class="slds-box">
                        <p>Default Sidebar Content</p>
                    </div>
                </slot>
            </aside>

            <!-- Main Content (Default Slot) -->
            <main class="main-content slds-col slds-size_3-of-4">
                <slot></slot>
            </main>
        </div>

        <!-- Footer Named Slot -->
        <footer class="page-footer slds-p-around_medium">
            <slot name="footer">
                <p>&copy; 2024 Default Footer</p>
            </slot>
        </footer>
    </div>
</template>
```

### 2. Page Component (Parent)

```javascript
// dashboardPage.js
import { LightningElement, track } from 'lwc';

export default class DashboardPage extends LightningElement {
    @track records = [
        { id: 1, name: 'Record 1', status: 'Active' },
        { id: 2, name: 'Record 2', status: 'Inactive' },
        { id: 3, name: 'Record 3', status: 'Pending' }
    ];
}
```

```html
<!-- dashboardPage.html -->
<template>
    <c-layout-component title="Dashboard" show-sidebar={true}>
        
        <!-- Header Slot Content -->
        <div slot="header">
            <div class="slds-grid slds-grid_align-spread">
                <h1 class="slds-text-heading_large">Custom Dashboard Header</h1>
                <lightning-button-group>
                    <lightning-button label="Export" icon-name="utility:download"></lightning-button>
                    <lightning-button label="Settings" icon-name="utility:settings"></lightning-button>
                </lightning-button-group>
            </div>
        </div>

        <!-- Sidebar Slot Content -->
        <div slot="sidebar">
            <lightning-card title="Quick Actions">
                <div class="slds-p-around_small">
                    <lightning-button label="New Record" variant="brand" class="slds-m-bottom_x-small"></lightning-button>
                    <lightning-button label="Import Data" class="slds-m-bottom_x-small"></lightning-button>
                    <lightning-button label="Generate Report"></lightning-button>
                </div>
            </lightning-card>

            <lightning-card title="Recent Activity" class="slds-m-top_medium">
                <div class="slds-p-around_small">
                    <ul class="slds-list_dotted">
                        <li>User logged in</li>
                        <li>Record updated</li>
                        <li>Report generated</li>
                    </ul>
                </div>
            </lightning-card>
        </div>

        <!-- Main Content (Default Slot) -->
        <div>
            <lightning-card title="Data Table">
                <div class="slds-p-around_medium">
                    <table class="slds-table slds-table_cell-buffer slds-table_bordered">
                        <thead>
                            <tr class="slds-line-height_reset">
                                <th scope="col">Name</th>
                                <th scope="col">Status</th>
                                <th scope="col">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <template for:each={records} for:item="record">
                                <tr key={record.id}>
                                    <td>{record.name}</td>
                                    <td>
                                        <lightning-badge label={record.status}></lightning-badge>
                                    </td>
                                    <td>
                                        <lightning-button-menu alternative-text="Actions">
                                            <lightning-menu-item value="edit" label="Edit"></lightning-menu-item>
                                            <lightning-menu-item value="delete" label="Delete"></lightning-menu-item>
                                        </lightning-button-menu>
                                    </td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </lightning-card>
        </div>

        <!-- Footer Slot Content -->
        <div slot="footer">
            <div class="slds-grid slds-grid_align-spread">
                <p>Dashboard v2.1 | Last updated: Today</p>
                <div>
                    <lightning-button label="Help" icon-name="utility:help"></lightning-button>
                    <lightning-button label="Feedback" icon-name="utility:feedback"></lightning-button>
                </div>
            </div>
        </div>

    </c-layout-component>
</template>
```

---

## Slot Features and Best Practices

### 1. **Default Content in Slots**
```html
<slot name="header">
    <!-- This shows if no content is provided for the header slot -->
    <h2>Default Header</h2>
</slot>
```

### 2. **Multiple Elements in Same Slot**
```html
<!-- Parent can pass multiple elements to same slot -->
<div slot="header">
    <h1>Title</h1>
    <p>Subtitle</p>
    <lightning-button label="Action"></lightning-button>
</div>
```

### 3. **Slot Selection in JavaScript**
```javascript
// Access slotted content in child component
get hasHeaderSlot() {
    const slot = this.template.querySelector('slot[name="header"]');
    return slot && slot.assignedElements().length > 0;
}
```

### 4. **Conditional Slots**
```html
<template if:true={hasHeaderSlot}>
    <div class="header-wrapper">
        <slot name="header"></slot>
    </div>
</template>
```

---

## Common Use Cases

### 1. **Layout Components**
- Headers, sidebars, footers
- Different content areas

### 2. **Card Components**
- Title, body, actions slots
- Flexible card layouts

### 3. **Modal/Dialog Components**
- Header, body, footer slots
- Custom buttons and content

### 4. **List/Table Components**
- Custom row templates
- Action buttons

### 5. **Form Components**
- Custom field layouts
- Dynamic form sections

---

## Key Points

### ✅ **Do's**
- Use named slots for specific content areas
- Provide default content for optional slots
- Keep slot names descriptive and consistent
- Use slots to make components reusable

### ❌ **Don'ts**
- Don't use too many slots (keeps it simple)
- Don't rely on slot content for component logic
- Don't forget to handle empty slots gracefully

### **Remember**
- Slots enable **composition over inheritance**
- They make components more **flexible and reusable**
- Content is projected from parent to child
- Slotted content maintains parent component's context

Slots are one of the most powerful features in LWC for building flexible, reusable components that can adapt to different use cases while maintaining clean separation of concerns.