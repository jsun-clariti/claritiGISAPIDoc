import { LightningElement, api } from 'lwc';

export default class Illustration extends LightningElement {
    @api heading;
    @api detailMessage;
}
