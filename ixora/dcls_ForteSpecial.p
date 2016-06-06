/* dcls_ForteSpecial.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Начисление процентов по депозитам.
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        27.06.2013 evseev tz-1909
 * BASES
        BANK COMM
 * CHANGES
*/


{global.i}
{getdep.i}
{dclstda.i}
{convgl.i "bank"}
{chbin.i}

def var vm-conv1 as dec decimals 2 .
def buffer blgr for lgr.
define var v-dep as char format 'x(5)'.
define var v-code as char.

define buffer dayacr for sysc.
def buffer b-jh for jh.
def var vm-conv as dec decimals 2 .
define shared var s-target as date.
define shared var s-bday as log .
define shared var s-intday as int.
def var v-text as cha .
define new shared var s-jh  like jh.jh.
define var intrat like pri.rate.
define var voldint as dec decimals 2.
define var vnewint as dec decimals 2.
define var vtotaip as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vtotaipc as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vln as int initial 1.
define var vcnt as int.
define var vbal like jl.dam label "BALANCE ".
define var v-accrued as dec decimals 2 .
define var vm10 as dec decimals 10 .
define variable v-m10 like aaa.m10.
def var ev-date as date.
def var uv-date as date.
def var DoPay  as logi.
def var DoUpr  as logi.
def var v-intday1 as integer.
def var v-intday2 as integer.
def buffer bnlg-sysc for sysc.
def var v-nlg as char.
def var v-sum like glbal.bal.
def buffer trxlevgl11 for trxlevgl .
def stream m-out.
def var fname1 as char.
def var vparam as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".
def var v-jh as inte.
def var v-pay as deci.
def var n-intday as integer.
def var v-diffsum as deci.
def var v-flag as logical init false.
run savelog('dcls_ForteSpecial','74').
for each aaa where lookup(aaa.lgr,"151,152,153,154,171,172,157,158,176,177,173,175,174") > 0 no-lock:
   find last acvolt where acvolt.aaa = aaa.aaa and acvolt.x7 <> 100 no-lock no-error.
   if avail acvolt then do:
      v-flag = true.
      leave.
   end.
end.
if v-flag = false then return.
fname1 = 'ForteSpecial_' + substring(string(g-today),1,2) + substring(string(g-today),4,2) + '.txt'.
output stream m-out to ForteSpecial.txt.
find dayacr where dayacr.sysc eq "dayaca".


if dayacr.loval eq true then do transaction:
    run x-jhnew.
    find jh where jh.jh = s-jh.
    jh.party = "ACCRUED INTEREST TRANSACTION".
    jh.crc = 0.
    if not s-bday then jh.jdt = s-target.
    display stream m-out jh.jh.
end.


