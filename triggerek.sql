-- Triggerek

-- Automatikus olvasószám

CREATE OR REPLACE TRIGGER trg_auto_olvasoszam
BEFORE INSERT ON beiratkozott_olvaso
FOR EACH ROW
BEGIN
    :NEW.olvasoszam := olvasoszam_seq.NEXTVAL;
END;

CREATE OR REPLACE TRIGGER trg_auto_olvasoid
BEFORE INSERT ON beiratkozott_olvaso
FOR EACH ROW
BEGIN
    :NEW.olvaso_id := olvasoid_seq.NEXTVAL;
END;

-- Automatikus könyv id
CREATE OR REPLACE TRIGGER trg_auto_konyvid
BEFORE INSERT ON konyv
FOR EACH ROW
BEGIN
    :NEW.konyv_id := konyv_id_seq.NEXTVAL;
END;


-- Automatikus kölcsönzés id

CREATE OR REPLACE TRIGGER trg_auto_kolcsonzes_id
BEFORE INSERT ON kolcsonzes
FOR EACH ROW
BEGIN
    :NEW.kolcsonzes_id:= kolcsonzes_id_seq.NEXTVAL;
END;


-- Elõjegyzés id

CREATE OR REPLACE TRIGGER trg_auto_elojegyzes_id
BEFORE INSERT ON elojegyzes
FOR EACH ROW
BEGIN
    :NEW.elojegyzes_id:= elojegyzes_id_seq.NEXTVAL;
END;

-- Automatikus tartozás id

CREATE OR REPLACE TRIGGER trg_auto_tartozasid
BEFORE INSERT ON tartozas
FOR EACH ROW
BEGIN
    :NEW.tartozas_id := tartozas_id_seq.NEXTVAL;
END;


-- Kölcsönzési elõzmények rögzítése


CREATE OR REPLACE TRIGGER KolcsonzesiElozmeny_Trigger
AFTER INSERT OR UPDATE ON kolcsonzes
FOR EACH ROW
BEGIN
    -- Könyv kikölcsönzése esetén
    IF INSERTING THEN
        olvaso_pkg.HandleInsert(
            kolcsonzo_olvaso => :NEW.kolcsonzo_olvaso,
            konyv_id => :NEW.konyv_id,
            kolcsonzes_idopont => :NEW.kolcsonzes_idopont
        );
    END IF;

    -- Könyv visszahozása esetén
    IF UPDATING AND :NEW.visszahozatal_idopont IS NOT NULL THEN
        olvaso_pkg.HandleUpdate(
            kolcsonzo_olvaso => :NEW.kolcsonzo_olvaso,
            konyv_id => :NEW.konyv_id,
            visszahozatal_idopont => :NEW.visszahozatal_idopont
        );
    END IF;
END KolcsonzesiElozmeny_Trigger;

-- Kölcsönzés állapota frissítése
CREATE OR REPLACE TRIGGER UpdateKolcsozve
BEFORE UPDATE OF visszahozatal_idopont ON Kolcsonzes
FOR EACH ROW
BEGIN
    IF :NEW.visszahozatal_idopont IS NULL THEN
        :NEW.kolcsonozve := 'I';
    ELSE
        :NEW.kolcsonozve := 'N';
    END IF;
END UpdateKolcsozve;
