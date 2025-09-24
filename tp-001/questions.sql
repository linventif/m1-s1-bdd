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
AND v.CodeV = ch.CodeV;


-- 2. Nom et Prénom des employés ayant un niveau d’étude supérieur au Bac (BTS ou ingénieur)
SELECT em.PRENOME, em.NOME
FROM QUALIF qu, EMPLOYE em
WHERE (qu.NIVEAUQ = 'BTS' OR qu.NIVEAUQ = 'Ingénieur') AND em.CodeQ = qu.CodeQ

-- 3. Codes des départements et noms des villes accueillant des entreprises et des chantiers
-- (classement par ordre « alphabétique » des départements et villes)
SELECT vi.CodeDeptV, vi.REGIONV
FROM CHANTIER ch, VILLE vi
WHERE ch.CodeV = vi.CodeV
ORDER BY RegionV ASC;

-- 4. Nom des types de travaux dont le coût horaire employé représente plus de 80% du cout horaire client.
SELECT tt.NOMTY
FROM TYPETRAVAUX tt
WHERE tt.TARIF_HEURE_EMPLOYÉ > tt.Tarif_Heure_Clt * 0.8;


-- 5. Nom des types de travaux ayant nécessité des réalisations hors devis cette année
SELECT tt.NOMTY
FROM TYPETRAVAUX tt, TRAVAILLERHORSDEVIS thd
WHERE tt.CODETY = thd.CODETY AND extract(YEAR FROM thd.DATET) = 2025;

-- 6. Raison Sociale des entreprises ayant proposé des devis cette année dans les villes où elles sont implantées
SELECT en.RAISONSOC
FROM ENTREPRISE en, DEVIS de, CHANTIER ch
WHERE en.NSIRET = de.NSIRET AND ch.CodeCH = de.CodeCH AND en.CODEV = ch.CODEV;

-- 7. Pour chaque gamme de travaux, donner son nom et le nom des types de travaux associés s’il en possède
SELECT ga.NomGA, ty.NomTY
FROM GAMMETRAVAUX ga, TYPETRAVAUX ty
WHERE ga.idGA (+) = ty.idGA

-- 8. Nom des gammes et des types de travaux rentables (types de travaux dont le gain entre le tarif
-- horaire payé par le client et le tarif horaire payé aux employés est supérieur à 80% du tarif horaire employé)
-- avec en-têtes personnalisés et classement décroissant des rentabilités
SELECT ga.NomGA AS "Gamme de travaux",
       tt.NomTY AS "Type de travaux",
       (tt.Tarif_Heure_Clt - tt.TARIF_HEURE_EMPLOYÉ) AS "Rentabilité"
FROM GAMMETRAVAUX ga, TYPETRAVAUX tt
WHERE ga.idGA = tt.idGA
  AND (tt.Tarif_Heure_Clt - tt.TARIF_HEURE_EMPLOYÉ) > tt.TARIF_HEURE_EMPLOYÉ * 0.8
ORDER BY (tt.Tarif_Heure_Clt - tt.TARIF_HEURE_EMPLOYÉ) DESC;

-- 9. Nom des types de travaux rentables proposés ce mois-ci dans des devis
SELECT DISTINCT tt.NomTY
FROM TYPETRAVAUX tt, COMPRENDRE c, DEVIS d
WHERE tt.CodeTY = c.CodeTY
  AND c.CodeDE = d.CodeDE
  AND (tt.Tarif_Heure_Clt - tt.TARIF_HEURE_EMPLOYÉ) > tt.TARIF_HEURE_EMPLOYÉ * 0.8
  AND EXTRACT(YEAR FROM d.DateDe) = 2024
  AND EXTRACT(MONTH FROM d.DateDe) = EXTRACT(MONTH FROM SYSDATE);

-- 10. Code et ville des chantiers ayant été réalisés avec des travaux répondant à des devis et des travaux hors devis
SELECT DISTINCT ch.CodeCH, v.NomV
FROM CHANTIER ch, VILLE v, DEVIS d, TRAVAILLERDEVIS td, TRAVAILLERHORSDEVIS thd
WHERE ch.CodeV = v.CodeV
  AND ch.CodeCH = d.CodeCH
  AND d.CodeDE = td.CodeDE
  AND ch.CodeCH = thd.CodeCH;

