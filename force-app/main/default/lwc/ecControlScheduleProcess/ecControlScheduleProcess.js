import { LightningElement,wire } from 'lwc';
import getScheduledProcessInfo from '@salesforce/apex/EC_ScheduleController.getScheduledProcessInfo';
import toggleScheduler from '@salesforce/apex/EC_ScheduleController.toggleScheduler';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/ecUtils';
export default class EcControlScheduleProcess extends LightningElement {

    lastRunInfo;
    isScheduled;

    @wire(getScheduledProcessInfo)
    wiredGetScheduledProcessInfo({ err, data }) {
        if (data) {
            console.log('RESULT FETCHED >> ' + JSON.stringify(data));
            this.lastRunInfo = data.lastRunInfo || 'Unknown';
            this.isScheduled = data.isScheduled;
        } else if (err) {
            showAsyncErrorMessage(this, err);
        }
    }

    handleInputChange(event) {
        if(event.currentTarget.name === 'invoiceSchedulerToggle') {
            toggleScheduler({})
            .then(res=>{
                    this.isScheduled = !this.isScheduled;
                    showMessage(this,{
                        title: "Success",
                        message: "Toggled Successfully",
                        messageType: "success",
                        mode: "dismissable"
                    });
            })
            .catch(err=>{
                showAsyncErrorMessage(this,err);
            })
        }
        console.log('EVENT >> ' + event.currentTarget.checked);
    }




}