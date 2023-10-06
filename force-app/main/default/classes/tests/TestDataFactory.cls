/****************************************************************************************
Name            : TestDataFactory
Created By      : 2023-07-17 Miles Sollinger - CodeScience
Use             : Test data setup for unit tests
*****************************************************************************************/
@isTest
public with sharing class TestDataFactory {
    public static void setupOnlineApplicationSetting() {
        ArcGIS_Map_Integration__c integrationSetting = ArcGIS_Map_Integration__c.getOrgDefaults();
        integrationSetting.ArcGIS_Type__c = Constants.ARCGIS_TYPE_ONLINE;
        integrationSetting.Connection_Type__c = Constants.CONNECTION_TYPE_APPLICATION;
        integrationSetting.Client_Id__c = 'abc';
        integrationSetting.Client_Secret__c = 'def';
        integrationSetting.URL__c = 'test.arcgis.com';
        upsert integrationSetting;
    }

    public static void setupOnlineUserSetting() {
        ArcGIS_Map_Integration__c integrationSetting = ArcGIS_Map_Integration__c.getOrgDefaults();
        integrationSetting.ArcGIS_Type__c = Constants.ARCGIS_TYPE_ONLINE;
        integrationSetting.Connection_Type__c = Constants.CONNECTION_TYPE_USER;
        integrationSetting.Username__c = 'test.user';
        integrationSetting.Password__c = 'pass';
        integrationSetting.URL__c = 'test.arcgis.com';
        upsert integrationSetting;
    }

    public static void setupEnterpriseSetting() {
        ArcGIS_Map_Integration__c integrationSetting = ArcGIS_Map_Integration__c.getOrgDefaults();
        integrationSetting.ArcGIS_Type__c = Constants.ARCGIS_TYPE_ENTERPRISE;
        integrationSetting.Username__c = 'test.user';
        integrationSetting.Password__c = 'pass';
        integrationSetting.URL__c = 'test.myarcigs.com';
        integrationSetting.Enterprise_Portal_URL__c = 'test.myarcigs.com/arcgis';
        upsert integrationSetting;
    }

    public static Map__c createEmptyMap() {
        Map__c emptyMap = new Map__c();
        insert emptyMap;
        return emptyMap;
    }

    public static Map_Geometry__c createMapGeometry(Id mapId) {
        return new Map_Geometry__c(
            Map__c = mapId,
            Type__c = Constants.GEOMETRY_TYPE_JSON,
            Data__c = '{"test": "test"}'
        );
    }
}