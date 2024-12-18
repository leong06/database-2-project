-- Teszt adatok a Beiratkozott Olvas�k t�bl�hoz
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('Kov�cs P�ter', 'kovacs.peter@gmail.com', '06701234567', TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('Nagy Anna', 'nagy.anna@gmail.com', '06708965432', TO_DATE('2022-06-10', 'YYYY-MM-DD'));
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('T�th Tam�s', 'toth.tamas@gmail.com', '06703456789', TO_DATE('2021-09-01', 'YYYY-MM-DD'));

-- Teszt adatok a K�nyvek t�bl�hoz
INSERT INTO konyv (cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('A Gy�r�k Ura', 'J.R.R. Tolkien', 'Fantasy', 'Eur�pa', 1954, 3);
INSERT INTO konyv ( cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('Harry Potter �s a B�lcsek K�ve', 'J.K. Rowling', 'Fantasy', 'Animus', 1997, 5);
INSERT INTO konyv (cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('Sz�z �v mag�ny', 'Gabriel Garc�a M�rquez', 'Irodalmi', 'Magvet�', 1967, 2);

-- Teszt adatok a K�lcs�nz�sek t�bl�hoz
INSERT INTO kolcsonzes (kolcsonzes_idopont, visszahozatal_idopont, esedekesseg_idopont, kolcsonzo_olvaso, konyv_id)
VALUES (TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_DATE('2024-11-10', 'YYYY-MM-DD'), TO_DATE('2024-11-15', 'YYYY-MM-DD'), 1, 1);
INSERT INTO kolcsonzes (kolcsonzes_id, kolcsonzes_idopont, visszahozatal_idopont, esedekesseg_idopont, kolcsonzo_olvaso, konyv_id)
VALUES (TO_DATE('2024-10-15', 'YYYY-MM-DD'), TO_DATE('2024-10-25', 'YYYY-MM-DD'), TO_DATE('2024-10-30', 'YYYY-MM-DD'), 2, 2);

-- Teszt adatok az El�jegyz�sek t�bl�hoz
INSERT INTO elojegyzes (foglalo_olvaso, foglalas_datum, foglalas_allapota, teljesules_datum, konyv_id)
VALUES (1, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Akt�v', NULL, 1);
INSERT INTO elojegyzes (foglalo_olvaso, foglalas_datum, foglalas_allapota, teljesules_datum, konyv_id)
VALUES (2, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'Teljes�lt', TO_DATE('2024-10-25', 'YYYY-MM-DD'), 3);

-- Teszt adatok a Tartoz�s t�bl�hoz
INSERT INTO tartozas (olvaso_szam, konyv_id, tartozas_merteke, tartozas_teljesulese)
VALUES (1, 3, 500, TO_DATE('2024-11-15', 'YYYY-MM-DD'));
INSERT INTO tartozas (olvaso_szam, konyv_id, tartozas_merteke, tartozas_teljesulese)
VALUES (2, 1, NULL);
