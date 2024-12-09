-- Triggerek

-- Automatikus olvasószám

CREATE OR REPLACE TRIGGER trg_auto_olvasoszam
BEFORE INSERT ON Beiratkozott_Olvasok
FOR EACH ROW
BEGIN
    :NEW.olvasoszam := olvasoszam_seq.NEXTVAL;
END;

-- Automatikus kölcsönzés id

CREATE OR REPLACE TRIGGER trg_auto_kolcsonzes_id
BEFORE INSERT ON kolcsonzesek
FOR EACH ROW
BEGIN
    :NEW.kolcsonzes_id:= kolcsonzes_id_seq.NEXTVAL;
END;


-- Elõjegyzés id

CREATE OR REPLACE TRIGGER trg_auto_elojegyzes_id
BEFORE INSERT ON elojegyzesek
FOR EACH ROW
BEGIN
    :NEW.elojegyzes_id:= elojegyzes_id_seq.NEXTVAL;
END;

-- ID átmásolása a kölcsönzési elõzményekbe

CREATE OR REPLACE TRIGGER trg_kolcsonzesi_elozmeny_id
BEFORE INSERT ON kolcsonzesi_elozmenyek
FOR EACH ROW
BEGIN
    :NEW.id:= kolcsonzes_id_seq.NEXTVAL;
END;



-- Kölcsönzési elõzmények rögzítése

CREATE OR REPLACE TRIGGER KolcsonzesiElozmenyek_Trigger
AFTER INSERT OR UPDATE ON Kolcsonzesek
FOR EACH ROW
BEGIN
    -- Könyv kikölcsönzése esetén
    IF INSERTING THEN
        INSERT INTO kolcsonzesi_elozmenyek (olvaso_szam, konyv_id, kolcsonzes_idopont)
        VALUES (:NEW.kolcsonzo_olvaso, :NEW.konyv_id, :NEW.kolcsonzes_idopont);
    END IF;

    -- Könyv visszahozása esetén
    IF UPDATING AND :NEW.visszahozatal_idopont IS NOT NULL THEN
        UPDATE kolcsonzesi_elozmenyek
        SET visszahozatal_idopont = :NEW.visszahozatal_idopont
        WHERE olvaso_szam = :NEW.kolcsonzo_olvaso
          AND konyv_id = :NEW.konyv_id
          AND visszahozatal_idopont IS NULL;
    END IF;
END;
