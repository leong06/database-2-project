-- Triggerek

-- Automatikus olvas�sz�m

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


-- Automatikus k�lcs�nz�s id

CREATE OR REPLACE TRIGGER trg_auto_kolcsonzes_id
BEFORE INSERT ON kolcsonzes
FOR EACH ROW
BEGIN
    :NEW.kolcsonzes_id:= kolcsonzes_id_seq.NEXTVAL;
END;


-- El�jegyz�s id

CREATE OR REPLACE TRIGGER trg_auto_elojegyzes_id
BEFORE INSERT ON elojegyzes
FOR EACH ROW
BEGIN
    :NEW.elojegyzes_id:= elojegyzes_id_seq.NEXTVAL;
END;

-- ID �tm�sol�sa a k�lcs�nz�si el�zm�nyekbe

CREATE OR REPLACE TRIGGER trg_kolcsonzesi_elozmeny_id
BEFORE INSERT ON kolcsonzesi_elozmeny
FOR EACH ROW
BEGIN
    :NEW.id:= kolcsonzes_id_seq.currval;
END;

-- Automatikus tartoz�s id

CREATE OR REPLACE TRIGGER trg_auto_tartozasid
BEFORE INSERT ON tartozas
FOR EACH ROW
BEGIN
    :NEW.tartozas_id := tartozas_id_seq.NEXTVAL;
END;


-- K�lcs�nz�si el�zm�nyek r�gz�t�se

CREATE OR REPLACE TRIGGER KolcsonzesiElozmeny_Trigger
AFTER INSERT OR UPDATE ON kolcsonzes
FOR EACH ROW
BEGIN
    -- K�nyv kik�lcs�nz�se eset�n
    IF INSERTING THEN
        olvaso_pkg.HandleInsert(
            kolcsonzo_olvaso => :NEW.kolcsonzo_olvaso,
            konyv_id => :NEW.konyv_id,
            kolcsonzes_idopont => :NEW.kolcsonzes_idopont
        );
    END IF;

    -- K�nyv visszahoz�sa eset�n
    IF UPDATING AND :NEW.visszahozatal_idopont IS NOT NULL THEN
        olvaso_pkg.HandleUpdate(
            kolcsonzo_olvaso => :NEW.kolcsonzo_olvaso,
            konyv_id => :NEW.konyv_id,
            visszahozatal_idopont => :NEW.visszahozatal_idopont
        );
    END IF;
END KolcsonzesiElozmeny_Trigger;

-- K�lcs�nz�s �llapota friss�t�se
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
