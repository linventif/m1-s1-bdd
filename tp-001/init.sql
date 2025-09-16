-- =========================================================
-- TP Oracle 23c Free - Schéma de travaux / devis / chantiers
-- Compatible SQL*Plus / DataGrip (JDBC)
-- =========================================================

-- Évite la substitution SQL*Plus avec &
SET DEFINE OFF;

-- 1) Nettoyage : drop toutes les tables du schéma courant
BEGIN
   FOR t IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/
PURGE RECYCLEBIN;
/

-- 2) DDL : création des tables (Oracle types + IDENTITY + CHECK)

-- Table VILLE
CREATE TABLE VILLE (
    CodeV      CHAR(5)       PRIMARY KEY,
    NomV       VARCHAR2(40)  NOT NULL,
    CodeDeptV  CHAR(3)       NOT NULL,
    RegionV    VARCHAR2(40)  NOT NULL
);

-- Table CHANTIER
CREATE TABLE CHANTIER (
    CodeCH     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RueCH      VARCHAR2(40)  NOT NULL,
    CodePostCH CHAR(5)       NOT NULL,
    CodeV      CHAR(5),
    CONSTRAINT fk_chantier_ville FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table GAMMETRAVAUX
CREATE TABLE GAMMETRAVAUX (
    idGA   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NomGA  VARCHAR2(40) NOT NULL
);

-- Table QUALIF
CREATE TABLE QUALIF (
    CodeQ    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NomQ     VARCHAR2(40) NOT NULL,
    NiveauQ  VARCHAR2(20) CHECK (NiveauQ IN ('BEP','CAP','Bac Pro','BTS','Ingénieur')) NOT NULL
);

-- Table ENTREPRISE
CREATE TABLE ENTREPRISE (
    N_Siret   CHAR(14)      PRIMARY KEY,
    RaisonSoc VARCHAR2(40)  NOT NULL,
    TypeSoc   VARCHAR2(5)   CHECK (TypeSoc IN ('SA','SARL','SCOP','EURL')) NOT NULL,
    GroupeSoc VARCHAR2(40),
    CodeV     CHAR(5),
    CONSTRAINT fk_entreprise_ville FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table DEVIS
CREATE TABLE DEVIS (
    CodeDE  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DateDe  DATE         NOT NULL,
    N_Siret CHAR(14),
    CodeCH  NUMBER,
    CONSTRAINT fk_devis_entreprise FOREIGN KEY (N_Siret) REFERENCES ENTREPRISE(N_Siret),
    CONSTRAINT fk_devis_chantier   FOREIGN KEY (CodeCH)  REFERENCES CHANTIER(CodeCH)
);

-- Table EMPLOYE
CREATE TABLE EMPLOYE (
    CodeE    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NomE     VARCHAR2(40) NOT NULL,
    PrenomE  VARCHAR2(40) NOT NULL,
    CodeQ    NUMBER,
    N_Siret  CHAR(14),
    CONSTRAINT fk_employe_qualif     FOREIGN KEY (CodeQ)   REFERENCES QUALIF(CodeQ),
    CONSTRAINT fk_employe_entreprise FOREIGN KEY (N_Siret) REFERENCES ENTREPRISE(N_Siret)
);

-- Table TYPETRAVAUX
CREATE TABLE TYPETRAVAUX (
    CodeTY               NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NomTY                VARCHAR2(40) NOT NULL,
    Tarif_Heure_Clt      NUMBER(10,2) NOT NULL,
    Tarif_Heure_Employe  NUMBER(10,2) NOT NULL,
    idGA                 NUMBER,
    CONSTRAINT fk_typetravaux_gamme FOREIGN KEY (idGA) REFERENCES GAMMETRAVAUX(idGA),
    CONSTRAINT ck_tarifs CHECK (Tarif_Heure_Clt > Tarif_Heure_Employe)
);

-- Table AUTORISER
CREATE TABLE AUTORISER (
    CodeQ  NUMBER NOT NULL,
    idGA   NUMBER NOT NULL,
    CONSTRAINT pk_autoriser PRIMARY KEY (CodeQ, idGA),
    CONSTRAINT fk_autoriser_q  FOREIGN KEY (CodeQ) REFERENCES QUALIF(CodeQ),
    CONSTRAINT fk_autoriser_ga FOREIGN KEY (idGA)  REFERENCES GAMMETRAVAUX(idGA)
);

-- Table COMPRENDRE
CREATE TABLE COMPRENDRE (
    CodeDE        NUMBER NOT NULL,
    CodeTY        NUMBER NOT NULL,
    NbHeuresPrev  NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_comprendre PRIMARY KEY (CodeDE, CodeTY),
    CONSTRAINT fk_comprendre_devis FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    CONSTRAINT fk_comprendre_ty    FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERHORSDEVIS
CREATE TABLE TRAVAILLERHORSDEVIS (
    CodeCH       NUMBER NOT NULL,
    CodeE        NUMBER NOT NULL,
    DateT        DATE   NOT NULL,
    CodeTY       NUMBER NOT NULL,
    NbHeureTrav  NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_travhd PRIMARY KEY (CodeCH, CodeE, DateT, CodeTY),
    CONSTRAINT fk_travhd_ch FOREIGN KEY (CodeCH) REFERENCES CHANTIER(CodeCH),
    CONSTRAINT fk_travhd_e  FOREIGN KEY (CodeE)  REFERENCES EMPLOYE(CodeE),
    CONSTRAINT fk_travhd_ty FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERDEVIS
CREATE TABLE TRAVAILLERDEVIS (
    CodeDE             NUMBER NOT NULL,
    CodeE              NUMBER NOT NULL,
    DateT              DATE   NOT NULL,
    CodeTY             NUMBER NOT NULL,
    NbHeureTravDEVIS   NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_travd PRIMARY KEY (CodeDE, CodeE, DateT, CodeTY),
    CONSTRAINT fk_travd_de FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    CONSTRAINT fk_travd_e  FOREIGN KEY (CodeE)  REFERENCES EMPLOYE(CodeE),
    CONSTRAINT fk_travd_ty FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- 3) Données (INSERT) - simples quotes, dates en TO_DATE, apostrophes doublées

-- VILLE
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('31000', 'Toulouse', '31', 'Occitanie');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('75000', 'Paris', '75', 'Île-de-France');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('13000', 'Marseille', '13', 'Provence-Alpes-Côte d''Azur');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('69000', 'Lyon', '69', 'Auvergne-Rhône-Alpes');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('06000', 'Nice', '06', 'Provence-Alpes-Côte d''Azur');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('44000', 'Nantes', '44', 'Pays de la Loire');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('67000', 'Strasbourg', '67', 'Grand Est');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('59000', 'Lille', '59', 'Hauts-de-France');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('33000', 'Bordeaux', '33', 'Nouvelle-Aquitaine');
INSERT INTO VILLE (CodeV, NomV, CodeDeptV, RegionV) VALUES
('31001', 'Blagnac', '31', 'Occitanie');

-- CHANTIER (CodeCH auto via IDENTITY -> 1..10)
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('12 Rue de la Paix', '31000', '31000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('34 Avenue des Champs', '75008', '75000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('56 Boulevard Saint-Michel', '13001', '13000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('78 Rue de la République', '69002', '69000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('90 Avenue Jean Médecin', '06000', '06000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('23 Rue de Nantes', '44000', '44000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('45 Place Kléber', '67000', '67000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('67 Rue Faidherbe', '59000', '59000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('89 Cours de l''Intendance', '33000', '33000');
INSERT INTO CHANTIER (RueCH, CodePostCH, CodeV) VALUES
('11 Rue des Artisans', '31700', '31001');

-- GAMMETRAVAUX (idGA -> 1..4)
INSERT INTO GAMMETRAVAUX (NomGA) VALUES ('Gros œuvre');
INSERT INTO GAMMETRAVAUX (NomGA) VALUES ('Second œuvre');
INSERT INTO GAMMETRAVAUX (NomGA) VALUES ('Aménagement');
INSERT INTO GAMMETRAVAUX (NomGA) VALUES ('Finition / Embellissement');

-- QUALIF (CodeQ -> 1..5)
INSERT INTO QUALIF (NomQ, NiveauQ) VALUES ('Maçon', 'Bac Pro');
INSERT INTO QUALIF (NomQ, NiveauQ) VALUES ('Électricien', 'BTS');
INSERT INTO QUALIF (NomQ, NiveauQ) VALUES ('Plombier', 'CAP');
INSERT INTO QUALIF (NomQ, NiveauQ) VALUES ('Menuisier', 'BEP');
INSERT INTO QUALIF (NomQ, NiveauQ) VALUES ('Ingénieur Civil', 'Ingénieur');

-- ENTREPRISE
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('12345678901234', 'Bati31', 'SARL', 'GroupeA', '31000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('23456789012345', 'Constructor', 'SA', 'GroupeB', '75000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('34567890123456', 'BuildIt', 'EURL', 'GroupeA', '13000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('45678901234567', 'RenovPlus', 'SCOP', 'GroupeC', '69000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('56789012345678', 'EcoBati', 'SARL', 'GroupeB', '06000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('67890123456789', 'UrbanConstruct', 'SA', 'GroupeA', '44000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('78901234567890', 'ProjectX', 'EURL', 'GroupeC', '67000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('89012345678901', 'BuildSmart', 'SCOP', 'GroupeB', '59000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('90123456789012', 'MegaBuild', 'SARL', 'GroupeA', '33000');
INSERT INTO ENTREPRISE (N_Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV) VALUES
('01234567890123', 'QuickConstruct', 'SA', 'GroupeC', '31001');

-- DEVIS (CodeDE auto -> 1..10)
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-01-15','YYYY-MM-DD'), '12345678901234', 1);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-02-20','YYYY-MM-DD'), '23456789012345', 2);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-03-10','YYYY-MM-DD'), '34567890123456', 3);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-04-05','YYYY-MM-DD'), '45678901234567', 4);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-05-15','YYYY-MM-DD'), '56789012345678', 5);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-06-25','YYYY-MM-DD'), '67890123456789', 6);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-07-30','YYYY-MM-DD'), '78901234567890', 7);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-08-12','YYYY-MM-DD'), '89012345678901', 8);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-09-18','YYYY-MM-DD'), '90123456789012', 9);
INSERT INTO DEVIS (DateDe, N_Siret, CodeCH) VALUES
(TO_DATE('2024-10-22','YYYY-MM-DD'), '01234567890123', 10);

-- EMPLOYE (CodeE auto -> 1..10)
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Dupont', 'Jean', 1, '12345678901234');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Martin', 'Claire', 2, '23456789012345');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Bernard', 'Luc', 3, '34567890123456');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Petit', 'Sophie', 4, '45678901234567');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Robert', 'Paul', 5, '56789012345678');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Richard', 'Emma', 1, '67890123456789');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Durand', 'Lucas', 2, '78901234567890');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Leroy', 'Chloé', 3, '89012345678901');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Moreau', 'Maxime', 4, '90123456789012');
INSERT INTO EMPLOYE (NomE, PrenomE, CodeQ, N_Siret) VALUES
('Simon', 'Julie', 5, '01234567890123');

