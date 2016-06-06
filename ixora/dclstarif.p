/* dcls17.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Запись в таблицу долгов всех комиссий за закрываемый день, потом все будет сниматься
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        24.01.2008 id00004
 * CHANGES
        30.10.2013 evseev tz1798
        01/11/2013 Luiza - ТЗ 1932 тарифы по экспресс кредитам
        25/11/2013 Luiza - ТЗ 2181 поиск по таблице comon
*/


{global.i}
{comm-txb.i}
{curs_conv.i}
{dclstarif.i}

def var v-TXB               as char. /*ALL - для всех TXB00,TXB01 и т.д признак филиала */
def var v-jur               as char. /*YES - юридическое лицо NO-физическое лицо        */
def var v-pout              as char. /*YES - внешний платеж    NO-внутренний платеж     */
def var v-vcrc              as char. /*YES - тенге  NO-валюта                           */
def var v-scan              as char. /*YES - сканированный платеж  NO-обычный платеж    */
def var v-debet             as char. /*YES - дебет  NO-кредит                           */
def var v-dt2_more_gtoday   as char. /*YES/NO                                           */
def var v-dt2_eq_gtoday     as char. /*YES/NO                                           */
def var v-do5000000         as char.
def var v-t13_30            as char.
def var v-t14_00            as char.
def var v-rbankTXB          as char.
def var v-dt2_eq_dt1        as char. /*YES/NO                                           */
def var v-urgency           as char.
def var v-dt2_more_dt1      as char.



def buffer bjl   for jl.
def buffer cjl   for jl.
def var v-dict   as char initial "flg90" no-undo.
def var v-dict2  as char initial "stmt" no-undo.
def var v-aaa    as char no-undo.
def var v-branch as char no-undo.
def var v-arp    as char no-undo.
def var v-arplg  as char no-undo.
def var v-err    as log no-undo.
def var v-payout as logical no-undo.
def var v-crctrf like crc.crc no-undo.
def var tmin1    as dec decimals 10  no-undo.
def var tmax1    as dec decimals 10  no-undo.
def var v-amt    as dec no-undo.
def var v-f      as log no-undo.
def var v-cbank  as char no-undo.
def var tproc    like tarif2.proc  no-undo.
def var pakal    as char no-undo.
def var netgro   as decimal.

def var ijh-dt1 as date init today.
def var ijh-rtim as integer.
def var v-is-urgency as logical no-undo.
def var v-jurfiz as char no-undo.
def var v-expcred as logical no-undo.

v-cbank = comm-txb ().

netgro = 5000000.
find sysc where sysc.sysc = "NETGRO" no-lock no-error.
if avail sysc then netgro = sysc.deval.

find sysc where sysc = "ourbnk" no-error.
if avail sysc then v-branch = sysc.chval.   /*TXB00, TXB01 и т.д.*/

find sysc where sysc  = "arpdt" no-error.   /* Счет-искл (ARP) для плат карт */
if available sysc then v-arp = sysc.chval.
find sysc where sysc = "aaact" no-error.    /* Счет-искл (CIF) для плат карт  */
if available sysc then v-aaa = sysc.chval.

find sysc where sysc  = "arplg" no-error .  /* Счет-искл (ARP) для плат карт на филиалах */
if available sysc then v-arplg = sysc.chval.
   else v-arplg = ''.


def buffer bb-sysc for sysc.
find last bb-sysc where bb-sysc.sysc = "JUR" no-lock no-error.


run savelog('dclstarif','95. ').
output to value("dclstarif" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".log").

