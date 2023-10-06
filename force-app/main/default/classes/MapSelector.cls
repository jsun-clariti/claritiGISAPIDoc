public with sharing class MapSelector extends Selector {
    public MapSelector() {
        super(Schema.Map__c.SObjectType);
    }

    public MapSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.Map__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id' };
    }

    /**
     * Gets Map and related Child Geometry records based on Map Id
     * @return Map records and related child records
     */
    public List<Map__c> getGeometryRecordsByMapId(string mapId) {
        Set<String> fields = this.getDefaultFields();
        List<String> queryFields = new List<String>(fields);
        String geoMetrySubQuery = ', (Select Data__c from Map_Geometries__r) ';

        Map<String, Object> queryArgs = new Map<String, Object>{ 'mapId' => mapId };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            geoMetrySubQuery +
            ' FROM Map__c' +
            ' WHERE ' +
            ' Id = :mapId';

        return new List<Map__c>(
            (List<Map__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }

    /**
     * Gets MapObjectId from the recordId and field Name relation
     * @return Stationary Asset Sources
     */
    public List<SObject> getMapObjectIdByRecordId(ObjectInfoMsg objectInfo) {
        List<String> queryFields = new List<String>{ 'Id', objectInfo.fieldApiName };

        Map<String, Object> queryArgs = new Map<String, Object>{ 'recordId' => objectInfo.recordId };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM ' +
            objectInfo.objectApiName +
            ' WHERE ' +
            ' Id = :recordId';

        return new List<Sobject>(
            (List<Sobject>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}