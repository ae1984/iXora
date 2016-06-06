/* lnriskrep1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет для рисковиков
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
        20/01/2011 madiyar
 * CHANGES
        03/03/2011 madiyar - изменения по ТЗ 924
        04/03/2011 madiyar - перекомпиляция
        14/03/2011 madiyar - изменил условие по turnoverDecrease
        18/05/2011 madiyar - уменьшение оборотов компании, дату первичного и текущего анализа и проверку решений КК берем для КЛ, если это транш в рамках КЛ
        19/05/2011 madiyar - добавил дни текущей просрочки, количество просрочек, изменения по мониторингам
        26/05/2011 madiyar - добавил ухудшение фин. состояния (wrk.fsDecline)
        14/10/2011 kapar - изменения по ТЗ 1175
        11/03/2012 dmitriy - добавил столбцы: Пул МСФО, Провизии МСФО, Штраф, Общая сумма залога недвиж.имущ., Общая сумма залога движ.имущ
                           - неправильно считались провизии АФН, исправил
                           - добавил wrk.grp, не отражалась группа кредита
                           - заменил фамилию риск-менеджера для ЮКО
        09.11.2012 dmitriy - изменил список ответственных риск-менеджеров
        25/02/2013 sayat(id01143) - ТЗ 1696 от 04/02/2013 вывод в отчет отвественного по обеспечению
        07.11.2013 dmitriy - ТЗ 1725, ТЗ 2108.  - добавил столбцы «Количество баллов» и «Финансовое состояние»
                                                - изменил группы кредитов при формировании отчета
*/

def input parameter dt as date no-undo.

def shared var vsel as decimal.
def shared var rates as deci no-undo extent 20.

def shared temp-table wrk no-undo
    field bank as char
    field bankn as char
    field grp as int
    field clGroup as integer
    field cif as char
    field cifn as char
    field lon as char
    field manager as char
    field riskManager as char
    field zalogManager as char

    field turnoverDecrease as deci
    field cushion as deci
    field applicationDate as date
    field lastMonitoring as date
    field fsDecline as char
    field approvalDate as date

    field rdt as date
    field duedt as date
    field prem as deci
    field prov as deci
    field opnamt as deci
    field od as deci
    field prc as deci
    /*
    field zalog as deci
    */
    field zalog as char
    field overdue as deci
    field daysOverdue as integer
    field maxDaysOverdue as integer
    field overdueCount as integer
    field appropriateUseFundsPrc as deci
    field blocks as char
    field isRestructured as char
    field industryEstimation as char
    field industry as char
    field lnObject as char
    field isAffil as char
    field kkres as char
    field err as char
    field poolmsfo as char
    field provmsfo as deci
    field shtraf as deci
    field nedvij as deci
    field dvij as deci
    field mark as int
    field fins as char
    index ind is primary bank cifn.

def var v-lonpool as char.
def var v-provmsfo as deci.
def var v-shtraf as deci.
def var v-nedvij as deci.
def var v-dvij as deci.


function getRiskManager returns char (input v-bank as char).
    def var res as char no-undo.
    res = ''.
    def var v-list as char no-undo.
    v-list = "Оразбаев М.Б.," +       /* HO  */
             "Канимкулова Ж.А.," +    /* akt */
             "Канифатов А.В.," +      /* kos */
             "Досыбаев А.Л.," +       /* trz */
             "Канимкулова Ж.А.," +    /* url */
             "Досыбаев А.Л.," +       /* kar */
             "Смагулова С.Б.," +      /* sem */
             "Канифатов А.В.," +      /* kok */
             "Молдарахимов Т.М.," +   /* ast */
             "Смагулова С.Б.," +      /* pav */
             "Молдарахимов Т.М.," +   /* pet */
             "Таттибеков Б.У.," +     /* atr */
             "Таттибеков Б.У.," +     /* akt */
             "Молдарахимов Т.М.," +   /* zes */
             "Омарова Ж.Т.," +        /* ust */
             "Сауруков А.М.," +       /* chm */
             "Оразбаев М.Б.".         /* alm */
    def var n as integer no-undo init -1.
    n = integer(substring(v-bank,4,2)) no-error.
    if (n <> ?) and (n >= 0) and (n <= 16) then res = entry(n + 1,v-list).
    return res.
