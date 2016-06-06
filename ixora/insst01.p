/*inkst01.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отправка уведомления о возврате РПРО при закрытии счета
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        13/05/2011 evseev - поиск закрытых счетов по филиалам
        23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
        12/10/2011 evseev - переход на ИИН/БИН
        17/11/2011 evseev - поправил if not v-res then return.
        23/11/2011 evseev - уведомлять если не recall
        23/11/2011 evseev - добавил логирование
        27/04/2012 evseev - в начале составляем список РПРО по которым закрыты все счета исключая текущий счет для закрытия
        28/04/2012 evseev - логирование значения aaa.hbal
        11/05/2012 evseev - изменил логирование, убрал оповещение

*/
{global.i}
{chbin.i}
def input parameter v-aaa like aaa.aaa.
/*def input parameter v-num as integer.*/
def var v-kref     as char    no-undo.
def var v-text     as char    no-undo.
def var v-bankbik  as char    no-undo.
def var v-file     as char    no-undo.
def var v-counter  as int     no-undo.

def var v-instype  as char    no-undo.

def var v-mt100out as char    no-undo.
def var v-exist1   as char    no-undo.
def var v-res      as logical no-undo.
def var i          as integer no-undo.
def stream mt400.
def buffer b-insin for insin.
def var op_kod as char no-undo.
def var s-aaa as char.

{aas2his.i &db = "bank"}

/*message "v-listRPRO". pause.*/
/*составляем список РПРО по которым закрыты все счета исключая текущий счет для закрытия*/
def var v-listRPRO as char. /*список референсов РПРО в которых все счета закрыты, кроме текущего*/
v-listRPRO = "".
for each insin where lookup(v-aaa,insin.blkaaa) > 0 no-lock:

    run findclsaaatxb(v-aaa, insin.blkaaa, output v-res).

    if v-res then do:
       if v-listRPRO <> "" then v-listRPRO = v-listRPRO + ",".
       v-listRPRO = v-listRPRO + insin.ref.
    end.
end.


def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
    if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
    else run log_write("Не найден параметр lbeks в sysc!").
    return.
end.
v-term = sysc.chval.

v-mt100out = "/data/export/insarc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-mt100out + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-mt100out).
    unix silent value("chmod 777 " + v-mt100out).
end.

