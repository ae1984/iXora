/* dcls22.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Начисление процентов по текущим счетам клиентов (юридических лиц)
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
        11.11.2004 dpuchkov
 * CHANGES
        22.11.2004 dpuchkov база начисления % берётся из aaa.base (aaa.base проставляет бухгалтерия)
        19.04.2005 nataly добавлено автоматическое проставление кодов расходов/доходов {cods.i}
        29/09/2005 nataly проставление кодов ГК + кода департамента в таблице accr
        28.04.2006 dpuchkov добавил перечисление процентов на другой счет ТЗ-273
        17.05.2006 dpuchkov закомментировал удержание 15% налога(сл записка ї347 от 17.05.2006)
        05.10.2006 nataly добавила getdep.i
        07.03.2007 id00004 добавил проверку при создании jh
        21.11.2012 evseev - ТЗ-1374
*/

{global.i}
{getdep.i}
{convgl.i "bank"}

  define shared var s-target as date.
  define shared var s-bday as log  init true.
  define shared var s-intday as int.
                                /*19.04.2005 nataly*/
define var v-code as char.
define var v-dep as char format 'x(5)'.
def buffer bgl for gl.            /*19.04.2005 nataly*/

def var v-sum like glbal.bal.
def var fname1 as char.
define var v-accrued as dec decimals 2 .
def var v-intday1 as inte.
def var v-intrat1 like aaa.rate.
def var v-base1 like jl.dam.
def var ev-date as date.
def var e-fire as logi.
def var v-jh as inte.
define var vm10 as dec decimals 10 .
def var vparam as char.
def var vdel as char initial "^".
def var rcode as inte.
def var rdes as char.
def var v-pay as deci.
def var v-text as cha .
define var vln as int initial 1.
def var vm-conv1 as dec decimals 2 .
define new shared var s-jh  like jh.jh.
define var vnewint as dec decimals 2.
define var voldint as dec decimals 2.
define var vtotaipc as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vtotaip as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vm-conv as dec decimals 2 .
define var vcnt as int.
def buffer trxlevgl11 for trxlevgl .

define buffer dayacr for sysc.
def buffer blgr for lgr.

fname1 = "acrall" + substring(string(g-today),1,2) +
      substring(string(g-today),4,2) + ".txt".

def stream m-out.
output stream m-out to acrall.txt.

def stream m-err.
output stream m-err to acrall.err.




find dayacr where dayacr.sysc eq "dayaca".
if dayacr.loval eq true then do transaction:
    run x-jhnew.
    find jh where jh.jh = s-jh.
    jh.party = "ACCRUED INTEREST TRANSACTION..".
    jh.crc = 0.
    if not s-bday then jh.jdt = s-target.
    display stream m-out jh.jh.
end.


Function EventInRange returns date (input event as char,
                                    input vdat1 as date,
                                    input vdat2 as date).
  def var curdate as date.
  curdate = vdat1.
  repeat:
    run EventHandler(event, curdate, aaa.dtbeg, aaa.dtend - 1, output e-fire).
    if e-fire then do:
       return curdate.
    end.
    curdate = curdate + 1.
    if curdate > vdat2 then return ?.
  end.
End Function.

Function EventInRange1 returns date (input event as char,
                                    input vdat1 as date,
                                    input vdat2 as date).
  def var curdate as date.
  curdate = vdat1.
  repeat:
    run EventHandler(event, curdate, aaa.dtbeg, aaa.dtpay - 1, output e-fire).
    if e-fire then do:
       return curdate.
    end.
    curdate = curdate + 1.
    if curdate > vdat2 then return ?.
  end.
End Function.



