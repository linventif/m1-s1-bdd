-- Create TP2 user
DECLARE
  user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO user_exists FROM dba_users WHERE username = 'TP1';
  IF user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER tp2 IDENTIFIED BY tp2';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO tp2';
    EXECUTE IMMEDIATE 'ALTER USER tp2 QUOTA UNLIMITED ON USERS';
  END IF;
END;
/

-- Switch to tp2
CONNECT tp2/tp2@//localhost:1521/BDD

-- Create schema
@/tp-002/create_db.sql

-- Insert data
WHENEVER SQLERROR CONTINUE
@/tp-002/insert_data.sql

EXIT;
