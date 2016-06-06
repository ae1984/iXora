/* dcls23.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Списание доходов с 13 уровня
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        24.05.2005 dpuchkov
 * CONNECT
        BANK
 * CHANGES
        15.07.2005 dpuchkov если последний месяц аренды то списываем всю оставшуюся сумму и все округления предыдущих месяцев.
        31.10.2005 dpuchkov добавил счет исключение.
        22.11.2005 dpuchkov добавил группу 412 (сл. записка от 22.11.05)
        27.02.2006 dpuchkov добавил процедуру начисления долга на 10 уровень
        05.04.2006 dpuchkov поменял местами списание комиссии и погашение долга.
        02.04.2006 dpuchkov добавил проверку если разница 0.01,0.02 списывать все в текущем месяце
        04.05.2006 dpuchkov закомментарил строку
        01.06.2006 dpuchkov добавил проверку на самый последний период аренды при начислении долга.
        06.06.2006 dpuchkov добавил коды доходов расходов.
        14.09.2006 dpuchkov исправил синтаксическую ошибку.
*/

{global.i}
{getdep.i}

define shared var s-target as date.
define shared var s-bday as log init true.
define shared var s-intday as int.
define var s-amt1 as decimal.
define var s-amt2 as decimal.



def var v-dep as char no-undo. 
def var v-code as char no-undo.
def var s-jh like jh.jh.
def buffer bjl for jl.




def var vdel as char initial "^".
def var rcode as inte.
def var rdes as char.
def var vparam as char.  
def var fname1 as char.
def var v-jh like jh.jh.
def var i_month as integer.

def var i_ind as integer.

def var i_day as integer.
def var s-amt as decimal.
def var iamt as integer.
def var s-amt10 as decimal decimals 2.
def var dolg as decimal decimals 2.

def var dd1 as date. 
def var dd2 as date.
def var iiday   as integer.
def var iimonth as integer.
def var iiyear  as integer.
def var dsum as decimal decimals 2.
def var depdpr as date.
def var depd2 as date.
def var dsd as date.
def var dsd0 as date.

Function gtmon returns integer (input mn as integer).
  if mn <> 12 then mn = mn + 1. else
  if mn = 12 then mn = 1.  
  return mn.
End Function.

Function gtmonmin returns integer (input mn as integer).
   if mn <> 1 then mn = mn - 1. else
   if mn = 1 then mn = 12.  
   return mn.
End Function.

