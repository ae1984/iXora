/* TRNper_ps.p
 * MODULE
        Переводы 
 * DESCRIPTION
        Переводы (загрузка из файла)
 * RUN
        .
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * BASES
        BANK COMM 
 * AUTHOR
        21.07.05  nataly
 * CHANGES
       28.07.05 nataly формирование уведомления по r-translat.rec-code
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        20/08/08 marinav - для платежей по которым поменялись реквизиты не создавать новый, а ред-ть старый 


*/


{lgps.i} 
{global.i}
{checktime.i}

def stream v-data.
def var v-str as char.
def var v-fl as log init false.
def var v-s as char extent 3.
def temp-table t-table       /* Таблица в которой будут содержаться полученные переводы */
  field nomer     like r-translat.nomer      /* Номер перевода */  
  field code      like r-translat.code       /* Код пункта отправки перевода */      
  field bank      like r-translat.bank       /* Банк/филиал из которого отправлен перевод */
  field fam       like r-translat.fam        /* Фамилия отправителя */
  field name      like r-translat.name       /* Имя отправителя */
  field otch      like r-translat.otch       /* Отчество отправителя */                 
  field type-doc  like r-translat.type-doc   /* Документ отправителя */               
  field series    like r-translat.series     /* Серия документа */               
  field nom-doc   like r-translat.nom-doc    /* Номер документа */                              
  field vid-doc   like r-translat.vid-doc    /* Кем выдан документ */                              
  field dt-doc    like r-translat.dt-doc     /* Когда выдан документ */                              
  field addres    like r-translat.addres     /* Адрес отправителя */                              
  field tel       like r-translat.tel        /* Телефон отправителя */                                                            
  field rec-fam   like r-translat.rec-fam    /* Фамилия получателя */                                                            
  field rec-name  like r-translat.rec-name   /* Имя получателя */                                                            
  field rec-otch  like r-translat.rec-otch   /* Отчество получателя */                                                        
  field rec-code  like r-translat.rec-code     /* Код банка получателя */                                                                
  field rec-bank  like r-translat.rec-bank     /* Банк получателя */                                                            
  field crc       like crc.code              /* Балюта перевода */ 
  field summa     like r-translat.summa      /* Сумма перевода */                                                            
  field send-date like r-translat.send-date  /* Дата отправки перевода */
  field send-tim  like r-translat.send-tim.   /* Время отправки перевода */

def temp-table t-uved-vip        /* Таблица в которой будут содержаться уведомления о полученных и выплоченных переводах */
  field stat         as char                  /* Статус - ДОСТАВЛЕН, ВЫПЛАЧЕН */  
  field nomer        like translat.nomer      /* Номер перевода */  
  field code         like translat.rec-code   /* Код пункта отправки уведомления, выплаты перевода */      
  field bank         like translat.rec-bank   /* Банк/филиал из которого отправлено уведомление, выплачен перевод */
  field dt           like translat.dt-dostav  /* Дата доставки, выплаты перевода*/
  field tim          like translat.tim-dostav. /* Время доставки, выплаты перевода*/



find first sysc where sysc.sysc = 'rectr' no-lock no-error.
if not avail sysc then do:
    v-text =  " Не найдена запись rectr в SYSC ".
    run lgps.    
    return.
end.

input from os-dir(sysc.chval). 
repeat.
    import v-s.
    if v-s[3] <> 'F' then
      next.
    if substring(v-s[1],1,1) = 'U' or substring(v-s[1],1,1) = 'V' or substring(v-s[1],1,1) = 'O' or substring(v-s[1],1,1) = 'R' or substring(v-s[1],1,1) = 'C' then 
      next.

    unix silent value ("cat " + v-s[2] + " | koi2win > rpt.txt").

    input stream v-data from rpt.txt.
    repeat.
        create t-table.
        import stream v-data delimiter '|' t-table.            
    end.
    input stream v-data close.
end.
input close.