for each insin where lookup(v-aaa,insin.blkaaa) > 0 no-lock:
    run savelog( "insst01", insin.ref + " 1) " + v-aaa).
    if insin.mnu = 'recall' or insin.mnu = "returned" then do:
       if insin.mnu <> 'recall' then do:
          run savelog( "insst01", insin.ref + " 1.1) " + v-aaa + ": Закрытие счета по которому был возврат РПРО").
          run mail("id00787@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "ОШИБКА: Закрытие счета по которому был возврат РПРО",
              v-aaa + " insis.ref = " + insin.ref, "1", "", "").
       end.
       next.
    end.
    /*удаляем РПРО проставляем статус возврата*/
    do transaction:
        find last aas where aas.aaa = v-aaa and aas.docnum = insin.numr exclusive-lock no-error.
        find last aaa where aaa.aaa = v-aaa exclusive-lock no-error.
        if avail aas and avail aaa then do:
            aas.docdat1  = g-today.
            aas.docprim1 = "Ворзврат. Счет закрыт".
            op_kod= 'D'.
            aas.who = g-ofc.
            aas.whn = g-today.
            aas.tim = time.
            aas.mn = substr(aas.mn,1,4) + "2".
            s-aaa = aaa.aaa.
            run aas2his.
            run savelog("aaahbal", "insst01 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
            aaa.hbal = aaa.hbal - aas.chkamt.

            delete aas.
            run savelog( "insst01", insin.ref + " 2) " + v-aaa + ": Удаление из aas").
        end.
    end.
    if  lookup (insin.ref,v-listRPRO) > 0 then
        run savelog( "insst01", insin.ref + " 3) " + v-aaa + ": v-res = true. insin.blkaaa = " + insin.blkaaa).
    else
       run savelog( "insst01", insin.ref + " 3.1) " + v-aaa + ": v-res = false. insin.blkaaa = " + insin.blkaaa).
    if lookup (insin.ref,v-listRPRO) > 0 then /*все счета закрыты*/  do:
        /* помечаем как возврат (insin.mnu) */
        do transaction:
            find first b-insin where b-insin.numr = insin.numr and lookup(v-aaa,b-insin.blkaaa) > 0 exclusive-lock no-error.
            if avail b-insin then do:
               b-insin.mnu = "returned".
               run savelog( "insst01", insin.ref + " 4) " + v-aaa + ": помечаем как возврат (insin.mnu). b-insin.mnu = returned." ).
            end.
        end.
        do transaction:
            find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
            if avail pksysc then do:
                pksysc.inval = pksysc.inval + 1.
                v-counter = pksysc.inval.
                find current pksysc no-lock.
            end. else do:
                run savelog( "inkaaacls", "inkaaacls: Ошибка определения текущего значения счетчика сообщений!").
                return.
            end.
        end.
        v-kref = string(v-counter, "999999").
        v-file = 'INS' + string(v-counter, "9999999999999") + ".txt".
        run savelog( "insst01", insin.ref + " 5) " + v-aaa + ": Отправка уведомления v-kref = " + v-kref).
        output stream mt400 to value(v-file).

        v-text = "\{1:F01K054700000000010" + v-kref + "\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{2:I998KNALOG000000U3003\}".
        put stream mt400 unformatted v-text skip.

        v-text = "\{4:".
        put stream mt400 unformatted v-text skip.

        v-text = ":20:INC" + string(v-counter, "9999999999999").
        put stream mt400 unformatted v-text skip.

        v-text = ":12:400".
        put stream mt400 unformatted v-text skip.
        if insin.type = 'AC' then assign
                v-text    = ":77E:FORMS/ACV/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат РПРО налогопл."
                v-instype = "РПРО налогопл.".
        if insin.type = 'ACP' then assign
                v-text    = ":77E:FORMS/APV/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат РПРО агента ОПВ"
                v-instype = "РПРО агента ОПВ".
        if insin.type = 'ASD' then assign
                v-text    = ":77E:FORMS/ASV/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Возврат РПРО плательщика СО"
                v-instype = "РПРО плательщика СО".

        put stream mt400 unformatted v-text skip.

        {sysc.i}
        v-bankbik = get-sysc-cha("clecod").

        v-text = "/BANK/" + v-bankbik.
        put stream mt400 unformatted v-text skip.

        if v-bin then
            v-text = "/PLAT/" + insin.clbin + "/" + insin.clname.
        else
            v-text = "/PLAT/" + insin.clrnn + "/" + insin.clname.
        put stream mt400 unformatted v-text skip.

        v-text = "/REFDOC/" + string(year(insin.dtr) mod 1000,'99') + string(month(insin.dtr),'99') + string(day(insin.dtr),'99') + "/" + string(insin.numr) + "/" + insin.ref.
        put stream mt400 unformatted v-text skip.

        v-text = "/REASON/01".
        put stream mt400 unformatted v-text skip.

        v-text = "-\}".
        put stream mt400 unformatted v-text skip.

        output stream mt400 close.

        /* положили в терминал для отправки */
        unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).

        /* положили в архив отправленных */
        unix silent value("mv " + v-file + " " + v-mt100out).
        message "Отправлено уведомление о возврате " + v-instype + " ~nномер распоряжения " + string(insin.numr,'999999999')  + '~nДата распоряжения ' + string(insin.dtr,'99/99/9999') view-as alert-box title 'ВНИМАНИЕ'.

        do transaction:
            create inshist.
            assign
                inshist.outfile = "BRINS" + string(v-counter, "9999999999999")
                inshist.insref  = insin.ref
                inshist.rdt     = g-today
                inshist.rtm     = time.
        end. /* transaction */
    end.
end.