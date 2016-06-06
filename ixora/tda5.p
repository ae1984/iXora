/* tda5.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр сумм при предварительном закрытии депозитов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        17.03.2009 id00004
 * CHANGES
*/

{mainhead.i}


def input parameter v-aaa like aaa.aaa.
def var d_1%    as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def var d_2%    as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */   
def var d_3%    as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def var d-brate2 as decimal decimals 2 . /*ставка до востребования в sysc*/
def var d-tstart as date. 
def var d-tstart1 as date. 
def var e-fire as logi.
def var vdel    as char initial "^".
def var vparam as char.
def var rcode  as inte.
def var rdes   as char.
def var v-jh like jh.jh.
def var s-amt2  as decimal decimals 2.
def var s-amt11 as decimal decimals 2.
def var s-amt1  as decimal decimals 2.
def var i-out  as integer.
def var v-sumchkamt as decimal.
def var i-mon as integer.
def var v-opnamt as decimal.
def var t_date as date.
def var t_date2 as date.
def var d_sumrt as decimal.
def var v-rt1 as decimal.
def var t-aaa like aaa.aaa.
def buffer bf-aaa for aaa.
def buffer bf-acvolt for acvolt.
def buffer bf-acc for aaa.
def var t-ind as date.
def var ev-date as date.
def buffer bf-t for acvolt.
def temp-table tmp-conv like aaa_conv.


Function EventInRange returns date (input event as char, input vdat1 as date, input vdat2 as date).
def var curdate as date.
def var e-fire as logi.
curdate = vdat1.
repeat:
  run EventHandler(event, curdate, date(bf-acvolt.x1), date(bf-acvolt.x3) - 1, output e-fire).
  if e-fire then do:
     return curdate.
  end.
  curdate = curdate + 1.
  if curdate > vdat2 then return ?.   
end.        
End Function.



   do transaction:
   find last aaa where aaa.aaa = v-aaa exclusive-lock no-error.
     if aaa.crc = 1  then do: find sysc "ratekz" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end. 
     if aaa.crc = 2  then do: find sysc "rateus" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end. 
     if aaa.crc = 3 then do: find sysc "rateeu" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end.

   if not avail aaa then do:
      message "Не найден счет" aaa.aaa. pause. return.
   end.
 
   if aaa.opnamt = 0 then do:
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip " дата открытия не совпадает с взносом основной суммы или " skip " сделана неверная операция " skip " ПРОВЕРЬТЕ КОРРЕКТНОСТЬ СУММ И ВЫПОЛНИТЕ НАЧИСЛЕНИЕ % " view-as alert-box question buttons ok title "".
      return.
   end.

   find last acvolt where acvolt.aaa =  aaa.aaa no-lock no-error.
   if not avail acvolt then do:
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip "" view-as alert-box question buttons ok title "".
      return.
   end.

   if (aaa.cr[1] - aaa.dr[1]) - aaa.hbal <> 0 then do:
      message "Одним из пользователей было сделано частичное изъятие но выплата клиенту не произведена" skip "Необходимо произвести выплату доступных сумм затем закрыть депозит." skip "" view-as alert-box question buttons ok title "".
      return.
   end.


   find last crc where crc.crc = aaa.crc no-lock no-error.
   find last lgr where lgr.lgr = aaa.lgr no-lock no-error.

   def var v-sum as decimal.
   def var v-allsum as decimal.

   i-mon = 0.
   run Get_Month_Begin(date(acvolt.x1), g-today, output i-mon).
   t-aaa = aaa.aaa.


   v-sumchkamt = 0.
   /* Прошло меньше месяца */


   if i-mon < 1 then do:

      for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
          v-sumchkamt = v-sumchkamt + aad.sumg .
      end.
      v-sumchkamt  =  v-sumchkamt + aaa.opnamt.

      d_1% = (aaa.cr[1] - aaa.dr[1]) - v-sumchkamt - aaa.stmgbal.
      d_3% = 0.
      if d_1% < 0 then d_1% = 0.
   end.
   else 
   do:
      v-sumchkamt = 0.


      t_date = date(acvolt.x1).
      t_date2 = g-today - 1.
      d_sumrt = 0.
      v-rt1 = 0.
      repeat: /*выбор конвертаций*/
         find last aaa_conv where aaa_conv.aaa = t-aaa  no-lock no-error.
         if not avail aaa_conv then leave.
         if avail aaa_conv then do:
            create tmp-conv. tmp-conv.aaa = aaa_conv.aaa. tmp-conv.conv = aaa_conv.conv. tmp-conv.dt = aaa_conv.dt. tmp-conv.aaaold = aaa_conv.aaaold. tmp-conv.aaac = aaa_conv.aaac. t-aaa = aaa_conv.aaaold.
         end.
      end.
      find last bf-acvolt where bf-acvolt.aaa =  t-aaa no-lock no-error.
      if avail bf-acvolt then do:
         run Get_Rate_Real(t-aaa, date(bf-acvolt.x1), output v-rt1).
         if i-mon < 18 then do:
            run Get_Rate_18(t-aaa, date(bf-acvolt.x1), output v-rt1). 
         end.
      end.
      else 
      v-rt1 = 0.

      v-opnamt = aaa.opnamt.
      do t-ind = t_date to t_date2:
