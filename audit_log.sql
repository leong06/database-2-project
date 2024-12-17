-- K�nyv history t�bla

CREATE TABLE konyv_h
(
  id          NUMBER,
  cim       VARCHAR2(300),
  szerzo      VARCHAR2(300),
  mod_user    VARCHAR2(300),
  created_on  TIMESTAMP(6),
  last_mod    TIMESTAMP(6),
  dml_flag    VARCHAR2(1), -- Jel�li: I = Insert, U = Update, D = Delete
  version     NUMBER
);


-- K�nyv audit trigger

CREATE OR REPLACE TRIGGER konyv_audit_trg
BEFORE INSERT OR UPDATE ON konyv
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
       -- Ha az ID mez� �res, szekvenci�val t�ltj�k
      IF :NEW.konyv_id IS NULL THEN
          :NEW.konyv_id := konyv_id_seq.NEXTVAL;
       END IF;
       --�j sor eset�n alap�rtelmezett �rt�kek
       :NEW.created_on := SYSDATE;
       :NEW.last_mod := SYSDATE;
       :NEW.dml_flag := 'I'; -- I = Insert
       :NEW.version := 1;
       :NEW.mod_user := SYS_CONTEXT('USERENV', 'OS_USER');

    ELSIF UPDATING THEN
       -- M�dos�t�s eset�n friss�tj�k az audit mez�ket
       :NEW.last_mod := SYSDATE;
       :NEW.dml_flag := 'U'; -- U = Update
       :NEW.mod_user := SYS_CONTEXT('USERENV', 'OS_USER');

       -- Verzi�sz�m n�vel�se
       :NEW.version := :OLD.version + 1;
    END IF;
END;

CREATE OR REPLACE TRIGGER konyv_htrg
AFTER DELETE OR UPDATE OR INSERT ON konyv
FOR EACH ROW
BEGIN
    IF DELETING THEN
        -- T�rl�s eset�n besz�rjuk a t�r�lt sor adatait a konyv_h t�bl�ba
        INSERT INTO konyv_h
          (id, cim, szerzo, mod_user, created_on, last_mod, dml_flag, version)
        VALUES
          (:OLD.konyv_id, :OLD.cim, :OLD.szerzo, SYS_CONTEXT('USERENV', 'OS_USER'), 
           :OLD.created_on, SYSDATE, 'D', :OLD.version + 1);

    ELSIF INSERTING THEN
        -- Besz�r�s eset�n az �j sort mentj�k az arch�v t�bl�ba
        INSERT INTO konyv_h
          (id, cim, szerzo, mod_user, created_on, last_mod, dml_flag, version)
        VALUES
          (:NEW.id, :NEW.cim, :NEW.szerzo, :NEW.mod_user, 
           :NEW.created_on, :NEW.last_mod, 'I', :NEW.version);

    ELSIF UPDATING THEN
        -- M�dos�t�s eset�n az �j �rt�kek ker�lnek az arch�v t�bl�ba
        INSERT INTO konyv_h
          (id, cim, szerzo, mod_user, created_on, last_mod, dml_flag, version)
        VALUES
          (:NEW.id, :NEW.cim, :NEW.szerzo, SYS_CONTEXT('USERENV', 'OS_USER'), 
           :NEW.created_on, SYSDATE, 'U', :NEW.version);
    END IF;
END;
