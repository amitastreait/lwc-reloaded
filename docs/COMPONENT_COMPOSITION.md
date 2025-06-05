# Component Composition in LWC (Lightning Web Components)

**Component Composition** refers to the practice of building complex UIs by combining smaller, reusable components. Think of it like LEGO blocks — instead of one large block, you create multiple small blocks that fit together.

---

## 🔹 Why Use Component Composition?

* **♻️ Reusability**: Use components in multiple places.
* **🛠 Maintainability**: Easier to debug and update smaller components.
* **📦 Separation of Concerns**: Each component handles a specific function.
* **🔐 Encapsulation**: Each component manages its own data and styles.

---

## 🔸 Example: Basic Composition

Suppose you're building a `StudentList` component that uses a child component `StudentItem`.

### `studentItem.html` (Child)

```html
<template>
    <div class="student">
        <p>{student.name}</p>
        <p>{student.grade}</p>
    </div>
</template>
```

### `studentItem.js`

```javascript
import { LightningElement, api } from 'lwc';

export default class StudentItem extends LightningElement {
    @api student;
}
```

---

### `studentList.html` (Parent)

```html
<template>
    <template for:each={students} for:item="stud">
        <c-student-item key={stud.id} student={stud}></c-student-item>
    </template>
</template>
```

### `studentList.js`

```javascript
import { LightningElement } from 'lwc';

export default class StudentList extends LightningElement {
    students = [
        { id: 1, name: 'Amit', grade: 'A' },
        { id: 2, name: 'Rita', grade: 'B' }
    ];
}
```

---

## 🔸 Real-world Scenarios of Composition

* 📦 A **Modal** component reused across different pages
* 🚨 A **Toast** component to display alerts across flows
* 🔍 A **SearchBar** component used in list views or dashboards

---

## 📌 Best Practices

* ✅ Keep components focused on one job
* ✅ Use descriptive names (`student-list`, `toast-message`)
* ✅ Use `@api` to pass data from parent to child
* ❌ Avoid tight coupling — child components should remain independent