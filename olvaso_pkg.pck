CREATE OR REPLACE PACKAGE olvaso_pkg IS

  PROCEDURE beiratkozas(p_nev            IN VARCHAR2
                       ,p_email          IN VARCHAR2
                       ,p_telefonszam    IN NUMBER
                       ,p_tagsag_kezdete IN DATE);
                       
  PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER, p_elozmeny OUT KolcsonzesiElozmenyList);
  PROCEDURE HandleInsert(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, kolcsonzes_idopont IN DATE);
  PROCEDURE HandleUpdate(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, visszahozatal_idopont IN DATE);
  PROCEDURE AktualisKolcsonzesek(p_olvaso_szam IN NUMBER);
  
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
  
    dbms_output.put_line('Sikeres beiratkoz�s!');
    
END beiratkozas;

-- K�lcs�nz�si el�zm�nyek lek�r�se

PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER, p_elozmeny OUT KolcsonzesiElozmenyList) IS
  BEGIN
    SELECT KolcsonzesiElozmenyType(k.cim, k.szerzo, ke.kolcsonzes_idopont, ke.visszahozatal_idopont)
    BULK COLLECT INTO p_elozmeny
    FROM kolcsonzesi_elozmeny ke
    JOIN konyv k ON ke.konyv_id = k.konyv_id
    WHERE ke.olvaso_id = p_olvaso_szam
    ORDER BY ke.kolcsonzes_idopont;

    FOR i IN 1..p_elozmeny.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('K�nyv: ' || p_elozmeny(i).cim || ' - ' || p_elozmeny(i).szerzo ||
                           ' | K�lcs�nz�s: ' || TO_CHAR(p_elozmeny(i).kolcsonzes_idopont, 'YYYY-MM-DD') ||
                           ' | Visszahozatal: ' || NVL(TO_CHAR(p_elozmeny(i).visszahozatal_idopont, 'YYYY-MM-DD'), 'Nincs visszahozva'));
    END LOOP;
  END get_kolcsonzesi_elozmeny;
  
  CREATE OR REPLACE PROCEDURE HandleKolcsonzesiElozmeny(
    p_is_inserting BOOLEAN,
    p_kolcsonzo_olvaso NUMBER,
    p_konyv_id NUMBER,
    p_kolcsonzes_idopont DATE,
    p_visszahozatal_idopont DATE
) IS
BEGIN
    -- K�nyv kik�lcs�nz�se eset�n
    IF p_is_inserting THEN
        olvaso_pkg.HandleInsert(
            kolcsonzo_olvaso => p_kolcsonzo_olvaso,
            konyv_id => p_konyv_id,
            kolcsonzes_idopont => p_kolcsonzes_idopont
        );
    END IF;

    -- K�nyv visszahoz�sa eset�n
    IF NOT p_is_inserting AND p_visszahozatal_idopont IS NOT NULL THEN
        olvaso_pkg.HandleUpdate(
            kolcsonzo_olvaso => p_kolcsonzo_olvaso,
            konyv_id => p_konyv_id,
            visszahozatal_idopont => p_visszahozatal_idopont
        );
    END IF;
END HandleKolcsonzes;

-- K�lcs�nz�si el�zm�nyek r�gz�t�se

-- Insert eset�n
PROCEDURE HandleInsert(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, kolcsonzes_idopont IN DATE) IS
    BEGIN
        INSERT INTO kolcsonzesi_elozmeny (olvaso_id, konyv_id, kolcsonzes_idopont)
        VALUES (kolcsonzo_olvaso, konyv_id, kolcsonzes_idopont);
    END HandleInsert;

-- Update eset�n
PROCEDURE HandleUpdate(kolcsonzo_olvaso IN NUMBER, konyv_id IN NUMBER, visszahozatal_idopont IN DATE) IS
    BEGIN
        UPDATE kolcsonzesi_elozmeny
        SET visszahozatal_idopont = visszahozatal_idopont
        WHERE olvaso_id = kolcsonzo_olvaso
          AND konyv_id = konyv_id
          AND visszahozatal_idopont IS NULL;
    END HandleUpdate;

-- Akt�v k�lcs�nz�sek lek�r�se
PROCEDURE AktualisKolcsonzesek(
    p_olvaso_szam IN NUMBER
) IS
    CURSOR kolcsonzes_cursor IS
        SELECT k.cim, k.szerzo, k.mufaj, k.kiado, k.megjelenes_eve
        FROM Kolcsonzes ko
        JOIN Konyv k ON ko.konyv_id = k.konyv_id
        WHERE ko.kolcsonzo_olvaso = p_olvaso_szam
          AND ko.kolcsonozve = 'I';
BEGIN
    FOR kolcsonzes_rec IN kolcsonzes_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('C�m: ' || kolcsonzes_rec.cim ||
                             ', Szerz�: ' || kolcsonzes_rec.szerzo ||
                             ', M�faj: ' || kolcsonzes_rec.mufaj ||
                             ', Kiad�: ' || kolcsonzes_rec.kiado ||
                             ', Megjelen�s �ve: ' || kolcsonzes_rec.megjelenes_eve);
    END LOOP;
END AktualisKolcsonzesek;


END olvaso_pkg;
/
