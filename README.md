# Nebula Framework for Salesforce Apex
[![Deploy to Salesforce](https://img.shields.io/badge/salesforce-deploy-blue.svg)](https://githubsfdeploy.herokuapp.com)
[![License: MIT](https://img.shields.io/badge/license-MIT-d742f4.svg)](https://opensource.org/licenses/MIT)
[![Travis CI](https://img.shields.io/travis/jongpie/NebulaFramework/master.svg)](https://travis-ci.org/jongpie/NebulaFramework)
[![Code Climate](https://img.shields.io/codeclimate/github/jongpie/NebulaFramework.svg)](https://codeclimate.com/github/jongpie/NebulaFramework)
[![Coveralls](https://img.shields.io/coveralls/jongpie/NebulaFramework/master.svg)](https://coveralls.io/github/jongpie/NebulaFramework)

Nebula is a backend development framework for Salesforce's Apex language. It aims to...
1. Provide a foundation for Apex development, with the flexibility to be easily adapted to meet your implementation needs
2. Promote the design of scalable, bulkified code
3. Standardise how your code is written & organised
4. Overcome some gaps in Apex and the Force.com platform

## Features
Nebula focusses on streamlining how you work with SObjects
1. **SObjectRepository.cls** - this module handles all DML actions & querying needs for an SObject, making the implementation of SObjects much easier & faster
    * **QueryBuilder.cls** powers Nebula's querying, allowing you to dynamically build reusable SOQL & SOSL queries without resorting to building query strings
    * **SObjectRepositoryMock.cls** can be used in unit tests for test-driven development (TDD) & to drastically reduce the time of your unit tests.
2. **SObjectTriggerHandler.cls** - this module provides a trigger framework to handle all trigger contexts provided by Salesforce and provides additional features, like recursion prevention.

The framework also provides several additional classes to make development easier
1. **SObjectRecordTypes.cls** - Record types are an important feature of the Force.com platform. Unfortunately, Apex has limitations with handling them - record types have a field called DeveloperName that (you guessed it!) should be used by developers... but native Apex describe methods cannot access this field. Nebula tries to overcome these shortcomings by providing cacheable query results of record types so you can access all record type details.
2. **Logger.cls** - a flexible logging solution for Apex, leveraged by the framework itself
3. **Environment.cls** - provides information about the current Salesforce environment
4. **UUID.cls** - Used to reate a randomly-generated unique ID in your code, using the Universally Unique Identifier (UUID) standard

## Usage
Nebula uses interfaces, virtual & abstract classes and some Salesforce features (like custom settings) to provide a baseline for your own Apex development. You can deploy the latest version of Nebula to your org and build your implementation on top of it. If you want to customise how Nebula works, most classes & methods can be overridden with your own logic. Ideally, you should minimise any code changes to Nebula's classes so that you can easily upgrade in the future when new versions of Nebula are released.

Nebula also leverages custom settings to give you control over how the framework works within your Salesforce environment. There are 4 settings
1. **Logger Settings (API Name: NebulaLoggerSettings__c)** - Controls the behavior of the class Logger.cls
2. **Record Type Settings (API Name: NebulaRecordTypesSettings__c)** - Controls the behavior of the class SObjectRecordTypes.cls
3. **Repository Seetings (API Name: NebulaRepositorySettings__c)** - Controls the behavior of the class SObjectRepository.cls
4. **Trigger Handler Settings (API Name: NebulaTriggerHandlerSettings__c)** - Controls the behavior of the class SObjectTriggerHandler.cls

## Versioning
We use [Semantic Versioning](http://semver.org/) for versioning, like 'v1.0.2' (MAJOR.MINOR.PATCH):

- MAJOR version when incompatible API changes are made
- MINOR version new functionality is added in a backwards-compatible manner
- PATCH version when backwards-compatible bug fixes are made
