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
        WindowsFeature HTTPRedirection {
            Name   = "Web-Http-Redirect"
            Ensure = "Present"
        }
        Package UrlRewrite {
            Ensure    = "Present"
            Name      = "IIS URL Rewrite Module 2"
            Path      = "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
            ProductId = "08F0318A-D113-4CF0-993E-50F191D397AD"
            DependsOn = "[WindowsFeature]InstallWebServer"
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