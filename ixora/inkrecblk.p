/* inkrecblk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        24/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        02/12/2008 alex - убрал перикодировку DOS
        10/12/2008 alex - убрал снятие специнструкций с валютных счетов
        25/12/2008 alex - добавил валюту счета (если была указана)
        25/12/2008 alex - копирование на терминал
        04/05/2009 galina - добавила статусы 12 (счет не найден),13 (счет закрыт)
                            статус 20 проставляем при несовпадении суммы, даты или номера отзываемого ИР
        05.05.2009 galina - исправила округление
        06.05.2009 galina - преобразовала inc100.dt в дату
        26.08.2009 galina - обработала случай, если ИР удалено в ручную
        27.08.2009 galina - перекопиляция
        12/10/2009 galina - исправила проставление статуса отзыва
        12/11/2009 galina - исправила запись в истории aas_hist при отзыве
        28/10/2010 madiyar - перекомпиляция
        10/03/2011 evseev - есть отзыв, но нет ИР, то группа рассылки ЦО
        24/05/2011 evseev - замена условий integer(aas.fnum) = inc100.num на aas.fnum = string(inc100.num)
        02/06/2011 evseev - переход на ИИН/БИН
        23/06/2011 evseev - запись в inchist "RECINC"
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
        23/06/2011 evseev - исправил inc100 на inkor1
        24/06/2011 evseev - добавил пробел между комментом и unix silent
        09/09/2011 evseev - исправил проблему подтягивания города из cmp
        28/04/2012 evseev - логирование значения aaa.hbal
        20.06.2012 evseev - добавил mn. исправил ошибку транзакционных блоков
        13.03.2013 evseev - tz-1759

*/

def shared var g-today  as date.
def shared var g-ofc    like ofc.ofc.

def var v-mt100out  as char no-undo.
def var v-exist1    as char no-undo.

def var op_kod      as char no-undo.
def var v-fsum      like aas.fsum.
def var v-docdat    like aas.docdat.
def var v-knp       like aas.knp.
def var v-kbk       like aas.kbk.
def var t-sum       as decimal.
def var v-knaaa     like aaa.aaa.
def var v-who       like aas.who.
def var v-whn       like aas.whn.
def var v-ofc1      as char.
def var v-jhink     like jh.jh.
def var v-summ      as deci no-undo.
def var s-vcourbank as char.
def var v-usrglacc  as char.
def var vparam2     as char.
def var d-SumOfPlat as decimal.
def var vdel        as char initial "^".
def var rcode       as inte.
def var rdes        as char.
def var v-stat      like inkor1.stat no-undo.
def var v-kref      as char no-undo.
def var v-counter   as int no-undo.
def var v-text      as char no-undo.
def var v-bankbik   as char no-undo.
def var v-kol       as int no-undo.
def var v-file      as char no-undo.
def var v-maillist as char no-undo.
def var v-mailmessage as char.
def var v-aaalist as char.
def var v-reflist as char.
def var i as integer no-undo.
def var v-bank as char.
def var s-aaa as char.

def buffer b-inkor1 for inkor1.

def stream mt400.

{comm-txb.i}
{get-dep.i}
{chbin.i}
{aas2his.i &db = "bank"}

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then return.
s-vcourbank = trim(sysc.chval).

def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

