# Init Schema
DROP SCHEMA IF EXISTS tp_001;
CREATE SCHEMA IF NOT EXISTS tp_001;

# use the schema
USE tp_001;

/*
ENTREPRISE(N°Siret, RaisonSoc, TypeSoc, GroupeSoc, CodeV#)
VILLE(CodeV, NomV, CodeDeptV, RegionV)
DEVIS(CodeDE, DateDe, N°Siret#, CodeCH#)
CHANTIER(CodeCH, RueCH, CodePostCH, CodeV#)
QUALIF(CodeQ, NomQ, NiveauQ)
EMPLOYE(CodeE, NomE, PrenomE, CodeQ#, N°Siret#)
TYPETRAVAUX(CodeTY, NomTY, Tarif_Heure_Clt, Tarif_Heure_Employé, idGa#)
GAMMETRAVAUX(idGA, NomGA)
AUTORISER(CodeQ#, idGA#)
COMPRENDRE(CodeDE#, CodeTY#, NbHeuresPrev)
TRAVAILLERHORSDEVIS(CodeCH#, CodeE#, DateT, CodeTY#, NbHeureTrav)
TRAVAILLERDEVIS(CodeDE#, CodeE#, DateT, CodeTY#, NbHeureTravDEVIS)

 Page 3 sur 5
Code Description Domaine
Règle de calcul
ou de
composition
Contrainte
CodeCH Code unique d'un chantier (numéro automatique) Entier >0
CodeDE Identifiant unique d'un devis (numéro automatique) Entier >0
CodeDeptV Code départemental d'une ville CC(3)
CodeE Code unique d'un employé (numéro automatique) Entier >0
CodePastCH Code postal du chantier CC(5) 5 chiffres
CodeQ Code unique d'une qualification (numéro automatique) Entier >0
CodeTY Code unique d'un type de travaux (numéro automatique) Entier >0
CodeV Code INSEE unique d'une ville - cf.
http://www.insee.fr/fr/methodes/nomenclatures/cog/telechargemen
t.asp
CC(5)
DateT Date d'activité d'un employé Date JJ/MM/AAAA <=date()
DateDe Date d'un devis Date JJ/MM/AAAA
GroupeSoc Nom du groupe de la société CC(40)
idGA Identifiant unique d'une gamme de travaux (numéro automatique) Entier >0
N°Siret Numéro de Siret d'une entreprise CC (14)
NbHeuresPrev Nombre d'heures prévues pour un type de travaux d'un devis (en
centième d'heure)
Réel >0
NbHeureTrav Nombre d'heures effectuées par un employé sur un chantier pour un
type de travaux donné à une date donnée (en centième d'heure)
Réel >0
NbHeureTravDEVIS Nombre d'heures effectuées par un employé pour un devis et pour un
type de travaux donné à une date donnée (en centième d'heure)
Réel >0
NiveauQ Niveau d'une qualification CC(9) énuméré BEP, CAP, Bac Pro, BTS ou Ingénieur
NomE Nom d'un employé CC(40)
NomGA Nom d'une gamme de travaux CC(40)
énuméré
Cf. tableau joint
NomQ Nom d'une qualification CC(40)
NomTY Nom d'un type de travaux (maçonnerie, carrelage…) CC(40)
énuméré
Cf. tableau joint
NomV Nom d'une ville CC(40)
PrenomE Prénom d'un employé CC(40)
RaisonSoc Raison Sociale d'une entreprise CC(40)
RegionV Nom de la région d'une ville CC(40)
RueCH Numéro et nom de la rue, boulevard… CC(40)
Tarif_Heure_Clt Tarif horaire d'un type de travaux payé par un client Réel > Tarif_Heure_Employé
Tarif_Heure_Employé Tarif horaire d'un type de travaux payé à l'employé Réel >0
TypeSoc Type d'une société CC(5) énuméré SA, SARL, SCOP, ou EURL
© Franck RAVAT Page 4 sur 5
Les valeurs pour les attributs « Gamme » et « Type Travaux » sont les suivantes
 */

-- Table VILLE
CREATE TABLE VILLE (
    CodeV CHAR(5) PRIMARY KEY,
    NomV VARCHAR(40) NOT NULL,
    CodeDeptV CHAR(3) NOT NULL,
    RegionV VARCHAR(40) NOT NULL
);

