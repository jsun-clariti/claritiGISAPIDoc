public with sharing class MapGeometrySelector extends Selector {
    public MapGeometrySelector() {
        super(Schema.Map_Geometry__c.SObjectType);
    }

    public MapGeometrySelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.Map_Geometry__c.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{ 'Id' };
    }

    /**
     * Gets all the Geometry records based on the Map Id
     * @return Map Geometry records
     */
    public List<Map_Geometry__c> getGeometryRecordsByMapId(string mapId) {
        Set<String> fields = this.getDefaultFields();
        List<String> queryFields = new List<String>(fields);

        Map<String, Object> queryArgs = new Map<String, Object>{ 'mapId' => mapId };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM Map_Geometry__c' +
            ' WHERE ' +
            ' Map__c = :mapId';

        return new List<Map_Geometry__c>(
            (List<Map_Geometry__c>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}