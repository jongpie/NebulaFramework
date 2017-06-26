---
layout: page
title: Nebula Framework
---
{% include JB/setup %}

Nebula is an open source development framework for Salesforce's Apex language, written in 100% native Apex.  It's built by developers for developers.

Nebula is a development framework for Salesforce's Apex language, written in 100% native Apex. It aims to improve Apex development by
1. Providing a strong & flexible code foundation
2. Eliminating or overcoming some of the inefficiencies in Apex and the Force.com platform
3. Providing a framework to standardise how your code is written & organised
4. Promoting the design of scalable, bulkified code

You can choose to use all of the Nebula framework, or only certain modules - it's open source, designed to be flexible, and we're not your parents, you can do whatever you want.** But all documentation assumes that you are utilising the full framework.

[Download from GitHub](https://github.com/jongpie/NebulaFramework/releases)

[View Source Code on GitHub](https://github.com/jongpie/NebulaFramework)

## Features
Nebula consists of 3 main modules
1. SObject Repositories (SObjectRepository.cls) - this module is an abstraction layer that bridges the gap between CRUD operations and your business logic, making the implementation of both standard & custom SObjects much easier. It also eliminates the need for writing SOQL & SOSL queries, allowing you to easily write dynamic queries.
2. SObject Trigger Handlers (SObjectTriggerHandler.cls) - this module provides a trigger framework for SObjects. It handles implementing your triggers on the Force.com platform and provides benefits like recursion prevention.
3. SObject Record Types (SObjectRecordTypes.cls) - Record types are an important feature of the Force.com platform. Unfortunately, Apex has limitations when working with them - record types have a field called DeveloperName that (you guessed it!) should be used by developers... but native Apex describe methods cannot access this field. Nebula tries to overcome these shortcomings by providing cacheable query of record types so you can access all record type details.

It also provides several additional classes to make Apex development easier, like
* Logger.cls - a flexible logging solution for Apex, leverage by the framework itself
* Environment.cls - provides critical (although missing from Apex) information about the current Salesforce environment, like detecting if you're in a sandbox or production.

## Architecture & Design
Apex & the Force.com platform provide a great baseline, but we are limited on how we can extend it - the biggest limitation is that SObjects cannot be extended. Nebula uses interfaces, virtual & abstract classes as much as possible so that you can extend & override its logic with your own as needed.

The framework also aims to follow (and encourage) the use of Salesforce best practices - but no solution can fit everyone's needs, so Nebula leverages custom settings to give you control over how the framework works within your Salesforce implementation. There are 4 settings
1. Logger Settings (API Name: NebulaLoggerSettings__c) - Controls the behavior of the class Logger.cls
2. Record Type Settings (API Name: NebulaRecordTypesSettings__c) - Controls the behavior of the class SObjectRecordTypes.cls
3. Repository Seetings (API Name: NebulaRepositorySettings__c) - Controls the behavior of the class SObjectRepository.cls
4. Trigger Handler Settings (API Name: NebulaTriggerHandlerSettings__c - Controls the behavior of the class SObjectTriggerHandler.cls