-- Könyvtáros adatbázis rendszer 
-- Gerencir Leon, BG80FA

-- Felhasználók létrehozása

-- 1. : Könyvtáros (Admin)
CREATE USER konyvtaros
IDENTIFIED BY 12345678
DEFAULT TABLESPACE users
QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION TO konyvtaros;
GRANT CREATE TABLE TO konyvtaros;
GRANT CREATE VIEW TO konyvtaros;
GRANT CREATE SEQUENCE TO konyvtaros;
GRANT CREATE PROCEDURE TO konyvtaros;
GRANT CREATE TRIGGER TO konyvtaros;
GRANT CREATE TYPE TO konyvtaros;

-- 2. : Olvasó (Read-only)

CREATE USER olvaso
IDENTIFIED BY 12345678
DEFAULT TABLESPACE users
QUOTA UNLIMITED ON USERS;

-- Táblák létrehozása

-- 1. Beiratkozott olvasók
CREATE TABLE beiratkozott_olvasok (
    olvasoszam NUMBER PRIMARY KEY,
    nev VARCHAR2(100) NOT NULL,
    email VARCHAR2(150) UNIQUE NOT NULL,
    telefonszam VARCHAR2(15),
    tagsag_kezdete DATE NOT NULL
);

-- 2. Könyvek
CREATE TABLE konyvek (
    konyv_id NUMBER PRIMARY KEY,
    cim VARCHAR2(200) NOT NULL,
    szerzo VARCHAR2(100) NOT NULL,
    mufaj VARCHAR2(50),
    kiado VARCHAR2(100),
    megjelenes_eve NUMBER(4),
    elerheto_peldanyszam NUMBER NOT NULL CHECK (elerheto_peldanyszam >= 0)
);

-- 3. Kölcsönzések
CREATE TABLE kolcsonzesek (
    kolcsonzes_id NUMBER PRIMARY KEY,
    kolcsonzes_idopont DATE NOT NULL,
    visszahozatal_idopont DATE,
    esedekesseg_idopont DATE NOT NULL,
    kolcsonzo_olvaso NUMBER NOT NULL,
    konyv_id NUMBER NOT NULL,
    CONSTRAINT fk_kolcsonzo_olvaso FOREIGN KEY (kolcsonzo_olvaso) REFERENCES Beiratkozott_Olvasok(olvasoszam),
    CONSTRAINT fk_konyv FOREIGN KEY (konyv_id) REFERENCES Konyvek(konyv_id)
);

-- 4. Elõjegyzések
CREATE TABLE elojegyzesek (
    elojegyzes_id NUMBER PRIMARY KEY,
    foglalo_olvaso NUMBER NOT NULL,
    foglalas_datum DATE NOT NULL,
    foglalas_allapota VARCHAR2(20) CHECK (foglalas_allapota IN ('Aktív', 'Teljesült', 'Törölt')),
    teljesules_datum DATE,
    konyv_id NUMBER NOT NULL,
    CONSTRAINT fk_foglalo_olvaso FOREIGN KEY (foglalo_olvaso) REFERENCES Beiratkozott_Olvasok(olvasoszam),
    CONSTRAINT fk_elojegyzes_konyv FOREIGN KEY (konyv_id) REFERENCES Konyvek(konyv_id)
);

-- 5. Tartozás
CREATE TABLE tartozas (
    tartozas_id NUMBER PRIMARY KEY,
    olvaso_szam NUMBER NOT NULL,
    konyv_id NUMBER NOT NULL,
    tartozas_merteke NUMBER NOT NULL CHECK (tartozas_merteke >= 0),
    tartozas_teljesulese DATE,
    CONSTRAINT fk_tartozas_olvaso FOREIGN KEY (olvaso_szam) REFERENCES Beiratkozott_Olvasok(olvasoszam),
    CONSTRAINT fk_tartozas_konyv FOREIGN KEY (konyv_id) REFERENCES Konyvek(konyv_id)
);

-- 6. Kölcsönzési elõzmények

CREATE TABLE kolcsonzesi_elozmenyek (
    id NUMBER PRIMARY KEY,
    olvaso_szam NUMBER NOT NULL,
    konyv_id NUMBER NOT NULL,
    kolcsonzes_idopont DATE NOT NULL,
    visszahozatal_idopont DATE,
    FOREIGN KEY (olvaso_szam) REFERENCES beiratkozott_olvasok(olvasoszam),
    FOREIGN KEY (konyv_id) REFERENCES Konyvek(konyv_id)
);

-- Szekvencia létrehozása
CREATE SEQUENCE olvasoszam_seq
START WITH 1000
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE kolcsonzes_id_seq
START WITH 3
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE elojegyzes_id_seq
START WITH 3
INCREMENT BY 1
NOCACHE;

