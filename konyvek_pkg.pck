CREATE OR REPLACE PACKAGE konyvek_pkg IS
  -- Kivételek
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

  -- Kölcsönzés procedure

  PROCEDURE kolcsonzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER) IS
    lv_elerheto_peldany      NUMBER;
    lv_elojegyzes            NUMBER;
    lv_kolcsonzott_peldanyok NUMBER;
    lv_ossz_tartozas         NUMBER;
  
  BEGIN
    -- 1. Van-e szabad példány a könyvbõl?
  
    SELECT elerheto_peldanyszam
      INTO lv_elerheto_peldany
      FROM konyvek
     WHERE konyv_id = p_konyv_id;
  
    IF lv_elerheto_peldany <= 0
    THEN
      RAISE nincs_elerheto_peldany;
    END IF;
  
    -- 2. Van-e elõjegyzés a könyvre?
  
    SELECT COUNT(*)
      INTO lv_elojegyzes
      FROM elojegyzesek
     WHERE konyv_id = p_konyv_id
       AND foglalas_allapota = 'Aktív';
  
    IF lv_elojegyzes > 0
    THEN
      RAISE elojegyzett_konyv;
    END IF;
  
    -- 3. Az olvasó kölcsönözhet könyvet? (Nem lépte át a limitet?)
  
    SELECT COUNT(*)
      INTO lv_kolcsonzott_peldanyok
      FROM kolcsonzesek
     WHERE kolcsonzo_olvaso = p_olvaso_id
       AND visszahozatal_idopont IS NULL;
  
    IF lv_kolcsonzott_peldanyok >= 10
    THEN
      RAISE kolcsonzes_limit;
    END IF;
  
    -- 4. Meghaladja-e az olvasó tartozása az 5000 forintot?
  
    SELECT SUM(tartozas_merteke)
      INTO lv_ossz_tartozas
      FROM tartozas
     WHERE olvaso_szam = p_olvaso_id
       AND tartozas_teljesulese IS NULL;
  
    IF lv_ossz_tartozas > 5000
    THEN
      RAISE magas_tartozas;
    END IF;
  
    -- Kölcsönzés
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
  
    dbms_output.put_line('A könyv sikeresen kölcsönözve.');
  
    -- Kivételkezelés
  EXCEPTION
    WHEN nincs_elerheto_peldany THEN
      dbms_output.put_line('Hiba: Nincs elérhetõ példány a könyvbõl.');
    WHEN elojegyzett_konyv THEN
      dbms_output.put_line('Hiba: A könyv elõjegyzett.');
    WHEN kolcsonzes_limit THEN
      dbms_output.put_line('Hiba: Az olvasó elérte a maximális kölcsönözhetõ könyvek számát.');
    WHEN magas_tartozas THEN
      dbms_output.put_line('Hiba: Az olvasó tartozása meghaladja az 5000 forintot.');
  END kolcsonzes;

  -- Elõjegyzés procedure

  PROCEDURE elojegyzes(p_konyv_id  IN NUMBER
                      ,p_olvaso_id IN NUMBER) IS
    v_tartozas           NUMBER(10, 2);
    v_aktiv_elojegyzesek NUMBER;
  BEGIN
    -- Ellenõrzés: Tartozás
    SELECT nvl(SUM(tartozas_merteke), 0)
      INTO v_tartozas
      FROM tartozas
     WHERE olvaso_szam = p_olvaso_id
       AND tartozas_teljesulese IS NULL;
  
    IF v_tartozas > 0
    THEN
      RAISE ex_tartozas_tul_lepve;
    END IF;
  
    -- Ellenõrzés: Aktív elõjegyzések száma
    SELECT COUNT(*)
      INTO v_aktiv_elojegyzesek
      FROM elojegyzesek
     WHERE foglalo_olvaso = p_olvaso_id
       AND foglalas_allapota = 'Aktív';
  
    IF v_aktiv_elojegyzesek >= 3
    THEN
      RAISE ex_max_elojegyzes_tul_lepve;
    END IF;
  
    -- Könyv elõjegyzése
    INSERT INTO elojegyzesek
      (foglalo_olvaso
      ,foglalas_datum
      ,foglalas_allapota
      ,konyv_id)
    VALUES
      (p_olvaso_id
      ,SYSDATE
      ,'Aktív'
      ,p_konyv_id);
  
    dbms_output.put_line('Könyv elõjegyzése sikeresen megtörtént.');
  EXCEPTION
    WHEN ex_tartozas_tul_lepve THEN
      dbms_output.put_line('Nem jegyezhet elõ könyvet, mivel tartozása van!');
    WHEN ex_max_elojegyzes_tul_lepve THEN
      dbms_output.put_line('Nem jegyezhet elõ könyvet, mivel már három aktív elõjegyzése van!');
    WHEN OTHERS THEN
      dbms_output.put_line('Hiba történt a könyv elõjegyzése során.');
  END elojegyzes;

  -- 3. Könyv visszahozás

  PROCEDURE visszahozas(p_konyv_id  IN NUMBER
                       ,p_olvaso_id IN NUMBER) IS
    v_esedekesseg_datum    DATE;
    v_visszahozatal_datum  DATE := SYSDATE;
    v_kesedelmi_napok      NUMBER := 0;
    v_elerheto_peldanyszam NUMBER;
    
  BEGIN
    -- Ellenõrzés: Az olvasó valóban kikölcsönözte-e a könyvet
    SELECT esedekesseg_idopont
      INTO v_esedekesseg_datum
      FROM kolcsonzesek
     WHERE konyv_id = p_konyv_id
       AND kolcsonzo_olvaso = p_olvaso_id
       AND visszahozatal_idopont IS NULL;
  
    -- Késedelem kiszámítása (ha van):
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
  
    -- Késedelmi díj rögzítése (ha van):
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
    
      dbms_output.put_line('Késedelmi díj: ' || v_kesedelmi_napok * 50 ||
                           ' Ft');
    ELSE
      dbms_output.put_line('Könyv idõben visszahozva, nincs késedelmi díj.');
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      RAISE ex_nem_kolcsonzott_konyv;
    WHEN ex_nem_kolcsonzott_konyv THEN
      dbms_output.put_line('Az adott olvasó nem kölcsönözte ki ezt a könyvet, vagy már visszahozta.');
    WHEN OTHERS THEN
      dbms_output.put_line('Hiba történt a könyv visszahozása során.');
  END visszahozas;

END konyvek_pkg;
/
