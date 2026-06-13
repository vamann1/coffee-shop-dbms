
-- Proiect SGBD - Gestiunea unei cafenele
-- Vaman Mircea-George, CSIE, Anul II, Grupa 1061


/* Stergerea  tabelelor existente */
BEGIN
   FOR t IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/

-- ____________ Crearea tabelelor _______________
CREATE TABLE Angajati (
    id_angajat NUMBER(5) PRIMARY KEY,
    nume VARCHAR2(20) NOT NULL,
    prenume VARCHAR2(20) NOT NULL,
    functie VARCHAR2(20),
    salariu NUMBER(10,2) CHECK (salariu > 0),
    data_angajare DATE
);

CREATE TABLE Furnizori (
    id_furnizor NUMBER(5) PRIMARY KEY,
    nume_furnizor VARCHAR2(100) NOT NULL,
    adresa VARCHAR2(200),
    telefon VARCHAR2(15),
    email VARCHAR2(50) UNIQUE
);

CREATE TABLE Produse (
    id_produs NUMBER(5) PRIMARY KEY,
    id_furnizor NUMBER(5),
    denumire VARCHAR2(100),
    pret NUMBER(10,2) CHECK (pret > 0),
    stoc NUMBER(4),
    CONSTRAINT fk_prod_furn FOREIGN KEY (id_furnizor)
        REFERENCES Furnizori(id_furnizor)
);

CREATE TABLE Mese (
    id_masa NUMBER(5) PRIMARY KEY,
    numar_masa NUMBER(2) UNIQUE,
    capacitate NUMBER(2) CHECK (capacitate > 0)
);

CREATE TABLE Comenzi (
    id_comanda NUMBER(5) PRIMARY KEY,
    id_masa NUMBER(5),
    id_angajat NUMBER(5),
    data_comanda DATE DEFAULT SYSDATE,
    total NUMBER(10,2),
    CONSTRAINT fk_com_masa FOREIGN KEY (id_masa)
        REFERENCES Mese(id_masa),
    CONSTRAINT fk_com_ang FOREIGN KEY (id_angajat)
        REFERENCES Angajati(id_angajat)
);

CREATE TABLE DetaliiComanda (
    id_comanda NUMBER(5),
    id_produs NUMBER(5),
    cantitate NUMBER(5),
    subtotal NUMBER(10,2),
    CONSTRAINT pk_detalii PRIMARY KEY (id_comanda, id_produs),
    CONSTRAINT fk_det_com FOREIGN KEY (id_comanda)
        REFERENCES Comenzi(id_comanda),
    CONSTRAINT fk_det_prod FOREIGN KEY (id_produs)
        REFERENCES Produse(id_produs)
);

CREATE TABLE ProgramAngajati (
    id_program NUMBER(5) PRIMARY KEY,
    id_angajat NUMBER(5),
    data_inceput DATE,
    data_sfarsit DATE,
    tura VARCHAR2(10),
    CONSTRAINT fk_prog_ang FOREIGN KEY (id_angajat)
        REFERENCES Angajati(id_angajat)
);

CREATE TABLE Plati (
    id_plata NUMBER(5) PRIMARY KEY,
    id_comanda NUMBER(5),
    tip_plata VARCHAR2(20),
    suma NUMBER(10,2),
    data_plata DATE DEFAULT SYSDATE,
    CONSTRAINT fk_plata_com FOREIGN KEY (id_comanda)
        REFERENCES Comenzi(id_comanda)
);


/* ALTER */
ALTER TABLE Angajati
ADD CONSTRAINT salariu_min CHECK (salariu >= 500);

ALTER TABLE DetaliiComanda
ADD CONSTRAINT chk_det_cantitate CHECK (cantitate > 0);

ALTER TABLE Furnizori
ADD CONSTRAINT chk_telefon_format CHECK (REGEXP_LIKE(telefon, '^07[0-9]{8}$'));

ALTER TABLE Furnizori
ADD CONSTRAINT uq_furnizori_telefon UNIQUE (telefon);

ALTER TABLE Furnizori
ADD CONSTRAINT uq_furnizori_telefon UNIQUE (telefon);

/* View pentru verificarea daca suma platilor este egala cu totalul din Comenzi. */
CREATE OR REPLACE VIEW v_verif_plati AS
SELECT c.id_comanda,
       c.total AS total_comanda,
       NVL(SUM(p.suma), 0) AS total_plati,
       c.total - NVL(SUM(p.suma), 0) AS diferenta
FROM Comenzi c, Plati p
WHERE c.id_comanda = p.id_comanda(+)
GROUP BY c.id_comanda, c.total;

-- OPERATII DML
INSERT INTO Furnizori VALUES (100, 'Confex SRL', 'Bucuresti', '0738272929', 'confex_business@gmail.ro');
INSERT INTO Furnizori VALUES (101, 'Dropshot Coffee', 'Cluj-Napoca', '0739240185', 'dropshot_enq@gmail.ro');
INSERT INTO Furnizori VALUES (102, 'BeansCo', 'Brasov', '0720001111', 'sales@beansco.ro');
INSERT INTO Furnizori VALUES (103, 'LactoFresh', 'Targoviste', '0723456001', 'comenzi@lactofresh.ro');
INSERT INTO Furnizori VALUES (104, 'Bakery Hub', 'Bucuresti', '0723456002', 'office@bakeryhub.ro');
INSERT INTO Furnizori VALUES (105, 'SweetLab SRL', 'Sibiu', '0723456003', 'contact@sweetlab.ro');
INSERT INTO Furnizori VALUES (106, 'Green Citrus', 'Constanta', '0723456004', 'vanzari@greencitrus.ro');
INSERT INTO Furnizori VALUES (107, 'AquaCarpatica Distrib', 'Piatra Neamt', '0723456005', 'comenzi@aquadist.ro');
INSERT INTO Furnizori VALUES (108, 'Roastery Nord', 'Iasi', '0723456006', 'hello@roasterynord.ro');
INSERT INTO Furnizori VALUES (109, 'PaperCup Supply', 'Bucuresti', '0723456007', 'support@papercup.ro');
SELECT * FROM Furnizori;

INSERT INTO Produse VALUES (100, 107, 'Apa Minerala 0.5L', 7, 120);
INSERT INTO Produse VALUES (101, 106, 'Limonada', 14, 60);
INSERT INTO Produse VALUES (102, 101, 'Cold Brew', 18, 40);
INSERT INTO Produse VALUES (103, 108, 'Espresso', 9, 80);
INSERT INTO Produse VALUES (104, 108, 'Americano', 12, 70);
INSERT INTO Produse VALUES (105, 102, 'Cappuccino', 15, 65);
INSERT INTO Produse VALUES (106, 102, 'Flat White', 16, 55);
INSERT INTO Produse VALUES (107, 104, 'Croissant cu unt', 11, 45);
INSERT INTO Produse VALUES (108, 105, 'Cheesecake', 18, 25);
INSERT INTO Produse VALUES (109, 104, 'Sandwich sunca', 22, 30);
INSERT INTO Produse VALUES (110, 105, 'Brownie', 13, 35);
INSERT INTO Produse VALUES (111, 101, 'Latte', 17, 50);
SELECT * FROM Produse;

INSERT INTO Mese VALUES (100, 1, 2);
INSERT INTO Mese VALUES (101, 2, 2);
INSERT INTO Mese VALUES (102, 3, 4);
INSERT INTO Mese VALUES (103, 4, 4);
INSERT INTO Mese VALUES (104, 5, 2);
INSERT INTO Mese VALUES (105, 6, 2);
INSERT INTO Mese VALUES (106, 7, 4);
INSERT INTO Mese VALUES (107, 8, 2);
INSERT INTO Mese VALUES (108, 9, 4);
INSERT INTO Mese VALUES (109, 10, 4);
SELECT * FROM Mese;

