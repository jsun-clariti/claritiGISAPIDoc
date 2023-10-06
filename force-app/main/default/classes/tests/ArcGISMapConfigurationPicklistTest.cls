/****************************************************************************************
Name            : ArcGISMapConfigurationPicklistTest
Use             : Unit tests for ArcGISMapConfigurationPicklist
*****************************************************************************************/
@isTest
private with sharing class ArcGISMapConfigurationPicklistTest {
    @isTest
    static void testGetDefaultValue() {
        System.runAs(UserTest.createStandardUser()) {
            Test.startTest();
            VisualEditor.DataRow row = new ArcGISMapConfigurationPicklist().getDefaultValue();
            Test.stopTest();

            System.assertEquals(null, row.getLabel(), 'Default label should be null');
            System.assertEquals(null, row.getValue(), 'Default value should be null');
        }
    }

    @isTest
    static void testGetValues() {
        System.runAs(UserTest.createStandardUser()) {
            ArcGISMapConfigurationPicklist picklist = new ArcGISMapConfigurationPicklist();
            picklist.configurationOverride.add(
                new ArcGIS_Map_Configuration__mdt(DeveloperName = 'LA_Map', Label = 'LA Map', Map_ID__c = '123')
            );

            Test.startTest();
            VisualEditor.DynamicPicklistRows rows = picklist.getValues();
            Test.stopTest();

            System.assertEquals(1, rows.size(), '1 row should be returned');
            VisualEditor.DataRow row = rows.get(0);
            System.assertEquals('LA Map', row.getLabel(), 'Label should be set');
            System.assertEquals('LA_Map', row.getValue(), 'Value should be set');
        }
    }
}