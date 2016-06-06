/* lnodnor2.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет % резерва по однородным кредитам
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
        25/01/2011 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        26/08/2013 Sayat(id01143) - ТЗ 1850 от 17/05/2013 "Изменения в расчет однородных кредитов по АФН"
*/

def shared var v-rezprc as deci no-undo extent 6.
def shared var g-today as date.

do transaction:
    find first txb.sysc where txb.sysc.sysc = "lnodnorf" exclusive-lock no-error.
    if not avail txb.sysc then do:
        create txb.sysc.
        assign txb.sysc.sysc = 'lnodnorf'
               txb.sysc.des = "Ставка по однородным кредитам".
    end.
    assign txb.sysc.daval = g-today
           txb.sysc.inval = time
           txb.sysc.chval = trim(string(v-rezprc[1],">>9.99")) + '|' + trim(string(v-rezprc[2],">>9.99")) + '|' + trim(string(v-rezprc[3],">>9.99")) + '|' + trim(string(v-rezprc[4],">>9.99")) + '|' + trim(string(v-rezprc[5],">>9.99")) + '|' + trim(string(v-rezprc[6],">>9.99")).
    find current txb.sysc no-lock.
end.

