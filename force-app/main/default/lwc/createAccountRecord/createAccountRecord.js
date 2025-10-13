import { api, LightningElement } from 'lwc';

import { createRecord, deleteRecord } from 'lightning/uiRecordApi';

export default class CreateAccountRecord extends LightningElement {
    @api recordId;
    @api objectApiName;

    recordIdTodelete = '001gK00000ONcrZQAT'

    isLoading = false;

    handleDelete(event){
        event.preventDefault();
        this.isLoading = true;
        deleteRecord(this.recordIdTodelete)
        .then(record => {
            alert('The record has been deleted')
        })
        .catch(error => {
            console.error('Error occured while deleting the record !', error);
        })
        .finally(() => {
            this.isLoading = false;
        })
    }

    handleClick(event){
        event.preventDefault();

        this.isLoading = true;

        const fields = {};
        fields['Name'] = 'Salesforce.com UK';
        fields['Rating'] = 'Hot';
        fields['Industry'] = 'Education';
        fields['Active__c'] = 'Yes';
        fields['AnnualRevenue'] = 8954525;
        fields['Phone'] = '9874563210';
        fields['Fax'] = '9874563210';
        fields['ParentId'] = this.recordId;

        const recordInput = {
            apiName : 'Account',
            fields : fields
        };

        createRecord(recordInput)
        .then(record => {
            console.log(record);
            alert('The account record has been saved')
        })
        .catch(error => {
            console.error(error);
        })
        .finally(() => {
            this.isLoading = false;
        })
    }
}