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
        DBMS_OUTPUT.PUT_LINE('Cím: ' || kolcsonzes_rec.cim ||
                             ', Szerzõ: ' || kolcsonzes_rec.szerzo ||
                             ', Mûfaj: ' || kolcsonzes_rec.mufaj ||
                             ', Kiadó: ' || kolcsonzes_rec.kiado ||
                             ', Megjelenés éve: ' || kolcsonzes_rec.megjelenes_eve);
    END LOOP;
END AktualisKolcsonzesek;
/

--  Tesztelés

BEGIN
    AktualisKolcsonzesek(p_olvaso_szam => 1001);
END;
/

SELECT * FROM Kolcsonzesek
SELECT * FROM AktualisKolcsonzesekTemp;
