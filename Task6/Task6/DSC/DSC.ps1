Configuration Main
{

    Param ( [string] $nodeName,
        [string]$certfilelocation,
        [securestring]$pfxpass="certpass"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    # Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Find-Module -Name xPSDesiredStateConfiguration | Install-Module
    # Import-DscResource -ModuleName xWebAdministration
    Find-Module -Name xWebAdministration | Install-Module
    # Import-DscResource -ModuleName xCertificate
    Find-Module -Name xCertificate | Install-Module

    File ArtifactsFolder {
        Type            = "Directory"
        DestinationPath = "C:\Cert"
        Ensure          = "Present"
    }   
    xRemoteFile DownloadPackage {            	
        DestinationPath = "C:\Cert\selfsignedcert.pfx"
        Uri             = $certfilelocation
        MatchSource     = $true
        DependsOn       = "[File]ArtifactsFolder" 
    }
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
    xPfxImport ImportPfxCert
    {
    Thumbprint = 'FB7E2DBDA1D2F41A63273C684DFA92D2699AC6EB'
    Path = 'C:\Cert\selfsignedcert.pfx'
    Credential = $pfxpass
    Location = 'LocalMachine'
    Store = "My"
    DependsOn = '[WindowsFeature]IIS'

    }
    # Create the new Website with HTTP
    xWebsite NewWebsite
    {
        Ensure          = "Present"
        Name            = "iissrv.westeurope.cloudapp.azure.com"
        State           = "Started"
        PhysicalPath    = "C:\inetpub\wwwroot"
        DependsOn       = "[WindowsFeature]IIS",'[xPfxImport]ImportPfxCert'
        BindingInfo     = @(
            MSFT_xWebBindingInformation
            {
                Protocol              = "https"
                Port                  = 443
                HostName              = "iissrv.westeurope.cloudapp.azure.com"
                CertificateThumbprint = "FB7E2DBDA1D2F41A63273C684DFA92D2699AC6EB"
                CertificateStoreName  = "My"
            }
        )
    }
}