/****************************************************************************************
Name            : ArcGISShapeMsg
Use             : Msg class to handle JSON payload of ArcGIS sketches
*****************************************************************************************/
public with sharing class ArcGISShapeMsg {
    public SpatialReference spatialReference;
    public List<List<List<Double>>> rings;
    public Double x;
    public Double y;
    public List<List<List<Double>>> paths;

    public class SpatialReference {
        public Integer latestWkid;
        public Integer wkid;
    }

    public static List<ArcGISShapeMsg> parse(String json) {
        return (List<ArcGISShapeMsg>) System.JSON.deserialize(json, List<ArcGISShapeMsg>.class);
    }
}