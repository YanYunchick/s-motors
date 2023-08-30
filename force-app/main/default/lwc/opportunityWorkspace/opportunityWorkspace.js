import { LightningElement, wire, track } from 'lwc';
import searchOpportunities from '@salesforce/apex/OpportunityWorkspaceController.searchOpportunities';
import ModalShareUsers from 'c/modalShareUsers';
import hasManagerPermission from '@salesforce/customPermission/Opportunity_Workspace_Permission';
import { refreshApex } from '@salesforce/apex';
import deleteSelectedOpportunities from '@salesforce/apex/OpportunityWorkspaceController.deleteSelectedOpportunities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Share', name: 'share' },
];

const MANAGER_OPP_COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'recordLink', type: 'url',
     typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency' },
    { label: 'Stage', fieldName: 'StageName', type: 'text'},  
    {
        type:"action",
        typeAttributes: {
            rowActions: actions
        },
    },  
];

const EMPLOYEE_OPP_COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'recordLink', type: 'url',
     typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency' },
    { label: 'Stage', fieldName: 'StageName', type: 'text'},  
];

export default class OpportunityWorkspace extends LightningElement {
    searchTerm = '';
    managerColumns = MANAGER_OPP_COLUMNS;
    employeeColumns = EMPLOYEE_OPP_COLUMNS;
    hasData = false;
    isTrue = false;
    buttonLabel = 'Delete Records';
    @track opportunities = [];
    @track recordsCount = 0;
    selectedRecords = [];

    get hasPermission() {
        return hasManagerPermission;
    }

    // @wire(searchOpportunities, {searchTerm: '$searchTerm'})
    // loadAccounts({error,data}) {
    //     if(data) {
    //         this.opportunities = data;
    //         var tempOppList = [];  
    //         for (var i = 0; i < this.opportunities.length; i++) {  
    //             let tempRecord = Object.assign({}, this.opportunities[i]); 
    //             tempRecord.recordLink = "/" + tempRecord.Id;  
    //             tempOppList.push(tempRecord);  
    //         } 
    //         this.opportunities = tempOppList;
    //         if(this.opportunities.length == 0) {
    //             this.hasData = false;  
    //         } else {
    //             this.hasData = true;
    //         }
    //         console.log(this.opportunities);
    //     } else if (error) {
    //         console.log(error);
    //     }
    // }

    connectedCallback() {
        this.searchData();
    }


    getSelectedRecords(event) {        
        const selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        this.selectedRecords=new Array();
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedRecords.push(selectedRows[i]);
        }        
    }

    deleteRecords() {
        if (this.selectedRecords) {
            this.buttonLabel = 'Processing....';
            this.isTrue = true;
            deleteSelectedOpportunities({deletedOpps: this.selectedRecords })
            .then(result => {
                console.log('result ====> ' + result);
                this.buttonLabel = 'Delete Records';
                this.isTrue = false;
                this.hasData = false; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: this.recordsCount + ' records are deleted.',
                        variant: 'success'
                    }),
                );
                this.template.querySelector('lightning-datatable').selectedRows = [];
                this.recordsCount = 0;
                this.delayTimeout = setTimeout(() => {
                    this.searchData();
                }, 300);
                //return refreshApex(this.opportunities);
            }).catch(error => {
                this.buttonLabel = 'Delete Records';
                this.isTrue = false;                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While Getting Opportunities',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),
                );
            });
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;

        console.log('share');
        ModalShareUsers.open({size: 'small',
                                oppId: rowId});

    }

    handleSearchTermChange(event) {
		window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
		}, 300);
        this.searchData();
	}

    searchData(){
        searchOpportunities({
            searchTerm: this.searchTerm
        })
        .then((result) => {
            console.log('success!!!');
            this.opportunities = result;
            var tempOppList = [];  
            for (var i = 0; i < this.opportunities.length; i++) {  
                let tempRecord = Object.assign({}, this.opportunities[i]); 
                tempRecord.recordLink = "/" + tempRecord.Id;  
                tempOppList.push(tempRecord);  
            } 
            this.opportunities = tempOppList;
            if(this.opportunities.length == 0) {
                this.hasData = false;  
            } else {
                this.hasData = true;
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }
}