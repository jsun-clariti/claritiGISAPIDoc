/****************************************************************************************
Name            : EsriService
Created By      : 2023-07-20 Alagu Chellappa - CodeScience
Use             : Service methods for Esri Component of ArcGIS Map Integration
*****************************************************************************************/
public with sharing class EsriService {
    @testVisible
    private static List<ArcGIS_Map_Component_Button_Setting__mdt> buttonSettingsOverride = new List<ArcGIS_Map_Component_Button_Setting__mdt>();
    @testVisible
    private static ArcGIS_Map_Configuration__mdt configurationOverride;
    /**
     *  Get Community URL or base URL to append with VF Page
     */
    public static ArcGISMsg getUrlForVFPage(ArcGISMsg arcGISDetails) {
        String vfPage = CSUtils.getNamespaceWithUnderscores() + 'esriMapPage';
        String baseURL;
        String currentSiteUrl = Site.getBaseUrl();
        if (!String.isEmpty(currentSiteUrl)) {
            baseURL = currentSiteUrl + '/apex/' + vfPage + '?isdtp=mn';
        } else {
            baseURL = '/apex/' + vfPage;
        }

        arcGISDetails.vfUrl = baseURL;
        arcGISDetails.orgVfUrl = 'https://' + DomainCreator.getVisualforceHostname(null);

        String siteDomain = Site.getDomain();
        if (!String.isBlank(siteDomain)) {
            arcGISDetails.siteDomain = 'https://' + siteDomain;
        }

        return arcGISDetails;
    }

    /**
     * Saves map sketches. This method handles multiple scenarios:
     * 1. objectInfo.recordId is empty
     * 2. objectInfo.recordId is a Map__c ID
     * 3a. objectInfo.recordId is an SObject ID and the reference to the SObject is provided
     * 3b. objecetInfo.recordId is an SObject ID and the reference to the SObject is not provided
     * @param msgs - JSON payload of sketches
     */
    public static String saveMapData(List<ArcGISShapeMsg> msgs, ObjectInfoMsg objectInfo) {
        String mapObjectId;
        if (String.isEmpty(objectInfo.recordId)) {
            mapObjectId = createMapRecord();
        } else if (isMapId(objectInfo.recordId)) {
            mapObjectId = objectInfo.recordId;
            removeExistingGeometries(mapObjectId);
        } else if (!isMapId(objectInfo.recordId)) {
            mapObjectId = retrieveMapIdFromChildObject(objectInfo);
            if (String.isEmpty(mapObjectId)) {
                mapObjectId = createMapRecord();
                if (
                    !String.isBlank(objectInfo.fieldApiName) &&
                    CSUtils.isFieldAvailable(objectInfo.objectApiName, objectInfo.fieldApiName)
                ) {
                    updateChildObjectWithMapId(objectInfo, mapObjectId);
                }
            } else {
                removeExistingGeometries(mapObjectId);
            }
        }
        List<Map_Geometry__c> geometries = new List<Map_Geometry__c>();
        for (ArcGISShapeMsg msg : msgs) {
            Map_Geometry__c childGeometry = new Map_Geometry__c(
                Map__c = mapObjectId,
                Type__c = Constants.GEOMETRY_TYPE_JSON,
                Data__c = JSON.serialize(msg)
            );
            geometries.add(childGeometry);
        }

        if (!geometries.isEmpty()) {
            Data.create(geometries);
        }
        return mapObjectId;
    }

    private static Id createMapRecord() {
        Map__c parentMap = new Map__c();
        Data.create(parentMap);
        return parentMap.Id;
    }

    private static void removeExistingGeometries(String mapObjectId) {
        List<Map_Geometry__c> geometries = new MapGeometrySelector().getGeometryRecordsByMapId(mapObjectId);
        Data.remove(geometries);
    }

    /**
     * Load map sketches. This method handles multiple scenarios:
     * 1. objectInfo.recordId is blank
     * 2. objectInfo.recordId is a Map__c ID
     * 3. objectInfo.recordId is an SObject ID
     * @param recordId, fieldName, objectApiName
     */
    public static ArcGISMsg loadMapData(ObjectInfoMsg objectInfo, ArcGISMsg arcGISDetails) {
        MapSelector mapSelector = new MapSelector();
        List<String> dataList = new List<String>();
        // if recordId exists, then the MapId will be retrieved from corresponding record,
        // otherwise, it will be spaces
        String mapObjectId = '';
        Boolean checkRecordIdExists = String.isBlank(objectInfo.recordId);
        if (!checkRecordIdExists && isMapId(objectInfo.recordId)) {
            mapObjectId = objectInfo.recordId;
        } else if (!checkRecordIdExists) {
            mapObjectId = retrieveMapIdFromChildObject(objectInfo);
        }

        if (String.isBlank(mapObjectId)) {
            arcGISDetails.spatialReference = JSON.serialize(dataList);
            return arcGISDetails;
        }

        List<Map__c> mapList = mapSelector.getGeometryRecordsByMapId(mapObjectId);
        for (Map_Geometry__c mg : mapList[0].Map_Geometries__r) {
            dataList.add(mg.Data__c);
        }
        arcGISDetails.spatialReference = JSON.serialize(dataList);
        return arcGISDetails;
    }

    private static String retrieveMapIdFromChildObject(ObjectInfoMsg objectInfo) {
        Boolean isFieldAvailable = CSUtils.isFieldAvailable(objectInfo.objectApiName, objectInfo.fieldApiName);
        if (String.isBlank(objectInfo.fieldApiName) || !isFieldAvailable) {
            return null;
        }
        MapSelector mapSelector = new MapSelector();
        List<Sobject> sobjectList = mapSelector.getMapObjectIdByRecordId(objectInfo);
        if (sobjectList.isEmpty()) {
            return null;
        }
        return String.valueof(sobjectList[0].get(objectInfo.fieldApiName));
    }

    private static void updateChildObjectWithMapId(ObjectInfoMsg objectInfo, String mapId) {
        // Get the Type instance of the object
        Type objectType = Type.forName(objectInfo.objectApiName);

        // Check if the type is valid and not null
        if (objectType != null) {
            // Create an instance of the object dynamically
            SObject objInstance = (SObject) objectType.newInstance();
            // Cast the instance to the appropriate SObject type (e.g., Account, Custom_Object__c, etc.)

            // Now you can work with the object instance
            objInstance.put('Id', objectInfo.recordId);
            objInstance.put(objectInfo.fieldApiName, mapId);
            Data.upsurt(objInstance);
        }
    }

    private static Boolean isMapId(String objectId) {
        return Id.valueOf(objectId).getSobjectType() == Schema.Map__c.sObjectType;
    }

    /**
     * Given a DeveloperName of a ArcGIS_Map_Configuration__mdt, fetches the Map_Id__c on that configuration record
     * as well as the Flow_API_Name__c on the child ArcGIS_Map_Component_Button_Setting__mdt
     */
    public static ArcGISMsg getFlowApiName(String developerName, ArcGISMsg arcGISDetails) {
        if (String.isEmpty(developerName)) {
            return arcGISDetails;
        }

        ArcGIS_Map_Configuration__mdt mapConfig = Test.isRunningTest()
            ? configurationOverride
            : ArcGIS_Map_Configuration__mdt.getInstance(developerName);
        arcGISDetails.webMapId = mapConfig?.Map_Id__c;

        String query = 'SELECT Flow_API_Name__c FROM ArcGIS_Map_Component_Button_Setting__mdt WHERE Related_ArcGIS_Map__r.DeveloperName =: developerName';
        // Query on custom metadata ignores CRUDFLS
        List<ArcGIS_Map_Component_Button_Setting__mdt> buttonSettings = Test.isRunningTest()
            ? buttonSettingsOverride
            : (List<ArcGIS_Map_Component_Button_Setting__mdt>) Data.read(
                  query,
                  new Map<String, Object>{ 'developerName' => developerName },
                  false,
                  false,
                  false
              );

        if (!buttonSettings.isEmpty()) {
            arcGISDetails.flowApiName = buttonSettings[0].Flow_API_Name__c;
        }

        return arcGISDetails;
    }
}