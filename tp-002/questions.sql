/*
-- create_hotels_schema.sql
-- Schéma Oracle pour la BD "Les Hôtels"
-- Conçu pour SQL*Plus

SET FEEDBACK OFF
SET DEFINE OFF

-- Suppression sûre des tables (si elles existent)
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Reserver CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Proposer CASCADE CONSTRAINTS PURGE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Client CASCADE CONSTRAINTS PURGE';   EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Hotel CASCADE CONSTRAINTS PURGE';    EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TypeCH CASCADE CONSTRAINTS PURGE';   EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Societe CASCADE CONSTRAINTS PURGE';  EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Groupe CASCADE CONSTRAINTS PURGE';   EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -942 THEN RAISE; END IF; END; /

-- Table SOCIETE
CREATE TABLE Societe (
  CodeSoc    NUMBER(6)    CONSTRAINT pk_societe PRIMARY KEY,
  RaisonSoc  VARCHAR2(100) NOT NULL,
  RueSoc     VARCHAR2(120),
  CpSoc      VARCHAR2(10),
  VilleSoc   VARCHAR2(80),
  DomaineSoc VARCHAR2(80)
);

-- Table CLIENT
CREATE TABLE Client (
  CodeC         NUMBER(6)    CONSTRAINT pk_client PRIMARY KEY,
  CivC          VARCHAR2(5)  CONSTRAINT ck_client_civ CHECK (CivC IN ('M','Mme')),
  NomC          VARCHAR2(80) NOT NULL,
  PrenomC       VARCHAR2(80) NOT NULL,
  RueFacC       VARCHAR2(120),
  CPostalFacC   VARCHAR2(10),
  VilleFacC     VARCHAR2(80),
  CodeSoc       NUMBER(6),
  CONSTRAINT fk_client_soc FOREIGN KEY (CodeSoc) REFERENCES Societe(CodeSoc)
);

-- Table GROUPE HOTELIER
CREATE TABLE Groupe (
  CodeGR        NUMBER(6)    CONSTRAINT pk_groupe PRIMARY KEY,
  NomGR         VARCHAR2(100) NOT NULL,
  PaysOrigineGR VARCHAR2(60)  NOT NULL
);

-- Table HOTEL
CREATE TABLE Hotel (
  CodeH       NUMBER(6)    CONSTRAINT pk_hotel PRIMARY KEY,
  NomH        VARCHAR2(120) NOT NULL,
  RueH        VARCHAR2(120),
  CPH         VARCHAR2(10),
  VilleH      VARCHAR2(80),
  PaysH       VARCHAR2(60),
  NbetoilesH  NUMBER(1)     CONSTRAINT ck_hotel_etoiles CHECK (NbetoilesH BETWEEN 1 AND 5),
  CodeGR      NUMBER(6),
  CONSTRAINT fk_hotel_groupe FOREIGN KEY (CodeGR) REFERENCES Groupe(CodeGR)
);

-- Table TYPE DE CHAMBRE
CREATE TABLE TypeCH (
  CodeTyCH   NUMBER(6)     CONSTRAINT pk_typech PRIMARY KEY,
  NomTyCH    VARCHAR2(80)  NOT NULL
);

-- Table PROPOSER (offre de chambres par type & hôtel)
CREATE TABLE Proposer (
  CodeH       NUMBER(6) NOT NULL,
  CodeTyCH    NUMBER(6) NOT NULL,
  NbChambres  NUMBER(4) CONSTRAINT ck_prop_nb CHECK (NbChambres >= 0),
  CONSTRAINT pk_proposer PRIMARY KEY (CodeH, CodeTyCH),
  CONSTRAINT fk_prop_hotel FOREIGN KEY (CodeH) REFERENCES Hotel(CodeH),
  CONSTRAINT fk_prop_type  FOREIGN KEY (CodeTyCH) REFERENCES TypeCH(CodeTyCH)
);

-- Table RESERVER
CREATE TABLE Reserver (
  CodeC      NUMBER(6) NOT NULL,
  CodeH      NUMBER(6) NOT NULL,
  CodeTyCH   NUMBER(6) NOT NULL,
  DateArr    DATE      NOT NULL,
  DateDep    DATE      NOT NULL,
  NombreCH   NUMBER(3) CONSTRAINT ck_res_nb CHECK (NombreCH > 0),
  CONSTRAINT pk_reserver PRIMARY KEY (CodeC, CodeH, CodeTyCH, DateArr),
  CONSTRAINT fk_res_client FOREIGN KEY (CodeC)    REFERENCES Client(CodeC),
  CONSTRAINT fk_res_hotel  FOREIGN KEY (CodeH)    REFERENCES Hotel(CodeH),
  CONSTRAINT fk_res_type   FOREIGN KEY (CodeTyCH) REFERENCES TypeCH(CodeTyCH),
  CONSTRAINT ck_res_dates  CHECK (DateDep > DateArr)
);

-- Fini
PROMPT Schéma créé.

-- 1. Pour chaque client, donner sa civilité en clair (Monsieur ou Madame), son nom, son prénom et
 */
