create or replace package tartozasok_pkg is

PROCEDURE get_tartozasok(p_olvaso_szam IN NUMBER);
PROCEDURE tartozas_fizetes(
    p_olvaso_szam IN NUMBER,
    p_fizetett_osszeg IN NUMBER
);

end tartozasok_pkg;
/
CREATE OR REPLACE PACKAGE BODY tartozasok_pkg IS

-- Függõ tartozások lekérése procedure

PROCEDURE get_tartozasok(p_olvaso_szam IN NUMBER) IS
    v_total_tartozas NUMBER := 0;
BEGIN
  
    SELECT SUM(t.tartozas_merteke)
    INTO v_total_tartozas
    FROM Tartozas t
    WHERE t.olvaso_szam = p_olvaso_szam
      AND t.tartozas_teljesulese IS NULL;

    IF v_total_tartozas IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Az olvasónak nincs tartozása.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Az olvasó tartozásainak összege: ' || v_total_tartozas || ' Ft');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Az olvasó nem található.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba történt: ' || SQLERRM);
END get_tartozasok;

-- Tartozás befizetése procedure

PROCEDURE tartozas_fizetes(
    p_olvaso_szam IN NUMBER,
    p_fizetett_osszeg IN NUMBER
) IS
    v_remaining_amount NUMBER := p_fizetett_osszeg;
    v_tartozas_id NUMBER;
    v_tartozas_merteke NUMBER;
BEGIN
    IF p_fizetett_osszeg <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('A befizetett összegnek pozitívnak kell lennie.');
        RETURN;
    END IF;

    -- Feldolgozás tartozásonként
    FOR rec IN (
        SELECT t.tartozas_id, t.tartozas_merteke
        FROM Tartozas t
        WHERE t.olvaso_szam = p_olvaso_szam
          AND t.tartozas_teljesulese IS NULL
        ORDER BY t.tartozas_id
    ) LOOP
        v_tartozas_id := rec.tartozas_id;
        v_tartozas_merteke := rec.tartozas_merteke;

        IF v_remaining_amount >= v_tartozas_merteke THEN
            -- Tartozás teljes kifizetése
            UPDATE Tartozas
            SET tartozas_merteke = 0, tartozas_teljesulese = SYSDATE
            WHERE tartozas_id = v_tartozas_id;
            v_remaining_amount := v_remaining_amount - v_tartozas_merteke;
        ELSE
            -- Tartozás részbeni kifizetése
            UPDATE Tartozas
            SET tartozas_merteke = tartozas_merteke - v_remaining_amount
            WHERE tartozas_id = v_tartozas_id;
            v_remaining_amount := 0;
            EXIT;
        END IF;

        -- Ha nincs több pénz, kilépünk
        IF v_remaining_amount = 0 THEN
            EXIT;
        END IF;
    END LOOP;

    -- Ellenõrzés: Maradt-e befizetetlen összeg
    IF v_remaining_amount > 0 THEN
        DBMS_OUTPUT.PUT_LINE('A teljes tartozás kiegyenlítve. Maradék összeg: ' || v_remaining_amount || ' Ft visszajár.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('A befizetés sikeresen feldolgozva.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Az olvasónak nincs tartozása.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba történt: ' || SQLERRM);
END tartozas_fizetes;

END tartozasok_pkg;
/
