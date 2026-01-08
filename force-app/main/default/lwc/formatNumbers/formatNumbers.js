import { LightningElement } from 'lwc';
import message from '@salesforce/label/c.Message';
import WelcomeMessage from '@salesforce/label/c.Welcome_Message';
import logo from '@salesforce/resourceUrl/logo';
import CHART_JS from '@salesforce/resourceUrl/ChartJS';

import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class FormatNumbers extends LightningElement {

    pantherSchoolsLogo = logo;

    labels = {
        message,
        WelcomeMessage
    }

    connectedCallback(){
        Promise.all([
            loadScript(this, CHART_JS),
        ]).then(() => {
            this.initializeChart();
        });
    }
    initializeChart(){
        
    }
}