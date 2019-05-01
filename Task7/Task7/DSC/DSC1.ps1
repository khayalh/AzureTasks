Configuration Main
{

    Param ( [string] $nodeName,
        [string] $SolrScriptFile 
    )

    Import-DscResource -ModuleName xStorage
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    
    xFirewall Firewall 
    { 
        Name                  = "SlaveVMFirewallRule" 
        DisplayName           = "Firewall Rule for SlaveVM" 
        Ensure                = "Present" 
        Enabled               = $true
        Profile               = ("Public", "Private") 
        Direction             = "Inbound" 
        LocalPort             = 8983          
        Protocol              = "TCP" 
        Description           = "Firewall Rule for SlaveVM"   
    } 
    xWaitforDisk Disk2 {
        DiskIdType = 'Number'
        DiskId = 2
        RetryIntervalSec = 60
        RetryCount = 60
    }
    xDisk F {
        DiskId = 2
        DiskIdType = 'Number'
        DriveLetter = 'F'
        FSLabel = 'Data'
        FSFormat = 'NTFS'
        ClearDisk = $true
        DependsOn = "[xWaitForDisk]Disk2"
    }
    xWaitForVolume F {
        DriveLetter = 'F'
        RetryIntervalSec = 5
        RetryCount = 10
    }
    xRemoteFile SolrScript {
        Uri             = $SolrScriptFile
        DestinationPath = "F:\solrservicerun.ps1"
    }
    ScheduledTask SolrServiceScheduled {
        TaskName           = 'SolrServiceRun'
        ActionExecutable   = "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
        ActionArguments    = "-File `"F:\solrservicerun.ps1`""
        ScheduleType       = 'AtStartup'
        RepeatInterval     = '00:15:00'
        RepetitionDuration = 'Indefinitely'
        WakeToRun          = $true 
        DependsOn       = "[xRemoteFile]SolrScript"
    }
}