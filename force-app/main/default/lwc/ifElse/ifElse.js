import { LightningElement } from 'lwc';

export default class IfElse extends LightningElement {

    /** Properties */
    /** Private Propery */
    /** Class Level Properties */
    showTom = false;
    showJerry = false;

    handleShowTom(event){
        this.showTom = event.target.checked;
    }
    handleShowJerry(event){
        this.showJerry = event.target.checked;
    }
}