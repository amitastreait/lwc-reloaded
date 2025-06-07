import { api, LightningElement } from 'lwc';

export default class Child extends LightningElement {
    @api contact;// Store the detials about the contacts like Name, Email, Phone
    @api componentType;

    constructor(){
        super();
        console.log('Inside Child constructor')
        console.log(this.componentType)
    }
    connectedCallback(){
        console.log(`I am from child component connectedCallback`);
        throw new Error('Error in ConnectedCallback Method of child component');
    }
    renderedCallback(){
        console.log(`I am from child component renderedCallback`);
    }

    disconnectedCallback(){
        console.log(`I am from child component disconnectedCallback`)
        this.removeThirdPartyLibraries();
        this.removeListers();
    }

    removeThirdPartyLibraries(){
        console.log(`removeThirdPartyLibraries`)
    }

    removeListers(){
        console.log(`removeListers`)
    }
}