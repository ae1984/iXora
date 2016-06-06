/* incplat1.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по оплате ИР
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26/07/2010 galina
 * BASES
        BANK TXB
 * CHANGES
        15.08.2011 ruslan - добавил столбец incregdt
*/

def shared var v-dt1 as date.
def shared var v-dt2 as date.
def shared temp-table t-incpart
    field incdt as date
    field incnum as char
    field incregdt as date
    field incsum as deci
    field clname as char
    field psum as deci
    field pdt as date
    field ostsum as deci /*на текущую дату*/
    field bank as char
    field sts as char
    index idx is primary bank incnum.

def buffer b-aaar for txb.aaar.
def var v-bank as char.

find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if not avail txb.sysc or trim(txb.sysc.chval) = '' then do:
    message "" view-as alert-box title "".
    return.
end.
v-bank = txb.sysc.chval.

for each txb.aaar where date(txb.aaar.a6) >= v-dt1 and date(txb.aaar.a6) <= v-dt2 /*and aaar.a4 <> "1"*/ no-lock:
    find first txb.aas where txb.aas.aaa = txb.aaar.a5 and txb.aas.fnum = txb.aaar.a2 no-lock no-error.
    if not avail txb.aas then do:
        find first txb.aas_his where txb.aas_his.aaa = txb.aaar.a5 and txb.aas_his.fnum = txb.aaar.a2 and txb.aas_his.chgoper = 'A' no-lock no-error.
        if not avail txb.aas_his then next.
    end.

    find first txb.aaa where txb.aaa.aaa = txb.aaar.a5 no-lock no-error.
    if not avail txb.aaa then next.
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if not avail txb.cif then next.

    create t-incpart.
    assign t-incpart.bank = v-bank
           t-incpart.pdt = date(txb.aaar.a6)
           t-incpart.psum = deci(txb.aaar.a3)
           t-incpart.incnum = txb.aaar.a2
           t-incpart.clname = txb.cif.prefix + ' ' + trim(txb.cif.name).
           if txb.aaar.a4 = '1' then t-incpart.sts = 'Оплачено'.
           else t-incpart.sts = 'Сформировано'.
    find first txb.aas where txb.aas.aaa = txb.aaar.a5 and txb.aas.fnum = txb.aaar.a2 no-lock no-error.
    if avail txb.aas then do:
        assign t-incpart.ostsum = deci(txb.aas.docprim)
               t-incpart.incdt = txb.aas.docdat
               t-incpart.incregdt = txb.aas.regdt
               t-incpart.incsum = txb.aas.fsum.
    end.
    else do:
        find last txb.aas_his where txb.aas_his.aaa = txb.aaar.a5 and txb.aas_his.fnum = txb.aaar.a2 and txb.aas_his.chgoper = 'A' no-lock no-error.
        if avail txb.aas_his then
            assign t-incpart.incdt = txb.aas_his.docdat
                   t-incpart.incregdt = txb.aas_his.regdt
                   t-incpart.incsum = txb.aas_his.fsum.
    end.
end.