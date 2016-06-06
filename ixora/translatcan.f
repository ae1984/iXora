/* translatcan.f 
 * MODULE
        Переводы
 * DESCRIPTION
        Отмена переводов 
 * RUN
        recall.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        21.06.2005 Ilchuk
 * CHANGES
        21.07.05 nataly добавлен код валюты внесения наличности
*/

def var v-name-val as char.
def var v-name-valcash as char.
def var v-stat as char format 'x(20)'.
def var v-tim as char.
def var v-send-tim as char.
def var v-tim-otm as char.
def var v-tim-vidach as char.
def var v-tim-pod-otm as char.


function f-crc returns logical (val as int).
   return can-find(crc where crc.crc = val no-lock).
end.

function val-code returns logical (val as char).
   if val = "" then
      return false.
   find first spr_bank where spr_bank.code = val no-lock no-error.
    if avail spr_bank then 
     return true.
    else
     return false.
end.

form translat.nomer        colon 26 label 'Контрольный N перевода'  translat.jh          colon 60 format "zzzzzzzz9" label "N проводки"         skip     
     "--------------------------------------- Реквизиты отправителя --------------------------------------"   skip
     translat.fam          colon 26 validate(translat.fam <> "", "")        skip     
     translat.name         colon 26 validate(translat.name <> "", "")       skip     
     translat.otch         colon 26           skip     
     translat.resident     colon 26 validate(translat.resident = 1 or translat.resident = 2, "")    skip     
     translat.type-doc     colon 26 validate(translat.type-doc <> "", "") label 'Док. удост-щий личность'  skip     
     translat.cod-country  colon 26 validate(can-find (codfr where codfr.codfr = "iso3166" and codfr.code = translat.cod-country no-lock), " Код страны не найден в справочнике ISO3166!") /* v-name-cou format 'x(25)' NO-LABELS*/ skip
     translat.series       colon 26           skip     
     translat.nom-doc      colon 26 format "x(20)"  validate(translat.nom-doc <> "", "")   skip     
     translat.vid-doc      colon 26 validate(translat.vid-doc <> "", "")                   skip     
     translat.dt-doc       colon 26 validate(translat.dt-doc > 01/01/1901, "")             skip     
     translat.addres       colon 26 format "x(45)" validate(translat.addres <> "", "")     skip     
     translat.tel          colon 26           skip     
     "--------------------------------------- Перевод ----------------------------------------------------"  skip
     translat.crc          colon 26 validate(f-crc(translat.crc), "") v-name-val NO-LABELS                   skip     
     translat.summa        colon 26 validate(translat.summa > 0, "") format "z,zzz,zzz,zzz,zz9.99"   skip     
     translat.commis       colon 26 validate(translat.commis > 0, "") format "z,zzz,zzz,zzz,zz9.99"  skip          
     translat.crc-cash         colon 26 validate(f-crc(translat.crc-cash), "") v-name-valcash NO-LABELS                   skip     

     "--------------------------------------- Реквизиты получателя ---------------------------------------"  skip
     translat.rec-fam      colon 26 validate(translat.rec-fam <> "", "")     skip     
     translat.rec-name     colon 26 validate(translat.rec-name <> "", "")    skip     
     translat.rec-otch     colon 26                                          skip     
     translat.rec-code     colon 26 validate(val-code(translat.rec-code), "Укажите код банка получателя перевода, f2 - выбор")   skip     
     translat.rec-bank     colon 26 format "x(40)"                           skip(1)     
     "--------------------------------------- Информация о переводе -------------------------------------"   skip
     v-stat                colon 34 label 'СТАТУС'                           skip     
     translat.date         colon 34 label 'Дата и время создания перевода' v-tim NO-LABELS          skip                  
     translat.send-date    colon 34 label 'Дата и время отправки перевода' v-send-tim NO-LABELS     skip                  
     translat.dt-otm       colon 34 label 'Дата и время формирования отмены' v-tim-otm NO-LABELS   skip                  
     translat.dt-pod-otm   colon 34 label 'Дата и время подтверждения отмены' v-tim-pod-otm NO-LABELS     skip                  
     translat.who          colon 34 label 'Сотрудник'                        skip     
                                                              
     with row 3 side-labels centered width 110 frame translatcan.

on help of translat.nomer in frame translatcan do:
    run h-cancel.
    translat.nomer:screen-value = return-value.
end. 

on help of translat.crc-cash in frame translatcan do:
    run h-crc.
    translat.crc-cash:screen-value = return-value.
end. 