-- 11. Code et ville des chantiers n'ayant pas fait l'objet d'un devis
SELECT ch.CodeCH, v.NomV
FROM CHANTIER ch, VILLE v
WHERE ch.CodeV = v.CodeV
  AND ch.CodeCH NOT IN (SELECT CodeCH FROM DEVIS WHERE CodeCH IS NOT NULL)
-- Grégoire Launay--Bécue

-- 12. Code et ville des chantiers n'ayant été réalisés qu'avec des travaux répondant à des devis
SELECT DISTINCT ch.CodeCH, v.NomV
FROM CHANTIER ch, VILLE v, DEVIS d, TRAVAILLERDEVIS td
WHERE ch.CodeV = v.CodeV
  AND ch.CodeCH = d.CodeCH
  AND d.CodeDE = td.CodeDE
  AND ch.CodeCH NOT IN (SELECT CodeCH FROM TRAVAILLERHORSDEVIS)
-- Grégoire Launay--Bécue

-- 13. Code des chantiers n'ayant pas fait l'objet de travaux
SELECT ch.CodeCH
FROM CHANTIER ch
WHERE ch.CodeCH NOT IN (SELECT CodeCH FROM TRAVAILLERHORSDEVIS WHERE CodeCH IS NOT NULL)
  AND ch.CodeCH NOT IN (SELECT DISTINCT d.CodeCH FROM DEVIS d, TRAVAILLERDEVIS td WHERE d.CodeDE = td.CodeDE AND d.CodeCH IS NOT NULL)
-- Grégoire Launay--Bécue












/*
 13. Code des chantiers n’ayant pas fait l’objet de travaux
 */
-- SELECT *
-- FROM ENTREPRISE etp, VILLE vil, CHANTIER cht

SELECT *
FROM CHANTIER ch
WHERE ch.CodeCH
NOT IN (
    SELECT ch.CodeCH
    FROM CHANTIER ch, DEVIS dv
    WHERE ch.CodeCH = dv.CodeCH
) NOT IN (
    SELECT ch.CodeCH
    FROM CHANTIER ch, TRAVAILLERHORSDEVIS thd
    WHERE ch.CodeCH = thd.CodeCH
)

SELECT *
FROM ENTREPRISE en, DEVIS dv
WHERE en.NSIRET = dv.NSIRET
AND dv.CODEDE NOT IN (
    SELECT dv.CODEDE
    FROM DEVIS dv, TRAVAILLERDEVIS td
    WHERE dv.CODEDE = td.CodeDE
    )


/*
 14. Nom et prénom des employés ayant une qualification relative aux gammes Gros œuvre et second œuvre

 */
SELECT *
FROM EMPLOYE em, QUALIF qu
WHERE em.CodeQ = qu.CODEQ
AND qu.NOMQ = 'Gros œuvre' OR qu.NOMQ = 'Second œuvre'



































-- 14. Nom et prénom des employés ayant une qualification relative aux gammes Gros œuvre et second œuvre
SELECT DISTINCT e.NomE, e.PrenomE
FROM EMPLOYE e, QUALIF q, AUTORISER a, GAMMETRAVAUX g
WHERE e.CodeQ = q.CodeQ
  AND q.CodeQ = a.CodeQ
  AND a.idGA = g.idGA
  AND g.NomGA IN ('Gros œuvre', 'Second œuvre')
-- Grégoire Launay--Bécue

-- 15. Raison sociale et groupe des sociétés n'ayant proposé que des devis (aucun travail effectué)
SELECT ent.RaisonSoc, ent.GroupeSoc
FROM ENTREPRISE ent
WHERE ent.NSIRET IN (SELECT NSIRET FROM DEVIS)
  AND ent.NSIRET NOT IN (SELECT DISTINCT e.NSIRET FROM EMPLOYE e, TRAVAILLERDEVIS td WHERE e.CodeE = td.CodeE)
  AND ent.NSIRET NOT IN (SELECT DISTINCT e.NSIRET FROM EMPLOYE e, TRAVAILLERHORSDEVIS thd WHERE e.CodeE = thd.CodeE)
