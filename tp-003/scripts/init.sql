-- Create TP1 user
DECLARE
  user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO user_exists FROM dba_users WHERE username = 'TP3';
  IF user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER tp3 IDENTIFIED BY tp3';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO tp3';
    EXECUTE IMMEDIATE 'ALTER USER tp3 QUOTA UNLIMITED ON USERS';
  END IF;
END;
/

-- Switch to tp3
CONNECT tp3/tp3@//localhost:1521/BDD

-- Create schema
@/tp-003/scripts/create_db.sql

-- Insert data
WHENEVER SQLERROR CONTINUE
@/tp-003/scripts/insert_data.sql

EXIT;
