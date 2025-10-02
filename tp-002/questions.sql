-- 1. Pour chaque client, donner sa civilité en clair (Monsieur ou Madame), son nom, son prénom et
-- éventuellement le nom et le domaine de sa société
SELECT cl.CIVC, cl.NomC, cl.PrenomC, so.RaisonSoc, so.DomaineSoc
FROM CLIENT cl, SOCIETE so
WHERE cl.CodeSoc = so.CodeSoc (+);
-- 2. Nom des sociétés ayant effectué au moins une réservation débutant cette année
SELECT COUNT(*)
FROM SOCIETE so, RESERVER re, CLIENT cl
WHERE to_char(re.DATEARR, 'YYYY') = to_char(current_date, 'YYYY')
AND cl.CODESOC = so.CODESOC
AND re.CODEC = cl.CODEC (+);

SELECT to_char(re.DATEARR, 'YYYY')
FROM SOCIETE so, RESERVER re, CLIENT cl


    SELECT *
    FROM RESERVER
-- 3. Nom des sociétés ayant effectué dix réservations débutant cette année
-- 4. Nom des sociétés n’ayant effectué aucune réservation en 2018 (arrivées et départs en 2018)
-- 5. Nom des sociétés ayant effectué toutes réservations débutant cette année
-- 6. Nom des sociétés n’ayant effectué que des réservations cette année (arrivée et départ cette année)
-- 7. Nom et prénom des clients ayant effectué une réservation de 2 nuits
-- 8. Nom et prénom des clients ayant effectué deux réservations en 2019 (ne pas se limiter à une arrivée
-- et un départ cette année)