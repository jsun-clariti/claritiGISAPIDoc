/****************************************************************************************
Name            : ClaritiEsriController
Use             : Controller for claritiEsri component
*****************************************************************************************/
public with sharing class ClaritiEsriController {
    /**
     *  Calls auth API and returns token with TTL
     * @return TokenMsg - Msg class with token and TTL
     */
    @AuraEnabled
    public static ArcGISMsg getArcGISDetails(
        String objectApiName,
        String fieldApiName,
        String recordId,
        String developerName
    ) {
        try {
            ArcGISMsg arcGISDetails = new ArcGISMsg();
            ObjectInfoMsg objectInfo = new ObjectInfoMsg(objectApiName, fieldApiName, recordId);
            arcGISDetails = AdminService.getToken(arcGISDetails);
            arcGISDetails = EsriService.getUrlForVFPage(arcGISDetails);
            arcGISDetails = EsriService.loadMapData(objectInfo, arcGISDetails);
            arcGISDetails = EsriService.getFlowApiName(developerName, arcGISDetails);
            return arcGISDetails;
        } catch (Exception e) {
            throw CSUtils.createAndLogAuraException(ClaritiEsriController.class.getName(), e);
        }
    }

    /**
     *  Calls auth API and returns token with TTL
     * @return TokenMsg - Msg class with token and TTL
     */
    @AuraEnabled
    public static TokenMsg getToken() {
        try {
            return AdminService.getToken();
        } catch (Exception e) {
            throw CSUtils.createAndLogAuraException(ClaritiEsriController.class.getName(), e);
        }
    }

    /**
     * Saves map sketches
     * @param jsonData - JSON payload of sketches
     * @return String - Id of parent Map__c
     */
    @AuraEnabled
    public static String saveMapData(String jsonData, String objectApiName, String fieldApiName, String recordId) {
        try {
            ObjectInfoMsg objectInfo = new ObjectInfoMsg(objectApiName, fieldApiName, recordId);
            List<ArcGISShapeMsg> msgs = ArcGISShapeMsg.parse(jsonData);
            return EsriService.saveMapData(msgs, objectInfo);
        } catch (Exception e) {
            throw CSUtils.createAndLogAuraException(ClaritiEsriController.class.getName(), e);
        }
    }
}