Function GetLastNum returns date (input mn as date).
      if month(mn) = 1 then mn = date("31." + string(month(mn)) + "." +  string(year(mn))).
      if month(mn) = 2 and (year(mn) - 2000) modulo 4  = 0 then mn = date("29." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 2 and (year(mn) - 2000) modulo 4 <> 0 then mn = date("28." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 3 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 4 then mn = date("30." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 5 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 6 then mn = date("30." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 7 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 8 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 9 then mn = date("30." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 10 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 11 then mn = date("30." + string(month(mn)) + "." + string(year(mn))).
      if month(mn) = 12 then mn = date("31." + string(month(mn)) + "." + string(year(mn))).
      return mn.
End Function.


Function GetDay returns integer (input mn as date).
 def var vx as integer.
      if month(mn) = 1 then vx = 31.
      if month(mn) = 2 and (year(mn) - 2000) modulo 4  = 0 then vx = 29.
      if month(mn) = 2 and (year(mn) - 2000) modulo 4 <> 0 then vx = 28.
      if month(mn) = 3 then vx = 31.
      if month(mn) = 4 then vx = 30.
      if month(mn) = 5 then vx = 31.
      if month(mn) = 6 then vx = 30.
      if month(mn) = 7 then vx = 31.
      if month(mn) = 8 then vx = 31.
      if month(mn) = 9 then vx = 30.
      if month(mn) = 10 then vx = 31.
      if month(mn) = 11 then vx = 30.
      if month(mn) = 12 then vx = 31.
      return vx.
End Function.

def buffer b-depo  for depo.
def buffer b-depo1 for depo.
def buffer b-depo2 for depo.

   fname1 = "acccell" + substring(string(g-today),1,2) + substring(string(g-today),4,2) + ".txt".
   def stream m-out.
   output stream m-out to acccell.txt.

   put stream m-out unformatted "Списание комиссии по ячейкам " g-today skip.
      /* последний день месяца */
      for each aaa where  (lookup(aaa.lgr, "415,413,410,411,412") <> 0 or aaa.aaa = "001720668" or aaa.aaa = "002079282") and aaa.sta <> "C" and aaa.sta <> "E"  exclusive-lock:
v-jh = 0.
      if aaa.crc <> 1 then next.
 {iskl.i}

          find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 13 no-lock no-error.
          find last crc where crc.crc = aaa.crc no-lock no-error.
          if available trxbal then do:
             s-amt = truncate((trxbal.cam - trxbal.dam) / crc.rate[1],2).
          end.



/* списание в период задолженности */
/* если период задолженности меньше сегодн дня */
                               find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
                                      ((depo.lstdt <> ? and depo.prlngdate < g-today and decimal(depo.sum) <> decimal(depo.lev)) or 
                                      (depo.dt1 <> ? and depo.dt2 < g-today  and decimal(depo.prim1) <> decimal(depo.pr))) exclusive-lock no-error. 
                                  if avail depo then do:
                                     s-amt1 = 0. s-amt2 = 0.
                                     if (depo.lstdt <> ? and depo.prlngdate < g-today and decimal(depo.sum) <> decimal(depo.lev)) then do:
                                        s-amt1 = decimal(depo.sum) - decimal(depo.lev).
                                     end.
                                     if (depo.dt1 <> ? and depo.dt2 < g-today  and decimal(depo.prim1) <> decimal(depo.pr)) then do:
                                        s-amt2 = s-amt2 + decimal(depo.prim1) - decimal(depo.pr).
                                     end.
                                     if s-amt1 > 0 then do:
                                        v-jh = 0.
                                        vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.lstdt) + "по" + string(depo.prlngdate) + vdel + "".
                                        run trxgen ("uni0188", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                                           if rcode ne 0 then do:
                                              put stream m-out unformatted "-11Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                                           end.
                                           else do:
                                              depo.lev = string(decimal(depo.lev) + s-amt1).
/*                                            depo.pr = string(decimal(depo.pr) + s-amt1). */
                                              put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                                              run trxsts(v-jh, 6, output rcode, output rdes).
                                           end.
                                     end.
                                     if s-amt2 > 0 then do:
                                        v-jh = 0.
                                        vparam = string(s-amt2) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.dt1) + "по" + string(depo.dt2) + vdel + "".
                                        run trxgen ("uni0188", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                                           if rcode ne 0 then do:
                                              put stream m-out unformatted "-12Ошибка списания " aaa.aaa ", " string(s-amt2) " -> " rdes skip.
                                           end.
                                           else do:
                                              depo.pr = string(decimal(depo.pr) + s-amt2).
                                              put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt2) " c " string(depo.dt1) " по " string(depo.dt2) skip.
                                              run trxsts(v-jh, 6, output rcode, output rdes).
                                           end.
                                     end.
                                 end.

/* Списание задолженности если период перекрывает сегодняшний день */

{dlg.i}




         /* если конец месяца */
         if /* s-bday eq true and */ month(g-today) ne month(s-target) then do:

            find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and ((depo.lstdt <> ? and depo.lstdt <= GetLastNum(g-today) and depo.prlngdate >= GetLastNum(g-today))
                  or (depo.dt1 <> ? and depo.dt1 <= GetLastNum(g-today) and depo.dt2 >= g-today /* GetLastNum(g-today)*/ )) exclusive-lock no-error.
            if avail depo then do:

 /* списание за неполный месяц c 15.01 по 15.02 основной */
               if (string(depo.lstdt) <> ? and month(depo.lstdt) = month(g-today) and depo.prlngdate >= g-today and depo.prlngdate > GetLastNum(g-today)) then do:
                  if depo.prlngdate - depo.lstdt <= 0 then s-amt1 = 0. else
                     s-amt1 = round((depo.sum / (depo.prlngdate - depo.lstdt)) * (GetLastNum(g-today) - depo.lstdt + 1), 2).
                  if s-amt1 > 0 then do:
                     v-jh = 0.
                     vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.lstdt) + " по " + string(GetLastNum(g-today)) + vdel + "".
                     run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode ne 0 then do:
                        put stream m-out unformatted "-1Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                     end.
                     else do:
   depo.lev = string(decimal(depo.lev) + s-amt1).
                        put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) + " по " + string(GetLastNum(g-today)) skip.
                        run trxsts(v-jh, 6, output rcode, output rdes).
                     end.
                  end.
               end.

               else
 /* списание за неполный месяц c 15.01 по 15.02 по льготному */
               if (string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and depo.dt2 >= g-today and depo.dt2 > GetLastNum(g-today)) then do:
                  if depo.dt2 - depo.dt1 <= 0 then s-amt1 = 0. else 
                     s-amt1 = round((decimal(depo.prim1) / (depo.dt2 - depo.dt1)) * ((GetLastNum(g-today) - depo.dt1) + 1), 2).

                  if s-amt1 > 0 then do:
                     v-jh = 0.
                     vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.dt1) + " по " + string(GetLastNum(g-today)) + vdel + "".
                     run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode ne 0 then do:
                        put stream m-out unformatted "-2Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                     end.
                     else do:
    depo.pr = string(decimal(depo.pr) + s-amt1).
                        put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.dt1) + " по " + string(GetLastNum(g-today)) skip.
                        run trxsts(v-jh, 6, output rcode, output rdes).
                     end.
                  end.
               end.
               else

 /* списание за неполный месяц с 05 по 30 осн и льготный */
 if (string(depo.lstdt) <> ? and month(depo.lstdt) = month(g-today) and month(depo.prlngdate) = month(g-today) and day(depo.prlngdate) > day(g-today)) 

 or (string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and month(depo.dt2) = month(g-today) and day(depo.dt2) > day(g-today))
               then do:
                  s-amt1 = depo.sum.

                     v-jh = 0.
                     if (string(depo.lstdt) <> ? and month(depo.lstdt) = month(g-today) and month(depo.prlngdate) = month(g-today) and day(depo.prlngdate) > day(g-today)) then do:
                        vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.lstdt) + " по " + string(depo.prlngdate) + vdel + "". 
                     end.
                     else
                     if (string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and month(depo.dt2) = month(g-today) and day(depo.dt2) > day(g-today)) then do:
                        s-amt1 = decimal(depo.prim1).
                        if s-amt1 + decimal(depo.pr) > decimal(depo.prim1) then do:
                           put stream m-out unformatted "-3Ошибка списания " aaa.aaa ", " string(s-amt1) " -> Превышает внесённую сумму " skip.
                           s-amt1 = 0. 
                        end.

                        vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.dt1) + " по " + string(depo.dt2) + vdel + "".
                     end.
                  if s-amt1 > 0 then do:
                     run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     if rcode ne 0 then do:
                        put stream m-out unformatted "-4Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                     end.
                     else do:
                        if (string(depo.lstdt) <> ? and month(depo.lstdt) = month(g-today) and month(depo.prlngdate) = month(g-today) and day(depo.prlngdate) > day(g-today)) then do:
    depo.lev = string(decimal(depo.lev) + s-amt1).
                           put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip. end. else

                        if (string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and month(depo.dt2) = month(g-today) and day(depo.dt2) > day(g-today)) then do:
    depo.pr = string(decimal(depo.pr) + s-amt1).
                           put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.dt1) " по " string(depo.dt2) skip.
                        end.
                        run trxsts(v-jh, 6, output rcode, output rdes).
                     end.
                  end.
               end.
               else
