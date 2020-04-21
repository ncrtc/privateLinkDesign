[CmdletBinding()]
param(
    $rg_prefix = "rg-dns-service-",
    $aarg = "rg-vse-central-services",
    $VMName_prefix = "vmdns",
    $aaName = "tjs-aa-01",
    $VMSize = "Standard_D4s_v3",
    $LocationName = "EastUS2"
)

$offset = (Get-Date | select -expand millisecond) * (Get-date | select -expand hour) * (get-date | select -ExpandProperty year) # generate a random sequence of characters

$rg = $rg_prefix + $offset
$VMName = $VMName_prefix + $offset

$SubnetId = Get-AzVirtualNetwork -Name vnet-dns-t-01 -ResourceGroupName rg-dns-core-01 | Get-AzVirtualNetworkSubnetConfig -Name vms | select -ExpandProperty ID

$Credential = New-Object System.Management.Automation.PSCredential ("tjs", (ConvertTo-SecureString "Insecure12341234!" -AsPlainText -Force));

New-AzResourceGroup -Name $rg -Location $LocationName

$NIC = New-AzNetworkInterface -Name "nic-$VMName" -ResourceGroupName $rg -Location $LocationName -SubnetId $SubnetId

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest

New-AzVM -ResourceGroupName $rg -Location $LocationName -VM $VirtualMachine -Verbose

Register-AzAutomationDscNode -AutomationAccountName $aaName -AzureVMName $VMName -ResourceGroupName $aarg -NodeConfigurationName "StandaloneDnsConditionalForwarderConfig.localhost" -RebootNodeIfNeeded $true -AzureVMResourceGroup $rg -AzureVMLocation $LocationName