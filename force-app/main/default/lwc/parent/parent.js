import { LightningElement } from 'lwc';

export default class Parent extends LightningElement {
    message = 'I am from parent component'
    contacts = [
        {
            "Id": 1,
            "FirstName": "Amy",
            "LastName": "Taylor",
            "Title": "VP of Engineering",
            "Email": "amy@demo.net",
            "Phone": "4152568563",
            "Picture__c": "https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/people/amy_taylor.jpg"
        },
        {
            "Id": 2,
            "FirstName": "Michael",
            "LastName": "Jones",
            "Title": "VP of Sales",
            "Email": "michael@demo.net",
            "Phone": "4158526633",
            "Picture__c": "https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/people/michael_jones.jpg"
        },
        {
            "Id": 3,
            "FirstName": "Jennifer",
            "LastName": "Wu",
            "Title": "CEO",
            "Email": "jennifer@demo.net",
            "Phone": "4158521463",
            "Picture__c": "https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/people/jennifer_wu.jpg"
        }
    ];

    greetings = '';
    hasRendered = false;

    constructor(){
        super();
        console.log(`I am from parent component constructor`);
        this.message = 'Changed from constructor';
        this.contacts = [
            {
                "Id": 1,
                "FirstName": "Amy",
                "LastName": "Taylor",
                "Title": "VP of Engineering",
                "Email": "amy@demo.net",
                "Phone": "4152568563",
                "Picture__c": "https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/people/amy_taylor.jpg"
            }
        ]
        console.log(this.message);
    }

    connectedCallback(){
        console.log(`I am from parent component connectedCallback`);
        this.handleMessage('Inside Handle message');
        this.loadCss();
        this.loadExternalJs();
        this.greetings = `${Math.random()}`
        alert(this.greetings);
    }

    renderedCallback(){
       /* if(!this.hasRendered){
            console.log(`I am from parent component renderedCallback`);
            this.greetings = `${Math.random()}`;
            this.hasRendered = true;
        } */
        if(this.hasRendered){
            return;
        }
        console.log(`I am from parent component renderedCallback`);
        this.greetings = `${Math.random()}`;
        this.hasRendered = true;
        /** Can Access the child elements */
    }

    handleMessage(message){
        console.log(message)
    }

    loadCss(){
        console.log('Loading the External CSS Files')
    }
    loadExternalJs(){
        console.log('Loading the External JS')
    }
}