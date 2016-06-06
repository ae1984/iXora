/* tdaclose1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Закрытие счетов по депозитам "метро-СТАНДАРТ"
 * RUN
        вызов из процедуры
 * CALLER
        tdacls2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        04/14/2005 id00004
 * CONNECT
         bank
 * CHANGES
        15.04.2011 id00004 изменил условие по депозитам Метростандарт с 11.04.2011
        22/12/2011 evseev - добавил логирование
        04.09.2013 evseev - tz-1465
        28/10/2013 Luiza  - ТЗ 1932 изменила параметры шаблона cda0003 и uni0048
*/

{mainhead.i}

def input parameter v-aaa like aaa.aaa.
def var d_1%    as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def var d_2%    as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */
def var d_3%    as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def var d-brate2 as decimal decimals 2 . /*ставка до востребования в sysc*/
def var v-rt1 as decimal.
def var v-adate as date.
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
def var i-mon  as integer.
def var t-aaa like aaa.aaa.
def var d_sumrt as decimal.
def var t_date as date.
def var t_date2 as date.
def var t-ind as date.
def var ev-date as date.

def buffer bf-aaa for aaa.
def buffer bf-acvolt for acvolt.
def buffer bf-acc for aaa.


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
     if aaa.crc = 3  then do: find sysc "rateeu" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end.

   if not avail aaa then do:
      run savelog( "tdaclose1", aaa.aaa + " Не найден счет").
      message "Не найден счет" aaa.aaa. pause. return.
   end.

   /*if aaa.opnamt = 0 then do:
      run savelog( "tdaclose1", aaa.aaa + " счет открыт НЕКОРРЕКТНО дата открытия не совпадает с взносом основной суммы").
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip " дата открытия не совпадает с взносом основной суммы или " skip " сделана неверная операция " skip " ПРОВЕРЬТЕ КОРРЕКТНОСТЬ СУММ И ВЫПОЛНИТЕ НАЧИСЛЕНИЕ % " view-as alert-box question buttons ok title "".
      return.
   end.*/

   find last acvolt where acvolt.aaa =  aaa.aaa no-lock no-error.
   if not avail acvolt then do:
      run savelog( "tdaclose1", aaa.aaa + " счет открыт НЕКОРРЕКТНО").
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip "" view-as alert-box question buttons ok title "".
      return.
   end.


   def var v-rate as deci no-undo.
   find last crc where crc.crc = aaa.crc no-lock no-error.
   v-rate  = crc.rate[1].
   find last lgr where lgr.lgr = aaa.lgr no-lock no-error.

   i-mon = 0.
   run Get_Month_Begin(date(acvolt.x1), g-today, output i-mon).

   t-aaa = aaa.aaa.

   /* Прошло меньше месяца */
   if i-mon < 1 then do:
      run savelog( "tdaclose1", aaa.aaa + " меньше месяца").
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

       find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
       if avail bf-aaa then do:
          run Get_Rate(t-aaa, output v-rt1).
       end.
       else
        v-rt1 = 0.

       do t-ind = t_date to t_date2:
          find last tmp-conv where tmp-conv.dt = t-ind   no-error.
          if avail tmp-conv then do:
             run Get_Rate(tmp-conv.aaa, output v-rt1).
          end.
          d_sumrt = d_sumrt + ((aaa.opnamt * v-rt1) / (aaa.base * 100)).
       end.
       d_3% = d_sumrt.
       d_1% = 0.

   end. /*меньше месяца*/
   else


   do: /*больше месяца*/
      run savelog( "tdaclose1", aaa.aaa + " больше месяца").
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
       end.
       else
       v-rt1 = 0.

       do t-ind = t_date to t_date2:
          find last tmp-conv where tmp-conv.dt = t-ind   no-error.
          if avail tmp-conv then do:
             t-aaa = tmp-conv.aaa.


                run Get_Rate_Real(tmp-conv.aaa, t-ind, output v-rt1).


          end.
          d_sumrt = d_sumrt + ((aaa.opnamt * (v-rt1 / 2) ) / (aaa.base * 100)).







          find last bf-aaa where bf-aaa.aaa = t-aaa no-lock no-error.
          find last bf-acvolt where bf-acvolt.aaa = t-aaa no-lock no-error.
          if avail bf-aaa and avail bf-acvolt then do:

             ev-date = EventInRange("Y", t-ind, t-ind).
             if ev-date <> ? then do:
                run tdagetrate(bf-aaa.aaa, bf-aaa.pri, bf-aaa.cla, ev-date, bf-aaa.opnamt, output v-rt1).
             end.
          end.
       end.
       d_3% = d_sumrt.
       d_1% = 0.
   end.





  /*депозиты открытые с этой даты  должны удерживать все %*/
   if aaa.regdt >= 04.11.2011 then do:
      d_3% = 0.
      d_1% = 0.
   end.











   run savelog( "tdaclose1", aaa.aaa + "Сумма в размере" +
          trim(string((aaa.cr[1] - aaa.dr[1]) + d_3%,'z,zzz,zzz,zz9.99-')) +
          crc.code + " будет доступна к выплате!").
   message "ДОСРОЧНОЕ ЗАКРЫТИЕ ДЕПОЗИТА!" skip
           "Сумма в размере" trim(string((aaa.cr[1] - aaa.dr[1]) + d_3%,'z,zzz,zzz,zz9.99-')) crc.code " будет доступна к выплате!"  skip
           "Подтвердите закрытие депозита."
            view-as alert-box question buttons yes-no title "" update v-ans as logical.

   if v-ans then run savelog( "tdaclose1", aaa.aaa + " v-ans = true").
   else run savelog( "tdaclose1", aaa.aaa + " v-ans = false").


   if not v-ans then return.


   run tdaremholda(aaa.aaa).

   if g-today <> aaa.regdt then do:

         /* Проводка с 2 на 1 уровень */
         if d_3% > 0 and d_3% <= (aaa.cr[2] - aaa.dr[2]) then do:
            run savelog( "tdaclose1", aaa.aaa + " Проводка с 2 на 1 уровень ").
            run trxgen("TDA0001", vdel, string(d_3%) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               run savelog( "tdaclose1", aaa.aaa + " TDA0001 " + rdes).
               message "TDA0001" rdes. pause. undo,retry.
            end.
            else do:
               run trxsts(v-jh, 6, output rcode, output rdes).
               if rcode ne 0 then do:
                  run savelog( "tdaclose1", aaa.aaa + " " + rdes).
                  message rdes view-as alert-box title "". undo,retry.
               end.
            end.
         end.
         v-jh = 0.

         /* Проводка с 1 на 2 уровень */
         if d_1% > 0 and d_1% <= (aaa.cr[1] - aaa.dr[1]) then do:
            run savelog( "tdaclose1", aaa.aaa + "Проводка с 1 на 2 уровень").
            run trxgen("UNI0074", vdel, string(d_1%) + vdel + aaa.aaa + vdel + "Удержание процентов с 1 уровня" + vdel + string(lgr.autoext,"999"), "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               run savelog( "tdaclose1", aaa.aaa + " UNI0074 " + rdes).
               message "UNI0074 " rdes. pause. undo,retry.
            end.
         end.
         /*проводка со 2 на 11 или расходы*/

         s-amt2 = aaa.cr[2] - aaa.dr[2]  . s-amt11 = 0.
         find first trxbal where trxbal.subled = 'cif' and trxbal.acc = aaa.aaa and trxbal.level = 11 no-lock no-error.
         s-amt11 = truncate((trxbal.dam - trxbal.cam) / crc.rate[1], 2).
         if s-amt2 > s-amt11 then s-amt1 = s-amt2 - s-amt11.
         else do : s-amt1 = 0. s-amt11 = s-amt2. end.
         /* Проводка со 2 на 11 уровень */
         if s-amt11 > 0 then do:
            run savelog( "tdaclose1", aaa.aaa + "  Проводка со 2 на 11 уровень").
            v-jh = 0.
            /*vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11).*/
            if aaa.crc = 1 then vparam = string(0) + vdel + aaa.aaa + vdel + string(0) + vdel + aaa.aaa + vdel + "0" + vdel + string(s-amt11) + vdel + aaa.aaa.
            else vparam = string(0) + vdel + aaa.aaa + vdel + string(s-amt11) + vdel + aaa.aaa + vdel + string(round(s-amt11 * v-rate,2)) + vdel + string(0) + vdel + aaa.aaa.
            run trxgen ("cda0003", vdel, vparam, "CIF" , aaa.aaa ,  output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               run savelog( "tdaclose1", aaa.aaa + " cda0003 " + rdes).
               message "cda0003" ' ' rdes. pause. undo,retry.
            end. else
            do: /* штамповка транзакции */
                 run trxsts(v-jh, 6, output rcode, output rdes).
                 if rcode ne 0 then do:
                    run savelog( "tdaclose1", aaa.aaa + " " + rdes).
                    message rdes view-as alert-box title "". return.
                 end.
            end.
         end.
         /* Урегулируем разность если на 2 ур > чем на 11 */
         if s-amt1 > 0 then do:
            run savelog( "tdaclose1", aaa.aaa + " Урегулируем разность если на 2 ур > чем на 11 ").
            v-jh = 0.
            /*vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие".*/
            if aaa.crc = 1 then vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие" + vdel +
                                    string(0) + vdel + aaa.aaa + vdel + "" + vdel + "0".
            else vparam = string(0) + vdel + aaa.aaa + vdel + "" + vdel +
                                    string(s-amt1) + vdel + aaa.aaa + vdel + "Удержание процентов за частичное изъятие" + vdel + string(round(s-amt1 * v-rate,2)).
            run trxgen ("uni0048", vdel, vparam, "CIF" , aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then do:
               run savelog( "tdaclose1", aaa.aaa + " uni0048 " + rdes).
               message "uni0048" ' ' rdes. pause. undo,retry.
            end.
         end.
         aaa.sta = "E".
         run savelog( "tdaclose1", aaa.aaa + " статус " + aaa.sta).
   end.
   else do:      /* счет открыли сегодня */
      aaa.sta = "E".
      run savelog( "tdaclose1", aaa.aaa + "Депозит успешно закрыт. статус " + aaa.sta).
      message "Депозит успешно закрыт".
      pause.
   end.
end.















Procedure Get_Rate. /*Возвращает ставку до востребования*/
   def input parameter a_aaa as char.
   def output parameter r_rate as decimal.
   find last bf-acc where bf-acc.aaa = a_aaa no-lock no-error.
   if avail bf-acc then do:
     if bf-acc.crc = 1  then do: find sysc "ratekz" no-lock no-error. if available sysc then r_rate = sysc.deval. end.
     if bf-acc.crc = 2  then do: find sysc "rateus" no-lock no-error. if available sysc then r_rate = sysc.deval. end.
     if bf-acc.crc = 11 then do: find sysc "rateeu" no-lock no-error. if available sysc then r_rate = sysc.deval. end.
   end.
   else
     r_rate = 0.
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
     or e_period = "7" or e_period = "8" or e_period = "9" then do:
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
