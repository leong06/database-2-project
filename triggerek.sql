-- Triggerek

-- Automatikus olvas�sz�m

CREATE OR REPLACE TRIGGER trg_auto_olvasoszam
BEFORE INSERT ON Beiratkozott_Olvasok
FOR EACH ROW
BEGIN
    :NEW.olvasoszam := olvasoszam_seq.NEXTVAL;
END;