run savelog('dcls_ForteSpecial','89').
for each lgr /*where lgr.intcal = "D" use-index intcal*/:
    if lookup(lgr.lgr,"151,152,153,154,171,172,157,158,176,177,173,175,174") = 0 then next.
    vcnt = 0. vtotaip = 0. vtotaipc = 0.
    run savelog('dcls_ForteSpecial','93. ' + lgr.lgr).
    c-aaa:
    for each aaa where aaa.lgr = lgr.lgr  break by aaa.crc:
        run savelog('dcls_ForteSpecial','96. ' + aaa.aaa).
        if lookup(aaa.sta,'c,e,C,E') > 0 then next.
        find last acvolt where acvolt.aaa = aaa.aaa and acvolt.x7 <> 100 exclusive-lock no-error.
        if not avail acvolt then  next .
        if acvolt.x1 = "" then next.
        if acvolt.x3 = "" then next.
        if acvolt.x7 = 4  then next. /* 3 пролонгации дальнейшее начисление запрещено */
        if aaa.rate = 0 then next.
        if date(acvolt.x3) <= g-today then next.
        if (aaa.cr[1] - aaa.dr[1]) = 0 or (aaa.regdt > g-today) or (lookup(aaa.sta, "C,T,S") > 0) then next c-aaa.
        if string(aaa.lstmdt) = ? then next.

        /*find first jl where jl.acc = aaa.aaa and jl.cam > 0 no-lock no-error.
        if not avail jl then next.*/

        run savelog('dcls_ForteSpecial','109. ' + aaa.aaa).
        /*if aaa.regdt = g-today then do:
           aaa.opnamt = (aaa.cr[1] - aaa.dr[1]) .
        end.
        if aaa.opnamt > (aaa.cr[1] - aaa.dr[1]) then do:
           aaa.opnamt = aaa.cr[1] - aaa.dr[1].
        end.*/
        DoPay = false.
        DoUpr  = false.
        /*if lgr.intcal = "D" then do: ежедневное начисление*/
           DoPay = false.
           DoUpr = false.
           uv-date = ?.
           uv-date = EventInRange(/*lgr.intcal*/ "D", g-today, s-target - 1). /*Вычисляем количество начисленных процентов  */
           if uv-date <> ? then do:
              DoUpr = true. /*Вычисляем количество начисленных процентов */
           end.
           ev-date = ?.
           ev-date = EventInRange(/*lgr.intpay*/ "F" , g-today, s-target - 1).
           if ev-date <> ? then do:
               DoPay = true. /*Выплата процентов на первый уровень */
           end.
        /*end.*/
        n-intday = s-intday.
        find last crc where crc.crc = aaa.crc no-lock no-error.
        if not avail crc then do:
           run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dcls_ForteSpecial",
                   aaa.aaa + " не найдена запись в crc [1] ", "1", "", "").
           next.
        end.

        vm-conv  = 0. /* сумма 11 ур по одному счету по всем проводкам     */
        v-accrued = 0. /*!!!!!!!!!*/
        voldint = aaa.accrued.
        intrat = aaa.rate.

        vbal = IntBase().



        run savelog('dcls_ForteSpecial','161. ' + aaa.aaa).
        if DoPay then do:
           if ev-date <> ? then do:
              v-intday1 = ev-date - g-today + 1.
              v-intday2 = s-intday - v-intday1.

              v-m10 = vbal * aaa.rate * v-intday1 / (aaa.base * 100).
              run savelog('dcls_ForteSpecial','168. ' + aaa.aaa).
              create accr-m10.
              assign
                  accr-m10.aaa     = aaa.aaa
                  accr-m10.rate    = aaa.rate
                  accr-m10.fdt     = g-today
                  accr-m10.base    = vbal
                  accr-m10.aaam10  = aaa.m10
                  accr-m10.m10     = v-m10
                  accr-m10.intday  = v-intday1.

              vm10  = vbal * aaa.rate * v-intday1 / (aaa.base * 100) + aaa.m10.
              if vm10 gt 0 then do:
                 v-accrued = vm10.
                 aaa.accrued = aaa.accrued + v-accrued.
                 aaa.m10 = vm10 - v-accrued.
                 {trxbal-aaa.i}
              end. else
                do:
                    aaa.m10 = aaa.m10 + v-m10.
                end.
              run PayInterests.
              acvolt.x7 = 100.
              run tdaremholda(aaa.aaa).
              run savelog('dcls_ForteSpecial','185. ' + aaa.aaa + ' ' + string(ev-date)).
              run savelog('dcls_ForteSpecial','186. ' + aaa.aaa + ' ' + string(aaa.expdt)).
           end.
        end. /*DoPay*/
        else do:
             if DoUpr then do:
                if uv-date <> ? then do:
                   v-intday1 = uv-date - g-today + 1.
                   v-intday2 = s-intday - v-intday1.
                   v-m10 =  vbal * aaa.rate * v-intday1 / (aaa.base * 100).
                   run savelog('dcls_ForteSpecial','206. ' + aaa.aaa).
                   create accr-m10.
                   assign
                       accr-m10.aaa     = aaa.aaa
                       accr-m10.rate    = aaa.rate
                       accr-m10.fdt     = g-today
                       accr-m10.base    = vbal
                       accr-m10.aaam10  = aaa.m10
                       accr-m10.m10     = v-m10
                       accr-m10.intday  = v-intday1.

                   vm10  = vbal * aaa.rate * v-intday1 / (aaa.base * 100) + aaa.m10.
                   if vm10 gt 0 then do:
                      v-accrued = vm10.
                      aaa.accrued = aaa.accrued + v-accrued.
                      aaa.m10 = vm10 - v-accrued.
                      {trxbal-aaa.i}
                   end. else
                   do:
                       aaa.m10 = aaa.m10 + v-m10.
                   end.
                   find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                   if avail acvolt then do:
                      acvolt.prim1 = string(aaa.accrued).
                   end.

                   if v-intday2 > 0 then do:

                      v-m10 =  v-intday2 * vbal * aaa.rate / (aaa.base * 100).
                      run savelog('dcls_ForteSpecial','235. ' + aaa.aaa).
                      create accr-m10.
                      assign
                          accr-m10.aaa     = aaa.aaa
                          accr-m10.rate    = aaa.rate
                          accr-m10.fdt     = g-today
                          accr-m10.base    = vbal
                          accr-m10.aaam10  = aaa.m10
                          accr-m10.m10     = v-m10
                          accr-m10.intday  = v-intday2.

                      vm10 = v-intday2 * vbal * aaa.rate / (aaa.base * 100) + aaa.m10.
                      if vm10 gt 0 then do:
                         v-accrued = vm10.
                         aaa.accrued = aaa.accrued + v-accrued.
                         aaa.m10 = vm10 - v-accrued.
                         {trxbal-aaa.i}
                      end. else
                      do:
                          aaa.m10 = aaa.m10 + v-m10.
                      end.
                   end. /*v-intday2 > 0*/
                end. /* uv-date <> ?*/
             end. /*DoUpr*/
             else do:
                v-m10 = vbal * aaa.rate * n-intday / (aaa.base * 100).
                run savelog('dcls_ForteSpecial','261. ' + aaa.aaa).
                create accr-m10.
                assign
                    accr-m10.aaa     = aaa.aaa
                    accr-m10.rate    = aaa.rate
                    accr-m10.fdt     = g-today
                    accr-m10.base    = vbal
                    accr-m10.aaam10  = aaa.m10
                    accr-m10.m10     = v-m10
                    accr-m10.intday  = n-intday.

                vm10 = vbal * aaa.rate * n-intday / (aaa.base * 100) + aaa.m10.
                if vm10 gt 0 then do:
                   v-accrued = vm10.
                   aaa.accrued = aaa.accrued + v-accrued.
                   aaa.m10 = vm10 - v-accrued.
                   {trxbal-aaa.i}
                end. else
                do:
                    aaa.m10 = aaa.m10 + v-m10.
                end.
             end.
        end. /*DoPay*/


        vnewint = aaa.accrued.
        vtotaip = vtotaip + vnewint - voldint.
        vtotaipc = vtotaipc + vm-conv.
        vcnt = vcnt + 1.

        find cif where cif.cif eq aaa.cif.
        if v-accrued > 0  then do:
           run savelog('dcls_ForteSpecial','288. ' + aaa.aaa).
           find last accr where accr.aaa eq aaa.aaa no-error.
           if available accr then do:
              if (accr.fdt <> g-today) then do:
                 create accr.
                 {accr.i}
                 assign accr.aaa = aaa.aaa
                        accr.fdt = g-today
                        accr.bal = aaa.cr[1] - aaa.dr[1]
                        accr.rate = intrat
                        accr.accrued = v-accrued.
              end.
              else
              if (accr.fdt = g-today) then do:
                 assign accr.bal = aaa.cr[1] - aaa.dr[1]
                 accr.rate = intrat
                 accr.accrued = accr.accrued + v-accrued.
              end.
           end. /* if available accr */
           if not available accr then do:
              create accr.
              {accr.i}
              assign accr.aaa = aaa.aaa
                     accr.fdt = g-today
                     accr.bal = aaa.cr[1] - aaa.dr[1]
                     accr.rate = intrat
                     accr.accrued = v-accrued.
           end.
           run savelog('dcls_ForteSpecial','316. ' + aaa.aaa).
        end.

    end. /* for each aaa */

    if false then do transaction :
      find first gl no-lock no-error.
      find first jl no-lock no-error.
      def var s-aah as int.
      def var s-line as int.
      {jlupd-r.i} /*обновляет aaa.cr[] aaa.dr[]*/
    end.
    if dayacr.loval eq true then do:
    if vtotaip ne 0 then do transaction:
     find first trxlevgl where  trxlevgl.gl = lgr.gl and trxlevgl.sub = "cif" and trxlevgl.lev = 2 no-lock no-error .
     find first trxlevgl11 where  trxlevgl11.gl = lgr.gl and trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error .
     if not avail trxlevgl or not avail trxlevgl11 then do:
        v-text = " Нет настройки уровней Г/К для " + lgr.lgr + " группы " + " Г/К = " + string(lgr.gl) .
        Message v-text .
        put stream m-out unformatted v-text .
        output stream m-out close .
        pause .
        return .
     end.

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
            {cods.i}                 /*19.04.2005 nataly*/
      vln = vln + 1.

  if lgr.crc ne 1 then do:
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
            {cods.i}                 /*19.04.2005 nataly*/
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
            {cods.i}                    /*19.04.2005 nataly*/
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
             jl.rem = lgr.lgr.
            {cods.i}                   /*19.04.2005 nataly*/
      vln = vln + 1.

      find crc where crc.crc eq lgr.crc no-lock no-error.
      v-sum = vtotaipc .
      accumulate v-sum (total).
      display stream m-out lgr.lgr crc.code vtotaip v-sum with no-label.
    end.  /* if vtotaip ne 0 */
    end. /* if dayacr eq true */
    run savelog('dcls_ForteSpecial','394. ' + aaa.aaa).
  end. /* for each lgr */