for each lgr where lgr.lgr = "151" or lgr.lgr = "153" or lgr.lgr = "155" or lgr.lgr = "157" or lgr.lgr = "171" no-lock:
    vcnt = 0.
    vtotaip = 0.
    vtotaipc = 0 .
  /*только по текущим счетам клиентов*/
 account:
  for each aaa where aaa.calc = true and aaa.lgr = lgr.lgr by aaa.crc:
      voldint = aaa.accrued.
      vm-conv   = 0.
      vm-conv1  = 0.
      v-accrued = 0.

      if (aaa.regdt > g-today) or
           (lookup (aaa.sta, "C,T,S") > 0) then next account.
      find last cif where cif.cif = aaa.cif no-lock no-error.
      if avail cif and cif.type <> "b" then next account.

      if  (aaa.cr[1] - aaa.dr[1]) > 0 and (aaa.cr[1] - aaa.dr[1]) > aaa.stsum and aaa.dtbeg <= g-today and dtend > g-today then
      do:
           if  aaa.dtend < s-target and aaa.dtend > g-today then do:
               run CalcInterests(dtend - g-today, aaa.rate1, aaa.cr[1] - aaa.dr[1]).
           end.
           else
           do:
               run CalcInterests(s-intday, aaa.rate1, aaa.cr[1] - aaa.dr[1]).
           end.

      end.

      ev-date = ?.
      ev-date = EventInRange1("F", g-today, s-target - 1).
      if ev-date <> ? then do:
         /*выплата вознаграждения на счет*/
         run PayInterests.
      end.
      else
      do:
             ev-date = ?.
             ev-date = EventInRange("M", g-today, s-target - 1).
             if ev-date <> ? then do:
                run PayInterests.
             end.
      end.
      vnewint = aaa.accrued.
      vtotaip = vtotaip + vnewint - voldint.
      vtotaipc = vtotaipc + vm-conv.
      vcnt = vcnt + 1.
  end. /* for aaa */


  if dayacr.loval eq true then do:
  if vtotaip > 0 then do transaction:

      find first trxlevgl where  trxlevgl.gl = lgr.gl and
               trxlevgl.sub = "cif" and trxlevgl.lev = 2 no-lock no-error.
      find first trxlevgl11 where  trxlevgl11.gl = lgr.gl and
               trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error.
      if not avail trxlevgl or not avail trxlevgl11 then do:
        v-text = " Нет настройки уровней Г/К для " + lgr.lgr + " группы "
               + " Г/К = " + string(lgr.gl).
        Message v-text.
        put stream m-out unformatted v-text.
        pause.
        return.
      end.
      find jh where jh.jh = s-jh.
      create jl.
      assign jl.jh =  jh.jh
             jl.ln =  vln
             jl.who = jh.who
             jl.jdt = jh.jdt
             jl.whn = jh.whn
             jl.cam = vtotaip
             jl.dc =  "C"
             jl.gl =  trxlevgl.glr
             jl.lev = trxlevgl.lev
             jl.crc = lgr.crc
             jl.acc = ""
             jl.rem[1] = "TOTAL " + string(vcnt) + " ACCOUNTS " + lgr.lgr.
            {cods.i}                                   /*19.04.2005 nataly*/
      vln = vln + 1.
  if lgr.crc ne  1 then do:
 /*find first sysc where sysc.sysc = "buygl"  no-lock .*/
     create jl.
     assign jl.jh =  jh.jh
            jl.ln =  vln
            jl.who = jh.who
            jl.jdt = jh.jdt
            jl.whn = jh.whn
            jl.dam = vtotaip
            jl.dc =  "D"
            jl.gl =  /*sysc.inval*/ getConvGL(lgr.crc,"D")
            jl.lev = 1
            jl.crc = lgr.crc
            jl.acc = ""
            jl.rem[1] = "TOTAL " + string(vcnt) + " ACCOUNTS " + lgr.lgr.
            {cods.i}                                     /*19.04.2005 nataly*/
     vln = vln + 1.

  /*find first sysc where sysc.sysc = "selgl"  no-lock .*/
     create jl.
      assign jl.jh =  jh.jh
             jl.ln =  vln
             jl.who = jh.who
             jl.jdt = jh.jdt
             jl.whn = jh.whn
             jl.cam = vtotaipc
             jl.dc =  "C"
             jl.gl =  /*sysc.inval*/ getConvGL(1,"C")
             jl.lev = 1
             jl.crc = 1
             jl.acc = ""
             jl.rem[1] = "TOTAL " + string(vcnt) + " ACCOUNTS " + lgr.lgr.
            {cods.i}                                     /*19.04.2005 nataly*/
      vln = vln + 1.
     end.
      create jl.
      assign jl.jh =  jh.jh
             jl.ln =  vln
             jl.who = jh.who
             jl.jdt = jh.jdt
             jl.whn = jh.whn
             jl.dam = vtotaipc
             jl.dc =  "D"
             jl.gl =  trxlevgl11.glr
             jl.lev = trxlevgl11.lev
             jl.crc = 1
             jl.acc = ""
             jl.rem = lgr.lgr.                         /*19.04.2005 nataly*/
            {cods.i}
      vln = vln + 1.
      find crc where crc.crc eq lgr.crc no-lock no-error.
      v-sum = vtotaipc .
      accumulate v-sum (total).
      display stream m-out lgr.lgr crc.code vtotaip v-sum with no-label.

    end.  /* if vtotaip > 0 */
   end. /* if dayacr.loval = true */
end. /*for each lgr*/


display stream m-out  fill("-",70) format "x(70)" skip
accum total v-sum at 29 format ">>>,>>>,>>>,>>>,>>9.99-"
with no-label frame a.
output stream m-out close.
unix silent mv acrall.txt value(fname1).

output stream m-err close.


