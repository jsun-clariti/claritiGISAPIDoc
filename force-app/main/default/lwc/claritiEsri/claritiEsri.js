import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import MAP_OBJECT from '@salesforce/schema/Map__c';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import labels from 'c/labelService';
import { showToast } from 'c/toastService';
import getToken from '@salesforce/apex/ClaritiEsriController.getToken';
import saveMapData from '@salesforce/apex/ClaritiEsriController.saveMapData';
import getArcGISDetails from '@salesforce/apex/ClaritiEsriController.getArcGISDetails';

const FOOTER_NEW_ACTION = 'Footer with "New" Action';
const FOOTER_EDIT_BTN = 'Footer with Edit Button';
const NO_FOOTER = 'No Footer';

export default class ClaritiEsri extends LightningElement {
    labels = labels;
    visualforceUrl;
    orgVfUrl;
    siteDomain;
    showSpinner = false;
    showFooterSpinner = false;
    authenticationAvailable;
    authenticationNotAvailable;
    heading = this.labels.ArcGisComponentEmptyStateHeading;
    detailMessage = this.labels.ArcGisComponentGenericError;
    setupIllustrationHeading = this.labels.NoMapConfigured;
    pollId;
    token;
    url;
    enterprisePortalUrl;
    @api mapFooter;
    @api mapConfiguration;
    webMapId;
    flowApiName;
    showScreenFlow = false;
    flowInputVariables = [];
    metadataNotConfigured = false;
    @api mapObjectAPIName;
    @api recordId;
    @api objectApiName;
    showCancelSaveBtns = false;

    @api
    get mapRecordId() {
        // used in flow
        return this._mapRecordId;
    }
    set mapRecordId(value) {
        this._mapRecordId = value;
    }
    _mapRecordId;

    @api mapConfigurationFlowInput; // used in flow
    spatialReference;
    itemsSelected = 0;
    @api readOnlyInput;
    boundFunction;

    // Fall back to Math.random for browsers like Safari, which didn't implement
    // `randomUUID` until 15.3 (Jan 2022)
    // eslint-disable-next-line no-restricted-globals
    #uuid = self?.crypto?.randomUUID ? self.crypto.randomUUID() : Math.random().toString(36);

