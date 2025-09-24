-- Table VILLE
CREATE TABLE VILLE (
    CodeV        VARCHAR2(5) PRIMARY KEY,
    NomV         VARCHAR2(40),
    CodeDeptV    VARCHAR2(3),
    RegionV      VARCHAR2(40)
);

-- Table ENTREPRISE
CREATE TABLE ENTREPRISE (
    NSiret       VARCHAR2(14) PRIMARY KEY,
    RaisonSoc    VARCHAR2(40),
    TypeSoc      VARCHAR2(5),
    GroupeSoc    VARCHAR2(40),
    CodeV        VARCHAR2(5),
    CONSTRAINT fk_entreprise_ville FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table CHANTIER
CREATE TABLE CHANTIER (
    CodeCH       INTEGER PRIMARY KEY,
    RueCH        VARCHAR2(40),
    CodePostCH   VARCHAR2(5),
    CodeV        VARCHAR2(5),
    CONSTRAINT fk_chantier_ville FOREIGN KEY (CodeV) REFERENCES VILLE(CodeV)
);

-- Table DEVIS
CREATE TABLE DEVIS (
    CodeDE       INTEGER PRIMARY KEY,
    DateDe       DATE,
    NSiret       VARCHAR2(14),
    CodeCH       INTEGER,
    CONSTRAINT fk_devis_entreprise FOREIGN KEY (NSiret) REFERENCES ENTREPRISE(NSiret),
    CONSTRAINT fk_devis_chantier FOREIGN KEY (CodeCH) REFERENCES CHANTIER(CodeCH)
);

-- Table QUALIF
CREATE TABLE QUALIF (
    CodeQ        INTEGER PRIMARY KEY,
    NomQ         VARCHAR2(40),
    NiveauQ      VARCHAR2(9)
);

-- Table EMPLOYE
CREATE TABLE EMPLOYE (
    CodeE        INTEGER PRIMARY KEY,
    NomE         VARCHAR2(40),
    PrenomE      VARCHAR2(40),
    CodeQ        INTEGER,
    NSiret       VARCHAR2(14),
    CONSTRAINT fk_employe_qualif FOREIGN KEY (CodeQ) REFERENCES QUALIF(CodeQ),
    CONSTRAINT fk_employe_entreprise FOREIGN KEY (NSiret) REFERENCES ENTREPRISE(NSiret)
);

-- Table GAMMETRAVAUX
CREATE TABLE GAMMETRAVAUX (
    idGA         INTEGER PRIMARY KEY,
    NomGA        VARCHAR2(40)
);

-- Table TYPETRAVAUX
CREATE TABLE TYPETRAVAUX (
    CodeTY              INTEGER PRIMARY KEY,
    NomTY               VARCHAR2(40),
    Tarif_Heure_Clt     NUMBER(10, 2),
    Tarif_Heure_Employé NUMBER(10, 2),
    idGA                INTEGER,
    CONSTRAINT fk_typetravaux_gamme FOREIGN KEY (idGA) REFERENCES GAMMETRAVAUX(idGA)
);

-- Table AUTORISER
CREATE TABLE AUTORISER (
    CodeQ        INTEGER,
    idGA         INTEGER,
    PRIMARY KEY (CodeQ, idGA),
    CONSTRAINT fk_autoriser_qualif FOREIGN KEY (CodeQ) REFERENCES QUALIF(CodeQ),
    CONSTRAINT fk_autoriser_gamme FOREIGN KEY (idGA) REFERENCES GAMMETRAVAUX(idGA)
);

-- Table COMPRENDRE
CREATE TABLE COMPRENDRE (
    CodeDE       INTEGER,
    CodeTY       INTEGER,
    NbHeuresPrev NUMBER(6,2),
    PRIMARY KEY (CodeDE, CodeTY),
    CONSTRAINT fk_comprendre_devis FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    CONSTRAINT fk_comprendre_typetravaux FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERHORSDEVIS
CREATE TABLE TRAVAILLERHORSDEVIS (
    CodeCH       INTEGER,
    CodeE        INTEGER,
    DateT        DATE,
    CodeTY       INTEGER,
    NbHeureTrav  NUMBER(6,2),
    PRIMARY KEY (CodeCH, CodeE, DateT, CodeTY),
    CONSTRAINT fk_travh_chantier FOREIGN KEY (CodeCH) REFERENCES CHANTIER(CodeCH),
    CONSTRAINT fk_travh_employe FOREIGN KEY (CodeE) REFERENCES EMPLOYE(CodeE),
    CONSTRAINT fk_travh_type FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);

-- Table TRAVAILLERDEVIS
CREATE TABLE TRAVAILLERDEVIS (
    CodeDE           INTEGER,
    CodeE            INTEGER,
    DateT            DATE,
    CodeTY           INTEGER,
    NbHeureTravDEVIS NUMBER(6,2),
    PRIMARY KEY (CodeDE, CodeE, DateT, CodeTY),
    CONSTRAINT fk_travd_devis FOREIGN KEY (CodeDE) REFERENCES DEVIS(CodeDE),
    CONSTRAINT fk_travd_employe FOREIGN KEY (CodeE) REFERENCES EMPLOYE(CodeE),
    CONSTRAINT fk_travd_type FOREIGN KEY (CodeTY) REFERENCES TYPETRAVAUX(CodeTY)
);