/* за месяц например с 20.05.05 по 20.08.05 списываем с 01.06.06. по 31.06.06 */
do:
    /* основной */
    if (string(depo.lstdt) <> ? and depo.lstdt < g-today and month(depo.lstdt) <> month(g-today) and depo.prlngdate > g-today and month(depo.prlngdat) <> month(g-today)  ) then do:
        if depo.prlngdate - depo.lstdt <= 0 then s-amt1 = 0. else
           s-amt1 = round((decimal(depo.sum) / (depo.prlngdate - depo.lstdt)) * GetDay(g-today), 2).
           if s-amt1 > 0 then do:

if abs(s-amt - s-amt1) = 0.01 or abs(s-amt - s-amt1) = 0.02 or abs(s-amt - s-amt1) = 0.03 then do:
   s-amt1 = s-amt.
end.

              v-jh = 0.                                            
              vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + "01/" + string(month(g-today),"99") + "/" + string(year(g-today)) + " по " + string(GetLastNum(g-today)) + vdel + "".
              run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
              if rcode ne 0 then do:
                 put stream m-out unformatted "-5Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
              end.
              else do:

                 depo.lev = string(decimal(depo.lev) + s-amt1).
                 put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) + " по " + string(GetLastNum(g-today)) skip.
                 run trxsts(v-jh, 6, output rcode, output rdes).
              end.
           end.
    end.
    else
    /* льготный */
    if (string(depo.dt1) <> ? and depo.dt1 < g-today and month(depo.dt1) <> month(g-today) and 
       depo.dt2 > g-today and month(depo.dt2) <> month(g-today)) then do:

        if depo.dt2 - depo.dt1 <= 0 then s-amt1 = 0. else
           s-amt1 = round((decimal(depo.prim1) / (depo.dt2 - depo.dt1)) * GetDay(g-today), 2).

           if s-amt1 > 0 then do:
              v-jh = 0.
              vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + "01/" + string(month(g-today),"99") + "/" + string(year(g-today)) + " по " + string(GetLastNum(g-today)) + vdel + "".
              run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
              if rcode ne 0 then do:
                 put stream m-out unformatted "-6Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
              end.
              else do:
 depo.pr = string(decimal(depo.pr) + s-amt1).
                 put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.dt1) + " по " + string(GetLastNum(g-today)) skip.
                 run trxsts(v-jh, 6, output rcode, output rdes).
              end.
           end.
    end.
