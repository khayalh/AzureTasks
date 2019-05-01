Configuration Main
{

    Param ( [string] $nodeName,
            [string] $tempFileLocation            
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    File ArtifactsFolder {
        Type            = "Directory"
        DestinationPath = "C:\Shell"
        Ensure          = "Present"
    }   

    xRemoteFile DownloadPackage {            	
      DestinationPath = "C:\Shell\myscript.ps1"
      Uri             = $tempFileLocation
      MatchSource     = $true
    }
}