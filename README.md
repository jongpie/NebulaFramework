# Nebula Framework for Salesforce Apex
[![Travis CI](https://travis-ci.org/jongpie/NebulaFramework.svg?branch=master)](https://travis-ci.org/jongpie/NebulaFramework)
[![Code Climate](https://codeclimate.com/github/jongpie/NebulaFramework.png)](https://codeclimate.com/github/jongpie/NebulaFramework)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Nebula is a backend development framework for Salesforce's Apex language. It aims to...
1. Provide a foundation for Apex development, with the flexibility to be easily adapted to meet your implementation needs
2. Promote the design of scalable, bulkified code
3. Standardise how your code is written & organised
4. Overcome some gaps in Apex and the Force.com platform

<a href="https://githubsfdeploy.herokuapp.com?owner=jongpie&repo=NebulaFramework">
     <img alt="Deploy to Salesforce"src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Features
Nebula focusses on streamlining how you work with SObjects
1. **SObjectRepository.cls** - this module handles all DML actions & querying needs for an SObject, making the implementation of SObjects much easier & faster
    * **QueryBuilder.cls** powers Nebula's querying, allowing you to dynamically build reusable SOQL & SOSL queries without resorting to building query strings
    * **SObjectRepositoryMock.cls** can be used in unit tests for test-driven development (TDD) & to drastically reduce the time of your unit tests.
2. **SObjectTriggerHandler.cls** - this module provides a trigger framework to handle all trigger contexts provided by Salesforce and provides additional features, like recursion prevention.

The framework also provides several additional classes to make development easier
1. **SObjectRecordTypes.cls** - Record types are an important feature of the Force.com platform. Unfortunately, Apex has limitations with handling them - record types have a field called DeveloperName that (you guessed it!) should be used by developers... but native Apex describe methods cannot access this field. Nebula tries to overcome these shortcomings by providing cacheable query results of record types so you can access all record type details.
2. **Logger.cls** - a flexible logging solution for Apex, leveraged by the framework itself
3. **Environment.cls** - provides critical (although missing from Apex-proper) information about the current Salesforce environment
4. **UUID.cls** - Used to reate a randomly-generated unique ID in your code, using the Universally Unique Identifier (UUID) standard

## Architecture & Design
Apex & the Force.com platform provide a great baseline, but we are limited on how we can extend it - the biggest limitation is that SObjects cannot be extended. Nebula uses interfaces, virtual & abstract classes as much as possible so that you can extend & override its logic with your own as needed.

The framework also aims to follow (and encourage) the use of Salesforce best practices - but no solution can fit everyone's needs, so Nebula leverages custom settings to give you control over how the framework works within your Salesforce implementation. There are 4 settings
1. Logger Settings (API Name: NebulaLoggerSettings__c) - Controls the behavior of the class Logger.cls
2. Record Type Settings (API Name: NebulaRecordTypesSettings__c) - Controls the behavior of the class SObjectRecordTypes.cls
3. Repository Seetings (API Name: NebulaRepositorySettings__c) - Controls the behavior of the class SObjectRepository.cls
4. Trigger Handler Settings (API Name: NebulaTriggerHandlerSettings__c - Controls the behavior of the class SObjectTriggerHandler.cls

## Versioning
We use [Semantic Versioning](http://semver.org/) for versioning, like 'v1.0.2' (MAJOR.MINOR.PATCH):

- MAJOR version when incompatible API changes are made
- MINOR version new functionality is added in a backwards-compatible manner
- PATCH version when backwards-compatible bug fixes are made