--Create endpoint on all Availability Group replicas
--Run this on the primary replica of the secondary Availability Group
:CONNECT WINSRV03\INSTA1
USE [master]
GO

CREATE ENDPOINT [Hadr_endpoint]
   STATE=STARTED
   AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
   FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE
      , ENCRYPTION = REQUIRED ALGORITHM AES)
GO

--Run this on the secondary replica of the secondary Availability Group-
:CONNECT WINSRV04\INSTA1
USE [master]
GO
CREATE ENDPOINT [Hadr_endpoint]
   STATE=STARTED
   AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
   FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE
       , ENCRYPTION = REQUIRED ALGORITHM AES)
GO  
   