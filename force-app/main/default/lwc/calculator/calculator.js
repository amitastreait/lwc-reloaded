import { LightningElement } from 'lwc';

export default class Calculator extends LightningElement {

    number1;
    number2;
    result;
    Result;
    numbe1Change(evt){
        this.number1 = evt.target.value;
    }

    number2Change(e){
        this.number2 = e.target.value;
    }

    hanleAdd(){
        if(this.number1 && this.number2){
            this.result = parseInt(this.number1) + parseInt(this.number2);
        } else {
            alert('Please enter both the numbers');
        }
        
    }

    hanleSubstract(){
        this.result = this.number1 - this.number2;
    }

    hanleMultiply(){
        if(this.number1 && this.number2){
            this.result = parseInt(this.number1) * parseInt(this.number2);
        } else {
            alert('Please enter both the numbers');
        }
    }
    hanleDevide(){
        if(this.number1 && this.number2){
            alert(typeof this.number1);
            if(this.number2 == '0' || this.number2 === '0'){
                alert('Can not devide by 0')
                return;
            }
            this.result = ( parseInt(this.number1) / parseInt(this.number2) ).toFixed(3);
        } else {
            alert('Please enter both the numbers');
        }
    }
}