-- Table CHANTIER
CREATE TABLE CHANTIER (
    CodeCH INT AUTO_INCREMENT PRIMARY KEY,
    RueCH VARCHAR(40) NOT NULL,
    CodePostCH CHAR(5) NOT NULL,
    CodeV CHAR(5),
    FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table GAMMETRAVAUX
CREATE TABLE GAMMETRAVAUX (
    idGA INT AUTO_INCREMENT PRIMARY KEY,
    NomGA VARCHAR(40) NOT NULL
);

-- Table QUALIF
CREATE TABLE QUALIF (
    CodeQ INT AUTO_INCREMENT PRIMARY KEY,
    NomQ VARCHAR(40) NOT NULL,
    NiveauQ ENUM('BEP', 'CAP', 'Bac Pro', 'BTS', 'Ingénieur') NOT NULL
);

-- Table ENTREPRISE
CREATE TABLE ENTREPRISE (
    N_Siret CHAR(14) PRIMARY KEY,
    RaisonSoc VARCHAR(40) NOT NULL,
    TypeSoc ENUM('SA', 'SARL', 'SCOP', 'EURL') NOT NULL,
    GroupeSoc VARCHAR(40),
    CodeV CHAR(5),
    FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table DEVIS
CREATE TABLE DEVIS (
    CodeDE INT AUTO_INCREMENT PRIMARY KEY,
    DateDe DATE NOT NULL,
    N_Siret CHAR(14),
    CodeCH INT,
    FOREIGN KEY (N_Siret) REFERENCES ENTREPRISE(N_Siret),
    FOREIGN KEY (CodeCH) REFERENCES CHANTIER(CodeCH)
);

-- Table EMPLOYE
CREATE TABLE EMPLOYE (
    CodeE INT AUTO_INCREMENT PRIMARY KEY,
    NomE VARCHAR(40) NOT NULL,
    PrenomE VARCHAR(40) NOT NULL,
    CodeQ INT,
    N_Siret CHAR(14),
    FOREIGN KEY (CodeQ) REFERENCES QUALIF(CodeQ),
    FOREIGN KEY (N_Siret) REFERENCES ENTREPRISE(N_Siret)
);

-- Table TYPETRAVAUX
CREATE TABLE TYPETRAVAUX (
    CodeTY INT AUTO_INCREMENT PRIMARY KEY,
    NomTY VARCHAR(40) NOT NULL,
    Tarif_Heure_Clt DECIMAL(10,2) NOT NULL,
    Tarif_Heure_Employe DECIMAL(10,2) NOT NULL,
    idGa INT,
    FOREIGN KEY (idGa) REFERENCES GAMMETRAVAUX(idGa),
    CHECK (Tarif_Heure_Clt > Tarif_Heure_Employe)
);


-- Table AUTORISER
CREATE TABLE AUTORISER (
    CodeQ INT,
    idGA INT,
    PRIMARY KEY (CodeQ, idGA),
    FOREIGN KEY (CodeQ) REFERENCES QUALIF(CodeQ),
    FOREIGN KEY (idGA) REFERENCES GAMMETRAVAUX(idGA)
);

-- Table COMPRENDRE
CREATE TABLE COMPRENDRE (
    CodeDE INT,
    CodeTY INT,
    NbHeuresPrev DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (CodeDE, CodeTY),
    FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERHORSDEVIS
CREATE TABLE TRAVAILLERHORSDEVIS (
    CodeCH INT,
    CodeE INT,
    DateT DATE NOT NULL,
    CodeTY INT,
    NbHeureTrav DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (CodeCH, CodeE, DateT, CodeTY),
    FOREIGN KEY (CodeCH) REFERENCES CHANTIER(CodeCH),
    FOREIGN KEY (CodeE) REFERENCES EMPLOYE(CodeE),
    FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERDEVIS
CREATE TABLE TRAVAILLERDEVIS (
    CodeDE INT,
    CodeE INT,
    DateT DATE NOT NULL,
    CodeTY INT,
    NbHeureTravDEVIS DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (CodeDE, CodeE, DateT, CodeTY),
    FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    FOREIGN KEY (CodeE) REFERENCES EMPLOYE(CodeE),
    FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);
