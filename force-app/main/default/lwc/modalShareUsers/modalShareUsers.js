import { track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import getSharedUsers from '@salesforce/apex/OpportunityWorkspaceController.getSharedUsers';
import saveSharing from '@salesforce/apex/OpportunityWorkspaceController.saveSharing';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    {
        type:"button",
        label:'Remove',
        typeAttributes: {
            label: 'Remove',
            name: 'Remove',
            title: 'Remove',
            disabled: false,  
            value: 'remove',  
            iconPosition: 'right' 
        }
    },  
];
export default class ModalShareUsers extends LightningModal {
    @track selectedRecords = [];
    columns = columns;
    @track selectedRecordsLength;
    @track sharedUsers;
    removedUsers = [];
    @api oppId;
    hasData = false;
    handleselectedCompanyRecords(event) {
        this.selectedRecords = [...event.detail.selRecords]
        this.selectedRecordsLength = this.selectedRecords.length;
    }
    connectedCallback() {
        getSharedUsers({
            oppId: this.oppId
        }).then((result) => {
                this.sharedUsers = result;
                this.hasData = true;
            })
            .catch((error) => {
                console.log(error);
            });
    }
    removeUser(event) {
        let removedUser = event.detail.row.Id;
        console.log('test1');
        let newList = this.sharedUsers.filter(object => {
            return object.Id !== removedUser;
        });
        console.log('test2');
        this.sharedUsers = newList;
        this.removedUsers.push(removedUser);
        console.log('test3');
    }
    saveResult() {
        let selectedIds = this.selectedRecords.map(item => item = item.Id);
        console.log(selectedIds);
        saveSharing({
            oppId: this.oppId,
            addedUsers: selectedIds,
            removedUsers: this.removedUsers
        }).then((result) => {
            console.log('success!!!');
            this.close('close');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Sharing',
                message: 'Successfully Saved',
                variant: 'success',
            }));
            })
            .catch((error) => {
                console.log(error);
                this.close('close');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Sharing',
                    message: 'Not Saved',
                    variant: 'error',
                }));
            });
    }
    closeWindow() {
        this.close('close');
    }
}