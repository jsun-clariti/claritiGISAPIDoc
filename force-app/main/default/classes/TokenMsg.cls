/****************************************************************************************
Name            : TokenMsg
Created By      : 2023-07-14 Miles Sollinger - CodeScience
Use             : Msg class to send token and TTL to front end
*****************************************************************************************/
public with sharing class TokenMsg {
    @AuraEnabled
    public String token { get; set; }
    @AuraEnabled
    public Integer ttl { get; set; }
    @AuraEnabled
    public String url { get; set; }
}