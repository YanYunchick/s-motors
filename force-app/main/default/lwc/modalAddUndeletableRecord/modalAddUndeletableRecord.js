import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import saveAddedUndeletableAccounts from '@salesforce/apex/OpportunityWorkspaceController.saveAddedUndeletableAccounts';
import saveAddedUndeletableContacts from '@salesforce/apex/OpportunityWorkspaceController.saveAddedUndeletableContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ModalAddUndeletableRecord extends LightningModal {
    @api objectname;
    @track selectedRecords = [];
    @track selectedRecordsLength;

    handleSelectedRecords(event) {
        console.log('--');
        this.selectedRecords = [...event.detail.selRecords]
        this.selectedRecordsLength = this.selectedRecords.length;
        console.log(this.selectedRecords);
    }
    
    saveResult() {
        console.log('savestart');
        console.log(this.selectedRecords);
        let selectedIds = this.selectedRecords.map(item => {
            return item = item.Id;
        });
        console.log(this.objectname);
        if(this.objectname == 'Contact') {
            saveAddedUndeletableContacts({
                updatedContactIds: selectedIds
            }).then((result) => {
                console.log('success!!!');
                this.close('close');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Updating',
                    message: 'Successfully Saved',
                    variant: 'success',
                }));
                })
                .catch((error) => {
                    console.log(error);
                    this.close('close');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Updating',
                        message: 'Not Saved',
                        variant: 'error',
                    }));
                });
        } else {
            saveAddedUndeletableAccounts({
                updatedAccountIds: selectedIds
            }).then((result) => {
                console.log('success!!!');
                this.close('close');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Updating',
                    message: 'Successfully Saved',
                    variant: 'success',
                }));
                })
                .catch((error) => {
                    console.log(error);
                    this.close('close');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Updating',
                        message: 'Not Saved',
                        variant: 'error',
                    }));
                });
        }
    }

    closeWindow() {
        this.close('close');
    }
}