

-- Olvasó beiratkozás procedure tesztelés

BEGIN
    olvaso_pkg.beiratkozas(
        p_nev => 'Juhász Katalin',
        p_email => 'juhasz.katalin@gmail.com',
        p_telefonszam => '06702345678',
        p_tagsag_kezdete => TO_DATE('2024-12-01', 'YYYY-MM-DD')
    );
END;

-- Könyv kölcsönzés procedure tesztelés
-- 1. A könyv már elõ van jegyezve
BEGIN
    konyvek_pkg.kolcsonzes(
        p_konyv_id => 2,
        p_olvaso_id => 1002
    );
END;
/

-- 2. A könyv kölcsönözhetõ
BEGIN
    konyvek_pkg.kolcsonzes(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;

-- Könyv elõjegyzése

BEGIN
    konyvek_pkg.elojegyzes(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;

-- Könyv visszahozása:
BEGIN
    konyvek_pkg.visszahozas(
        p_konyv_id => 2,
        p_olvaso_id => 1001
    );
END;
/



SELECT * FROM kolcsonzesek





