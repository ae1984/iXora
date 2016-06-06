/* dclsUR.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Начисление процентов по депозитам юридических лиц.
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        06.12.2005 dpuchkov
 * BASES
        BANK COMM
 * CHANGES
        04.07.2006 dpuchkov - если счет в тенге используем шаблон без конвертации
        05.10.06 nataly добавила getdep.i
        09.03.2010 id00004 добавил возможность выплаты на 1 ур по счету 500714501 согл СЗ
        02.04.2010 id00004 Добавил аозможность начисления процентов по депозитам открытым в днях в соответствии с ТЗ-643
        14/01/2010 evseev - депозит недропользователь 518,519,520
        22/02/2011 evseev - удержание налога 15% с выплаты процентов нерезидентам
        30.03.2011 evseev - изменил Y на N для DoRate
        31/05/2011 evseev - изменил условие if aaa.payfre <> 1 then на if aaa.payfre <> 1 or (aaa.payfre = 1 and lookup(aaa.lgr,"478,479,480,481,482,483") <> 0) then
        29/06/2011 evseev - при закрытии года или раньше если выпадут праздники на конец месяца проводки "садятся" с будущей датой.
        30/06/2011 evseev - ТЗ-1070. Запрет автопролонгации 478-483
        04/10/2011 evseev - если запись не напйдена, то отправка ошибок мне на почту.
        22/11/2011 evseev - ведение журнала accr-m10. если начисл. % < 0.01, то аккумулировать в aaa.m10.
        29/11/2011 evseev - перекомпиляция
        13/12/2011 evseev - ТЗ-1070. Запрет выплаты % по 478-483
        21.11.2012 evseev - ТЗ-1374
        28.11.2012 evseev - ТЗ-1374
        23.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        05.07.2013 evseev - tz-1856
*/


{global.i}
{getdep.i}
{dclstda.i}
{convgl.i "bank"}
{chbin.i}
def var glbuy like gl.gl .
def var glsel like gl.gl .
define buffer dayacr for sysc.
define buffer aicoll for sysc.
def buffer b-jh for jh.
def var vm-conv as dec decimals 2 .
def var vm-conv1 as dec decimals 2 .
define shared var s-target as date.
define shared var s-bday as log .
define shared var s-intday as int.
def var v-text as cha .
define new shared var s-jh  like jh.jh.
define new shared var s-consol like jh.consol initial false.
define var wekday as int.
define var intrat like pri.rate.
define var voldacc like aaa.accrued label "OLD-ACC".
define var voldint as dec decimals 2.
define var vnewint as dec decimals 2.
define var vtotaip as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vtotaipc as dec decimals 2 format ">>>,>>>,>>>,>>>.99-" .
define var vln as int initial 1.
define var vcnt as int.
define var vbal like jl.dam label "BALANCE ".
define var v-inttyp as log.
define var v-accrued as dec decimals 2 .
define var v-inc as int.
define var v-tmpbal as dec decimals 2.
define var v-intbal like v-tmpbal.
define var v-max like aaa.cbal.
define var v-min like aaa.cbal.
define var vm10 as dec decimals 10 .
define variable v-m10 like aaa.m10.
define var acdate    as date.
define var v-nrate   as decimal.
                                             /* 19.04.2005 nataly */
define var v-code as char.
define var v-dep as char format 'x(5)'.
def buffer bgl for gl.                       /* 19.04.2005 nataly */

/*Добавлено*/
def var ev-date as date.
def var uv-date as date.
def var rt-date as date.
def var DoPay  as logi.
def var DoHold as logi.
def var DoUpr  as logi.
def var DoRate  as logi.

def var v-intday1 as integer.
def var v-intday2 as integer.
/*END добавлено*/


def buffer blgr for lgr.
def var v-pri like pri.pri.
def var v-itype like pri.itype.
def var po as int init 0.
def var sycc as char.
def var pir as char.
def buffer b-sysc for sysc.
def buffer bnlg-sysc for sysc.
def var v-nlg as char.
def var v-sum like glbal.bal.
def buffer trxlevgl11 for trxlevgl .
def stream m-out.
def var fname1 as char.
def var d_sm1 as decimal.

run savelog('dclsUR','115').
find first aaa where lookup(aaa.lgr,"478,479,480,481,482,483,484,485,486,487,488,489,518,519,520") > 0 no-lock no-error.
if not avail aaa then return.
run savelog('dclsUR','118').

