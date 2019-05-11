Login-AzureRmAccount
$vm1vnet=Get-AzureRmVirtualNetwork -ResourceGroupName task8Rg1 -Name vmnetwork
$vm2vnet=Get-AzureRmVirtualNetwork -ResourceGroupName task8Rg2 -Name vm2VNET
Add-AzureRmVirtualNetworkPeering -Name "myVnet1ToMyVnet2" -VirtualNetwork $vm1vnet -RemoteVirtualNetworkId $vm2vnet.Id
Add-AzureRmVirtualNetworkPeering -Name "myVnet2ToMyVnet1" -VirtualNetwork $vm2vnet -RemoteVirtualNetworkId $vm1vnet.id