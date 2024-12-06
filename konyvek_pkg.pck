CREATE OR REPLACE PACKAGE konyvek_pkg IS
  -- Kiv�telek
  nincs_elerheto_peldany EXCEPTION;
  elojegyzett_konyv      EXCEPTION;
  kolcsonzes_limit       EXCEPTION;
  magas_tartozas         EXCEPTION;

  PROCEDURE kolcsonzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER);

END konyvek_pkg;
/
CREATE OR REPLACE PACKAGE BODY konyvek_pkg IS

  PROCEDURE kolcsonzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER) IS
                      lv_elerheto_peldany NUMBER;
                      lv_elojegyzes NUMBER;
                      lv_kolcsonzott_peldanyok NUMBER;
                      lv_ossz_tartozas NUMBER;

BEGIN
-- 1. Van-e szabad p�ld�ny a k�nyvb�l?

 SELECT elerheto_peldanyszam
        INTO lv_elerheto_peldany
        FROM konyvek
        WHERE konyv_id = p_konyv_id;

        IF lv_elerheto_peldany <= 0 THEN
            RAISE nincs_elerheto_peldany;
        END IF;

-- 2. Van-e el�jegyz�s a k�nyvre?

 SELECT COUNT(*)
        INTO lv_elojegyzes
        FROM elojegyzesek
        WHERE konyv_id = p_konyv_id
          AND foglalas_allapota = 'Akt�v';

        IF lv_elojegyzes > 0 THEN
            RAISE elojegyzett_konyv;
        END IF;

-- 3. Az olvas� k�lcs�n�zhet k�nyvet? (Nem l�pte �t a limitet?)

 SELECT COUNT(*)
        INTO lv_kolcsonzott_peldanyok
        FROM kolcsonzesek
        WHERE kolcsonzo_olvaso = p_olvaso_id
          AND visszahozatal_idopont IS NULL;

        IF lv_kolcsonzott_peldanyok >= 10 THEN
            RAISE kolcsonzes_limit;
        END IF;

-- 4. Meghaladja-e az olvas� tartoz�sa az 5000 forintot?
 
 SELECT SUM(tartozas_merteke)
        INTO lv_ossz_tartozas
        FROM tartozas
        WHERE olvaso_szam = p_olvaso_id
          AND tartozas_teljesulese IS NULL;

        IF lv_ossz_tartozas > 5000 THEN
            RAISE magas_tartozas;
        END IF;

-- K�lcs�nz�s
INSERT INTO kolcsonzesek (konyv_id, kolcsonzo_olvaso, kolcsonzes_idopont, esedekesseg_idopont)
        VALUES (p_konyv_id, p_olvaso_id, SYSDATE, SYSDATE + 30);

UPDATE konyvek
        SET elerheto_peldanyszam = elerheto_peldanyszam - 1
        WHERE konyv_id = p_konyv_id;
        
DBMS_OUTPUT.PUT_LINE('A k�nyv sikeresen k�lcs�n�zve.');

-- Kiv�telkezel�s
EXCEPTION
        WHEN nincs_elerheto_peldany THEN
            DBMS_OUTPUT.PUT_LINE('Hiba: Nincs el�rhet� p�ld�ny a k�nyvb�l.');
        WHEN elojegyzett_konyv THEN
            DBMS_OUTPUT.PUT_LINE('Hiba: A k�nyv el�jegyzett.');
        WHEN kolcsonzes_limit THEN
            DBMS_OUTPUT.PUT_LINE('Hiba: Az olvas� el�rte a maxim�lis k�lcs�n�zhet� k�nyvek sz�m�t.');
        WHEN magas_tartozas THEN
            DBMS_OUTPUT.PUT_LINE('Hiba: Az olvas� tartoz�sa meghaladja az 5000 forintot.');
END kolcsonzes;

END konyvek_pkg;
/