INSERT INTO Angajati VALUES (100, 'Georgescu', 'Andrei', 'Manager', 5600, DATE '2024-01-17');
INSERT INTO Angajati VALUES (101, 'Ghiba', 'Maria', 'Casier', 3300, DATE '2024-03-15');
INSERT INTO Angajati VALUES (102, 'Popescu', 'Ion', 'Ospatar', 3400, DATE '2024-05-08');
INSERT INTO Angajati VALUES (103, 'Marinescu', 'Delia', 'Barista', 3800, DATE '2024-04-13');
INSERT INTO Angajati VALUES (104, 'Stan', 'Radu', 'Ospatar', 3450, DATE '2024-06-01');
INSERT INTO Angajati VALUES (105, 'Dima', 'Alexandra', 'Barista', 3900, DATE '2024-06-10');
INSERT INTO Angajati VALUES (106, 'Iordache', 'Teodora', 'Barista', 3850, DATE '2024-02-05');
INSERT INTO Angajati VALUES (107, 'Ilie', 'Vlad', 'Ospatar', 3425, DATE '2024-02-20');
INSERT INTO Angajati VALUES (108, 'Matei', 'Bianca', 'Casier', 3250, DATE '2024-07-02');
INSERT INTO Angajati VALUES (109, 'Rusu', 'Mihai', 'Ospatar', 3500, DATE '2024-08-12');
SELECT * FROM Angajati;

INSERT INTO ProgramAngajati VALUES (400, 100, DATE '2025-12-01', DATE '2025-12-31', 'Full');
INSERT INTO ProgramAngajati VALUES (401, 101, DATE '2025-12-01', DATE '2025-12-31', 'Seara');
INSERT INTO ProgramAngajati VALUES (402, 102, DATE '2025-12-01', DATE '2025-12-31', 'Dimineata');
INSERT INTO ProgramAngajati VALUES (403, 103, DATE '2025-12-01', DATE '2025-12-31', 'Dimineata');
INSERT INTO ProgramAngajati VALUES (404, 104, DATE '2025-12-01', DATE '2025-12-31', 'Seara');
INSERT INTO ProgramAngajati VALUES (405, 105, DATE '2025-12-01', DATE '2025-12-31', 'Seara');
INSERT INTO ProgramAngajati VALUES (406, 106, DATE '2025-12-01', DATE '2025-12-31', 'Dimineata');
INSERT INTO ProgramAngajati VALUES (407, 107, DATE '2025-12-01', DATE '2025-12-31', 'Seara');
INSERT INTO ProgramAngajati VALUES (408, 108, DATE '2025-12-01', DATE '2025-12-31', 'Full');
INSERT INTO ProgramAngajati VALUES (409, 109, DATE '2025-12-01', DATE '2025-12-31', 'Dimineata');
SELECT * FROM ProgramAngajati;

/* Comenzi: insert pe coloane */
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (200, 100, 102, SYSDATE - 1);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (201, 101, 103, SYSDATE - 1);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (202, 102, 107, SYSDATE - 1);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (203, 103, 105, SYSDATE - 3/24);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (204, 104, 104, SYSDATE - 4/24);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (205, 105, 106, SYSDATE - 2);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (206, 106, 109, SYSDATE - 1/24);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (207, 107, 102, SYSDATE - 1);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (208, 108, 107, SYSDATE);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (209, 109, 103, SYSDATE);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (210, 102, 105, SYSDATE);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (211, 103, 106, SYSDATE - 0.5/24);
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (212, 104, 108, SYSDATE);
SELECT * FROM Comenzi;

INSERT INTO DetaliiComanda VALUES (200, 102, 1, 18);
INSERT INTO DetaliiComanda VALUES (201, 106, 1, 16);
INSERT INTO DetaliiComanda VALUES (202, 105, 1, 15);
INSERT INTO DetaliiComanda VALUES (202, 107, 1, 11);
INSERT INTO DetaliiComanda VALUES (203, 109, 1, 22);
INSERT INTO DetaliiComanda VALUES (204, 101, 1, 14);
INSERT INTO DetaliiComanda VALUES (205, 108, 1, 18);
INSERT INTO DetaliiComanda VALUES (206, 104, 1, 12);
INSERT INTO DetaliiComanda VALUES (206, 100, 1, 7);
INSERT INTO DetaliiComanda VALUES (207, 111, 1, 17);
INSERT INTO DetaliiComanda VALUES (207, 107, 1, 11);
INSERT INTO DetaliiComanda VALUES (207, 100, 1, 7);
INSERT INTO DetaliiComanda VALUES (207, 106, 1, 16);
INSERT INTO DetaliiComanda VALUES (208, 103, 1, 9);
INSERT INTO DetaliiComanda VALUES (208, 108, 1, 18);
INSERT INTO DetaliiComanda VALUES (209, 110, 1, 13);
INSERT INTO DetaliiComanda VALUES (211, 104, 1, 12);
INSERT INTO DetaliiComanda VALUES (211, 103, 1, 9);
INSERT INTO DetaliiComanda VALUES (211, 100, 1, 7);
INSERT INTO DetaliiComanda VALUES (212, 108, 1, 18);
INSERT INTO DetaliiComanda VALUES (212, 104, 1, 12);
SELECT * FROM DetaliiComanda;

INSERT INTO Plati VALUES (300, 200, 'CARD', 18, SYSDATE - 1 + 10/1440);
INSERT INTO Plati VALUES (301, 201, 'CASH', 16, SYSDATE - 1 + 15/1440);
INSERT INTO Plati VALUES (302, 202, 'CARD', 15, SYSDATE - 1 + 20/1440);
INSERT INTO Plati VALUES (303, 202, 'CASH', 11, SYSDATE - 1 + 22/1440);
INSERT INTO Plati VALUES (304, 203, 'CARD', 22, SYSDATE - 3/24 + 5/1440);
INSERT INTO Plati VALUES (305, 204, 'CASH', 14, SYSDATE - 4/24 + 8/1440);
INSERT INTO Plati VALUES (306, 205, 'CARD', 18, SYSDATE - 2 + 30/1440);
INSERT INTO Plati VALUES (307, 206, 'CASH', 19, SYSDATE - 1/24 + 6/1440);
INSERT INTO Plati VALUES (308, 207, 'CARD', 20, SYSDATE - 1 + 40/1440);
INSERT INTO Plati VALUES (309, 207, 'CASH', 14, SYSDATE - 1 + 45/1440);
INSERT INTO Plati VALUES (310, 208, 'CARD', 9,  SYSDATE + 2/1440);
INSERT INTO Plati VALUES (311, 208, 'CASH', 18, SYSDATE + 3/1440);
INSERT INTO Plati VALUES (312, 209, 'CARD', 13, SYSDATE + 4/1440);
INSERT INTO Plati VALUES (313, 210, 'CARD', 24, SYSDATE + 6/1440);
INSERT INTO Plati VALUES (314, 211, 'CASH', 28, SYSDATE - 0.5/24 + 7/1440);
INSERT INTO Plati VALUES (315, 212, 'CARD', 12, SYSDATE + 8/1440);
INSERT INTO Plati VALUES (316, 212, 'CASH', 18, SYSDATE + 9/1440);
SELECT * FROM Plati;

-- Modificarea inregistrarilor 
UPDATE Produse SET pret = pret * 1.05 WHERE id_furnizor = 108;
UPDATE Produse SET stoc = stoc - 3 WHERE denumire IN ('Espresso', 'Cappuccino', 'Flat White');
UPDATE Angajati SET salariu = salariu + 300 WHERE functie = 'Barista';
UPDATE Angajati SET functie = 'Barista Senior', salariu = salariu + 400
WHERE nume = 'Marinescu' AND prenume = 'Delia';

DELETE FROM Comenzi WHERE id_comanda = 207;
INSERT INTO Comenzi VALUES (207, 107, 102, SYSDATE - 1, 34);
ROLLBACK;

/* Stergerea si recuperarea unei tabele */
DROP TABLE Produse CASCADE CONSTRAINTS;
SHOW RECYCLEBIN;
FLASHBACK TABLE Produse TO BEFORE DROP;

-- INTEROGARI VARIATE
/*1.Sa se selecteze produsele cu pretul mai mare de 15.*/
SELECT id_produs, denumire, pret
FROM Produse
WHERE pret > 15;

/*2.Sa se selecteze comenzile impreuna cu numele angajatului care le-a preluat.*/
SELECT c.id_comanda, a.nume, a.prenume
FROM Comenzi c, Angajati a
WHERE c.id_angajat = a.id_angajat;

/*3.Sa se selecteze comenzile, masa la care s-a dat comanda si sa se ordoneze in functie de numarul mesei.*/
SELECT c.id_comanda, m.numar_masa, a.nume, c.data_comanda, c.total
FROM Comenzi c, Mese m, Angajati a
WHERE c.id_masa = m.id_masa
  AND c.id_angajat = a.id_angajat
ORDER BY numar_masa;

