<#
    MoveVD.ps1
	Move a virtual disk between two VMs

    Recently I had a request for writing a script to easily detach a virtual disk from a VM and attach it to another VM.
	

    .History.
	2020/05/28 - 0.1 - Reza Rafiee		- Initial version
	

#>

###############################
Write-host (" ")
$SourceVM =		Read-Host "Enter Source VM Name "
$srcVM=Get-VM -Name $SourceVM

Write-host ("The attached virtual disks on $srcVM.name ")
get-vm -name $srcVM | Get-HardDisk | Select Name,CapacityGB,Persistence,Filename

Write-host (" ")

$VDiskNumber =	Read-Host "Enter the Virtual Hard Disk Number that you want to detach from $srcVM.name  "

$VDiskSize =	Read-Host "Enter the Disk Size (GB) "

Write-host (" ")

$TargetVM =		Read-Host "Enter Target VM Name "




$trgVM= Get-VM -Name $TargetVM
$trgDisk="Hard Disk $VDiskNumber"

$disk=get-vm -name $srcVM | Get-HardDisk | Where-Object {($_.Name -eq $trgDisk) -AND ($_.CapacityGB -eq $VDiskSize)}


If ($disk -eq $null){
write-host ("No Hard Disk found as ($trgDisk - $VDiskSize GB) on $SourceVM")
exit
}

$confirmation = Read-Host -Prompt "Are you sure you want to detach ($trgDisk - $VDiskSize GB) on $SourceVM and attach it to $TargetVM ? [y/n]"

If ($confirmation -eq "y") {
	Remove-HardDisk $disk -Confirm:$false
	New-HardDisk -VM $trgVM -DiskPath $disk.Filename
#You can also specify the SCSI controller of which the disk should be attached to by adding the following parameter to the above command:  -Controller "SCSI Controller 0"
	Write-host (" ")
	Write-host ("The attached virtual disks on $trgVM.name ")
	get-vm -name $trgVM | Get-HardDisk | Select Name,CapacityGB,Persistence,Filename
	
	}
###############################