/*Клиринг*/
for each jl where jl.jdt eq g-today and jl.sub eq "CIF" and jl.lev eq 1 no-lock use-index jdtlevsub:
    v-f = yes.

    v-TXB = "".
    v-jur = "".
    v-pout = "".
    v-vcrc = "".
    v-scan = "".
    v-debet = "".
    v-dt2_more_gtoday = "".
    v-dt2_eq_gtoday = "".
    v-do5000000 = "".
    v-t13_30 = "".
    v-t14_00 = "".
    v-rbankTXB = "".

    if lookup(string(jl.gl),v-aaa) > 0 then do:
        find bjl where bjl.jh = jl.jh and bjl.sub = "ARP" and bjl.lev = 1  and lookup(string(bjl.gl),v-arp) > 0 and bjl.dc = (if jl.dc = "c" then "d" else "c")  no-lock no-error.
        if available bjl then v-f = no.
        else if v-cbank ne 'TXB00' then do: /* если счет принадлежит к счету искл. кл. и перевод клиенту осущ-ся на филиале с льгот. транз. счета платежных карт Ц.О. */
            find remtrz where remtrz.rdt <= jl.jdt and remtrz.sbank = 'TXB00' and lookup(remtrz.sacc,v-arplg) > 0 and remtrz.jh2 = jl.jh  no-lock no-error.
            if avail remtrz then v-f = no.
        end.
    end.

    if jl.rem[1] begins "Storno" then v-f = no.

    find trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.trxt = 0 and trxcods.codfr = v-dict no-lock no-error.
    if available trxcods then do:
       if trxcods.code eq "no" then v-f = no.
    end.

    find trxcods where trxcods.trxh eq jl.jh and trxcods.trxln eq jl.ln and trxcods.trxt eq 0 and trxcods.codfr eq v-dict2 no-lock no-error.
    if available trxcods then  do:
       if trxcods.code begins "chg" then v-f = no.
    end.
    if jl.rem[1] begins "Storno" or jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then v-f = no.
    if not v-f then next.

    find jh where jh.jh = jl.jh no-lock no-error.
    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.

    find aaa where aaa.aaa = jl.acc no-lock no-error. /*а есть ли вообще такой счет?*/
    if not available aaa then next.
    if aaa.cif = "A12004" then next.
    if lookup(aaa.lgr, bb-sysc.chval) <> 0 then next.
    v-expcred = no.
    if aaa.lgr = "250" then v-expcred = yes.

    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
    if not available sub-cod or sub-cod.ccode = "msc" then do:
       put unformatted  aaa.aaa "  " jl.acc " Не проставлен признак Физ/Юр Комиссия не списана" skip.
       next.
    end.

    if sub-cod.ccode = "0" then v-jur = "yes". else v-jur   = "no".

    find sub-cod where sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" and sub-cod.acc = aaa.aaa no-lock no-error. /*льготный счет ?*/
    if available sub-cod and sub-cod.ccode = "no" then next. /*счет льготный, выходим*/

    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
    v-payout = (avail remtrz and remtrz.ptype <> "M").  /* YES = платеж внешний */
    v-err = no.
    find first comon where comon.aaa = aaa.aaa no-lock no-error.
    if available comon then do:
        create wt.
        wt.cif = aaa.cif.
        wt.aaac = comon.aaac.
        if available remtrz then wt.plat = remtrz.ref.
    end.
    else do:
        find wt where wt.cif = aaa.cif no-error.
        if not available wt then do: create wt. wt.cif = aaa.cif. end.
    end.
    if jl.dc = "D" then v-debet  = "yes". else v-debet = "no".
    if jl.crc = 1  then v-vcrc   = "1".   else v-vcrc  = "val".
    if v-payout    then v-pout   = "yes". else v-pout  = "no".

    if avail remtrz then do:
       find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "urgency" no-lock no-error.
       if avail sub-cod then do:
          if sub-cod.ccode = 's' then v-urgency = "yes". else v-urgency = "no".
       end. else v-urgency = "no".
    end.

    if avail remtrz and remtrz.source = 'SCN'     then v-scan = "yes". else v-scan = "no".
    if avail remtrz and remtrz.valdt2 > g-today   then v-dt2_more_gtoday = "yes". else v-dt2_more_gtoday = "no".
    if avail remtrz and remtrz.valdt2 = g-today   then v-dt2_eq_gtoday = "yes".   else v-dt2_eq_gtoday   = "no".
    if avail remtrz and remtrz.rbank begins 'TXB' then v-rbankTXB = "yes". else v-rbankTXB = "no" .
    if avail remtrz and remtrz.rbank begins 'TXB' then next.

    if avail remtrz and (remtrz.rtim <= 13 * 3600 + 30 * 60) then v-t13_30 = "yes". else v-t13_30 = "no".
    if avail remtrz and (remtrz.rtim <= 14 * 3600) then v-t14_00 = "yes". else v-t14_00 = "no".
    if avail remtrz and remtrz.payment >= netgro then v-do5000000 = "no". else v-do5000000 = "yes".

    if not avail remtrz then do:
       v-pout = "-".
       v-scan = "-".
       v-dt2_more_gtoday = "-".
       v-dt2_eq_gtoday = "-".
       v-rbankTXB = "-".
       v-t13_30 = "-".
       v-t14_00 = "-".
       v-do5000000 = "-".
       v-urgency = "-".
    end.

    for each Klir_tab no-lock:
         if ((Klir_tab.TXB = "--") or (Klir_tab.TXB <> "--" and Klir_tab.TXB = v-TXB and v-TXB <> "-")) and
            ((Klir_tab.urgency = "--") or (Klir_tab.urgency <> "--" and Klir_tab.urgency = v-urgency and v-urgency <> "-")) and
            ((Klir_tab.jur = "--") or (Klir_tab.jur <> "--" and Klir_tab.jur = v-jur and v-jur <> "-")) and
            ((Klir_tab.payout = "--") or (Klir_tab.payout <> "--" and Klir_tab.payout = v-pout and v-pout <> "-")) and
            ((Klir_tab.vcrc = "--") or (Klir_tab.vcrc <> "--" and Klir_tab.vcrc = v-vcrc and v-vcrc <> "-")) and
            ((Klir_tab.scan = "--") or (Klir_tab.scan <> "--" and Klir_tab.scan = v-scan and v-scan <> "-")) and
            ((Klir_tab.debet = "--") or (Klir_tab.debet <> "--" and Klir_tab.debet = v-debet and v-debet <> "-")) and
            ((Klir_tab.dt2_more_gtoday = "--") or (Klir_tab.dt2_more_gtoday <> "--" and Klir_tab.dt2_more_gtoday = v-dt2_more_gtoday and v-dt2_more_gtoday <> "-")) and
            ((Klir_tab.dt2_eq_gtoday = "--") or (Klir_tab.dt2_eq_gtoday <> "--" and Klir_tab.dt2_eq_gtoday = v-dt2_eq_gtoday and v-dt2_eq_gtoday <> "-")) and
            ((Klir_tab.do_5000000 = "--") or (Klir_tab.do_5000000 <> "--" and Klir_tab.do_5000000 = v-do5000000 and v-do5000000 <> "-")) and
            ((Klir_tab.t13_30 = "--") or (Klir_tab.t13_30 <> "--" and Klir_tab.t13_30 = v-t13_30 and v-t13_30 <> "-")) and
            ((Klir_tab.t14_00 = "--") or (Klir_tab.t14_00 <> "--" and Klir_tab.t14_00 = v-t14_00 and v-t14_00 <> "-")) and
            ((Klir_tab.rbankTXB = "--") or (Klir_tab.rbankTXB <> "--" and Klir_tab.rbankTXB = v-rbankTXB and v-rbankTXB <> "-")) and
             Klir_tab.expcred = v-expcred then do:

            if avail remtrz and remtrz.source = "IBH" then next.

            find current remtrz exclusive-lock no-error.
            if avail remtrz then do:
               run savelog('dclstarif','214. ' + remtrz.remtrz + ' ' + Klir_tab.tarifkod).
               if remtrz.tarif <> "" then remtrz.tarif = remtrz.tarif + ",".
               remtrz.tarif = remtrz.tarif + Klir_tab.tarifkod.
               find current remtrz no-lock no-error.
            end.

            v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
            run perev0(aaa.aaa, Klir_tab.tarifkod, aaa.cif, output v-crctrf, output tproc, output tmin1, output tmax1, output v-amt, output pakal, output v-err).
            if not v-err then do:
               if v-amt = 0 and tproc <> 0 then  do:
                  v-amt = (jl.dam * tproc) / 100.
                  if v-amt < tmin1 then  v-amt = tmin1. else
                  if v-amt > tmax1 and tmax1 > 0 then v-amt = tmax1.
               end.
               if v-amt <> 0 then do:
                  put unformatted  wt.cif  "  "  jl.acc " коммисия по коду " string(Klir_tab.tarifkod) " = " string(v-amt) " " if avail remtrz then remtrz.remtrz  else " "  skip.
                  wt.cnt[Klir_tab.i]   = wt.cnt[Klir_tab.i] + 1.
                  wt.sum[Klir_tab.i]   = wt.sum[Klir_tab.i] + v-amt.
                  wt.pakal[Klir_tab.i] = pakal.
                  wt.comis[Klir_tab.i] = Klir_tab.tarifkod.
                  wt.crc[Klir_tab.i]   = v-crctrf.
              end.
            end.
         end.  else next.
    end.
