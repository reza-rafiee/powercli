<#
    configure-snmp-on-esxi.ps1
	
	Configure SNMP settings on multiple ESXi hosts using a reference host settings

    .History.
	2020/04/09 - 0.1 - Reza Rafiee	- First version


	.Variables.
	$VC				    : vCenter Server
	$targethosts	: Target ESXi host cluster (to apply on single ESXi host refer to line30) 
	$refesxhost		: Reference ESXi host
			
#>

$VC="vCenter Server Name"
$targethosts="Target cluster name"
$refesxhost = "Reference ESXi host name"



Connect-viserver $VCServer
$refhost = get-vmhost $refesxhost
$refesxcli = Get-EsxCli -VMhost $refhost -V2
$snmp=$refesxcli.system.snmp.get.invoke()
write-host "SNMP configuration on " $refesxhost," (Refernce Host): " 
$snmp

$vmhosts = get-cluster -name $targethosts | get-vmhost
<#If you want to apply the snmp config on a single host
 then enter ESXi host name for $targethosts variable and replace the above line with the below line:
 
 $vmhosts = get-vmhost -name $targethosts
 
 #> 
 

foreach ($vmhost in $vmhosts){

  $esxcli = Get-EsxCli -VMHost $vmhost -V2

#Reset SNMP settings to factory default on the target host prior to reconfigure SNMP settings on that host
  $snmpreset = $esxcli.system.snmp.set.CreateArgs()
  $snmpreset.reset = $true
  $esxcli.system.snmp.set.Invoke($snmpreset)

  write-host "SNMP settigs has been reset to default on $vmhost"
#SNMP settings reset complete
  
  $esxcli = Get-EsxCli -VMHost $vmhost -V2
  $arguments = $esxcli.system.snmp.set.CreateArgs()
 
 #The below arguments cannot be null hence we skip the null ones
 
if ($snmp.communities -ne $null) {
	$arguments.communities = $snmp.communities  
}

if ($snmp.engineid -ne "$null") {
	write-host "engineid is nt null"
	$arguments.engineid = $snmp.engineid
}

if ($snmp.targets -ne $null) {
	$arguments.targets = $snmp.targets
}

if ($snmp.users -ne $null) {
	$arguments.users = $snmp.users
}

if ($snmp.privacy -in ("none", "AES128")) {
	$arguments.privacy = $snmp.privacy
}

if ($snmp.remoteusers -ne $null) {
	$arguments.remoteusers = $snmp.remoteusers
}
 
if ($snmp.authentication -in ("none", "MD5", "SHA1")) {
	$arguments.authentication = $snmp.authentication
}

if ($snmp.v3targets -in ("none", "auth", "priv")) {
	$arguments.v3targets = $snmp.v3targets
}

  $arguments.hwsrc = $snmp.hwsrc
  $arguments.largestorage = $snmp.largestorage
  $arguments.loglevel = $snmp.loglevel
  $arguments.notraps = $snmp.notraps
  $arguments.enable = $snmp.enable
  $arguments.port = $snmp.port
  $arguments.syscontact = $snmp.syscontact
  $arguments.syslocation = $snmp.syslocation

  $esxcli.system.snmp.set.Invoke($arguments)

  $newsnmp=$esxcli.system.snmp.get.Invoke()
  write-host "SNMP configuration on", $vmhost, ": "
  $newsnmp
  
}
