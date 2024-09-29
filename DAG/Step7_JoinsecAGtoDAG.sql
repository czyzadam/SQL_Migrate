--Create second availability group on second failover cluster with replicas and listener
--Run this on the primary replica of the secondary Availability Group
:CONNECT WINSRV03\INSTA1
ALTER AVAILABILITY GROUP [DistAG_DC1_DC2]   
JOIN   
AVAILABILITY GROUP ON  
'AG_DC1' WITH    
(   
   LISTENER_URL = 'TCP://AG_DC1_LISTENER.ADAM.LOCAL:5022',    
   AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
   FAILOVER_MODE = MANUAL,   
   SEEDING_MODE = AUTOMATIC   
),   
'AG_DC2' WITH    
(   
   LISTENER_URL = 'TCP://AG_DC2_LISTENER.ADAM.LOCAL:5022',   
   AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,   
   FAILOVER_MODE = MANUAL,   
   SEEDING_MODE = AUTOMATIC   
);    
GO     
   