end.

/* Интернет платежи */
for each jl where jl.jdt eq g-today and jl.sub eq "CIF" and jl.lev eq 1 no-lock use-index jdtlevsub:
    v-TXB = "". v-urgency = "". v-jur = "". v-t13_30 = "".  v-do5000000 = "".  v-scan = "".  v-dt2_more_gtoday = "".   v-dt2_eq_gtoday = "". v-dt2_eq_dt1 = "". v-dt2_more_dt1 = "". v-t14_00 = "". v-rbankTXB = "".
    v-f = yes.
    find jh where jh.jh = jl.jh no-lock no-error.
    find first remtrz where remtrz.remtrz = jh.ref and remtrz.jh1 = jh.jh no-lock no-error.
    if not avail  remtrz then next.

    /* Только интернет платежи */
    if remtrz.source <> 'IBH' then next.

    ijh-dt1 = jh.jdt no-error.
    if remtrz.ptype = "M" then next.

    /* Комиссия с палтежей зарплатных проектов снимается в другом месте */
    if remtrz.rcvinfo[1] = "\/CRDS\/" then next.
    v-payout = remtrz.ptype <> "M".  /* YES = платеж внешний */

    /* tsoy 02.06.05 Определяем срочность платежа */
    v-is-urgency = false.

    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "urgency" no-lock no-error.
    if avail sub-cod then do:
        if sub-cod.ccode = 's' then v-urgency = "yes". else v-urgency = "no".
    end. else  v-urgency = "no".

    if lookup(string(jl.gl),v-aaa) > 0 then do: /*если счет принадлежит к счету исключения для клиентов и снятия идут с льготного АРП-счета - например, карточники переводы делают коммерсантам */
        find bjl where bjl.jh = jl.jh and bjl.sub = "ARP" and bjl.lev = 1  and lookup(string(bjl.gl),v-arp) > 0 and bjl.dc = (if jl.dc = "c" then "d" else "c")  no-lock no-error.
        if available bjl then v-f = no.
    end.

    find trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.trxt = 0 and trxcods.codfr = v-dict no-lock no-error.
    if available trxcods then do:
       if trxcods.code eq "no" then v-f = no.
    end.
    find trxcods where trxcods.trxh eq jl.jh and trxcods.trxln eq jl.ln and trxcods.trxt eq 0 and trxcods.codfr eq v-dict2 no-lock no-error.
    if available trxcods then do:
       if trxcods.code begins "chg" then v-f = no.
    end.

    if jl.rem[1] begins "Storno" or jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then v-f = no.
    if not v-f then next.
    find aaa where aaa.aaa = jl.acc no-lock no-error.
    if not available aaa then next. /*если не найден то переходим на следующую проводку */
    if aaa.crc <> 1 then next.
    if aaa.cif = "A12004" then next.
    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error. /*if not available sub-cod or sub-cod.ccode <> "0" then next.*/ /*если это не юр лицо то выходим*/
    if not available sub-cod then next.
    if avail sub-cod then do:
       if sub-cod.ccode = "0" then v-jur = "yes". else v-jur   = "no".
    end.

    find sub-cod where sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" and sub-cod.acc = aaa.aaa no-lock no-error. /*льготный счет ?*/
    if available sub-cod and sub-cod.ccode = "no" then next. /*счет льготный, выходим*/

    if avail remtrz and remtrz.rbank begins 'TXB' then next.

    if ijh-dt1 = remtrz.valdt2 then v-dt2_eq_gtoday = "yes".   else v-dt2_eq_gtoday   = "no".
    if remtrz.payment >= netgro  then v-do5000000 = "no". else v-do5000000 = "yes".
    if avail remtrz and (remtrz.rtim <= 14 * 3600 + 30 * 60) then v-t14_00 = "yes". else v-t14_00 = "no".
    find first comon where comon.aaa = aaa.aaa no-lock no-error.
    if available comon then do:
        create wt.
        wt.cif = aaa.cif.
        wt.aaac = comon.aaac.
        wt.aaa = aaa.aaa.
        if available remtrz then wt.plat = remtrz.ref.
    end.
    else do:
        find wt where wt.cif = aaa.cif no-error.
        if not available wt then do:
            create wt.
            wt.cif = aaa.cif.
            wt.aaa = aaa.aaa.
        end.
    end.
    for each Inet no-lock:
          if ((Inet.TXB = "--") or (Inet.TXB <> "--" and Inet.TXB = v-TXB and v-TXB <> "-")) and
             ((Inet.jur = "--") or (Inet.jur <> "--" and Inet.jur = v-jur and v-jur <> "-")) and
             ((Inet.dt2_eq_gtoday = "--") or (Inet.dt2_eq_gtoday <> "--" and Inet.dt2_eq_gtoday = v-dt2_eq_gtoday and v-dt2_eq_gtoday <> "-")) and
             ((Inet.do_5000000 = "--") or (Inet.do_5000000 <> "--" and Inet.do_5000000 = v-do5000000 and v-do5000000 <> "-")) and
             ((Inet.urgency = "--") or (Inet.urgency <> "--" and Inet.urgency = v-urgency and v-urgency <> "-")) and
             ((Inet.t14_00 = "--") or (Inet.t14_00 <> "--" and Inet.t14_00 = v-t14_00 and v-t14_00 <> "-")) and
             ((Inet.rbankTXB = "--") or (Inet.rbankTXB <> "--" and Inet.rbankTXB = v-rbankTXB and v-rbankTXB <> "-")) then do:

             find current remtrz exclusive-lock no-error.
             if avail remtrz then do:
                run savelog('dclstarif','321. ' + remtrz.remtrz + ' ' + Inet.tarifkod).
                if remtrz.tarif <> "" then remtrz.tarif = remtrz.tarif + ",".
                remtrz.tarif = remtrz.tarif + Inet.tarifkod.
                find current remtrz no-lock no-error.
             end.

             v-crctrf = 0. tmin1 = 0. tmax1 = 0. v-amt = 0. tproc = 0.
             run perev0(aaa.aaa, Inet.tarifkod, aaa.cif, output v-crctrf, output tproc, output tmin1, output tmax1, output v-amt, output pakal, output v-err).
             if not v-err then do:
                if v-amt = 0 and tproc <> 0 then do:
                   v-amt = (remtrz.payment * tproc) / 100.
                   if v-amt < tmin1 then  v-amt = tmin1. else
                   if v-amt > tmax1 and tmax1 > 0 then v-amt = tmax1.
                end.
                if v-amt <> 0 then do:
                   put unformatted  wt.cif  "  "  aaa.aaa " коммисия по коду " string(Inet.tarifkod) " = " string(v-amt) " " if avail remtrz then remtrz.remtrz  else " "  skip.
                   wt.cnt[Inet.i]   = wt.cnt[Inet.i] + 1.
                   wt.sum[Inet.i]   = wt.sum[Inet.i] + v-amt.
                   wt.pakal[Inet.i] = pakal.
                   wt.comis[Inet.i] = Inet.tarifkod.
                   wt.crc[Inet.i]   = v-crctrf.
                end.
             end.
          end. else next.
    end.
end. /* jl */
output close.

/*Записываем все необходимые тарифы в таблицу bxcif*/

def var i as integer.
for each wt :
    do i = 1 to 52:
       if wt.cnt[i] > 0 and wt.sum[i] > 0 then do:
       create bxcif.
       assign bxcif.cif    = wt.cif
              bxcif.whn    = g-today
              bxcif.amount = wt.sum[i]
              bxcif.crc    = wt.crc[i]
              bxcif.rem    = wt.pakal[i] + " за " + string(g-today) + ". Количество " + trim(string((wt.cnt[i]),">>>>>"))
              bxcif.type   = wt.comis[i].
              if wt.aaac <> "" then do: bxcif.aaa = wt.aaac. bxcif.pref = yes. bxcif.rem = bxcif.rem + " за плат поруч. № " + trim(wt.plat). end.
       end.
    end.
end.

run savelog('dclstarif','366. ').