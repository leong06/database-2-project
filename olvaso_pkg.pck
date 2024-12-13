CREATE OR REPLACE PACKAGE olvaso_pkg IS
  PROCEDURE beiratkozas(p_nev            IN VARCHAR2
                       ,p_email          IN VARCHAR2
                       ,p_telefonszam    IN NUMBER
                       ,p_tagsag_kezdete IN DATE);
                       
  PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER);
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

PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER) IS
  BEGIN
    dbms_output.put_line('Bejelentkezett olvasó: ' || p_olvaso_szam);
  
    FOR rec IN (SELECT ke.kolcsonzes_idopont
                      ,ke.visszahozatal_idopont
                      ,k.cim
                      ,k.szerzo
                  FROM kolcsonzesi_elozmeny ke
                  JOIN konyv k
                    ON ke.konyv_id = k.konyv_id
                 WHERE ke.olvaso_szam = p_olvaso_szam
                 ORDER BY ke.kolcsonzes_idopont)
    LOOP
      dbms_output.put_line('Könyv: ' || rec.cim || ' - ' || rec.szerzo ||
                           ' | Kölcsönzés: ' ||
                           to_char(rec.kolcsonzes_idopont, 'YYYY-MM-DD') ||
                           ' | Visszahozatal: ' ||
                           nvl(to_char(rec.visszahozatal_idopont,
                                       'YYYY-MM-DD'),
                               'Nincs visszahozva'));
    END LOOP;
  END get_kolcsonzesi_elozmeny;



END olvaso_pkg;
/
