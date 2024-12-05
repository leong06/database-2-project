-- Könyvtáros adatbázis rendszer 
-- Gerencir Leon, BG80FA

-- Felhasználók létrehozása

-- 1. : Könyvtáros (Admin)
CREATE USER konyvtaros
IDENTIFIED BY 12345678
ON TABLESPACE users
QUOTA UNLIMITED ON USERS;




-- 2. : Olvasó (Read-only)

CREATE USER olvaso
IDENTIFIED BY 12345678
ON TABLESPACE users
QUOTA UNLIMITED ON USERS;



-- Táblák létrehozása