v-aaalist = ''.
v-reflist = ''.
for each inkor1 where inkor1.stat = '' no-lock:
    v-bank = 'TXB' + substr(inkor1.aaa,19,2).
    find first comm.txb where comm.txb.bank = v-bank and comm.txb.consolid no-lock no-error.
    if not avail comm.txb then v-bank = "txb00".
    if v-bank <> s-vcourbank then next.
    find first inc100 where inc100.ref eq inkor1.inkref and inc100.iik eq inkor1.aaa no-lock no-error.

    if not avail inc100 then do :
        find first b-inkor1 where b-inkor1.inkref = inkor1.inkref exclusive-lock.
        b-inkor1.stat = "20".
        find current b-inkor1 no-lock.
        if v-reflist <> '' then v-reflist = v-reflist + ','.
        v-reflist = v-reflist + inkor1.ref.
        next.
    end.
    if inc100.bank <> s-vcourbank then next.
    if round(inkor1.sum,2) <> round(inc100.sum,2) or (inkor1.inknum <> inc100.num) or (inkor1.inkdt <> date(inc100.dt)) then do:
        find first b-inkor1 where b-inkor1.inkref = inkor1.inkref exclusive-lock.
        b-inkor1.stat = "20".
        find current b-inkor1 no-lock.
        if v-reflist <> '' then v-reflist = v-reflist + ','.
        v-reflist = v-reflist + b-inkor1.ref.
        next.
    end.
    /*do transaction:*/
        v-stat = ''.
        if inc100.mnu eq "returned" then v-stat = "21".
        if inc100.mnu eq "paid" then v-stat = "22".
        if inc100.mnu ne "returned" and inc100.mnu ne "paid" and inc100.stat = 1 then do:
            find last aas where aas.aaa = inc100.iik and aas.fnum = string(inc100.num) exclusive-lock no-error.
            find last aaa where aaa.aaa = inc100.iik exclusive-lock no-error.
            if avail aaa then find last cif where cif.cif = aaa.cif no-lock no-error.
            if not avail aaa then v-stat = '12'.
            if aaa.sta = 'C' or aaa.sta = 'E' then v-stat = '13'.
            if avail aas and (avail aaa and aaa.sta <> 'C' and aaa.sta <> 'E') and avail cif then do:
                aas.irsts = "отозван".
                run savelog("aaahbal", "inkrecblk ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
                aaa.hbal = aaa.hbal - aas.chkamt.
                aas.chkamt = 0.
                aas.tim = time.
                aas.mn = substr(aas.mn,1,4) + "1".
                op_kod = 'O'.
                aas.whn = g-today.
                aas.who = g-ofc.
                aas.docnum1 = string(inkor1.num).
                aas.docdat1 = inkor1.dt.
                s-aaa = aaa.aaa.
                RUN aas2his.
                v-fsum = aas.fsum.
                v-docdat = aas.docdat.
                v-knp = aas.knp.
                v-kbk = aas.kbk.
                v-summ = decimal(aas.docprim).
                /* помечаем как отозванный (inc100.mnu) */
                find first inc100 where inc100.iik eq aas.aaa and string(inc100.num) eq aas.fnum exclusive-lock no-error.
                if avail inc100 then do:
                    inc100.mnu = "recall".
                    find current inc100 no-lock.
                end.
                delete aas.

                /*с внебаланса*/
                t-sum = 0.
                def buffer b2-aas for aas.
                for each b2-aas where b2-aas.aaa = inc100.iik and lookup(string(b2-aas.sta), "11,2,4,5,15,6,7,9,16") <> 0 no-lock:
                    t-sum = t-sum + b2-aas.chkamt.
                end.
                run savelog("aaahbal", "inkrecblk ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
                aaa.hbal = aaa.hbal - t-sum.
                d-SumOfPlat = v-summ.
                {vnebal.i}
                run savelog("aaahbal", "inkrecblk ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
                aaa.hbal = aaa.hbal + t-sum.
                v-knaaa = aaa.aaa.
                v-stat = "01".
            end. else do:
                if not avail aas then do:
                    find first aas_his where aas_his.aaa = inc100.iik and aas_his.fnum = string(inc100.num) no-lock no-error.
                    if avail aas_his then v-stat = '20'. else v-stat = "err".
                end.
            end.
        end.
        if v-stat <> '' then do:
            find first b-inkor1 where b-inkor1.inkref = inkor1.inkref exclusive-lock.
            b-inkor1.stat = v-stat.
            find current b-inkor1 no-lock.
            if v-stat <> 'err' then do:
                if v-reflist <> '' then v-reflist = v-reflist + ','.
                v-reflist = v-reflist + b-inkor1.ref.
            end.
        end.
    /*end.*/
end.

if v-reflist <> '' then do:
    v-mt100out = "/data/export/inkarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
    input through value( "find " + v-mt100out + ";echo $?").
    repeat:
        import unformatted v-exist1.
    end.
    if v-exist1 <> "0" then do:
        unix silent value ("mkdir " + v-mt100out).
        unix silent value("chmod 777 " + v-mt100out).
    end.
    /*do transaction:*/
        find first pksysc where pksysc.sysc = "inccou" no-lock no-error.
        if avail pksysc then v-counter = pksysc.inval + 1.
        else do:
            run savelog( "inkps", "inkrecall: Ошибка определения текущего значения счетчика сообщений!").
            return.
        end.
        find first pksysc where pksysc.sysc = "inccou" exclusive-lock no-error.
        if avail pksysc then pksysc.inval = v-counter.
        find current pksysc no-lock.
    /*end.*/
    /* формирование ответного сообщения по полученным отзывам инкассовых распоряжений */
    v-file = 'INC' + string(v-counter, "9999999999999") + ".txt".
    v-kref = string(v-counter, "999999").
    output stream mt400 to value(v-file).
    v-text = "\{1:F01K054700000000010" + v-kref + "\}".
    put stream mt400 unformatted v-text skip.
    v-text = "\{2:I998KNALOG000000N2020\}".
    put stream mt400 unformatted v-text skip.
    v-text = "\{4:".
    put stream mt400 unformatted v-text skip.
    v-text = ":20:INC" + string(v-counter, "9999999999999").
    put stream mt400 unformatted v-text skip.
    v-text = ":12:400".
    put stream mt400 unformatted v-text skip.
    v-text = ":77E:FORMS/P02/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Подтверждение о принятии отзывов инк. расп.".
    put stream mt400 unformatted v-text skip.
    {sysc.i}
    v-bankbik = get-sysc-cha("clecod").
    v-text = "/BANK/" + v-bankbik.
    put stream mt400 unformatted v-text skip.
    v-kol = 0.
    v-mailmessage = ''.
    do i = 1 to num-entries(v-reflist):
        find first inkor1 where inkor1.ref = entry(i,v-reflist) no-lock no-error.
        if avail inkor1 then do:
            if v-bin then v-text = "//07/" + inkor1.bin + "/" + string(inkor1.aaa,"x(20)") + inkor1.reschar[5] + "/" + string(inkor1.num) + "/" + inkor1.ref + "/" + inkor1.stat.
            else v-text = "//07/" + inkor1.jss + "/" + string(inkor1.aaa,"x(20)") + inkor1.reschar[5] + "/" + string(inkor1.num) + "/" + inkor1.ref + "/" + inkor1.stat.
            put stream mt400 unformatted v-text skip.
            v-kol = v-kol + 1.
            if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
            if v-bin then v-mailmessage = v-mailmessage + inkor1.filename + " Отзыв ИР=" + string(inkor1.num) + " БИН=" + inkor1.bin + " счет=" + inkor1.aaa + " sum=" + string(inkor1.sum) + " N ИР=" + string(inkor1.inknum).
            else v-mailmessage = v-mailmessage + inkor1.filename + " Отзыв ИР=" + string(inkor1.num) + " РНН=" + inkor1.jss + " счет=" + inkor1.aaa + " sum=" + string(inkor1.sum) + " N ИР=" + string(inkor1.inknum).

            find first aaa where aaa.aaa = inkor1.aaa no-lock.
            if avail aaa then do:
                if lookup (aaa.lgr , "138,139,140,143,144,145") > 0 then do:
                   run mail("DPC@fortebank.com", "METROCOMBANK <abpk@fortebank.com>", "Прием отзыва инкассовых распоряжений ",
                       inkor1.filename + " Отзыв ИР=" + string(inkor1.num) + " БИН=" + inkor1.bin + " счет=" + inkor1.aaa + " sum=" + string(inkor1.sum) + " N ИР=" + string(inkor1.inknum)
                       , "1", "", "").
                end.
            end.


            create inchist.
            assign inchist.ref = "RECINC" + string(v-counter, "9999999999999")
                   inchist.incref = inkor1.ref
                   inchist.rdt = g-today
                   inchist.rtm = time.
        end.
    end.
    v-text = "/TOTAL/" + string(v-kol).
    put stream mt400 unformatted v-text skip.
    v-text = "-\}".
    put stream mt400 unformatted v-text skip.
    output stream mt400 close.
    unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /*  положили в терминал для отправки */
    unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */
end.

def var v-city as char.
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
                  else. if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               v-mailmessage = v-city + "\n\n" + v-mailmessage.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием отзывов инкассовых распоряжений " + v-city, v-mailmessage, "1", "", "").
            end.
        end.
    end.
end. /* if v-mailmessage <> '' */

