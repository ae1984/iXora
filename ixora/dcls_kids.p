/* dcls_kids.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Начисление процентов по депозитам "МЕТРО-ДЕТСКИЙ"
 * RUN

 * CALLER
        dayclose.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        30.06.2008 - id00004.
 * CHANGES
        15.08.08 - id00004 если открыли счет и не сделали ни одной проводки счет удаляем
        29.03.2011 evseev - изменил 18 на lgr.prefix для DoChgRate
        22/11/2011 evseev - ведение журнала accr-m10. если начисл. % < 0.01, то аккумулировать в aaa.m10.
        29/11/2011 evseev - перекомпиляция
        21.11.2012 evseev - ТЗ-1374
        26.12.2012 evseev
*/


{global.i }
{getdep.i }
{dcls_kids.i}
{convgl.i "bank"}
{chbin.i}

define new shared var s-jh  like jh.jh.
define shared var s-target as date.
define shared var s-bday   as log init true.
define shared var s-intday as int .




define buffer dayacr     for sysc.
define buffer aicoll     for sysc.
define buffer b-sysc     for sysc.
define buffer trxlevgl11 for trxlevgl .

define var vm-conv   as decimal decimals 2 .
define var vm-conv1  as decimal decimals 2 .
define var voldint   as decimal decimals 2.
define var vnewint   as decimal decimals 2.
define var vtotaip   as decimal decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vtotaipc  as decimal decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var v-accrued as decimal decimals 2 .
define var vm10      as decimal decimals 10 .
define var v-pay     as decimal.



define var DoPay     as logical.
define var DoCap     as logical.
define var DoChgRate as logical.
define var DoMature  as logical.
define var fire      as logical.



define var i         as integer.
define var v-intday1 as integer.
define var v-intday2 as integer.
define var v-jh      as integer.
define var rcode     as integer.
define var vln       as integer initial 1.
define var vcnt      as integer.


define var ev-date   as date.


define var vdel   as char initial "^".
define var vparam as char.
define var rdes   as char.
define var fname1 as char.
define var sycc   as char.
define var v-text as char.
define var v-code as char.
define var v-dep  as char format 'x(5)'.
define var acdate    as date.

define var intrat    like pri.rate.
define var vbal      like jl.dam label "BALANCE ".
define var v-intrat1 like aaa.rate.
define var v-intrat2 like aaa.rate.
define var v-base1   like jl.dam.
define var v-base2   like jl.dam.
define var v-pri     like pri.pri.
define var v-itype   like pri.itype.
define var v-sum     like glbal.bal.
define var v-nrate   as decimal.




def buffer blgr for lgr.
def buffer bgl for gl.




fname1 = "acrkids" + substring(string(g-today),1,2) + substring(string(g-today),4,2) + ".txt".

def stream m-out.
output stream m-out to acrtda.txt.

def stream m-err.
output stream m-err to acrtda.err.

find dayacr where dayacr.sysc eq "dayaca".
find aicoll where aicoll.sysc eq "aicoll".

find sysc where sysc.sysc = "IPGL" no-lock no-error.
if available sysc then sycc = sysc.chval.



def var v-nm as integer.
v-nm = 0.
for each lgr where lgr.led = "TDA" :
    if lgr.feensf <> 3 then next.
    for each aaa where aaa.lgr eq lgr.lgr break by aaa.crc:
        v-nm = 1.
    end.
end.

if v-nm = 1 then do:
if dayacr.loval eq true then do transaction:
    run x-jhnew.
    find jh where jh.jh = s-jh.
    jh.party = "TDA ACCRUED INTEREST TRANSACTION".
    jh.crc = 0.
    if not s-bday then jh.jdt = s-target.
    display stream m-out jh.jh.
end.
end.



/*Только депозит метро-СТАНДАРТ*/
for each lgr where lgr.led = "TDA" and lgr.feensf = 7 :

    vcnt = 0.
    vtotaip = 0.
    vtotaipc = 0 .

    account:
    for each aaa where aaa.lgr eq lgr.lgr break by aaa.crc:



/*if aaa.aaa <> "199759775" then next account. */

        find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
        if not avail acvolt then do:
           next account.
        end.
        if acvolt.x1 = "" then next account.
        if acvolt.x3 = "" then next account.



        find last crc where crc.crc eq aaa.crc no-lock no-error.

        if (aaa.regdt > g-today) or (lookup (aaa.sta, "C,T,S") > 0) then next account.
        if aaa.sta = "E" then do:
           aaa.cltdt = g-today.
           if aaa.cr[1] = aaa.dr[1] then aaa.sta = "C".
           next account.
        end.
        if aaa.opnamt = 0 and aaa.cr[2] = aaa.dr[2] then do:
           aaa.cltdt = g-today.
           next account.
        end.

        if v-bin then do:
           find first cif where cif.cif = aaa.cif no-lock no-error.
           if avail cif then do:
              if trim(cif.bin) = '' and trim(cif.geo) <> '022'  then do:
                 find first bin where bin.rnn = cif.jss no-lock no-error.
                 if not avail bin then do:
                    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                    if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","Начисление % не производилось", "Операция не возможна в связи с отсутствием ИИН/БИН " + cif.cif + ", " + trim(cif.prefix) + " " + trim(cif.name) + ", " + aaa.aaa , "", "","").
                    run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "Начисление % не производилось", "Операция не возможна в связи с отсутствием ИИН/БИН " + cif.cif + ", " + trim(cif.prefix) + " " + trim(cif.name) + ", " + aaa.aaa , "", "","").
                    next account.
                 end.
              end.
           end.
        end.


        if aaa.regdt = g-today then do:
           if aaa.opnamt <> aaa.cr[1] - aaa.dr[1] then do:
              aaa.opnamt = aaa.cr[1] - aaa.dr[1].
           end.
        end.


        vm-conv  = 0. /* сумма 11 ур по одному счету по всем проводкам     */
        vm-conv1 = 0. /* сумма 11 уровня по одному счету по одной проводке */
        v-accrued = 0.
        voldint = aaa.accrued.



        if lgr.intcal = "D" then do:
           DoPay     = false.
           DoCap     = false.
           DoChgRate = false.
           DoMature  = false.
           ev-date = ?.




           ev-date = EventInRange(lgr.type, g-today, s-target - 1).
           if ev-date <> ? then do:
              DoCap = true.
              run EventHandler(lgr.prefix, ev-date, date(acvolt.x1), date(acvolt.x3) - 1, output fire).
              if fire then DoChgRate = true.
           end.
           else do:
             ev-date = EventInRange(lgr.prefix, g-today, s-target - 1).
             if ev-date <> ? then do:

                DoChgRate = true.
             end.
           end.












            if ev-date <> ? then aaa.cltdt = ev-date.
            else aaa.cltdt = g-today.

            v-intday1 = ev-date - g-today + 1.
            v-intday2 = s-intday - v-intday1.

/* Смена ставки */
           if DoChgRate then do:
              v-base1 = IntBase().
              v-intrat1 = aaa.rate.

              run CalcInterests(v-intday1, v-intrat1, v-base1).
              if DoCap then run CapInterests.

              aaa.nextint = ev-date.
              v-base2 = IntBase().
              v-intrat2 = GetRate(v-base2).
              aaa.rate = v-intrat2.

              if v-intday2 > 0 then do:
                 run CalcInterests(v-intday2, v-intrat2, v-base2).
              end.
           end.
           else
           if DoCap then do:



              v-base1 = IntBase().
              v-intrat1 = aaa.rate.
              run CalcInterests(v-intday1, v-intrat1, v-base1).
              run CapInterests.

