#Map DC to log server:
$servermap = @{
"DEHAM01-LAB" = "tcp://log.sjt-consulting.int:514";
"DEHAM01-LAB2" = "tcp://dXXXXt:514";
"DEHAM01-LAB3" = "tcp://jXXXXX.int:514";
     
};
​
foreach ($vmhost in (Get-VMHost)) {
    $DC = (Get-Datacenter -VMHost $vmhost)
    echo $vmhost.Name 
    echo $servermap.($DC.Name)
    #Assign log server to host:
    #Set-VMHostSysLogServer -SysLogServer $servermap.($DC.Name) -SysLogServerPort 514 -VMHost $vmhost
    #$syslog = "`""+$servermap.($DC.Name)+"`""
    $syslog = $servermap.($DC.Name)
    #Set-VMHostSysLogServer -SysLogServer $syslog -SysLogServerPort 514 -VMHost $vmhost
    Get-AdvancedSetting -Entity $vmhost -Name "SysLog.Global.loghost" | Set-AdvancedSetting -Value $syslog -Confirm:$false
    Write-Host "Restarting syslog daemon." -ForegroundColor Green
    $esxcli = Get-EsxCli -VMHost $vmhost -V2
    $esxcli.system.syslog.reload.Invoke()
    Write-Host "Setting firewall to allow Syslog out of $($vmhost)" -ForegroundColor Green
    Get-VMHostFirewallException -VMHost $vmhost | where {$_.name -eq 'syslog'} | Set-VMHostFirewallException -Enabled:$true
}
