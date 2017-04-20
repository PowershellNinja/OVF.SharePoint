


function New-HostTemplate{
	
	# Template object for the host array:
	$hostTemplate = New-Object -TypeName PSObject
	$hostTemplate | Add-Member -MemberType NoteProperty -Name hostName -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name components -Value 0
	$hostTemplate | Add-Member -MemberType NoteProperty -Name cpc -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name qpc -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name pAdmin -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name sAdmin -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name apc -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name crawler -Value $null
	$hostTemplate | Add-Member -MemberType NoteProperty -Name index -Value $null

	return $hostTemplate

}

function New-HATemplate{
	
	# Template object for the HA group array:
	$haTemplate = New-Object -TypeName PSObject
	$haTemplate | Add-Member -MemberType NoteProperty -Name entity -Value $null
	$haTemplate | Add-Member -MemberType NoteProperty -Name partition -Value -1
	$haTemplate | Add-Member -MemberType NoteProperty -Name primary -Value $null
	$haTemplate | Add-Member -MemberType NoteProperty -Name docs -Value 0
	$haTemplate | Add-Member -MemberType NoteProperty -Name components -Value 0
	$haTemplate | Add-Member -MemberType NoteProperty -Name componentsOk -Value 0
	
	return $haTemplate
	
}

function New-ComponentTemplate{
	
	# Template object for the component/server table:
	$compTemplate = New-Object -TypeName PSObject
	$compTemplate | Add-Member -MemberType NoteProperty -Name Component -Value $null
	$compTemplate | Add-Member -MemberType NoteProperty -Name Server -Value $null
	$compTemplate | Add-Member -MemberType NoteProperty -Name Partition -Value $null
	$compTemplate | Add-Member -MemberType NoteProperty -Name State -Value $null
	
	return $compTemplate

}

function New-ComponentHAList{
	
	param(
		$searchComponent
	)
	
	if ($searchComponent.ServerName)
	{
		$hostName = $searchComponent.ServerName
	}
	else
	{
		$hostName = "Unknown server"
	}
	$partition = $searchComponent.IndexPartitionOrdinal
	$newHostFound = $true
	$newHaFound = $true
	$entity = $null

	foreach ($searchHost in ($script:hostArray))
	{
		if ($searchHost.hostName -eq $hostName)
		{
			$newHostFound = $false
		}
	}
	if ($newHostFound)
	{
		# Add the host to $script:hostArray
		$hostTemp = New-HostTemplate
		$hostTemp.hostName = $hostName
		$script:hostArray += $hostTemp
		$script:searchHosts += 1
	}

	# Fill in component specific data in $script:hostArray
	foreach ($searchHost in ($script:hostArray))
	{
		if ($searchHost.hostName -eq $hostName)
		{
			$partition = -1
			if ($searchComponent.Name -match "Query") 
			{ 
				$entity = "QueryProcessingComponent" 
				$searchHost.qpc = "QueryProcessing "
				$searchHost.components += 1
			}
			elseif ($searchComponent.Name -match "Content") 
			{ 
				$entity = "ContentProcessingComponent" 
				$searchHost.cpc = "ContentProcessing "
				$searchHost.components += 1
			}
			elseif ($searchComponent.Name -match "Analytics") 
			{ 
				$entity = "AnalyticsProcessingComponent" 
				$searchHost.apc = "AnalyticsProcessing "
				$searchHost.components += 1
			}
			elseif ($searchComponent.Name -match "Admin") 
			{ 
				$entity = "AdminComponent" 
				if ($searchComponent.Name -eq $script:primaryAdmin)
				{
					$searchHost.pAdmin = "Admin(Primary) "
				}
				else
				{
					$searchHost.sAdmin = "Admin "
				}
				$searchHost.components += 1
			}
			elseif ($searchComponent.Name -match "Crawl") 
			{ 
				$entity = "CrawlComponent" 
				$searchHost.crawler = "Crawler "
				$searchHost.components += 1
			}
			elseif ($searchComponent.Name -match "Index") 
			{ 
				$entity = "IndexComponent"
				$partition = $searchComponent.IndexPartitionOrdinal
				$searchHost.index = "IndexPartition($partition) "
				$searchHost.components += 1
			}
		}
	}

	# Fill in component specific data in $script:haArray
	foreach ($haEntity in ($script:haArray))
	{
		if ($haEntity.entity -eq $entity)
		{
			if ($entity -eq "IndexComponent")
			{
				if ($haEntity.partition -eq $partition)
				{
					$newHaFound = $false
				}
			}
			else 
			{ 
				$newHaFound = $false
			}
		}
	}
	if ($newHaFound)
	{
		# Add the HA entities to $script:haArray
		$haTemp = New-HATemplate
		$haTemp.entity = $entity
		$haTemp.components = 1
		if ($partition -ne -1) 
		{ 
			$haTemp.partition = $partition 
		}
		$script:haArray += $haTemp
	}
	else
	{
		foreach ($haEntity in ($script:haArray))
		{
			if ($haEntity.entity -eq $entity) 
			{
				if (($entity -eq "IndexComponent") )
				{
					if ($haEntity.partition -eq $partition)
					{
						$haEntity.components += 1
					}
				}
				else
				{
					$haEntity.components += 1
					if (($haEntity.entity -eq "AdminComponent") -and ($searchComponent.Name -eq $script:primaryAdmin))
					{
						$haEntity.primary = $script:primaryAdmin
					}
				}
			}
		}
	}
}

