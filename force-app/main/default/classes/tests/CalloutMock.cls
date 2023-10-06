/****************************************************************************************
Name            : CalloutMock
Created By      : 2023-07-13 Miles Sollinger - CodeScience
Use             : Implementation of HttpCalloutMock interface allowing for multiple HTTP responses
                : in a single unit test 
*****************************************************************************************/
@isTest
public class CalloutMock implements HttpCalloutMock {
    public CalloutMock(String jsonResponse) {
        this.addResponse(200, jsonResponse);
    }

    public CalloutMock(List<HttpResponse> responses) {
        httpResponses.addAll(responses);
    }

    public CalloutMock(HttpResponse response) {
        this.addResponse(response);
    }

    private List<HttpResponse> httpResponses = new List<HttpResponse>();
    private Integer responseIndex = 0;

    public void addResponse(HttpResponse response) {
        httpResponses.add(response);
    }

    public void addResponse(String body) {
        this.addResponse(200, body);
    }

    public void addResponse(Integer code, String body) {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(body);
        httpResponse.setStatusCode(code);
        httpResponses.add(httpResponse);
    }

    public HTTPResponse respond(HTTPRequest request) {
        return httpResponses[responseIndex++];
    }
}