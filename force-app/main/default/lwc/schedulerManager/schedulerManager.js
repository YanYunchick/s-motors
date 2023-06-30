import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import runOnceBatch from '@salesforce/apex/SchedulerManagerController.runOnceBatch';
import abortBatch from '@salesforce/apex/SchedulerManagerController.abortBatch';
import scheduleBatch from '@salesforce/apex/SchedulerManagerController.scheduleBatch';
import getJobState from '@salesforce/apex/SchedulerManagerController.getJobState';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SchedulerManager extends LightningModal {
    @api batchName;
    @api schedulerName;
    jobName = 'Birthday Email';
    cronString = '';
    jobID;

    connectedCallback() {
        getJobState({
            jobName: this.jobName
        })
        .then((result) => {
            this.jobID = result;
        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }
    runOnceAction() {
        runOnceBatch({batchName: this.batchName})
        .then(() => {
            console.log("batch is running");
            this.dispatchEvent(new ShowToastEvent({
                title: 'Batch',
                message: 'Successfully ran',
                variant: 'success',
            }));
        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }

    abortAction() {
        abortBatch({
            abortedJob: this.jobID
        })
        .then(() => {
            this.jobID = undefined;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Batch',
                message: 'Successfully aborted',
                variant: 'success',
            }));
        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }

    scheduleAction() {
        scheduleBatch({
            schedulerName: this.schedulerName,
            cronString: this.cronString,
            jobName: this.jobName
        })
        .then((result) => {
            this.jobID = result;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Scheduler',
                message: 'Successfully created',
                variant: 'success',
            }));
        })
        .catch((error) => {
            console.error("Error:", error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Invalid CRON String',
                variant: 'error',
            }));
        });
    }

    handleChange(event){
        this.cronString = event.target.value;
    }
}