    async connectedCallback() {
        this.showSpinner = true;
        try {
            let recordIdToUse = this.objectApiName ? this.recordId : this.mapRecordId;
            let arcGISresult = await getArcGISDetails({
                objectApiName: this.objectApiName,
                fieldApiName: this.mapObjectAPIName,
                recordId: recordIdToUse,
                developerName: this.mapDeveloperName
            });
            if (arcGISresult) {
                if (arcGISresult.token && arcGISresult.ttl) {
                    this.token = arcGISresult.token;
                    this.authenticationAvailable = true;
                    this.url = arcGISresult.url;
                    this.enterprisePortalUrl = arcGISresult.enterprisePortalUrl;
                    this.pollAuthToken(arcGISresult.ttl);
                } else {
                    this.authenticationNotAvailable = true;
                    return;
                }
                if (arcGISresult.vfUrl.includes('?isdtp=mn')) {
                    this.visualforceUrl = arcGISresult.vfUrl + '&uuid=' + encodeURI(this.#uuid);
                } else {
                    this.visualforceUrl = arcGISresult.vfUrl + '?uuid=' + encodeURI(this.#uuid);
                }
                this.orgVfUrl = arcGISresult.orgVfUrl;
                this.siteDomain = arcGISresult.siteDomain;
                if (!arcGISresult.webMapId) {
                    this.metadataNotConfigured = true;
                    return;
                }
                this.flowApiName = arcGISresult.flowApiName;
                this.webMapId = arcGISresult.webMapId;
                if (arcGISresult.spatialReference.length > 2) {
                    this.spatialReference = arcGISresult.spatialReference;
                }

                this.boundFunction = this.handleVFMessage.bind(this);
                window.addEventListener('message', this.boundFunction);
            }
        } catch (error) {
            this.authenticationNotAvailable = true;
        } finally {
            this.showSpinner = false;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.boundFunction);
    }

    @wire(getObjectInfo, { objectApiName: MAP_OBJECT })
    wiredMapObjectInfo;

    get isReadOnly() {
        return this.wiredMapObjectInfo.data
            ? this.wiredMapObjectInfo.data.createable === false || this.readOnlyInput
            : true;
    }

    get showFooter() {
        return this.mapFooter !== NO_FOOTER;
    }

    get showNewBtn() {
        return this.mapFooter === FOOTER_NEW_ACTION;
    }

    get showEditFooterBtns() {
        return this.mapFooter === FOOTER_EDIT_BTN;
    }

    get disableNewBtn() {
        return this.itemsSelected === 0 || this.isReadOnly;
    }

    get disableEditBtn() {
        return this.isReadOnly;
    }

    get itemsSelectedText() {
        return this.itemsSelected + ' ' + labels.ArcGisComponentItemsSelected;
    }

    get mapDeveloperName() {
        return this.mapConfiguration || this.mapConfigurationFlowInput;
    }

    pollAuthToken(ttl) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.pollId = setInterval(() => {
            // Check if the user has navigated away from the page
            if (this.template.querySelector('div').offsetParent === null) {
                clearInterval(this.pollId);
            } else {
                getToken()
                    .then(result => {
                        let eventData = { ...result };
                        eventData.eventType = 'updateToken';
                        this.sendMsgToVfPage(eventData);
                    })
                    .catch(() => {
                        this.authenticationNotAvailable = true;
                    });
            }
        }, ttl);
    }

    handleNewBtnClick() {
        let eventData = {
            eventType: 'saveDrawings'
        };
        this.sendMsgToVfPage(eventData);
    }

    handleEditBtnClick() {
        let eventData = {
            eventType: 'loadDrawingTools'
        };
        this.sendMsgToVfPage(eventData);
        this.showCancelSaveBtns = true;
    }

    handleCancelBtnClick() {
        let eventData = {
            eventType: 'cancelEdit',
            spatialReference: this.spatialReference
        };
        this.sendMsgToVfPage(eventData);
        this.showCancelSaveBtns = false;
    }

    handleSaveBtnClick() {
        let eventData = {
            eventType: 'saveEdit'
        };
        this.sendMsgToVfPage(eventData);
    }

    handleLoadData() {
        let loadDrawingTools = this.isReadOnly || this.showEditFooterBtns ? false : true;
        let eventData = {
            eventType: 'loadDrawings',
            url: this.url,
            enterprisePortalUrl: this.enterprisePortalUrl,
            token: this.token,
            mapId: this.webMapId,
            mapFooter: this.mapFooter,
            isReadOnly: this.isReadOnly,
            spatialReference: this.spatialReference,
            loadDrawingTools: loadDrawingTools
        };
        this.sendMsgToVfPage(eventData);
    }

    handleVFMessage(event) {
        if ((event.origin !== this.orgVfUrl && event.origin !== this.siteDomain) || event.data.uuid !== this.#uuid) {
            return;
        }
        if (event.data.eventType === 'saveDrawings') {
            if (!event.data.isEdit && !this.flowApiName) {
                showToast(this, labels.NoFlowConfigured, 'info', null);
                return;
            }
            this.showFooterSpinner = true;
            this.saveMapData(event.data.eventData)
                .then(result => {
                    this.spatialReference = event.data.eventData;
                    if (event.data.isEdit) {
                        this.showCancelSaveBtns = false;
                        showToast(this, labels.SaveToastMessage, 'success', null);
                    } else {
                        this.flowInputVariables = [
                            {
                                name: 'mapId',
                                type: 'String',
                                value: result
                            }
                        ];
                        this.showScreenFlow = true;
                    }
                })
                .catch(error => {
                    showToast(this, error.body.message, 'error', labels.Error);
                })
                .finally(() => {
                    this.showFooterSpinner = false;
                });
        } else if (event.data.eventType === 'updateDrawings') {
            this.itemsSelected = event.data.shapeCount;
            // Save JSON data on every update if component is in a flow
            if (this.mapConfigurationFlowInput && !event.data.isOnLoad) {
                this.saveMapData(event.data.jsonData)
                    .then(result => {
                        this._mapRecordId = result;
                        this.dispatchEvent(new FlowAttributeChangeEvent('mapRecordId', this._mapRecordId));
                    })
                    .catch(error => {
                        showToast(this, error.body.message, 'error', labels.Error);
                    });
            }
        } else if (event.data.eventType === 'loadDrawings') {
            this.handleLoadData();
        }
    }

    async saveMapData(jsonData) {
        let recordId = this._mapRecordId || this.recordId;
        let saveResult = await saveMapData({
            jsonData: jsonData,
            objectApiName: this.objectApiName,
            fieldApiName: this.mapObjectAPIName,
            recordId: recordId
        });

        return saveResult;
    }

    sendMsgToVfPage(eventData) {
        let eventObj = { ...eventData };
        eventObj.uuid = this.#uuid;
        const iframeWindow = this.template.querySelector('iframe').contentWindow;
        let postUrl = this.siteDomain ? this.siteDomain : this.orgVfUrl;
        iframeWindow.postMessage(eventObj, postUrl);
    }
}
