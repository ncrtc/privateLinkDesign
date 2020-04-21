[cmdletbinding()]
param(
  $ResourceGroup = 'rg-dns-core-01',
  $Location = 'East US 2', 
  $VirtualNetworkName = 'vnet-dns-t-01'
)

try {
  get-azresourcegroup -ResourceGroupName $ResourceGroup -ErrorAction Stop
} catch {
  New-AzResourceGroup -Name $ResourceGroup -Location $Location
}

$virtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName  $ResourceGroup -Location $Location -AddressPrefix '10.0.0.0/16'

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

$publicip = New-AzPublicIpAddress -ResourceGroupName  $ResourceGroup -name "pip-azbastion" -location $Location -AllocationMethod Static -Sku Standard

$bastion = New-AzBastion -ResourceGroupName  $ResourceGroup -Name "ab-01" -PublicIpAddress $publicip -VirtualNetworkName $VirtualNetworkName -VirtualNetworkRgName $ResourceGroup