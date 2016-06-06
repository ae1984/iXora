/* s_cancel.p       
 * MODULE
        Переводы
 * DESCRIPTION
        Возврат переводов 
 * RUN
        return-per.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        .
 * AUTHOR
        22.06.2005 Ilchuk
 * CHANGES
        21.07.05 nataly добавлен код валюты внесения наличности

*/

{mainhead.i}
{opr-stat.i}
def var v-name as char.

{sisn.i 
    &head = "translat" 
    &headkey = "nomer"     
    &post = "ret"
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
          update translat.crc-cash with frame translatret.
          v-ans = true.
          message 'Будет отослан запрос в банк-корреспондент на возврат перевода!         Возвратить перевод?'  view-as alert-box buttons yes-no title 'Внимание!' update v-ans.
          if v-ans = true then                   
            run payment-file(translat.nomer,4).
        end.  
        if translat.stat = 8 and translat.summa-voz = 0 then do:
           update translat.crc-val with frame translatret.
           run crc(translat.crc-val, output v-name).
            v-name-val2 = v-name.
            displ v-name-val2 with frame translatret.
           update translat.summa-voz with frame translatret.
           update translat.commis-voz with frame translatret.
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
          translat.crc-val translat.summa-voz translat.commis-voz 
          with frame translatret.
    "
    &postdisplay = "  "
}

procedure crc. /* Определение кода валюты*/
def input parameter v-crc as integer.
def output parameter v-name as char.
  find first crc where crc.crc = v-crc no-lock no-error.
   if avail crc then
     v-name = crc.code.        
   else 
     v-name = "".

/*   displ v-name-val2 with frame translatret.*/
end.


