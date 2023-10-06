/****************************************************************************************
Name            : AdminService
Created By      : 2023-07-12 Miles Sollinger - CodeScience
Use             : Service methods for admin setup of ArcGIS Map Integration
*****************************************************************************************/
public with sharing class AdminService {
    /**
     *  Saves msg to custom setting
     * @param msg - Admin-entered data from front end
     */
    public static void saveMapIntegration(ArcGISMapIntegrationMsg msg) {
        ArcGIS_Map_Integration__c updatedSetting = msg.convertToCustomSetting(
            ArcGIS_Map_Integration__c.getOrgDefaults()
        );
        // DML on custom setting ignores CRUDFLS
        Data.upsurt(updatedSetting, false, false, false);
    }

    /**
     *  Performs callout to token endpoint
     * @param msg - Msg representation of ArcGIS_Map_Integration__c custom setting
     */
    public static HttpResponse getTokenResponse(ArcGISMapIntegrationMsg msg) {
        HttpResponse response;
        if (msg.isOnlineApplication) {
            response = ArcGISClient.getApplicationToken(msg.url, msg.clientId, msg.clientSecret);
        } else if (msg.isOnlineUser) {
            response = ArcGISClient.getIdentityToken(msg.url, msg.username, msg.password);
        } else if (msg.isEnterprise) {
            response = ArcGISClient.getEnterpriseIdentityToken(msg.url, msg.username, msg.password);
        } else {
            throw new AdminSetupException(System.Label.AdminSettingNotSetup);
        }

        return response;
    }

    /**
     * Retrieves existing ArcGIS_Map_Integration__c
     * @return ArcGISMapIntegrationMsg
     */
    public static ArcGISMapIntegrationMsg getMapIntegration() {
        return new ArcGISMapIntegrationMsg(ArcGIS_Map_Integration__c.getOrgDefaults());
    }

    /**
     *  Calls auth API and returns token with TTL
     * @return TokenMsg - Msg class with token and TTL
     */
    public static TokenMsg getToken() {
        ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg(ArcGIS_Map_Integration__c.getOrgDefaults());
        HttpResponse tokenResponse = getTokenResponse(msg);
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse.getBody());
        TokenMsg tokenMsg = new TokenMsg();
        tokenmsg.url = msg.url;

        if (msg.isOnlineApplication) {
            tokenMsg.token = (String) responseObject.get('access_token');
            Integer responseTTL = (Integer) responseObject.get('expires_in');
            tokenMsg.ttl = (responseTTL * 1000) - Constants.TOKEN_TTL_OFFSET;
        } else {
            tokenMsg.token = (String) responseObject.get('token');
            Long responseTTL = (Long) responseObject.get('expires');
            DateTime responseDT = DateTime.newInstance(responseTTL);
            Long differenceInMilliseconds = responseDT.getTime() - DateTime.now().getTime();
            Integer intDifferenceWithOffset = differenceInMilliseconds.intValue() - Constants.TOKEN_TTL_OFFSET;
            tokenMsg.ttl = intDifferenceWithOffset;
        }

        return tokenMsg;
    }

    /**
     *  Calls auth API and returns token with TTL
     * @param ArcGISMsg - ArcGISMsg
     * @return ArcGISMsg - Msg class with token and TTL
     */
    public static ArcGISMsg getToken(ArcGISMsg arcGISDetails) {
        ArcGISMapIntegrationMsg msg = new ArcGISMapIntegrationMsg(ArcGIS_Map_Integration__c.getOrgDefaults());
        HttpResponse tokenResponse = getTokenResponse(msg);
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse.getBody());

        if (msg.isOnlineApplication) {
            arcGISDetails.token = (String) responseObject.get('access_token');
            Integer responseTTL = (Integer) responseObject.get('expires_in');
            arcGISDetails.ttl = (responseTTL * 1000) - Constants.TOKEN_TTL_OFFSET;
        } else {
            arcGISDetails.token = (String) responseObject.get('token');
            Long responseTTL = (Long) responseObject.get('expires');
            DateTime responseDT = DateTime.newInstance(responseTTL);
            Long differenceInMilliseconds = responseDT.getTime() - DateTime.now().getTime();
            Integer intDifferenceWithOffset = differenceInMilliseconds.intValue() - Constants.TOKEN_TTL_OFFSET;
            arcGISDetails.ttl = intDifferenceWithOffset;
        }

        arcGISDetails.url = msg.url;
        arcGISDetails.enterprisePortalUrl = msg.enterprisePortalUrl;

        return arcGISDetails;
    }

    public class AdminSetupException extends Exception {
    }
}