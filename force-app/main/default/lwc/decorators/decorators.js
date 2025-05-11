import { LightningElement, api, wire, track } from 'lwc';

export default class Decorators extends LightningElement {

   @api name;
   @track age;
   @track user = {
        Name: 'Amit Singh',
        age: '',
        address: {
            city: 'Noida',
            country: {
                name: 'India',
                code: 'IN'
            },
            state: {
                name: 'Uttar Pradesh',
                stateCode: 'UP'
            }
        }
   }

   @track users = [
        {
            Name: 'Amit Singh',
            age: '',
            address: {
                city: 'Noida',
                country: {
                    name: 'India',
                    code: 'IN'
                },
                state: {
                    name: 'Uttar Pradesh',
                    stateCode: 'UP'
                }
            }
    },
    {
            Name: 'Amit Singh',
            age: '',
            address: {
                city: 'Noida',
                country: {
                    name: 'India',
                    code: 'IN'
                },
                state: {
                    name: 'Uttar Pradesh',
                    stateCode: 'UP'
                }
            }
    },
    {
            Name: 'Amit Singh',
            age: '',
            address: {
                city: 'Noida',
                country: {
                    name: 'India',
                    code: 'IN'
                },
                state: {
                    name: 'Uttar Pradesh',
                    stateCode: 'UP'
                }
            }
    },
    {
            Name: 'Amit Singh',
            age: '',
            address: {
                city: 'Noida',
                country: {
                    name: 'India',
                    code: 'IN'
                },
                state: {
                    name: 'Uttar Pradesh',
                    stateCode: 'UP'
                }
            }
    }
   ]

   @api
   handleChangeUserInfo(){
        this.user = {
            Name: 'Ankit Singh',
            age: '',
            address: {
                city: 'New York',
                country: {
                    name: 'United States',
                    code: 'USA'
                },
                state: {
                    name: 'New York',
                    stateCode: 'USA'
                }
            }
        }
   }
}