display stream m-out  fill("-",70) format "x(70)" skip
accum total v-sum at 29 format ">>>,>>>,>>>,>>>,>>9.99-"
with no-label frame a.


output stream m-out close.
unix silent mv ForteSpecial.txt value(fname1).





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



Procedure PayInterests. /*Выплата процентов*/
    /*def var d_sum as decimal.*/
    def var v-pay as decimal.
    def var d_tax as decimal decimals 2 init 0.
      v-pay = aaa.cr[2] - aaa.dr[2].
      if v-pay > 0 then do:
         vparam = string(v-pay) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999").
         v-jh = 0.
         run trxgen("DCL0005", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
         if rcode ne 0 then do:  end.
         else do:
                 if not s-bday then do:
                    find b-jh where b-jh.jh = v-jh exclusive-lock.
                    for each jl of b-jh exclusive-lock:
                        jl.jdt = s-target.
                    end.
                    b-jh.jdt = s-target.
                 end.
                 d_tax =  ((v-pay) * 15) / 100. /* Удержание 15% налога */
                 create urpayment.
                        urpayment.aaa = aaa.aaa.
                        urpayment.sum = v-pay - d_tax.
                        urpayment.jdt = s-target.
                 release jl. release urpayment.
                 run trxsts(v-jh, 6, output rcode, output rdes).


                  if d_tax > 0 then do:
                     find last cif where cif.cif = aaa.cif no-lock no-error.
                     v-jh = 0.
                     /* Удержание 15 % налога */
                     if cif.geo = '022' and cif.type = 'B' then do:
                        v-nlg = "".
                        find last bnlg-sysc where bnlg-sysc.sysc = "nlg022"  no-lock no-error.
                        if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                     end. else do:
                        v-nlg = "".
                        find last bnlg-sysc where bnlg-sysc.sysc = "nlg"  no-lock no-error.
                        if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                     end. /* cif.geo = '022'*/

                     if aaa.crc <> 1 then do:
                        vparam = string(d_tax)
                             + vdel + aaa.aaa
                             + vdel + string(getConvGL(aaa.crc,"C"))
                             + vdel + string("Налог у источника выплаты 15%. " + cif.prefix + " " + cif.name + " " + cif.bin)
                             + vdel + v-nlg
                             + vdel + string("Налог у источника выплаты 15%. " + cif.prefix + " " + cif.name + " " + cif.bin).
                        run trxgen("vnb0083", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     end. else do:
                        vparam = string(d_tax) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel + string(v-nlg) + vdel +
                                 string("Налог у источника выплаты 15%. " + cif.prefix + " " + cif.name + " " + cif.bin) + vdel + "390".
                        run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                     end. /*aaa.crc <> 1*/

                     if rcode ne 0 then do:  end.
                     else do:
                        if not s-bday then do:
                           find b-jh where b-jh.jh = v-jh exclusive-lock.
                           for each jl of b-jh exclusive-lock:
                               jl.jdt = s-target.
                           end.
                           b-jh.jdt = s-target.
                        end.
                     end.
                  end.  /*d_tax > 0*/

         end.  /*rcode ne 0*/
      end. /*v-pay > 0*/
End procedure.



Procedure EvaluateExpiryDate.
     def input  parameter j_lstmdt as date.
     def output parameter j_expdt  as date.

     def var years as inte initial 0.
     def var months as inte initial 0.
     def var days as inte.
     days = day(j_lstmdt).
     years = integer(integer(acvolt.x4) / 12 - 0.5).
     months = integer(acvolt.x4) - years * 12.
     months = months + month(j_lstmdt).
     if months > 12 then do:
        years = years + 1.
        months = months - 12.
     end.
     if month(j_lstmdt) <> month(j_lstmdt + 1) then do:
        months = months + 1.
        if months = 13 then do:
           months = 1.
           years = years + 1.
        end.
        days = 1.
     end.

     if months = 2 and days = 30 then do: months = 3. days = 1. end.
     if months = 2 and days = 29  and  (( (year(j_lstmdt)  + years) - 2000) modulo 4) <> 0 then do:
        months = 3.  days = 1.  end.

     j_expdt = date(months, days, year(j_lstmdt) + years).
     if month(j_lstmdt) <> month(j_lstmdt + 1) then do:
        if month(j_expdt) = 3 and day(j_expdt) = 1 then do:
        end.
        else
          j_expdt = j_expdt - 1.
     end.
End procedure.






