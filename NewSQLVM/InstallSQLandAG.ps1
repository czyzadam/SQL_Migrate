$domain = "adam.local"
$username = "cmfadmin"
$password = "Kopytko123!"  # Use a secure method to handle passwords in production
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

Add-Computer -DomainName $domain -Credential $credential -Restart


# Map the network drive
New-PSDrive -Name Y -PSProvider FileSystem -Root \\192.168.0.1\ISO -Persist

#mount disk on S:
Mount-DiskImage -ImagePath "Y:\SQLServer2016SP2-FullSlipstream-x64-ENU.iso"

# Define the SQL folder paths
$folders = @(
    "C:\SQL\MSSQL\BACKUP",
    "C:\SQL\MSSQL\DATA",
    "C:\SQL\MSSQL\LOGS"
)

# Create the folders
foreach ($folder in $folders) {
    # Create the directory if it doesn't exist
    if (-not (Test-Path -Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force
        Write-Host "Created folder: $folder"
    } else {
        Write-Host "Folder already exists: $folder"
    }
}

# Add Perrmissions to SQL servcie account

# Define the folder path
$folderPath = "C:\SQL"

# Get the current ACL
$acl = Get-Acl $folderPath

# Define the permission
$permission = "ADAM\sqlsvc","FullControl","Allow"  # Use the correct format based on your environment

# Create the access rule
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission

# Set the access rule
$acl.SetAccessRule($accessRule)

# Apply the modified ACL back to the folder
Set-Acl -Path $folderPath -AclObject $acl

# Create ini file 
# Define the path for the .ini file
$iniFilePath = "C:\SQL\setup.ini"

# Define the content of the .ini file
$iniContent = @"
; SQL Server Installation Configuration File

[OPTIONS]
ACTION="Install"
FEATURES="SQLEngine,FullText"
INSTANCENAME="INSTA1"
SQLSVCACCOUNT="ADAM\sqlsvc"
SQLSVCPASSWORD="Kopytko123!"
SQLSYSADMINACCOUNTS="sqladmins"
AGTSVCACCOUNT="ADAM\sqlsvc"
AGTSVCPASSWORD="Kopytko123!"
AGTSVCSTARTUPTYPE="Automatic"
TCPENABLED="1"
SQLSVCINSTANTFILEINIT="True"
INSTALLSQLDATADIR="C:\Program Files\Microsoft SQL Server"
SQLBACKUPDIR="C:\SQL\MSSQL1\Backup"
SQLUSERDBDIR="C:\SQL\MSSQL1\DATA"
SQLUSERDBLOGDIR="C:\SQL\MSSQL\LOGS"
IACCEPTSQLSERVERLICENSETERMS="True"
"@

# Create the .ini file and write the content to it
Set-Content -Path $iniFilePath -Value $iniContent

# Output a message indicating the file has been created
Write-Host "SQL Server unattended installation .ini file created at: $iniFilePath"


# Install MSSQL server 
#E:\setup.exe /qs /ACTION=Install /FEATURES=SQLEngine,FullText /INSTANCENAME='INSTA1' /SQLSVCACCOUNT='sqlsvc@adam.local' /SQLSVCPASSWORD='Kopytko123!' /SQLSYSADMINACCOUNTS='sqladmins' /AGTSVCACCOUNT='sqlsvc@adam.local' /AGTSVCPASSWORD='Kopytko123!' /AGTSVCSTARTUPTYPE=Automatic /TCPENABLED=1 /SQLSVCINSTANTFILEINIT=True /INSTALLSQLDATADIR='C:\Program Files\Microsoft SQL Server' /SQLBACKUPDIR='C:\SQL\MSSQL1\Backup' /SQLUSERDBDIR='C:\SQL\MSSQL1\DATA' /SQLUSERDBLOGDIR='C:\SQL\MSSQL\LOGS' /IACCEPTSQLSERVERLICENSETERM='True'
E:\setup.exe /qs /CONFIGURATIONFILE="C:\SQL\setup.ini"

# Read server names from the text file


# Define the list of servers
$servers = @("WinSrv01", "WinSrv02", "WinSrv03", "WinSrv04")

# Install Failover Clustering feature on remote servers
Invoke-Command -ComputerName $servers -ScriptBlock {
    Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
}

Invoke-Command -ComputerName $servers -ScriptBlock {
    Test-Cluster -Node $using:servers
}


## Create onprem cluster 
New-Cluster –Name DC1_WFC –StaticAddress 192.168.0.101 –Node WinSrv01,WinSrv02

## Create Azure cluster
New-Cluster –Name DC2_WFC –StaticAddress 192.168.0.102 –Node WinSrv03,WinSrv04

# Set quorum
Set-ClusterQuorum -FileShareWitness "\\DC1\QUORUM\DC1_WFC"
Set-ClusterQuorum -FileShareWitness "\\DC1\QUORUM\DC2_WFC"


# enable Always On for the SQL instance on each node
$ServerInstance = 'WinSrv01\INSTA1' 
Enable-SqlAlwaysOn -ServerInstance $ServerInstance -Force
$ServerInstance = 'WinSrv02\INSTA1'
Enable-SqlAlwaysOn -ServerInstance $ServerInstance -Force
$ServerInstance = 'WinSrv03\INSTA1'
Enable-SqlAlwaysOn -ServerInstance $ServerInstance -Force
$ServerInstance = 'WinSrv04\INSTA1'
Enable-SqlAlwaysOn -ServerInstance $ServerInstance -Force
