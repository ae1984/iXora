/* r-translat.f   
 * MODULE
        Переводы
 * DESCRIPTION
        Полученные переводы
 * RUN
        r-translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        19.06.2005 Ilchuk
 * CHANGES
        21.07.05 nataly добавлен код валюты внесения наличности
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        25.02.10 marinav - РНН получателя

*/

def var v-name-val as char.
def var v-name-val2 as char.
def var v-name-valcash as char.
def var v-name as char.
def var v-stat as char format 'x(30)'.
def var v-tim as char.
def var v-send-tim as char.
def var v-tim-vidach as char.
def var v-tim-uved as char.
def var v-tim-otm as char.
def var v-name-cou as char.

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

form r-translat.nomer        colon 26 label 'Контрольный N перевода'    r-translat.jh          colon 60 format "zzzzzzzz9" label "N проводки"  skip     
     "--------------------------------------- Реквизиты отправителя --------------------------------------"   skip
     r-translat.code         colon 26 r-translat.bank          colon 60 format "x(40)"                                     skip                                          
     r-translat.fam          colon 26                                                    skip     
     r-translat.name         colon 26                                                    skip     
     r-translat.otch         colon 26                                                    skip     
     r-translat.type-doc     colon 26  label 'Док. удост-щий личность'                   skip     
     r-translat.series       colon 26  r-translat.nom-doc      colon 60 format "x(20)"   skip               
     r-translat.dt-doc       colon 26  r-translat.vid-doc      colon 60                  skip                                                          
     r-translat.addres       colon 26 format "x(60)"                                     skip     
     r-translat.tel          colon 26                                                    skip     
     "--------------------------------------- Перевод ----------------------------------------------------"  skip
     r-translat.crc          colon 26 validate(f-crc(r-translat.crc), "") v-name-val NO-LABELS                   skip     
     r-translat.summa        colon 26 validate(r-translat.summa > 0, "") format "z,zzz,zzz,zzz,zz9.99"       skip     
     "--------------------------------------- Реквизиты получателя ---------------------------------------"  skip
     r-translat.rec-fam      colon 26                                                    skip     
     r-translat.rec-name     colon 26                                                    skip     
     r-translat.rec-otch     colon 26                                                    skip     
     r-translat.rec-resident colon 26 format ">9" validate(r-translat.rec-resident = 1 or r-translat.rec-resident = 2, "")  r-translat.acc format "x(12)"  colon 60 validate(r-translat.acc <> "", "Введите РНН") label "РНН" skip     
     r-translat.rec-type-doc colon 26 validate(r-translat.rec-type-doc <> "", "") label 'Док. удост-щий личность'  skip     
     r-translat.rec-cod-country  colon 26 validate(can-find (codfr where codfr.codfr = "iso3166" and codfr.code = r-translat.rec-cod-country no-lock), " Код страны не найден в справочнике ISO3166!")  v-name-cou format 'x(25)' NO-LABELS        skip
     r-translat.rec-series   colon 26 label 'Серия документа'     r-translat.rec-nom-doc      colon 60 format "x(20)"  validate(r-translat.rec-nom-doc <> "", "") label 'Номер документа'  skip                    
     r-translat.rec-dt-doc   colon 26 validate(r-translat.rec-dt-doc > 01/01/1901, "") label 'Когда выдан документ' r-translat.rec-vid-doc format 'x(15)'  colon 60 validate(r-translat.rec-vid-doc <> "", "") label 'Кем выдан документ' skip                      
     r-translat.rec-addres   colon 26 format "x(45)" validate(r-translat.rec-addres <> "", "")     skip     
     r-translat.rec-tel      colon 26           skip     
     "--------------------------------------- Выплата перевода ------------------------------------------"  skip
     r-translat.rec-crc          colon 26 validate(r-translat.rec-crc = r-translat.crc, "Валюта выплаты не соответствует валюте перевода!") v-name-val2 NO-LABELS                   skip     
     r-translat.rec-summa        colon 26 validate(r-translat.rec-summa = r-translat.summa, "Сумма выплаты не соответствует сумме перевода!") format "z,zzz,zzz,zzz,zz9.99"         skip          
     r-translat.crc-cash         colon 26 validate(f-crc(r-translat.crc-cash), "") v-name-valcash NO-LABELS                   skip     
     "--------------------------------------- Информация о переводе -------------------------------------"   skip
     v-stat                colon 26 label 'СТАТУС'                           skip     

     r-translat.send-date  colon 32 label 'Дата и время отправки перевода' v-send-tim NO-LABELS     skip                  
     r-translat.date       colon 32 label 'Дата и время доставки перевода' v-tim NO-LABELS         skip                       
     r-translat.dt-vidach  colon 32 label 'Дата и время выплаты перевода' v-tim-vidach NO-LABELS     skip                  
     r-translat.dt-otm     colon 32 label 'Дата и время отмены / возврата' v-tim-otm NO-LABELS     skip                  
     r-translat.who        colon 32 label 'Сотрудник выплативший перевод'  skip     

     with row 3 side-labels centered width 110 frame r-translat.

