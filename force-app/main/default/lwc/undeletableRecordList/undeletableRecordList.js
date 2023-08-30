import { LightningElement, track } from 'lwc';
import getUndeletableContacts from '@salesforce/apex/OpportunityWorkspaceController.getUndeletableContacts';
import getUndeletableAccounts from '@salesforce/apex/OpportunityWorkspaceController.getUndeletableAccounts';
import ModalAddUndeletableRecord from 'c/modalAddUndeletableRecord';
import removeFromUndeletableAccount from '@salesforce/apex/OpportunityWorkspaceController.removeFromUndeletableAccount';
import removeFromUndeletableContact from '@salesforce/apex/OpportunityWorkspaceController.removeFromUndeletableContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasManagerPermission from '@salesforce/customPermission/Opportunity_Workspace_Permission';

const actions = [
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'recordLink', type: 'url',
     typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    {
        type:"action",
        typeAttributes: {
            rowActions: actions
        },
    },  
];

export default class UndeletableRecordList extends LightningElement {
    baseType = 'Contact';
    @track contactList = [];
    @track accountList = [];
    hasData = false;
    isContact = true;
    columns = columns;

    get hasPermission() {
        return hasManagerPermission;
    }

    get options() {
        return [
            { label: 'Contact', value: 'Contact' },
            { label: 'Account', value: 'Account' },
        ];
    }
    connectedCallback() {
        this.getData();
        this.hasData = true;
    }
    handleTypeChange(event) {
        if(event.detail.value == 'Account') {
            this.isContact = false;
        }
        if(event.detail.value == 'Contact') {
            this.isContact = true;
        }
    }

    handleRowAction(event) {
        const rowId = event.detail.row.Id;
        if(this.isContact === true) {
            removeFromUndeletableContact({
                contactId: rowId
            })
            .then((result) => {
                console.log('success!!!');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Deleting',
                    message: 'Successfully Deleted',
                    variant: 'success',
                }));
                })
                .catch((error) => {
                    console.log(error);
                    this.close('close');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Deleting',
                        message: 'Not Deleted',
                        variant: 'error',
                    }));
                });
        } else {
            removeFromUndeletableAccount({
                accountId: rowId
            })
            .then((result) => {
                console.log('success!!!');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Deleting',
                    message: 'Successfully Deleted',
                    variant: 'success',
                }));
                })
                .catch((error) => {
                    console.log(error);
                    this.close('close');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Deleting',
                        message: 'Not Deleted',
                        variant: 'error',
                    }));
                });
        }
        console.log('do');
        console.log(this.contactList);
        this.hasData = false;
        this.getData();
        console.log('posle');
        console.log(this.contactList);
    }

    getData() {
        getUndeletableAccounts()
        .then((result) => {
            this.accountList = result;
            var tempList = [];  
            for (var i = 0; i < this.accountList.length; i++) {  
                let tempRecord = Object.assign({}, this.accountList[i]); 
                tempRecord.recordLink = "/" + tempRecord.Id;  
                tempList.push(tempRecord);  
            } 
            this.accountList = tempList;
            console.log(this.accountList);
            getUndeletableContacts()
            .then((result) => {
                this.contactList = result;
                var tempList = [];  
                for (var i = 0; i < this.contactList.length; i++) {  
                    let tempRecord = Object.assign({}, this.contactList[i]); 
                    tempRecord.recordLink = "/" + tempRecord.Id;  
                    tempList.push(tempRecord);  
                } 
                this.contactList = tempList;
                console.log(this.contactList);
            })
            .catch((error) => {
                console.log(error);
            })
            this.hasData = true;
        })
        .catch((error) => {
            console.log(error);
        })
    }

    openAdd() {
        let object = this.isContact === true ? 'Contact' : 'Account';
        ModalAddUndeletableRecord.open({size: 'small',
                                        objectname: object});
    }
}