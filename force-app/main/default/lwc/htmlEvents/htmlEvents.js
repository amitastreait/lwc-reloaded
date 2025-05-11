import { LightningElement } from 'lwc';

export default class HtmlEvents extends LightningElement {

    handleNameChange(event){
        console.log('Name Change Event')
        console.log(event.target);
        console.log(event.target.value);
        console.log(event.target.type);
        console.log(event.target.label);
    }

    handleEmailChange = (event) => {
        console.log('Email Change Event')
        console.log(event.target);
        console.log(event.target.value);
    }

    handleClick(event){
        console.log('Click Event')
        console.log(event.target);
        console.log(event.target.label);
        console.log(event.target.title);
        console.log(event.target.variant);
    }
}