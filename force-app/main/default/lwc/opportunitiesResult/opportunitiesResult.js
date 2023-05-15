import { LightningElement, track, wire, api } from 'lwc';
import ModalList from 'c/modalList';
import searchAccounts from '@salesforce/apex/OpportunitiesResultController.searchAccounts';
import getOpportunityProducts from '@salesforce/apex/OpportunitiesResultController.getOpportunityProducts';
import getAccount from '@salesforce/apex/OpportunitiesResultController.getAccount';
const OPP_COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'recordLink', type: 'url',
     typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency' },
    {
        type:"button",
        label:'Products',
        typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,  
            value: 'view',  
            iconPosition: 'left' 
        }
    },  
];
const PROD_COLUMNS = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Quantity', fieldName: 'Quantity', type: 'number'},
    {label: 'Price', fieldName: 'TotalPrice', type: 'currency'}
];
export default class OpportunitiesResult extends LightningElement {
    @api recordId;
    @track searchTerm = '';
    totalAccounts;
    visibleAccounts;
    products;
    columns = OPP_COLUMNS;
    
    connectedCallback() {
        if(this.recordId) {
            getAccount({
                accId: this.recordId
            }).then((result) => {
                console.log(this.recordId);
                this.visibleAccounts = [];
                for(let key in result) {
                    this.visibleAccounts.push({value:result[key], key:key});
                } 
                this.visibleAccounts.map(element => {
                    if (element.value) {  
                        var tempOppList = [];  
                        for (var i = 0; i < element.value.length; i++) {  
                         let tempRecord = Object.assign({}, element.value[i]); 
                         tempRecord.recordLink = "/" + tempRecord.Id;  
                         tempOppList.push(tempRecord);  
                        } 
                        element.value = tempOppList;
                }});
            })
            .catch((error) => {
                console.log(error);
            })
        }

    }

    @wire(searchAccounts, {searchTerm: '$searchTerm'})
    loadAccounts({error,data}) {
        if(data) {
            this.totalAccounts = [];
            for(let key in data) {

                this.totalAccounts.push({value:data[key], key:key});
            } 
            this.totalAccounts.map(element => {
                if (element.value) {  
                    var tempOppList = [];  
                    for (var i = 0; i < element.value.length; i++) {  
                     let tempRecord = Object.assign({}, element.value[i]); 
                     tempRecord.recordLink = "/" + tempRecord.Id;  
                     tempOppList.push(tempRecord);  
                    } 
                    element.value = tempOppList;
            }});
        } else if (error) {
            console.log(error);
        }
    }
    updateAccountHandler(event){
        this.visibleAccounts=[...event.detail.records]
    }
    handleSearchTermChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
		}, 300);
	}
    showProducts(event) {
        console.log(event.detail.row.Id);
        getOpportunityProducts({
            oppId: event.detail.row.Id
        }).then((result) => {
                this.products = result;
                ModalList.open({
                    content: this.products,
                    structure: PROD_COLUMNS
                    }).then((result) => {
                        console.log(result);
                });
            })
            .catch((error) => {
                console.log(error);
            });
    }

}