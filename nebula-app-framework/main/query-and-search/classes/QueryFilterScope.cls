/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description Enum of possible values for SOQL's optional USING SCOPE
* Salesforce docs: developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm
*
*/
public enum QueryFilterScope { EVERYTHING, DELEGATED, TEAM, MINE, MY_TERRITORY, MY_TEAM_TERRITORY }