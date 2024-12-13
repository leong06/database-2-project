CREATE OR REPLACE PACKAGE olvaso_pkg IS
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
  
  BEGIN  
    INSERT INTO beiratkozott_olvaso
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
    
END beiratkozas;

END olvaso_pkg;
/