-- éventuellement le nom et le domaine de sa société
SELECT cl.CIVC, cl.NomC, cl.PrenomC, so.RaisonSoc, so.DomaineSoc
FROM CLIENT cl, SOCIETE so
WHERE cl.CodeSoc = so.CodeSoc (+);
-- 2. Nom des sociétés ayant effectué au moins une réservation débutant cette année
SELECT DISTINCT so.RAISONSOC
FROM SOCIETE so, RESERVER re, CLIENT cl
WHERE to_char(re.DATEARR, 'YYYY') = to_char(current_date, 'YYYY')
AND re.CODEC = cl.CODEC
AND cl.CODESOC = so.CODESOC

-- 3. Nom des sociétés ayant effectué dix réservations débutant cette année
SELECT so.RAISONSOC, COUNT(re.CODEC)
FROM SOCIETE so, RESERVER re, CLIENT cl
WHERE to_char(re.DATEARR, 'YYYY') = to_char(current_date, 'YYYY')
AND re.CODEC = cl.CODEC
AND cl.CODESOC = so.CODESOC
HAVING COUNT(re.CODEC) >= 10
GROUP BY so.RAISONSOC;
-- 4. Nom des sociétés n’ayant effectué aucune réservation en 2018 (arrivées et départs en 2018)
SELECT so.RAISONSOC
FROM SOCIETE so
WHERE NOT EXISTS(
    SELECT *
    FROM RESERVER re, CLIENT cl
    WHERE re.CODEC = cl.CODEC
    AND cl.CODESOC = so.CODESOC
    AND ( to_char(re.DATEARR, 'YYYY') = '2018'
    OR   to_char(re.DATEDEP, 'YYYY') = '2018')
    )
;
-- 5. Nom des sociétés ayant effectué toutes réservations débutant cette année
-- 6. Nom des sociétés n’ayant effectué que des réservations cette année (arrivée et départ cette année)
-- 7. Nom et prénom des clients ayant effectué une réservation de 2 nuits
-- 8. Nom et prénom des clients ayant effectué deux réservations en 2019 (ne pas se limiter à une arrivée
-- et un départ cette année)

-- 16. Nom des sociétés ayant réservé le séjour le plus long
SELECT re.DATEDEP - re.DATEARR as duree, so.RAISONSOC
FROM RESERVER re, CLIENT cl, SOCIETE so
WHERE so.CODESOC = cl.CODESOC
AND re.CODEC = cl.CODEC
ORDER BY duree DESC

-- 17. Nom des sociétés ayant réservé le séjour le plus court dans la ville de la société
SELECT re.DATEDEP - re.DATEARR as duree, so.RAISONSOC
FROM RESERVER re, CLIENT cl, SOCIETE so, HOTEL ho
WHERE so.CODESOC = cl.CODESOC
AND re.CODEC = cl.CODEC
AND re.CODEH = ho.CODEH
AND so.VILLESOC = ho.VILLEH
ORDER BY duree ASC;

