import { api, LightningElement } from 'lwc';

export default class MetaConfigExamples extends LightningElement {
    @api message;
    @api objectApiName;
    @api showHeader;
    @api maxRecords;
}