-- Grégoire Launay--Bécue

-- 16. Code et date des devis ne proposant que du gros œuvre
SELECT d.CodeDE, d.DateDe
FROM DEVIS d
WHERE d.CodeDE IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA = 'Gros œuvre'
)
AND d.CodeDE NOT IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeDE = d.CodeDE
      AND c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA != 'Gros œuvre'
)
-- Grégoire Launay--Bécue

-- 17. Code et date des devis proposant du gros œuvre et du second œuvre
SELECT d.CodeDE, d.DateDe
FROM DEVIS d
WHERE d.CodeDE IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA = 'Gros œuvre'
)
AND d.CodeDE IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA = 'Second œuvre'
)
-- Grégoire Launay--Bécue

-- 18. Tableau de bord contenant, le nom, le prénom et le nombre d'heures maximum réalisé dans une journée par un employé en réponse à un devis
SELECT e.NomE, e.PrenomE, MAX(td.NbHeureTravDEVIS) AS "Max heures par jour"
FROM EMPLOYE e, TRAVAILLERDEVIS td
WHERE e.CodeE = td.CodeE
GROUP BY e.NomE, e.PrenomE
-- Grégoire Launay--Bécue

-- 19. Tableau de bord contenant la raison sociale des sociétés et le Chiffre d'Affaire (CA) réalisé dans le cadre des devis (calculé en fonction des heures déclarées dans le devis), classement par ordre décroissant des CA
SELECT ent.RaisonSoc, SUM(td.NbHeureTravDEVIS * tt.Tarif_Heure_Clt) AS "CA Devis"
FROM ENTREPRISE ent, EMPLOYE e, TRAVAILLERDEVIS td, TYPETRAVAUX tt
WHERE ent.NSIRET = e.NSIRET
  AND e.CodeE = td.CodeE
  AND td.CodeTY = tt.CodeTY
GROUP BY ent.RaisonSoc
ORDER BY SUM(td.NbHeureTravDEVIS * tt.Tarif_Heure_Clt) DESC
-- Grégoire Launay--Bécue