/*4. Sa se afiseze data tuturor comenzilor in formatul DD-MM-YYYY HH24:MI*/
SELECT id_comanda, TO_CHAR(data_comanda, 'DD-MM-YYYY HH24:MI') AS data_formatata
FROM Comenzi;

/*5.Sa se selecteze numarul total al comenzilor*/
SELECT COUNT(id_comanda) AS nr_comenzi
FROM Comenzi;

/*6.Sa se selecteze numarul de comenzi preluate de fiecare angajat.*/
SELECT c.id_angajat, a.nume, a.prenume, COUNT(c.id_comanda) AS nr_comenzi
FROM Comenzi c, Angajati a
WHERE c.id_angajat = a.id_angajat
GROUP BY c.id_angajat, a.nume, a.prenume;

/*7.Sa se selecteze angajatii care au preluat o comanda.*/
SELECT c.id_angajat, a.nume, a.prenume, COUNT(*) AS nr_comenzi
FROM Comenzi c, Angajati a
WHERE c.id_angajat = a.id_angajat
GROUP BY c.id_angajat, a.nume, a.prenume
HAVING COUNT(c.id_angajat) = 1;

/*8.Sa se selecteze angajatii cu salariu peste medie.*/
SELECT id_angajat, nume, prenume, salariu
FROM Angajati
WHERE salariu > (SELECT AVG(salariu) FROM Angajati);

/*9.Sa se selecteze produsele care apar in macar o comanda, si de cate ori au aparut.*/
SELECT p.id_produs, p.denumire, COUNT(DISTINCT d.id_comanda) AS nr_aparitii
FROM Produse p, DetaliiComanda d
WHERE p.id_produs = d.id_produs
GROUP BY p.id_produs, p.denumire;

/*10.Clasifica produsele in functie de nivelul de pret*/
SELECT denumire,
CASE
    WHEN pret < 10 THEN 'IEFTIN'
    WHEN pret BETWEEN 10 AND 20 THEN 'MEDIU'
    ELSE 'SCUMP'
END AS categorie
FROM Produse;

/*11.Clasifica comenzile dupa valoare*/
SELECT id_comanda,
       DECODE(SIGN(total - 30), -1, 'Comanda mica', 0, 'Comanda medie', 1, 'Comanda mare') AS tip_comanda
FROM Comenzi;

/*12.Sa se afiseze angajatii care nu au preluat comenzi*/
SELECT id_angajat FROM Angajati
MINUS
SELECT id_angajat FROM Comenzi;

INSERT INTO Produse VALUES (112, 108, 'Biscuiti', 9, 0);
/*13.Sa se selecteze produsele mai ieftine de 10, sau cele care nu au stoc.*/
SELECT id_produs, denumire FROM Produse WHERE pret < 10
UNION
SELECT id_produs, denumire FROM Produse WHERE stoc = 0;

/*14.Sa se afiseze pretul minim, maxim si mediu al produselor.*/
SELECT MIN(pret), MAX(pret), ROUND(AVG(pret), 2)
FROM Produse;

/* Adaugarea coloanei id_manager (cheie externa recursiva) - necesara pt. interogarile 15-20 */
ALTER TABLE Angajati ADD (id_manager NUMBER(5));
ALTER TABLE Angajati
  ADD CONSTRAINT fk_ang_manager FOREIGN KEY (id_manager) REFERENCES Angajati(id_angajat);

UPDATE Angajati SET id_manager = 100 WHERE id_angajat IN (101, 108, 103, 107);
UPDATE Angajati SET id_manager = 103 WHERE id_angajat IN (105, 106);
UPDATE Angajati SET functie = 'Ospatar Sef' WHERE id_angajat = 107;
UPDATE Angajati SET id_manager = 107 WHERE id_angajat IN (102, 104, 109);

/*15. Sa se afiseze ierarhia angajatilor indentata*/
SELECT
  LEVEL AS nivel,
  LPAD(' ', (LEVEL-1)*2) || a.nume || ' ' || a.prenume AS angajat,
  a.functie, a.id_angajat, a.id_manager
FROM Angajati a
START WITH a.id_manager IS NULL
CONNECT BY PRIOR a.id_angajat = a.id_manager;

/*16.Sa se afiseze ierarhia angajatilor folosind SYS_CONNECT_BY_PATH*/
SELECT id_angajat, nume, LEVEL AS NIVEL,
SYS_CONNECT_BY_PATH(id_angajat, '/') AS ID_Superiori
FROM Angajati
START WITH id_angajat = 100
CONNECT BY PRIOR id_angajat = id_manager;

/*17. Sa se afiseze functiile angajatilor in fraze.*/
SELECT 'Angajatul ' || INITCAP(nume) || ' ' || INITCAP(prenume) ||
' are functia ' || functie AS mesaj
FROM Angajati;

/*18. Sa se afiseze vechimea angajatilor in zile si in luni*/
SELECT id_angajat, nume, prenume,
TRUNC(SYSDATE - data_angajare) AS vechime_zile,
TRUNC(MONTHS_BETWEEN(SYSDATE, data_angajare)) AS vechime_luni
FROM Angajati;

/*19.Pentru fiecare angajat, afisati urmatoarea zi de luni dupa data angajarii, ultima zi a lunii angajarii si data de dupa 6 luni.*/
SELECT id_angajat, nume, data_angajare,
NEXT_DAY(data_angajare, 'MONDAY') AS urmatoarea_luni,
LAST_DAY(data_angajare) AS ultima_zi_luna,
ADD_MONTHS(data_angajare, 6) AS dupa_6_luni
FROM Angajati;

/*20.Sa se afiseze pentru fiecare angajat managerul; daca nu are manager, sa se afiseze 0; si marcati daca are manager (DA/NU).*/
SELECT id_angajat, nume, prenume,
NVL(id_manager, 0) AS manager_sau_0,
NVL2(id_manager, 'DA', 'NU') AS are_manager
FROM Angajati;

/*21. Sa se creeze un view cu managerii si nr lor de subordonati*/
CREATE OR REPLACE VIEW v_manageri_subordonati AS
SELECT m.id_angajat, m.nume, m.prenume, COUNT(*) as nr_subordonati
FROM Angajati a, Angajati m
WHERE a.id_manager = m.id_angajat
GROUP BY m.id_angajat, m.nume, m.prenume
ORDER BY nr_subordonati DESC;

SELECT * FROM v_manageri_subordonati;

/*22. Sa se creeze un sinonim pentru tabela angajati*/
CREATE SYNONYM ang FOR Angajati;
SELECT * FROM ang;

/*23. Sa se creeze un index pe coloana nume din angajati*/
CREATE INDEX idx_angajati_nume ON Angajati(nume);
SELECT * FROM Angajati WHERE nume = 'Georgescu';

/*24.Sa se afiseze pentru fiecare produs valoarea totala a unitatilor vandute si NULL daca produsul nu s-a vandut niciodata*/
SELECT p.id_produs, p.denumire, p.pret * NULLIF(SUM(d.cantitate), 0) AS valoare_totala_vanduta
FROM Produse p, DetaliiComanda d
WHERE p.id_produs = d.id_produs(+)
GROUP BY p.id_produs, p.denumire, p.pret;

/*25.Sa se selecteze angajatii care au preluat mai multe comenzi decat media numarului de comenzi preluate de fiecare angajat.*/
SELECT a.id_angajat, a.nume, a.prenume, COUNT(c.id_comanda) as nr_comenzi
FROM Angajati a, Comenzi c
WHERE a.id_angajat = c.id_angajat
GROUP BY a.id_angajat, a.nume, a.prenume
HAVING COUNT(c.id_comanda) >
( SELECT AVG(nr_comenzi)
  FROM (SELECT COUNT(id_comanda) AS nr_comenzi FROM Comenzi GROUP BY id_angajat) );

/*Actualizarea schemei (sem. II) 
 Stergerea coloanelelor derivate si adaugam pret_unitar (pretul din momentul comenzii) */
ALTER TABLE Comenzi DROP COLUMN total;
ALTER TABLE DetaliiComanda DROP COLUMN subtotal;
ALTER TABLE DetaliiComanda ADD pret_unitar NUMBER(10,2);

UPDATE DetaliiComanda d
SET pret_unitar = (SELECT pret FROM Produse WHERE id_produs = d.id_produs);
COMMIT;


SET SERVEROUTPUT ON;

