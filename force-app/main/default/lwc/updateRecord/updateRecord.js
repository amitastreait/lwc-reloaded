import { api, LightningElement } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';

import TYPE_FIELD from '@salesforce/schema/Account.Type';

export default class UpdateRecord extends LightningElement {

    @api recordId;
    @api objectApiName;

    description;

    handleInputChange(event){
        this.description = event.target.value;
    }

    handleUpdate(event){
        event.preventDefault();

        const fields = {};
        fields['Id'] = this.recordId;
        fields['Description'] = this.description;
        fields['Active__c'] = 'Yes';
        fields['AnnualRevenue'] = 89834;
        //fields[TYPE_FIELD.fieldApiName] = '';

        const recordInput = { fields };

        updateRecord(recordInput)
        .then(record => {
            alert('Record is updated')
        })
        .catch((error) => {
            console.error(error)
        })
        .finally(()=>{

        })
    }

}