for each t-table no-lock:  
  if t-table.nomer = "" then
    next.
  find last r-translat where r-translat.nomer = t-table.nomer no-lock no-error.
    if avail r-translat then do:
         /* для платежей по которым поменялись реквизиты */
         if r-translat.send-date = t-table.send-date and r-translat.send-tim = t-table.send-tim  
            then next.
            else v-fl = true.
    end.
         


  find first crc where crc.code = t-table.crc no-lock no-error.
    if not avail crc then do:
      if t-table.crc = 'RUB' then do: /* Для Москвы */
         find first crc where crc.code = 'RUR' no-lock no-error.
           if not avail crc then do:
             v-text =  " Не найдена валюта " + t-table.crc + "перевода в crc! Для N перевода " + t-table.nomer.
             run lgps.    
             leave.
           end.
      end.
    end.

   if v-fl = false then create r-translat. 
   if v-fl = true  then find current r-translat exclusive-lock.
      r-translat.nomer     = t-table.nomer.      /* Номер перевода */      
      r-translat.code      = t-table.code.       /* Код пункта отправки перевода */ 
      r-translat.bank      = t-table.bank.       /* Банк/филиал из которого отправлен перевод */
      r-translat.rec-code  = t-table.rec-code.   /* Код пункта получателя перевода */ 
      r-translat.rec-bank  = t-table.rec-bank.   /* Банк/филиал в который отправлен перевод */
      r-translat.fam       = t-table.fam.        /* Фамилия отправителя */
      r-translat.name      = t-table.name.       /* Имя отправителя */
      r-translat.otch      = t-table.otch.       /* Отчество отправителя */                 
      r-translat.type-doc  = t-table.type-doc.   /* Документ отправителя */               
      r-translat.series    = t-table.series.     /* Серия документа */               
      r-translat.nom-doc   = t-table.nom-doc.    /* Номер документа */                              
      r-translat.vid-doc   = t-table.vid-doc.    /* Кем выдан документ */                              
      r-translat.dt-doc    = t-table.dt-doc.     /* Когда выдан документ */                              
      r-translat.addres    = t-table.addres.     /* Адрес отправителя */                              
      r-translat.tel       = t-table.tel.        /* Телефон отправителя */                                                            
      r-translat.rec-fam   = t-table.rec-fam.    /* Фамилия получателя */                                                            
      r-translat.rec-name  = t-table.rec-name.   /* Имя получателя */                                                            
      r-translat.rec-otch  = t-table.rec-otch.   /* Отчество получателя */                                                        
      r-translat.crc       = crc.crc.            /* Балюта перевода */ 
      r-translat.summa     = t-table.summa.      /* Сумма перевода */                                                            
      r-translat.send-date = t-table.send-date.  /* Дата отправки перевода */
      r-translat.send-tim  = t-table.send-tim.   /* Время отправки перевода */
      r-translat.date      = today.              /* Дата получения перевода */
      r-translat.tim       = time.               /* Время получения перевода */
      r-translat.stat      = 1.                 /* Статус перевода */

  /************* Формирование уведомления о получении перевода ******************/

    find first sysc where sysc.sysc = 'sendtr' no-lock no-error.   /* Пути откуда отправляем*/
    if not avail sysc then do:
        v-text =  " Уведомление о получении. Не найдена запись sendtr Б SYSC. ". 
        run lgps.    
        leave.
    end.

/*    find first spr_bank where spr_bank.our-bank = 1 no-lock no-error.
      if not avail spr_bank then do:
        v-text = " Не найден банк отправитель перевода в таблице spr_bank!".    
        run lgps.    
        leave.
      end.*/

    find first spr_bank where spr_bank.code = t-table.rec-code no-lock no-error.
      if not avail spr_bank then do:
        v-text = " Не найден банк отправитель перевода в таблице spr_bank!".    
        run lgps.    
        leave.
      end.


    find first r-translat where r-translat.nomer = t-table.nomer exclusive-lock no-error.
      if not avail r-translat then do:
        v-text = " Не найден перевод: " + t-table.nomer + ", для отправки уведомления о доставке! ".    
        run lgps.    
        leave.
      end.

    output to rpt.img.
    put unformatted "ДОСТАВЛЕН"          "|"  /* Статус */
                    r-translat.nomer     "|"  /* Номер перевода */
                    spr_bank.code        "|"  /* Код пункта отправки уведомления о переводе */      
                    spr_bank.name        "|"  /* Банк/филиал из которого отправлено уведомление о переводе */
                    r-translat.date      "|"  /* Дата доставки перевода */
                    r-translat.tim       "|"  /* Время доставки перевода */                                         
                                      skip.
    output close. pause 0.
    unix silent value ("cat rpt.img | win2koi > " + sysc.chval + "U" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code).



  run mail  ("metroexport@ml01.metrobank.kz",
           "METROKOMBANK <mkb@metrokombank.kz>",
           "Kildd638Hsy728 ДОСТАВЛЕН " + r-translat.nomer,
           "Перевод ДОСТАВЛЕН См. вложение." ,
            "1", "",
           sysc.chval + "U" + substring(r-translat.nomer,5,6) + "." + spr_bank.eng-code  ).
        
    RELEASE r-translat.
  
  /************* Окончание формирование уведомления о получении перевода ********/

end.



