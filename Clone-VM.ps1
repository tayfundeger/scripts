Add-PSSnapin VMware.VimAutomation.Core
#variables
$VC='vcenter-server-FQDN-or-IP'
#import credentials
$pwd = Get-Content D:\tools\scripts\ap-vcs-credentials | ConvertTo-SecureString
$credentials = New-Object System.Management.Automation.PsCredential “username“, $pwd
#Connect to vCenter
Connect-VIServer -Server $VC
$sourceVM = 'test01'
#in $respool you can specify ESX host, cluster or resource pool
$respool=Get-VMhost -Name "ESXi host name"
$datastore=Get-datastore -Name 'datastore name'
$cloneName = $sourceVM+'-01'
#Remove second copy of VM
Remove-VM $sourceVM'-02' -Confirm:$false -DeletePermanently:$true
#Rename latest VM copy
Get-VM -Name $sourceVM'-01' | Set-VM -Name $sourceVM'-02' -confirm:$false
#Clone VM
if(New-VM -Name $cloneName -VM $sourceVM -ResourcePool $respool -Datastore $datastore -DiskStorageFormat Thin ){"DONE"}else{"Something wrong with cloning"}
Disconnect-VIServer -Confirm:$false
