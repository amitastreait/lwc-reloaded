import { LightningElement } from 'lwc';

export default class Getters extends LightningElement {
    firstName = "John"
    lastName = 'Doe'
    marks;

    //fullName = this.firstName +' '+ this.lastName;

    handleInputChange(event){
        this.marks = event.target.value;
        this.fullName = `John Doe ${Math.random()}`
    }

    get fullName(){
        /** Complete process or logic */
        return `${this.firstName} ${this.lastName}`;
    }

    get gradeAPlus(){
        if(parseInt(this.marks) > 75){
            return true;
        }
        return false;
    }

    get gradeA(){
        if(parseInt(this.marks) > 60 && parseInt(this.marks) <=75){
            return true;
        }
        return false;
    }

    get gradeB(){
        if(parseInt(this.marks) > 45 && parseInt(this.marks) <=60){
            return true;
        }
        return false;
    }
}