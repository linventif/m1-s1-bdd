-- ========================================================
-- POPULATION SCRIPT FOR SAMPLE DATA
-- ========================================================

-- EMPLOYE
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Employe (PrenomE, TelE, NomE)
      VALUES (
         'Prenom_' || i,
         '06' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(10000000,99999999))),
         'Nom_' || i
      );
   END LOOP;
   COMMIT;
END;
/
w
-- CLIENT
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Client (NomC, PrenomC, RueC, CPC, VilleC, DepC, NbKm)
      VALUES (
         'NomC_' || i,
         'PrenomC_' || i,
         'Rue du Client ' || i,
         TO_CHAR(ROUND(DBMS_RANDOM.VALUE(59000,59999))),
         'Ville_' || i,
         'Dep_' || MOD(i, 10),
         ROUND(DBMS_RANDOM.VALUE(1, 200))
      );
   END LOOP;
   COMMIT;
END;
/

-- URGENCE
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Urgence (NomU)
      VALUES ('Urgence_' || i);
   END LOOP;
   COMMIT;
END;
/

-- FORMATION
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Formation (NomF)
      VALUES ('Formation_' || i);
   END LOOP;
   COMMIT;
END;
/

-- QUALIF
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Qualif (DateDebQ, DateFinQ, CodeF)
      VALUES (
         SYSDATE - ROUND(DBMS_RANDOM.VALUE(100, 300)),
         SYSDATE - ROUND(DBMS_RANDOM.VALUE(1, 99)),
         MOD(i, 50) + 1
      );
   END LOOP;
   COMMIT;
END;
/

-- INTERVENTION
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Intervention (NomI, MontantChequeClient, TarifPublicI, TarifKmI, CodeU)
      VALUES (
         'Intervention_' || i,
         ROUND(DBMS_RANDOM.VALUE(50, 200), 2),
         ROUND(DBMS_RANDOM.VALUE(50, 150), 2),
         ROUND(DBMS_RANDOM.VALUE(0.5, 2.5), 2),
         MOD(i, 50) + 1
      );
   END LOOP;
   COMMIT;
END;
/

-- PLANIFIER_I
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Planifier_I (CodeE, CodeC, CodeI, DateI, HeureI)
      VALUES (
         MOD(i, 50) + 1,
         MOD(i + 5, 50) + 1,
         MOD(i + 10, 50) + 1,
         SYSDATE + i,
         NUMTODSINTERVAL(MOD(i, 24), 'HOUR')
      );
   END LOOP;
   COMMIT;
END;
/

-- QUALIFIER
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Qualifier (CodeE, CodeI, CodeQ)
      VALUES (
         MOD(i, 50) + 1,
         MOD(i + 3, 50) + 1,
         MOD(i + 6, 50) + 1
      );
   END LOOP;
   COMMIT;
END;
/

-- COUTER_I
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Couter_I (CodeI, DateDebT, HeureDebT, Tarif)
      VALUES (
         MOD(i, 50) + 1,
         SYSDATE + i,
         NUMTODSINTERVAL(MOD(i, 24), 'HOUR'),
         ROUND(DBMS_RANDOM.VALUE(80, 250), 2)
      );
   END LOOP;
   COMMIT;
END;
/

-- COUTER_U
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Couter_U (CodeU, DateDebT, HeureDebT, Tarif)
      VALUES (
         MOD(i, 50) + 1,
         SYSDATE + i,
         NUMTODSINTERVAL(MOD(i, 24), 'HOUR'),
         ROUND(DBMS_RANDOM.VALUE(100, 300), 2)
      );
   END LOOP;
   COMMIT;
END;
/

-- EFFECTUER_I
BEGIN
   FOR i IN 1..50 LOOP
      INSERT INTO Effectuer_I (CodeE, CodeC, CodeI, DateI, HeureI, DureeI)
      VALUES (
         MOD(i, 50) + 1,
         MOD(i + 2, 50) + 1,
         MOD(i + 5, 50) + 1,
         SYSDATE + i,
