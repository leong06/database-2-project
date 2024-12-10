CREATE OR REPLACE PACKAGE olvaso_pkg IS
  email_exists EXCEPTION;

  PROCEDURE beiratkozas(p_nev            IN VARCHAR2
                       ,p_email          IN VARCHAR2
                       ,p_telefonszam    IN NUMBER
                       ,p_tagsag_kezdete IN DATE);
END olvaso_pkg;
/
CREATE OR REPLACE PACKAGE BODY olvaso_pkg IS
  PROCEDURE beiratkozas(p_nev            IN VARCHAR2
                       ,p_email          IN VARCHAR2
                       ,p_telefonszam    IN NUMBER
                       ,p_tagsag_kezdete IN DATE) IS
    email_count NUMBER;
  
  BEGIN
    -- E-mail egyediségének ellenõrzése
    SELECT COUNT(*)
      INTO email_count
      FROM beiratkozott_olvasok
     WHERE email = p_email;
  
    IF email_count > 0
    THEN
      RAISE email_exists;
    END IF;
  
    INSERT INTO beiratkozott_olvasok
      (nev
      ,email
      ,telefonszam
      ,tagsag_kezdete)
    VALUES
      (p_nev
      ,p_email
      ,p_telefonszam
      ,p_tagsag_kezdete);
  
    dbms_output.put_line('Sikeres beiratkozás!');
    
  EXCEPTION
    WHEN email_exists THEN
      dbms_output.put_line('Hiba: Az e-mail cím már létezik az adatbázisban.');
      RAISE_APPLICATION_ERROR(-20009, 'Hiba: Az e-mail cím már létezik az adatbázisban.');
  END beiratkozas;

END olvaso_pkg;
/