-- B. Utilizarea comenzilor SQL in context de LDD si LMD
-- =====================================================================

/* B.1. Sa se afiseze pentru fiecare angajat numele complet, functia, vechimea
   in luni si id-ul managerului (daca are) in ordinea vechimii. */
DECLARE
    CURSOR c_ang IS
        SELECT INITCAP(nume) || ' ' || INITCAP(prenume) nume_intreg,
               functie,
               TRUNC(MONTHS_BETWEEN(SYSDATE, data_angajare), 0) vechime_luni,
               NVL2(id_manager, TO_CHAR(id_manager), 'Nu are manager') AS id_manager_daca
        FROM Angajati
        ORDER BY vechime_luni DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Angajati');
    DBMS_OUTPUT.PUT_LINE('________________________________');
    FOR rec IN c_ang LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.nume_intreg, 25) || RPAD(rec.functie, 18) ||
         'Vechime: ' || rec.vechime_luni || ' luni | ' || rec.id_manager_daca);
    END LOOP;
END;
/

/* B.2. Sa se afiseze pentru fiecare angajat care a preluat comenzi: numarul de comenzi,
   valoarea totala vanduta, valoarea medie pe comanda si ultima data cand a preluat o comanda. */
DECLARE
    CURSOR c_vanzari IS
        SELECT a.nume ||' ' || a.prenume angajat,
        COUNT(DISTINCT c.id_comanda) nr_comenzi,
        SUM(d.cantitate * d.pret_unitar) valoare_totala,
        ROUND(SUM(d.cantitate * d.pret_unitar)/COUNT(DISTINCT c.id_comanda), 2) medie,
        MAX(c.data_comanda) ultima_comanda
        FROM Angajati a, Comenzi c, DetaliiComanda d
        WHERE a.id_angajat = c.id_angajat
        AND c.id_comanda = d.id_comanda
        GROUP BY a.nume, a.prenume
        ORDER BY valoare_totala DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Raport vanzari');
    DBMS_OUTPUT.PUT_LINE('_______________________________________');
    FOR rec IN c_vanzari LOOP
        DBMS_OUTPUT.PUT_LINE(rec.angajat || ' | Comenzi: ' || rec.nr_comenzi ||
        ' | Total: ' || rec.valoare_totala || ' lei' ||
        ' | Medie: ' || rec.medie || ' lei' ||
        ' | Ultima comanda: ' || TO_CHAR(rec.ultima_comanda, 'DD-MM-YYYY'));
    END LOOP;
END;
/

/* B.3. Sa se mareasca salariul cu un procent citit de la tastatura angajatilor cu functia Ospatar. */
DECLARE
    V_PROCENT NUMBER(3) := &procent;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Marire salarii ospatari');
    EXECUTE IMMEDIATE 'UPDATE ANGAJATI SET SALARIU = SALARIU * ' || V_PROCENT || ' WHERE FUNCTIE = ''Ospatar''';
    DBMS_OUTPUT.PUT_LINE('S-au marit ' || SQL%ROWCOUNT || ' salarii cu ' || V_PROCENT || '%');
    ROLLBACK;
END;
/

/* B.4. Sa se creeze un view numit TopProduse cu cantitatea totala vanduta din fiecare produs.
   Daca exista deja un view cu acelasi nume sa se inlocuiasca, iar la final sa se interogheze. */
DECLARE
   v_nume_view VARCHAR2(30) := 'TopProduse';
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Top produse');
   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || v_nume_view || ' AS SELECT p.id_produs, p.denumire,
   SUM(d.cantitate) AS total_vandut
       FROM Produse p, DetaliiComanda d
       WHERE p.id_produs = d.id_produs
       GROUP BY p.id_produs, p.denumire';
   DBMS_OUTPUT.PUT_LINE('View-ul ' || v_nume_view || ' a fost creat.');
END;
/
SELECT * FROM TopProduse ORDER BY total_vandut DESC;

/* B.5. Sa se stearga toate platile aferente comenzilor mai vechi de 6 luni.
   La final sa se afiseze cate inregistrari au fost sterse. */
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   EXECUTE IMMEDIATE 'DELETE FROM Plati WHERE ID_COMANDA IN
   (SELECT id_comanda FROM Comenzi WHERE data_comanda < ADD_MONTHS(SYSDATE, -6))';
   DBMS_OUTPUT.PUT_LINE('Au fost sterse ' || SQL%ROWCOUNT || ' plati mai vechi de 6 luni.');
   ROLLBACK;
END;
/

-- =====================================================================
-- C. Structuri alternative si repetitive
-- =====================================================================

/* C.1. Sa se afiseze pentru fiecare angajat categoria salariala (Entry-level, Mid-level,
   Senior) folosind structura IF-ELSIF. */
DECLARE
   CURSOR c_ang IS
      SELECT id_angajat, nume, prenume, salariu FROM Angajati ORDER BY salariu;
   v_categorie VARCHAR2(20);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Categorii salariale');
   DBMS_OUTPUT.PUT_LINE('Nume                     Categorie');
   DBMS_OUTPUT.PUT_LINE('___________________________________________');
   FOR rec IN c_ang LOOP
      IF rec.salariu < 3500 THEN
         v_categorie := 'Entry-level';
      ELSIF rec.salariu BETWEEN 3500 AND 4500 THEN
         v_categorie := 'Mid-level';
      ELSE
         v_categorie := 'Senior';
      END IF;
      DBMS_OUTPUT.PUT_LINE(RPAD(rec.nume || ' ' || rec.prenume, 25) || v_categorie);
   END LOOP;
END;
/

/* C.2. Sa se afiseze bonusul de care beneficiaza fiecare angajat in functie de vechimea
   in luni, folosind CASE. */
DECLARE
   v_bonus NUMBER;
   CURSOR c_ang IS
      SELECT nume, prenume, salariu, MONTHS_BETWEEN(SYSDATE, data_angajare) vechime_luni FROM Angajati;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('________________________________________');
   FOR r IN c_ang LOOP
      CASE
         WHEN r.vechime_luni < 6  THEN v_bonus := 0;
         WHEN r.vechime_luni < 12 THEN v_bonus := 200;
         WHEN r.vechime_luni < 18 THEN v_bonus := 350;
         ELSE v_bonus := 500;
      END CASE;
      DBMS_OUTPUT.PUT_LINE(RPAD(r.nume || ' ' || r.prenume, 25) || 'Bonus: ' || v_bonus || ' lei');
   END LOOP;
END;
/

/* C.3. Folosind un FOR LOOP sa se calculeze valoarea totala a stocului din depozit si sa se
   afiseze produsele al caror stoc a scazut sub 40 de bucati. */
DECLARE
   v_total_stoc NUMBER := 0;
   CURSOR c_prod IS
      SELECT id_produs, denumire, pret, stoc FROM Produse ORDER BY id_produs;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('____________________________________');
   DBMS_OUTPUT.PUT_LINE('PRODUSE CU STOC MIC: ');
   FOR r IN c_prod LOOP
      CONTINUE WHEN r.stoc = 0;
      v_total_stoc := v_total_stoc + (r.pret * r.stoc);
      IF r.stoc < 40 THEN
         DBMS_OUTPUT.PUT_LINE('  ! ' || RPAD(r.denumire, 25) || ' stoc: ' || r.stoc || ' bucati');
      END IF;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('_____________________________________');
   DBMS_OUTPUT.PUT_LINE('Valoare totala a stocului: ' || v_total_stoc || ' lei');
END;
/

/* C.4. Sa se calculeze folosind un WHILE LOOP suma salariilor angajatilor pana cand aceasta
   depaseste un buget dat, afisand cati angajati incap in buget. */
DECLARE
   CURSOR C IS
      SELECT nume, prenume, salariu FROM Angajati ORDER BY salariu ASC;
   v_buget NUMBER := 15000;
   v_suma NUMBER := 0;
   v_nr_angajati NUMBER := 0;
   r C%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('Buget disponibil: ' || v_buget || ' lei');
   OPEN C;
   FETCH C INTO r;
   WHILE C%FOUND AND (v_suma + r.salariu) <= v_buget LOOP
      v_suma := v_suma + r.salariu;
      v_nr_angajati := v_nr_angajati + 1;
      DBMS_OUTPUT.PUT_LINE(RPAD(r.nume || ' ' || r.prenume, 25) ||
                           r.salariu || ' lei | suma curenta: ' || v_suma || ' lei');
      FETCH C INTO r;
   END LOOP;
   CLOSE C;
   DBMS_OUTPUT.PUT_LINE('__________________________________________');
   DBMS_OUTPUT.PUT_LINE('Incap ' || v_nr_angajati || ' angajati in bugetul de ' || v_buget || ' lei.');
