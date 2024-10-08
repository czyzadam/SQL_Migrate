#https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-vm-create-powershell-quickstart?view=azuresql

Connect-AzAccount
Set-AzContext -subscription "4bfade5e-64eb-4d29-ba2e-933a6612bd5c"

# Create Resource Group
$ResourceGroupName = "SQLAuto"
$Location = "Sweden Central"
$ResourceGroupParams = @{
   Name = $ResourceGroupName
   Location = $Location
   }
New-AzResourceGroup @ResourceGroupParams


# Network settings
$SubnetName = $ResourceGroupName + "subnet"
$VnetName = $ResourceGroupName + "vnet"
$PipName = $ResourceGroupName + $(Get-Random)

# Create a subnet configuration
$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 192.168.1.0/24

# Create a virtual network
$Vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location `
   -Name $VnetName -AddressPrefix 192.168.0.0/16 -Subnet $SubnetConfig

Create a public IP address and specify a DNS name
$Pip = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location `
  -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name $PipName



# network security group
# Rule to allow remote desktop (RDP)
$NsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "RDPRule" -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

#Rule to allow SQL Server connections on port 1433
$NsgRuleSQL = New-AzNetworkSecurityRuleConfig -Name "MSSQLRule"  -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433 -Access Allow

# Create the network security group
$NsgName = $ResourceGroupName + "nsg"
$Nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name $NsgName -SecurityRules $NsgRuleRDP,$NsgRuleSQL


# Netowrk interface 
$InterfaceName = $ResourceGroupName + "int"
$Interface = New-AzNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $Pip.Id -NetworkSecurityGroupId $Nsg.Id


# Define a credential object
$userName = "adam"
$SecurePassword = ConvertTo-SecureString 'Rowerek123!@#' `
   -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($userName, $securePassword)

# Create a virtual machine configuration
$VMName = $ResourceGroupName + "VM"
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize Standard_B2ms |
   Set-AzVMOperatingSystem -Windows -ComputerName $VMName -Credential $Cred -ProvisionVMAgent -EnableAutoUpdate |
   Set-AzVMSourceImage -PublisherName "MicrosoftSQLServer" -Offer "SQL2016SP2-WS2016" -Skus "enterprisedbengineonly-gen2" -Version "latest" |
   Add-AzVMNetworkInterface -Id $Interface.Id

# Create the VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig

# Register the SQL IaaS Agent extension to your subscription
#Register-AzResourceProvider -ProviderNamespace Microsoft.SqlVirtualMachine

#$License = 'PAYG'

# Register SQL Server VM with the extension
#New-AzSqlVM -Name $VMName -ResourceGroupName $ResourceGroupName -Location $Location -LicenseType $License

