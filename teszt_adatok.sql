-- Teszt adatok a Beiratkozott Olvasók táblához
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('Kovács Péter', 'kovacs.peter@gmail.com', '06701234567', TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('Nagy Anna', 'nagy.anna@gmail.com', '06708965432', TO_DATE('2022-06-10', 'YYYY-MM-DD'));
INSERT INTO beiratkozott_olvaso (nev, email, telefonszam, tagsag_kezdete)
VALUES ('Tóth Tamás', 'toth.tamas@gmail.com', '06703456789', TO_DATE('2021-09-01', 'YYYY-MM-DD'));

-- Teszt adatok a Könyvek táblához
INSERT INTO konyv (cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('A Gyûrûk Ura', 'J.R.R. Tolkien', 'Fantasy', 'Európa', 1954, 3);
INSERT INTO konyv ( cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('Harry Potter és a Bölcsek Köve', 'J.K. Rowling', 'Fantasy', 'Animus', 1997, 5);
INSERT INTO konyv (cim, szerzo, mufaj, kiado, megjelenes_eve, elerheto_peldanyszam)
VALUES ('Száz év magány', 'Gabriel García Márquez', 'Irodalmi', 'Magvetõ', 1967, 2);

-- Teszt adatok a Kölcsönzések táblához
INSERT INTO kolcsonzes (kolcsonzes_idopont, visszahozatal_idopont, esedekesseg_idopont, kolcsonzo_olvaso, konyv_id)
VALUES (TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_DATE('2024-11-10', 'YYYY-MM-DD'), TO_DATE('2024-11-15', 'YYYY-MM-DD'), 1, 1);
INSERT INTO kolcsonzes (kolcsonzes_id, kolcsonzes_idopont, visszahozatal_idopont, esedekesseg_idopont, kolcsonzo_olvaso, konyv_id)
VALUES (TO_DATE('2024-10-15', 'YYYY-MM-DD'), TO_DATE('2024-10-25', 'YYYY-MM-DD'), TO_DATE('2024-10-30', 'YYYY-MM-DD'), 2, 2);

-- Teszt adatok az Elõjegyzések táblához
INSERT INTO elojegyzes (foglalo_olvaso, foglalas_datum, foglalas_allapota, teljesules_datum, konyv_id)
VALUES (1, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Aktív', NULL, 1);
INSERT INTO elojegyzes (foglalo_olvaso, foglalas_datum, foglalas_allapota, teljesules_datum, konyv_id)
VALUES (2, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'Teljesült', TO_DATE('2024-10-25', 'YYYY-MM-DD'), 3);

-- Teszt adatok a Tartozás táblához
INSERT INTO tartozas (olvaso_szam, konyv_id, tartozas_merteke, tartozas_teljesulese)
VALUES (1, 3, 500, TO_DATE('2024-11-15', 'YYYY-MM-DD'));
INSERT INTO tartozas (olvaso_szam, konyv_id, tartozas_merteke, tartozas_teljesulese)
VALUES (2, 1, NULL);