fname1 = 'acraaan' + substring(string(g-today),1,2) + substring(string(g-today),4,2) + '.txt'.

output stream m-out to acraaan.txt.

find dayacr where dayacr.sysc eq "dayaca".
find aicoll where aicoll.sysc eq "aicoll".
find sysc "bsrate" no-lock no-error.
if available sysc then v-brate = sysc.deval. else v-brate = 6.
find sysc where sysc.sysc = "IPGL" no-lock no-error.
if available sysc then sycc = sysc.chval.

if dayacr.loval eq true then do transaction:
    run x-jhnew.
    find jh where jh.jh = s-jh.
    jh.party = "ACCRUED INTEREST TRANSACTION".
    jh.crc = 0.
    if not s-bday then jh.jdt = s-target.
    display stream m-out jh.jh.
end.


def var vparam as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".
def var v-jh as inte.
def var v-pay as deci.
def var n-intday as integer.
def var v-val as char.
define buffer bb-cif for cif.
define buffer bb-sysc for sysc.
find last bb-sysc where bb-sysc.sysc = "JUR" no-lock no-error.



for each lgr where lgr.intcal = "D" use-index intcal:
    if lgr.led = "TDA" then next.
    if lookup(lgr.lgr, "478,479,480,481,482,483,484,485,486,487,488,489,518,519,520") = 0 then next.
    if lookup(lgr.lgr, bb-sysc.chval) = 0 then next.

    vcnt = 0. vtotaip = 0. vtotaipc = 0. v-pri = lgr.pri.
    if (lookup(lgr.lgr,"518,519,520") = 0) then do:
       find pri where pri.pri eq lgr.pri.
       v-itype = pri.itype.
       if lgr.lookaaa eq false then do:
          if v-pri ne "F" then do:
             if v-itype eq 1 then intrat = pri.rate + lgr.rate.
          end.
          else intrat = lgr.rate.
       end.
    end.

    /* ПО ВСЕМ СЧЕТАМ ААА */
    c-aaa:
    for each aaa where aaa.lgr = lgr.lgr  break by aaa.crc:
        /*if aaa.aaa <> "002714522" then next. */
        if lookup(aaa.sta,'c,e,C,E') > 0 then next.
        find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
        if not avail acvolt then do:
           next .
        end.

        if acvolt.x1 = "" then next.
        if acvolt.x3 = "" then next.
        if acvolt.x7 = 4  then next. /* 3 пролонгации дальнейшее начисление запрещено */
        if (lookup(aaa.lgr,"518,519,520") <> 0) and (aaa.rate = 0) then next. /*Недропользователь без пролонгаций*/
        if (lookup(aaa.lgr,"518,519,520") <> 0) and (aaa.pri = 'F')  then next.
        if date(acvolt.x3) <= g-today then next.

        if string(aaa.lstmdt) = ? then next.

        if aaa.regdt = g-today then do:
           aaa.opnamt = (aaa.cr[1] - aaa.dr[1]) .
        end.
        if aaa.opnamt > (aaa.cr[1] - aaa.dr[1]) then do:
           aaa.opnamt = aaa.cr[1] - aaa.dr[1].
        end.

        DoPay = false.
        DoRate = false.
        DoHold = false.
        DoUpr  = false.
        if lgr.intcal = "D" then do: /*ежедневное начисление*/
           DoPay = false.
           DoHold = false.
           DoUpr = false.
           DoRate = false.
           uv-date = ?.
           if lookup(aaa.lgr,"518,519,520") <> 0 then do:
              /*uv-date = EventInRange(lgr.intcal, g-today, s-target - 1).*/
              uv-date = ?.
           end.
           else do:
              uv-date = EventInRange("M", g-today, s-target - 1). /*Вычисляем количество начисленных процентов на конец месяца */
           end.
           if uv-date <> ? then do:
              DoUpr = true. /*Вычисляем количество начисленных процентов */
           end.

           ev-date = ?.
           if lookup(aaa.lgr,"518,519,520") <> 0 then do:
              ev-date = EventInRange(lgr.intpay, g-today, s-target - 1).
           end.
           else do:
              if acvolt.sts = "d" then do:
                 ev-date = EventInRange("F", g-today, s-target - 1).
              end.
              else do:
                 ev-date = EventInRange(lgr.intpay, g-today, s-target - 1).
              end.
           end. /*lookup(aaa.lgr,"A38,518,519,520")*/

           if (lookup(aaa.lgr,"478,479,480,481,482,483") > 0) and (aaa.regdt >= 08/01/2011) then do:
              if aaa.aaa = 'KZ13470172215A319508' then ev-date = EventInRange(/*lgr.intpay*/ "M", g-today, s-target - 1).
              else ev-date = EventInRange(/*lgr.intpay*/ "F", g-today, s-target - 1).
           end.

           if ev-date <> ? then do:
              if aaa.aaa <> "500714501" then do:
                 DoPay = true. /*Выплата процентов на первый уровень */
              end.
           end.

           rt-date = ?.
           if lookup(aaa.lgr,"518,519,520") <> 0 then do:
               rt-date = EventInRange(lgr.prefix, g-today, s-target - 1).
           end.
           else do:
               rt-date = EventInRange("N", g-today, s-target - 1). /*смена процентных ставок*/ /*Evseev. Сменил Y на N*/
           end.
           if rt-date <> ? then do:
              DoRate = true. /*смена процентных ставок*/
           end.
        end.

        /*ставки до востребования*/
        if aaa.crc = 1 then  do: find sysc "ratekz" no-lock no-error. if available sysc then v-brate = sysc.deval. end.
        if aaa.crc = 2 then  do: find sysc "rateus" no-lock no-error. if available sysc then v-brate = sysc.deval. end.
        if aaa.crc = 3 then  do: find sysc "rateeu" no-lock no-error. if available sysc then v-brate = sysc.deval. end.

        n-intday = s-intday.

        find last crc where crc.crc = aaa.crc no-lock no-error.
        if not avail crc then do:
           run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                   aaa.aaa + " не найдена запись в crc [1] ", "1", "", "").
           next.
        end.
        if (aaa.cr[1] - aaa.dr[1]) = 0 or  (aaa.regdt > g-today) or (lookup(aaa.sta, "C,T,S") > 0) then next c-aaa.

        if aicoll.loval eq true and aaa.cbal le 0 then next c-aaa.

        if v-bin then do:
           find first cif where cif.cif = aaa.cif no-lock no-error.
           if avail cif then do:
              if trim(cif.bin) = '' and trim(cif.geo) <> '022'  then do:
                 find first bin where bin.rnn = cif.jss no-lock no-error.
                 if not avail bin then do:
                    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                    if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","Начисление % не производилось", "Операция не возможна в связи с отсутствием ИИН/БИН " + cif.cif + ", " + trim(cif.prefix) + " " + trim(cif.name) + ", " + aaa.aaa , "", "","").
                    run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "Начисление % не производилось", "Операция не возможна в связи с отсутствием ИИН/БИН " + cif.cif + ", " + trim(cif.prefix) + " " + trim(cif.name) + ", " + aaa.aaa , "", "","").
                    next.
                 end.
              end.
           end.
        end.


        vm-conv  = 0. /* сумма 11 ур по одному счету по всем проводкам     */
        vm-conv1 = 0. /* сумма 11 уровня по одному счету по одной проводке */
        v-accrued = 0. /*!!!!!!!!!*/
        voldacc = aaa.accrued.
        voldint = aaa.accrued.

        intrat = aaa.rate.

        if aaa.aaa = 'KZ13470172215A319508' then do:
            vbal = IntBase().
        end. else do:
            vbal = aaa.opnamt.
            for each aad where aad.aaa = aaa.aaa no-lock:
                vbal = vbal + aad.sumg.
            end.
        end.

        do transaction:
           if DoPay then do:
              if ev-date <> ? then do:
                 v-intday1 = ev-date - g-today + 1.
                 v-intday2 = s-intday - v-intday1.

                 v-m10 = vbal * aaa.rate * v-intday1 / (aaa.base * 100).
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

                 if lookup(aaa.lgr,"518,519,520") <> 0 then do:
                    aaa.rate = 0.
                 end.
                 else do:
                     if (lookup(aaa.lgr,"478,479,480,481,482,483") > 0) and (aaa.regdt < 08/01/2011) or (lookup(aaa.lgr,"478,479,480,481,482,483") = 0) then do:
                         /*Новые сроки при пролонгации*/
                         find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                         if avail acvolt then do:
                            if ev-date = date(acvolt.x3) - 1 then do:
                               acvolt.x1 = string(ev-date + 1). /*дата открытия*/
                               if acvolt.sts = "d" then do:
                                  acvolt.x3 = string(date(acvolt.x1) + integer(acvolt.x4)).
                               end.
                               else do:
                                  run EvaluateExpiryDate(date(acvolt.x1), output acdate).
                                  acvolt.x3 = string(acdate).
                               end.

                               d_sm1 = 0.
                               for each urpayment where urpayment.aaa = aaa.aaa no-lock:
                                   d_sm1 = d_sm1 + urpayment.sum.
                               end.
                               /*Сумма на момент окончания срока депозита*/
                               acvolt.bonusopnamt = d_sm1.

                               if aaa.payfre <> 1 or (aaa.payfre = 1 and lookup(aaa.lgr,"478,479,480,481,482,483") <> 0) then do:
                                  if aaa.crc = 1 then  v-val = "KZT".
                                  if aaa.crc = 2 then  v-val = "USD".
                                  if aaa.crc = 3 then v-val = "EUR".


                                  if lookup(aaa.lgr,"478,479,480,481,482,483") <> 0 then do: /*Срочный вклад*/
                                     if acvolt.sts = "d" then do:
                                        find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SRd"  no-lock no-error.
                                        if avail rtur then  aaa.rate = rtur.rate.
                                        else do:
                                          run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                          acvolt.aaa + " не найдена запись в rtur [1] ", "1", "", "").
                                        end.
                                     end.
                                     else do:
                                        find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SR"  no-lock no-error.
                                        if avail rtur then  aaa.rate = rtur.rate.
                                        else do:
                                          run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                          acvolt.aaa + " не найдена запись в rtur [2] ", "1", "", "").
                                        end.
                                     end.
                                  end.

                                  if lookup(aaa.lgr,"484,485,486,487,488,489") <> 0 then do: /*Накопительный вклад*/
                                     find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "NK"  no-lock no-error.
                                     if avail rtur then  aaa.rate = rtur.rate.
                                     else do:
                                       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                       acvolt.aaa + " не найдена запись в rtur [3] ", "1", "", "").
                                     end.
                                  end.
                               end.
                               acvolt.x7 = acvolt.x7 + 1. /*считаем количество пролонгаций*/
                               if acvolt.x7 = 4 then aaa.rate = 0. /*Пролонгация  3 раза дальнейшее начисление запрещено*/
                            end.
                            acvolt.prim1 = string(aaa.accrued).
                         end. /*avail acvolt*/
                         /*Новые сроки при пролонгации*/
                     end. /*if (lookup(aaa.lgr,"478,479*/
                 end. /*lookup(aaa.lgr,"518,519,520") <> 0*/

                 if (lookup(aaa.lgr,"478,479,480,481,482,483") > 0) and (aaa.regdt >= 08/01/2011) then do:
                 end. else do:
                     if v-intday2 > 0 then do:
                         v-m10 =  v-intday2 * vbal * aaa.rate / (aaa.base * 100).
                         create accr-m10.
                         assign
                             accr-m10.aaa     = aaa.aaa
                             accr-m10.rate    = aaa.rate
                             accr-m10.fdt     = g-today
                             accr-m10.base    = vbal
                             accr-m10.aaam10  = aaa.m10
                             accr-m10.m10     = v-m10
                             accr-m10.intday  = v-intday2.

                        vm10 =  v-intday2 * vbal * aaa.rate / (aaa.base * 100) + aaa.m10.
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
                 end.
              end.
           end. /*DoPay*/
           else do:
                if DoUpr then do:
                   if uv-date <> ? then do:
                      v-intday1 = uv-date - g-today + 1.
                      v-intday2 = s-intday - v-intday1.
                      v-m10 =  vbal * aaa.rate * v-intday1 / (aaa.base * 100).
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
                      if DoRate then do:
                            if aaa.payfre <> 1 then do:
                               if aaa.crc = 1 then  v-val = "KZT".
                               if aaa.crc = 2 then  v-val = "USD".
                               if aaa.crc = 3 then v-val = "EUR".

                               if lookup(aaa.lgr,"518,519,520") <> 0 then do:
                                  v-nrate = 0.
                                  run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, ev-date, aaa.opnamt, output v-nrate).
                                  aaa.rate = v-nrate.
                               end.

                               if lookup(aaa.lgr,"478,479,480,481,482,483") <> 0 then do:
                                  if acvolt.sts = "d" then do:
                                     find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SRd"  no-lock no-error.
                                     if avail rtur then  aaa.rate = rtur.rate.
                                     else do:
                                       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                       acvolt.aaa + " не найдена запись в rtur [4] ", "1", "", "").
                                     end.
                                  end.
                                  else do:
                                     find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SR"  no-lock no-error.
                                     if avail rtur then  aaa.rate = rtur.rate.
                                     else do:
                                       run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                       acvolt.aaa + " не найдена запись в rtur [5] ", "1", "", "").
                                     end.
                                  end.
                               end.

                               if lookup(aaa.lgr,"484,485,486,487,488,489") <> 0 then do:
                                  find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "NK"  no-lock no-error.
                                  if avail rtur then  aaa.rate = rtur.rate.
                                  else do:
                                    run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                    acvolt.aaa + " не найдена запись в rtur [6] ", "1", "", "").
                                  end.
                               end.
                            end.
                      end. /*DoRate*/
                      if v-intday2 > 0 then do:

                         v-m10 =  v-intday2 * vbal * aaa.rate / (aaa.base * 100).
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
                else
                if DoRate then do:
                   if rt-date <> ? then do:
                      v-intday1 = rt-date - g-today + 1.
                      v-intday2 = s-intday - v-intday1.
                      v-m10 =  vbal * aaa.rate * v-intday1 / (aaa.base * 100).
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
                      if aaa.payfre <> 1 then do:
                         if aaa.crc = 1 then  v-val = "KZT".
                         if aaa.crc = 2 then  v-val = "USD".
                         if aaa.crc = 3 then v-val = "EUR".

                         if lookup(aaa.lgr,"518,519,520") <> 0 then do:
                            v-nrate = 0.
                            run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, ev-date, aaa.opnamt, output v-nrate).
                            aaa.rate = v-nrate.
                         end.


                         if lookup(aaa.lgr,"478,479,480,481,482,483") <> 0 then do:
                            if acvolt.sts = "d" then do:
                               find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SRd"  no-lock no-error.
                               if avail rtur then  aaa.rate = rtur.rate.
                               else do:
                                 run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                 acvolt.aaa + " не найдена запись в rtur [7] ", "1", "", "").
                               end.
                            end.
                            else do:
                               find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "SR"  no-lock no-error.
                               if avail rtur then  aaa.rate = rtur.rate.
                               else do:
                                 run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                                 acvolt.aaa + " не найдена запись в rtur [8] ", "1", "", "").
                               end.
                            end.
                         end.
                         if lookup(aaa.lgr,"484,485,486,487,488,489") <> 0 then do:
                            find last rtur where rtur.cod = v-val and rtur.trm = integer(acvolt.x4) and rtur.rem = "NK"  no-lock no-error.
                            if avail rtur then  aaa.rate = rtur.rate.
                            else do:
                              run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: в dclsUR",
                              acvolt.aaa + " не найдена запись в rtur [9] ", "1", "", "").
                            end.
                         end.
                      end.

                      if v-intday2 > 0 then do:
                          v-m10 =  v-intday2 * vbal * aaa.rate / (aaa.base * 100).
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
                   end. /*if rt-date <> ?*/
                end. /*DoRate*/
                else do:
                   v-m10 = vbal * aaa.rate * n-intday / (aaa.base * 100).
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
                end. /*DoRate*/
           end. /*DoPay*/
        end. /*do transaction*/

        vnewint = aaa.accrued.
        vtotaip = vtotaip + vnewint - voldint.
        vtotaipc = vtotaipc + vm-conv.
        vcnt = vcnt + 1.

        find cif where cif.cif eq aaa.cif.
        if v-accrued > 0  then do:
           create accr.
           {accr.i}
           assign accr.aaa = aaa.aaa
                  accr.fdt = g-today
                  accr.bal = aaa.cr[1] - aaa.dr[1]
                  accr.rate = intrat
                  accr.accrued = v-accrued.
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
     find first trxlevgl where  trxlevgl.gl = lgr.gl and
       trxlevgl.sub = "cif" and trxlevgl.lev = 2 no-lock no-error .
     find first trxlevgl11 where  trxlevgl11.gl = lgr.gl and
       trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error .
     if not avail trxlevgl or not avail trxlevgl11 then do:
       v-text = " Нет настройки уровней Г/К для " + lgr.lgr + " группы "
        + " Г/К = " + string(lgr.gl) .
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
    {dcls7.i} /*Пустая ишка*/
  end. /* for each lgr */

