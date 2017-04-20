#OVF.SharePoint
## Overview

Tests based on the Operation Validation Framework to test basic SharePoint functionality and operation using Pester.

Requirements:
* PSSnapin: Microsoft.SharePoint.Powershell
* PSModule: WebAdministration
* PSModule: Pester
* PSModule: OperationValidation

**Currently implemented tests**

**SharePoint Server**
* Windows Services
  * W3SVC
  * SPSearchHostController
  * OSearch15
  * SPTimerV4
  * SPTraceV4
  * AppFabricCachingService
* WebApplication Pools
  * WebApp Pools should be running (Except "Sharepoint Web Services Root")
* URL Online and Login working Check
  * Custom (URLs need to be changed according to you needs)
  * Central Administation (URL needs to be changed)
* SharePoint SiteCollection Health Tests (Test-SPSite)
  * Custom (WebApplication URL needs to be changed)
* SharePoint Databases should have to Upgrades pending
	
**SharePoint Enterprise Search**
* Enterprise Search Service Application Online
* All Enterprise Search Components Online
* Indexer, Content Processor and Admin Component should not have Errors
* Indexer, Content Processor and Admin Component should not have Warnings
* No Component should be on a High Document Count
* No Component should exceed the Healthy Document Count
* All Host Controllers should have the same Repository Version
* All Analytics Jobs should have Succesfully Run in the last three Days
* Enterprise Search Service Application should not be Paused
* All Content Sources should have been successfully crawled in the last 3 days
