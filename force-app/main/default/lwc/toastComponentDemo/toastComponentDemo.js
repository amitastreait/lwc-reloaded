import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ToastComponentDemo extends LightningElement {

    showToast(){
        let toastMessage = new ShowToastEvent({
            title : "Success",
            message: "This is a success toast",
            variant: "success" // error, info, warning
        });
        this.dispatchEvent(toastMessage);

        this.dispatchEvent(new ShowToastEvent({
            title : "Error",
            message: "This is a error toast",
            variant: "error" // error, info, warning
        }))

        this.dispatchEvent(new ShowToastEvent({
            title : "Warning",
            message: "This is a warning toast",
            variant: "warning" // error, info, warning
        }))

        this.dispatchEvent(new ShowToastEvent({
            title : "Information",
            message: "This is a information toast",
            variant: "info" // error, info, warning
        }))
    }

    showToastWithLink(){
        let toastMessage = new ShowToastEvent({
            title : "Success",
            message: "Record {0} is created. See it {1}. Here is another placeholder with value {2}",
            variant: "success",
            messageData: [
                "Salesforce",
                {
                    "url": "https://www.salesforce.com/blog/category/it/",
                    "label": "here"
                },
                "Pantherschools.com"
            ]
        });
        this.dispatchEvent(toastMessage);
    }
}