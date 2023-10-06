/****************************************************************************************
Name            : ArcGISMsg
Created By      : 2023-07-14 Miles Sollinger - CodeScience
Use             : Msg class to send token, TTL, Url, ObjectInfo, flow to front end
*****************************************************************************************/
public with sharing class ArcGISMsg {
    @AuraEnabled
    public String token { get; set; }
    @AuraEnabled
    public Integer ttl { get; set; }
    @AuraEnabled
    public String url { get; set; }
    @AuraEnabled
    public String enterprisePortalUrl { get; set; }
    @AuraEnabled
    public String orgVfUrl { get; set; }
    @AuraEnabled
    public String vfUrl { get; set; }
    @AuraEnabled
    public String siteDomain { get; set; }
    @AuraEnabled
    public String spatialReference { get; set; }
    @AuraEnabled
    public String flowApiName { get; set; }
    @AuraEnabled
    public String webMapId { get; set; }
}