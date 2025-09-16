# TP / CM de BDD

## Créer un user: 

### Connection a la bdd

```bash
docker exec -it oracle_m1_s1_bdd sqlplus system/root@//localhost:1521/BDD
```

### Créer le user

```sql
SQL> CREATE USER tp1 IDENTIFIED BY tp1;                      

User created.

SQL> GRANT CONNECT, RESOURCE TO tp1;

Grant succeeded.

SQL> ALTER USER tp1 QUOTA UNLIMITED ON USERS;

User altered.
     
SQL> EXIT

```

### Tester le user 

```bash
docker exec -it oracle_m1_s1_bdd sqlplus user/user@//localhost:1521/BDD
```