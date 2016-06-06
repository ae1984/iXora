cnt = 0.
cnti = 0.

repeat:
    import unformatted str no-error.
    cnt = cnt + 1.
    if cnt < 3 then do:                   /* заголовок файла */
       filehead [cnt] = trim (str).
       next.
    end.

    if substring (str, 1, 2) = "BT" then  /* итоговая сумма */
    do:
       v-tot-amtbt = decimal (replace(trim(substr (str, 16)), ",", ".")).
       wasbt = yes.
       next.
    end.

    if str = "KZT" or                     /* смена валюты */
       str = "USD" then do:
                           wascrc       = yes.
                           wasbt        = no.
                           v-crccode    = str.
                           next.
                        end.
                        else if cnt = 3 then
                        do: /*Неверный формат */
                           str = "no".
                           leave.
                        end.

    if wasbt and not wascrc
             then do:
                      str = "yes".
                      leave. /* если был итог и нет смены валюты то выходим */
             end.
    
    if wascrc and not wasbt then wascrc = no. /* просто убрать признак смены валюты */

    cnti = cnti + 1. 
    create tmp.
           tmp.num        = cnti.
           tmp.card       = trim (substr (str, 1, 19)).
           tmp.fio        = trim (substr (str, 34)).
           tmp.sum        = decimal (replace(trim(substr (str, 20, 14)), ",", ".")).

           if v-crccode = "KZT" then tmp.crc  = "1".
           if v-crccode = "USD" then tmp.crc  = "2".

           tmp.crccode    = v-crccode.
           tmp.trxdes     = "Начисление ЗП " + trim (substr (str, 34)).
           tmp.sts        = "".
           tmp.stsname    = "".
       
end.


