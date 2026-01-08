import { LightningElement } from 'lwc';
import CHART_JS from '@salesforce/resourceUrl/ChartJS';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
export default class ChartJs extends LightningElement {

    connectedCallback(){
        Promise.all([
            loadScript(this, CHART_JS),
            // loadScript(this, ANOTHER_JS)
        ])
        .then(()=>{
            this.initializeChart()
        })
        .catch((error)=>{

        })
    }

    initializeChart(){
        const ctx = this.refs.myChart;
        new Chart(ctx, {
            type: 'bar',
            data: {
            labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
            datasets: [{
                label: '# of Votes',
                data: [12, 19, 3, 5, 2, 3],
                borderWidth: 1
            }]
            },
            options: {
            scales: {
                y: {
                beginAtZero: true
                }
            }
            }
        });
    }
}