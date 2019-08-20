param(
    [string]$RG1,
    [string]$RG2,
    [string]$Location,
    [string]$VNGName1,
    [string]$VNGName2,
    [string]$Connection1,
    [string]$Connection2,
    [securestring]$SharedKey
)

$vnet1gw = Get-AzureRMVirtualNetworkGateway -Name $VNGName1 -ResourceGroupName $RG1
$vnet2gw = Get-AzureRMVirtualNetworkGateway -Name $VNGName2 -ResourceGroupName $RG2
New-AzureRMVirtualNetworkGatewayConnection `
    -Name $Connection1 `
    -ResourceGroupName $RG1 `
    -VirtualNetworkGateway1 $vnet1gw `
    -VirtualNetworkGateway2 $vnet2gw `
    -Location $Location `
    -ConnectionType Vnet2Vnet `
    -SharedKey $SharedKey
New-AzureRMVirtualNetworkGatewayConnection `
    -Name $Connection2 `
    -ResourceGroupName $RG2 `
    -VirtualNetworkGateway1 $vnet2gw `
    -VirtualNetworkGateway2 $vnet1gw `
    -Location $Location `
    -ConnectionType Vnet2Vnet `
    -SharedKey $SharedKey