END;
/

-- =====================================================================
-- D. Colectii de date
-- =====================================================================

/* D.1. Sa se afiseze numele, prenumele si salariul angajatilor, ordonati descrescator dupa
   salariu, folosind o colectie INDEX BY TABLE indexata cu PLS_INTEGER. */
DECLARE
   TYPE T_REC IS RECORD (
      nume      Angajati.nume%TYPE,
      prenume   Angajati.prenume%TYPE,
      salariu   Angajati.salariu%TYPE);
   TYPE T_ANG IS TABLE OF T_REC INDEX BY PLS_INTEGER;
   V   T_ANG;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_____________________________________________');
   SELECT nume, prenume, salariu BULK COLLECT INTO V
   FROM Angajati ORDER BY salariu DESC;
   DBMS_OUTPUT.PUT_LINE('Nr angajati: ' || V.COUNT);
   FOR I IN 1..V.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(I || ' -> ' || RPAD(V(I).nume || ' ' || V(I).prenume, 25) || V(I).salariu || ' lei');
   END LOOP;
END;
/

/* D.2. Sa se afiseze, folosind o colectie INDEX BY TABLE indexata cu VARCHAR2, salariul
   fiecarui angajat, indexat dupa numele complet al acestuia. */
DECLARE
   TYPE T_SAL IS TABLE OF Angajati.salariu%TYPE INDEX BY VARCHAR2(50);
   V   T_SAL;
   I   VARCHAR2(50);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('__________________________________________________');
   FOR R IN (SELECT nume || ' ' || prenume AS np, salariu FROM Angajati ORDER BY salariu DESC) LOOP
      V(R.np) := R.salariu;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('Nr angajati: ' || V.COUNT);
   I := V.FIRST;
   WHILE I IS NOT NULL LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(I, 25) || '-> ' || V(I) || ' lei');
      I := V.NEXT(I);
   END LOOP;
END;
/

/* D.3. Folosind o colectie de tip NESTED TABLE sa se afiseze denumirea produselor si valoarea
   totala vanduta din fiecare, ordonate descrescator dupa valoare. */
DECLARE
   TYPE T_REC IS RECORD (
      denumire  Produse.denumire%TYPE,
      valoare   NUMBER);
   TYPE T_PROD IS TABLE OF T_REC;
   V   T_PROD;
   I   PLS_INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_________________________________________________');
   SELECT p.denumire, SUM(d.cantitate * d.pret_unitar) BULK COLLECT INTO V
   FROM Produse p, DetaliiComanda d
   WHERE p.id_produs = d.id_produs
   GROUP BY p.denumire
   ORDER BY SUM(d.cantitate * d.pret_unitar) DESC;
   DBMS_OUTPUT.PUT_LINE('Nr produse vandute: ' || V.COUNT);
   I := V.FIRST;
   WHILE I IS NOT NULL LOOP
      DBMS_OUTPUT.PUT_LINE(I || ' -> ' || RPAD(V(I).denumire, 25) || V(I).valoare || ' lei');
      I := V.NEXT(I);
   END LOOP;
END;
/

/* D.4. Folosind o colectie de tip VARRAY sa se afiseze numele angajatilor care au preluat cel
   putin 2 comenzi si numarul de comenzi preluat de acestia. */
DECLARE
   TYPE T_REC IS RECORD (
      nume_complet VARCHAR2(50),
      nr_comenzi NUMBER);
   TYPE T_ANG IS VARRAY(50) OF T_REC;
   V   T_ANG;
   I   PLS_INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('___________________________________________________');
   SELECT a.nume || ' ' || a.prenume, COUNT(c.id_comanda) nr_comenzi BULK COLLECT INTO V
   FROM Angajati a, Comenzi c
   WHERE a.id_angajat = c.id_angajat
   GROUP BY a.nume, a.prenume
   HAVING COUNT(c.id_comanda) >= 2
   ORDER BY COUNT(c.id_comanda) DESC;
   DBMS_OUTPUT.PUT_LINE('Nr. angajati: ' || V.COUNT);
   I := V.FIRST;
   WHILE I IS NOT NULL LOOP
      DBMS_OUTPUT.PUT_LINE(I || ' -> ' || V(I).nume_complet || ' ' || V(I).nr_comenzi || ' comenzi');
      I := V.NEXT(I);
   END LOOP;
END;
/

/* D.5. Folosind o colectie de tip NESTED TABLE sa se afiseze furnizorii si numarul de produse
   pe care le furnizeaza, ordonati descrescator dupa numarul de produse. */
DECLARE
   TYPE T_REC IS RECORD (
      nume_furnizor Furnizori.nume_furnizor%TYPE,
      oras VARCHAR2(50),
      nr_produse NUMBER);
   TYPE T_FURNIZORI IS TABLE OF T_REC;
   V   T_FURNIZORI;
   I   PLS_INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('____________________________________________');
   SELECT f.nume_furnizor, f.adresa, COUNT(p.id_produs) BULK COLLECT INTO V
   FROM Furnizori f, Produse p
   WHERE f.id_furnizor = p.id_furnizor
   GROUP BY f.nume_furnizor, f.adresa
   ORDER BY COUNT(p.id_produs) DESC;
   DBMS_OUTPUT.PUT_LINE('Nr. furnizori: ' || V.COUNT);
   DBMS_OUTPUT.PUT_LINE('____________________________________________');
   FOR I IN 1..V.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(I || ' -> ' || RPAD(V(I).nume_furnizor, 25) ||
      RPAD(V(I).oras, 20) || ' Produse: ' || V(I).nr_produse);
   END LOOP;
END;
/

/* D.6. Folosind o colectie VARRAY sa se afiseze mesele, numarul de comenzi plasate la fiecare
   masa si valoarea totala a comenzilor de la fiecare masa. */
DECLARE
   TYPE T_REC IS RECORD (
      numar_masa Mese.numar_masa%TYPE,
      capacitate Mese.capacitate%TYPE,
      nr_comenzi NUMBER,
      valoare NUMBER);
   TYPE T_MESE IS VARRAY(20) OF T_REC;
   V T_MESE;
   I PLS_INTEGER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_____________________');
   SELECT m.numar_masa, m.capacitate, COUNT(DISTINCT c.id_comanda),
          SUM(d.cantitate * d.pret_unitar) BULK COLLECT INTO V
   FROM Mese m, Comenzi c, DetaliiComanda d
   WHERE m.id_masa = c.id_masa
     AND c.id_comanda = d.id_comanda
   GROUP BY m.numar_masa, m.capacitate
   ORDER BY m.numar_masa;
   FOR I IN 1..V.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(I || ' -> ' || 'Masa ' || V(I).numar_masa ||
      ' | Nr. Comenzi: ' || V(I).nr_comenzi || ' | Valoare: ' || V(I).valoare || ' lei');
   END LOOP;
END;
/

-- =====================================================================
-- E. Tratarea exceptiilor
-- =====================================================================
-- E.I. Exceptii implicite

/* E.I.1. Sa se insereze un furnizor nou. Daca telefonul exista deja in baza de date, sa se
   trateze exceptia. */
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   INSERT INTO Furnizori VALUES (200, 'Test SRL', 'Bucuresti', '0738272929', 'test@test.ro');
   DBMS_OUTPUT.PUT_LINE('Furnizorul a fost adaugat cu succes.');
   ROLLBACK;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: exista deja un furnizor cu acest telefon.');
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('S-a declansat o exceptie: ' || SQLERRM);
END;
/

/* E.I.2. Sa se caute un produs dupa denumire citita de la tastatura. Daca exista mai multe
   produse cu acea denumire, sa se trateze exceptia. */
DECLARE
   v_denumire Produse.denumire%TYPE := '&denumire';
   v_prod Produse%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   SELECT * INTO v_prod FROM Produse WHERE denumire = v_denumire;
   DBMS_OUTPUT.PUT_LINE('Produs: ' || v_prod.denumire || ' | Pret: ' || v_prod.pret || ' lei' ||
   ' | Stoc: ' || v_prod.stoc);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista niciun produs cu denumirea ' || v_denumire || '.');
   WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('Mai multe produse au denumirea ' || v_denumire || '.');
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('S-a declansat o exceptie: ' || SQLERRM);
END;
/

