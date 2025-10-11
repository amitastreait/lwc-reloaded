import { LightningElement, api, track } from 'lwc';

export default class LdsLoadRecord extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track fieldList = [
        "Name", "Industry","Rating", "Description", "Active__c"
    ];

    connectedCallback(){
        console.log('Record Id', this.recordId);
        console.log('Object API Name', this.objectApiName);
    }

    handleSuccess(event){
        alert('Record is saved');
        console.log(JSON.stringify(event.detail))
    }

    handleError(event){
        console.error(JSON.stringify(event))
    }
}