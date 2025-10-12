import { LightningElement } from 'lwc';

export default class LdsCreateRecord extends LightningElement {
    /** Requirement
     * Create the Account Record using LDS which will have the following fields
     *  Name
     *  Industry
     *  Rating
     *  Type
     *  Active__c
     *  Description
     *  Phone
    */
    fields = [
        "Name",
        "Industry",
        "Rating",
        "Type",
        "Active__c",
        "Description",
        "Phone"
    ];

    handleSubmit(event){
        event.preventDefault();
        let fields = event.detail.fields;
        fields.Fax = '9087657345';
        fields.ParentId = '001gK000005BgHOQA0';
        fields.Description = 'This is update from the LDS JavaScript!';

        this.refs.accountForm.submit(fields);
    }

    handleSuccess(event){
        console.log(JSON.stringify(event.detail.fields))
    }

    handleError(event){
         console.error(JSON.stringify(event.detail))
    }
}