/*
message v-rt1.
pause 111. */

         find last tmp-conv where tmp-conv.dt = t-ind   no-error.
         if avail tmp-conv then do:
            t-aaa = tmp-conv.aaa.

            run Get_Rate_Real(tmp-conv.aaa, t-ind, output v-rt1).
            if i-mon < 18 then do:
               run Get_Rate_18(tmp-conv.aaa, t-ind, output v-rt1). 
            end.
 
         end.

         find last aad where aad.aaa = aaa.aaa and aad.regdt = t-ind and aad.who <> "bankadm" no-lock no-error.
         if avail aad then do:
            v-opnamt = v-opnamt + sumg.
         end.


         d_sumrt = d_sumrt + ((v-opnamt * (v-rt1) ) / (aaa.base * 100)).



          find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
          find last bf-acvolt where bf-acvolt.aaa = t-aaa no-lock no-error.
          if avail bf-aaa and avail bf-acvolt then do:
               
             ev-date = EventInRange("18", t-ind, t-ind).
             if ev-date <> ? then do:
                run tdagetrate(bf-aaa.aaa, bf-aaa.pri, bf-aaa.cla, ev-date, bf-aaa.opnamt, output v-rt1).
                if i-mon < 18 then do:
                   run Get_Rate_18(bf-aaa.aaa, t-ind, output v-rt1). 
                end.
              end.
          end.
       end.


       for each aad where aad.aaa = aaa.aaa and aad.who <> "bankadm" no-lock:
           v-sumchkamt = v-sumchkamt + aad.sumg .
       end.
       v-sumchkamt  =  v-sumchkamt + aaa.opnamt.



       if (aaa.cr[1] - aaa.dr[1]) >= (acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (aaa.accrued - (aaa.cr[2] - aaa.dr[2]) - aaa.stmgbal)) then do:
          d_1% = (aaa.cr[1] - aaa.dr[1]) - (acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (aaa.accrued - (aaa.cr[2] - aaa.dr[2]) - aaa.stmgbal) ).
          d_3% = 0.
       end.
       else do:
          d_1% = 0.
          d_3% =  (acvolt.bonusopnamt + v-sumchkamt + d_sumrt - (aaa.accrued - (aaa.cr[2] - aaa.dr[2]) - aaa.stmgbal)) - (aaa.cr[1] - aaa.dr[1]).
       end.

if i-mon >= 18 then do:
          d_1% = 0.
          d_3% = (aaa.cr[2] - aaa.dr[2]).
end.


   end.





           message "" skip
           "Сумма депозита при досрочном закрытии на текущую дату" skip
           " составляет "   trim(string((aaa.cr[1] - aaa.dr[1]) - d_1% + d_3%  ,'z,zzz,zzz,zz9.99-'))   crc.code 
            view-as alert-box  title "" .

           return.







end.


Procedure Get_Rate_Real. /*Возврещает ставку счета*/
   def input parameter a_aaa as char.
   def input parameter a_date as date.
   def output parameter r_rate as decimal.
   find last bf-acc where bf-acc.aaa = a_aaa no-lock no-error.
   if avail bf-acc then do:
      run tdagetrate(bf-acc.aaa, bf-acc.pri, bf-acc.cla, a_date, bf-acc.opnamt, output r_rate). 
   end.
   else
   r_rate = 0.
end.


Procedure Get_Rate_18. /*Возврещает ставку счета*/
   def input parameter a_aaa as char.
   def input parameter a_date as date.
   def output parameter r_rate as decimal.
   find last bf-t where bf-t.aaa = a_aaa no-lock no-error.
   if avail bf-t then do:
      r_rate = decimal(bf-t.x4).
   end.
   else
   r_rate = 0.
end.



Procedure Get_Month_Begin.
   def input parameter a_start as date.
   def input parameter e_date as date.
   def output parameter out_month as integer.

   def var vterm as inte.
   def var e_refdate as date.
   def var e_displdate as date.
   def var t_date as date.
   def var years as inte initial 0.
   def var months as inte initial 0.
   def var days as inte initial 0.

   def var t-years as inte initial 0.
   def var t-months as inte initial 0.
   def var t-days as inte initial 0.

   def var i as integer initial 0.


     vterm = 1.
     t_date = a_start.
     i = 0.
     


     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do: 
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/
 
          if months = 2 and (days = 29 or days = 30 or days = 31) then 
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end. 



       if e_displdate + 1 >= e_date then do:
          if e_displdate + 1 = e_date then i = i + 1.
          out_month = i.
          return.
       end.

       i = i + 1.

       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/
End procedure.


Procedure EventHandler.
def input parameter e_period as char.
def input parameter e_date as date.
def input parameter a_start as date.
def input parameter a_expire as date.
def output parameter e_fire as logi.

def var vterm as inte.
def var e_refdate as date.
def var e_displdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.

def var t-years as inte initial 0.
def var t-months as inte initial 0.
def var t-days as inte initial 0.


def var i as integer initial 0.

e_fire = false.
if e_period  = "N" then return.
else if e_period = "S" and e_date = a_start then do:
   e_fire = true.
   return.    
end.
else if e_period = "F" and e_date = a_expire then do:
   e_fire = true.
   return.
end.
else if e_period = "M" or e_period = "Q" or e_period = "Y" 
     or e_period = "1" or e_period = "2" or e_period = "3"
     or e_period = "4" or e_period = "5" or e_period = "6"
     or e_period = "7" or e_period = "8" or e_period = "9" or e_period = "18" then do:
     if e_period = "M" then vterm = 1.
     else if e_period = "Q" then vterm = 3.
     else if e_period = "Y" then vterm = 12.
     else vterm = integer(e_period).
     t_date = a_start.
     i = 1.



     repeat:
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.


       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do: 
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/
 
          if months = 2 and (days = 29 or days = 30 or days = 31) then 
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.

       if e_displdate > e_date then return.
       else if e_displdate > a_expire then return.
       if e_date = e_displdate then do:
          e_fire = true.
          return.
       end.  


       t_date = date(months, 15, year(t_date) + years).
       i = i + 1.
     end.  /*repeat*/

end.
else if e_period = "D" then e_fire = true.
End procedure.

