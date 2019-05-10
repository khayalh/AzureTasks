Configuration Main
{

    Param ( [string] $nodeName,
        [string]$certfilelocation,
        [string] $Thumbprint,
        [PSCredential]$certcredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName xCertificate
    
    Node $AllNodes.NodeName {

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
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = "[WindowsFeature]IIS"
        }
        xPfxImport ImportPfxCert {
            Thumbprint = "$Thumbprint"
            Path       = "C:\Cert\selfsignedcert.pfx"
            Credential = $certcredential
            Location   = 'LocalMachine'
            Store      = "WebHosting"
            DependsOn  = '[xRemoteFile]DownloadPackage'
        }
        # Create the new Website with HTTP
        xWebsite NewWebsite {
            Ensure       = "Present"
            Name         = "iissrv.westeurope.cloudapp.azure.com"
            State        = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = @("[WindowsFeature]IIS", "[xPfxImport]ImportPfxCert")
            BindingInfo  = MSFT_xWebBindingInformation {
                Protocol              = "https"
                Port                  = 443
                HostName              = "iissrv.westeurope.cloudapp.azure.com"
                CertificateThumbprint = "$Thumbprint"
                CertificateStoreName  = "WebHosting"
            }
        }
        LocalConfigurationManager {
            CertificateId = "$Thumbprint"
        }
    }
}