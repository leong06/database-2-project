create or replace procedure get_kolcsonzesi_elozmenyek(p_olvaso_szam IN NUMBER) is
begin
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Bejelentkezett olvasó: ' || p_olvaso_szam);
    
    FOR rec IN (
        SELECT ke.kolcsonzes_idopont, ke.visszahozatal_idopont, k.cim, k.szerzo
        FROM KolcsonzesiElmenyek ke
        JOIN Konyvek k ON ke.konyv_id = k.konyv_id
        WHERE ke.olvaso_szam = p_olvaso_szam
        ORDER BY ke.kolcsonzes_idopont
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Könyv: ' || rec.cim || ' - ' || rec.szerzo ||
                             ' | Kölcsönzés: ' || TO_CHAR(rec.kolcsonzes_idopont, 'YYYY-MM-DD') ||
                             ' | Visszahozatal: ' || NVL(TO_CHAR(rec.visszahozatal_idopont, 'YYYY-MM-DD'), 'Nincs visszahozva'));
    END LOOP;
end get_kolcsonzesi_elozmenyek;
/