-- 26. Nom des groupes hôteliers proposant uniquement des hôtels 2 et 3 étoiles
SELECT gp.NomGR
FROM GROUPE gp
WHERE NOT EXISTS(
    SELECT *
    FROM HOTEL ho
    WHERE ho.CODEGR = gp.CODEGR
    AND ho.NBETOILESH != 3 AND ho.NBETOILESH != 2
AND EXISTS (
    SELECT *
    FROM HOTEL ho
    WHERE ho.CODEGR = gp.CODEGR
    ));

-- 32
SELECT ho.NOMH
FROM HOTEL ho, PROPOSER pr
WHERE ho.CODEH = pr.CODEH
AND NOT EXISTS (
    SELECT *
    FROM RESERVER re
    WHERE ho.CODEH = re.CODEH
    AND pr.CODETYCH != re.CODETYCH
)



-- 34
SELECT ho.NomH
FROM HOTEL ho, RESERVER re, TYPECH ty
WHERE re.CodeH = ho.CodeH
AND NOT EXISTS (
    SELECT *
    FROM Proposer pr
    WHERE ho.CodeH = pr.CodeH
    AND pr.CODETYCH = re.CODETYCH
)

-- 35 Pour chaque groupe hôtelier, donner son nom, le nombre d’hôtels, le nombre de types de chambres
-- proposés et le nombre de clients ayant effectué des réservations durant les 10 dernières années
SELECT gp.NOMGR, ho.NOMH, tc.type_count, hc.hotel_count, rc.resa_count
FROM HOTEL ho, GROUPE gp
, (
    SELECT gp.CODEGR, COUNT(ho.CODEH) AS hotel_count
    FROM GROUPE gp, HOTEL ho
    WHERE ho.CODEGR = gp.CODEGR
    GROUP BY gp.CODEGR
    ORDER BY hotel_count DESC
) hc, (
    SELECT ho.CODEH, COUNT(pr.CODETYCH) AS type_count
    FROM HOTEL ho, PROPOSER pr
    WHERE ho.CodeH = pr.CodeH
    GROUP BY ho.CodeH
    ORDER BY type_count DESC
) tc, (
    SELECT ho.CODEH, COUNT(re.CodeH) AS resa_count
    FROM HOTEL ho, RESERVER re
    WHERE (to_number(to_char(re.DateDep, 'YYYY')) > to_number(to_char(CURRENT_DATE, 'YYYY')) - 10)
    AND re.CODEH = ho.CODEH
    GROUP BY ho.CODEH
) rc
WHERE ho.CODEGR = gp.CODEGR
AND hc.CODEGR = ho.CODEGR
AND tc.CODEH = ho.CODEH
AND rc.CODEH = ho.CODEH
ORDER BY gp.NOMGR;


SELECT
    gp.NomGR,
    COUNT(DISTINCT ho.CodeH) AS nb_hotels,
    COUNT(DISTINCT pr.CodeTyCH) AS nb_types_chambres,
    COUNT(DISTINCT re.CodeC) AS nb_clients_10ans
FROM GROUPE gp, HOTEL ho, PROPOSER pr, RESERVER re
WHERE ho.CodeGR(+) = gp.CodeGR
  AND pr.CodeH(+) = ho.CodeH
  AND re.CodeH(+) = ho.CodeH
  AND re.DateDep(+) > ADD_MONTHS(TRUNC(CURRENT_DATE), -120)
GROUP BY gp.NomGR
ORDER BY gp.NomGR;



SELECT DISTINCT gp.CODEGR, gp.NOMGR, COUNT(ho.CodeH) as hotel_count
FROM RESERVER re, CLIENT cl, GROUPE gp, HOTEL ho
WHERE re.DateDep > ADD_MONTHS(TRUNC(CURRENT_DATE), -120)
AND re.CODEC = cl.CODEC
AND gp.CODEGR = ho.CODEGR
AND ho.CODEH = re.CODEH
GROUP BY gp.CODEGR, gp.NOMGR
ORDER BY hotel_count DESC;



-- 19 Nom des sociétés ayant réservé tous les types de chambres
SELECT COUNT(re.CODETYCH)
FROM SOCIETE so, CLIENT cl, RESERVER re, TYPECH tc
WHERE cl.CODESOC = so.CODESOC
AND re.CODEC = cl.CODEC
AND tc.CODETYCH = re.CODETYCH;