end. /* за месяц например с 20.05.05 по 20.08.05 списываем с 01.06.06. по 31.06.06 */

               end. /* if avail depo */

            end. /* если послед. день месяца. */
            else


/* ЕСЛИ НЕ ПОСЛЕДНИЙ ДЕНЬ МЕСЯЦА. ЕСЛИ НЕ ПОСЛЕДНИЙ ДЕНЬ МЕСЯЦА. */
            do:
/* СПИСАНИЕ с 05 по 12 */
            find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
                ((depo.lstdt <> ? and month(depo.lstdt) = month(g-today) and year(depo.lstdt) = year(g-today) and depo.prlngdate - 1 >= g-today and depo.prlngdate - 1 < s-target) or
                (string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and year(depo.dt1) = year(g-today) and depo.dt2 - 1 >= g-today and depo.dt2 - 1 < s-target)) exclusive-lock no-error.
                if avail depo then do:

  /* списание за неполный месяц с 05 по 12 основной */
                   if string(depo.lstdt) <> ? and month(depo.lstdt) = month(g-today) and depo.prlngdate - 1 >= g-today and depo.prlngdate - 1 < s-target then do:
                      s-amt1 = depo.sum.
                      v-jh = 0.
                      vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.lstdt) + " по " + string(depo.prlngdate) + vdel + "".
                      run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      if rcode ne 0 then do:
                         put stream m-out unformatted "-7Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                      end.
                      else do:
                         depo.lev = string(decimal(depo.lev) + s-amt1).
                         put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                         run trxsts(v-jh, 6, output rcode, output rdes).
                      end.
                   end.
                   else
 /* списание за неполный месяц с 05 по 12 льготный */
                   if string(depo.dt1) <> ? and month(depo.dt1) = month(g-today) and depo.dt2 - 1 >= g-today and depo.dt2 - 1 < s-target then do:
                     s-amt1 = decimal(depo.prim1).
                      v-jh = 0.
                      if s-amt1 <> 0 then do:
                         vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.dt1) + " по " + string(depo.dt2) + vdel + "".
                         run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                         if rcode ne 0 then do:
                            put stream m-out unformatted "-8Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                         end.
                         else do:
                            depo.pr = string( decimal(depo.pr) + s-amt1).
                            put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                            run trxsts(v-jh, 6, output rcode, output rdes).
                         end.
                      end.
                   end.
                 end.

