import { LightningElement, api } from 'lwc';

export default class LdsEditRecord extends LightningElement {
    @api recordId;
    @api objectApiName;

    handleSuccess(event){
        alert('Record is saved');
        console.log(JSON.stringify(event.detail))
    }

    handleError(event){
        console.error(JSON.stringify(event))
    }
}