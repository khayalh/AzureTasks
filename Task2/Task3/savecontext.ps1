param (
    [Parameter(Mandatory = $true)]
    [string]$azurecontextjsonfilepath
)
Save-AzureRmContext -Profile (Connect-AzureRmAccount) -path $azurecontextjsonfilepath
Import-AzureRmContext -Path $azurecontextjsonfilepath