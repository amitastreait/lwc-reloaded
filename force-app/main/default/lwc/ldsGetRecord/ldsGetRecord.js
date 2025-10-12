import { api, LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import OWNER_NAME_FIELD from '@salesforce/schema/Account.Owner.Name';

import ANNUAL_REVENUE from '@salesforce/schema/Account.AnnualRevenue';

export default class LdsGetRecord extends LightningElement {
    @api recordId;
    @api objectApiName;

    account;
    error;

    @wire(getRecord, {
        recordId: '001gK000005BgHOQA0',
        fields: [NAME_FIELD, INDUSTRY_FIELD, ANNUAL_REVENUE],
        optionalFields : [OWNER_NAME_FIELD]
    })
    wiredAccount({data, error}){
        if(data){
            this.account = data;
        } else {
            this.error = error;
            console.error(this.error);
        }
    }

    get accountName(){
        return getFieldValue(this.account, NAME_FIELD)
    }

    get industry(){
        return getFieldValue(this.account, INDUSTRY_FIELD)
    }

    get ownerName(){
        return getFieldValue(this.account, OWNER_NAME_FIELD)
    }

    get revenue(){
        return getFieldDisplayValue(this.account, ANNUAL_REVENUE)
    }
}