-- TYPETRAVAUX (CodeTY auto -> 1..16) + idGA cohérent
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Terrassement & VRD',           100.00, 60.00, 1);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Maçonnerie',                     90.00, 55.00, 1);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Eléments de structure métalliques', 110.00, 70.00, 1);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Métallerie',                     95.00, 58.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Bois',                           85.00, 50.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Composite',                     120.00, 75.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Cloisonnement',                  80.00, 48.00, 3);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Faux plafond',                   75.00, 45.00, 3);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Revêtement de sol',              70.00, 42.00, 3);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Ventilation / Climatisation',   130.00, 80.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Électricité',                   115.00, 69.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Chaudronnerie',                 140.00, 110.00, 1);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Plomberie',                     105.00, 75.00, 2);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Menuiserie',                     95.00, 85.00, 4);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Mobilier',                      150.00, 120.00, 4);
INSERT INTO TYPETRAVAUX (NomTY, Tarif_Heure_Clt, Tarif_Heure_Employe, idGA) VALUES
('Plafonnage',                     65.00, 60.00, 4);

-- AUTORISER
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (1, 1);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (1, 2);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (2, 2);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (2, 4);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (3, 3);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (4, 4);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (5, 1);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (5, 2);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (5, 3);
INSERT INTO AUTORISER (CodeQ, idGA) VALUES (5, 4);

