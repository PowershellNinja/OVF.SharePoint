# OVF.SharePoint
## Overview

Tests based on the Operation Validation Framework to test basic SharePoint functionality and operation using Pester.

Requirements:
* PSSnapin: Microsoft.SharePoint.Powershell
* PSModule: WebAdministration
* PSModule: Pester
* PSModule: OperationValidation

### Currently implemented tests

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
  * Custom **(URLs need to be changed according to you needs)**
  * Central Administation **(URL needs to be changed)**
* SharePoint SiteCollection Health Tests (Test-SPSite)
  * Custom **(WebApplication URL needs to be changed)**
* SharePoint Databases should have to Upgrades pending
	
**SharePoint Enterprise Search**

*Currently works only with one Search Service Application*

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



### Getting Started - Installation

To get started with the OVF.SharePoint Module, you will need to either download it from the PowershellGallery,
or clone/download this repository and copy the files to the correct place.

**Option 1: Direct Download from the Powershell Gallery**

*The Powershell Way to do things* 

**If no one ever used the Powershell Package Management on you Machine, you will need Local Admin Rights for this. You have been warned.**

**Steps**

#### Step 1: 

You have chosen the the red pill (Morpheus is proud of you)

#### Step 2:

Jokes aside. The most important thing is: Knoweth thy Powershell Version. 

Open a Powershell Window, enter 
```Powershell 
$PSVersionTable
```
and press Enter.

Look for the PSVersion Property.

#### Step 3:

*If you have Powershell Version 5 or higher:*

Directly go to Step 4. (*Do not pass over Start. Haha. Monopoly-Joke*)

*If you have Powershell Version 3 or 4:*

