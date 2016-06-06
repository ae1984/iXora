/* s_change.p        
 * MODULE
        Переводы
 * DESCRIPTION
        Отмена переводов 
 * RUN
        change-per.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * AUTHOR
        15.07.2005 nataly
 * CHANGES
        20.07.05 nataly была добавлена проверка на ЕКНП

*/

{mainhead.i}
{opr-stat.i}

/*define new shared variable s-nomer like translat.nomer.
  */
{sisn.i 
    &head = "translat" 
    &headkey = "nomer"     
    &post = "ch"
    &option = "TRANSL"
    &start = " " 
    &end = " "
    &noedt = "false"
    &nodel = "false"
    &variable = " "
    &aftersub = " "
    
    &no-update = " "
    
    &update = "

    if translat.stat = 9 then do:        
       v-ans = true.
       message ' После отправки перевода, его редактирование невозможно! Отправить перевод?' view-as alert-box buttons yes-no title 'Внимание!' update v-ans. 
       if v-ans = true then find sub-cod where sub ='trl' and acc = translat.nomer and d-cod = 'eknp'no-lock   no-error  .
            if (avail  sub-cod  and sub-cod.ccode = 'msc') or not  avail sub-cod  then 
             do:                
               message 'Не заполнен справочник ЕКНП!!! Отправка перевода невозможна!'.
               pause 3.
                next.
             end.
            else do:
             run platezh(s-nomer).
             run create-file(translat.nomer).
             find current translat no-lock.
           end.
    end.  
    else do:
                message 'Перевод не подлежит редактированию, тк имеет статус ' opr-stat(translat.stat) '!!!' view-as alert-box.
                pause 3.
                return.
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
          with frame translatch.
    "
    &postdisplay = "  "
}

procedure crc. /* Определение кода валюты*/
  find first crc where crc.crc = translat.crc no-lock no-error.
   if avail crc then
     v-name-val = crc.code.        
   else 
     v-name-val = "".

   displ v-name-val with frame translatch.
end.

