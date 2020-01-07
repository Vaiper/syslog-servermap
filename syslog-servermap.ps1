

#Map DC to log server:
 
$servermap = @{
 
    "DC1" = "tcp://syslog01.v-crew.int:514,tcp://syslog02.v-crew.int:514";
    "DC2" = "tcp://syslog03.v-crew.int:514,tcp://syslog04.v-crew.int:514";
    "DC3" = "tcp://syslog05.v-crew.int:514,tcp://syslog06.v-crew.int:514";
 
};
 
  
 
foreach ($vmhost in (Get-VMHost)) {
 
    $DC = (Get-Datacenter -VMHost $vmhost)
 
    echo $vmhost.Name 
 
    echo $servermap.($DC.Name)
 

    $syslog = $servermap.($DC.Name)
 
    Get-AdvancedSetting -Entity $vmhost -Name "SysLog.Global.loghost" | Set-AdvancedSetting -Value $syslog -Confirm:$false
 
    Write-Host "Restarting syslog daemon." -ForegroundColor Green
 
    $esxcli = Get-EsxCli -VMHost $vmhost -V2
 
    $esxcli.system.syslog.reload.Invoke()
 
    Write-Host "Setting firewall to allow Syslog out of $($vmhost)" -ForegroundColor Green
 
    Get-VMHostFirewallException -VMHost $vmhost | where {$_.name -eq 'syslog'} | Set-VMHostFirewallException -Enabled:$true
 
}
