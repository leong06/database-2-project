-- Triggerek

-- Automatikus olvasószám

CREATE OR REPLACE TRIGGER trg_auto_olvasoszam
BEFORE INSERT ON Beiratkozott_Olvasok
FOR EACH ROW
BEGIN
    :NEW.olvasoszam := olvasoszam_seq.NEXTVAL;
END;

