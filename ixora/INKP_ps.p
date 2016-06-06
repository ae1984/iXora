/* INKP_ps.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Пункт меню
 * AUTHOR
        17/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        27/11/2008 alex - добавил обработку принятых отзывов
        10/06/2009 galina - добавила обработку ОПВ и СО
        26.06.2009 galina - заполняем поле Банк бенефициара и Примечание для ОПВ и СО
                            убрала лишнюю строку
        12/11/2009 galina - в теме собщения добавила пробел перед городом
        28/10/2010 madiyar - 780300 -> 830300
        02/06/2011 evseev - переход на ИИН/БИН
        09/09/2011 evseev - исправил проблему подтягивания города из cmp
        24/11/2011 evseev - ТЗ-1208 отправка уведомлений
        28/11/2011 evseev - ТЗ-1208 отправка уведомлений менеджеру
        29/11/2011 evseev - повтор. ТЗ-1201 внесение изменений в назначение платежа при оплате ИР
        12/12/2011 evseev - логирование
        13/12/2011 evseev - изменение в подтягивание города из cmp.
        15/12/2011 evseev - изменение в подтягивание города из cmp.
        28/04/2012 evseev - логирование значения aaa.hbal
        20.06.2012 evseev - отструктурировал код. добавил mn
        27.06.2012 evseev - ТЗ-1233
        17.09.2012 evseev - ТЗ-1445
        13.03.2013 evseev - tz-1759
*/
{chbin.i}

def buffer b-aash for aas_hist.
def buffer b-ofc for ofc.
def buffer b-inc100 for inc100.

def shared var g-today as date.
def shared var g-ofc as char.

def var s-vcourbank as char no-undo.
def var v-usrglacc as char no-undo.
def var v-jh like jh.jh no-undo.
def var vparam2 as char no-undo.
def var rcode as inte no-undo.
def var rdes as char no-undo.
def var vdel as char initial "^" no-undo.
def var v-ofc1 as char no-undo.
def var s-aaa like aaa.aaa no-undo.
def var v-dep like ofchis.depart no-undo.
def var op_kod as char format "x(1)" no-undo.
def var v-maillist as char no-undo.
def var v-mailmessage as char.
def var v-mailmessage2 as char.
def var v-mailmessage3 as char.
def var v-mail as char no-undo.
def var i as integer no-undo.
def var v-city as char.

{aas2his.i &db = "bank"}

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   run savelog( "inkps", "INKP_ps: There is no record OURBNK in bank.sysc file!").
   return.
end.

s-vcourbank = trim(sysc.chval).

run inksts.

v-mailmessage = ''.
v-mailmessage2 = ''.
v-mailmessage3 = ''.

