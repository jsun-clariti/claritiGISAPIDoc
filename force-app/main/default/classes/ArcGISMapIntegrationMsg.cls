/****************************************************************************************
Name            : ArcGISMapIntegrationMsg
Created By      : 2023-07-12 Miles Sollinger - CodeScience
Use             : Msg class for getting/saving ArcGIS_Map_Integration__c custom setting
*****************************************************************************************/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class ArcGISMapIntegrationMsg {
    @AuraEnabled
    public String arcGISType { get; set; }
    @AuraEnabled
    public String connectionType { get; set; }
    @AuraEnabled
    public String clientId { get; set; }
    @AuraEnabled
    public String clientSecret { get; set; }
    @AuraEnabled
    public String url { get; set; }
    @AuraEnabled
    public String username { get; set; }
    @AuraEnabled
    public String password { get; set; }
    @AuraEnabled
    public String enterprisePortalUrl { get; set; }
    public Boolean isOnlineApplication {
        get {
            return this.arcGISType == Constants.ARCGIS_TYPE_ONLINE &&
                this.connectionType == Constants.CONNECTION_TYPE_APPLICATION;
        }
        set;
    }
    public Boolean isOnlineUser {
        get {
            return this.arcGISType == Constants.ARCGIS_TYPE_ONLINE &&
                this.connectionType == Constants.CONNECTION_TYPE_USER;
        }
        set;
    }
    public Boolean isEnterprise {
        get {
            return this.arcGISType == Constants.ARCGIS_TYPE_ENTERPRISE;
        }
        set;
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    // Empty constructor needed for LWC
    public ArcGISMapIntegrationMsg() {
    }

    public ArcGISMapIntegrationMsg(ArcGIS_Map_Integration__c integrationSetting) {
        this.arcGISType = integrationSetting.ArcGIS_Type__c;
        this.connectionType = integrationSetting.Connection_Type__c;
        this.clientId = integrationSetting.Client_Id__c;
        this.clientSecret = integrationSetting.Client_Secret__c;
        this.username = integrationSetting.Username__c;
        this.password = integrationSetting.Password__c;
        this.url = integrationSetting.URL__c;
        this.enterprisePortalUrl = integrationSetting.Enterprise_Portal_URL__c;
    }

    public ArcGIS_Map_Integration__c convertToCustomSetting(ArcGIS_Map_Integration__c integrationSetting) {
        integrationSetting.ArcGIS_Type__c = this.arcGISType;
        integrationSetting.Connection_Type__c = this.connectionType;
        integrationSetting.Client_Id__c = this.clientId;
        integrationSetting.Client_Secret__c = this.clientSecret;
        integrationSetting.Username__c = this.username;
        integrationSetting.Password__c = this.password;
        integrationSetting.URL__c = this.url;
        integrationSetting.Enterprise_Portal_URL__c = this.enterprisePortalUrl;
        return integrationSetting;
    }
}