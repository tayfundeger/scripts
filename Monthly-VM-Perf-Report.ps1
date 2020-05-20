## VM Configuration Report ##
## Composed by Tayfun Deger##
## mailto:tayfundeger@gmail.com
## https://www.tayfundeger.com##
##########################################################################
# Style of the Report in Css
$Css=”<style>
body {
font-family: Verdana, sans-serif;
font-size: 14px;
color: #666666;
background: #FEFEFE;
}
#title{
color:#FF0000;
font-size: 30px;
font-weight: bold;
padding-top:25px;
margin-left:35px;
height: 50px;
}
#subtitle{
font-size: 11px;
margin-left:35px;
}
#main {
position:relative;
padding-top:10px;
padding-left:10px;
padding-bottom:10px;
padding-right:10px;
}
#box1{
position:absolute;
background: #F8F8F8;
border: 1px solid #DCDCDC;
margin-left:10px;
padding-top:10px;
padding-left:10px;
padding-bottom:10px;
padding-right:10px;
}
#boxheader{
font-family: Arial, sans-serif;
padding: 5px 20px;
position: relative;
z-index: 20;
display: block;
height: 30px;
color: #777;
text-shadow: 1px 1px 1px rgba(255,255,255,0.8);
line-height: 33px;
font-size: 19px;
background: #fff;
background: -moz-linear-gradient(top, #ffffff 1%, #eaeaea 100%);
background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ffffff), color-stop(100%,#eaeaea));
background: -webkit-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
background: -o-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
background: -ms-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
background: linear-gradient(top, #ffffff 1%,#eaeaea 100%);
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr=’#ffffff’, endColorstr=’#eaeaea’,GradientType=0 );
box-shadow:
0px 0px 0px 1px rgba(155,155,155,0.3),
1px 0px 0px 0px rgba(255,255,255,0.9) inset,
0px 2px 2px rgba(0,0,0,0.1);
}
 
table{
width:100%;
border-collapse:collapse;
}
table td, table th {
border:1px solid #FA5858;
padding:3px 7px 2px 7px;
}
table th {
text-align:left;
padding-top:5px;
padding-bottom:4px;
background-color:#FA5858;
color:#fff;
}
table tr.alt td {
color:#000;
background-color:#F5A9A9;
}
</style>”
# End the Style.
######################################## HTML Markup for SYM#############################
$PageBoxOpener=”<div id=’box1’>”
$ReportVMs=”<div id=’boxheader’>Aylık Sanal Sunucuları Performans Raporu</div>”
$Report=”<table><tr><th>VM Name</th><th>PowerState</th><th>vHardware</th><th>vCPU Count</th><th>vMtools version</th><th>vCPU </th><th>vMemory (MB)</th><th>Provisioned Disk Size(GB)</th><th>Used Disk Size (GB)</th><th>Guest OS</th><th>IP Address</th></tr>”
$BoxContentOpener=”<div id=’boxcontent’>”
$PageBoxCloser=”</div>”
$br=”<br>”
$ReportGetVmCluster=”<div id=’boxheader’></div>”
######################### End HTML Markup ##############################################
###### Import Required Modules & Connect vCenter Server with Credentials #
Get-Module -Name VMware* -ListAvailable | Import-Module
Import-Module VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Connect-VIServer VCENTER-IP -User VCENTER-USERNAME -Password VCENTER-PASSWORD
##### Ana kod #######
get-vm | select Name, PowerState,
@{l="Total Cpu Amount";e={$_.numcpu}},
@{N="CPU Monthly Average (%)"; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Average).Average),2)}},
@{N="CPU Monthly Peak (%)"; E={[Math]::Round((($_ | Get-Stat -Stat cpu.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)}},
@{l="Total Memory Amount (GB)";e={$_.MemoryGB}},
@{N="Memory Monthly Average(%)"; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Average).Average),2)}},
@{N="Memory Monthly Peak(%)"; E={[Math]::Round((($_ | Get-Stat -Stat mem.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Network Monthly Average(Kbps)"; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Average).Average),2)}},
@{N="Network Monthly Peak(Kbps)"; E={[Math]::Round((($_ | Get-Stat -Stat net.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)}},
@{N="Disk Monthly Average(KBps)"; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Average).Average),2)}},
@{N="Disk Monthly Peak(KBps)"; E={[Math]::Round((($_ | Get-Stat -Stat disk.usage.average -Start (get-date).Addmonths(-1) -Finish (get-date).AddDays(-1) | Measure-Object Value -Maximum).Maximum),2)}},
@{n="TotalHDSizeGB"; e={(Get-HardDisk -VM $_ | Measure-Object -Sum CapacityGB).Sum}},
@{N='Disk Partititons';E={((get-vm $_).extensiondata.Guest.Disk | Sort DiskPath | %{" $($_.DiskPath) $([math]::Round($_.Capacity /1024MB)) GB"}) -join ','}} | Sort-Object Name -Descending | ConvertTo-HTML -Title “Aylık VM Performans Raporu” -Head “<div id=’title’> Virtualization Management- Virtual Machine Performance Report</div>$br<div id=’subtitle’>Report Date $(Get-Date)</div>” -Body ” $Css $PageBoxOpener $ReportClusterStats $BoxContentOpener</table> $br $ReportGetVmCluster $BoxContentOpener $GetVmCluster $PageBoxCloser” | Out-File c:\monthly-Virtual_Machine_Performance_Report.html
##### Ana kod sonu #####
########### Mailing Variables ######## ################################
$fromaddress = "vcenter@tayfundeger.com"
$toaddress = "to@tayfundeger.com"
$CCaddress = "cc@tayfundeger.com"
$Subject = "Monthly Virtual Machine Performance Report"
$attachment = "c:\monthly-Virtual_Machine_Performance_Report.html"
$smtpserver = "SMTP-IP-ADRESI"
############ Send E-mail ############################################
$message = new-object System.Net.Mail.MailMessage
$message.From = $fromaddress
$message.To.Add($toaddress)
$message.CC.Add($CCaddress)
$message.IsBodyHtml = $True
$message.Subject = $Subject
$attach = new-object Net.Mail.Attachment($attachment)
$message.Attachments.Add($attach)
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)
######### Disconnect vCenter & Finish script ##########################
Disconnect-VIServer localhost -Confirm:$False
 
exit
