/****************************************************************************************
Name            : EsriMapPageCtrl
Use             : Controller for esriMapPage VF page
*****************************************************************************************/
public with sharing class EsriMapPageCtrl {
    public String lexOrigin {
        get {
            String currentSiteUrl = Site.getBaseCustomUrl();
            return String.isEmpty(currentSiteUrl) ? 'https://' + DomainCreator.getLightningHostname() : currentSiteUrl;
        }
        set;
    }
    public String vfOrigin {
        get {
            String currentSiteUrl = Site.getBaseCustomUrl();
            return String.isEmpty(currentSiteUrl)
                ? 'https://' + DomainCreator.getVisualforceHostname(null)
                : currentSiteUrl;
        }
        set;
    }
    public String siteDomain {
        get {
            String baseUrl = Site.getDomain();
            return String.isEmpty(baseUrl) ? null : 'https://' + baseUrl;
        }
    }
}