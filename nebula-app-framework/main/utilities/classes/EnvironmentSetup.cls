/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class EnvironmentSetup implements SandboxPostCopy {

    public virtual void runApexClass(SandboxContext context) {
        this.insertOrgDefaultsCustomSettings();
    }

    public void insertOrgDefaultsCustomSettings() {
        insert LoggerSettings__c.getOrgDefaults();
        insert QueryAndSearchSettings__c.getOrgDefaults();
        insert TriggerHandlerSettings__c.getOrgDefaults();
    }

}