form translat.nomer        colon 26 label "Контрольный N перевода"          skip     
     "--------------------------------------- Реквизиты отправителя --------------------------------------"   skip
     translat.fam          colon 26 validate(translat.fam <> "", "")        skip     
     translat.name         colon 26 validate(translat.name <> "", "")       skip     
     translat.otch         colon 26           skip     
     translat.resident     colon 26 validate(translat.resident = 1 or translat.resident = 2, "")    skip     
     translat.type-doc     colon 26 validate(translat.type-doc <> "", "") label 'Док. удост-щий личность'  skip     
     translat.cod-country  colon 26 validate(can-find (codfr where codfr.codfr = "iso3166" and codfr.code = translat.cod-country no-lock), " Код страны не найден в справочнике ISO3166!")  v-name-cou format 'x(25)' NO-LABELS        skip
     translat.series       colon 26           skip     
     translat.nom-doc      colon 26 format "x(20)"  validate(translat.nom-doc <> "", "")   skip     
     translat.vid-doc      colon 26 validate(translat.vid-doc <> "", "")                   skip     
     translat.dt-doc       colon 26 validate(translat.dt-doc > 01/01/1901, "")             skip     
     translat.rnn          colon 26 format "x(12)" skip
     translat.addres       colon 26 format "x(45)" validate(translat.addres <> "", "")     skip     
     translat.tel          colon 26           skip     
     "--------------------------------------- Перевод ----------------------------------------------------"  skip
     translat.crc          colon 26 validate(f-crc(translat.crc), "") v-name-val NO-LABELS                   skip     
     translat.summa        colon 26 validate(translat.summa > 0, "") format "z,zzz,zzz,zzz,zz9.99"  skip     
     translat.commis       colon 26 validate(translat.commis > 0, "") label "Комиссия банка" format "z,zzz,zzz,zzz,zz9.99" skip          

     "--------------------------------------- Реквизиты получателя ---------------------------------------"  skip
     translat.rec-fam      colon 26 validate(translat.rec-fam <> "", "")     skip     
     translat.rec-name     colon 26 validate(translat.rec-name <> "", "")    skip     
     translat.rec-otch     colon 26                                          skip     
     translat.rec-code     colon 26 validate(val-code(translat.rec-code), "Укажите код банка получателя перевода, f2 - выбор")   skip     
     translat.rec-bank     colon 26 format "x(40)"                           skip(1)     
     "--------------------------------------- Информация о переводе -------------------------------------"   skip
     v-stat                colon 32 label 'СТАТУС'                           skip     
     translat.date         colon 32 label 'Дата и время создания перевода' v-tim NO-LABELS          skip                  
     translat.send-date    colon 32 label 'Дата и время отправки перевода' v-send-tim NO-LABELS     skip                  
     translat.dt-dostav    colon 32 label 'Дата и время доставки перевода' /* v-tim-dostav NO-LABELS */  skip                  
     translat.dt-vidach    colon 32 label 'Дата и время выплаты перевода'   v-tim-vidach NO-LABELS     skip                  
     translat.who          colon 32 label 'Сотрудник'                        skip       

     with row 3 side-labels centered width 110 frame translat.

on help of r-translat.nomer in frame r-translat do:
    run h-r-translat.
    r-translat.nomer:screen-value = return-value.
end. 
on help of r-translat.rec-crc in frame r-translat do:
    run h-crc.
    r-translat.rec-crc:screen-value = return-value.
end. 
on help of r-translat.crc-cash in frame r-translat do:
    run h-crc.
    r-translat.crc-cash:screen-value = return-value.
end. 

on help of r-translat.rec-cod-country in frame r-translat do:    
    run h-country.
    r-translat.rec-cod-country:screen-value = return-value.
end. 



/*r-translat.dt-uved-pol label 'Дата отправки уведом'   colon 94*/
/*v-tim-uved label 'Время отправки уведомл' colon 94*/









