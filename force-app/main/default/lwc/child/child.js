import { api, LightningElement } from 'lwc';

export default class Child extends LightningElement {
    @api contact;// Store the detials about the contacts like Name, Email, Phone
    @api componentType;

    constructor(){
        super();
        console.log('Inside Child constructor')
        console.log(this.componentType)
    }
}