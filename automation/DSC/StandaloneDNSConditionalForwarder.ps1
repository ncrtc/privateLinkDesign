configuration StandaloneDnsConditionalForwarderConfig
{
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xDnsServer'

    WindowsFeature DNS
    {
        Ensure  = 'Present'
        Name    = 'DNS'
        IncludeAllSubFeature = $true
    }

    WindowsFeature DNSMgmtTool
    {
        Ensure  = 'Present'
        Name    = 'RSAT-DNS-Server'
        IncludeAllSubFeature = $true
    }

    xDnsServerConditionalForwarder DBPrivateLinkToAzure
    {
        Ensure = 'Present'
        Name = 'database.windows.net'
        MasterServers = '168.63.129.16'
    }
}