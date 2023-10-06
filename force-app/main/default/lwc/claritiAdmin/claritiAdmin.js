import { LightningElement, track } from 'lwc';
import labels from 'c/labelService';
import { showToast } from 'c/toastService';
import getMapIntegration from '@salesforce/apex/AdminCtrl.getMapIntegration';
import saveMapIntegration from '@salesforce/apex/AdminCtrl.saveMapIntegration';

export default class ClaritiAdmin extends LightningElement {
    labels = labels;
    arcGISTypeOptions = [
        { label: labels.ArcGISTypeOnline, value: 'online' },
        { label: labels.ArcGISTypeEnterprise, value: 'enterprise' }
    ];
    connectionTypeOptions = [
        { label: labels.ConnectionTypeApplication, value: 'application' },
        { label: labels.ConnectionTypeNamedUser, value: 'user' }
    ];
    @track mapIntegrationMsg = {
        arcGISType: null,
        connectionType: null,
        clientId: null,
        clientSecret: null,
        username: null,
        password: null,
        url: null,
        enterprisePortalUrl: null
    };
    originalMapIntegrationMsg = {};
    showSpinner = false;
    readOnly;
    showCancelBtn;

    connectedCallback() {
        this.showSpinner = true;
        getMapIntegration()
            .then(result => {
                this.mapIntegrationMsg = { ...result };
                this.originalMapIntegrationMsg = { ...result };
                let allPropertiesFalsy = Object.values(this.mapIntegrationMsg).every(value => !value);
                this.readOnly = !allPropertiesFalsy;
                this.showCancelBtn = !allPropertiesFalsy;
            })
            .catch(error => {
                showToast(this, error.body.message, 'error', 'Error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    get showOnlineSetup() {
        return this.mapIntegrationMsg.arcGISType === 'online';
    }

    get showUserDetails() {
        return this.mapIntegrationMsg.connectionType === 'user';
    }

    get showApplicationDetails() {
        return this.mapIntegrationMsg.connectionType === 'application';
    }

    get showEnterpriseSetup() {
        return this.mapIntegrationMsg.arcGISType === 'enterprise';
    }

    get showOnlineDetails() {
        return this.mapIntegrationMsg.arcGISType === 'online' && this.mapIntegrationMsg.connectionType;
    }

    get disableAuthorizeBtn() {
        if (!this.mapIntegrationMsg.arcGISType) {
            return true;
        }

        if (this.mapIntegrationMsg.arcGISType === 'online' && !this.mapIntegrationMsg.connectionType) {
            return true;
        }

        if (
            this.mapIntegrationMsg.arcGISType === 'online' &&
            this.mapIntegrationMsg.connectionType === 'application' &&
            (!this.mapIntegrationMsg.clientId || !this.mapIntegrationMsg.clientSecret)
        ) {
            return true;
        }

        if (
            this.mapIntegrationMsg.arcGISType === 'online' &&
            this.mapIntegrationMsg.connectionType === 'user' &&
            (!this.mapIntegrationMsg.username || !this.mapIntegrationMsg.password)
        ) {
            return true;
        }

        if (
            this.mapIntegrationMsg.arcGISType === 'enterprise' &&
            (!this.mapIntegrationMsg.enterprisePortalUrl ||
                !this.mapIntegrationMsg.url ||
                !this.mapIntegrationMsg.username ||
                !this.mapIntegrationMsg.password)
        ) {
            return true;
        }

        return false;
    }

    handleArcGISTypeChange(event) {
        this.mapIntegrationMsg.arcGISType = event.detail.value;
        this.clearFields();
        this.mapIntegrationMsg.connectionType = null;
    }

    handleConnectionTypeChange(event) {
        this.mapIntegrationMsg.connectionType = event.detail.value;
        this.clearFields();
    }

    handleTextFieldChange(event) {
        let fieldName = event.currentTarget.dataset.name;
        let fieldValue = event.currentTarget.value;
        this.mapIntegrationMsg[fieldName] = fieldValue;
    }

    handleEditClick() {
        this.readOnly = false;
        this.showCancelBtn = true;
    }

    handleCancelClick() {
        this.mapIntegrationMsg = { ...this.originalMapIntegrationMsg };
        this.readOnly = true;
    }

    handleAuthorizeClick() {
        this.showSpinner = true;
        saveMapIntegration({ msg: this.mapIntegrationMsg })
            .then(() => {
                showToast(this, null, 'success', labels.Connected);
                this.originalMapIntegrationMsg = { ...this.mapIntegrationMsg };
                this.readOnly = true;
            })
            .catch(() => {
                showToast(this, labels.AuthorizationFailure, 'error', labels.Error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    clearFields() {
        this.mapIntegrationMsg.clientId = null;
        this.mapIntegrationMsg.clientSecret = null;
        this.mapIntegrationMsg.username = null;
        this.mapIntegrationMsg.password = null;
        this.mapIntegrationMsg.url = null;
        this.mapIntegrationMsg.enterprisePortalUrl = null;
    }
}