/* СПИСАНИЕ с 12 по 12 */
            find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
                ((depo.lstdt <> ? and 
((month(depo.lstdt) <> month(g-today)) or (month(depo.lstdt) = month(g-today) and year(depo.lstdt) <> year(g-today)))
and depo.prlngdate - 1 >= g-today and depo.prlngdate - 1 < s-target) or (depo.dt1 <> ? and
((month(depo.dt1) <> month(g-today)) or (month(depo.dt1) = month(g-today) and year(depo.dt1) <> year(g-today)))
and depo.dt2 - 1 >= g-today and depo.dt2 - 1 < s-target)) exclusive-lock no-error.

                if avail depo then do:

                   /* с 31 по 12 основной */
                   if depo.lstdt <> ? and ((month(depo.lstdt) <> month(g-today)) or (month(depo.lstdt) = month(g-today) and year(depo.lstdt) <> year(g-today))) and depo.prlngdate - 1 >= g-today and depo.prlngdate - 1 < s-target then do:
                      s-amt1 = round((depo.prlngdate - date("01." + string(month(depo.prlngdate)) + "." + string(year(depo.prlngdate)))) * (depo.sum / (depo.prlngdate - depo.lstdt)), 2).


                      if (abs((depo.sum - decimal(depo.lev)) - s-amt1)) >= 0 and (abs((depo.sum - decimal(depo.lev)) - s-amt1)) <= 0.08 then
                         s-amt1 = depo.sum - decimal(depo.lev).
                      else
                         s-amt1 = 0.
                      v-jh = 0.
        if s-amt1 > 0 then do:
                      vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + "01/" + string(month(g-today),"99") + "/" + string(year(g-today)) + " по " + string(depo.prlngdate) + vdel + "".
                      run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      if rcode ne 0 then do:
                         put stream m-out unformatted "-9Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                      end.
                      else do:
                         depo.lev = string(decimal(depo.lev) + s-amt1).
                         put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " "01/" + string(month(g-today),"99") + "/" + string(year(g-today)) " по " string(depo.prlngdate) skip.
                         run trxsts(v-jh, 6, output rcode, output rdes).
                      end.
         end.

                   end.


                   /* с 31 по 12 льготный */
                   if depo.dt1 <> ? and ((month(depo.dt1) <> month(g-today)) or (month(depo.dt1) = month(g-today) and year(depo.dt1) <> year(g-today)))
                      and depo.dt2 - 1 >= g-today and depo.dt2 - 1 < s-target then do:
                      s-amt1 = round((depo.dt2 - date("01." + string(month(depo.dt2)) + "." + string(year(depo.dt2)))) * (decimal(depo.prim1) / (depo.dt2 - depo.dt1)), 2).
                      if (abs((decimal(depo.prim1) - decimal(depo.pr)) - s-amt1)) >= 0 and (abs((decimal(depo.prim1) - decimal(depo.pr)) - s-amt1)) <= 0.07 then
                         s-amt1 = decimal(depo.prim1) - decimal(depo.pr).
                      else
                         s-amt1 = 0.
                      v-jh = 0.
                      vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + "01/" + string(month(g-today)) + "/" + string(year(g-today)) + " по " + string(depo.dt2) + vdel + "".
                      run trxgen ("uni0165", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      if rcode ne 0 then do:
                         put stream m-out unformatted "-10Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                      end.
                      else do:
                         depo.pr = string(decimal(depo.pr) + s-amt1).
                         put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                         run trxsts(v-jh, 6, output rcode, output rdes).
                      end.
                   end.
               end.  
            end.
                  



/* КОРРЕКТИРОВКА ДОЛГА */
    find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 10 no-lock no-error.
    find last crc where crc.crc = aaa.crc no-lock no-error.
    if available trxbal then do:
       s-amt10 = truncate(abs(trxbal.dam - trxbal.cam) / crc.rate[1], 2).
       if s-amt10 > 0 then do: /* на 10 есть деньги если нет долгов то списываем */

/*  find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
  ((depo.prlngdate >= g-today and depo.prlngdate < s-target) or 
   (depo.dt2 >= g-today and depo.dt2 < s-target)) exclusive-lock no-error. */
    find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
  ((depo.lstdt <= g-today and depo.prlngdate >= g-today and depo.prlngdate >= s-target) or 
   (depo.dt1 <= g-today and depo.dt2 >= g-today and depo.dt2 >= s-target )) exclusive-lock no-error.
          if avail depo then do:
                v-jh = 0.
                vparam = string(s-amt10) + vdel + aaa.aaa + vdel + "Корректировка долга за аренду ячейки " .
                run trxgen ("uni0187", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                if rcode ne 0 then
                   put stream m-out unformatted "-Ошибка корректировки долга " aaa.aaa ", " string(s-amt10) " -> " rdes skip.
                else
                   put stream m-out unformatted "+Успешно корректировка долга " aaa.aaa ", " string(s-amt10) skip.
          end.
       end.
    end. /* Списание долга */





    find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 1 no-lock no-error.
    if (avail trxbal and trxbal.cam - trxbal.dam = 0) or not avail trxbal then do:
        find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 13 no-lock no-error.
        if (avail trxbal and trxbal.cam - trxbal.dam = 0) or not avail trxbal  then do:
           find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 10 no-lock no-error.
             if (avail trxbal and trxbal.cam - trxbal.dam = 0) or not avail trxbal then do:
                 aaa.sta = "C".
 for each cellx where cellx.aaa = aaa.aaa exclusive-lock :
    if avail cellx then do:
       cellx.name = "".
       cellx.aaa = "".
       cellx.sts = "Свободна".
    end.
 end.
                 next.
             end.
           end.
     end.
         





/* НАЧИСЛЕНИЕ ДОЛГА */                                  
/* Если нет периода перекрывающего долг тогда */
    dd1 = ?. dd2 = ?.
/*  find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and depo.lstdt <= g-today and ((depo.prlngdate >= s-target) or (depo.dt2 >= s-target and depo.dt1 <= g-today)) exclusive-lock no-error. */

find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and ((depo.prlngdate >= s-target) or (depo.dt2 >= s-target)) exclusive-lock no-error.
if not avail depo then do:


    find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and 
  ((depo.lstdt <= g-today and depo.prlngdate > g-today and depo.prlngdate >= s-target - 1 ) or 
   (depo.dt1 <= g-today and depo.dt2 > g-today and depo.dt2 >= s-target - 1 )) exclusive-lock no-error.
    if not avail depo then do:

       depdpr = ?. depd2 = ?. dsd0 = ?. dsd = ?.
       for each depo where depo.aaa = aaa.aaa and depo.prim2 <> "del"  and depo.prlngdate <= s-target no-lock break by depo.prlngdate:
           depdpr = depo.prlngdate.
       end.
       for each depo where depo.aaa = aaa.aaa and depo.prim2 <> "del"  and depo.dt2 <= s-target no-lock break by depo.dt2 :
           depd2 = depo.dt2.
       end.
       if depdpr <> ? and depd2 <> ? then do:
          if depdpr > depd2 then do:
             dsd = depdpr.
             find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del"  and depo.prlngdate = depdpr no-lock no-error.
             dsd0 = depo.prlngdate.
          end.
          if depdpr < depd2 then do:
             dsd = depd2.
             find last depo where depo.prim2 <> "del" and depo.aaa = aaa.aaa and depo.dt2 = depd2 no-lock no-error.
             dsd0 = depo.dt2.

          end.
          if depdpr = depd2 then do:
             dsd = depd2.
             find last depo where depo.prim2 <> "del" and depo.aaa = aaa.aaa and depo.dt2 = depd2 no-lock no-error.
             dsd0 = depo.dt2.
          end.
       end.
       else 
          if depdpr <> ? then do:
             dsd = depdpr.
             find last depo where depo.prim2 <> "del" and depo.aaa = aaa.aaa and depo.prlngdate = depdpr no-lock no-error.
             dsd0 = depo.prlngdate.
          end.
       else
          if depd2 <> ? then do:
             dsd = depd2.
             find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and  depo.dt2 = depd2 no-lock no-error.
             dsd0 = depo.dt2.
          end.

/*       if avail depo then do:*/
         if dsd0 <> ? then do:

          iiday =  0. iimonth = 0. iiyear = 0. dsum = 0. 
          run DayCount(dsd0, s-target, output iiyear, output iimonth, output iiday).

     {depo.i}

          find trxbal where trxbal.sub = 'cif' and  trxbal.acc = aaa.aaa and trxbal.level = 10 no-lock no-error.
          find last crc where crc.crc = aaa.crc no-lock no-error.
          if available trxbal then do:
             s-amt = truncate(abs(trxbal.dam - trxbal.cam) / crc.rate[1], 2).
          end.
          else s-amt = 0.

          if s-amt > dsum then do: s-amt = s-amt - dsum. dsum  = 0. end. else
          if s-amt < dsum then do: dsum = dsum -  s-amt. s-amt = 0. end. else
          if s-amt = dsum then do: dsum = 0. s-amt = 0. end.
          /* Начисление долга */

          if dsum > 0 then do:
             v-jh = 0.
             vparam = string(dsum) + vdel + aaa.aaa + vdel + "Долг за аренду ячейки с " + string(dsd0) + " по " + string(s-target).
             run trxgen ("uni0186", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then
                put stream m-out unformatted "-Ошибка начисления долга " aaa.aaa ", " string(dsum) " -> " rdes skip.
             else
                put stream m-out unformatted "+Успешно начислен долг   " aaa.aaa ", " string(dsum) " c " string(dsd0) " по " string(s-target) skip.
          end.

          /* Сторно долга */
          if s-amt > 0 then do:
             v-jh = 0.
             vparam = string(s-amt) + vdel + aaa.aaa + vdel + "Корректировка долга за аренду ячейки с " + string(dsd0) + " по " + string(s-target).
             run trxgen ("uni0187", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
             if rcode ne 0 then
                put stream m-out unformatted "-Ошибка корректировки долга " aaa.aaa ", " string(s-amt) " -> " rdes skip.
             else
                put stream m-out unformatted "+Успешно корректировка долга " aaa.aaa ", " string(s-amt) " c " string(dsd0) " по " string(s-target) skip.
          end.
       end. 
     end. /* начисление долга */
end.

 s-jh = v-jh.

 {upd-dep.i}

    end.  /* for each aaa */
    output stream m-out close.
    unix silent mv acccell.txt value(fname1).













Procedure DayCount. /*возвращает количество дней за целое число месяцев*/
def input parameter a_start  as date.
def input parameter a_expire as date.
def output parameter iiyear  as integer .
def output parameter iimonth as integer .
def output parameter iiday   as integer .

def var vterm as inte.
def var e_refdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.
def var i as inte initial 0.

def var e_fire as logical init False.
def var t-days as date.
def var e_date as date.
iiday = 0. iiyear = 0. iimonth = 0.

e_refdate = a_start.

if a_start = a_expire then do: return. end.

do e_date = a_start to a_expire:     
   iiday = iiday + 1.

   if day(e_refdate) = 31 then do:
      if (day(e_date) = 30 and month(e_date) = 4) or
         (day(e_date) = 30 and month(e_date) = 6) or
         (day(e_date) = 30 and month(e_date) = 9) or
         (day(e_date) = 30 and month(e_date) = 11) then do:
      iimonth = iimonth + 1.
      iiday = 0.
      end.
   end.

   if day(e_date) = day(e_refdate) and e_date <> a_start then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   /* февраль высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) = 0) and ( day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 29) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.
   /* февраль не высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) <> 0) and ( day(e_refdate) = 29 or day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 28) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   
   if iimonth = 12 then do:
      iiyear = iiyear + 1.
      iimonth = 0.
      iiday = 0.
   end.
end.
    if iimonth = 0 and iiyear = 0 then iiday = iiday - 1. 
    if iiday < 0 then iiday = 0.

End procedure.



