## DATASTORE PROVISONING REPORT ##
## Composed by Tayfun Değer##
## mailto:tayfundeger@gmail.com
## https://www.tayfundeger.com ##
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
######################################## HTML Markup ###################################
$PageBoxOpener=”<div id=’box1’>”
$ReportVMs=”<div id=’boxheader’>Datastore Raporu</div>”
$Report=”<table><tr><th>VM Name</th><th>PowerState</th><th>vHardware</th><th>vCPU Count</th><th>vMTools version</th><th>vCPU </th><th>vMemory (MB)</th><th>Provisioned Disk Size(GB)</th><th>Used Disk Size (GB)</th><th>Guest OS</th><th>IP Address</th></tr>”
$BoxContentOpener=”<div id=’boxcontent’>”
$PageBoxCloser=”</div>”
$br=”<br>”
$ReportGetVmCluster=”<div id=’boxheader’></div>”
######################### End HTML Markup ##############################################
############ Powershel'e gerekli Vmware Modullerini yukle & vCenter'a baglan ##########
Get-Module -Name VMware* -ListAvailable | Import-Module
Import-Module VMware.VimAutomation.Core
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Connect-VIServer VCENTER-IP -User USER-YAZIN -Password PASSWORD-YAZIN
########### Ana kod ####################################################################
get-datastore | select-object name,
@{Label=”FreespaceGB”;E={“{0:n2}” -f ($_.FreespaceGB)}}, CapacityGB,
@{N='Freespace%';E={[math]::Round($_.FreespaceGB/$_.CapacityGB*100,1)}},
@{Label=”Provisioned VM's Size(GB)”;E={“{0:n2}” -f ($_.CapacityGB – $_.FreespaceGB +($_.extensiondata.summary.uncommitted/1GB))}},
@{N='VM';E={$_.ExtensionData.VM.Count}} | sort name | ConvertTo-HTML -Title “Virtualization Management – Datastore Provisioning Report” -Head “<div id=’title’> Virtualization Management – Datastore Provisioning Report</div>$br<div id=’subtitle’>Report Date $(Get-Date)</div>” -Body ” $Css $PageBoxOpener $ReportClusterStats $BoxContentOpener</table> $br $ReportGetVmCluster $BoxContentOpener $GetVmCluster $PageBoxCloser” | Out-File c:\datastores.html
########### Mail Degiskenleri ##########################################################
$fromaddress = "vcenter@tayfundeger.com"
$toaddress = "to@tayfundeger.com"
$CCaddress = "cc@tayfundeger.com"
$Subject = "Virtualization Management – Datastore Provisioning Report"
$body = "Datastorelarinin kapasite durumlari ekteki gibidir."
$attachment = "c:\datastores.html"
$smtpserver = "SMTP-IP-ADRESİ"
############ E-mail Gonder ############################################################
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
######### Disconnect vCenter & Finish script ###########################################
Disconnect-VIServer localhost -Confirm:$False
 
exit