display stream m-out  fill("-",70) format "x(70)" skip
accum total v-sum at 29 format ">>>,>>>,>>>,>>>,>>9.99-"
with no-label frame a.
{dcls7.i} /*Пустая ишка*/

output stream m-out close.
unix silent mv acraaan.txt value(fname1).







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

             find last urdpinfo where urdpinfo.aaa = aaa.aaa no-lock no-error.
             if avail urdpinfo then do:
                if urdpinfo.rem1 = "1" then d_tax =  ((v-pay) * 15) / 100. /* Удержание 15% налога */
             end.

             if aaa.aaa = 'KZ13470172215A319508' then do:
                 create aad.
                 assign aad.aaa   = aaa.aaa
                        aad.gl    = aaa.gl
                        aad.lgr   = aaa.lgr
                        aad.crc   = aaa.crc
                        aad.regdt = g-today
                        aad.cam   = v-pay
                        aad.rate  = aaa.rate
                        aad.who   = 'bankadm'
                        aad.rem   = 'true'
                        aad.m10   = 0.
             end.

             create urpayment.
                    urpayment.aaa = aaa.aaa.
                    urpayment.sum = v-pay - d_tax.
                    urpayment.jdt = s-target.
                    /*urpayment.rem2 = char(d_tax). */
             release jl. release urpayment.
             run trxsts(v-jh, 6, output rcode, output rdes).
             /*if rcode ne 0 then do:  end.*/
             if DoHold = True then do: run tdaremholda(aaa.aaa). end.
             if avail urdpinfo and urdpinfo.rem1 = "1" then do:
                if d_tax > 0 then do:
                   find last cif where cif.cif = aaa.cif no-lock no-error.
                   /*vparam = string(d_tax) + vdel + aaa.aaa + vdel + string("15% подоходный налог, " + cif.name + " " + cif.jss) + vdel + "".*/
                   v-jh = 0.
                   /* Удержание 15 % налога */
                   if cif.geo = '022' and cif.type = 'B' then do:
                      v-nlg = "".
                      find last bnlg-sysc where bnlg-sysc.sysc = "nlg022"  no-lock no-error.
                      if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                      if aaa.crc <> 1 then do:
                         vparam = string(d_tax)
                              + vdel + aaa.aaa
                              + vdel + string(getConvGL(aaa.crc,"C"))
                              + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin)
                              + vdel + v-nlg
                              + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin).
                         run trxgen("vnb0083", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      end. else do:
                         vparam = string(d_tax) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel + string(v-nlg) + vdel +
                                  string("15% подоходный налог, " + cif.name + " " + cif.bin) + vdel + "390".

                         run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      end. /*aaa.crc <> 1*/
                   end. else do:
                      v-nlg = "".
                      find last bnlg-sysc where bnlg-sysc.sysc = "nlg"  no-lock no-error.
                      if avail bnlg-sysc then v-nlg = bnlg-sysc.chval.
                      if aaa.crc <> 1 then do:
                         /*run trxgen("vnb0024", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).*/
                         vparam = string(d_tax)
                              + vdel + aaa.aaa
                              + vdel + string(getConvGL(aaa.crc,"C"))
                              + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin)
                              + vdel + v-nlg
                              + vdel + string("15% подоходный налог, " + cif.name + " " + cif.bin).
                         run trxgen("vnb0083", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      end. else do:
                         vparam = string(d_tax) + vdel + string(aaa.crc) + vdel +  aaa.aaa + vdel +  string(v-nlg) + vdel +
                                  string("15% подоходный налог, " + cif.name + " " + cif.bin) + vdel + "390".
                         run trxgen("uni0113", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      end. /*aaa.crc <> 1*/
                   end. /* cif.geo = '022'*/

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
             end. /* avail urdpinfo and urdpinfo.rem1 = "1"*/
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






