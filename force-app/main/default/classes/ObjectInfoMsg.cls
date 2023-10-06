/****************************************************************************************
Name            : ObjectInfoMsg
Use             : Msg class to get Object Name, Field Name and Record Id
*****************************************************************************************/
public with sharing class ObjectInfoMsg {
    public String objectApiName;
    public String fieldApiName;
    public String recordId;

    public ObjectInfoMsg(String objectApiName, String fieldApiName, String recordId) {
        this.objectApiName = objectApiName;
        this.fieldApiName = fieldApiName;
        this.recordId = recordId;
    }
}