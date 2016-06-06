/* s_cancel.p        
 * MODULE
        Переводы
 * DESCRIPTION
        Отмена переводов 
 * RUN
        cancel-per.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * AUTHOR
        21.06.2005 Ilchuk
 * CHANGES
        21.07.05 nataly добавлен код валюты внесения наличности

*/

{mainhead.i}
{opr-stat.i}

{sisn.i 
    &head = "translat" 
    &headkey = "nomer"     
    &post = "can"
    &option = "TRANSL"
    &start = " " 
    &end = " "
    &noedt = "false"
    &nodel = "false"
    &variable = " "
    &aftersub = " "
    
    &no-update = " "
    
    &update = "

        if translat.stat = 2 or translat.stat = 3 then do:
          update translat.crc-cash with frame translatcan.
         v-ans = true.
          message 'Будет отослан запрос в банк-корреспондент на отмену перевода!         Отменить перевод?'  view-as alert-box buttons yes-no title 'Внимание!' update v-ans.
          if v-ans = true then                   
            run payment-file(translat.nomer,2).
        end.  

    " 

    &no-delete = "

    "
    &delete = " " 
    
    &predisplay = " 
                    find first crc where crc.crc = translat.crc no-lock no-error.
                    v-stat = opr-stat(translat.stat).
                    if translat.tim <> 0 then 
                      v-tim  = STRING(translat.tim, 'hh:mm:ss').
                    if translat.send-tim <> 0 then 
                      v-send-tim = STRING(translat.send-tim, 'hh:mm:ss').
                    if translat.tim-otm <> 0 then 
                      v-tim-otm = STRING(translat.tim-otm, 'hh:mm:ss').
                    if translat.tim-vidach <> 0 then 
                      v-tim-vidach = STRING(translat.tim-vidach, 'hh:mm:ss').
                    if translat.tim-pod-otm <> 0 then
                      v-tim-pod-otm = STRING(translat.tim-pod-otm, 'hh:mm:ss').

    "                                       

    &display = "        
     displ translat.nomer translat.jh v-stat translat.fam translat.name translat.otch translat.type-doc translat.series translat.nom-doc  
          translat.vid-doc translat.dt-doc translat.addres translat.tel translat.crc translat.summa translat.commis    
          translat.rec-fam translat.rec-name translat.rec-otch translat.rec-code translat.rec-bank
          (if avail crc then crc.code else '') @ v-name-val
          translat.date v-tim translat.send-date v-send-tim translat.who
          translat.dt-otm v-tim-otm translat.dt-pod-otm v-tim-pod-otm
          with frame translatcan.
    "
    &postdisplay = "  "
}

procedure crc. /* Определение кода валюты*/
  find first crc where crc.crc = translat.crc no-lock no-error.
   if avail crc then
     v-name-val = crc.code.        
   else 
     v-name-val = "".

   displ v-name-val with frame translatcan.
end.


