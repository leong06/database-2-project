-- K�nyvt�ros adatb�zis rendszer 
-- Gerencir Leon, BG80FA

-- Felhaszn�l�k l�trehoz�sa

-- 1. : K�nyvt�ros (Admin)
CREATE USER konyvtaros
IDENTIFIED BY 12345678
ON TABLESPACE users
QUOTA UNLIMITED ON USERS;




-- 2. : Olvas� (Read-only)

CREATE USER olvaso
IDENTIFIED BY 12345678
ON TABLESPACE users
QUOTA UNLIMITED ON USERS;



-- T�bl�k l�trehoz�sa
