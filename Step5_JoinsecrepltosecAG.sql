--Join the secondary replicas to the secondary Availability Group
--Run this on the secondary replicas of the secondary Availability Group 
:CONNECT MSSQLAZ2\INSTA1
ALTER AVAILABILITY GROUP [AG_DC2] JOIN

--Allow the Availability Group to create databases on behalf of the primary replica
ALTER AVAILABILITY GROUP [AG_DC2] GRANT CREATE ANY DATABASE
GO