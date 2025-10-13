CREATE TABLE Societe (
  CodeSoc    NUMBER(6)    CONSTRAINT pk_societe PRIMARY KEY,
  RaisonSoc  VARCHAR2(100) NOT NULL,
  RueSoc     VARCHAR2(120),
  CpSoc      VARCHAR2(10),
  VilleSoc   VARCHAR2(80),
  DomaineSoc VARCHAR2(80)
);

-- 2.1 Grégoire Launay--Bécue
SELECT em.NomE, em.PrenomE
FROM EMPLOYE em
WHERE NOT EXISTS (
    SELECT *
    FROM FROM EMPLOYE em2
    WHERE NOT EXISTS (
        SELECT *
        FROM PLANIFIER pl
        WHERE to_chart(pl.DATEI
        , 'YYYY') = to_chart(CURRENT_DATE
        , 'YYYY')
        AND pl.HeureI = 0.5
      )
)

-- 2.2 Grégoire Launay--Bécue
SELECT em.NomE, em.PrenomE
FROM EMPLOYE em
WHERE NOT EXISTS (
    SELECT *
    FROM FROM EMPLOYE em2
    WHERE NOT EXISTS (
        SELECT *
        FROM PLANIFIER pl
        WHERE to_chart(pl.DATEI
        , 'YYYY') = to_chart(CURRENT_DATE
        , 'YYYY')
        AND pl. = 0.5
      )
)