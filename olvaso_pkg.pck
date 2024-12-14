CREATE OR REPLACE PACKAGE olvaso_pkg IS
  TYPE KolcsonzesiElozmenyType IS RECORD (
        cim VARCHAR2(255),
        szerzo VARCHAR2(255),
        kolcsonzes_idopont DATE,
        visszahozatal_idopont DATE
    );

  TYPE KolcsonzesiElozmenyList IS TABLE OF KolcsonzesiElozmenyType;

  PROCEDURE beiratkozas(p_nev            IN VARCHAR2
                       ,p_email          IN VARCHAR2
                       ,p_telefonszam    IN NUMBER
                       ,p_tagsag_kezdete IN DATE);
                       
  PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER, p_elozmeny OUT KolcsonzesiElozmenyList);
  PROCEDURE HandleInsert(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, kolcsonzes_idopont IN DATE);
  PROCEDURE HandleUpdate(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, visszahozatal_idopont IN DATE);
  
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

-- Kölcsönzési elõzmények lekérése

PROCEDURE get_kolcsonzesi_elozmeny(
        p_olvaso_szam IN NUMBER,
        p_elozmeny OUT KolcsonzesiElozmenyList
    ) IS
    BEGIN
        -- Eredmények begyûjtése
        SELECT KolcsonzesiElozmenyRecord(k.cim, k.szerzo, ke.kolcsonzes_idopont, ke.visszahozatal_idopont)
        BULK COLLECT INTO p_elozmeny
        FROM kolcsonzesi_elozmeny ke
        JOIN konyv k
          ON ke.konyv_id = k.konyv_id
        WHERE ke.olvaso_szam = p_olvaso_szam
        ORDER BY ke.kolcsonzes_idopont;

        FOR i IN 1..p_elozmeny.COUNT LOOP
            dbms_output.put_line('Könyv: ' || p_elozmeny(i).cim || ' - ' || p_elozmeny(i).szerzo ||
                                 ' | Kölcsönzés: ' ||
                                 to_char(p_elozmeny(i).kolcsonzes_idopont, 'YYYY-MM-DD') ||
                                 ' | Visszahozatal: ' ||
                                 nvl(to_char(p_elozmeny(i).visszahozatal_idopont, 'YYYY-MM-DD'),
                                     'Nincs visszahozva'));
        END LOOP;
    END get_kolcsonzesi_elozmeny;

-- Kölcsönzési elõzmények rögzítése

-- Insert esetén
PROCEDURE HandleInsert(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, kolcsonzes_idopont IN DATE) IS
    BEGIN
        INSERT INTO kolcsonzesi_elozmeny (olvaso_szam, konyv_id, kolcsonzes_idopont)
        VALUES (kolcsonzo_olvaso, konyv_id, kolcsonzes_idopont);
    END HandleInsert;

-- Update esetén
PROCEDURE HandleUpdate(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, visszahozatal_idopont IN DATE) IS
    BEGIN
        UPDATE kolcsonzesi_elozmeny
        SET visszahozatal_idopont = visszahozatal_idopont
        WHERE olvaso_szam = kolcsonzo_olvaso
          AND konyv_id = konyv_id
          AND visszahozatal_idopont IS NULL;
    END HandleUpdate;


END olvaso_pkg;
/
