@"
===============================================================================
Title: Kapasite-raporu.ps1
Description: List capacity report on all VMWARE ESX/ESXi servers as well as VM's managed by Virtual Center.
Requirements: Windows Powershell and the VI Toolkit
Usage: .\Kapasite-raporu.ps1
Author: Tayfun Deger
===============================================================================
"@
 
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
 
filter Get-FolderPath {
$_ | Get-View | % {
$row = "" | select Name, Path
$row.Name = $_.Name
 
$current = Get-View $_.Parent
# $path = $_.Name # Uncomment out this line if you do want the VM Name to appear at the end of the path
$path = ""
do {
$parent = $current
if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
$current = Get-View $current.Parent
} while ($current.Parent -ne $null)
$row.Path = $path
$row
}
}
 
$VCServerName = "TayfunDeger-vCenter-IP"
$VC = Connect-VIServer $VCServerName -User tayfundeger\Administrator -Password Password1
$VMFolder = "*"
$ExportFilePath = "C:\TayfunDeger-vCenter-Configuration.csv"
 
$Report = @()
$VMs = Get-Folder $VMFolder | Get-VM
 
$Datastores = Get-Datastore | select Name, Id
$VMHosts = Get-VMHost | select Name, Parent
 
ForEach ($VM in $VMs) {
$VMView = $VM | Get-View
$VMInfo = {} | Select VMName,Powerstate,Cluster,Datastore,NumCPU,MemoryGb,DiskGb,Notes
$VMInfo.VMName = $vm.name
$VMInfo.Powerstate = $vm.Powerstate
$VMInfo.Cluster = $vm.host.Parent.Name
$VMInfo.Datastore = ($Datastores | where {$_.ID -match (($vmview.Datastore | Select -First 1) | Select Value).Value} | Select Name).Name
$VMInfo.NumCPU = $vm.NumCPU
$VMInfo.MemoryGb = ([Math]::Round(($vm.MemoryMB),2)) / 1024
$VMInfo.DiskGb = [Math]::Round(((Get-VM -Name $vm.Name | Get-HardDisk | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
$VMInfo.Notes = $vm.Notes
$Report += $VMInfo
}
$Report = $Report | Sort-Object VMName
IF ($Report -ne "") {
$report | Export-Csv $ExportFilePath -NoTypeInformation -UseCulture
}
 
###########Define Variables########
 
$fromaddress = "vcenterinfo@tayfundeger.com"
$bccaddress = "bcc@tayfundeger.com"
$Subject = "VM Configuration Report - TayfunDeger"
$attachment = "C:\TayfunDeger-vCenter-Configuration.csv"
$smtpserver = "SMTP-IP-Adresi"
 
####################################
 
$message = new-object System.Net.Mail.MailMessage
$message.From = $fromaddress
#$message.To.Add($toaddress)
$message.Bcc.Add($bccaddress)
$message.IsBodyHtml = $True
$message.Subject = $Subject
$attach = new-object Net.Mail.Attachment($attachment)
$message.Attachments.Add($attach)
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)
 
$VC = Disconnect-VIServer TayfunDeger-vCenter-IP -Confirm:$False
