param (
    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$location,
    [Parameter(Mandatory=$true)]
    [string]$storageAccountName,
    [Parameter(Mandatory=$true)]
    [string]$containerName,
    [Parameter(Mandatory=$true)]
    [string]$folderForUpload
)
# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a storage account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName "Standard_LRS"

$context = $storageAccount.Context

# Create a container
New-AzStorageContainer -Name $containerName -Context $context

# Upload folder
ls -Recurse -Path $folderForUpload | Set-AzStorageBlobContent -Container $containerName -Context $context -Force