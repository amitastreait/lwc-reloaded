import { LightningElement, api } from "lwc";

export default class extends LightningElement {
  @api objectApiName;

  get computedClassNames() {
    return [
        this.objectApiName === 'Account' ? "slds-theme_shade" : "slds-theme_success"
    ];
  }
}