/*Новые сроки при пролонгации*/
  find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
  if avail acvolt then do:
     if ev-date = date(acvolt.x3) - 1 then do:
        acvolt.x1 = string(ev-date + 1). /*дата открытия*/
        run EvaluateExpiryDate(date(acvolt.x1), output acdate).
        acvolt.x3 = string(acdate).
        v-nrate = 0.
        acvolt.bonusopnamt = aaa.stmgbal.
        if aaa.payfre <> 1 then do:
           run tdagetrate(aaa.aaa, aaa.pri, 18, ev-date, aaa.opnamt, output v-nrate).
           aaa.rate = v-nrate.
        end.
     end.
  end.

/*Новые сроки при пролонгации*/

              v-base1 = IntBase().
              v-intrat1 = aaa.rate.
              if v-intday2 > 0 then
                 run CalcInterests(v-intday2, v-intrat1, v-base1).
           end.
           else do:
              aaa.cltdt = g-today.
              v-base1 = IntBase().
              v-intrat1 = aaa.rate.
              run CalcInterests(s-intday, v-intrat1, v-base1).
           end.
        end.
        else do:
          aaa.cltdt = g-today.
          next account.
        end.
        vnewint = aaa.accrued.
        vtotaip = vtotaip + vnewint - voldint.
        vtotaipc = vtotaipc + vm-conv.
        vcnt = vcnt + 1.
   end. /* for each aaa */

   if dayacr.loval eq true then do:
    if vtotaip > 0 then do transaction:
      find first trxlevgl where  trxlevgl.gl = lgr.gl and trxlevgl.sub = "cif" and trxlevgl.lev = 2 no-lock no-error.
      find first trxlevgl11 where  trxlevgl11.gl = lgr.gl and trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error.
      if not avail trxlevgl or not avail trxlevgl11 then do:
        v-text = " Нет настройки уровней Г/К для " + lgr.lgr + " группы " + " Г/К = " + string(lgr.gl).
        Message v-text.
        put stream m-out unformatted v-text.
        output close.
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
            {cods.i}       /*19.04.05 nataly*/
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
            {cods.i}       /*19.04.05 nataly*/
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
            {cods.i}       /*19.04.05 nataly*/
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
            {cods.i}       /*19.04.05 nataly*/
      vln = vln + 1.

      find crc where crc.crc eq lgr.crc no-lock no-error.
      v-sum = vtotaipc .
      accumulate v-sum (total).
      display stream m-out lgr.lgr crc.code vtotaip v-sum with no-label.
    end.  /* if vtotaip > 0 */
   end. /* if dayacr.loval = true */
  end. /* for each lgr */

display stream m-out  fill("-",70) format "x(70)" skip
accum total v-sum at 29 format ">>>,>>>,>>>,>>>,>>9.99-"
with no-label frame a.
output stream m-out close.
unix silent mv acrtda.txt value(fname1).

output stream m-err close.






/*Начисление процентов*/
Procedure CalcInterests.
   def input parameter ss-intday as inte.
   def input parameter ss-intrat like aaa.rate.
   def input parameter ss-base like jl.dam.
   define variable v-m10 like aaa.m10.

   v-m10 = ss-base * ss-intrat * ss-intday / (aaa.base * 100).
   create accr-m10.
   assign
       accr-m10.aaa     = aaa.aaa
       accr-m10.rate    = ss-intrat
       accr-m10.fdt     = g-today
       accr-m10.base    = ss-base
       accr-m10.aaam10  = aaa.m10
       accr-m10.m10     = v-m10
       accr-m10.intday  = ss-intday.

   vm10  = ss-base * ss-intrat * ss-intday / (aaa.base * 100) + aaa.m10.
   if vm10 > 0 then do :

      v-accrued = vm10.
      aaa.accrued = aaa.accrued + v-accrued.
      aaa.m10 = vm10 - v-accrued .
      {trxbal-aaa.i}
      if v-accrued > 0  then do:
         find last accr where accr.aaa eq aaa.aaa no-error.
         if available accr then do:
            if (accr.fdt <> g-today) then do:
               create accr.
               {accr.i}

               assign accr.aaa = aaa.aaa
                      accr.fdt = g-today
                      accr.bal = ss-base
                      accr.rate = ss-intrat
                      accr.accrued = v-accrued.
            end.
            else
            if (accr.fdt = g-today) then do:
               assign accr.bal = ss-base
               accr.rate = ss-intrat
               accr.accrued = accr.accrued + v-accrued.
            end.
         end. /* if available accr */
         if not available accr then do:
            create accr.
            {accr.i}

            assign accr.aaa = aaa.aaa
                   accr.fdt = g-today
                   accr.bal = ss-base
                   accr.rate = ss-intrat
                   accr.accrued = v-accrued.
          end.
      end.
   end. else
   do:
       aaa.m10 = aaa.m10 + v-m10.
   end.
