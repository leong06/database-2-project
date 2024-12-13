CREATE OR REPLACE PROCEDURE get_kolcsonzesi_elozmeny(p_olvaso_szam IN NUMBER) IS
  BEGIN
    dbms_output.put_line('Bejelentkezett olvasó: ' || p_olvaso_szam);
  
    FOR rec IN (SELECT ke.kolcsonzes_idopont
                      ,ke.visszahozatal_idopont
                      ,k.cim
                      ,k.szerzo
                  FROM kolcsonzesi_elozmeny ke
                  JOIN konyv k
                    ON ke.konyv_id = k.konyv_id
                 WHERE ke.olvaso_szam = p_olvaso_szam
                 ORDER BY ke.kolcsonzes_idopont)
    LOOP
      dbms_output.put_line('Könyv: ' || rec.cim || ' - ' || rec.szerzo ||
                           ' | Kölcsönzés: ' ||
                           to_char(rec.kolcsonzes_idopont, 'YYYY-MM-DD') ||
                           ' | Visszahozatal: ' ||
                           nvl(to_char(rec.visszahozatal_idopont,
                                       'YYYY-MM-DD'),
                               'Nincs visszahozva'));
    END LOOP;
  END get_kolcsonzesi_elozmeny;
/
