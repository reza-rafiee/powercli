<#
    Create_VDS_PortGroups.ps1

    Creates Port Groups in a VMware Distributed Switch

    Feed the script with "portgroups.csv" file with portgroup names and vlan IDs and then update $VDS with the terget VDS_Name.
	
	portgroup.csv must have "portgroup" and "vlan" header to identify the portgroup name and corresponding vlan ID.
	
	Please note that this code is only for creating switchports (single VLAN) not trunk port groups (VLAN range).
	
	I wrote this script for migrating portgroups from Nexus 1000v to VMware Distributed Switch
    
    .History.
	2020/03/06 - 0.1 - Reza Rafiee	- First version

#>

############################
$PGs = Import-CSV .\portgroups.csv
$VDS = "RZ-VDS"
$RefPG = Get-VDPortgroup -Name "RZPG1"

ForEach ($PG in $PGs) {
    $newPG = Get-VDSwitch -Name $VDS |
    New-VDPortgroup -Name $PG.portgroup  -ReferencePortgroup $RefPG.Name | Set-VDPortgroup -Notes $PG.description
    Set-VDVlanConfiguration -VDPortgroup $newPG -VlanId $PG.vlan -Confirm:$false 
	}
############################
