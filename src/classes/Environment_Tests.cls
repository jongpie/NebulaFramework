/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class Environment_Tests {

    @isTest
    static void getBaseUrl() {
        System.assert(Environment.BaseUrl.endsWithIgnoreCase('.salesforce.com'));
    }

    @isTest
    static void getInstanceName() {
        Organization org = [SELECT Id, InstanceName FROM Organization];
        System.assertEquals(org.InstanceName, Environment.InstanceName);
    }

    @isTest
    static void getIsSandbox() {
        Organization org = [SELECT Id, IsSandbox FROM Organization];
        System.assertEquals(org.IsSandbox, Environment.IsSandbox);
    }

    @isTest
    static void getName() {
        Organization org = [SELECT Id, Name FROM Organization];
        System.assertEquals(org.Name, Environment.Name);
    }

    @isTest
    static void getType() {
        Organization org = [SELECT Id, OrganizationType FROM Organization];
        System.assertEquals(org.OrganizationType, Environment.Type);
    }

}