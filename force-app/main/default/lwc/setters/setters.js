import { LightningElement } from 'lwc';

export default class Setters extends LightningElement {
    _count = 0;
    _message = '';

    get count(){
        return this._count;
    }

    set count(value){
        if(typeof value == 'number'){
            this._count = value;
            this._message = '';
        } else {
            console.error(`Count must be a number`);
            this._message = `Count must be a number`;
        }
    }

    handleIncrement(){
        // this._count = this._count+1;
        this.count = 'AVC';
    }
}