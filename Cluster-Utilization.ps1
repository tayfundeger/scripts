@"
===============================================================================
Title: Cluster-Utilization.ps1
Description: List cluster report on all VMware ESX/ESXi servers as well as VM's managed by Virtual Center.
Requirements: Windows Powershell and the VI Toolkit
Usage: .\Cluster-Utilization.ps1
Author: Tayfun Deger
===============================================================================
"@
 
Get-Module -Name VMware* -ListAvailable | Import-Module
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
 
Connect-VIServer vCenter-IP -User vCenter-Username -Password vCenter-Şifre
 
$report = @()
$clusterName = "*"
$report = foreach($cluster in Get-Cluster -Name $clusterName){
$esx = $cluster | Get-VMHost
$ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS" -and $_.Extensiondata.Summary.MultipleHostAccess}
$rp = Get-View $cluster.ExtensionData.ResourcePool
New-Object PSObject -Property @{
VCname = $cluster.Uid.Split(':@')[1]
DCname = (Get-Datacenter -Cluster $cluster).Name
Clustername = $cluster.Name
"Number of hosts" = $esx.Count
"Total Processors" = ($esx | measure -InputObject {$_.Extensiondata.Summary.Hardware.NumCpuPkgs} -Sum).Sum
"Total Cores" = ($esx | measure -InputObject {$_.Extensiondata.Summary.Hardware.NumCpuCores} -Sum).Sum
"Current CPU Failover Capacity" = $cluster.Extensiondata.Summary.AdmissionControlInfo.CurrentCpuFailoverResourcesPercent
"Current Memory Failover Capacity" = $cluster.Extensiondata.Summary.AdmissionControlInfo.CurrentMemoryFailoverResourcesPercent
"Configured Failover Capacity" = $cluster.Extensiondata.ConfigurationEx.DasConfig.FailoverLevel
"Migration Automation Level" = $cluster.Extensiondata.ConfigurationEx.DrsConfig.DefaultVmBehavior
"DRS Recommendations" = &{$result = $cluster.Extensiondata.Recommendation | %{$_.Reason};if($result){[string]::Join(',',$result)}}
"DRS Faults" = &{$result = $cluster.Extensiondata.drsFault | %{$_.Reason};if($result){[string]::Join(',',$result)}}
"Migration Threshold" = $cluster.Extensiondata.ConfigurationEx.DrsConfig.VmotionRate
"target hosts load standard deviation" = "NA"
"Current host load standard deviation" = "NA"
"Total Physical Memory (MB)" = ($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum
"Configured Memory MB" = ($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum
"Available Memroy (MB)" = ($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum
"Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
"Configured CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
"Available CPU (Mhz)" = ($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum
"Total Disk Space (MB)" = ($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum
"Configured Disk Space (MB)" = ($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum
"Available Disk Space (MB)" = ($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum
"CPU Total Capacity" = $rp.Runtime.Cpu.MaxUsage
"CPU Reserved Capacity" = $rp.Runtime.Cpu.ReservationUsed
"CPU Available Capacity" = $rp.Runtime.Cpu.MaxUsage - $rp.Runtime.Cpu.ReservationUsed
"Memory Total Capacity" = $rp.Runtime.Memory.MaxUsage
"Memory Reserved Capacity" = $rp.Runtime.Memory.ReservationUsed
"Memory Available Capacity" = $rp.Runtime.Memory.MaxUsage - $rp.Runtime.Memory.ReservationUsed
}
}
 
$report | Export-Csv "C:\Cluster-Report.csv" -NoTypeInformation -UseCulture
 
###########Define Variables########
 
$fromaddress = "vcenter@tayfundeger.com"
$toaddress = "tayfun@tayfundeger.com, info@tayfundeger.com"
# $bccaddress = "bcc@tayfundeger.com"
$CCaddress = "cc@tayfundeger.com"
$Subject = "Cluster Utilizasyon Raporu"
$body = "Cluster utilizasyon raporuna ekteki dosyadan ulasabilirsiniz..."
$attachment = "C:\Cluster-Report.csv"
$smtpserver = "SMTP-IP-Adresi"
 
####################################
 
$message = new-object System.Net.Mail.MailMessage
$message.From = $fromaddress
$message.To.Add($toaddress)
$message.CC.Add($CCaddress)
# $message.Bcc.Add($bccaddress)
$message.IsBodyHtml = $True
$message.Subject = $Subject
$attach = new-object Net.Mail.Attachment($attachment)
$message.Attachments.Add($attach)
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)
 
Disconnect-VIServer vCenter-IP -Confirm:$false
