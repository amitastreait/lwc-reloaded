### 📘 LWC Directives Overview

| Directive                            | Purpose                                                                             | Example Usage                                                                                                                                                                                                                      |   |
| ------------------------------------ | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | - |
| `for:each`                           | Iterates over an array to render a list of items.                                   | `<template for:each={items} for:item="item"><br>  <p key={item.id}>{item.name}</p><br></template>`                                                                                                                         |   |
| `lwc:if` / `lwc:elseif` / `lwc:else` | Conditionally renders elements based on boolean expressions.                        | `<template lwc:if={isMorning}><br>  <p>Good morning!</p><br></template><br><template lwc:elseif={isAfternoon}><br>  <p>Good afternoon!</p><br></template><br><template lwc:else><br>  <p>Good evening!</p><br></template>` |   |
| `lwc:spread`                         | Passes multiple properties from an object to a child component efficiently.         | `<c-child-component lwc:spread={childProps}></c-child-component>`                                                                                                                                                          |   |
| `if:true` / `if:false`               | Conditionally renders elements based on the truthiness or falsiness of expressions. | `<template if:true={isVisible}><br>  <p>Visible Content</p><br></template><br><template if:false={isVisible}><br>  <p>Hidden Content</p><br></template>`                                                                   |   |
| `lwc:ref`                            | Assigns a reference to a DOM element for access in JavaScript via `this.refs`.      | `<div lwc:ref="myDiv">Content</div>`<br>`javascript<br>const divElement = this.refs.myDiv;`                                                                                                                                |   |
| `lwc:is`                             | Dynamically renders a component based on a constructor reference.                   | `<lwc:component lwc:is={dynamicComponent}></lwc:component>`                                                                                                                                                                |   |

---

**Notes:**

* **`for:each`**: Requires a `key` attribute for each item to optimize rendering performance.

* **`lwc:if` / `lwc:elseif` / `lwc:else`**: Provide a more robust alternative to `if:true` / `if:false`, especially for complex conditional rendering scenarios.

* **`lwc:spread`**: Introduced in Salesforce Summer '23, this directive simplifies passing multiple properties to child components.

* **`if:true` / `if:false`**: Suitable for simple conditional rendering but less flexible than the newer `lwc:if` directives.

* **`lwc:ref`**: Useful for accessing DOM elements directly within your component's JavaScript.

* **`lwc:is`**: Enables dynamic component rendering based on runtime conditions.

---

For more detailed information and examples, you can refer to the [LWC Directives Documentation](https://developer.salesforce.com/docs/platform/lwc/guide/reference-directives.html).