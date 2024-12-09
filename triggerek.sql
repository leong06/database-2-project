-- Triggerek

-- Automatikus olvas�sz�m

CREATE OR REPLACE TRIGGER trg_auto_olvasoszam
BEFORE INSERT ON Beiratkozott_Olvasok
FOR EACH ROW
BEGIN
    :NEW.olvasoszam := olvasoszam_seq.NEXTVAL;
END;

-- Automatikus k�lcs�nz�s id

CREATE OR REPLACE TRIGGER trg_auto_kolcsonzes_id
BEFORE INSERT ON kolcsonzesek
FOR EACH ROW
BEGIN
    :NEW.kolcsonzes_id:= kolcsonzes_id_seq.NEXTVAL;
END;


-- El�jegyz�s id

CREATE OR REPLACE TRIGGER trg_auto_elojegyzes_id
BEFORE INSERT ON elojegyzesek
FOR EACH ROW
BEGIN
    :NEW.elojegyzes_id:= elojegyzes_id_seq.NEXTVAL;
END;

-- ID �tm�sol�sa a k�lcs�nz�si el�zm�nyekbe

CREATE OR REPLACE TRIGGER trg_kolcsonzesi_elozmeny_id
BEFORE INSERT ON kolcsonzesi_elozmenyek
FOR EACH ROW
BEGIN
    :NEW.id:= kolcsonzes_id_seq.NEXTVAL;
END;



-- K�lcs�nz�si el�zm�nyek r�gz�t�se

CREATE OR REPLACE TRIGGER KolcsonzesiElozmenyek_Trigger
AFTER INSERT OR UPDATE ON Kolcsonzesek
FOR EACH ROW
BEGIN
    -- K�nyv kik�lcs�nz�se eset�n
    IF INSERTING THEN
        INSERT INTO kolcsonzesi_elozmenyek (olvaso_szam, konyv_id, kolcsonzes_idopont)
        VALUES (:NEW.kolcsonzo_olvaso, :NEW.konyv_id, :NEW.kolcsonzes_idopont);
    END IF;

    -- K�nyv visszahoz�sa eset�n
    IF UPDATING AND :NEW.visszahozatal_idopont IS NOT NULL THEN
        UPDATE kolcsonzesi_elozmenyek
        SET visszahozatal_idopont = :NEW.visszahozatal_idopont
        WHERE olvaso_szam = :NEW.kolcsonzo_olvaso
          AND konyv_id = :NEW.konyv_id
          AND visszahozatal_idopont IS NULL;
    END IF;
END;
