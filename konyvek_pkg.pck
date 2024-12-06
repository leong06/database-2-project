CREATE OR REPLACE PACKAGE konyvek_pkg IS
  -- Kiv�telek
  nincs_elerheto_peldany      EXCEPTION;
  elojegyzett_konyv           EXCEPTION;
  kolcsonzes_limit            EXCEPTION;
  magas_tartozas              EXCEPTION;
  ex_tartozas_tul_lepve       EXCEPTION;
  ex_max_elojegyzes_tul_lepve EXCEPTION;
  ex_nem_kolcsonzott_konyv    EXCEPTION;

  PROCEDURE kolcsonzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER);

  PROCEDURE elojegyzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER);

  PROCEDURE visszahozas(p_konyv_id  IN NUMBER
                       ,p_olvaso_id IN NUMBER);

END konyvek_pkg;
/
CREATE OR REPLACE PACKAGE BODY konyvek_pkg IS

  -- K�lcs�nz�s procedure

  PROCEDURE kolcsonzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER) IS
    lv_elerheto_peldany      NUMBER;
    lv_elojegyzes            NUMBER;
    lv_kolcsonzott_peldanyok NUMBER;
    lv_ossz_tartozas         NUMBER;
  
  BEGIN
    -- 1. Van-e szabad p�ld�ny a k�nyvb�l?
  
    SELECT elerheto_peldanyszam
      INTO lv_elerheto_peldany
      FROM konyvek
     WHERE konyv_id = p_konyv_id;
  
    IF lv_elerheto_peldany <= 0
    THEN
      RAISE nincs_elerheto_peldany;
    END IF;
  
    -- 2. Van-e el�jegyz�s a k�nyvre?
  
    SELECT COUNT(*)
      INTO lv_elojegyzes
      FROM elojegyzesek
     WHERE konyv_id = p_konyv_id
       AND foglalas_allapota = 'Akt�v';
  
    IF lv_elojegyzes > 0
    THEN
      RAISE elojegyzett_konyv;
    END IF;
  
    -- 3. Az olvas� k�lcs�n�zhet k�nyvet? (Nem l�pte �t a limitet?)
  
    SELECT COUNT(*)
      INTO lv_kolcsonzott_peldanyok
      FROM kolcsonzesek
     WHERE kolcsonzo_olvaso = p_olvaso_id
       AND visszahozatal_idopont IS NULL;
  
    IF lv_kolcsonzott_peldanyok >= 10
    THEN
      RAISE kolcsonzes_limit;
    END IF;
  
    -- 4. Meghaladja-e az olvas� tartoz�sa az 5000 forintot?
  
    SELECT SUM(tartozas_merteke)
      INTO lv_ossz_tartozas
      FROM tartozas
     WHERE olvaso_szam = p_olvaso_id
       AND tartozas_teljesulese IS NULL;
  
    IF lv_ossz_tartozas > 5000
    THEN
      RAISE magas_tartozas;
    END IF;
  
    -- K�lcs�nz�s
    INSERT INTO kolcsonzesek
      (konyv_id
      ,kolcsonzo_olvaso
      ,kolcsonzes_idopont
      ,esedekesseg_idopont)
    VALUES
      (p_konyv_id
      ,p_olvaso_id
      ,SYSDATE
      ,SYSDATE + 30);
  
    UPDATE konyvek
       SET elerheto_peldanyszam = elerheto_peldanyszam - 1
     WHERE konyv_id = p_konyv_id;
  
    dbms_output.put_line('A k�nyv sikeresen k�lcs�n�zve.');
  
    -- Kiv�telkezel�s
  EXCEPTION
    WHEN nincs_elerheto_peldany THEN
      dbms_output.put_line('Hiba: Nincs el�rhet� p�ld�ny a k�nyvb�l.');
    WHEN elojegyzett_konyv THEN
      dbms_output.put_line('Hiba: A k�nyv el�jegyzett.');
    WHEN kolcsonzes_limit THEN
      dbms_output.put_line('Hiba: Az olvas� el�rte a maxim�lis k�lcs�n�zhet� k�nyvek sz�m�t.');
    WHEN magas_tartozas THEN
      dbms_output.put_line('Hiba: Az olvas� tartoz�sa meghaladja az 5000 forintot.');
  END kolcsonzes;

  -- El�jegyz�s procedure

  PROCEDURE elojegyzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER) IS
    v_tartozas           NUMBER(10, 2);
    v_aktiv_elojegyzesek NUMBER;
  BEGIN
    -- Ellen�rz�s: Tartoz�s
    SELECT nvl(SUM(tartozas_merteke), 0)
      INTO v_tartozas
      FROM tartozas
     WHERE olvaso_szam = p_olvaso_id
       AND tartozas_teljesulese IS NULL;
  
    IF v_tartozas > 0
    THEN
      RAISE ex_tartozas_tul_lepve;
    END IF;
  
    -- Ellen�rz�s: Akt�v el�jegyz�sek sz�ma
    SELECT COUNT(*)
      INTO v_aktiv_elojegyzesek
      FROM elojegyzesek
     WHERE foglalo_olvaso = p_olvaso_id
       AND foglalas_allapota = 'Akt�v';
  
    IF v_aktiv_elojegyzesek >= 3
    THEN
      RAISE ex_max_elojegyzes_tul_lepve;
    END IF;
  
    -- K�nyv el�jegyz�se
    INSERT INTO elojegyzesek
      (foglalo_olvaso
      ,foglalas_datum
      ,foglalas_allapota
      ,konyv_id)
    VALUES
      (p_olvaso_id
      ,SYSDATE
      ,'Akt�v'
      ,p_konyv_id);
  
    dbms_output.put_line('K�nyv el�jegyz�se sikeresen megt�rt�nt.');
  EXCEPTION
    WHEN ex_tartozas_tul_lepve THEN
      dbms_output.put_line('Nem jegyezhet el� k�nyvet, mivel tartoz�sa van!');
    WHEN ex_max_elojegyzes_tul_lepve THEN
      dbms_output.put_line('Nem jegyezhet el� k�nyvet, mivel m�r h�rom akt�v el�jegyz�se van!');
    WHEN OTHERS THEN
      dbms_output.put_line('Hiba t�rt�nt a k�nyv el�jegyz�se sor�n.');
  END elojegyzes;

  -- 3. K�nyv visszahoz�s

  PROCEDURE visszahozas(p_konyv_id  IN NUMBER
                       ,p_olvaso_id IN NUMBER) IS
    v_esedekesseg_datum    DATE;
    v_visszahozatal_datum  DATE := SYSDATE;
    v_kesedelmi_napok      NUMBER := 0;
    v_elerheto_peldanyszam NUMBER;
    
  BEGIN
    -- Ellen�rz�s: Az olvas� val�ban kik�lcs�n�zte-e a k�nyvet
    SELECT esedekesseg_idopont
      INTO v_esedekesseg_datum
      FROM kolcsonzesek
     WHERE konyv_id = p_konyv_id
       AND kolcsonzo_olvaso = p_olvaso_id
       AND visszahozatal_idopont IS NULL;
  
    -- K�sedelem kisz�m�t�sa (ha van):
    IF v_visszahozatal_datum > v_esedekesseg_datum
    THEN
      v_kesedelmi_napok := v_visszahozatal_datum - v_esedekesseg_datum;
    END IF;
  
    UPDATE kolcsonzesek
       SET visszahozatal_idopont = v_visszahozatal_datum
     WHERE konyv_id = p_konyv_id
       AND kolcsonzo_olvaso = p_olvaso_id;
  
    SELECT elerheto_peldanyszam
      INTO v_elerheto_peldanyszam
      FROM konyvek
     WHERE konyv_id = p_konyv_id;
  
    UPDATE konyvek
       SET elerheto_peldanyszam = v_elerheto_peldanyszam + 1
     WHERE konyv_id = p_konyv_id;
  
    -- K�sedelmi d�j r�gz�t�se (ha van):
    IF v_kesedelmi_napok > 0
    THEN
      INSERT INTO tartozas
        (olvaso_szam
        ,konyv_id
        ,tartozas_merteke
        ,tartozas_teljesulese)
      VALUES
        (p_olvaso_id
        ,p_konyv_id
        ,v_kesedelmi_napok * 50
        ,NULL);
    
      dbms_output.put_line('K�sedelmi d�j: ' || v_kesedelmi_napok * 50 ||
                           ' Ft');
    ELSE
      dbms_output.put_line('K�nyv id�ben visszahozva, nincs k�sedelmi d�j.');
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      RAISE ex_nem_kolcsonzott_konyv;
    WHEN ex_nem_kolcsonzott_konyv THEN
      dbms_output.put_line('Az adott olvas� nem k�lcs�n�zte ki ezt a k�nyvet, vagy m�r visszahozta.');
    WHEN OTHERS THEN
      dbms_output.put_line('Hiba t�rt�nt a k�nyv visszahoz�sa sor�n.');
  END visszahozas;

END konyvek_pkg;
/
