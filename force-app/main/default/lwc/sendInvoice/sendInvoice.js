import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailBody from '@salesforce/apex/OpportunityInvoiceExtension.getEmailBody';
import getPrimaryContact from '@salesforce/apex/OpportunityInvoiceExtension.getPrimaryContact';
import getAttachedInvoiceId from '@salesforce/apex/OpportunityInvoiceExtension.getAttachedInvoiceId';
import sendEmail from '@salesforce/apex/OpportunityInvoiceExtension.sendEmail';

import INVOICE_NUMBER from '@salesforce/schema/Opportunity.InvoiceNumber__c';
const fields = [INVOICE_NUMBER];

export default class SendInvoice extends NavigationMixin(LightningElement) {
    @api recordId;
    hasData = false;
    primaryContact;
    HTMLBody;
    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'list',
        'indent',
        'align',
        'link',
        'clean',
        'table',
        'header',
    ];

    @wire(getRecord, { recordId: '$recordId', fields })
    opportunity;

    get emailSubject() {
        return getFieldValue(this.opportunity.data, INVOICE_NUMBER);
    }

    @wire(getEmailBody, {templateName: 'Invoice Email Template'})
    emailBody;

    @wire(getPrimaryContact, { recordId: '$recordId' })
    wiredGetPrimaryContact({ error, data }) {
        if (data) {
            this.primaryContact = data;
            this.hasData = true;
        } else if (error) {
            console.log('error', error);
        }
    }

    @wire(getAttachedInvoiceId, { recordId: '$recordId'})
    invoicePDFId;

    previewAction() {
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: this.invoicePDFId.data
            }
        })
    }

    sendEmailAction() {
        this.HTMLBody = this.template.querySelector('lightning-input-rich-text').value;
        sendEmail({emailBody: this.HTMLBody, recordId: this.recordId})
        .then(() => {
            console.log("Email Sent");
        })
        .catch((error) => {
            console.error("Error in sendEmailController:", error);
        });
        
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new ShowToastEvent({
            title: 'Email',
            message: 'Successfully sent',
            variant: 'success',
        }));
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}