-- COMPRENDRE
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (1,  1, 100.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (1,  2, 150.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (2,  3, 200.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (2,  4, 120.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (3,  5,  80.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (3,  6,  90.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (4,  7, 110.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (4,  8, 130.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (5,  9, 140.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (5, 10, 160.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (6, 11, 170.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (6, 12, 180.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (7, 13, 190.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (7, 14, 200.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (8, 15, 210.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (8, 16, 220.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (9,  1, 230.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (9,  3, 240.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (10, 5, 250.00);
INSERT INTO COMPRENDRE (CodeDE, CodeTY, NbHeuresPrev) VALUES (10, 7, 260.00);

-- TRAVAILLERHORSDEVIS
INSERT INTO TRAVAILLERHORSDEVIS (CodeCH, CodeE, DateT, CodeTY, NbHeureTrav) VALUES
(1, 1,  TO_DATE('2022-01-16','YYYY-MM-DD'), 1,  8.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(1, 2,  TO_DATE('2023-01-16','YYYY-MM-DD'), 2,  6.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(2, 3,  TO_DATE('2024-02-21','YYYY-MM-DD'), 3,  7.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(2, 4,  TO_DATE('2022-02-21','YYYY-MM-DD'), 4,  5.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(3, 5,  TO_DATE('2023-03-11','YYYY-MM-DD'), 5,  9.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(3, 6,  TO_DATE('2025-03-11','YYYY-MM-DD'), 6,  4.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(4, 7,  TO_DATE('2022-04-06','YYYY-MM-DD'), 7,  8.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(4, 8,  TO_DATE('2023-04-06','YYYY-MM-DD'), 8,  6.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(5, 9,  TO_DATE('2024-05-16','YYYY-MM-DD'), 9,  7.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(5, 10, TO_DATE('2022-05-16','YYYY-MM-DD'), 10, 5.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(6, 1,  TO_DATE('2023-06-26','YYYY-MM-DD'), 11, 9.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(6, 2,  TO_DATE('2025-06-26','YYYY-MM-DD'), 12, 4.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(7, 3,  TO_DATE('2022-07-31','YYYY-MM-DD'), 13, 8.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(7, 4,  TO_DATE('2023-07-31','YYYY-MM-DD'), 14, 6.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(8, 5,  TO_DATE('2024-08-13','YYYY-MM-DD'), 15, 7.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(8, 6,  TO_DATE('2022-08-13','YYYY-MM-DD'), 16, 5.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(9, 7,  TO_DATE('2023-09-19','YYYY-MM-DD'), 1,  8.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(9, 8,  TO_DATE('2025-09-19','YYYY-MM-DD'), 3,  6.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(10, 9, TO_DATE('2022-10-23','YYYY-MM-DD'), 5,  7.00);
INSERT INTO TRAVAILLERHORSDEVIS VALUES
(10, 10, TO_DATE('2023-10-23','YYYY-MM-DD'), 7, 5.00);

-- TRAVAILLERDEVIS
INSERT INTO TRAVAILLERDEVIS (CodeDE, CodeE, DateT, CodeTY, NbHeureTravDEVIS) VALUES
(1, 1,  TO_DATE('2022-01-17','YYYY-MM-DD'), 1,  8.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(1, 2,  TO_DATE('2023-01-17','YYYY-MM-DD'), 2,  6.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(2, 3,  TO_DATE('2024-02-22','YYYY-MM-DD'), 3,  7.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(2, 4,  TO_DATE('2025-02-22','YYYY-MM-DD'), 4,  5.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(3, 5,  TO_DATE('2022-03-12','YYYY-MM-DD'), 5,  9.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(3, 6,  TO_DATE('2023-03-12','YYYY-MM-DD'), 6,  4.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(4, 7,  TO_DATE('2024-04-07','YYYY-MM-DD'), 7,  8.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(4, 8,  TO_DATE('2025-04-07','YYYY-MM-DD'), 8,  6.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(5, 9,  TO_DATE('2022-05-17','YYYY-MM-DD'), 9,  7.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(5, 10, TO_DATE('2023-05-17','YYYY-MM-DD'), 10, 5.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(6, 1,  TO_DATE('2024-06-27','YYYY-MM-DD'), 11, 9.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(6, 2,  TO_DATE('2025-06-27','YYYY-MM-DD'), 12, 4.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(7, 3,  TO_DATE('2022-08-01','YYYY-MM-DD'), 13, 8.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(7, 4,  TO_DATE('2023-08-01','YYYY-MM-DD'), 14, 6.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(8, 5,  TO_DATE('2024-08-14','YYYY-MM-DD'), 15, 7.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(8, 6,  TO_DATE('2025-08-14','YYYY-MM-DD'), 16, 5.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(9, 7,  TO_DATE('2022-09-20','YYYY-MM-DD'), 1,  8.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(9, 8,  TO_DATE('2023-09-20','YYYY-MM-DD'), 3,  6.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(10, 9, TO_DATE('2024-10-24','YYYY-MM-DD'), 5,  7.00);
INSERT INTO TRAVAILLERDEVIS VALUES
(10, 10, TO_DATE('2025-10-24','YYYY-MM-DD'), 7, 5.00);

COMMIT;

-- 1. Code et adresse postale complète (rue + ville) des chantiers
--     ayant fait intervenir des employés dans le cadre de devis
SELECT DISTINCT
    ch.CodeCH,
    ch.RueCH,
    ch.CodePostCH,
    v.NomV
FROM
    TRAVAILLERDEVIS td,
    DEVIS d,
    CHANTIER ch,
    VILLE v
WHERE
    d.CodeDE  = td.CodeDE
AND ch.CodeCH = d.CodeCH
AND v.CodeV   = ch.CodeV;


-- 2. Nom et Prénom des employés ayant un niveau d’étude supérieur au Bac (BTS ou ingénieur)
SELECT em.PRENOME, em.NOME
FROM QUALIF qu, EMPLOYE em
WHERE (qu.NIVEAUQ = 'BTS' OR qu.NIVEAUQ = 'Ingénieur') AND em.CodeQ = qu.CodeQ

-- 3. Codes des départements et noms des villes accueillant des entreprises et des chantiers
-- (classement par ordre « alphabétique » des départements et villes)
SELECT vi.CodeDeptV, vi.REGIONV
FROM CHANTIER ch, VILLE vi
WHERE ch.CodeV = vi.CodeV
ORDER BY RegionV ASC

-- 4. Nom des types de travaux dont le coût horaire employé représente plus de 80% du cout horaire client.
SELECT tt.NOMTY
FROM TYPETRAVAUX tt
WHERE tt.TARIF_HEURE_EMPLOYE > tt.Tarif_Heure_Clt * 0.8


-- 5. Nom des types de travaux ayant nécessité des réalisations hors devis cette année
SELECT tt.NOMTY
FROM TYPETRAVAUX tt, TRAVAILLERHORSDEVIS thd
WHERE tt.CODETY = thd.CODETY AND extract(YEAR FROM thd.DATET) = 2025

-- 6. Raison Sociale des entreprises ayant proposé des devis cette année dans les villes où elles sont implantées
SELECT en.RAISONSOC
FROM ENTREPRISE en, DEVIS de, CHANTIER ch
WHERE en.N_SIRET = de.N_Siret AND ch.CodeCH = de.CodeCH AND en.CODEV = ch.CODEV

-- 7. Pour chaque gamme de travaux, donner son nom et le nom des types de travaux associés s’il en possède
-- 8. Nom des gammes et des types de travaux rentables (types de travaux dont le gain entre le tarif horaire payé par le client et le tarif horaire payé aux employés est supérieur à 80% du tarif horaire employé) avec en-têtes
-- personnalisés et classement décroissant des rentabilités
-- 9. Nom des types de travaux rentables proposés ce mois-ci dans des devis
-- 10. Code et ville des chantiers ayant été réalisés avec des travaux répondant à des devis et des travaux hors devis
-- 11. Code et ville des chantiers n’ayant pas fait l’objet d’un devis
-- 12. Code et ville des chantiers n’ayant été réalisés qu’avec des travaux répondant à des devis
-- 13. Code des chantiers n’ayant pas fait l’objet de travaux
-- 14. Nom et prénom des employés ayant une qualification relative aux gammes Gros œuvre et second œuvre.
-- 15. Raison sociale et groupe des sociétés n’ayant proposé que des devis (aucun travail effectué)
-- 16. Code et date des devis ne proposant que du gros œuvre
-- 17. Code et date des devis proposant du gros œuvre et du second œuvre
-- 18. Tableau de bord contenant, le nom, le prénom et le nombre d’heures maximum réalisé dans une journée par un employé en réponse à un devis
-- 19. Tableau de bord contenant la raison sociale des sociétés et le Chiffre d’Affaire (CA) réalisé dans le cadre des devis (calculé en fonction des heures déclarées dans le devis), classement par ordre décroissant des CA © Franck RAVAT Page 5 sur 5
-- 20. Code et ville des chantiers totalisant plus de 1000 heures de travail effectué hors devis (classement par ordre décroissant du nombre d’heures)
-- 21. Tableau de bord permettant d’afficher le code des départements et le nombre de chantiers associés en se limitant aux départements possédant aux minimum 5 chantiers
-- 22. Nom des villes à prospecter : celles qui ne possède pas plus de 2 chantiers
-- 23. Donner le nom et le prénom des employés pouvant effectuer des travaux de toutes les gammes.
-- 24. Donner la raison sociale des entreprises de la Haute Garonne (département 31) proposant tous les types de travaux au travers de ses devis
-- 25. Code, date et CA prévisionnel du dernier devis (celui ayant le code le plus élevé)
-- 26. Raison sociale de l’entreprise ayant réalisé un CA prévisionnel supérieur à celui de Bati31
-- 27. Noms des villes possédant plus de chantiers que Toulouse
-- 28. Code et date du dernier devis émis par une SARL
-- 29. Pour chaque entreprise, donner sa raison sociale et son dernier devis (code et date et son Chiffre d’affaires prévisionnel)
-- 30. Donner le CA (Chiffre d"Affaire) prévisionnel moyen d"un devis
-- 31. Donner le nom de la gamme proposant un CA prévisionnel plus élevé que la gamme SOL
-- 32. Donner la raison sociale des entreprises ayant proposé le plus de devis
-- 33. Donner les coordonnées du chantier (code, rue, ville) ayant fait intervenir le plus d’employés cette année (dans le cadre des devis).
-- 34. Pour chaque chantier donner son code et son CA réalisé hors devis
-- 35. Pour chaque chantier, donner son code et son CA réalisé dans le cadre des devis
-- 36. Pour chaque chantier donner son CA total (en se limitant aux chantiers ayant des CA hors devis et des CA devis)
-- 37. Donner le nom des villes possédant le plus chantiers.
-- 38. Donner les noms des types de travaux ayant plus d’heures prévisionnelles totales que le type plomberie
-- 39. Nom et type de la société ayant effectué le plus d’heures hors devis cette année.
-- 40. Donner le nom et le prénom des employés ayant travaillé dans le cadre des devis sur tous les chantiers de la Haute Garonne (département 31) cette année.
-- 41. Code des chantiers n’ayant été réalisés qu’avec des travaux défini dans un devis (pas de travaux hors devis)
-- 42. Donner le code des devis contenant uniquement des travaux des gammes gros œuvre et second œuvre
-- 43. Donner le code des départements n’accueillant aucune société
-- 44. Donner le code du ou des départements accueillant le plus grand nombre de sociétés
-- 45. Donner le code des départements accueillant toutes les sociétés du groupe
-- 46. Donner le code des départements accueillant plus de société que le département 75.
