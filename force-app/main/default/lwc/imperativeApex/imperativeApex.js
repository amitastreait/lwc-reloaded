import { LightningElement } from 'lwc';
import getAllAccounts from '@salesforce/apex/AccountController.getAllAccounts';
import getAllAccountsByIndustry from '@salesforce/apex/AccountController.getAllAccountsByIndustry';
export default class ImperativeApex extends LightningElement {

    accounts;
    errors;
    isLoading = false;

    industryValue = 'Education';

    handleClick(event){
        event.preventDefault();
        this.isLoading = true;

        getAllAccountsByIndustry({
            industry: this.industryValue
        })
        .then(result => {
            this.accounts = result;
        })
        .catch( err => {
            this.errors = err;
        })
        .finally( () => {
            this.isLoading = false;
        });
        /* getAllAccounts()
        .then(result => {
            this.accounts = result;
        })
        .catch( err => {
            this.errors = err;
        })
        .finally( () => {
            this.isLoading = false;
        }); */
    }
}