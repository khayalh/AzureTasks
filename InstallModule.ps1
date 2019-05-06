$Modules = @('xStorage', 'xNetworking', 'xPSDesiredStateConfiguration', 'ComputerManagementDsc', 'xWebAdministration', 'xCertificate')
foreach ($Module in $Modules) {
    Install-Module $Module -Force
}