function Get-IndexerEvents{

	$indexerComps = $script:escss | Where-Object{$_.Name -match "Index" -or $_.Name -match "Content" -or $_.Name -match "Admin" -and $_.Name -notmatch "Cell" -and $_.State -notmatch "Unknown" -and $_.State -notmatch "Registering"}

    foreach ($component in $indexerComps)
    {

		[array]$events += Get-SPEnterpriseSearchStatus -SearchApplication $script:essa -HealthReport -Component $component.Name
		
		return $events
    
    } 

}

function Test-AnalyticsStatus{
	
	$analyticsStatus = Get-SPEnterpriseSearchStatus -SearchApplication $script:essa -JobStatus

    foreach ($analyticsEntry in $analyticsStatus)
    {
        
        # Output additional diagnostics from the dictionary
        foreach ($de in ($analyticsEntry.Details))
        {
            # Skip entries that is listed as Not Available
            if ( ($de.Value -ne "Not available") -and ($de.Key -ne "Activity") -and ($de.Key -ne "Status") )
            {
                if ($de.Key -match "Last successful start time")
                {
                    $dLast = Get-Date $de.Value
                    $dNow = Get-Date
                    $daysSinceLastSuccess = $dNow.DayOfYear - $dLast.DayOfYear
                    if ($daysSinceLastSuccess -gt 3)
                    {
                        [array]$analytcsJobNotRunCount += 1
                    }
                }
            }
        }
    }
	
	return $analytcsJobNotRunCount
}


Add-PSSnapin Microsoft.SharePoint.Powershell
	
$script:essa = Get-SPEnterpriseSearchServiceApplication
$script:esccs = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication $script:essa
$script:est = Get-SPEnterpriseSearchTopology -SearchApplication $script:essa -Active
$script:esc = Get-SPEnterpriseSearchComponent -SearchTopology $script:est
$script:ess = Get-SPEnterpriseSearchStatus -SearchApplication $script:essa -JobStatus
$script:eshc = Get-SPEnterpriseSearchHostController
$script:escss = Get-SPEnterpriseSearchStatus -SearchApplication $script:essa


$script:hostArray = @()

$script:haArray = @()

$script:compArray = @()

$script:topologyCompList = Get-SPEnterpriseSearchComponent -SearchTopology $script:est

foreach ($component in ($script:esccs)){
	if ( ($component.Name -match "Admin") -and ($component.State -ne "Unknown") ){
		if (Get-SPEnterpriseSearchStatus -SearchApplication $script:essa -Primary -Component $($component.Name)){
			$script:primaryAdmin = $component.Name
		}
	}
}   

foreach ($searchComponent in ($script:topologyCompList))
{
    New-ComponentHAList -searchComponent $searchComponent
}


$componentEvents = Get-IndexerEvents


Describe "Operational Validation of SharePoint 2013 Search Topology"{

	
	
	It "Enterprise Search Service Application should be Online"{
	
		$script:essa.Status | Should be "Online"

	}
	
	It "All Enterprise Search Components should be Online"{
		
		$offlineComponents = ($script:escss | Where-Object{$_.State -ne "Active"} | Measure-Object).Count
		
		$offlineComponents | Should be 0

	}	

	It "Indexer, Content Processor and Admin Component should not have Errors"{
		$errorEventCount = ($componentEvents | Where-Object{$_.Level -eq "Error"} | Measure-Object).Count
		
		$errorEventCount | Should be 0
	}
	
	It "Indexer, Content Processor and Admin Component should not have Warnings"{
		$warningEventCount = ($componentEvents | Where-Object{$_.Level -eq "Warning"} | Measure-Object).Count
		
		$warningEventCount | Should be 0
	}

	It "No Component should be on a High Document Count"{
		$docsHighCount = ($script:haArray | Where-Object{$_.docs -gt 9000000} | Measure-Object).Count 
	
		$docsHighCount | Should be 0
	}
	
	It "No Component should exceed the Healthy Document Count"{
	
		$docsExceededCount = ($script:haArray | Where-Object{$_.docs -gt 10000000}| Measure-Object).Count
		
		$docsExceededCount | Should be 0
	}

	It "All Host Controllers should have the same Repository Version"{
		
		$hostControllerCount = ($script:eshc | Measure-Object).Count
		if($hostControllerCount -eq 1){
			$sameVersion = $true
		}
		elseif($hostControllerCount -gt 1){
			
			$highestVersion = 0
			
			foreach($hostController in $script:eshc){
				if($hostController.Version -gt $highestVersion){
					$highestVersion = $hostController.Version
				}
			}
			
			$hostControllerWithLowerVersionCount = ($script:eshc | Where-Object{$_.Version -lt $highestVersion} | Measure-Object).Count
			
			if($hostControllerWithLowerVersionCount = 0){
				$sameVersion = $true
			}
			else{
				$sameVersion = $false
			}
			
		}
		
		$sameVersion | Should be true

	}

	It "All Analytics Jobs should have Succesfully Run in the last three Days"{
        $jobsNotRunCount = Test-AnalyticsStatus
		
		$jobsNotRunCount | Should be 0
	}

	It "Enterprise Search Service Application should not be Paused"{
		
		$essaStatus = $script:essa.Ispaused()
		
		$essaStatus | Should be 0
        
	}
	
	It "All Content Sources should have been successfully crawled in the last 3 days"{
		
		$contentSources = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication $global:essa
		
		$crawlNotCompletedCount = 0
		
		foreach($contentSource in $contentSources){
			
			$crawlLastCompleted = $contentSource.CrawlCompleted
			$timeDifference = (Get-Date) - $crawlLastCompleted
			
			if($timeDifference.Days -ge 3){
				$crawlNotCompletedCount++
			}
			
		}
		
		$crawlNotCompletedCount | Should be 0
        
	}


}