/* E.I.3. Sa se afiseze datele unui angajat al carui id este citit de la tastatura. Daca
   angajatul nu exista, sa se trateze exceptia. */
DECLARE
   v_id Angajati.id_angajat%TYPE := &id_angajat;
   v_ang Angajati%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   SELECT * INTO v_ang FROM Angajati WHERE id_angajat = v_id;
   DBMS_OUTPUT.PUT_LINE('Nume angajat: ' || v_ang.nume || ' ' || v_ang.prenume ||
    ' | Functie: ' || v_ang.functie || ' | Salariu: ' || v_ang.salariu || ' lei');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista niciun angajat cu id-ul ' || v_id || '.');
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('S-a declansat o exceptie: ' || SQLERRM);
END;
/

/* E.I.4. Sa se stearga un furnizor. Daca furnizorul are produse asociate, sa se trateze
   exceptia care apare. */
DECLARE
   are_produse EXCEPTION;
   PRAGMA EXCEPTION_INIT(are_produse, -2292);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DELETE FROM Furnizori WHERE id_furnizor = 108;
   DBMS_OUTPUT.PUT_LINE('Furnizorul a fost sters.');
   ROLLBACK;
EXCEPTION
   WHEN are_produse THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: Furnizorul nu poate fi sters deoarece are produse asociate in baza de date.');
END;
/

-- E.II. Exceptii explicite

/* E.II.1. Sa se stearga un produs al carui id este citit de la tastatura. Daca produsul nu
   exista, sa se ridice o exceptie definita de utilizator. */
DECLARE
   v_id Produse.id_produs%TYPE := &id_produs;
   produs_inexistent EXCEPTION;
   PRAGMA EXCEPTION_INIT(produs_inexistent, -20000);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DELETE FROM Produse WHERE id_produs = v_id;
   IF SQL%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'Nu exista niciun produs cu id-ul ' || v_id);
   END IF;
   DBMS_OUTPUT.PUT_LINE('Produsul ' || v_id || ' a fost sters.');
   ROLLBACK;
EXCEPTION
   WHEN produs_inexistent THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

/* E.II.2. Sa se verifice daca stocul unui produs este suficient pentru o cantitate ceruta
   citita de la tastatura. Daca stocul este insuficient, sa se ridice o exceptie definita
   de utilizator. */
ACCEPT v_id_produs PROMPT 'Introduceti id-ul produsului cautat: '
ACCEPT v_cantitate PROMPT 'Introduceti cantitatea dorita din produs: '
DECLARE
   v_id_produs Produse.id_produs%TYPE := &v_id_produs;
   v_cantitate NUMBER := &v_cantitate;
   v_stoc Produse.stoc%TYPE;
   v_denumire Produse.denumire%TYPE;
   stoc_insuficient EXCEPTION;
   PRAGMA EXCEPTION_INIT(stoc_insuficient, -20002);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   SELECT denumire, stoc INTO v_denumire, v_stoc FROM Produse WHERE id_produs = v_id_produs;
   IF v_stoc < v_cantitate THEN
      RAISE_APPLICATION_ERROR(-20002, 'Stoc insuficient pentru ' || v_denumire ||
      '. Stoc disponibil: ' || v_stoc || ', cantitate ceruta: ' || v_cantitate || '.');
   END IF;
   DBMS_OUTPUT.PUT_LINE('Stoc suficient pentru ' || v_denumire ||
   '. Stoc disponibil: ' || v_stoc || ' bucati.');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista niciun produs cu id-ul ' || v_id_produs || '.');
   WHEN stoc_insuficient THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

/* E.II.3. Sa se mareasca salariul unui angajat al carui id este citit de la tastatura. Daca
   salariul nou depaseste 10000 lei, sa se ridice o exceptie. */
ACCEPT v_id PROMPT 'Introduceti id-ul angajatului: '
ACCEPT v_marire PROMPT 'Introduceti marimea cu care se mareste salariul: '
DECLARE
   v_id_angajat Angajati.id_angajat%TYPE := &v_id;
   v_marire NUMBER := &v_marire;
   v_salariu_nou NUMBER;
   v_nume VARCHAR2(50);
   salariu_prea_mare EXCEPTION;
   PRAGMA EXCEPTION_INIT(salariu_prea_mare, -20003);
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Marire salariu');
   SELECT nume || ' ' || prenume, salariu + v_marire INTO v_nume, v_salariu_nou
   FROM Angajati WHERE id_angajat = v_id_angajat;
   IF v_salariu_nou > 10000 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Salariul nou (' || v_salariu_nou ||
      ' lei) depaseste limita maxima de 10000 lei.');
   END IF;
   UPDATE Angajati SET salariu = v_salariu_nou WHERE id_angajat = v_id_angajat;
   DBMS_OUTPUT.PUT_LINE('Salariul lui ' || v_nume || ' a fost marit la ' || v_salariu_nou || ' lei.');
   ROLLBACK;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista niciun angajat cu id-ul ' || v_id_angajat || '.');
   WHEN salariu_prea_mare THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

-- =====================================================================
-- F. Gestionarea cursorilor
-- =====================================================================

/* F.1. Cursor explicit fara parametru - parcurgere cu OPEN/FETCH/LOOP.
   Sa se afiseze angajatii care nu au preluat nicio comanda. */
DECLARE
   CURSOR c IS
      SELECT a.id_angajat, a.nume, a.prenume, a.functie
      FROM Angajati a
      WHERE a.id_angajat NOT IN (SELECT id_angajat FROM Comenzi);
   r c%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('______________________');
   IF NOT c%ISOPEN THEN
      OPEN c;
   END IF;
   LOOP
      FETCH c INTO r;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(c%ROWCOUNT || ' -> ' || r.nume || ' ' || r.prenume || ' ' || r.functie);
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('Total angajati fara comenzi: ' || c%ROWCOUNT);
   CLOSE c;
END;
/

/* F.2. Cursor explicit fara parametru - parcurgere FOR.
   Sa se afiseze pentru fiecare furnizor produsele furnizate si pretul acestora. */
DECLARE
   CURSOR c IS
      SELECT f.nume_furnizor, p.denumire, p.pret, p.stoc
      FROM Furnizori f, Produse p
      WHERE f.id_furnizor = p.id_furnizor
      ORDER BY f.nume_furnizor, p.pret DESC;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('__________________');
   FOR rec IN c LOOP
      DBMS_OUTPUT.PUT_LINE(rec.nume_furnizor || ' ' || rec.denumire || ' ' ||
      'Pret: ' || rec.pret || ' lei' || ' | Stoc: ' || rec.stoc);
   END LOOP;
END;
/

/* F.3. Cursor cu parametru. Sa se afiseze comenzile dintr-o anumita perioada, impreuna cu
   angajatul care le-a preluat si valoarea totala a fiecarei comenzi. Perioada se citeste
   de la tastatura. */
ACCEPT v_data_inceput PROMPT 'Introduceti data de inceput (DD-MM-YYYY):'
ACCEPT v_data_sfarsit PROMPT 'Introduceti data de sfarsit (DD-MM-YYYY):'
DECLARE
   CURSOR c (p_inceput DATE, p_sfarsit DATE) IS
      SELECT c.id_comanda, a.nume || ' ' || a.prenume angajat,
      c.data_comanda, SUM(d.cantitate * d.pret_unitar) valoare
      FROM Comenzi c, Angajati a, DetaliiComanda d
      WHERE c.id_angajat = a.id_angajat
      AND c.id_comanda = d.id_comanda
      AND TRUNC(c.data_comanda) BETWEEN p_inceput AND p_sfarsit
      GROUP BY c.id_comanda, a.nume, a.prenume, c.data_comanda
      ORDER BY c.data_comanda;
   r c%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_____________________');
   OPEN C(TO_DATE('&v_data_inceput', 'DD-MM-YYYY'), TO_DATE('&v_data_sfarsit', 'DD-MM-YYYY'));
   LOOP
      FETCH c INTO r;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(c%ROWCOUNT || ' -> ' || 'Comanda ' || r.id_comanda ||
    ' | ' || RPAD(r.angajat, 25) || ' | ' || TO_CHAR(r.data_comanda, 'DD-MM-YYYY')
    || ' | ' || r.valoare || ' lei');
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('Total comenzi: ' || c%ROWCOUNT);
   CLOSE c;