-- 20. Code et ville des chantiers totalisant plus de 1000 heures de travail effectué hors devis (classement par ordre décroissant du nombre d'heures)
SELECT ch.CodeCH, v.NomV, SUM(thd.NbHeureTrav) AS "Total heures hors devis"
FROM CHANTIER ch, VILLE v, TRAVAILLERHORSDEVIS thd
WHERE ch.CodeV = v.CodeV
  AND ch.CodeCH = thd.CodeCH
GROUP BY ch.CodeCH, v.NomV
HAVING SUM(thd.NbHeureTrav) > 1000
ORDER BY SUM(thd.NbHeureTrav) DESC
-- Grégoire Launay--Bécue

-- 21. Tableau de bord permettant d'afficher le code des départements et le nombre de chantiers associés en se limitant aux départements possédant aux minimum 5 chantiers
SELECT v.CodeDeptV, COUNT(ch.CodeCH) AS "Nombre de chantiers"
FROM VILLE v, CHANTIER ch
WHERE v.CodeV = ch.CodeV
GROUP BY v.CodeDeptV
HAVING COUNT(ch.CodeCH) >= 5
-- Grégoire Launay--Bécue

-- 22. Nom des villes à prospecter : celles qui ne possède pas plus de 2 chantiers
SELECT v.NomV
FROM VILLE v
WHERE v.CodeV IN (
    SELECT ch.CodeV
    FROM CHANTIER ch
    WHERE ch.CodeV = v.CodeV
    GROUP BY ch.CodeV
    HAVING COUNT(ch.CodeCH) <= 2
)
OR v.CodeV NOT IN (SELECT CodeV FROM CHANTIER WHERE CodeV IS NOT NULL)
-- Grégoire Launay--Bécue

-- 23. Donner le nom et le prénom des employés pouvant effectuer des travaux de toutes les gammes
SELECT e.NomE, e.PrenomE
FROM EMPLOYE e, QUALIF q
WHERE e.CodeQ = q.CodeQ
  AND q.CodeQ IN (
    SELECT a.CodeQ
    FROM AUTORISER a
    GROUP BY a.CodeQ
    HAVING COUNT(DISTINCT a.idGA) = (SELECT COUNT(*) FROM GAMMETRAVAUX)
  )
-- Grégoire Launay--Bécue

-- 24. Donner la raison sociale des entreprises de la Haute Garonne (département 31) proposant tous les types de travaux au travers de ses devis
SELECT ent.RaisonSoc
FROM ENTREPRISE ent, VILLE v
WHERE ent.CodeV = v.CodeV
  AND v.CodeDeptV = '31'
  AND ent.NSIRET IN (
    SELECT d.NSIRET
    FROM DEVIS d, COMPRENDRE c
    WHERE d.CodeDE = c.CodeDE
    GROUP BY d.NSIRET
    HAVING COUNT(DISTINCT c.CodeTY) = (SELECT COUNT(*) FROM TYPETRAVAUX)
  )
-- Grégoire Launay--Bécue

-- 25. Code, date et CA prévisionnel du dernier devis (celui ayant le code le plus élevé)
SELECT d.CodeDE, d.DateDe, SUM(c.NbHeuresPrev * tt.Tarif_Heure_Clt) AS "CA prévisionnel"
FROM DEVIS d, COMPRENDRE c, TYPETRAVAUX tt
WHERE d.CodeDE = c.CodeDE
  AND c.CodeTY = tt.CodeTY
  AND d.CodeDE = (SELECT MAX(CodeDE) FROM DEVIS)
GROUP BY d.CodeDE, d.DateDe
-- Grégoire Launay--Bécue

-- 26. Raison sociale de l'entreprise ayant réalisé un CA prévisionnel supérieur à celui de Bati31
SELECT ent.RaisonSoc
FROM ENTREPRISE ent, DEVIS d, COMPRENDRE c, TYPETRAVAUX tt
WHERE ent.NSIRET = d.NSIRET
  AND d.CodeDE = c.CodeDE
  AND c.CodeTY = tt.CodeTY
GROUP BY ent.RaisonSoc
HAVING SUM(c.NbHeuresPrev * tt.Tarif_Heure_Clt) > (
    SELECT SUM(c2.NbHeuresPrev * tt2.Tarif_Heure_Clt)
    FROM ENTREPRISE ent2, DEVIS d2, COMPRENDRE c2, TYPETRAVAUX tt2
    WHERE ent2.NSIRET = d2.NSIRET
      AND d2.CodeDE = c2.CodeDE
      AND c2.CodeTY = tt2.CodeTY
      AND ent2.RaisonSoc = 'Bati31'
    GROUP BY ent2.RaisonSoc
)
-- Grégoire Launay--Bécue

-- 27. Noms des villes possédant plus de chantiers que Toulouse
SELECT v.NomV
FROM VILLE v, CHANTIER ch
WHERE v.CodeV = ch.CodeV
GROUP BY v.NomV
HAVING COUNT(ch.CodeCH) > (
    SELECT COUNT(ch2.CodeCH)
    FROM VILLE v2, CHANTIER ch2
    WHERE v2.CodeV = ch2.CodeV
      AND v2.NomV = 'Toulouse'
    GROUP BY v2.NomV
)
-- Grégoire Launay--Bécue

-- 28. Code et date du dernier devis émis par une SARL
SELECT d.CodeDE, d.DateDe
FROM DEVIS d, ENTREPRISE ent
WHERE d.NSIRET = ent.NSIRET
  AND ent.TypeSoc = 'SARL'
  AND d.DateDe = (
    SELECT MAX(d2.DateDe)
    FROM DEVIS d2, ENTREPRISE ent2
    WHERE d2.NSIRET = ent2.NSIRET
      AND ent2.TypeSoc = 'SARL'
  )
-- Grégoire Launay--Bécue

-- 29. Pour chaque entreprise, donner sa raison sociale et son dernier devis (code et date et son Chiffre d'affaires prévisionnel)
SELECT ent.RaisonSoc, d.CodeDE, d.DateDe, SUM(c.NbHeuresPrev * tt.Tarif_Heure_Clt) AS "CA prévisionnel"
FROM ENTREPRISE ent, DEVIS d, COMPRENDRE c, TYPETRAVAUX tt
WHERE ent.NSIRET = d.NSIRET
  AND d.CodeDE = c.CodeDE
  AND c.CodeTY = tt.CodeTY
  AND d.DateDe = (
    SELECT MAX(d2.DateDe)
    FROM DEVIS d2
    WHERE d2.NSIRET = ent.NSIRET
  )
GROUP BY ent.RaisonSoc, d.CodeDE, d.DateDe
-- Grégoire Launay--Bécue

-- 30. Donner le CA (Chiffre d'Affaire) prévisionnel moyen d'un devis
SELECT AVG(ca_devis.ca) AS "CA prévisionnel moyen"
FROM (
    SELECT SUM(c.NbHeuresPrev * tt.Tarif_Heure_Clt) AS ca
    FROM COMPRENDRE c, TYPETRAVAUX tt
    WHERE c.CodeTY = tt.CodeTY
    GROUP BY c.CodeDE
) ca_devis
-- Grégoire Launay--Bécue

-- 31. Donner le nom de la gamme proposant un CA prévisionnel plus élevé que la gamme SOL
SELECT g.NomGA
FROM GAMMETRAVAUX g, TYPETRAVAUX tt, COMPRENDRE c
WHERE g.idGA = tt.idGA
  AND tt.CodeTY = c.CodeTY
GROUP BY g.NomGA
HAVING SUM(c.NbHeuresPrev * tt.Tarif_Heure_Clt) > (
    SELECT SUM(c2.NbHeuresPrev * tt2.Tarif_Heure_Clt)
    FROM GAMMETRAVAUX g2, TYPETRAVAUX tt2, COMPRENDRE c2
    WHERE g2.idGA = tt2.idGA
      AND tt2.CodeTY = c2.CodeTY
      AND g2.NomGA = 'SOL'
    GROUP BY g2.NomGA
)
-- Grégoire Launay--Bécue

-- 32. Donner la raison sociale des entreprises ayant proposé le plus de devis
SELECT ent.RaisonSoc
FROM ENTREPRISE ent, DEVIS d
WHERE ent.NSIRET = d.NSIRET
GROUP BY ent.RaisonSoc
HAVING COUNT(d.CodeDE) = (
    SELECT MAX(nb_devis)
    FROM (
        SELECT COUNT(d2.CodeDE) AS nb_devis
        FROM ENTREPRISE ent2, DEVIS d2
        WHERE ent2.NSIRET = d2.NSIRET
        GROUP BY ent2.NSIRET
    )
)
-- Grégoire Launay--Bécue

-- 33. Donner les coordonnées du chantier (code, rue, ville) ayant fait intervenir le plus d'employés cette année (dans le cadre des devis)
SELECT ch.CodeCH, ch.RueCH, v.NomV
FROM CHANTIER ch, VILLE v, DEVIS d, TRAVAILLERDEVIS td
WHERE ch.CodeV = v.CodeV
  AND ch.CodeCH = d.CodeCH
  AND d.CodeDE = td.CodeDE
  AND EXTRACT(YEAR FROM td.DateT) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY ch.CodeCH, ch.RueCH, v.NomV
HAVING COUNT(DISTINCT td.CodeE) = (
    SELECT MAX(nb_employes)
    FROM (
        SELECT COUNT(DISTINCT td2.CodeE) AS nb_employes
        FROM CHANTIER ch2, DEVIS d2, TRAVAILLERDEVIS td2
        WHERE ch2.CodeCH = d2.CodeCH
          AND d2.CodeDE = td2.CodeDE
          AND EXTRACT(YEAR FROM td2.DateT) = EXTRACT(YEAR FROM SYSDATE)
        GROUP BY ch2.CodeCH
    )
)
-- Grégoire Launay--Bécue

-- 34. Pour chaque chantier donner son code et son CA réalisé hors devis
SELECT ch.CodeCH, NVL(SUM(thd.NbHeureTrav * tt.Tarif_Heure_Clt), 0) AS "CA hors devis"
FROM CHANTIER ch
LEFT JOIN TRAVAILLERHORSDEVIS thd ON ch.CodeCH = thd.CodeCH
LEFT JOIN TYPETRAVAUX tt ON thd.CodeTY = tt.CodeTY
GROUP BY ch.CodeCH
-- Grégoire Launay--Bécue

-- 35. Pour chaque chantier, donner son code et son CA réalisé dans le cadre des devis
SELECT ch.CodeCH, NVL(SUM(td.NbHeureTravDEVIS * tt.Tarif_Heure_Clt), 0) AS "CA devis"
FROM CHANTIER ch
LEFT JOIN DEVIS d ON ch.CodeCH = d.CodeCH
LEFT JOIN TRAVAILLERDEVIS td ON d.CodeDE = td.CodeDE
LEFT JOIN TYPETRAVAUX tt ON td.CodeTY = tt.CodeTY
GROUP BY ch.CodeCH
-- Grégoire Launay--Bécue

-- 36. Pour chaque chantier donner son CA total (en se limitant aux chantiers ayant des CA hors devis et des CA devis)
SELECT ch.CodeCH,
       (NVL(ca_hors.ca_hors, 0) + NVL(ca_devis.ca_devis, 0)) AS "CA total"
FROM CHANTIER ch,
     (SELECT thd.CodeCH, SUM(thd.NbHeureTrav * tt.Tarif_Heure_Clt) AS ca_hors
      FROM TRAVAILLERHORSDEVIS thd, TYPETRAVAUX tt
      WHERE thd.CodeTY = tt.CodeTY
      GROUP BY thd.CodeCH) ca_hors,
     (SELECT d.CodeCH, SUM(td.NbHeureTravDEVIS * tt.Tarif_Heure_Clt) AS ca_devis
      FROM DEVIS d, TRAVAILLERDEVIS td, TYPETRAVAUX tt
      WHERE d.CodeDE = td.CodeDE AND td.CodeTY = tt.CodeTY
      GROUP BY d.CodeCH) ca_devis
WHERE ch.CodeCH = ca_hors.CodeCH
  AND ch.CodeCH = ca_devis.CodeCH
-- Grégoire Launay--Bécue

-- 37. Donner le nom des villes possédant le plus de chantiers
SELECT v.NomV
FROM VILLE v, CHANTIER ch
WHERE v.CodeV = ch.CodeV
GROUP BY v.NomV
HAVING COUNT(ch.CodeCH) = (
    SELECT MAX(nb_chantiers)
    FROM (
        SELECT COUNT(ch2.CodeCH) AS nb_chantiers
        FROM VILLE v2, CHANTIER ch2
        WHERE v2.CodeV = ch2.CodeV
        GROUP BY v2.NomV
    )
)
-- Grégoire Launay--Bécue

-- 38. Donner les noms des types de travaux ayant plus d'heures prévisionnelles totales que le type plomberie
SELECT tt.NomTY
FROM TYPETRAVAUX tt, COMPRENDRE c
WHERE tt.CodeTY = c.CodeTY
GROUP BY tt.NomTY
HAVING SUM(c.NbHeuresPrev) > (
    SELECT SUM(c2.NbHeuresPrev)
    FROM TYPETRAVAUX tt2, COMPRENDRE c2
    WHERE tt2.CodeTY = c2.CodeTY
      AND tt2.NomTY = 'Plomberie'
    GROUP BY tt2.NomTY
)
-- Grégoire Launay--Bécue

-- 39. Nom et type de la société ayant effectué le plus d'heures hors devis cette année
SELECT ent.RaisonSoc, ent.TypeSoc
FROM ENTREPRISE ent, EMPLOYE e, TRAVAILLERHORSDEVIS thd
WHERE ent.NSIRET = e.NSIRET
  AND e.CodeE = thd.CodeE
  AND EXTRACT(YEAR FROM thd.DateT) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY ent.RaisonSoc, ent.TypeSoc
HAVING SUM(thd.NbHeureTrav) = (
    SELECT MAX(total_heures)
    FROM (
        SELECT SUM(thd2.NbHeureTrav) AS total_heures
        FROM ENTREPRISE ent2, EMPLOYE e2, TRAVAILLERHORSDEVIS thd2
        WHERE ent2.NSIRET = e2.NSIRET
          AND e2.CodeE = thd2.CodeE
          AND EXTRACT(YEAR FROM thd2.DateT) = EXTRACT(YEAR FROM SYSDATE)
        GROUP BY ent2.NSIRET
    )
)
-- Grégoire Launay--Bécue

-- 40. Donner le nom et le prénom des employés ayant travaillé dans le cadre des devis sur tous les chantiers de la Haute Garonne (département 31) cette année
SELECT e.NomE, e.PrenomE
FROM EMPLOYE e
WHERE NOT EXISTS (
    SELECT ch.CodeCH
    FROM CHANTIER ch, VILLE v
    WHERE ch.CodeV = v.CodeV
      AND v.CodeDeptV = '31'
      AND NOT EXISTS (
        SELECT 1
        FROM DEVIS d, TRAVAILLERDEVIS td
        WHERE d.CodeCH = ch.CodeCH
          AND d.CodeDE = td.CodeDE
          AND td.CodeE = e.CodeE
          AND EXTRACT(YEAR FROM td.DateT) = EXTRACT(YEAR FROM SYSDATE)
      )
)
-- Grégoire Launay--Bécue

-- 41. Code des chantiers n'ayant été réalisés qu'avec des travaux défini dans un devis (pas de travaux hors devis)
SELECT DISTINCT d.CodeCH
FROM DEVIS d, TRAVAILLERDEVIS td
WHERE d.CodeDE = td.CodeDE
  AND d.CodeCH NOT IN (SELECT CodeCH FROM TRAVAILLERHORSDEVIS WHERE CodeCH IS NOT NULL)
-- Grégoire Launay--Bécue

-- 42. Donner le code des devis contenant uniquement des travaux des gammes gros œuvre et second œuvre
SELECT d.CodeDE
FROM DEVIS d
WHERE d.CodeDE IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA IN ('Gros œuvre', 'Second œuvre')
)
AND d.CodeDE NOT IN (
    SELECT c.CodeDE
    FROM COMPRENDRE c, TYPETRAVAUX tt, GAMMETRAVAUX g
    WHERE c.CodeTY = tt.CodeTY
      AND tt.idGA = g.idGA
      AND g.NomGA NOT IN ('Gros œuvre', 'Second œuvre')
)
-- Grégoire Launay--Bécue

-- 43. Donner le code des départements n'accueillant aucune société
SELECT DISTINCT v.CodeDeptV
FROM VILLE v
WHERE v.CodeV NOT IN (SELECT CodeV FROM ENTREPRISE WHERE CodeV IS NOT NULL)
-- Grégoire Launay--Bécue

-- 44. Donner le code du ou des départements accueillant le plus grand nombre de sociétés
SELECT v.CodeDeptV
FROM VILLE v, ENTREPRISE ent
WHERE v.CodeV = ent.CodeV
GROUP BY v.CodeDeptV
HAVING COUNT(ent.NSIRET) = (
    SELECT MAX(nb_societes)
    FROM (
        SELECT COUNT(ent2.NSIRET) AS nb_societes
        FROM VILLE v2, ENTREPRISE ent2
        WHERE v2.CodeV = ent2.CodeV
        GROUP BY v2.CodeDeptV
    )
)
-- Grégoire Launay--Bécue

-- 45. Donner le code des départements accueillant toutes les sociétés du groupe
SELECT v.CodeDeptV
FROM VILLE v, ENTREPRISE ent
WHERE v.CodeV = ent.CodeV
GROUP BY v.CodeDeptV, ent.GroupeSoc
HAVING COUNT(DISTINCT ent.NSIRET) = (
    SELECT COUNT(ent2.NSIRET)
    FROM ENTREPRISE ent2
    WHERE ent2.GroupeSoc = ent.GroupeSoc
)
-- Grégoire Launay--Bécue

-- 46. Donner le code des départements accueillant plus de société que le département 75
SELECT v.CodeDeptV
FROM VILLE v, ENTREPRISE ent
WHERE v.CodeV = ent.CodeV
GROUP BY v.CodeDeptV
HAVING COUNT(ent.NSIRET) > (
    SELECT COUNT(ent2.NSIRET)
    FROM VILLE v2, ENTREPRISE ent2
    WHERE v2.CodeV = ent2.CodeV
      AND v2.CodeDeptV = '75'
    GROUP BY v2.CodeDeptV
)
-- Grégoire Launay--Bécue
