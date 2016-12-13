
#Functions
function Test-OPSValServiceState{
    
    param(
        $serviceName,
        $computerName = "."
    )
	
	if(($computerName -eq ".") -or ($computerName -eq "$env:computername") -or ($computerName -eq "localhost") -or ($computerName -eq "$env:computername.$env:USERDNSDOMAIN")){
		
		$service = Get-Service -Name $serviceName
		
	}
	else{
		
		$service = Get-Service -Name $serviceName -ComputerName $computerName
		
	}

    return $service

}

function Test-OPSValWebAppPoolState{
    
    param(
        $computerName = "."
    )


    if(($computerName -eq ".") -or ($computerName -eq "$env:computername") -or ($computerName -eq "localhost") -or ($computerName -eq "$env:computername.$env:USERDNSDOMAIN")){

        $iisPool = Get-ChildItem -Path IIS:\AppPools | Where-Object{($_.Name -ne "SharePoint Web Services Root") -and ($_.State -ne "Started")}

    }
    else{

        $template = 'Import-Module WebAdministration;Get-ChildItem -Path IIS:\AppPools | Where-Object{($_.Name -ne "SharePoint Web Services Root") -and ($_.State -ne "Started")}'
        $sb = [ScriptBlock]::Create($template)

        $session = New-PSSession -ComputerName $computerName
        
        $iisPool =  Invoke-Command -Session $session -ScriptBlock $sb
        
        Remove-PSSession -Session $session

    }

    return $iispool

}

#Modules
Import-Module Pester
Import-Module OperationValidation
Add-PSSnapin Microsoft.Sharepoint.Powershell -ErrorAction SilentlyContinue
Import-Module WebAdministration


Describe "Operational Validation of SharePoint 2013" {
    
	Context "Windows Services" {
	
		#Windows Service Area
		$serviceName = "W3SVC"
		$computerName = "localhost"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}

		$serviceName = "SPSearchHostController"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}

		$serviceName = "OSearch15"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}


		$serviceName = "SPTimerV4"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}


		$serviceName = "SPTraceV4"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}

		
		$serviceName = "AppFabricCachingService"

		It "Service $serviceName State should be running" {

			$service = Test-OPSValServiceState -serviceName $serviceName -ComputerName $computerName
			$service.Status | Should be running
		}

		
    }

	Context "WebApp Pools"{
	
		#Web App Pools Area
		It "Web Application Pools in IIS should be running" {

			$iispool = Test-OPSValWebAppPoolState

			($iisPool | Measure-Object).Count | Should be 0	
		}
	
	}
	
	Context "URLCheck" {
		#Url Areas
		$url = "https://sharepoint-test.mydomain.com"

		It "WebSite $url should be running and login working" {

			$request = Invoke-WebRequest -Uri $url -UseDefaultCredentials
			$request.StatusCode | Should be 200				
		}
		
		$url = "https://server:centralAdminPort/"

		It "The Central Administration on $url should be running and login working" {

			$request = Invoke-WebRequest -Uri $url -UseDefaultCredentials
			$request.StatusCode | Should be 200				
		}
	
	}
	
	Context "SP Sites Test"{

		#SharePoint Site Tests
		$webAppUrl = "https://sharepoint-test.domain.com/"

		It "The SharePoint Sites should have no Errors"{
			
			$webApp = Get-SPWebApplication -Identity $webAppUrl

			$sites = Get-SPSite -WebApplication $webApp -Limit All

			$result = $sites | Test-SPSite

			$sitesWithErrors = $null
			$sitesWithErrors = $result | Where-Object{$_.FailedErrorCount -gt 0}

			if(-not([String]::IsNullOrEmpty($sitesWithErrors))){
				$testResult = "Failed"
			}
			else{
				$testResult = "Succeeded"
			}

			$testResult | Should be Succeeded

		}
	}


}

