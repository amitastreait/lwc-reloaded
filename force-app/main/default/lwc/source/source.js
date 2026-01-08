import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
export default class Source extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
        pageRef
    
    connectedCallback() {
        console.log('Current page reference is ', JSON.stringify(this.pageRef))
    }

    handleNavigateToLightningWebComponent(){
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__details'
            },
            state : {
                c__recordId: '001gK000005BgHOQA0',
                c__recordName: 'Salesforce.com',
                c__counter: 10,
                stateParam: 'value1'
            }
        })
    }
}