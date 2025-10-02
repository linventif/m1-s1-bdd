-- Create TP1 user
DECLARE
  user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO user_exists FROM dba_users WHERE username = 'TP1';
  IF user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER tp1 IDENTIFIED BY tp1';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO tp1';
    EXECUTE IMMEDIATE 'ALTER USER tp1 QUOTA UNLIMITED ON USERS';
  END IF;
END;
/

-- Switch to tp1
CONNECT tp1/tp1@//localhost:1521/BDD

-- Create schema
@/tp-001/create_db.sql

-- Insert data
WHENEVER SQLERROR CONTINUE
@/tp-002/insert_data.sql

EXIT;
