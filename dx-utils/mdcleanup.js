//Metadata cleanup to deploy to Enterprise Edition Salesforce environments
const fs = require('fs').promises;

//Replaces Protected custom settings attribute with Public
const protectedObjNames = ['DebugSettings__c', 'ArcGIS_Map_Integration__c'];

(async () => {
    for (let objPath of protectedObjNames) {
        let fullPath = `./deploy/objects/${objPath}.object`;
        let file = await fs.readFile(fullPath, 'utf8');
        let updatedFile = file.replace('<visibility>Protected</visibility>', '<visibility>Public</visibility>');
        fs.writeFile(fullPath, updatedFile, { encoding: 'utf8' });
    }
})();

