CREATE OR REPLACE PACKAGE olvaso_pkg IS
email_exists EXCEPTION;

PROCEDURE beiratkozas(
  p_nev IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefonszam IN NUMBER,
  p_tagsag_kezdete IN DATE
  );
END olvaso_pkg;
/
CREATE OR REPLACE PACKAGE BODY olvaso_pkg IS
PROCEDURE beiratkozas(
  p_nev IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefonszam IN NUMBER,
  p_tagsag_kezdete IN DATE
  ) IS
  email_count NUMBER;
  
BEGIN
-- E-mail egyediségének ellenõrzése
SELECT COUNT(*)
INTO email_count
FROM beiratkozott_olvasok
WHERE email = p_email;

IF email_count > 0 THEN
  RAISE email_exists;
END IF;

INSERT INTO beiratkozott_olvasok (nev, email, telefonszam, tagsag_kezdete)
        VALUES (p_nev, p_email, p_telefonszam, p_tagsag_kezdete);

        DBMS_OUTPUT.PUT_LINE('Sikeres beiratkozás!');
    EXCEPTION
        WHEN email_exists THEN
            DBMS_OUTPUT.PUT_LINE('Hiba: Az e-mail cím már létezik az adatbázisban.');
    END Beiratkozas;

END olvaso_pkg;
/