END;
/

/* F.4. Cursor implicit. Sa se mareasca cu 5% pretul produselor care au fost comandate de cel
   putin 6 ori. Sa se afiseze numarul produselor modificate si id-urile acestora. */
DECLARE
   TYPE T_PROD IS TABLE OF NUMBER;
   v_produse T_PROD;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   UPDATE Produse SET pret = pret * 1.05
   WHERE id_produs IN (
      SELECT id_produs FROM DetaliiComanda GROUP BY id_produs HAVING COUNT(*) >= 6)
   RETURNING id_produs BULK COLLECT INTO v_produse;
   IF SQL%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('S-au modificat ' || SQL%ROWCOUNT || ' preturi.');
      FOR i IN 1..v_produse.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(i || '  id_produs: ' || v_produse(i));
      END LOOP;
   ELSE
      DBMS_OUTPUT.PUT_LINE('Nu s-a modificat niciun pret.');
   END IF;
   ROLLBACK;
END;
/

/* F.5. Cursor inline. Sa se afiseze produsele care nu au fost niciodata comandate. */
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('');
   FOR r IN (SELECT p.id_produs, p.denumire, p.pret, p.stoc
             FROM Produse p
             WHERE p.id_produs NOT IN (SELECT id_produs FROM DetaliiComanda)
             ORDER BY p.id_produs) LOOP
      DBMS_OUTPUT.PUT_LINE(r.id_produs || '. ' || RPAD(r.denumire, 25) ||
        'Pret: ' || r.pret || ' lei' || ' | Stoc: ' || r.stoc);
   END LOOP;
END;
/

/* F.6. Cursor FOR UPDATE. Sa se mareasca cu 5% pretul produselor care apar in cel putin 3
   comenzi distincte. */
DECLARE
   CURSOR c IS
      SELECT p.id_produs, p.denumire, p.pret
      FROM Produse p
      WHERE p.id_produs IN (
         SELECT id_produs FROM DetaliiComanda GROUP BY id_produs HAVING COUNT(DISTINCT id_comanda) >= 3)
      FOR UPDATE WAIT 5;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('____________________________________________________');
   FOR r IN c LOOP
      UPDATE Produse SET pret = pret * 1.05 WHERE CURRENT OF c;
      DBMS_OUTPUT.PUT_LINE(RPAD(r.denumire, 25) || 'Pret vechi: ' || r.pret ||
       ' | Pret nou: ' || ROUND(r.pret * 1.05, 2));
   END LOOP;
   ROLLBACK;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

-- =====================================================================
-- G. Functii, proceduri si pachete
-- =====================================================================
-- G.I. Functii

/* G.I.1. Sa se calculeze valoarea totala a unei comenzi pe baza id-ului acesteia. */
CREATE OR REPLACE FUNCTION total_comanda(p_id_comanda NUMBER) RETURN NUMBER IS
   v_total NUMBER;
BEGIN
   SELECT SUM(cantitate * pret_unitar) INTO v_total
   FROM DetaliiComanda WHERE id_comanda = p_id_comanda;
   RETURN NVL(v_total, 0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN 0;
END;
/

DECLARE
    v_total_comanda NUMBER;
    v_id_comanda NUMBER := 200;
BEGIN
    v_total_comanda := total_comanda(200);
    DBMS_OUTPUT.PUT_LINE('Valoarea comenzii cu ID-ul ' || v_id_comanda || ' este ' || v_total_comanda);
END;
/

/* G.I.2. Sa se returneze numele si prenumele angajatului cu cele mai multe comenzi dintr-o
   luna si an date. */
CREATE OR REPLACE FUNCTION cel_mai_bun_angajat(p_luna NUMBER, p_an NUMBER) RETURN VARCHAR2 IS
   v_nume VARCHAR2(50);
BEGIN
   SELECT a.nume || ' ' || a.prenume INTO v_nume
   FROM Angajati a, Comenzi c
   WHERE a.id_angajat = c.id_angajat
   AND EXTRACT(MONTH FROM c.data_comanda) = p_luna
   AND EXTRACT(YEAR FROM c.data_comanda) = p_an
   GROUP BY a.nume, a.prenume
   ORDER BY COUNT(*) DESC
   FETCH FIRST 1 ROW ONLY;
   RETURN v_nume;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'Nu exista comenzi in aceasta perioada.';
END;
/

BEGIN
   DBMS_OUTPUT.PUT_LINE('Cel mai bun angajat: ' || cel_mai_bun_angajat(5, 2026));
END;
/

/* G.I.3. Sa se returneze pretul unui produs dupa aplicarea unei reduceri. Daca pretul redus
   scade sub 50% din pretul original, sa se ridice o exceptie. */
CREATE OR REPLACE FUNCTION reducere_produs(p_id_produs NUMBER, p_valoare NUMBER) RETURN NUMBER IS
   v_pret NUMBER;
   v_pret_redus NUMBER;
BEGIN
   SELECT pret INTO v_pret FROM Produse WHERE id_produs = p_id_produs;
   v_pret_redus := v_pret - p_valoare;
   IF v_pret_redus < v_pret * 0.5 THEN
      RAISE_APPLICATION_ERROR(-20005, 'Reducerea de ' || p_valoare ||
      ' lei face ca pretul sa scada sub 50% din pretul original.');
   END IF;
   RETURN v_pret_redus;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20006, 'Nu exista niciun produs cu id-ul ' || p_id_produs || '.');
END;
/

DECLARE
   v_pret_redus NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George - Reducere produs');
   v_pret_redus := reducere_produs(103, 20);
   DBMS_OUTPUT.PUT_LINE('Pretul redus este: ' || v_pret_redus || ' lei');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
END;
/

-- G.II. Proceduri

/* G.II.1. Sa se afiseze datele complete ale unui angajat impreuna cu comenzile preluate si
   valoarea fiecareia, apeland total_comanda. */
CREATE OR REPLACE PROCEDURE raport_angajat(p_id_angajat NUMBER) IS
   v_ang Angajati%ROWTYPE;
   CURSOR c_comenzi IS
      SELECT id_comanda, data_comanda FROM Comenzi
      WHERE id_angajat = p_id_angajat ORDER BY data_comanda;
BEGIN
   SELECT * INTO v_ang FROM Angajati WHERE id_angajat = p_id_angajat;
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('______________________________________');
   DBMS_OUTPUT.PUT_LINE('Nume:     ' || v_ang.nume || ' ' || v_ang.prenume);
   DBMS_OUTPUT.PUT_LINE('Functie:  ' || v_ang.functie);
   DBMS_OUTPUT.PUT_LINE('Salariu:  ' || v_ang.salariu || ' lei');
   DBMS_OUTPUT.PUT_LINE('Vechime:  ' || TRUNC(MONTHS_BETWEEN(SYSDATE, v_ang.data_angajare)) || ' luni');
   DBMS_OUTPUT.PUT_LINE('_______________________________________');
   DBMS_OUTPUT.PUT_LINE('Comenzi preluate:');
   FOR r IN c_comenzi LOOP
      DBMS_OUTPUT.PUT_LINE('   - Comanda ' || r.id_comanda || ' | ' || TO_CHAR(r.data_comanda, 'DD-MM-YYYY')
      || ' | Total: ' || total_comanda(r.id_comanda) || ' lei');
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('_______________________________________');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu id-ul ' || p_id_angajat || '.');
END;
/

BEGIN
   raport_angajat(102);
END;
/

/* G.II.2. Sa se construiasca o procedura care mareste salariul cu un procent dat pentru toti
   angajatii cu o anumita functie. Sa se afiseze numarul de salarii modificate si id-urile
   angajatilor carora li s-au actualizat salariile. */
CREATE OR REPLACE PROCEDURE marire_salariu(p_functie VARCHAR2, p_procent NUMBER) IS
   TYPE T_ANG IS TABLE OF NUMBER;
   v_ids T_ANG;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   UPDATE Angajati SET salariu = salariu * (1 + p_procent/100)
   WHERE functie = p_functie
   RETURNING id_angajat BULK COLLECT INTO v_ids;
   IF SQL%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('S-au marit ' || SQL%ROWCOUNT || ' salarii cu ' || p_procent
      || '% pentru functia ' || p_functie);
      FOR i IN 1..v_ids.COUNT LOOP
         DBMS_OUTPUT.PUT_LINE('   -> id_angajat: ' || v_ids(i));
      END LOOP;
   ELSE
      DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu functia ' || p_functie);
   END IF;
   ROLLBACK;
