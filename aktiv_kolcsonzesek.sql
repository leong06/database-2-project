-- K�lcs�nz�s view, k�lcs�nz�si el�zm�nyek

-- Ideiglenes t�bla l�trehoz�sa az aktu�lis k�lcs�nz�seknek

CREATE GLOBAL TEMPORARY TABLE AktualisKolcsonzesekTemp (
    cim VARCHAR2(255),
    szerzo VARCHAR2(255),
    mufaj VARCHAR2(100),
    kiado VARCHAR2(255),
    megjelenes_eve NUMBER(4)
) ON COMMIT PRESERVE ROWS;

-- Akt�v k�lcs�nz�sek lek�r�se

CREATE OR REPLACE PROCEDURE AktualisKolcsonzesek(
    p_olvaso_szam IN NUMBER
) IS
BEGIN
    DELETE FROM AktualisKolcsonzesekTemp;

    INSERT INTO AktualisKolcsonzesekTemp (cim, szerzo, mufaj, kiado, megjelenes_eve)
    SELECT k.cim, k.szerzo, k.mufaj, k.kiado, k.megjelenes_eve
    FROM Kolcsonzesek ko
    JOIN Konyvek k ON ko.konyv_id = k.id
    WHERE ko.kolcsonzo_olvaso = p_olvaso_szam
      AND ko.visszahozatal_idopont IS NULL;
END AktualisKolcsonzesek;
/

--  Tesztel�s

BEGIN
    AktualisKolcsonzesek(p_olvaso_szam => 1001);
END;
/

SELECT * FROM AktualisKolcsonzesekTemp;