End Procedure.






Procedure CapInterests.
  def var d_sum as decimal decimals 2.
  def var d_aadcap as decimal init 0.
  def var d_sm2 as decimal decimals 2.
       d_aadcap = 0.
       v-pay = aaa.cr[2] - aaa.dr[2].
       d_sm2 = aaa.cr[2] - aaa.dr[2].

       if v-pay > 0 then do transaction:


           vparam = string(v-pay) + vdel + aaa.aaa + vdel + string(lgr.autoext,"999").
           v-jh = 0.
           run trxgen("DCL0005", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
           if rcode ne 0 then do:
              put stream m-err unformatted "Не удалось сформировать проводку капитализации накопленных % : " aaa.aaa ", " string(v-pay) " -> " rdes skip.
           end.
           else do:

             d_sum = 0.
             for each aad where aad.aaa = aaa.aaa and aad.who <> 'bankadm' exclusive-lock.
               if aad.cam - aad.dam > 0 then do:
                  aad.cam = aad.cam + aad.cam1.
                  d_sum = d_sum + aad.cam1.
                  aad.cam1 = 0.
               end.
             end.

             create aad.
             assign aad.aaa   = aaa.aaa
                    aad.gl    = aaa.gl
                    aad.lgr   = aaa.lgr
                    aad.crc   = aaa.crc
                    aad.regdt = g-today
                    aad.cam   = v-pay - d_sum  /* От общей суммы % 2 уровня отнимаем % нач-ные на доп взносы */
                    aad.rate  = aaa.rate
                    aad.who   = 'bankadm'
                    aad.rem   = 'true'
                    aad.m10   = 0.

             if not s-bday then do:
                find jh where jh.jh = v-jh exclusive-lock.
                for each jl of jh exclusive-lock:
                    jl.jdt = s-target.
                end.
                jh.jdt = s-target.
             end.

             release jl. release jh.
             run trxsts(v-jh, 6, output rcode, output rdes).
             if rcode ne 0 then do:
                put stream m-err unformatted
                 "Не удалось отштамповать проводку капитализации накопленных % : "
                 aaa.aaa ", " string(v-pay) " -> " rdes skip.
             end.
             /*увеличили aas.chkamt на сумму %% */
             run tdasethold(aaa.aaa, v-pay).
             aaa.stmgbal = aaa.stmgbal + v-pay.
           end. /* else do   */
         end.   /* v-pay > 0 */
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
def var ts as integer.


ts = 0.


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
ts = 0.
       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.


       /*еУМЙ УЮЕФ ПФЛТЩФ Ч РПУМЕДОЙК ДЕОШ НЕУСГБ ОП ОЕ Ч ЖЕЧТБМЕ*/
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
       /*еУМЙ УЮЕФ ПФЛТЩФ 1-ЗП ЮЙУМБ*/
       if day(a_start) = 1 then do: /*еУМЙ дБФБ ПФЛТЩФЙС 1 ЮЙУМБ*/
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
             ts = 1.
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
if  ts = 1 then do:
    ts = 0. months = 2.
end.

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






Procedure EvaluateExpiryDate.
 def input  parameter j_lstmdt as date.
 def output parameter j_expdt  as date.


 def var years as inte initial 0.
 def var months as inte initial 0.
 def var days as inte.
 days = day(j_lstmdt).
 years = integer(aaa.cla / 12 - 0.5).
 months = aaa.cla - years * 12.
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