/*----------------- Оброботка уведомлений о доставке, выплате   -------------------- */
find first sysc where sysc.sysc = 'rectr' no-lock no-error.   /* Пути откуда затягиваем*/
if not avail sysc then do:
    v-text =  " Уведомление о получении. Не найдена запись rectr Б SYSC. ".
    run lgps.    
    leave.
end.


input from os-dir(sysc.chval). 
repeat.
    import v-s.
    if v-s[3] <> 'F' then
      next.
    if substring(v-s[1],1,1) <> 'U' and substring(v-s[1],1,1) <> 'V' and substring(v-s[1],1,1) <> 'O' and substring(v-s[1],1,1) <> 'R' and substring(v-s[1],1,1) <> 'C' then  /* Файл с доставкой имеет в начале имени файла букву U*/
      next.       

    unix silent value ("cat " + v-s[2] + " | koi2win > rpt.txt").
                                                         /* Файл с выплатой имеет в начале имени файла букву V*/
    input stream v-data from rpt.txt.                                /* Файл с отменой имеет в начале имени файла букву O*/
    repeat.         
        create t-uved-vip.
        import stream v-data delimiter '|' t-uved-vip.            
    end.
   input stream v-data close.

    v-text = "rm -f " + v-s[2].
    /*run lgps.    */
    /*unix silent value(v-text).*/
end.
input close.

for each t-uved-vip no-lock:  
  if t-uved-vip.nomer = "" then
    next.

  case t-uved-vip.stat:
     when "ДОСТАВЛЕН" then do:
      find first translat where translat.nomer = t-uved-vip.nomer exclusive-lock no-error.
        if not avail translat then do:
          v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
          run lgps.          
          next.
        end.

       if translat.stat < 3 then do: 
         translat.stat        = 3.
         translat.dt-dostav   = t-uved-vip.dt.
         translat.tim-dostav  = t-uved-vip.tim.
       end.
       RELEASE translat.
     end.
     when "ВЫПЛАЧЕН" then do:
      find first translat where translat.nomer = t-uved-vip.nomer exclusive-lock no-error.
        if not avail translat then do:
          v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
          run lgps.          
          next.
        end.

       if translat.stat < 4 then do: 
         translat.stat        = 4.
         translat.dt-vidach   = t-uved-vip.dt.
         translat.tim-vidach  = t-uved-vip.tim.
       end.
       RELEASE translat.
     end.
     when "ОТМЕНЕН" then do:
      find first r-translat where r-translat.nomer = t-uved-vip.nomer  exclusive-lock no-error.
        if r-translat.send-date < t-uved-vip.dt or r-translat.send-tim < t-uved-vip.tim then do:
           if not avail r-translat then do:
             v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
             run lgps.          
             next.
           end.
           if r-translat.stat = 1 then do: 
             r-translat.stat     = 3.
             r-translat.dt-otm   = t-uved-vip.dt.
             r-translat.tim-otm  = t-uved-vip.tim.
             run payment-file(r-translat.nomer,3). /* Уведомление об отмене перевода*/         
           end.
        end. 
        RELEASE r-translat.
     end.
     when "ПОДТВЕРЖДЕНИЕОТМЕНЕНЫ" then do:
      find first translat where translat.nomer = t-uved-vip.nomer exclusive-lock no-error.
        if not avail translat then do:
          v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
          run lgps.          
          next.
        end.
       if translat.stat = 5 then do: 
         translat.stat        = 6.
         translat.dt-pod-otm    = t-uved-vip.dt.
         translat.tim-pod-otm   = t-uved-vip.tim.
       end.
       RELEASE translat.
      end.
     when "ВОЗВРАЩЕН" then do:
      find first r-translat where r-translat.nomer = t-uved-vip.nomer exclusive-lock no-error.
        if not avail r-translat then do:
          v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
          run lgps.          
          next.
        end.

       if r-translat.stat = 1 then do: 
         r-translat.stat     = 4.
         r-translat.dt-otm   = t-uved-vip.dt.
         r-translat.tim-otm  = t-uved-vip.tim.
         run payment-file(r-translat.nomer,5). /* Уведомление об возврате перевода*/         
       end.
       RELEASE r-translat.
     end.
     when "ПОДТВЕРЖДЕНИЕВОЗВРАТА" then do:
      find first translat where translat.nomer = t-uved-vip.nomer exclusive-lock no-error.
        if not avail translat then do:
          v-text = " Не найден перевод: " + t-uved-vip.nomer + ", для изменения статуса! ".    
          run lgps.          
          next.
        end.
       if translat.stat = 7 then do: 
         translat.stat        = 8.
         translat.dt-pod-otm    = t-uved-vip.dt.
         translat.tim-pod-otm   = t-uved-vip.tim.         
       end.
       RELEASE translat.
     end.
  end.       
end.


