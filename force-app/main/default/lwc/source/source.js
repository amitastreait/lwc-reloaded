import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Source extends NavigationMixin(LightningElement) {

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