import { LightningElement } from 'lwc';
import templateOne from './templates/templateOne.html'
import templateTwo from './templateTwo.html'
import renderExample from './renderExample.html'
export default class RenderExample extends LightningElement {

    showTemplateOne = true;
    showDefault = false;
    render(){
        if(this.showTemplateOne){
            return templateOne;
        } else if(this.showDefault){
            return renderExample;
        }
        return templateTwo;
    }

    showTemplateOneJS(){
        this.showTemplateOne = true;
        this.showDefault = false;
    }

    showTemplateTwo(){
        this.showTemplateOne = false;
        this.showDefault = false;
    }

    showDefaultTemplate(){
        this.showTemplateOne = false;
        this.showDefault = true;
    }

}