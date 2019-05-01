Configuration Main
{

    Param ( [string] $nodeName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    WindowsFeature IIS
    {
        Ensure          = "Present"
        Name            = "Web-Server"
    }
    WindowsFeature Management {
 
        Name = 'Web-Mgmt-Service'
        Ensure = 'Present'
        DependsOn = @('[WindowsFeature]IIS')
    }
    Registry RemoteManagement {
        Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
        ValueName = 'EnableRemoteManagement'
        ValueType = 'Dword'
        ValueData = '1'
        DependsOn = @('[WindowsFeature]IIS','[WindowsFeature]Management')
   }
   Service StartWMSVC {
        Name = 'WMSVC'
        StartupType = 'Automatic'
        State = 'Running'
        DependsOn = '[Registry]RemoteManagement'
   }
    # Stop the default website
    xWebsite DefaultSite
    {
        Ensure          = "Present"
        Name            = "Default Web Site"
        State           = "Stopped"
        PhysicalPath    = "C:\inetpub\wwwroot"
        DependsOn       = "[WindowsFeature]IIS"
    }
    # Create the new Website with HTTP
    xWebsite NewWebsite
    {
        Ensure          = "Present"
        Name            = "webtestsite"
        State           = "Started"
        PhysicalPath    = "C:\inetpub\wwwroot"
        DependsOn       = "[WindowsFeature]IIS"
        BindingInfo     = @(
            MSFT_xWebBindingInformation
            {
                Protocol              = "HTTP"
                Port                  = 8080
            }
            MSFT_xWebBindingInformation
            {
                Protocol              = "HTTP"
                Port                  = 8081
            }
        )
    }
}