END;
/

BEGIN
   marire_salariu('Ospatar', 10);
END;
/

/* G.II.3. Intr-o procedura sa se afiseze produsele cu stoc sub un prag dat ca parametru,
   impreuna cu furnizorul fiecaruia. */
CREATE OR REPLACE PROCEDURE stoc_scazut(p_prag NUMBER) IS
   CURSOR c IS
      SELECT p.id_produs, p.denumire, p.stoc, f.nume_furnizor
      FROM Produse p, Furnizori f
      WHERE p.id_furnizor = f.id_furnizor AND p.stoc < p_prag
      ORDER BY p.stoc ASC;
   v_gasit BOOLEAN := FALSE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_____________________');
   FOR r IN c LOOP
      DBMS_OUTPUT.PUT_LINE(RPAD(r.denumire, 25) || 'Stoc: ' || RPAD(r.stoc, 6)
      || '| Furnizor: ' || r.nume_furnizor);
      v_gasit := TRUE;
   END LOOP;
   IF NOT v_gasit THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista produse cu stoc sub ' || p_prag);
   END IF;
END;
/

BEGIN
   stoc_scazut(40);
END;
/

-- G.III. Pachete

/* G.III. Intr-un pachet sa se defineasca o functie care returneaza valoarea stocului de la un
   anumit furnizor si o procedura care aplica un bonus angajatilor care lucreaza pe tura de tip
   "Full". Sa se apeleze functia si procedura. */
CREATE OR REPLACE PACKAGE pkg_cafenea IS
   FUNCTION valoare_stoc_furnizor(p_id_furnizor NUMBER) RETURN NUMBER;
   PROCEDURE bonus_tura_full(p_bonus NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_cafenea IS

   FUNCTION valoare_stoc_furnizor(p_id_furnizor NUMBER) RETURN NUMBER IS
      v_valoare NUMBER;
   BEGIN
      SELECT SUM(p.pret * p.stoc) INTO v_valoare
      FROM Produse p WHERE p.id_furnizor = p_id_furnizor;
      RETURN NVL(v_valoare, 0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN 0;
   END;

   PROCEDURE bonus_tura_full(p_bonus NUMBER) IS
      CURSOR c IS
         SELECT a.id_angajat, a.nume, a.prenume, a.salariu, a.functie
         FROM Angajati a, ProgramAngajati p
         WHERE a.id_angajat = p.id_angajat AND p.tura = 'Full';
   BEGIN
      DBMS_OUTPUT.PUT_LINE('_______________________');
      FOR r IN c LOOP
         UPDATE Angajati SET salariu = salariu + p_bonus WHERE id_angajat = r.id_angajat;
         DBMS_OUTPUT.PUT_LINE(RPAD(r.nume || ' ' || r.prenume, 25) ||
         RPAD(r.functie, 16) || 'Salariu vechi: ' || r.salariu || ' lei'
         || ' | Salariu nou: ' || (r.salariu + p_bonus) || ' lei');
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('__________________________');
      DBMS_OUTPUT.PUT_LINE('Bonus aplicat: ' || p_bonus || ' lei.');
      ROLLBACK;
   END;

END;
/

BEGIN
   DBMS_OUTPUT.PUT_LINE('Vaman Mircea-George');
   DBMS_OUTPUT.PUT_LINE('_______________________');
   DBMS_OUTPUT.PUT_LINE('Valoare stoc furnizor 108: ' || pkg_cafenea.valoare_stoc_furnizor(108) || ' lei');
   pkg_cafenea.bonus_tura_full(300);
END;
/

-- =====================================================================
-- H. Declansatori
-- =====================================================================
-- H.I. La nivel de instructiune

/* H.I.1. Sa se construiasca un trigger care sa nu permita adaugarea, modificarea sau stergerea
   comenzilor in afara programului (8:00 - 22:00). */
CREATE OR REPLACE TRIGGER trg_program_comenzi
BEFORE INSERT OR UPDATE OR DELETE ON Comenzi
BEGIN
   IF TO_CHAR(SYSDATE, 'HH24:MI') < '08:00' OR TO_CHAR(SYSDATE, 'HH24:MI') > '22:00' THEN
      IF INSERTING THEN
         RAISE_APPLICATION_ERROR(-20010, 'Nu se pot adauga comenzi in afara orelor 08:00 - 22:00.');
      ELSIF UPDATING THEN
         RAISE_APPLICATION_ERROR(-20011, 'Nu se pot modifica comenzi in afara orelor 08:00 - 22:00.');
      ELSIF DELETING THEN
         RAISE_APPLICATION_ERROR(-20012, 'Nu se pot sterge comenzi in afara orelor 08:00 - 22:00.');
      END IF;
   END IF;
END;
/

-- Testare trigger
INSERT INTO Comenzi (id_comanda, id_masa, id_angajat, data_comanda) VALUES (250, 100, 102, SYSDATE);
ROLLBACK;

/* H.I.2. Sa se construiasca un trigger care nu permite inserarea unui program de lucru al unui
   angajat daca intervalul dintre data de inceput si data de sfarsit depaseste 7 zile. */
CREATE OR REPLACE TRIGGER trg_program_max_7_zile
BEFORE INSERT ON ProgramAngajati
DECLARE
   C_max_zile CONSTANT NUMBER := 7;
BEGIN
   FOR r IN (SELECT data_inceput, data_sfarsit, id_angajat FROM ProgramAngajati) LOOP
      IF (r.data_sfarsit - r.data_inceput) > C_max_zile THEN
         RAISE_APPLICATION_ERROR(-20013, 'Programul angajatului ' || r.id_angajat ||
                                 ' depaseste ' || C_max_zile || ' zile.');
      END IF;
   END LOOP;
END;
/

-- Testare trigger
INSERT INTO ProgramAngajati VALUES (410, 100, DATE '2026-05-01', DATE '2026-05-20', 'Full');
ROLLBACK;

-- H.II. La nivel de rand

/* H.II.1. Sa se construiasca un trigger care sa nu permita micsorarea salariului unui angajat
   care a preluat cel putin 2 comenzi. */
CREATE OR REPLACE TRIGGER trg_verif_salariu
BEFORE UPDATE OF salariu ON Angajati
FOR EACH ROW
WHEN (NEW.salariu < OLD.salariu)
DECLARE
   v_nr_comenzi NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_nr_comenzi FROM Comenzi WHERE id_angajat = :NEW.id_angajat;
   IF v_nr_comenzi >= 2 THEN
      RAISE_APPLICATION_ERROR(-20014, 'Nu se poate micsora salariul angajatului '
      || :OLD.nume || ' ' || :OLD.prenume || ' deoarece a preluat ' || v_nr_comenzi || ' comenzi.');
   END IF;
END;
/

-- Testare trigger
UPDATE Angajati SET salariu = salariu - 500 WHERE id_angajat = 102;
ROLLBACK;

/* H.II.2. Sa se construiasca un trigger care sa verifice daca stocul unui produs este suficient
   inainte de inserarea unei linii in DetaliiComanda si sa il decrementeze automat. */
CREATE OR REPLACE TRIGGER trg_verif_stoc
BEFORE INSERT ON DetaliiComanda
FOR EACH ROW
DECLARE
   v_stoc NUMBER;
   v_denumire VARCHAR2(100);
BEGIN
   SELECT stoc, denumire INTO v_stoc, v_denumire FROM Produse WHERE id_produs = :NEW.id_produs;
   IF v_stoc < :NEW.cantitate THEN
      RAISE_APPLICATION_ERROR(-20015, 'Stoc insuficient pentru ' || v_denumire ||
      '. Stoc disponibil: ' || v_stoc || ', cantitate ceruta: ' || :NEW.cantitate);
   END IF;
   UPDATE Produse SET stoc = stoc - :NEW.cantitate WHERE id_produs = :NEW.id_produs;
END;
/

-- Cazul cu stoc insuficient
INSERT INTO DetaliiComanda VALUES (210, 108, 9999, 18);
ROLLBACK;

-- Cazul cu stoc suficient
INSERT INTO DetaliiComanda VALUES (210, 108, 1, 18);
SELECT stoc FROM Produse WHERE id_produs = 108;
ROLLBACK;