Go to the : [Powershell Gallery Web Page](https://www.powershellgallery.com)

Press the "Get PowershellGet for PS 3 & 4" Button

Download and install the MSI (Preferred in x64)

Continue with Step 4.


#### Step 4:

If you don't already have an open Powershell Window, open one.

Type in your Powershell Window: 
```Powershell
Find-Module -Name "OVF.SharePoint" -Repository "PSGallery" | Install-Module
```
Press Enter

If you have never used the Powershell Package Management before, you will be asked to Confirm the Installation of Nuget, the Package Software Powershell relies upon (**You need to be a Local Administrator to do this**)

Wait for the Download to finish.

#### Step 5:

To check if the Installation worked, open a Powershell Window and type:

```Powershell
Get-Module -Name "OVF.SharePoint" -ListAvailable
```

If the Module shows up: Yay!

If the Module does not show up: 

Something went wrong. Either go to "C:\Program Files\WindowsPowershell\Modules" and directly look for the Folder (OVF.SharePoint) or try the installation again and append ```-Scope CurrentUser```, which will place the module in your UserProfile\WindowsPowershell\Modules:

```Powershell
Find-Module -Name OVF.SharePoint -Repository PSGallery | Install-Module -Scope CurrentUser
```

**Option 2: Download / Clone this Repository and do some manual copying**

*For all who know that there are 10 kinds of humans... (and all who can do Copy-Paste)*

#### Step 1:

On this Page, in the upper right corner, press the green **"Clone or download"** button, then press **"Download ZIP"**.

Save on a local path, unzip.

#### Step 2:

From the unzipped folder, where you also have the README.MD file, copy the **"OVF.SharePoint"** folder to:

*If you have Local Admin Rights*

```C:\Program Files\WindowsPowershell\Modules```

*If you do not have Local Admin Rights*

```C:\Users\TheNameOfYourUserProfile\WindowsPowershell\Modules```

**Note:** The WindowsPowershell folder in your UserProfile may not exists, if so, just create it manually (With this exact name. Also create the "Modules" subfolder with this exact name)

#### Step 3:

To check if the Installation worked, open a Powershell Window and type:

```Powershell
Get-Module -Name "OVF.SharePoint" -ListAvailable
```

If the Module shows up: Yay!

If the Module does not show up: 

Check if you have any errors in your path. The Module needs to be (exactly) located at either

```C:\Program Files\WindowsPowershell\Modules\OVF.SharePoint```

OR

```C:\Users\TheNameOfYourUserProfile\WindowsPowershell\Modules\OVF.SharePoint```

In this Folder contained should be a Folder called "Diagnostics" and a file called "OVF.SharePoint.psd1".

### Getting Started - Configuration

#### Step 1:

*The Hardware*

Go to the Folder "OVF.SharePoint" (in the Path where you installed it, either unter Program Files or your UserProfile), and from there on, open the following file:

```"\OVF.SharePoint\Diagnostics\Simple\OVF.SharePoint.Tests.ps1"```

If you are hardcore, you can use Notepad. If you are not, there are a lot of better options:

* The Powershell ISE (Press Windows+R and enter ```powershell_ise```): Builtin, medium performance, full syntax highlighting for Powershell, builtin Powershell Console
* [Notepad++](https://notepad-plus-plus.org): Free, Lightweight, a lot of cool plugins (I love the "Compare"-Plugin), simple syntax highlighting for Powershell, NO builtin Powershell Console
* [Visual Studio Code](https://code.visualstudio.com): Free, Lightweight, a lot functions like source control and more, full syntax highlighting for Powershell, builtin Powershell Console (**My Favorite ;-)**)

#### Step 2:

*Know what you are doing*

Analyse the File Content (Ignore the Functions for now) and try to understand the following Structure of a OperationValidation Test:

```Powershell
Describe "Operational Validation of A System" {
  
  Context "Windows Services" {
    
    It "Service "Spooler" State should be running" {

      $service = Get-Service -Name Spooler
      $service.Status | Should be running

    }
  }
}
```

The **"Describe"** Keyword encloses the whole Test Definition. **You need this.**


The **"Context"** Keyword encloses a part, some of the tests. In OperationValidation, you don't necessarily need this, it is here for reference and to make stuff look a bit more organized.

If you want to know what the Context Keyword is really about, I suggest you read a Pester primer: 
[PowershellMagazine](http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework)
or [Simple Talk](https://www.simple-talk.com/sysadmin/powershell/practical-powershell-unit-testing-getting-started)

The **"It"** Keyword is used to describe one specific test.

Inside the It block, you are completely free to use Powershell - Functions, Scripts, Variables and so on.

Important is this: In the End, you need 1 Value that you can test against another Value, like 
```Powershell
$service.Status | Should be "Running"
```
This is OperationValidations way to test if
```Powershell
$service.Status -eq "Running"
```
You are completely free to use the whole Pester syntax - but then again, read a Pester primer first ;-)


#### Step 3:

*Dive in head first*

Now to explain the actual setup. There are two functions:
*  Test-OPSValServiceState
*  Test-OPSValWebAppPoolState

Both of them do nothing more than accept a "ComputerName" parameter to let you decide from which Computer you would like to gather this info. Most prodcutive SharePoint setups have more than one server. If you dont: Do it. Else Murphy will get you (:-P)

So now we got two functions that can get a Windows Service State and the State of some WebAppPools from a local or a remote Computer using Powershell Remoting - lets test something.

We define two Variables:
```Powershell
$serviceName = "W3SVC"
$computerName = "localhost"
```

This means, the functions are going to run against the local computer, and, the service being tested is the "W3SVC".

**Removing Tests**

Now for exampe if you don't have a Enterprise Search Service: Just delete the whole **"It"** block, including the brackets {}. Test gone.

**Adding Tests**

If you want to add another test for lets say your ultracool Windows Service you wrote yourself, just add anywhere between the other service tests:

```Powershell
$serviceName = "MyUltraCoolProvisioningService"
$computerName = "localhost"

It "Service $serviceName State should be running" {

  $service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
  $service.Status | Should be running
}
```

Voila, test added.

#### Step 4:

*Now, can we please stop all the theory and run this?!*

Sure. Soon. Just some little additional adjustements needed.

As I don't know under which URLs you are running your SharePoint, you will have to adjust the following part:

```Powershell
Context "URLCheck" {
		#Url Areas
		$url = "https://sharepoint-test.mydomain.com"
```

Obviously, I just entered any URL and you should adjust this to the URL of one of your SharePoint Sites.

Do the same for

```Powershell
$url = "https://server:centralAdminPort/"
```

Enter your Central Admin URL.

Now, likely you don't have only one SiteCollection. Want to add a URL Test?

Just Copy-Paste

```Powershell
$url = "https://sharepoint-test.mydomain.com"

It "WebSite $url should be running and login working" {

  $request = Invoke-WebRequest -Uri $url -UseDefaultCredentials
  $request.StatusCode | Should be 200				
}
```

and change the URL. Voila.

Just one more thing to go.

Adjust the URL here:

```Powershell
Context "SP Sites Test"{
    #SharePoint Site Tests
    $webAppUrl = "https://sharepoint-test.domain.com/"
```
To be the URL of one of your WebApplications. Want to add another WebApplication Test? Well, do as above, Copy-Paste the **"It"** statement and change the Url.

#### Step 5:

*Now, running all of this...*

Is fairly simple. Open a Powershell Console and type:

```Powershell
Invoke-OperationValidation -ModuleName "OVF.SharePoint"
```

Seeing some green? Yay!
Seeing some red? Either, something went wrong during the Configuration - check the URLs for the test that failed - if everything is correct - congrats, you just found use for OperationValidation (and should likely now go investigate why something is down in your SharePoint ;-))

Happy testing!

## Contributing

**Contribution without coding - Bugs, Issues, Ideas, Feature Requests**

You like this module, but you found a bug or have and idea that you think would make this cooler? Or you have an idea for an additional test? Just click on the "Issues" tab, open a new issue and tell me about it.

**Contribution with coding**

You like the module so much you would like to implement some stuff yourself? Great, you are very welcome.

Before you dive head in, make sure you are familiar with the way Github works - if you don't, read a primer on Github, like this one:
[Github for Powershell Projects](http://ramblingcookiemonster.github.io/GitHub-For-PowerShell-Projects) (In fact, the article is good for anyone who has not already a lot of experience with Github)

**Now have fun trying out the module and don't forget, suggestions, bugreports and ideas and of course contribution are very welcome!**


