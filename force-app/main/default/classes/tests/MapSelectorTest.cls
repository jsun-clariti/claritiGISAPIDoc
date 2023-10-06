@IsTest
public with sharing class MapSelectorTest {
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
        System.runAs(UserTest.createArcGISCRUDUser()) {
            System.Test.startTest();
            MapSelector mapSelector = new MapSelector();
            List<Map__c> mapRecords = mapSelector.getGeometryRecordsByMapId(mapList[0].Id);
            System.Test.stopTest();
            System.assertEquals(
                2,
                mapRecords[0].Map_Geometries__r.size(),
                'Map Geometry records are not pulled with Map Id'
            );
        }
    }

    @IsTest
    public static void getGeometryRecordsByMapId_hasNoRecords() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            System.Test.startTest();
            MapSelector mapSelector = new MapSelector();
            List<Map__c> mapRecords = mapSelector.getGeometryRecordsByMapId(null);
            System.Test.stopTest();
            System.assertEquals(0, mapRecords.size(), 'Map Geometry records are not pulled with Map Id');
        }
    }
}