CREATE OR REPLACE PROCEDURE AktualisKolcsonzesek(
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
/

--  Tesztel�s

BEGIN
    AktualisKolcsonzesek(p_olvaso_szam => 1001);
END;
/

SELECT * FROM Kolcsonzesek
SELECT * FROM AktualisKolcsonzesekTemp;
