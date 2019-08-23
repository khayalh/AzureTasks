Configuration Main
{

    Param ( [string] $nodeName,
        [string] $certfilelocation,
        [string] $Thumbprint,
        [PSCredential]$certcredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xCertificate
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName xNetworking


    Node $AllNodes.NodeName
    {
        xFirewall HTTPRule { 
            Name        = "Firewall Rule for HTTP" 
            DisplayName = "Firewall Rule for HTTP" 
            Ensure      = "Present" 
            Enabled     = $true
            Profile     = ("Public", "Private") 
            Direction   = "Inbound" 
            LocalPort   = 80          
            Protocol    = "TCP" 
            Description = "Firewall Rule for HTTP"   
        }
        xFirewall HTTPSRule { 
            Name        = "Firewall Rule for HTTPS" 
            DisplayName = "Firewall Rule for HTTPS" 
            Ensure      = "Present" 
            Enabled     = $true
            Profile     = ("Public", "Private") 
            Direction   = "Inbound" 
            LocalPort   = 443          
            Protocol    = "TCP" 
            Description = "Firewall Rule for HTTPS"   
        }
        WindowsFeature InstallWebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        WindowsFeature WebManagementConsole {
            Name   = "Web-Mgmt-Console"
            Ensure = "Present"
        }
        WindowsFeature WebManagementService {
            Name   = "Web-Mgmt-Service"
            Ensure = "Present"
        }
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
        xPfxImport ImportPfxCert {
            Thumbprint = "$Thumbprint"
            Path       = "C:\Cert\selfsignedcert.pfx"
            Credential = $certcredential
            Location   = 'LocalMachine'
            Store      = "WebHosting"
            DependsOn  = '[xRemoteFile]DownloadPackage'
        }
        # Create the new Website with HTTP and HTTPS
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = @("[WindowsFeature]InstallWebServer", "[xPfxImport]ImportPfxCert")
            BindingInfo  = @(
                MSFT_xWebBindingInformation {
                    Protocol              = "HTTPS"
                    Port                  = 443
                    HostName              = "*"
                    CertificateThumbprint = "$Thumbprint"
                    CertificateStoreName  = "WebHosting"
                }
                MSFT_xWebBindingInformation {
                    Protocol = "HTTP" 
                    Port     = 80
                    HostName = "*"
                }
            )
        }
        LocalConfigurationManager {
            CertificateId = "$Thumbprint"
        }
    }
}