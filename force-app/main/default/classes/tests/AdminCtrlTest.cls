/****************************************************************************************
Name            : AdminCtrlTest
Created By      : 2023-07-13 Miles Sollinger - CodeScience
Use             : Unit tests for AdminCtrl
*****************************************************************************************/
@isTest
private with sharing class AdminCtrlTest {
    @isTest
    static void testGetMapIntegration() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGIS_Map_Integration__c setting = ArcGIS_Map_Integration__c.getOrgDefaults();
            setting.ArcGIS_Type__c = 'online';
            setting.Connection_Type__c = 'application';
            setting.Client_Id__c = '1';
            setting.Client_Secret__c = '2';
            setting.Username__c = 'test.user';
            setting.Password__c = 'pass';
            setting.URL__c = 'www.arcgis.com';
            setting.Enterprise_Portal_URL__c = 'www.arcgis.com/portal';
            upsert setting;

            Test.startTest();
            ArcGISMapIntegrationMsg msg = AdminCtrl.getMapIntegration();
            Test.stopTest();

            System.assertEquals('online', msg.arcGISType, 'Value not set correctly on msg');
            System.assertEquals('application', msg.connectionType, 'Value not set correctly on msg');
            System.assertEquals('1', msg.clientId, 'Value not set correctly on msg');
            System.assertEquals('2', msg.clientSecret, 'Value not set correctly on msg');
            System.assertEquals('test.user', msg.username, 'Value not set correctly on msg');
            System.assertEquals('pass', msg.password, 'Value not set correctly on msg');
            System.assertEquals('www.arcgis.com', msg.url, 'Value not set correctly on msg');
            System.assertEquals('www.arcgis.com/portal', msg.enterprisePortalUrl, 'Value not set correctly on msg');
        }
    }

    @isTest
    static void testSetMapIntegrationWithOnlineApplication() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'online';
            msg.connectionType = 'application';
            msg.clientId = '1';
            msg.clientSecret = '2';
            msg.url = 'testcompany.arcgis.com';

            Map<String, Object> response = new Map<String, Object>{ 'access_token' => 'abc' };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(response)));

            Test.startTest();
            AdminCtrl.saveMapIntegration(msg);
            Test.stopTest();

            ArcGIS_Map_Integration__c setting = ArcGIS_Map_Integration__c.getOrgDefaults();
            System.assertEquals('online', setting.ArcGIS_Type__c, 'Value not set correctly on custom setting');
            System.assertEquals('application', setting.Connection_Type__c, 'Value not set correctly on custom setting');
            System.assertEquals('1', setting.Client_Id__c, 'Value not set correctly on custom setting');
            System.assertEquals('2', setting.Client_Secret__c, 'Value not set correctly on custom setting');
            System.assertEquals('testcompany.arcgis.com', setting.URL__c, 'Value not set correctly on custom setting');
        }
    }

    @isTest
    static void testSetMapIntegrationWithOnlineApplicationErrorResponse() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'online';
            msg.connectionType = 'application';
            msg.clientId = '1';
            msg.clientSecret = '2';
            msg.url = 'testcompany.arcgis.com';

            Map<String, Object> errorObject = new Map<String, Object>();
            errorObject.put('message', 'Invalid input');
            Map<String, Object> responseObject = new Map<String, Object>{ 'error' => errorObject };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(responseObject)));

            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                AdminCtrl.saveMapIntegration(msg);
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'Exception should be thrown if response contains error property');
            List<Log__c> logs = [SELECT Id FROM Log__c WHERE Level__c = 'ERROR'];
            System.assertEquals(1, logs.size(), 'Log should be created');
        }
    }

    @isTest
    static void testSetMapIntegrationWithOnlineUser() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'online';
            msg.connectionType = 'user';
            msg.username = 'test.user';
            msg.password = 'pass';
            msg.url = 'testcompany.arcgis.com';

            Map<String, Object> response = new Map<String, Object>{ 'access_token' => 'abc' };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(response)));

            Test.startTest();
            AdminCtrl.saveMapIntegration(msg);
            Test.stopTest();

            ArcGIS_Map_Integration__c setting = ArcGIS_Map_Integration__c.getOrgDefaults();
            System.assertEquals('online', setting.ArcGIS_Type__c, 'Value not set correctly on custom setting');
            System.assertEquals('user', setting.Connection_Type__c, 'Value not set correctly on custom setting');
            System.assertEquals('test.user', setting.Username__c, 'Value not set correctly on custom setting');
            System.assertEquals('pass', setting.Password__c, 'Value not set correctly on custom setting');
            System.assertEquals('testcompany.arcgis.com', setting.URL__c, 'Value not set correctly on custom setting');
        }
    }

    @isTest
    static void testSetMapIntegrationWithOnlineUserErrorResponse() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'online';
            msg.connectionType = 'user';
            msg.username = 'test.user';
            msg.password = 'pass';
            msg.url = 'testcompany.arcgis.com';

            Map<String, Object> errorObject = new Map<String, Object>();
            errorObject.put('details', new List<String>{ 'Invalid username' });
            Map<String, Object> responseObject = new Map<String, Object>{ 'error' => errorObject };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(responseObject)));

            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                AdminCtrl.saveMapIntegration(msg);
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'Exception should be thrown if response contains error property');
            List<Log__c> logs = [SELECT Id FROM Log__c WHERE Level__c = 'ERROR'];
            System.assertEquals(1, logs.size(), 'Log should be created');
        }
    }

    @isTest
    static void testSetMapIntegrationEnterprise() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'enterprise';
            msg.username = 'test.user';
            msg.password = 'pass';
            msg.url = 'testcompany.argcis.com';
            msg.enterprisePortalUrl = 'testcompany.arcgis.com/portal';

            Map<String, Object> response = new Map<String, Object>{ 'access_token' => 'abc' };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(response)));

            Test.startTest();
            AdminCtrl.saveMapIntegration(msg);
            Test.stopTest();

            ArcGIS_Map_Integration__c setting = ArcGIS_Map_Integration__c.getOrgDefaults();
            System.assertEquals('enterprise', setting.ArcGIS_Type__c, 'Value not set correctly on custom setting');
            System.assertEquals('test.user', setting.Username__c, 'Value not set correctly on custom setting');
            System.assertEquals('pass', setting.Password__c, 'Value not set correctly on custom setting');
            System.assertEquals('testcompany.argcis.com', setting.URL__c, 'Value not set correctly on custom setting');
            System.assertEquals(
                'testcompany.arcgis.com/portal',
                setting.Enterprise_Portal_URL__c,
                'Value not set correctly on custom setting'
            );
        }
    }

    @isTest
    static void testSetMapIntegrationEnterpriseErrorResponse() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'enterprise';
            msg.username = 'test.user';
            msg.password = 'pass';
            msg.url = 'testcompany.argcis.com';
            msg.enterprisePortalUrl = 'testcompany.arcgis.com/portal';

            Map<String, Object> errorResponse = new Map<String, Object>{ 'details' => 'Invalid credentials' };
            Map<String, Object> response = new Map<String, Object>{ 'error' => errorResponse };
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(response)));

            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                AdminCtrl.saveMapIntegration(msg);
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'Exception should be thrown');
            List<Log__c> logs = [SELECT Id FROM Log__c WHERE Level__c = 'ERROR'];
            System.assertEquals(1, logs.size(), 'Log should be created');
        }
    }

    @isTest
    static void testSetMapIntegrationFailure() {
        System.runAs(UserTest.createAdminUser()) {
            ArcGIS_Map_Integration__c setting = ArcGIS_Map_Integration__c.getOrgDefaults();
            setting.ArcGIS_Type__c = 'online';
            upsert setting;

            ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg();
            msg.arcGISType = 'enterprise';
            msg.username = 'test.user';
            msg.password = 'pass';
            msg.url = 'testcompany.argcis.com';
            msg.enterprisePortalUrl = 'testcompany.arcgis.com/portal';

            HttpResponse errorResponse = new HttpResponse();
            errorResponse.setBody('failed');
            errorResponse.setStatusCode(400);

            Test.setMock(HttpCalloutMock.class, new CalloutMock(errorResponse));

            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                AdminCtrl.saveMapIntegration(msg);
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'Exception should be thrown');
            List<Log__c> logs = [SELECT Id FROM Log__c WHERE Level__c = 'ERROR'];
            System.assertEquals(1, logs.size(), 'Log should be created');
        }
    }
}