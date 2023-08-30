import { LightningElement } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityList from '@salesforce/apex/OpportunityWorkspaceController.getOpportunityList';
import hasManagerPermission from '@salesforce/customPermission/Opportunity_Workspace_Permission';

export default class OpportunityChartPie extends LightningElement {
    chart;
    oppPieconfig;

    get hasPermission() {
        return hasManagerPermission;
    }
    
    connectedCallback() {
        getOpportunityList(
        ).then((result) => {
            let listOfOppName = [];
            let listOfOppAmount = [];
            let listOfBackgroundColor = [];
            let mapOppData = new Map();
            for(let i = 0; i < result.length; i++) {
                mapOppData.set(result[i].Name, result[i].Amount);
            }
            mapOppData.forEach(function (value, key) {
                listOfOppName.push(key);
                listOfOppAmount.push(value);
                var randomColor = '#' + Math.floor(Math.random() * 16777215).toString(16);
                listOfBackgroundColor.push(randomColor);
            });
            if (listOfOppAmount.length > 0) {  
                this.oppPieconfig = {
                    type: 'pie',
                    data: {
                        labels: listOfOppName,
                        datasets: [{
                            label: 'Opportunity',
                            data: listOfOppAmount,
                            backgroundColor: listOfBackgroundColor,
                            borderColor: listOfBackgroundColor,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        legend: {
                            position: 'bottom',
                            align: 'start'
                        },
                        title: {
                            display: true,
                            text: 'Amounts of Opportunities($)'
                          }
                    },
                };                
                }
                Promise.all([loadScript(this, chartjs)])
                .then(() => {        
                const ctx = this.template.querySelector('canvas');
                this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.oppPieconfig)));         
               })
               .catch(error => {
                    console.log(error);
                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: 'Error loading Chart',
                    //         message: error.message,
                    //         variant: 'error',
                    //     })
                    // );
                });
                console.log('end conf');
            })
            .catch((error) => {
                console.log(error);
            });
    }
}