Procedure CalcInterests.
  def input parameter ss-intday as inte.
  def input parameter ss-intrat like aaa.rate.
  def input parameter ss-base like jl.dam.
  def var v-sum as decimal.

  v-jh = 0.
  vm10 = ((ss-base * ss-intrat * ss-intday) / (aaa.base * 100)).
  /* Начисление процентов */
  v-accrued = vm10.
  vparam = string(vm10) + vdel + aaa.aaa.
  aaa.accrued = aaa.accrued + v-accrued.

  find last crc where crc.crc = aaa.crc no-lock no-error.
  {trxbal-aaa.i}
  if v-accrued > 0  then do:
  find last accr where accr.aaa eq aaa.aaa no-error.
  if available accr then do:
   if  (
    /* (accr.bal ne ss-base or
         accr.accrued <> v-accrued or accr.rate <> ss-intrat)   and*/
    accr.fdt <> g-today)
    then do:
      create accr.
          {accr.i} /*28/09/05 nataly*/
      assign accr.aaa = aaa.aaa
             accr.fdt = g-today
             accr.bal = ss-base
             accr.rate = ss-intrat
             accr.accrued = v-accrued.
    end.
  else  if (accr.fdt = g-today)
    then do:
      assign accr.bal = ss-base
             accr.rate = ss-intrat
             accr.accrued = accr.accrued + v-accrued.
    end.
  end. /*if available accr*/
 if not available accr then do:
      create accr.
           {accr.i} /*28/09/05 nataly*/
      assign accr.aaa = aaa.aaa
             accr.fdt = g-today
             accr.bal = ss-base
             accr.rate = ss-intrat
             accr.accrued = v-accrued.
  end.
 end. /*if v-accred > 0 */
End procedure.


Procedure PayInterests.
  def var d_sum as decimal.
  def var d_tax as decimal.
  v-pay =  aaa.cr[2] - aaa.dr[2].
  find last pipl where pipl.stats = aaa.aaa exclusive-lock no-error.
  if (not avail pipl) or (avail pipl and pipl.name = "")  then do:
     d_tax =  ((aaa.cr[2] - aaa.dr[2]) * 15) / 100.
     if v-pay > 0 then do:
        vparam = string(v-pay) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999").
        run trxgen("DCL0005", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
        if rcode = 0 then do:
           run trxsts(v-jh, 6, output rcode, output rdes).
           if rcode ne 0 then do:
              put stream m-err unformatted
               "Не удалось отштамповать проводку выплаты накопленных % : "
               aaa.aaa ", " string(v-pay) " -> " rdes skip.
           end.
        end.
        else
        do:
          put stream m-err unformatted "Не удалось сформировать проводку выплаты накопленных % : " aaa.aaa ", " string(v-pay) " -> " rdes skip.
        end.
     end.
     /* Подоходный налог */
      v-pay = d_tax.
/*   if v-pay > 0 then do:
        vparam = string(v-pay) + vdel + aaa.aaa + vdel + string("Удержание 15% налога") + vdel + "".
        v-jh = 0.
        run trxgen("vnb0024", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
        if rcode <> 0 then do:
          put stream m-err unformatted
              "Не удалось сформировать проводку по удержанию 15% налога: "
              aaa.aaa ", " string(v-pay) " -> " rdes skip.
        end.
     end. */



  end.
  else do:

    if pipl.name <> "" then do:
       vparam = string(v-pay) + vdel + "2" + vdel + aaa.aaa + vdel + "1" + vdel + pipl.name + vdel + "Перевод процентов".
       run trxgen("vnb0069", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
       if rcode = 0 then do:
          run trxsts(v-jh, 6, output rcode, output rdes).
       end.
    end.
  end.

end procedure.



Procedure EventHandler.
def input  parameter e_period as char.
def input  parameter e_date   as date.
def input  parameter a_start  as date.
def input  parameter a_expire as date.
def output parameter e_fire   as logi.

def var vterm as inte.
def var i as inte.
def var e_refdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.

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
       days = day(t_date).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).

       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
         if month(t_date) <> month(t_date + 1) then do:
           months = months + 1.
           if months = 13 then do:
              months = 1.
              years = years + 1.
           end.
           days = 1.
         end.
         if months = 2 and days = 30 then do: months = 2. days = 29. end.
         if months = 2 and days = 29
          and  (( (year(t_date) + years) - 2000) modulo 4) <> 0 then do:
         months = 3.  days = 1.  end.
         if i = 1 then e_refdate = date(months, days, year(t_date) + years) - 1.
                 else e_refdate = date(months, days, year(t_date) + years) .
         if month(t_date) <> month(t_date + 1) then e_refdate = e_refdate - 1.
         if e_refdate > e_date then return.
         else if e_refdate > a_expire then return.
         if e_date = e_refdate then do:
            e_fire = true.
            return.
         end.
       t_date = e_refdate.
        i = i + 1.
     end. /* repeat */
end.
else if e_period = "D" then e_fire = true.
End procedure.
