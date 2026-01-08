import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
export default class Details extends LightningElement {

    @wire(CurrentPageReference)
    pageRef

    labeles = {

    }
        
    connectedCallback() {
        console.log('Current page reference indide Details is ', JSON.stringify(this.pageRef))
        let states = this.pageRef.state;
        this.labeles.recordId = states.c__recordId;
        this.labeles.recordName = states.c__recordName;
        this.labeles.counter = states.c__counter;
    }
}