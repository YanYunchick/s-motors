import { api } from 'lwc';
import LightningModal from 'lightning/modal';
export default class ModalList extends LightningModal {
    @api content;
    @api structure;
    hasData = false;
    connectedCallback() {
        this.hasData = true;
    }
    handleClose() {
        this.close('close');
    }
}