# hello-dx

![CircleCI](https://circleci.com/gh/CodeScience/hello-dx.svg?style=svg&circle-token=4a464ee69ca07cf45740bff043d8ffa19fb8c722)

Keep any components needed only by Developers that will not be packaged in the `unpackaged` directory. DX scratch orgs will get all of the metadata under `force-app/`, including `force-app/unpackaged`. When it comes time to deploy to the golden packaging org, only metadata from `force-app/main/` will be converted to legacy metadata and deployed.

## dx-utils

All of the scripts in `dx-utils` are meant to be generic, and usable across projects. Utilize the `config/dx-utils.cfg` file to make changes to the following:

-   Name of Unmanaged Package in Salesforce orgs (when using metadata deploy to Int/QA/Packaging orgs)
-   Default Duration of Scratch Orgs
-   Permission Set assignments
-   Managed Packages to install before code push (such as Health Cloud)
-   Creating new users
-   Page to open after a Scratch Org creation command

## Developer Setup

### Install Prettier and Husky pre-commit hook

Run `npm install` to install Husky (for git commit hooks) which will run Prettier on your code when you commit your files to a predetermined CodeScience standard.

**BUGFIX?** If you are experiencing an issue with running Prettier on Apex files, make sure that your JAVA_HOME environment variable is at least running JDK 11 or higher. (Run `java --version` from a command prompt to see your current version.) `prettier-plugin-apex@1.9.0` dropped support for anything below Java 11 ([GitHub Issue](https://github.com/dangmai/prettier-plugin-apex/issues/357)). If you still need Java 8 to be your primary JDK, then change the value in package.json to `"prettier-plugin-apex": "1.8.0"` instead of `"^1.9.0"`, however this might cause some dependencies to be stale or insecure in the future.

### Create Feature Branches With An Org

If you want to follow the pattern of creating a Feature Branch and a fresh Scratch Org with that branch name:

`npm run branch:create BranchName`

Creation commands can have an optional second parameter of scratch org duration. The default is 15 (up from the sfdx default of 7) but you can set this number as high as 30. `npm run branch:create BranchName 30`

This command:

-   creates a new branch and pushes it to origin
-   creates a new scratch org aliased to branch name
-   pushes the dx metadata to scratch org
-   assigns the required permission set to your user
-   opens the app

To delete your feature branch and scratch org with the same name:

`npm run branch:delete BranchName`

This command:

-   deletes branch locally and remotely
-   destroys scratch org
-   switches to default branch

### Create Scratch Org Without Creating A Branch

If you want to just create a new Scratch Org and handle creating Feature Branches on your own (i.e. if you want to just have one scratch org for your entire sprint):

`npm run org:create OrgName`

Creation commands can have an optional second parameter of scratch org duration. The default is 15 (up from the sfdx default of 7) but you can set this number as high as 30. `npm run org:create OrgName 30`

This command:

-   creates a new scratch org aliased to branch name
-   pushes the dx metadata to scratch org
-   assigns the required permission set to your user
-   opens the app

To delete your scratch org:

`npm run org:delete OrgName`

This command:

-   destroys scratch org
-   switches to default branch

## Other Commands

### Switch branch and default scratch org

`./dx-utils/switch_branch.sh <branch-name>`

### Run unit tests

`./dx-utils/run_tests.sh`

### Run predefined anonymous apex scripts

Displays a menu of scripts from `dx-utils/apex-scripts`

`./dx-utils/run_apex.sh`

### Display SFDX Auth url (to store in CircleCI Environment Variables)

`sfdx force:org:display --verbose -u <org_alias>`

### generate package.xml from Managed/Unmanaged Package Container or ChangeSets

`./dx-utils/generatepkgXML.sh <org_alias> <packageName>`

Lets say the package Name is **Codescience** and org alias is **DevOrg** the command `./dx-utils/generatepkgXML.sh DevOrg "Codescience"` generates package.xml in Manifest folder .

## Seeing A New Repo

To seed a new repo, you may use most of what you see here. Be sure to remove the contents of the `force-app` directory as the version of CSUtils may be out of date - use the latest from the CSUtils repo.

## Code Formatting and Linting

If you prefer to have linting on each save, use the following. Linting will occur on commit with the Husky pre-commit hook.

Note: These steps are intended to be used with VSCode. If you use another IDE, please setup prettier and eslint to work with it or switch to VSCode.

-   Install Prettier [VSCode extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
-   Install VSCode [ESLint extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
-   Install [Apex PMD extension](https://marketplace.visualstudio.com/items?itemName=chuckjonas.apex-pmd)
-   In the root directory, run `npm install` to install necessary packages.
-   Add these attributes to your vscode workspace settings (.vscode/settings.json)

```
{
    "apexPMD.rulesets": ["pmd/pmd_rules.xml", "pmd/pmd_rules.CRUDFLS.xml"],
    "editor.codeActionsOnSave": {
        "source.fixAll": true
    },
    "editor.formatOnSaveTimeout": 5000,
    "eslint.format.enable": true,
    "eslint.lintTask.enable": true,
    "prettier.configPath": ".prettierrc",
    "prettier.requireConfig": true
}
```

## Label Service Helper

A utility to facilitate a quicker way of using Custom Labels inside of Lightning Web Components is housed inside this repo.

### VSCode Snippet

To create the XML inside the `CustomLabels.labels-meta.xml` file without having to do a lot of copy/pasting, create a snippet inside Visual Studio Code for the project.

Go to File->Preferences->User Snippets and add a new snippet to your workspace called CustomLabels. Then, populate the generated file with the following:

```json
{
    "Custom Label Blank": {
        "scope": "xml",
        "prefix": "label",
        "body": [
            "<labels>",
            "    <fullName>${4:${1/ /_/g}_${2/ /_/g}}</fullName>",
            "    <categories>$1</categories>",
            "    <language>en_US</language>",
            "    <protected>true</protected>",
            "    <shortDescription>$1: $2</shortDescription>",
            "    <value>$3</value>",
            "</labels>"
        ],
        "description": "Custom Label Blank Snippet"
    },
    "Custom Label Paste": {
        "scope": "xml",
        "prefix": "labelPaste",
        "body": [
            "<labels>",
            "    <fullName>${4:${1/ /_/g}_${2/ /_/g}}</fullName>",
            "    <categories>$1</categories>",
            "    <language>en_US</language>",
            "    <protected>true</protected>",
            "    <shortDescription>$1: ${2:${CLIPBOARD}}</shortDescription>",
            "    <value>${3:${CLIPBOARD}}</value>",
            "</labels>"
        ],
        "description": "Custom Label Paste Snippet"
    }
}
```

Then, while in the Custom Labels file, navigate to an area between labels and start typing the word "label" and both "label" and "labelPaste" will show up. "label" gives you a blank slate, while "labelPaste" will have whatever is in your clipboard be the value of the label, and prepopulate some of the variables with that variable. (Best used for single words or small phrases!)

Highlight "label", and hit TAB. The labels XML element should appear and your cursor will be on the Category field. Fill out the category of this label (Admin, Record Page, etc) and then hit TAB. The cursor will now be at the Short Description portion - fill this out and hit TAB. The cursor will now be on the Value. Fill this out, and hit TAB again. The cursor will jump up to the FullName, which should already be populated based on what you had already.

If you use "labelPaste", both the second part of the Short Description and the Value will be prepopulated with what is in your clipboard buffer, so you just need to fill out the category and hit TAB four times to complete that label.

### Generate LWC Label Service Component

The second part is a node script that reads in the contents of the CustomLabels XML file and generates a Javascript class that can be referenced by your LWC.

First, have your CustomLabels XML file inside its own deployment area off of main instead of default. If you structure your `sfdx-project.json` file correctly, this means that the custom labels will deploy in an earlier transaction than your LWC. SFDX does not like deploying a new Custom Label AND having it imported into an LWC in the same transaction.

Create an LWC called `labelService` (the node script does not generate the meta-xml file) and remove the html file.

Run the script from the project root directory: `npm run labels`

Add command line parameters for input and output:

-   --input (-i) CustomLabels XML File location (default: `force-app/main/labels/labels/CustomLabels.labels-meta.xml`)
-   --output (-o) LabelService LWC JS File location (default: `force-app/main/default/lwc/labelService/labelService.js`)
-   --categorize (-c) Categorize labels inside the LWC object (optional)

Example without Categorize:

```javascript
const labels = {
    AdminAuthenticated,
    AdminUnauthenticated,
    UserName
};
```

Example with Categorize: (`npm run labels -- -c`)

```javascript
const labels = {
    Admin: {
        AdminAuthenticated,
        AdminUnauthenticated
    },
    User: {
        UserName
    }
};
```

### Using labelService in your components

Use the following syntax to expose the labels inside your LWC:

```JavaScript
import labels from 'c/labelService';

export default class MyLWC extends LightningElement {
    label = labels;
}
```

Then, in your HTML file, you can use `{label.AdminAuthenticated}` (or `{label.Admin.AdminAuthenticated}` if you used the categorize option) to reference the custom label. Whenever you change a custom label, just rerun the node script and it will update your labelService and give you instant access to the label inside all of your LWC's.

## Slack

If you do not want slack integration on your build, remove the `slack/notify` nodes in `config.yml`
You can also customize these notifications, see the resources section

The Slack integration posts by default to the `#cs-circlebot-default` channel.
If you want to change the behavior, hardcode the channelId in the `channel:` parameter of the notification node

Example

```
- slack/notify:
    event: pass
    template: basic_success_1
    channel: "<my project's channel>"
    branch_pattern: 'integration,qa,clientqa,main'
```

## Resources

-   Trailhead: [Get Started with Salesforce DX](https://trailhead.salesforce.com/trails/sfdx_get_started)
-   Dev Hub [Trial Org Signup](https://developer.salesforce.com/promotions/orgs/dx-signup)
-   Dev Hub [Link Namespace to a Dev Hub Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_reg_namespace.htm)
-   CircleCI [Slack Integration](https://circleci.com/developer/orbs/orb/circleci/slack)
