--Create login and grant CONNECT permissions to the SQL Server service account
USE master
GO

CREATE LOGIN [ADAM\sqlsvc] FROM WINDOWS;
GO

GRANT CONNECT ON ENDPOINT::Hadr_endpoint 
TO [ADAM\sqlsvc];  
GO