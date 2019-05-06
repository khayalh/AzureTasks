$Modules = @('xStorage', 'xNetworking', 'xPSDesiredStateConfiguration', 'ComputerManagementDsc')
foreach ($Module in $Modules) {
    Install-Module $Module -Force
}