end function.

/*
Статус ИР/Специнструкции

S
0  Арест на определенную сумму
3  Наложение ареста на определенную сумму.

P
1  Полное приостановление операций по счету.
2  Приостановление операций за исключением платежей в бюджет.
16 Приостановление операций за исключением пенсионных платежей
17 Приостановление операций за исключением социальных платежей

N
4  Налоговое инкассовое, не оплаченное.
5  Налоговое инкассовое оплачено частично.
6  Налоговое инкассовое оплачено полностью.
8  Налоговое приостановлено.
9  Инкассовое прочее, не оплачено.
15 Инкассовое прочее, оплачено частично.

*/

function getBlocks returns char (input p-aaa as char).
    def var res as char no-undo.
    res = ''.
    find first txb.aaa where txb.aaa.aaa = p-aaa no-lock no-error.
    if avail txb.aaa and txb.aaa.sta <> 'E' and txb.aaa.sta <> 'C' then do:
        find first txb.aas where txb.aas.aaa = p-aaa no-lock no-error.
        if avail txb.aas then do:
            for each txb.aas where txb.aas.aaa = p-aaa no-lock:
                if txb.aas.sta = 0 or txb.aas.sta = 3 then do:
                    if lookup('S',res) = 0 then do:
                        if res <> '' then res = res + ','.
                        res = res + 'S'.
                    end.
                end.
                else
                if txb.aas.sta = 1 or txb.aas.sta = 2 or txb.aas.sta = 16 or txb.aas.sta = 17 then do:
                    if lookup('P',res) = 0 then do:
                        if res <> '' then res = res + ','.
                        res = res + 'P'.
                    end.
                end.
                else
                if txb.aas.sta >= 4 and txb.aas.sta <= 15 then do:
                    if lookup('N',res) = 0 then do:
                        if res <> '' then res = res + ','.
                        res = res + 'N'.
                    end.
                end.
            end.
        end.
    end.
    return res.
end function.


def var s-ourbank as char no-undo.
def var v-bankn as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

if s-ourbank = "txb00" then v-bankn = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankn = entry(2,txb.cmp.addr[1]).
end.

hide message no-pause.
message v-bankn.

def var bilance as deci no-undo.
def var proc as deci no-undo.
def var v-ofcname as char no-undo.
def var v-bal as deci no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var nm as char no-undo.
def var v-ob1 as deci no-undo.
def var v-ob2 as deci no-undo.
def var v-bal7 as deci no-undo.
def buffer b-lon for txb.lon.

