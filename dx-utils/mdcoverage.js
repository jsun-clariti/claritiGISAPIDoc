/**
 * Usage:
 *   `$ npm run mdcoverage`
 *   `$ npm run mdcoverage -- -p ./path/to/package.xml -o ./path/to/output`
 * 
 * This script scans a deployment folder (old style metadata) for components
 * that cannot be added to a managed, unmanaged, or 2nd gen package and
 * lists them out in JSON format, as a table in your console, and optionally
 * in a table file.
 * 
 * To get a dx project into metadata format, run:
 * `$ sfdx force:source:convert -r force-app/main -d ./path/to/output`
 * 
 * @author Pat Meeker
 * @author Mark Pond
 * @author Nathan Phillips
 */
/* eslint-env node */

const axios = require('axios');
const fs = require('fs');
const path = require('path');
const parser = require('xml-js');
const commander = require('commander');
const objectPath = require('object-path');
const chalk = require('chalk');
const { table } = require('table');
const stripAnsi = require('strip-ansi');

// Command line argument processing
commander
    .option('-p, --package <pkg>', 'Path to your package.xml metadata file.')
    .option('-o, --output <out>', 'Path to the results file.')
    .option('-t, --table <table>', 'Path to the table file.');
commander.parse();
const options = commander.opts();

// Defaults
const packagePath = (
    options.package ? 
    options.package : 
    './deploy/package.xml'
);
const outputPath = (
    options.output ?
    options.output :
    'unpackageable-components.json'
);
const coverageEndpoint = 'https://mdcoverage.secure.force.com/services/apexrest/report';

// parse the package.xml
fs.readFile(packagePath, function (err, data) {

    if (err) {
        console.error(`Package.xml file at path ${packagePath} could not be read.`);
        process.exit(1);
    }

	const packageAsJSON = JSON.parse(parser.xml2json(data, {
        compact: true, 
        spaces: 4
    }));
    // if there is only one type, xml2json will interpret it as an object, not an array
    // so we need to wrap it in an array if so
    if (!Array.isArray(packageAsJSON.Package.types)) {
        packageAsJSON.Package.types = [packageAsJSON.Package.types];
    }

	// get the API version from package.xml
    // if missing, endpoint defaults to newest API version
	const apiVersion = (
        objectPath.has(packageAsJSON, 'Package.version._text') ?
        Math.floor(packageAsJSON.Package.version._text) :
        ''
    );
    const endpoint = coverageEndpoint + (apiVersion ? `?version=${apiVersion}` : '');
    
	// get the coverage list for this API version
	axios.get(endpoint).then((response) => {

		// find all types in package.xml which are not covered in managed packaging (from coverage list)
        const typeList = packageAsJSON.Package.types;
		const resultsJSON = { 
            version: apiVersion || response.data.versions.selected, 
            components: [] 
        };

		// for each type in package.xml...
		for (const typeValue in typeList) {
            if (
                Object.prototype.hasOwnProperty.call(typeList, typeValue)
                // objectPath.has(packageAsJSON, `Package.types.${typeValue}.name._text`)
            ) {
                // get the name
                // console.log(typeList);
                // console.log(packageAsJSON.Package.types[typeValue])
                const typeName = packageAsJSON.Package.types[typeValue].name._text;

                // find the corresponding type in the coverage list
                const coverageType = response.data.types[typeName];

                // check if type is covered for managed packaging
                if (
                    coverageType &&
                    (!coverageType.channels.classicManagedPackaging ||
                        !coverageType.channels.classicUnmanagedPackaging ||
                        !coverageType.channels.managedPackaging)
                ) {
                    resultsJSON.components.push({
                        type: typeName,
                        classicManagedPackaging: coverageType.channels.classicManagedPackaging,
                        classicUnmanagedPackaging: coverageType.channels.classicUnmanagedPackaging,
                        secondGenPackaging: coverageType.channels.managedPackaging
                    });
                }

            }
		}

        // output into console
        logTable(resultsJSON);
		
        // Pretty-print a JSON file to the specified output path
		fs.writeFile(outputPath, JSON.stringify(resultsJSON, null, 4), (writeErr) => {
			if (writeErr) throw writeErr;
			console.log(`\rView your results at ${chalk.blue(path.resolve(outputPath))}`);
		});
	});
});

/**
 * Consume the pre-JSON object containing type results,
 * and log it to the console in a user-friendly table format.
 * 
 * @param {Object} results 
 */
function logTable(results) {
    // headers
    const data = [
        [
            chalk.blue(`Type (Version ${results.version})`),
            chalk.blue('Managed'),
            chalk.blue('Unmanaged'),
            chalk.blue('Second Gen')
        ]
    ];

    // body
    results.components.forEach((item) => {
        data.push([
            item.type,
            formatBoolean(item.classicManagedPackaging),
            formatBoolean(item.classicUnmanagedPackaging),
            formatBoolean(item.secondGenPackaging)
        ]);
    });

    const output = (
        results.components.length ?
        table(data) :
        'All components are packageable!'
    );
    console.log(output);

    // optionally write the table out to a file instead of just the console
    // primarily used for CI purposes
    if (options.table) {
        fs.writeFile(options.table, stripAnsi(output), (writeErr) => {
            if (writeErr) throw writeErr;
        });
    }

}

/**
 * Display a boolean as a green checkmark
 * or a red x.
 * 
 * @param {Boolean} v 
 * @returns A color-formatted unicode string.
 */
function formatBoolean (v) {
    return (
        v ?
        chalk.green('\u2713') :
        chalk.red('\u2717')
    );
}