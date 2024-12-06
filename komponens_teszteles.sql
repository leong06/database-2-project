

-- Olvas� beiratkoz�s procedure tesztel�s

BEGIN
    olvaso_pkg.beiratkozas(
        p_nev => 'Juh�sz Katalin',
        p_email => 'juhasz.katalin@gmail.com',
        p_telefonszam => '06702345678',
        p_tagsag_kezdete => TO_DATE('2024-12-01', 'YYYY-MM-DD')
    );
END;

-- K�nyv k�lcs�nz�s procedure tesztel�s
-- 1. A k�nyv m�r el� van jegyezve
BEGIN
    konyvek_pkg.kolcsonzes(
        p_konyv_id => 2,
        p_olvaso_id => 1002
    );
END;
/

-- 2. A k�nyv k�lcs�n�zhet�
BEGIN
    konyvek_pkg.kolcsonzes(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;

-- K�nyv el�jegyz�se

BEGIN
    konyvek_pkg.elojegyzes(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;

-- K�nyv visszahoz�sa:
BEGIN
    konyvek_pkg.visszahozas(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;
/



SELECT * FROM kolcsonzesek





