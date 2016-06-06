/* cash.i  
 * MODULE
        Переводы 
 * DESCRIPTION
        Переводы (выгрузка в файл)
 * RUN
        x1-cash.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        18/07/05 nataly
 * CHANGES
        20/07/05 nataly добавлено no-lock
        27.07.05 nataly добавлена обработка банка по коду nmbr
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
*/

find first sysc where sysc.sysc = 'sendtr' no-lock no-error.   /* Пути откуда отправляем*/
if not avail sysc then do:
    message " Не найдена запись sendtr Б SYSC ".    
    pause 3.
    return.
end.

find nmbr where nmbr.code = 'translat' no-lock no-error.
find first spr_bank where spr_bank.code = nmbr.prefix no-lock no-error.
  if not avail spr_bank then do:
    message " Не найден банк отправитель перевода в таблице spr_bank!".    
    pause 3.
    return.
end.

find translat where translat.jh = p-pjh or translat.jh-voz = p-pjh no-lock no-error.
find r-translat where r-translat.jh = p-pjh  no-lock no-error.
 if avail translat then  do:
    find translat where translat.jh = p-pjh or translat.jh-voz = p-pjh exclusive-lock .
     if translat.stat = 11 then do: 
         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728 Перевод " + translat.nomer,
           "Перевод См. вложение." ,
            "1", "",
           sysc.chval + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).
 
          translat.stat = 2. /*ОТПРАВЛЕН*/
     end. 
     if translat.stat = 51 then do: 
         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
               "Kildd638Hsy728 Перевод ОТМЕНЕН" + translat.nomer,
               "Перевод ОТМЕНЕН См. вложение." ,
               "1", "",
               sysc.chval + "O"  + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).
  
          translat.stat = 5. 
     end.
     if translat.stat = 71 then do: 
         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
               "Kildd638Hsy728 Перевод ВОЗВРАЩЕН " + translat.nomer,
               "Перевод ВОЗВРАЩЕН См. вложение." ,
               "1", "",
               sysc.chval + "C" + substring(translat.nomer,5,6) + "." + spr_bank.eng-code  ).

          translat.stat = 7. 
     end.
 end. /*translat*/

 if avail r-translat then  do:
   find r-translat where r-translat.jh = p-pjh  exclusive-lock no-error.
     if r-translat.stat = 11 then do: 

         run mail  ("metroexport@ml01.metrobank.kz",
            "METROKOMBANK <mkb@metrokombank.kz>",
               "Kildd638Hsy728 Перевод ВЫПЛАЧЕН " + r-translat.nomer,
               "Перевод ВЫПЛАЧЕН См. вложение." ,
               "1", "",
               sysc.chval + "V"  + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code  ).
  
    r-translat.stat = 2.
   end.
 end. /*r-translat*/
       release translat.
       release r-translat.
