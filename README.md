#OVF.SharePoint
## Overview

Tests based on the Operation Validation Framework to test basic SharePoint functionality and operation using Pester.

Requirements:
* PSSnapin: Microsoft.SharePoint.Powershell
* PSModule: WebAdministration
* PSModule: Pester
* PSModule: OperationValidation

**Currently implemented tests**


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
	