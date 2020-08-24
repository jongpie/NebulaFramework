/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Record Types
*
* @description TODO
*
*/
public interface ISObjectRecordTypes {

    // Setup methods
    Schema.SObjectType getSObjectType();

    // Getter methods
    Map<Id, RecordType> getAllById();
    Map<String, RecordType> getAllByDeveloperName();

}