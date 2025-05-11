import { LightningElement } from 'lwc';

export default class NestedIfElse extends LightningElement {
    gradeAPlus = false;
    gradeA = false;
    gradeB = false;

    user; // An Object
    // undefined

    person = {
        name: "Amit SIngh",
        age: 31,
        title: "Salesforce Architect",
        gender: "M",
        phone: "9854712630",
        email: "asigg@gmail.com"
    }

    users = [
        {
            name: "Amit SIngh",
            age: 31,
            title: "Salesforce Architect",
            gender: "M",
            phone: "9854712630",
            email: "asigg@gmail.com"
        },
        {
            name: "Amit SIngh",
            age: 31,
            title: "Salesforce Architect",
            gender: "M",
            phone: "9854712630",
            email: "asigg@gmail.com"
        },
        {
            name: "Amit SIngh",
            age: 31,
            title: "Salesforce Architect",
            gender: "M",
            phone: "9854712630",
            email: "asigg@gmail.com"
        },
        {
            name: "Amit SIngh",
            age: 31,
            title: "Salesforce Architect",
            gender: "M",
            phone: "9854712630",
            email: "asigg@gmail.com"
        }
    ]

    handleMarksChange(event){
        let marks = event.target.value;
        if(marks >= 75){
            this.gradeAPlus = true;
            this.gradeA = false;
            this.gradeB = false;
        } else if (marks >= 60){
            this.gradeA = true;
            this.gradeB = false;
            this.gradeAPlus = false;
        } else if (marks >= 50){
            this.gradeB = true;
            this.gradeA = false;
            this.gradeAPlus = false;
        } else {
            this.gradeB = false;
            this.gradeA = false;
            this.gradeAPlus = false;
        }
    }

    handleDefineUser(event){
        this.user = {
            name: "Jon Doe",
        }
    }
}