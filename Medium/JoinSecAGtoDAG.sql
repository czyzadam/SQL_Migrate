ALTER AVAILABILITY GROUP [DBADistributedAG]  
  JOIN
  AVAILABILITY GROUP ON  
  'AG_DC1' WITH   
   (  
     LISTENER_URL = 'tcp://dbadaglistener1.adam.local:5022',   
     AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,  
     FAILOVER_MODE = MANUAL,  
     SEEDING_MODE = AUTOMATIC
    ),  
  'AG_DC2' WITH   
    (  
     LISTENER_URL = 'tcp://dbadaglistener2.adam.local:5022',  
     AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,  
     FAILOVER_MODE = MANUAL,  
     SEEDING_MODE = AUTOMATIC
    );