for each inc100 where inc100.bank eq s-vcourbank and inc100.mnu eq "pay" and inc100.stat eq 1 and inc100.stat2 = ""  no-lock:
    do transaction on error undo, return:
        find first aaa where aaa.aaa eq inc100.iik exclusive-lock no-error.
        find first cif where cif.cif eq aaa.cif no-lock no-error.
        create aas.
        find last b-aash where b-aash.aaa = aaa.aaa and b-aash.ln <> 7777777  use-index aaaln no-lock no-error.
        if available b-aash then aas.ln = b-aash.ln + 1. else aas.ln = 1.
        aas.aaa = aaa.aaa.
        aas.regdt = g-today.
        aas.docdat = inc100.dtz.
        if v-bin then aas.nkbin = inc100.nkbin. else aas.dpname = inc100.dpname. /* РНН НК */
        aas.bnf = inc100.bnf. /* Название НК */
        aas.docnum = string(inc100.num).
        aas.knp = fill('0', 3 - length(string(inc100.knp))) + string(inc100.knp).
        aas.chkamt = 100000000000.00 . /* блокируем счет */
        if inc100.vo = '07' or inc100.vo = '09' then do:
           aas.sta = 9.
           aas.kbk = "".
           aas.bicben = inc100.reschar[3].
           aas.iikben = inc100.reschar[2].
           aas.bnfname = inc100.bnf.
           aas.mn = "70000".
           if v-bin then aas.binben = inc100.nkbin. else aas.rnnben = inc100.dpname.
           find first bankl where bankl.bank = inc100.reschar[3] no-lock no-error.
           if avail bankl then aas.bankben = bankl.name.
           case inc100.knp:
                when 10 then do: aas.mn = "71000". aas.payee = 'Задолженность по обяз. пенс. платежам.'. end.
                when 12 then do: aas.mn = "72000". aas.payee = 'Задолженность по обяз. соц. платежам'. end.
                when 19 then do: aas.mn = "73000". aas.payee = 'Пеня по обяз. пенс. платежам'. end.
                when 17 then do: aas.mn = "74000". aas.payee = 'Пеня по обяз. соц. платежам'. end.
           end.
        end. else do:
          aas.sta = 4.
          aas.kbk = string(inc100.kbk).
        end.
        find first budcodes where budcodes.code eq integer(aas.kbk) no-lock no-error.
        if   lookup(aas.knp,'912,915,918,922,925,928,932,935,938,942,945,948,952,955,958,965,966,967,968,982,985,988,992') > 0 and avail budcodes then do:
            aas.mn = "82000".
            aas.payee = 'Пеня по ' + budcodes.name.
        end. else if lookup(aas.knp,'913,916,919,923,926,929,933,936,939,943,946,949,953,956,959,983,986,989,993,995') > 0 and avail budcodes then do:
            aas.mn = "83000".
            aas.payee = 'Штраф ' + budcodes.name.
        end. else if avail budcodes then do:
            aas.mn = "81000".
            aas.payee = budcodes.name.
        end.
        aas.who = g-ofc.
        aas.fsum  = inc100.sum.
        aas.docnum = inc100.vo.
        aas.fnum = string(inc100.num).
        aas.docprim = string(inc100.sum).
        aas.irsts = "не оплачено".
        aas.activ = True.
        aas.contr = False.
        aas.tim   = time.
        aas.whn   = g-today.
        aas.who   = g-ofc.
        aas.sic   = 'HB'.
        aas.rgref = inc100.rgref.
        s-aaa = aaa.aaa.
        if avail aaa then do:
           run savelog("aaahbal", "INKP_ps ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
           aaa.hbal = aaa.hbal + aas.chkamt.
        end.
        find current aaa no-lock.
        aas.cif = cif.cif.

        if lookup (aaa.lgr , "138,139,140,143,144,145") > 0 then do:
           run mail("DPC@fortebank.com", "METROCOMBANK <abpk@fortebank.com>", "Прием инкассовых распоряжений ",
               inc100.filename + " ИР=" + string(inc100.num) + " БИН=" + inc100.bin + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp)
               , "1", "", "").
        end.


        if inc100.VO = '07' or inc100.VO = '09' then do:
           if v-mailmessage2 <> '' then v-mailmessage2 = v-mailmessage2 + "\n\n".
           if v-mailmessage3 <> '' then v-mailmessage3 = v-mailmessage3 + "\n\n".
           if v-bin then v-mailmessage2 = v-mailmessage2 + inc100.filename + " ИР=" + string(inc100.num) + " БИН=" + inc100.bin + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp).
           else v-mailmessage2 = v-mailmessage2 + inc100.filename + " ИР=" + string(inc100.num) + " РНН=" + inc100.jss + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp).
           if aaa.cr[1] - aaa.dr[1] > 0 then do:
               if v-bin then v-mailmessage3 = v-mailmessage3 + inc100.filename + " ИР=" + string(inc100.num) + " БИН=" + inc100.bin + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp).
               else v-mailmessage3 = v-mailmessage3 + inc100.filename + " ИР=" + string(inc100.num) + " РНН=" + inc100.jss + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp).
           end.
        end.
        if inc100.VO <> '07' and inc100.VO <> '09' then do:
           if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
           if v-mailmessage3 <> '' then v-mailmessage3 = v-mailmessage3 + "\n\n".
           if v-bin then v-mailmessage = v-mailmessage + inc100.filename + " ИР=" + string(inc100.num) + " БИН=" + inc100.bin + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp) + " КБК=" + string(inc100.kbk).
           else v-mailmessage = v-mailmessage + inc100.filename + " ИР=" + string(inc100.num) + " РНН=" + inc100.jss + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp) + " КБК=" + string(inc100.kbk).
           if aaa.cr[1] - aaa.dr[1] > 0 then do:
               if v-bin then v-mailmessage3 = v-mailmessage3 + inc100.filename + " ИР=" + string(inc100.num) + " БИН=" + inc100.bin + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp) + " КБК=" + string(inc100.kbk).
               else v-mailmessage3 = v-mailmessage3 + inc100.filename + " ИР=" + string(inc100.num) + " РНН=" + inc100.jss + " счет=" + inc100.iik + " sum=" + string(inc100.sum) + " КНП=" + string(inc100.knp) + " КБК=" + string(inc100.kbk).
           end.
        end.
        v-usrglacc = "".
        if s-vcourbank = "txb00" then do:
            find last vnebal where vnebal.usr = substr(cif.fname, 1, 8) no-lock no-error.
            if avail vnebal then do:
                v-usrglacc = vnebal.gl.
            end. else do:
                find last ofchis where ofchis.ofc = substr(cif.fname,1,8) and ofchis.regdt <= g-today use-index ofchis no-lock no-error.
                if not avail ofchis then do:
                    find first ofchis where ofchis.ofc = substr(cif.fname,1,8) and ofchis.regdt >= g-today use-index ofchis no-lock no-error.
                    if not avail ofchis then v-dep = 1. /*Если истории по пользователю не оказалось, то говорим, что он работает в Центральном офисе*/
                    else v-dep = ofchis.depart.
                end. else v-dep = ofchis.depart.
                v-ofc1 =  string(v-dep).
                find last vnebal where vnebal.usr = v-ofc1  no-lock no-error.
                if avail vnebal then do:
                    v-usrglacc = vnebal.gl.
                end.
            end.
        end. else do:
            find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
            if avail vnebal then do:
                v-usrglacc = vnebal.gl.
            end.
        end.
        /* Блокируем сумму и производим транзакцию на внебаланс */
        if deci(aas.docprim) > 0 and v-usrglacc <> "" then do:
            v-jh = 0.
            vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + /* "учет суммы И.Р. " + */ "Налоговое отчисление, счет " + aaa.aaa + vdel + "" + vdel.
            run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
            if rcode ne 0 then run savelog("inkps", "INKP_ps: [err]Ошибка генерации проводки, rcode=" + string(rcode) + ", rdes=" + rdes + ", ref=" + inc100.ref).
            else do:
                find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
                if avail b-inc100 then do:
                    b-inc100.mnu = "blk".
                    find current b-inc100 no-lock.
                end.
                else run savelog("inkps", "INKP_ps: [err]Статус Blk не проставился!" + " ref=" + inc100.ref).
                run savelog("inkps", "INKP_ps: Учет на внебалансе, trx #" + string(v-jh) + ", ref=" + inc100.ref).
            end.
        end. else do:
            if deci(aas.docprim) <= 0 then run savelog("inkps", "INKP_ps: [err]Невозможно зачислить сумму 0.0 на внебаланс, ref=" + inc100.ref).
            if v-usrglacc = "" then run savelog("inkps", "INKP_ps: [err]Не удалось найти счет Г/К для зачисления на внебаланс! Mенеджер - " + substr(cif.fname, 1, 8) + ", ref=" + inc100.ref).
            find first b-inc100 where b-inc100.ref = inc100.ref exclusive-lock no-error.
            if avail b-inc100 then do:
                b-inc100.mnu = "err".
                find current b-inc100 no-lock.
            end.
        end.
        find first b-ofc where b-ofc.ofc = g-ofc no-lock.
        aas.point = b-ofc.regno / 1000 - 0.5.
        aas.depart = b-ofc.regno MODULO 1000.
        op_kod = 'A'.
        run savelog( "INKP_ps", aas.aaa + ":" + aas.payee).
        RUN aas2his.
    end. /* transaction */
