import { api, LightningElement, wire } from 'lwc';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType, getObjectInfos } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class QuickCase extends LightningElement {

    @api recordId;
    @api objectApiName;

    recordTypeId = '012000000000000AAA';

    statusOptions;
    priorityOptions;
    typeOptions;
    originOptions;
    reasonOptions;

    @wire(getPicklistValuesByRecordType, { recordTypeId: '$recordTypeId', objectApiName: CASE_OBJECT})
    wiredPicklistOptions({ data, error}){
        if(data){
            console.log('All picklist Info', data);
            this.priorityOptions = data.picklistFieldValues.Priority.values;
            this.originOptions   = data.picklistFieldValues.Origin.values;
            this.typeOptions     = data.picklistFieldValues.Type.values;
            this.reasonOptions   = data.picklistFieldValues.Reason.values;
            this.statusOptions   = data.picklistFieldValues.Status.values;
        } else if(error){
            console.error('All picklist Error', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STATUS_FIELD })
    wiredStatusPicklist({ data, error}){
        if(data){
            console.log('Status picklist Info', data);
            // this.statusOptions = data.values;
        } else if(error){
            console.error('Status picklist Error', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    wiredObjectInfo({ data, error}){
        if(data){
            console.log('Object Info', data);
        } else if(error){
            console.error('Error', error);
        }
    }

    connectedCallback(){
        console.log('Record Id', this.recordId);
        console.log('Object API Name', this.objectApiName);
    }

    /* get statusOptions(){
        return [
            { label: 'New', value: 'New' },
            { label: 'Working', value: 'Working' },
            { label: 'Escalated', value: 'Escalated' }
        ]
    } */

    /* get priorityOptions(){
        return [
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' }
        ]
    } */
}