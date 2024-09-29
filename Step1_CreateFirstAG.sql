-- 1. Create the primary Availability Group (AG_DC1) with a corresponding listener name (AG_DC1_LISTENER)
-- 2. Create the Availability Group endpoint on all the replicas in the secondary Availability Group
-- 3. Create login and grant the SQL Server service account CONNECT permissions to the endpoint
-- 4. Create the secondary Availability Group (AG_DC2) with a corresponding listener name (AG_DC2_LISTENER)
-- 5. Join the secondary replicas to the secondary Availability Group
-- 6. Create Distributed Availability Group (DistAG_DC1_DC2) on the primary Availability Group (AG_DC1)
-- 7. Join the secondary Availability Group (AG_DC2) to the Distributed Availability Group

--- Create Availiability group in DC1
--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.

:Connect MSSQL1\INSTA1

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END

GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [ADAM\sqlsvc]

GO

:Connect MSSQL1\INSTA1

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect MSSQL2\INSTA1

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [ADAM\sqlsvc]

GO

:Connect MSSQL2\INSTA1

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect MSSQL1\INSTA1

USE [master]

GO

CREATE AVAILABILITY GROUP [AG_DC1]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE)
FOR DATABASE [WideWorldImporters]
REPLICA ON N'MSSQL1\INSTA1' WITH (ENDPOINT_URL = N'TCP://MSSQL1.adam.local:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
	N'MSSQL2\INSTA1' WITH (ENDPOINT_URL = N'TCP://MSSQL2.adam.local:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));

GO

:Connect MSSQL1\INSTA1

USE [master]

GO

ALTER AVAILABILITY GROUP [AG_DC1]
ADD LISTENER N'AG_DC1_LISTENER' (
WITH IP
((N'10.0.0.102', N'255.255.255.0'),
(N'10.0.1.102', N'255.255.255.0')
)
, PORT=1433);

GO

:Connect MSSQL2\INSTA1

ALTER AVAILABILITY GROUP [AG_DC1] JOIN;

GO

ALTER AVAILABILITY GROUP [AG_DC1] GRANT CREATE ANY DATABASE;

GO


GO


