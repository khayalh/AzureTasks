Configuration Main
{

    Param ( [string] $nodeName,
            [string] $tempFileLocation            
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    File ArtifactsFolder {
        Type            = "Directory"
        DestinationPath = "C:\Artifacts"
        Ensure          = "Present"
    }   

    xRemoteFile DownloadPackage {            	
      DestinationPath = "C:\Artifacts\artifacts.txt"
      Uri             = $tempFileLocation
      MatchSource     = $true
    }
}