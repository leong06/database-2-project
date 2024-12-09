create or replace package tartozasok_pkg is

PROCEDURE get_tartozasok(p_olvaso_szam IN NUMBER);
PROCEDURE tartozas_fizetes(
    p_olvaso_szam IN NUMBER,
    p_fizetett_osszeg IN NUMBER
);

end tartozasok_pkg;
/
CREATE OR REPLACE PACKAGE BODY tartozasok_pkg IS

-- F�gg� tartoz�sok lek�r�se procedure

PROCEDURE get_tartozasok(p_olvaso_szam IN NUMBER) IS
    v_total_tartozas NUMBER := 0;
BEGIN
  
    SELECT SUM(t.tartozas_merteke)
    INTO v_total_tartozas
    FROM Tartozas t
    WHERE t.olvaso_szam = p_olvaso_szam
      AND t.tartozas_teljesulese IS NULL;

    IF v_total_tartozas IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Az olvas�nak nincs tartoz�sa.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Az olvas� tartoz�sainak �sszege: ' || v_total_tartozas || ' Ft');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Az olvas� nem tal�lhat�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba t�rt�nt: ' || SQLERRM);
END get_tartozasok;

-- Tartoz�s befizet�se procedure

PROCEDURE tartozas_fizetes(
    p_olvaso_szam IN NUMBER,
    p_fizetett_osszeg IN NUMBER
) IS
    v_remaining_amount NUMBER := p_fizetett_osszeg;
    v_tartozas_id NUMBER;
    v_tartozas_merteke NUMBER;
BEGIN
    IF p_fizetett_osszeg <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('A befizetett �sszegnek pozit�vnak kell lennie.');
        RETURN;
    END IF;

    -- Feldolgoz�s tartoz�sonk�nt
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
            -- Tartoz�s teljes kifizet�se
            UPDATE Tartozas
            SET tartozas_merteke = 0, tartozas_teljesulese = SYSDATE
            WHERE tartozas_id = v_tartozas_id;
            v_remaining_amount := v_remaining_amount - v_tartozas_merteke;
        ELSE
            -- Tartoz�s r�szbeni kifizet�se
            UPDATE Tartozas
            SET tartozas_merteke = tartozas_merteke - v_remaining_amount
            WHERE tartozas_id = v_tartozas_id;
            v_remaining_amount := 0;
            EXIT;
        END IF;

        -- Ha nincs t�bb p�nz, kil�p�nk
        IF v_remaining_amount = 0 THEN
            EXIT;
        END IF;
    END LOOP;

    -- Ellen�rz�s: Maradt-e befizetetlen �sszeg
    IF v_remaining_amount > 0 THEN
        DBMS_OUTPUT.PUT_LINE('A teljes tartoz�s kiegyenl�tve. Marad�k �sszeg: ' || v_remaining_amount || ' Ft visszaj�r.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('A befizet�s sikeresen feldolgozva.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Az olvas�nak nincs tartoz�sa.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba t�rt�nt: ' || SQLERRM);
END tartozas_fizetes;

END tartozasok_pkg;
/
