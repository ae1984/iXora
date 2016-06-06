cnt = 0.
cnti = 0.

/* обработка строк файла */
repeat:
    import unformatted str no-error.
    cnt = cnt + 1.

    if cnt = 1 then do:                 /* валюта */
       filehead[2] = trim(entry(1, str, ";")).
       v-crccode = filehead [2].
       wascrc = yes.
       next.
    end.

    if cnt = 2 then do:                 /* назначение платежа */
       filehead [3] = trim (entry(1, str, ";")).
       next.
    end.

    if cnt = 3 then next.               /* шапка с описаниями ячеек */

    if not endof and trim(entry(1, str, ";")) = "" then do:
       endof = yes.
       next.
    end.

    if endof and entry(1, caps(trim(str)), ";") = "ИТОГО" then  /* итоговая сумма */
    do:
       v-tot-amtbt = decimal (replace(trim(entry (6, str, ";")), ",", "." )).
       wasbt = yes.
       next.
    end.

    if not endof then do:
       /* создать новую запись */
    cnti = cnti + 1. 
    create tmp.
           tmp.num        = cnti.
           tmp.card       = trim (entry (5, str, ";")).
           tmp.fio        = trim (entry (1, str, ";")) + " " + trim (entry (2, str, ";")) + " " + trim (entry (3, str, ";")).
           tmp.sum        = decimal (replace (trim(entry (6, str, ";")), ",", ".")).
           if v-crccode = "KZT" then tmp.crc  = "1".
           if v-crccode = "USD" then tmp.crc  = "2".

           tmp.crccode    = v-crccode.
           tmp.trxdes     = "Начисление ЗП " + tmp.fio.
           tmp.sts        = "".
           tmp.stsname    = "".

    end.

end.





