/****************************************************************************************
Name            : AdminCtrl
Created By      : 2023-07-13 Miles Sollinger - CodeScience
Use             : Controller for claritiAdmin component
*****************************************************************************************/
public with sharing class AdminCtrl {
    /**
     * Performs callout to token endpoint and saves msg to custom setting
     * @param msg - Admin-entered data from front end
     */
    @AuraEnabled
    public static void saveMapIntegration(ArcGISMapIntegrationMsg msg) {
        try {
            AdminService.getTokenResponse(msg);
            AdminService.saveMapIntegration(msg);
        } catch (Exception e) {
            throw CSUtils.createAndLogAuraException(AdminCtrl.class.getName(), e);
        }
    }

    /**
     * Retrieves existing ArcGIS_Map_Integration__c
     * @return ArcGISMapIntegrationMsg
     */
    @AuraEnabled
    public static ArcGISMapIntegrationMsg getMapIntegration() {
        try {
            return AdminService.getMapIntegration();
        } catch (Exception e) {
            throw CSUtils.createAndLogAuraException(AdminCtrl.class.getName(), e);
        }
    }
}