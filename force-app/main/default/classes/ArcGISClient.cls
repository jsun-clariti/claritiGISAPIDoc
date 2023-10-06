/****************************************************************************************
Name            : ArcGISClient
Created By      : 2023-07-12 Miles Sollinger - CodeScience
Use             : Callouts to ArcGIS
*****************************************************************************************/
public with sharing class ArcGISClient {
    private static final String APPLICATION_TOKEN_ENDPOINT = '/oauth2/token';
    private static final String IDENTITY_TOKEN_ENDPOINT = '/generateToken';

    /**
     * Gets token for online application flow
     * @param providedEndpoint - Identity endpoint
     * @param clientId - Application Client ID
     * @param clientSecret - Application Client Secret
     * @return HttpResponse
     */
    public static HttpResponse getApplicationToken(String providedEndpoint, String clientId, String clientSecret) {
        String endpoint = providedEndpoint + APPLICATION_TOKEN_ENDPOINT;

        Map<String, String> requestVals = new Map<String, String>();
        requestVals.put('client_id', clientId);
        requestVals.put('client_secret', clientSecret);
        requestVals.put('grant_type', 'client_credentials');

        HttpResponse response = doCallout(
            endpoint,
            CSUtils.urlEncode(requestVals),
            new Map<String, String>{ 'Content-Type' => 'application/x-www-form-urlencoded' },
            'POST'
        );

        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if (responseObject.containsKey('error')) {
            Map<String, Object> errorObject = (Map<String, Object>) responseObject.get('error');
            throw new AuthException((String) errorObject.get('message'));
        }

        return response;
    }

    /**
     * Gets token for online user flow
     * @param providedEndpoint - Identity endpoint
     * @param username - Username for named user
     * @param password - Password for named user
     * @return HttpResponse
     */
    public static HttpResponse getIdentityToken(String providedEndpoint, String username, String password) {
        HttpResponse response = doIdentityTokenCallout(providedEndpoint, username, password);

        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if (responseObject.containsKey('error')) {
            Map<String, Object> errorObject = (Map<String, Object>) responseObject.get('error');
            List<Object> errorMessages = (List<Object>) errorObject.get('details');
            throw new AuthException((String) errorMessages[0]);
        }

        return response;
    }

    /**
     * Gets token for enterprise
     * @param providedEndpoint - Identity endpoint
     * @param username - Username for named user
     * @param password - Password for named user
     * @return HttpResponse
     */
    public static HttpResponse getEnterpriseIdentityToken(String providedEndpoint, String username, String password) {
        HttpResponse response = doIdentityTokenCallout(providedEndpoint, username, password);

        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if (responseObject.containsKey('error')) {
            Map<String, Object> errorObject = (Map<String, Object>) responseObject.get('error');
            throw new AuthException((String) errorObject.get('details'));
        }

        return response;
    }

    /**
     * Builds request body and performs callout to /generateToken
     * @param providedEndpoint - Identity endpoint
     * @param username - Username for named user
     * @param password - Password for named user
     * @return HttpResponse
     */
    private static HttpResponse doIdentityTokenCallout(String providedEndpoint, String username, String password) {
        String endpoint = providedEndpoint + IDENTITY_TOKEN_ENDPOINT;

        Map<String, String> requestVals = new Map<String, String>();
        requestVals.put('f', 'json');
        requestVals.put('username', username);
        requestVals.put('password', password);
        requestVals.put('referer', providedEndpoint);
        requestVals.put('client', 'referer');

        return doCallout(
            endpoint,
            CSUtils.urlEncode(requestVals),
            new Map<String, String>{ 'Content-Type' => 'application/x-www-form-urlencoded' },
            'POST'
        );
    }

    /**
     * Utility method to make callout
     * @param endpoint - Endpoint to call
     * @param body - Request body
     * @param headers - Request headers
     * @param method - Request method
     * @return HttpResponse
     */
    private static HttpResponse doCallout(String endpoint, String body, Map<String, String> headers, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);

        if (body != null) {
            request.setBody(body);
        }

        if (!headers.isEmpty()) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }

        request.setMethod(method);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() > 200) {
            throw new AuthException(response.getBody());
        }

        return response;
    }

    public class AuthException extends Exception {
    }
}