SELECT so.CODESOC, tc.CODETYCH, so.RAISONSOC
FROM TYPECH tc, CLIENT cl, RESERVER re, SOCIETE so
WHERE cl.CODESOC = so.CODESOC
AND re.CODEC = cl.CODEC
AND tc.CODETYCH = re.CODETYCH

SELECT *
FROM SOCIETE so
WHERE NOT EXISTS (
    SELECT *
    FROM TYPECH tc, CLIENT cl, RESERVER re
    WHERE cl.CODESOC = so.CODESOC
    AND re.CODEC = cl.CODEC
    AND tc.CODETYCH = re.CODETYCH
);


SELECT tc.CODETYCH, so.RAISONSOC
FROM SOCIETE so, CLIENT cl, RESERVER re, TYPECH tc
WHERE cl.CODESOC = so.CODESOC
AND re.CODEC = cl.CODEC
AND tc.CODETYCH = re.CODETYCH



SELECT c.CodeC, c.NomC
FROM Client c
WHERE EXISTS (
    SELECT 1
    FROM Reserver r
    WHERE r.CodeC = c.CodeC
);




SELECT *
FROM CLIENT cl, RESERVER re, TYPECH ty
WHERE



--     help me to understant exist & not exist
DROP TABLE test_a PURGE;
CREATE TABLE test_a (
    id_a NUMBER PRIMARY KEY,
    val_a VARCHAR2(20)
);

DROP TABLE test_b PURGE;
CREATE TABLE test_b (
    id_b NUMBER PRIMARY KEY,
    val_b VARCHAR2(20)
);


DROP TABLE test_c PURGE;
CREATE TABLE test_c (
    id_b NUMBER PRIMARY KEY,
    val_b VARCHAR2(20)
);

INSERT INTO test_a (id_a, val_a) VALUES (1, 'A1');
INSERT INTO test_a (id_a, val_a) VALUES (2, 'A2');
INSERT INTO test_a (id_a, val_a) VALUES (3, 'A3');

INSERT INTO test_b (id_b, val_b) VALUES (1, 'B1');
INSERT INTO test_b (id_b, val_b) VALUES (2, 'B2');
INSERT INTO test_b (id_b, val_b) VALUES (4, 'B4');

INSERT INTO test_c (id_b, val_b) VALUES (1, 'C1');
INSERT INTO test_c (id_b, val_b) VALUES (2, 'C2');

SELECT * FROM test_a;

SELECT * FROM test_b;

-- 1. Select all records from test_a where there is a matching record in test_b
SELECT *
FROM test_a a
WHERE EXISTS (
    SELECT 1
    FROM test_b b
    WHERE a.id_a = b.id_b
);

SELECT *
FROM test_a a
WHERE NOT EXISTS (
    SELECT b.id_b
    FROM test_b b
    WHERE a.id_a = b.id_b
);


SELECT a.id_a
FROM test_b b, test_a a
WHERE a.id_a = b.id_b

-- make sure all of c exit in c with double not exist
SELECT *
FROM test_a a
WHERE NOT EXISTS (
    SELECT 1
    FROM test_c c
    WHERE NOT EXISTS (
        SELECT 1
        FROM test_b b
        WHERE b.id_b = c.id_b
        AND b.id_b = a.id_a
    )
);






-- 19 Nom des sociétés ayant réservé tous les types de chambres
SELECT *
FROM SOCIETE so
WHERE NOT EXISTS (
    SELECT *
    FROM RESERVER re
    WHERE NOT EXISTS (
        FROM 
    )
)

INSERT INTO Reserver (CodeC, CodeH, CodeTyCH, DateArr, DateDep, NombreCH) VALUES (2, 24, 12, TO_DATE('2025-06-06','YYYY-MM-DD'), TO_DATE('2025-06-14','YYYY-MM-DD'), 4);

-- 20
SELECT *
FROM CLIENT cl
WHERE cl.CODEC = (
    SELECT  cl.CODEC, re.CODETYCH, COUNT(*)
    FROM CLIENT cl, RESERVER re
    WHERE cl.CODEC = re.CODEC
    GROUP BY cl.CODEC, re.CODETYCH
)






