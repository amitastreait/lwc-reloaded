import { LightningElement } from 'lwc';
import message from '@salesforce/label/c.Message';
import WelcomeMessage from '@salesforce/label/c.Welcome_Message';
import logo from '@salesforce/resourceUrl/logo';
import CHART_JS from '@salesforce/resourceUrl/ChartJS';
export default class FormatNumbers extends LightningElement {

    pantherSchoolsLogo = logo;

    labels = {
        message,
        WelcomeMessage
    }
}