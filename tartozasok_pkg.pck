CREATE OR REPLACE PACKAGE tartozas_pkg IS

  PROCEDURE get_tartozas(p_olvaso_szam IN NUMBER);
  PROCEDURE tartozas_fizetes(p_olvaso_szam     IN NUMBER
                            ,p_fizetett_osszeg IN NUMBER);

END tartozas_pkg;
/
CREATE OR REPLACE PACKAGE BODY tartozas_pkg IS

-- F�gg� tartoz�sok lek�r�se procedure

CREATE OR REPLACE FUNCTION get_tartozas(p_olvaso_szam IN NUMBER) RETURN NUMBER IS
    v_total_tartozas NUMBER;
BEGIN
    -- �sszes tartoz�s lek�rdez�se
    SELECT SUM(t.tartozas_merteke)
    INTO v_total_tartozas
    FROM tartozas t
    WHERE t.olvaso_szam = p_olvaso_szam
      AND t.tartozas_teljesulese IS NULL;

    -- Ha nincs tartoz�s, t�rjen vissza 0-val
    IF v_total_tartozas IS NULL THEN
        RETURN 0;
    END IF;

    RETURN v_total_tartozas;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Ha az olvas� nem tal�lhat�, t�rjen vissza 0-val
        RETURN 0;
    WHEN OTHERS THEN
        -- Ha egy�b hiba t�rt�nt, dobja tov�bb a hib�t
        RAISE;
END get_tartozas;

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

        IF v_remaining_amount = 0 THEN
            EXIT;
        END IF;
    END LOOP;

    IF v_remaining_amount > 0 THEN
        DBMS_OUTPUT.PUT_LINE('A teljes tartoz�s kiegyenl�tve. Marad�k �sszeg: ' || v_remaining_amount || ' Ft visszaj�r.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('A befizet�s sikeresen feldolgozva.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Az olvas�nak nincs tartoz�sa.');
        RAISE_APPLICATION_ERROR(-20010, 'Hiba: Az olvas�nak nincs tartoz�sa.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Hiba t�rt�nt a tartoz�s kifizet�se sor�n.');
END tartozas_fizetes;

END tartozas_pkg;
/
