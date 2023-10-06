/****************************************************************************************
Name            : ClaritiEsriControllerTest
Use             : Unit tests for ClaritiEsriController
*****************************************************************************************/
@isTest
private with sharing class ClaritiEsriControllerTest {
    private static final String JSON_WITH_TWO_SHAPES = '[{"spatialReference":{"latestWkid":3857,"wkid":102100},"x":-13184144.129840745,"y":4026558.776550635},{"spatialReference":{"latestWkid":3857,"wkid":102100},"x":-13182481.624475544,"y":4027476.020890056}]';
    private static final String JSON_WITH_ONE_SHAPE = '[{"spatialReference":{"latestWkid":3857,"wkid":102100},"rings":[[[-13162226.236563023,4037554.435476657],[-13161394.983880423,4037554.435476657],[-13161394.983880423,4037076.704049876],[-13162226.236563023,4037076.704049876],[-13162226.236563023,4037554.435476657]]]}]';
    @isTest
    static void testGetApplicationToken() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            TestDataFactory.setupOnlineApplicationSetting();

            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('access_token', 'foo');
            responseMap.put('expires_in', 7200);
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(responseMap)));

            Test.startTest();
            TokenMsg msg = ClaritiEsriController.getToken();
            Test.stopTest();

            System.assertEquals('foo', msg.token, 'Token not set correctly on response msg');
            System.assertEquals(7200000 - Constants.TOKEN_TTL_OFFSET, msg.ttl, 'TTL not set correctly on response msg');
        }
    }

    @isTest
    static void testGetIdentityToken() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            TestDataFactory.setupEnterpriseSetting();

            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('token', 'foo');
            responseMap.put('expires', 1689609704450L);
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(responseMap)));

            Test.startTest();
            TokenMsg msg = ClaritiEsriController.getToken();
            Test.stopTest();

            System.assertEquals('foo', msg.token, 'Token not set correctly on response msg');
            System.assert(msg.ttl != null, 'TTL should be provided on response msg');
        }
    }

    @isTest
    static void testGetTokenFailure() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            TestDataFactory.setupEnterpriseSetting();

            HttpResponse response = new HttpResponse();
            response.setBody('failed');
            response.setStatusCode(400);
            Test.setMock(HttpCalloutMock.class, new CalloutMock(response));

            Boolean exceptionThrown = false;
            Test.startTest();
            try {
                ClaritiEsriController.getToken();
            } catch (Exception e) {
                exceptionThrown = true;
            }
            Test.stopTest();

            System.assert(exceptionThrown, 'Exception should be thrown');
            List<Log__c> logs = [SELECT Id FROM Log__c];
            System.assertEquals(1, logs.size(), 'Log should be created');
        }
    }

    @isTest
    static void testExceptionThrownWhenCustomSettingNotSetup() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            try {
                ClaritiEsriController.getArcGISDetails(null, null, null, null);
            } catch (Exception e) {
                System.assertEquals(
                    System.Label.AdminSettingNotSetup,
                    e.getMessage(),
                    'AdminSetupException should be thrown'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveMapDataWithAccountRecordId() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Test.startTest();
            String mapId = ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, 'Account', 'Industry', acc.Id);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), '1 map should be created');
            System.assertEquals(2, maps[0].Map_Geometries__r.size(), '2 map geometries should be created');
            System.assertEquals(maps[0].Id, mapId, 'Map ID should be returned');

            Account updatedAcc = [SELECT Industry FROM Account WHERE Id = :acc.Id];
            System.assertEquals(maps[0].Id, updatedAcc.Industry, 'Reference to map should be set');
        }
    }

    @isTest
    static void testSaveMapDataWithAccountAndExistingGeometries() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Map__c emptyMap = TestDataFactory.createEmptyMap();
            Map_Geometry__c firstShape = TestDataFactory.createMapGeometry(emptyMap.Id);
            Map_Geometry__c secondShape = TestDataFactory.createMapGeometry(emptyMap.Id);
            insert new List<Map_Geometry__c>{ firstShape, secondShape };
            acc.Industry = emptyMap.Id;
            update acc;

            Test.startTest();
            ClaritiEsriController.saveMapData(JSON_WITH_ONE_SHAPE, 'Account', 'Industry', acc.Id);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), '1 map should exist');
            System.assertEquals(1, maps[0].Map_Geometries__r.size(), '1 map geometry should be returned');
        }
    }

    @isTest
    static void testSaveMapDataWithMapRecordId() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Map__c emptyMap = TestDataFactory.createEmptyMap();

            Test.startTest();
            String mapId = ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, null, null, emptyMap.Id);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), 'Only 1 map should exist');
            System.assertEquals(2, maps[0].Map_Geometries__r.size(), '2 map geometries should be created');
            System.assertEquals(emptyMap.Id, mapId, 'Same Map ID should be returned');
        }
    }

    @isTest
    static void testSaveMapDataWithNoRecordId() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            String mapId = ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, null, null, null);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), '1 map should be created');
            System.assertEquals(2, maps[0].Map_Geometries__r.size(), '2 map geometries should be created');
            System.assertEquals(maps[0].Id, mapId, 'Map ID should be returned');
        }
    }

    @isTest
    static void testSaveMapDataWithEmptyFieldName() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            String mapId = ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, 'Account', null, null);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), '1 map should be created');
            System.assertEquals(2, maps[0].Map_Geometries__r.size(), '2 map geometries should be created');
            System.assertEquals(maps[0].Id, mapId, 'Map ID should be returned');
        }
    }

    @isTest
    static void testSaveMapDataWithIncorrectFieldName() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            String mapId = ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, 'Account', 'Test__c', null);
            Test.stopTest();

            List<Map__c> maps = [SELECT Id, (SELECT Id FROM Map_Geometries__r) FROM Map__c];
            System.assertEquals(1, maps.size(), '1 map should be created');
            System.assertEquals(2, maps[0].Map_Geometries__r.size(), '2 map geometries should be created');
            System.assertEquals(maps[0].Id, mapId, 'Map ID should be returned');
        }
    }

    @isTest
    static void testSaveMapDataError() {
        System.runAs(UserTest.createArcGISReadOnlyUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, 'Account', 'Industry', acc.Id);
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
    static void testLoadMapDataWithAccount() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Map__c emptyMap = TestDataFactory.createEmptyMap();
            Map_Geometry__c shape = TestDataFactory.createMapGeometry(emptyMap.Id);
            insert shape;
            acc.Industry = emptyMap.Id;
            update acc;

            ArcGISMsg arcGISDetails = new ArcGISMsg();
            ObjectInfoMsg objectInfo = new ObjectInfoMsg('Account', 'Industry', acc.Id);

            Test.startTest();
            ArcGISMsg jsonLoad = EsriService.loadMapData(objectInfo, arcGISDetails);
            Test.stopTest();

            System.assertNotEquals(null, jsonLoad.spatialReference, 'JSON string is null.');
        }
    }

    @isTest
    static void testLoadMapDataWithMap() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Map__c emptyMap = TestDataFactory.createEmptyMap();
            Map_Geometry__c shape = TestDataFactory.createMapGeometry(emptyMap.Id);
            insert shape;
            ObjectInfoMsg objectInfo = new ObjectInfoMsg(null, null, emptyMap.Id);

            Test.startTest();
            ArcGISMsg returnedMsg = EsriService.loadMapData(objectInfo, new ArcGISMsg());
            Test.stopTest();

            System.assertNotEquals(null, returnedMsg.spatialReference, 'JSON string is null.');
        }
    }

    @isTest
    static void testLoadMapDataWithEmptyObjectInfo() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            ArcGISMsg returnedMsg = EsriService.loadMapData(new ObjectInfoMsg(null, null, null), new ArcGISMsg());
            Test.stopTest();

            System.assertEquals('[]', returnedMsg.spatialReference, 'Empty array should be returned');
        }
    }

    @isTest
    static void testLoadMapDataWithEmptyFieldName() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Map__c emptyMap = TestDataFactory.createEmptyMap();
            Map_Geometry__c shape = TestDataFactory.createMapGeometry(emptyMap.Id);
            insert shape;
            acc.Industry = emptyMap.Id;
            update acc;

            ArcGISMsg arcGISDetails = new ArcGISMsg();
            ObjectInfoMsg objectInfo = new ObjectInfoMsg('Account', null, acc.Id);

            Test.startTest();
            ArcGISMsg jsonLoad = EsriService.loadMapData(objectInfo, arcGISDetails);
            Test.stopTest();

            System.assertEquals('[]', jsonLoad.spatialReference, 'Empty array should be returned');
        }
    }

    @isTest
    static void testLoadMapDataWithIncorrectFieldName() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Map__c emptyMap = TestDataFactory.createEmptyMap();
            Map_Geometry__c shape = TestDataFactory.createMapGeometry(emptyMap.Id);
            insert shape;
            acc.Industry = emptyMap.Id;
            update acc;

            ArcGISMsg arcGISDetails = new ArcGISMsg();
            ObjectInfoMsg objectInfo = new ObjectInfoMsg('Account', 'Test__c', acc.Id);

            Test.startTest();
            ArcGISMsg jsonLoad = EsriService.loadMapData(objectInfo, arcGISDetails);
            Test.stopTest();

            System.assertEquals('[]', jsonLoad.spatialReference, 'Empty array should be returned');
        }
    }

    @isTest
    static void testLoadMapDataWithAccountAndEmptyFieldApiName() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Test.startTest();
            ArcGISMsg returnedMsg = EsriService.loadMapData(
                new ObjectInfoMsg('Account', null, acc.Id),
                new ArcGISMsg()
            );
            Test.stopTest();

            System.assertEquals('[]', returnedMsg.spatialReference, 'Empty array should be returned');
        }
    }

    @isTest
    static void testLoadMapDataError() {
        System.runAs(UserTest.createArcGISReadOnlyUser()) {
            Account acc = new Account(Name = 'Test account');
            insert acc;
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                ClaritiEsriController.saveMapData(JSON_WITH_TWO_SHAPES, 'Account', 'Industry', acc.Id);
                ArcGISMsg arcGISDetails = new ArcGISMsg();
                ObjectInfoMsg objectInfo = new ObjectInfoMsg('Account', 'Industry', acc.Id);
                ArcGISMsg jsonLoad = EsriService.loadMapData(objectInfo, arcGISDetails);
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
    static void testGetArcGisDetails() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            TestDataFactory.setupEnterpriseSetting();

            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('token', 'foo');
            responseMap.put('expires', 1689609704450L);
            Test.setMock(HttpCalloutMock.class, new CalloutMock(JSON.serialize(responseMap)));

            Account acc = new Account(Name = 'Test account');
            insert acc;

            EsriService.buttonSettingsOverride.add(
                new ArcGIS_Map_Component_Button_Setting__mdt(Flow_API_Name__c = 'testFlow')
            );
            EsriService.configurationOverride = new ArcGIS_Map_Configuration__mdt(
                DeveloperName = 'testMap',
                Label = 'Test map',
                Map_Id__c = '123'
            );

            Test.startTest();
            ArcGISMsg msg = ClaritiEsriController.getArcGISDetails('Account', 'Industry', acc.Id, 'testMap');
            Test.stopTest();

            System.assertEquals('foo', msg.token, 'Token not set correctly on response msg');
            System.assertEquals('test.myarcigs.com', msg.url, 'url should be set');
            System.assertEquals(
                'test.myarcigs.com/arcgis',
                msg.enterprisePortalUrl,
                'enterprisePortalUrl should be set'
            );
            System.assert(msg.orgVfUrl != null, 'orgVfUrl should be set');
            System.assert(msg.vfUrl != null, 'vfUrl should be set');
            System.assert(msg.spatialReference != null, 'spatialReference should be set');
            System.assertEquals('testFlow', msg.flowApiName, 'flowApiName should be set');
            System.assertEquals('123', msg.webMapId, 'webMapId should be set');
        }
    }

    @isTest
    static void testNoExceptionThrownWhenNoMapIdProvided() {
        System.runAs(UserTest.createArcGISCRUDUser()) {
            Test.startTest();
            ArcGISMsg msg = new ArcGISMsg();
            msg = EsriService.getFlowApiName(null, msg);
            Test.stopTest();

            System.assertEquals(null, msg.webMapId, 'webMapId should be null');
            System.assertEquals(null, msg.flowApiName, 'flowApiName should be null');
        }
    }
}