for each txb.longrp where lookup(string(txb.longrp.longrp), "10,11,13,14,15,16,21,23,24,25,26,50,53,54,55,56,63,64,65,66,70,80") > 0
/*"20,27,28,60,67,68,70,80,81,82,90,92,95,96"*/

        /*(txb.longrp.des matches '*МСБ*') or
         txb.longrp.longrp = 70 or txb.longrp.longrp = 80 or
         txb.longrp.longrp = 11 or txb.longrp.longrp = 21*/ no-lock:

    for each txb.lon where txb.lon.grp = txb.longrp.longrp no-lock:

        if txb.lon.opnamt <= 0 then next.

        run lonbalcrc_txb('lon',txb.lon.lon,dt,"1,7",no,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,dt,"2,9,4",no,txb.lon.crc,output proc).

        if vsel = 1 then do:
          if bilance + proc <= 0 then next.
        end.
        else do:
          if bilance + proc > 0 then next.
          if lon.gua = 'CL' then next.
        end.

        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

        /*-------- Пул МСФО --------*/
        find last txb.lonpool where txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= dt no-lock no-error.
        if avail txb.lonpool then v-lonpool = txb.lonpool.poolId.
        /*--------------------------*/

        create wrk.
        assign wrk.bank = s-ourbank
               wrk.bankn = v-bankn
               wrk.cif = txb.lon.cif
               wrk.grp = txb.lon.grp
               wrk.cifn = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)
               wrk.lon = txb.lon.lon
               wrk.rdt = txb.lon.rdt
               wrk.duedt = txb.lon.duedt
               wrk.od = bilance * rates[txb.lon.crc]
               wrk.prc = proc * rates[txb.lon.crc]
               wrk.poolmsfo = v-lonpool.

        /* группа */
        find first cclient where cclient.clientId = txb.lon.cif no-lock no-error.
        if avail cclient then wrk.clGroup = cclient.groupId.

        if txb.lon.clmain = '' then find b-lon where rowid(b-lon) = rowid(txb.lon) no-lock.
        else do:
            find first b-lon where b-lon.lon = txb.lon.clmain no-lock no-error.
            if not avail b-lon then find b-lon where rowid(b-lon) = rowid(txb.lon) no-lock.
        end.

        /*
        уменьшение оборотов компании, дату первичного и текущего анализа и проверку решений КК берем для КЛ, если это транш в рамках КЛ,
        в противном случае - для самого кредита, все остальные данные - для самого кредита
        */
        /* уменьшение оборотов компании */
        v-ob1 = 0. v-ob2 = 0.
        find first txb.lnmoncln where txb.lnmoncln.lon = b-lon.lon and txb.lnmoncln.code = "mon1" no-lock no-error.
        if avail txb.lnmoncln then do:
            wrk.applicationDate = txb.lnmoncln.edt.

            wrk.mark = txb.lnmoncln.mark.
            wrk.fins = txb.lnmoncln.fins.

            v-ob1 = txb.lnmoncln.res-deci[1].
            if v-ob1 < 0 then v-ob1 = 0.
        end.
        wrk.lastMonitoring = ?.
        find last txb.lnmoncln where txb.lnmoncln.lon = b-lon.lon and txb.lnmoncln.code = "fin-hoz" and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then do:
            v-ob2 = txb.lnmoncln.res-deci[1].
            wrk.lastMonitoring = txb.lnmoncln.edt.
            wrk.fsDecline = txb.lnmoncln.res-ch[1].
            if v-ob2 < 0 then v-ob2 = 0.

            wrk.mark = txb.lnmoncln.mark.
            wrk.fins = txb.lnmoncln.fins.
        end.
        find last txb.lnmoncln where txb.lnmoncln.lon = b-lon.lon and txb.lnmoncln.code = "extmon" and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then do:
            if wrk.lastMonitoring <= txb.lnmoncln.edt then do:
                v-ob2 = txb.lnmoncln.res-deci[1].
                wrk.lastMonitoring = txb.lnmoncln.edt.
                wrk.fsDecline = txb.lnmoncln.res-ch[1].
                if v-ob2 < 0 then v-ob2 = 0.
            end.
        end.

        if v-ob1 = 0 then do: /* не введены обороты по первичному мониторингу */
            wrk.turnoverDecrease = -1.
            if wrk.err <> '' then wrk.err = wrk.err + "<br>".
            wrk.err = wrk.err + "Не проставлены обороты по первичному мониторингу".
        end.
        else do:
            if wrk.lastMonitoring = ? then wrk.turnoverDecrease = -1. /* не было проведено ни одного текущего/расширенного мониторинга */
            else do:
                if v-ob2 = 0 then do: /* не введены обороты по последнему проведенному текущему/расширенному мониторингу */
                    wrk.turnoverDecrease = -1.
                    if wrk.err <> '' then wrk.err = wrk.err + "<br>".
                    wrk.err = wrk.err + "Не проставлены обороты по последнему проведенному текущему/расширенному мониторингу".
                end.
                else do:
                    wrk.turnoverDecrease = round((v-ob1 - v-ob2) / v-ob1 * 100,2).
                    if wrk.turnoverDecrease < 0 then wrk.turnoverDecrease = 0.
                end.
            end.
        end.

        if wrk.lastMonitoring <> ? and wrk.fsDecline = '' then do:
            if wrk.err <> '' then wrk.err = wrk.err + "<br>".
            wrk.err = wrk.err + "Не проставлено наличие/отсутствие ухудшения фин. состояния".
        end.

        /* Проверка решений КК */
        for each txb.lnmoncln where txb.lnmoncln.lon = b-lon.lon and txb.lnmoncln.code = "kkres" and txb.lnmoncln.edt = ? use-index lncodepdt no-lock:
            if trim(lnmoncln.res-ch[1]) <> '' then do:
                if wrk.kkres <> '' then wrk.kkres = wrk.kkres + '; '.
                wrk.kkres = wrk.kkres + trim(lnmoncln.res-ch[1]).
            end.
        end.

        /* Дата утверждения КК */
        find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lndtkk" and txb.sub-cod.ccode = "msc" no-lock no-error.
        if avail txb.sub-cod then wrk.approvalDate = date(txb.sub-cod.rcode) no-error.

        /* Доля целевого использования кредита */
        find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lntgt" and txb.sub-cod.ccode = "10" no-lock no-error.
        find first txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = "purpose" no-lock no-error.
        if not avail txb.lnmoncln and avail txb.sub-cod then wrk.appropriateUseFundsPrc = -1. /* не требуется */
        else do:
            find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = "purpose" and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
            if avail txb.lnmoncln then wrk.appropriateUseFundsPrc = txb.lnmoncln.res-deci[1].
            else wrk.appropriateUseFundsPrc = -2.
        end.

        /* Реструктуризация */
        find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lnrestr" and txb.sub-cod.ccode = '01' no-lock no-error.
        if avail txb.sub-cod then wrk.isRestructured = "Да". else wrk.isRestructured = "Нет".

        /* Отрасль заемщика для ДР */
        find first txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lnotrdr" no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then do:
            find first txb.codfr where txb.codfr.codfr = "lnotrdr" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.industry = txb.codfr.name[1].
            else wrk.industry = '<' + txb.sub-cod.ccode + '>'.
        end.

        find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        if avail txb.loncon then do:
            find first txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
            if not avail txb.ofc then wrk.manager = "[" + txb.loncon.pase-pier + "]".
            else do:
                v-ofcname = trim(txb.ofc.name).
                wrk.manager = entry(1,v-ofcname," ").
                if num-entries(v-ofcname," ") > 1 then wrk.manager = wrk.manager + " " + caps(substring(entry(2,v-ofcname," "),1,1)) + ".".
                if num-entries(v-ofcname," ") > 2 then wrk.manager = wrk.manager + caps(substring(entry(3,v-ofcname," "),1,1)) + ".".
            end.
            if trim(txb.loncon.obes-pier) <> "" then do:
                find first txb.ofc where txb.ofc.ofc = txb.loncon.obes-pier no-lock no-error.
                if not avail txb.ofc then wrk.zalogManager = "[" + txb.loncon.obes-pier + "]".
                else do:
                    v-ofcname = trim(txb.ofc.name).
                    wrk.zalogManager = entry(1,v-ofcname," ").
                    if num-entries(v-ofcname," ") > 1 then wrk.zalogManager = wrk.zalogManager + " " + caps(substring(entry(2,v-ofcname," "),1,1)) + ".".
                    if num-entries(v-ofcname," ") > 2 then wrk.zalogManager = wrk.zalogManager + caps(substring(entry(3,v-ofcname," "),1,1)) + ".".
                end.
            end.
        end.

        wrk.riskManager = getRiskManager(s-ourbank).
        wrk.blocks = getBlocks(txb.lon.aaa).

        find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < dt and txb.ln%his.intrate > 0 no-lock no-error.
        if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
        else wrk.prem = txb.lon.prem.

        /*run lonbalcrc_txb('lon',txb.lon.lon,dt,"6,36",no,txb.lon.crc,output v-bal).
        wrk.prov = - v-bal * rates[txb.lon.crc].

        run lonbalcrc_txb('lon',txb.lon.lon,dt,"37",no,1,output v-bal).
        wrk.prov = wrk.prov - v-bal.*/

        run lonbalcrc_txb('lon',txb.lon.lon,dt,"41",no,txb.lon.crc,output v-bal).
        wrk.prov = - v-bal * rates[txb.lon.crc].

        /* ---- Провизии МСФО ---- */
        run lonbalcrc_txb('lon',txb.lon.lon,dt,"6,36,37",no,txb.lon.crc,output v-provmsfo).
        v-provmsfo = - v-provmsfo * rates[txb.lon.crc].
        wrk.provmsfo = v-provmsfo.

        /* -------- Штраф -------- */
        run lonbalcrc_txb('lon',txb.lon.lon,dt,"5,16",no,txb.lon.crc,output v-shtraf).
        v-shtraf = v-shtraf * rates[txb.lon.crc].
        wrk.shtraf = v-shtraf.

        wrk.opnamt = txb.lon.opnamt * rates[txb.lon.crc].

        /*
        for each txb.crc no-lock:
            run lonbalcrc_txb('lon',txb.lon.lon,dt,"19",no,txb.crc.crc,output v-bal).
            wrk.zalog = wrk.zalog + v-bal * rates[txb.crc.crc].
        end.
        */
        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
            if wrk.zalog <> '' then wrk.zalog = wrk.zalog + '; '.
            wrk.zalog = wrk.zalog + txb.lonsec1.prm + ', ' + txb.lonsec1.pielikums[3].
        end.

        /*------- Залог недвижимого имущества -------*/
        v-nedvij = 0.
        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = 2 no-lock:
            v-nedvij = v-nedvij + txb.lonsec1.secamt.
        end.
        wrk.nedvij = v-nedvij * rates[txb.lon.crc].

        /*------- Залог движимого имущества -------*/
        v-dvij = 0.
        for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and (txb.lonsec1.lonsec = 1 or txb.lonsec1.lonsec = 3 or txb.lonsec1.lonsec = 4) no-lock:
            v-dvij = v-dvij + txb.lonsec1.secamt.
        end.
        wrk.dvij = v-dvij * rates[txb.lon.crc].

        /* просрочки */
        run lonbalcrc_txb('lon',txb.lon.lon,dt,"7,9,4",no,txb.lon.crc,output v-bal).
        wrk.overdue = v-bal * rates[txb.lon.crc].
        run lonbalcrc_txb('lon',txb.lon.lon,dt,"16,5",no,1,output v-bal).
        wrk.overdue = wrk.overdue + v-bal.

        run lndayspry_txb(txb.lon.lon,dt,no,output v-days_od,output v-days_prc,output wrk.maxDaysOverdue).
        if v-days_od > v-days_prc then wrk.daysOverdue = v-days_od. else wrk.daysOverdue = v-days_prc.

        v-bal7 = 0.
        for each txb.lonres where txb.lonres.lon = lon.lon and txb.lonres.lev = 7 no-lock use-index jdt:
            if txb.lonres.dc = 'd' then do:
                if v-bal7 = 0 and txb.lonres.amt > 0 then wrk.overdueCount = wrk.overdueCount + 1.
                v-bal7 = v-bal7 + txb.lonres.amt.
            end.
            else do:
                v-bal7 = v-bal7 - txb.lonres.amt.
                if v-bal7 <= 0 then v-bal7 = 0.
            end.
        end. /* for each txb.lonres */

        /* отрасль */
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = 'ecdivis' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            wrk.industry = txb.sub-cod.ccode + " - " + txb.codfr.name[1].
        end.
        else wrk.industry = "НЕ ПРОСТАВЛЕНА".

        /* объект кредитования */
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lntgt' no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.lnObject = trim(txb.codfr.name[1]).
        end.

        /* аффилированнность */
        if txb.cif.jss <> '' then do:
            find first prisv where prisv.rnn = txb.cif.jss and prisv.rnn <> '' no-lock no-error.
            if avail prisv then do:
                find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                if avail txb.codfr then wrk.isAffil = txb.codfr.name[1]. else wrk.isAffil = '[' + txb.codfr.code + ']'.
            end.
            else do:
                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                find first prisv where trim(prisv.name) = nm no-lock no-error.
                if avail prisv then do:
                    find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                    if avail txb.codfr then wrk.isAffil = txb.codfr.name[1]. else wrk.isAffil = '[' + txb.codfr.code + ']'.
                end.
                else wrk.isAffil = "Не связанное лицо".
            end.
        end.
        else do:
            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
            find first prisv where trim(prisv.name) = nm no-lock no-error.
            if avail prisv then do:
                find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock no-error.
                if avail txb.codfr then wrk.isAffil = txb.codfr.name[1]. else wrk.isAffil = '[' + txb.codfr.code + ']'.
            end.
            else wrk.isAffil = "Не связанное лицо".
        end.

        find last txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = "fin-hoz" and txb.lnmoncln.edt <> ? use-index lncodeedt no-lock no-error.
        if avail txb.lnmoncln then wrk.lastMonitoring = txb.lnmoncln.edt.

    end. /* for each txb.lon */

end.

