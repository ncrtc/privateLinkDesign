$virtualNetowrk = New-AzVirtualNetwork -Name 'vnet-dns-t-01' -ResourceGroupName 'rg-dns-core-01' -Location 'East US 2' -AddressPrefix '10.0.0.0/16'

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name default `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name vms `
  -AddressPrefix 10.0.1.0/24 `
  -VirtualNetwork $virtualNetwork

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name AzureBastionSubnet `
  -AddressPrefix 10.0.2.0/24 `
  -VirtualNetwork $virtualNetwork

$virtualNetwork | Set-AzVirtualNetwork

$publicip = New-AzPublicIpAddress -ResourceGroupName 'rg-dns-core-01' -name "pip-azbastion" -location "eastus2" -AllocationMethod Static -Sku Standard

$bastion = New-AzBastion -ResourceGroupName 'rg-dns-core-01' -Name "ab-01" -PublicIpAddress $publicip -VirtualNetworkName'vnet-dns-t-01' -VirtualNetworkRgName 'rg-dns-core-01'