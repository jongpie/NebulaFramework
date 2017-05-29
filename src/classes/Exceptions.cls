/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class Exceptions {

    public class DescribeException extends Exception {}
    public class InvalidOperationException extends Exception {}
    public class RecordTypeException extends Exception {}
    public class SObjectTriggerHandlerException extends Exception {}

}