ArcGIS_Map_Integration__c integrationSetting = ArcGIS_Map_Integration__c.getOrgDefaults();
integrationSetting.ArcGIS_Type__c = Constants.ARCGIS_TYPE_ONLINE;
integrationSetting.Connection_Type__c = Constants.CONNECTION_TYPE_APPLICATION;
integrationSetting.Client_Id__c = 'REBhOcPO77z5XMKF';
integrationSetting.Client_Secret__c = '20eb03f2cc6e4ec88d2b0eef92ab29d1';
integrationSetting.URL__c = 'https://bgsi.maps.arcgis.com/sharing/rest';
upsert integrationSetting;

Account a = new Account(Name = 'test');
insert a;
System.debug('Created account ID ' + a.Id);