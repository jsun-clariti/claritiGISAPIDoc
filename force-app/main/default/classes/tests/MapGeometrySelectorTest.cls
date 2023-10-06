@IsTest
public with sharing class MapGeometrySelectorTest {
    @TestSetup
    static void makeData() {
        Map__c map1 = new Map__c();
        insert map1;

        Map_Geometry__c mapgeometry1 = new Map_Geometry__c();
        mapgeometry1.Map__c = map1.Id;

        Map_Geometry__c mapgeometry2 = new Map_Geometry__c();
        mapgeometry2.Map__c = map1.Id;

        insert new List<Map_Geometry__c>{ mapgeometry1, mapgeometry2 };
    }

    @IsTest
    public static void getGeometryRecordsByMapId_hasRecords() {
        List<Map__c> mapList = [SELECT Id FROM Map__c LIMIT 1];

        System.Test.startTest();
        MapGeometrySelector mapGeometrySelector = new MapGeometrySelector();
        List<Map_Geometry__c> mapGeometryRecords = mapGeometrySelector.getGeometryRecordsByMapId(mapList[0].Id);
        System.Test.stopTest();
        System.assertEquals(2, mapGeometryRecords.size(), 'Map Geometry records are not pulled with Map Id');
    }

    @IsTest
    public static void getGeometryRecordsByMapId_hasNoRecords() {
        System.Test.startTest();
        MapGeometrySelector mapGeometrySelector = new MapGeometrySelector();
        List<Map_Geometry__c> mapGeometryRecords = mapGeometrySelector.getGeometryRecordsByMapId(null);
        System.Test.stopTest();
        System.assertEquals(0, mapGeometryRecords.size(), 'Map Geometry records are not pulled with Map Id');
    }
}