end.


if v-mailmessage <> '' then do:
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               v-mailmessage = v-city + "\n\n" + v-mailmessage.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием инкассовых распоряжений " + v-city, v-mailmessage, "1", "", "").
            end.
        end.
    end.
end.

if v-mailmessage2 <> '' then do:
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               v-mailmessage2 = v-city + "\n\n" + v-mailmessage2.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием инкассовых распоряжений  по ОПВ и СО " + v-city, v-mailmessage2, "1", "", "").
            end.
        end.
    end.
end.

if v-mailmessage3 <> '' then do:
    v-mailmessage3 = v-city + "\n\n" + v-mailmessage3.
    v-mail = "".
    find first pksysc where pksysc.sysc = "inksm" no-lock no-error.
    if avail pksysc then do:
       v-mail = pksysc.chval.
    end.
    if v-mail <> '' then do:
       run mail(v-mail, "METROCOMBANK <abpk@fortebank.com>", "Прием инкассовых распоряжений/платежных требований-поручений на счета клиентов с остатком более 0",
                v-mailmessage3, "1", "", "").
    end.
    run mail("id00787@fortebank.com", "METROCOMBANK <abpk@fortebank.com>", "Прием инкассовых распоряжений/платежных требований-поручений на счета клиентов с остатком более 0",
            v-mailmessage3, "1", "", "").
end.

/* Обработка принятых отзывов */
run inkrecblk.