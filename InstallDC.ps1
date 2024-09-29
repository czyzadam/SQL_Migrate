# Set Ip
New-NetIPAddress -InterfaceAlias "Ethernet 4" -IPAddress "192.168.0.44" -PrefixLength 24 -DefaultGateway "192.168.0.1"

# configure DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("192.168.0.2", "168.63.127.16")

# Sysprep
C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /reboot

# Disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Change name
Rename-Computer -NewName "DC1" -Force -Restart


# Install AD roles
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Create Forest
Install-ADDSForest -DomainName "adam.local" -DomainNetbiosName "ADAM" -ForestMode "Default" -DomainMode "Default" -InstallDns -NoRebootOnCompletion -Force

# Restart
Restart-Computer

# Import ad module 
Import-Module ActiveDirectory

# Create SQL OU
New-ADOrganizationalUnit -Name "SQLCluster" -Path "DC=adam,DC=local"

#Create group and service account
New-ADGroup -Name "sqladmins" -GroupScope Global -GroupCategory Security -Path "OU=SQLCluster,DC=adam,DC=local"
New-ADUser -Name "sqlsvc" -GivenName "SQL" -Surname "Service" -SamAccountName "sqlsvc" -UserPrincipalName "sqlsvc@adam.local" -Path "OU=SQLCluster,DC=adam,DC=local" -AccountPassword (ConvertTo-SecureString "Kopytko123!" -AsPlainText -Force) -Enabled $true

#add acounts to SQL admins group
Add-ADGroupMember -Identity "sqladmins" -Members "sqlsvc"
Add-ADGroupMember -Identity "sqladmins" -Members "adam"

# Define the OU path
$ouPath = "CN=Computers,DC=adam,DC=local"  # Replace with your actual OU path

# Create computer accounts
New-ADComputer -Name "DC1_WFC" -Path $ouPath
New-ADComputer -Name "DC2_WFC" -Path $ouPath

