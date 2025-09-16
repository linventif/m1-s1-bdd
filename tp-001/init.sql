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
# Cf. tableau joint
NomQ Nom d'une qualification CC(40)
NomTY Nom d'un type de travaux (maçonnerie, carrelage…) CC(40)
énuméré
# Cf. tableau joint
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

# Questions
# 1. Code et adresse postale complète (rue et ville) des chantiers ayant fait intervenir des employés dans le cadre
# de devis
# 2. Nom et Prénom des employés ayant un niveau d’étude supérieur au Bac (BTS ou ingénieur)
# 3. Codes des départements et noms des villes accueillant des entreprises et des chantiers (classement par ordre
# « alphabétique » des départements et villes)
# 4. Nom des types de travaux dont le coût horaire employé représente plus de 80% du cout horaire client.
# 5. Nom des types de travaux ayant nécessité des réalisations hors devis cette année
# 6. Raison Sociale des entreprises ayant proposé des devis cette année dans les villes où elles sont implantées
# 7. Pour chaque gamme de travaux, donner son nom et le nom des types de travaux associés s’il en possède
# 8. Nom des gammes et des types de travaux rentables (types de travaux dont le gain entre le tarif horaire payé par le client et le tarif horaire payé aux employés est supérieur à 80% du tarif horaire employé) avec en-têtes
# personnalisés et classement décroissant des rentabilités
# 9. Nom des types de travaux rentables proposés ce mois-ci dans des devis
# 10. Code et ville des chantiers ayant été réalisés avec des travaux répondant à des devis et des travaux hors devis
# 11. Code et ville des chantiers n’ayant pas fait l’objet d’un devis
# 12. Code et ville des chantiers n’ayant été réalisés qu’avec des travaux répondant à des devis
# 13. Code des chantiers n’ayant pas fait l’objet de travaux
# 14. Nom et prénom des employés ayant une qualification relative aux gammes Gros œuvre et second œuvre.
# 15. Raison sociale et groupe des sociétés n’ayant proposé que des devis (aucun travail effectué)
# 16. Code et date des devis ne proposant que du gros œuvre
# 17. Code et date des devis proposant du gros œuvre et du second œuvre
# 18. Tableau de bord contenant, le nom, le prénom et le nombre d’heures maximum réalisé dans une journée par un employé en réponse à un devis
# 19. Tableau de bord contenant la raison sociale des sociétés et le Chiffre d’Affaire (CA) réalisé dans le cadre des devis (calculé en fonction des heures déclarées dans le devis), classement par ordre décroissant des CA © Franck RAVAT Page 5 sur 5
# 20. Code et ville des chantiers totalisant plus de 1000 heures de travail effectué hors devis (classement par ordre décroissant du nombre d’heures)
# 21. Tableau de bord permettant d’afficher le code des départements et le nombre de chantiers associés en se limitant aux départements possédant aux minimum 5 chantiers
# 22. Nom des villes à prospecter : celles qui ne possède pas plus de 2 chantiers
# 23. Donner le nom et le prénom des employés pouvant effectuer des travaux de toutes les gammes.
# 24. Donner la raison sociale des entreprises de la Haute Garonne (département 31) proposant tous les types de travaux au travers de ses devis
# 25. Code, date et CA prévisionnel du dernier devis (celui ayant le code le plus élevé)
# 26. Raison sociale de l’entreprise ayant réalisé un CA prévisionnel supérieur à celui de Bati31
# 27. Noms des villes possédant plus de chantiers que Toulouse
# 28. Code et date du dernier devis émis par une SARL
# 29. Pour chaque entreprise, donner sa raison sociale et son dernier devis (code et date et son Chiffre d’affaires prévisionnel)
# 30. Donner le CA (Chiffre d'Affaire) prévisionnel moyen d'un devis
# 31. Donner le nom de la gamme proposant un CA prévisionnel plus élevé que la gamme SOL
# 32. Donner la raison sociale des entreprises ayant proposé le plus de devis
# 33. Donner les coordonnées du chantier (code, rue, ville) ayant fait intervenir le plus d’employés cette année (dans le cadre des devis).
# 34. Pour chaque chantier donner son code et son CA réalisé hors devis
# 35. Pour chaque chantier, donner son code et son CA réalisé dans le cadre des devis
# 36. Pour chaque chantier donner son CA total (en se limitant aux chantiers ayant des CA hors devis et des CA devis)
# 37. Donner le nom des villes possédant le plus chantiers.
# 38. Donner les noms des types de travaux ayant plus d’heures prévisionnelles totales que le type plomberie
# 39. Nom et type de la société ayant effectué le plus d’heures hors devis cette année.
# 40. Donner le nom et le prénom des employés ayant travaillé dans le cadre des devis sur tous les chantiers de la Haute Garonne (département 31) cette année.
# 41. Code des chantiers n’ayant été réalisés qu’avec des travaux défini dans un devis (pas de travaux hors devis)
# 42. Donner le code des devis contenant uniquement des travaux des gammes gros œuvre et second œuvre
# 43. Donner le code des départements n’accueillant aucune société
# 44. Donner le code du ou des départements accueillant le plus grand nombre de sociétés
# 45. Donner le code des départements accueillant toutes les sociétés du groupe
# 46. Donner le code des départements accueillant plus de société que le département 75.
