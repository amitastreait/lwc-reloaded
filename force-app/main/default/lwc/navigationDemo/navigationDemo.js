import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class NavigationDemo extends NavigationMixin(LightningElement) {

    handleNavigateToRecordPage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '006gK000001bBdsQAE',
                actionName: 'view',
            },
        })
    }
    handleNavigateToNewContact(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                actionName: 'new',
                objectApiName: 'Contact'
            },
        })
    }
}