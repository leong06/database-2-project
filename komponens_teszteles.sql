

-- Olvas� beiratkoz�s procedure tesztel�s

BEGIN
    olvaso_pkg.beiratkozas(
        p_nev => 'Juh�sz Katalin',
        p_email => 'juhasz.katalin@gmail.com',
        p_telefonszam => '06702345678',
        p_tagsag_kezdete => TO_DATE('2024-12-01', 'YYYY-MM-DD')
    );
END;