#!/usr/local/bin/node

/* eslint-env es6 */

//##########################################################################
/* This script is used to assign a post install class to First-Generation Managed Packages
To use, assign_post_install_class.js FOOClass
https://help.salesforce.com/articleView?id=apex_post_install_script_specify.htm&type=5
*/
//##########################################################################
var fs = require("fs");

let params = process.argv.slice(2);

if(Array.isArray(params) && params.length > 0){
    const className = params[0];
    let xmlData = fs.readFileSync('deploy/package.xml', 'utf8').replace('</Package>', `    <postInstallClass>${className}</postInstallClass>\n</Package>`);

    fs.writeFile("deploy/package.xml", xmlData, function(err, data) {
        if (err){
            console.log(err);
            process.exit(1);
        } else{
            console.log(`Updated package.xml file to include <postInstallClass>${className}</postInstallClass>`);
        }
    });
}
