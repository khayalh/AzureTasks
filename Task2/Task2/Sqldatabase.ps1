param (
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$location,
    [Parameter(Mandatory = $true)]
    [string]$storageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$storageContainerName,    
    [Parameter(Mandatory = $true)]
    [string]$firstSqlServerName,
    [Parameter(Mandatory = $true)]
    [string]$secondSqlServerName,
    [Parameter(Mandatory = $true)]
    [string]$adminUsernameForSqlServer,
    [Parameter(Mandatory = $true)]
    [SecureString]$adminPasswordForSqlServer,
    [Parameter(Mandatory = $true)]
    [string]$sqlFirewallRuleName,
    [Parameter(Mandatory = $true)]
    [string]$firstSqlDatabaseName,
    [Parameter(Mandatory = $true)]
    [int]$firstSqlDatabaseCount,
    [Parameter(Mandatory = $true)]
    [string]$secondSqlDatabaseName,
    [Parameter(Mandatory = $true)]
    [int]$secondSqlDatabaseCount,
    [Parameter(Mandatory = $true)]
    [int]$exportedDatabaseNumber
)
#Saving context for auto login in Azure
Import-AzureRMContext -Path "C:\Scripts2\Task3\credentials.json"
#Select Azure Subscription
$subid = (Get-AzureRMSubscription).Id
Select-AzureRmSubscription -SubscriptionId $subid
#Creating Azure Resource Group
New-AzureRMResourceGroup `
    -Name $resourceGroupName `
    -Location $location
#Creating Azure Storage Account,Storage Container and context file. 
$storagectx = (New-AzureRMStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -SkuName "Standard_LRS" `
        -Location "eastus").Context
New-AzureStorageContainer `
    -Name $storageContainerName `
    -Context $storagectx 
#Creating Storage Uri for Blob Container
$storageuri = $storagectx.BlobEndPoint
#Converting admin password to secure string
$Pass = ConvertTo-SecureString `
    -String $adminPasswordForSqlServer `
    -AsPlainText -Force
#Creating new object and adding arguments
$Credentials = New-Object `
    -TypeName "System.Management.Automation.PSCredential" `
    -ArgumentList $adminUsernameForSqlServer, $Pass
#Getting Storage Account Key
$storageAccountKey = (Get-AzureRmStorageAccountKey `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName).Value[0]
#Creating New SQL Servers
New-AzureRMSqlServer `
    -ResourceGroupName $resourceGroupName `
    -ServerName $firstSqlServerName  `
    -Location $location `
    -ServerVersion "12.0" `
    -SqlAdministratorCredentials ($Credentials)
New-AzureRMSqlServer `
    -ResourceGroupName $resourceGroupName `
    -ServerName $secondSqlServerName `
    -Location $location `
    -ServerVersion "12.0" `
    -SqlAdministratorCredentials ($Credentials)
#Creating New SQL Firewall Rules
New-AzureRMSqlServerFirewallRule `
    -ResourceGroupName $resourceGroupName `
    -ServerName $firstSqlServerName `
    -FirewallRuleName $sqlFirewallRuleName `
    -StartIpAddress "0.0.0.0" `
    -EndIpAddress "0.0.0.0"
New-AzureRMSqlServerFirewallRule `
    -ResourceGroupName $resourceGroupName `
    -ServerName $secondSqlServerName `
    -FirewallRuleName $sqlFirewallRuleName `
    -StartIpAddress "0.0.0.0" `
    -EndIpAddress "0.0.0.0"
#Loop for creating SQL Databases
for ($i = 0; $i -lt $firstSqlDatabaseCount; $i++) {
    New-AzureRMSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $firstSqlServerName `
        -DatabaseName $("$firstSqlDatabaseName" + "$i")  `
        -Edition "Standard" `
        -RequestedServiceObjectiveName "S1"
}
for ($i = 0; $i -lt $secondSqlDatabaseCount; $i++) {
    New-AzureRMSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $secondSqlServerName `
        -DatabaseName $("$secondSqlDatabaseName" + "$i")  `
        -Edition "Standard" `
        -RequestedServiceObjectiveName "S1"
}
#Variable for getting database name
$exportedDataBase = (Get-AzureRmSqlDatabase `
        -ResourceGroupName $resourceGroupName `
        -ServerName $firstSqlServerName).DatabaseName[$exportedDatabaseNumber]
#Export Sql Database to Blob Container
$exportrequest = New-AzureRmSqlDatabaseExport `
    -ResourceGroupName $resourceGroupName `
    -ServerName $firstSqlServerName `
    -DatabaseName $exportedDataBase   `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $storageAccountKey `
    -StorageUri $("$storageuri" + "$storageContainerName/" + "$exportedDataBase.bacpac") `
    -AdministratorLogin $Credentials.UserName `
    -AdministratorLoginPassword $Credentials.Password
#Variable for requesting Export status of database
$exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportrequest.OperationStatusLink
#The purpose of this loop is to assign border between export and import function
[Console]::Write("Exporting")
while ($exportStatus.Status -eq "InProgress") {
    $exportStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 20
}
[Console]::WriteLine("")
Write-Host "$exportedDataBase Successfully Exported From $exportedSqlServerName"
#Import Sql Database to another SQL Server
$importrequest = New-AzureRmSqlDatabaseImport `
    -ResourceGroupName $resourceGroupName `
    -ServerName $secondSqlServerName `
    -DatabaseName $exportedDataBase `
    -DatabaseMaxSizeBytes "268435456000" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $storageAccountKey  `
    -StorageUri $("$storageuri" + "$storageContainerName/" + "$exportedDataBase.bacpac") `
    -Edition "Standard" `
    -ServiceObjectiveName "S1" `
    -AdministratorLogin $Credentials.UserName `
    -AdministratorLoginPassword $Credentials.Password
#Variable for requesting Import status of database
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importrequest.OperationStatusLink
[Console]::Write("Importing")
while ($importStatus.Status -eq "InProgress") {
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 20
}
[Console]::WriteLine("")
Write-Host "$exportedDataBase Successfully Imported To $secondSqlServerName"