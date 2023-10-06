/****************************************************************************************
Name            : ArcGisMapConfigurationPicklist
Use             : Exposes ArcGIS_Map_Configuration__mdt records for use in a picklist
                : designer attribute
*****************************************************************************************/
global with sharing class ArcGISMapConfigurationPicklist extends VisualEditor.DynamicPickList {
    @testVisible
    private List<ArcGIS_Map_Configuration__mdt> configurationOverride = new List<ArcGIS_Map_Configuration__mdt>();

    global override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow(null, null);
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        List<ArcGIS_Map_Configuration__mdt> mapConfigurations = Test.isRunningTest()
            ? configurationOverride
            : ArcGIS_Map_Configuration__mdt.getAll().values();
        for (ArcGIS_Map_Configuration__mdt configuration : mapConfigurations) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(configuration.Label, configuration.DeveloperName);
            values.addRow(value);
        }

        return values;
    }
}