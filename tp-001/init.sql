-- Create TP1 user
CREATE USER tp1 IDENTIFIED BY tp1;
GRANT CONNECT, RESOURCE TO tp1;
ALTER USER tp1 QUOTA UNLIMITED ON USERS;

-- Switch to tp1
CONNECT tp1/tp1@//localhost:1521/BDD

-- Create schema
@/scripts/create_db.sql

-- Insert data
WHENEVER SQLERROR CONTINUE
@/scripts/insert_data.sql

EXIT;
