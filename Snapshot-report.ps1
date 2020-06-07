@"
===============================================================================
Title: Get-VmwareSnaphots.ps1
Description: List snapshots on all VMWARE ESX/ESXi servers as well as VM's managed by Virtual Center.
Requirements: Windows Powershell and the VI Toolkit
Usage: .\Get-VmwareSnaphots.ps1
Author: Tayfun Deger
===============================================================================
"@
 
Import-Module VMware.VimAutomation.Core
#Global Functions
#This function generates a nice HTML output that uses CSS for style formatting.
function Generate-Report {
Write-Output "<html><head><title></title><style type=""text/css"">.Error {color:#FF0000;font-weight: bold;}.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;}.Normal {}</style></head><body><table><tr class=""Title""><td colspan=""5"">VMware Snaphot Report</td></tr><tr class="Title"><td>VM Name </td><td>Snapshot Name </td><td>Date Created </td><td>Description </td><td>Size (GB) </td><td>User Name </td></tr>"
 
Foreach ($snapshot in $report){
Write-Output "<td>$($snapshot.vm)</td><td>$($snapshot.name)</td><td>$($snapshot.created)</td><td>$($snapshot.description)</td><td>$($snapshot.SizeGB)</td><td>$($snapshot.username)</td></tr> "
}
Write-Output "</table></body></html>"
}
 
#Login details for standalone ESXi servers
$username = 'vCenter-Login-Name'
$password = 'vCenter-Login-Şifre' #Change to the root password you set for you ESXi server
 
#List of servers including Virtual Center Server. The account this script will run as will need at least Read-Only access to Virtual Center
#$ServerList = "vCenter-ISMI" #Chance to DNS Names/IP addresses of your ESXi servers or Virtual Center Server
 
#Initialise Array
$Report = @()
 
#Get snapshots from all servers
#' foreach ($server in $serverlist){
 
# Check is server is a Virtual Center Server and connect with current user
# if ($server -eq "vCenter-ISMI"){Connect-VIServer $server}
 
# Use specific login details for the rest of servers in $serverlist
# else {Connect-VIServer $server -user $username -password $password}
Connect-VIServer vCenter-ISMI -user $username -password $password
 
get-vm | where { $_.PowerState -eq “PoweredOn”} | get-snapshot | %{
$Snap = {} | Select VM,Name,Created,Description,SizeGB,username
$Snap.VM = $_.vm.name
$Snap.Name = $_.name
$Snap.Created = $_.created
$Snap.Description = $_.description
$Snap.SizeGB = [Math]::Floor($_.SizeGB)
 
$t =Get-VIEvent -Entity $_.vm.name -MaxSamples 1000 | where {$_.FullFormattedMessage -like "*Task: Create virtual machine snapshot*"} | select username | select-object -First 1
$Snap.username =$t.UserName
$Report += $Snap
echo $Snap >> "C:\out.txt"
}
# }
echo $Report >> "C:\out1.txt"
 
# Generate the report and email it as a HTML body of an email
Generate-Report > "VmwareSnapshots.html"
IF ($Report -ne ""){
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "SMTP-IP-ADRESI" #Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "snapshotwarning@tayfundeger.com" #Change to email address you want emails to be coming from
$MailMessage.To.add("tayfun@tayfundeger.com") #Change to email address you would like to receive emails.
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "vCenter-ISMI- Günlük Snapshot Listesi"
$MailMessage.Body = Generate-Report
$SmtpClient.Send($MailMessage)}
 
Disconnect-VIServer vCenter-ISMI -Confirm:$false
