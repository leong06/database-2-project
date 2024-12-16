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

-- Automatikus k�nyv id
CREATE OR REPLACE TRIGGER trg_auto_konyvid
BEFORE INSERT ON konyv
FOR EACH ROW
BEGIN
    :NEW.konyv_id := konyv_id_seq.NEXTVAL;
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

-- Automatikus tartoz�s id

CREATE OR REPLACE TRIGGER trg_auto_tartozasid
BEFORE INSERT ON tartozas
FOR EACH ROW
BEGIN
    :NEW.tartozas_id := tartozas_id_seq.NEXTVAL;
END;

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
